--[[
   \   Cel Shading Tool ]] local version = "1.2" --[[
 =o |   License: MIT
   /   Created by: Xalalau Xubilozo
  |
   \   Special thanks to HomemCamisinhaCósmico, Bomberman Maldito and Nick MBR
 =b |   https://github.com/xalalau/GMod/tree/master/Cel%20Shading%20Tool
   /   Enjoy! - Aproveitem!
]]

-- ----------------
-- SETUPS & GLOBALS
-- ----------------

TOOL.Category = "Render" 
TOOL.Name = "#Tool.cel.name"
TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" }
}

local cel_textures = {
    "models/debug/debugwhite",
    "models/shiny",
    "models/player/shared/ice_player",
}
local cel_ent_tbl = {}

local Frame

if ( SERVER ) then
    util.AddNetworkString( "net_left_click_start" )
    util.AddNetworkString( "net_left_click_finish" )
    util.AddNetworkString( "net_right_click" )
    util.AddNetworkString( "net_set_halo" )
    util.AddNetworkString( "net_remove_halo" )
    util.AddNetworkString( "net_enable_celshading_yourself" )
    util.AddNetworkString( "net_first_login_sync" )
    
    CreateConVar( "enable_gm13_for_players", "0", FCVAR_REPLICATED )
    CreateConVar( "enable_celshading_on_players", "1", FCVAR_REPLICATED )
end

if ( CLIENT ) then
    language.Add( "Tool.cel.name", "Cel Shading" )
    language.Add( "Tool.cel.desc", "Adds Cel Shading like effects to entities" )
    language.Add( "Tool.cel.left", "Apply" )
    language.Add( "Tool.cel.right", "Copy" )
    language.Add( "Tool.cel.reload", "Remove" )
    
    CreateClientConVar( "cel_h_mode" , 1, false, false )
    CreateClientConVar( "cel_h_colour_r" , 255, false, false )
    CreateClientConVar( "cel_h_colour_g" , 0, false, false )
    CreateClientConVar( "cel_h_colour_b" , 0, false, false )
    CreateClientConVar( "cel_h_size" , 0.3, false, false )
    CreateClientConVar( "cel_h_shake" , 0, false, false )
    CreateClientConVar( "cel_h_13_passes" , 1, false, false )
    CreateClientConVar( "cel_h_13_additive" , 1, false, false )
    CreateClientConVar( "cel_h_13_throughwalls" , 0, false, false )
    CreateClientConVar( "cel_apply_texture" , 0, false, false )
    CreateClientConVar( "cel_texture" , 1, false, false )
    CreateClientConVar( "cel_texture_mimic_halo" , 0, false, false )
    CreateClientConVar( "cel_colour_r" , 255, false, false )
    CreateClientConVar( "cel_colour_g" , 255, false, false )
    CreateClientConVar( "cel_colour_b" , 255, false, false )
    CreateClientConVar( "cel_sobel_thershold" , 0.2, false, false )
    CreateClientConVar( "cel_h_12_selected_halo" , 1, false, false )
    CreateClientConVar( "cel_h_12_size_2" , 0.3, false, false )
    CreateClientConVar( "cel_h_12_shake_2" , 0, false, false )
    CreateClientConVar( "cel_h_12_colour_r_2" , 0, false, false )
    CreateClientConVar( "cel_h_12_colour_g_2" , 0, false, false )
    CreateClientConVar( "cel_h_12_colour_b_2" , 0, false, false )
    CreateClientConVar( "cel_h_12_singleshake" , 0, false, false )
    CreateClientConVar( "cel_h_12_two_layers" , 1, false, false )
    CreateClientConVar( "cel_apply_yourself" , 0, false, false )
    
    CreateConVar( "enable_gm13_for_players", "0", FCVAR_REPLICATED )
    CreateConVar( "enable_celshading_on_players", "1", FCVAR_REPLICATED )
end

-- -------------
-- HALO
-- -------------

if ( CLIENT ) then
    local pos, ang, size, shake

    local cel_mat = Material( "pp/sobel" )
    cel_mat:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )

    -- https://facepunch.com/showthread.php?t=1337232
    hook.Add( "PostDrawOpaqueRenderables", "PlayerBorders", function()
        if table.Count( cel_ent_tbl ) > 0 then
            for k,v in pairs( cel_ent_tbl ) do
                if ( !IsValid( v[1] ) ) then
                    cel_ent_tbl[k] = nil  -- Clean the table
                else
                    if ( v[1].cel.Mode == 1 ) then -- Sobel PP effect (light / works / players)
                        render.ClearStencil()
                        render.SetStencilEnable( true )
                            render.SetStencilWriteMask( 255 )
                            render.SetStencilTestMask( 255 )
                            render.SetStencilReferenceValue( 1 )
                            render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
                            render.SetBlend( 0 )
                            if ( v[1].cel.Color ) then
                                v[1]:SetColor( v[1].cel.Color )
                            end
                            v[1]:DrawModel()
                            render.SetBlend( 1 )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            render.UpdateScreenEffectTexture();
                            cel_mat:SetFloat( "$threshold", 0.15 - v[1].cel.SobelThershold * 0.15 )
                            v[1]:DrawModel()
                            render.SetMaterial( cel_mat );
                            render.DrawScreenQuad();
                        render.SetStencilEnable( false )
                    elseif ( v[1].cel.Mode == 2 ) then -- GMod 12 halos (light / scaling problems / players)
                        pos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 10
                        ang = LocalPlayer():EyeAngles()
                        ang = Angle( ang.p + 90, ang.y, 0 )
                        shake = math.Rand( 0, v[1].cel.Layer1.Shake )
                        render.ClearStencil()
                        render.SetStencilEnable( true )
                            render.SetStencilWriteMask( 255 )
                            render.SetStencilTestMask( 255 )
                            render.SetStencilReferenceValue( 15 )
                            render.SetStencilFailOperation( STENCILOPERATION_KEEP )
                            render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
                            render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
                            render.SetBlend( 0 )
                            local addsizefromlayer2onlayer1 = 0
                            if ( v[1].cel.Layers == 1 ) then
                                addsizefromlayer2onlayer1 = v[1].cel.Layer2.Size / 2 + 1
                            end
                            v[1]:SetModelScale( v[1].cel.Layer1.Size / 2 + addsizefromlayer2onlayer1 + shake / 15, 0 )
                            v[1]:DrawModel()
                            v[1]:SetModelScale( 1,0 )
                            render.SetBlend( 1 )
                            render.SetStencilPassOperation( STENCIL_KEEP )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            cam.Start3D2D( pos,ang,1 )
                                surface.SetDrawColor( v[1].cel.Layer1.Color )
                                surface.DrawRect( -ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2 )
                            cam.End3D2D()
                            v[1]:DrawModel()
                        render.SetStencilEnable( false )
                        if ( v[1].cel.Layers == 1 ) then
                            if ( v[1].cel.SingleShake == 0 ) then
                                shake = math.Rand( 0, v[1].cel.Layer2.Shake )
                            end
                            render.ClearStencil()
                            render.SetStencilEnable( true )
                                render.SetStencilWriteMask( 255 )
                                render.SetStencilTestMask( 255 )
                                render.SetStencilReferenceValue( 15 )
                                render.SetStencilFailOperation( STENCILOPERATION_KEEP )
                                render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
                                render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
                                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
                                render.SetBlend( 0 )
                                v[1]:SetModelScale( v[1].cel.Layer2.Size / 2 + 1 + shake / 15, 0 )
                                v[1]:DrawModel()
                                v[1]:SetModelScale( 1,0 )
                                render.SetBlend( 1 )
                                render.SetStencilPassOperation( STENCIL_KEEP )
                                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                                cam.Start3D2D( pos,ang,1 )
                                    surface.SetDrawColor( v[1].cel.Layer2.Color )
                                    surface.DrawRect( -ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2 )
                                cam.End3D2D()
                                v[1]:DrawModel()
                            render.SetStencilEnable( false )
                        end
                    elseif ( v[1].cel.Mode == 3 ) then -- GMod 13 halos (heavy / works / admins)
                        size = v[1].cel.Size * 5 + math.Rand( 0, v[1].cel.Shake )
                        halo.Add( v, v[1].cel.Color, size, size, v[1].cel.Passes, v[1].cel.Additive, v[1].cel.ThroughWalls )
                    end
                end
            end
        end
    end )

    net.Receive( "net_set_halo", function()
        local ent = net.ReadEntity()
        local h_data = net.ReadTable()

        for k,v in pairs( cel_ent_tbl ) do
            if ( table.HasValue( v, ent ) ) then
                cel_ent_tbl[k] = nil
            end
        end

        ent.cel = h_data
        table.insert( cel_ent_tbl, { ent } )
    end )

    net.Receive( "net_remove_halo", function()
        local ent = net.ReadEntity()

        for k,v in pairs( cel_ent_tbl ) do
            if ( table.HasValue( v, ent ) ) then
                cel_ent_tbl[k] = nil
            end
        end

        ent.cel = nil
    end )
end

local function SetHalo( ply, ent, h_data )
    if ( SERVER ) then
        ent.cel = h_data

        timer.Create( "DuplicatorFix", 0.1, 1, function()
            for _,v in pairs( player.GetAll() ) do
                net.Start( "net_set_halo" )
                net.WriteEntity( ent )
                net.WriteTable( h_data )
                net.Send( v )
            end

            table.insert( cel_ent_tbl, { ent } )
            duplicator.StoreEntityModifier( ent, "Cel_Halo", h_data )
        end)
    end
end
duplicator.RegisterEntityModifier( "Cel_Halo", SetHalo )

local function RemoveHalo( ent )
    if ( SERVER ) then
        ent.cel = nil

        for k,v in pairs( cel_ent_tbl ) do
            if ( table.HasValue( v, ent ) ) then
                cel_ent_tbl[k] = nil
            end
        end

        for _,v in pairs( player.GetAll() ) do
            net.Start( "net_remove_halo" )
            net.WriteEntity( ent )
            net.Send( v )
        end

        duplicator.ClearEntityModifier( ent, "Cel_Halo" )
    end
end

-- -------------
-- Color
-- -------------

local function SetColor( ply, ent, c_data )
    if ( SERVER ) then
        if ( c_data.Color ) then
            if ( c_data.Mode == 2 ) then
                ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
            else
                ent:SetRenderMode( RENDERMODE_NORMAL )
            end
            ent:SetColor( c_data.Color )
            if ( c_data.Mode == 1 ) then
                ent:PhysWake()
            end
        end

        duplicator.StoreEntityModifier( ent, "Cel_Colour", c_data )
    end
    duplicator.RegisterEntityModifier( "Cel_Colour", SetColor )
end

local function RemoveColor ( ent )
    if ( SERVER ) then
        SetColor( nil, ent, { Color = Color( 255, 255, 255, 255 ), Mode = ent.cel.Mode } )
        duplicator.ClearEntityModifier( ent, "Cel_Colour" )
    end
end

-- -------------
-- MATERIAL
-- -------------

local function SetMaterial( ply, ent, t_data )
    if ( SERVER ) then
        ent:SetMaterial( t_data.MaterialOverride )
        duplicator.StoreEntityModifier( ent, "Cel_Material", t_data )
    end
    duplicator.RegisterEntityModifier( "Cel_Material", SetMaterial )
end

local function RemoveMaterial ( ent )
    if ( SERVER ) then
        SetMaterial( nil, ent, { MaterialOverride = "" } )
        duplicator.ClearEntityModifier( ent, "Cel_Material" )
    end
end

-- -------------
-- GENERAL
-- -------------

if ( SERVER ) then
    hook.Add( "PlayerInitialSpawn", "set halo table and options", function ( ply )
        if ( table.Count( cel_ent_tbl ) > 0 ) then
            timer.Create( "FSpawnFix", 3, 1, function()
                for _,v in pairs( cel_ent_tbl ) do
                    net.Start( "net_set_halo" )
                    net.WriteEntity( v[1] )
                    net.WriteTable( v[1].cel )
                    net.Send( ply )
                end
                net.Start( "net_first_login_sync" )
                net.WriteInt( GetConVar( "enable_gm13_for_players" ):GetInt(), 2 )
                net.WriteInt( GetConVar( "enable_celshading_on_players" ):GetInt(), 2 )
                net.Send( ply )
            end)
        end
    end)

    net.Receive( "net_enable_celshading_yourself", function( _, ply )
        ply.celserver = net.ReadTable()
        ply.cel = {}
    end)
end

if ( CLIENT ) then
    net.Receive( "net_first_login_sync", function()
        RunConsoleCommand( "enable_gm13_for_players", tostring( net.ReadInt( 2 ) ) )
        RunConsoleCommand( "enable_celshading_on_players", tostring( net.ReadInt( 2 ) ) )
    end )
end

-- -------------
-- PANEL
-- -------------

if ( CLIENT ) then

    function BuildPanel()
        -- --------
        -- WINDOW:
        -- --------
        
        local panelw = 510
        local panelh = 340
        
        if Frame then
            Frame:SetVisible( true )
            return
        end
        
        Frame = vgui.Create( "DFrame" )
            Frame:SetSize( panelw, panelh )
            Frame:SetPos( (ScrW() - panelw) / 2, (ScrH() - panelh) / 2 )
            Frame:SetTitle( "#Tool.cel.name" )
            Frame:SetVisible( false )
            Frame:SetDraggable( true )
            Frame:ShowCloseButton( true )
            Frame:SetDeleteOnClose( false )

        local sheet = vgui.Create( "DPropertySheet", Frame )
            sheet:Dock( FILL )

        local panel1 = vgui.Create( "DPanel", sheet )
            panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 112, 112, 112 ) ) end
            sheet:AddSheet( "General", panel1, "icon16/application_view_list.png" )

        local panel2 = vgui.Create( "DPanel", sheet )
            panel2.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 112, 112, 112 ) ) end
            sheet:AddSheet( "Modes", panel2, "icon16/star.png" )

        local panel3 = vgui.Create( "DPanel", sheet )
            panel3.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 112, 112, 112 ) ) end
            sheet:AddSheet( "Textures", panel3, "icon16/picture.png" )

        -- --------
        -- TAB 3:
        -- --------

        local TextureEnable = vgui.Create( "DCheckBoxLabel", panel3 )
            TextureEnable:SetPos( 10, 10 )
            TextureEnable:SetText( "Enable Textures" )
            TextureEnable:SetConVar( "cel_apply_texture" )
            TextureEnable:SetValue( GetConVar( "cel_apply_texture" ):GetInt() )
            TextureEnable:SizeToContents()

        local HaloSizeLabel = vgui.Create( "DLabel", panel3 )
            HaloSizeLabel:SetPos( 10, 32 )
            HaloSizeLabel:SetText( "Select:" )

        local TextureType = vgui.Create( "DComboBox", panel3 )
            TextureType:SetPos( 10, 57 )
            TextureType:SetSize( 190, 25 )
            TextureType:SetValue( cel_textures[GetConVar( "cel_texture" ):GetInt()] )
            for k,v in pairs( cel_textures ) do
                TextureType:AddChoice( cel_textures[k], k )
            end
            TextureType.OnSelect = function( panel, index, value )
                RunConsoleCommand( "cel_texture", tostring( index ) )
            end

        local TextureColorLabel = vgui.Create( "DLabel", panel3 )
            TextureColorLabel:SetPos( 210, 5 )
            TextureColorLabel:SetText( "Color:" )

        local TextureColor = vgui.Create( "DColorMixer", panel3 )
            local r, g, b
            TextureColor:SetSize( 266, 230 )
            TextureColor:SetPos( 210, 30 )
            TextureColor:SetPalette( true )
            TextureColor:SetAlphaBar( false )
            TextureColor:SetWangs( true )
            r = GetConVar( "cel_colour_r" ):GetInt()
            g = GetConVar( "cel_colour_g" ):GetInt()
            b = GetConVar( "cel_colour_b" ):GetInt()
            TextureColor:SetColor( Color( r, g, b ) )
            TextureColor.ValueChanged = function()
                local ChosenColor = TextureColor:GetColor()
                RunConsoleCommand( "cel_colour_r", tostring( ChosenColor.r ) )
                RunConsoleCommand( "cel_colour_g", tostring( ChosenColor.g ) )
                RunConsoleCommand( "cel_colour_b", tostring( ChosenColor.b ) )
            end

        local TextureMimic = vgui.Create( "DCheckBoxLabel", panel3 )
            TextureMimic:SetPos( 10, 95 )
            TextureMimic:SetText( "Use The Halo Color" )
            TextureMimic:SetConVar( "cel_texture_mimic_halo" )
            TextureMimic:SetValue( GetConVar( "cel_texture_mimic_halo" ):GetInt() )
            TextureMimic:SizeToContents()
            TextureMimic:SetVisible( false )
            function TextureMimic:OnChange( val )
                local r, g, b
                if ( val ) then
                    TextureColor:SetVisible( false )
                    TextureColorLabel:SetVisible( false )
                else
                    TextureColor:SetVisible( true )
                    TextureColorLabel:SetVisible( true )
                end
            end

		Frame:SetVisible( true )
		Frame:MakePopup()

        -- --------
        -- TAB 2:
        -- --------

        local HaloModelLabel = vgui.Create( "DLabel", panel2 )
            HaloModelLabel:SetPos( 10, 5 )
            HaloModelLabel:SetText( "Mode:" )

        local SobelLabel = vgui.Create( "DLabel", panel2 )
            SobelLabel:SetPos( 10, 60 )
            SobelLabel:SetText( "Thershold:" )

        local Sobel = vgui.Create( "DNumSlider", panel2 )
            Sobel:SetPos( -130, 75 )
            Sobel:SetSize( 340, 35 )
            Sobel:SetMin( 0.09 )
            Sobel:SetMax( 0.99 )
            Sobel:SetDecimals( 2 )
            Sobel:SetConVar( "cel_sobel_thershold" )

        local HaloSizeLabel = vgui.Create( "DLabel", panel2 )
            HaloSizeLabel:SetPos( 10, 60 )
            HaloSizeLabel:SetText( "Size:" )

        local HaloSize = vgui.Create( "DNumSlider", panel2 )
            HaloSize:SetPos( -130, 75 )
            HaloSize:SetSize( 340, 35 )
            HaloSize:SetMin( 0.1 )
            HaloSize:SetMax( 1 )
            HaloSize:SetDecimals( 2 )
            HaloSize:SetConVar( "cel_h_size" )

        local HaloShakeLabel = vgui.Create( "DLabel", panel2 )
            HaloShakeLabel:SetPos( 10, 105 )
            HaloShakeLabel:SetText( "Shake:" )

        local HaloShake = vgui.Create( "DNumSlider", panel2 )
            HaloShake:SetPos( -130, 120 )
            HaloShake:SetSize( 340, 35 )
            HaloShake:SetMin( 0 )
            HaloShake:SetMax( 10 )
            HaloShake:SetDecimals( 2 )
            HaloShake:SetConVar( "cel_h_shake" )

        local Halo13PassesLabel = vgui.Create( "DLabel", panel2 )
            Halo13PassesLabel:SetPos( 10, 150 )
            Halo13PassesLabel:SetText( "Passes:" )

        local Halo13Passes = vgui.Create( "DNumSlider", panel2 )
            Halo13Passes:SetPos( -130, 165 )
            Halo13Passes:SetSize( 340, 35 )
            Halo13Passes:SetMin( 0 )
            Halo13Passes:SetMax( 10 )
            Halo13Passes:SetDecimals( 0 )
            Halo13Passes:SetConVar( "cel_h_13_passes" )

        local Halo13Aditive = vgui.Create( "DCheckBoxLabel", panel2 )
            Halo13Aditive:SetPos( 10, 215 )
            Halo13Aditive:SetText( "Aditive" )
            Halo13Aditive:SetValue( GetConVar( "cel_h_13_additive" ):GetInt() )
            function Halo13Aditive:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "cel_h_13_additive", tostring( aux ) )
            end

        local Halo13ThroughWalls = vgui.Create( "DCheckBoxLabel", panel2 )
            Halo13ThroughWalls:SetPos( 10, 240 )
            Halo13ThroughWalls:SetText( "Render Through The Map" )
            Halo13ThroughWalls:SetValue( GetConVar( "cel_h_13_throughwalls" ):GetInt() )
            function Halo13ThroughWalls:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "cel_h_13_throughwalls", tostring( aux ) )
            end

        local HaloColorLabel = vgui.Create( "DLabel", panel2 )
            HaloColorLabel:SetPos( 210, 5 )
            HaloColorLabel:SetText( "Color:" )

        local HaloColor = vgui.Create( "DColorMixer", panel2 )
            local r, g, b
            HaloColor:SetSize( 266, 230 )
            HaloColor:SetPos( 210, 30 )
            HaloColor:SetPalette( true )
            HaloColor:SetAlphaBar( false )
            HaloColor:SetWangs( true )
            r = GetConVar( "cel_h_colour_r" ):GetInt()
            g = GetConVar( "cel_h_colour_g" ):GetInt()
            b = GetConVar( "cel_h_colour_b" ):GetInt()
            HaloColor:SetColor( Color( r, g, b ) )
            HaloColor.ValueChanged = function()
                local ChosenColor = HaloColor:GetColor()
                if ( GetConVar( "cel_h_12_selected_halo" ):GetInt() == 1 || not GetConVar( "cel_h_12_two_layers" ):GetInt() ) then
                    RunConsoleCommand( "cel_h_colour_r", tostring( ChosenColor.r ) )
                    RunConsoleCommand( "cel_h_colour_g", tostring( ChosenColor.g ) )
                    RunConsoleCommand( "cel_h_colour_b", tostring( ChosenColor.b ) )
                else
                    RunConsoleCommand( "cel_h_12_colour_r_2", tostring( ChosenColor.r ) )
                    RunConsoleCommand( "cel_h_12_colour_g_2", tostring( ChosenColor.g ) )
                    RunConsoleCommand( "cel_h_12_colour_b_2", tostring( ChosenColor.b ) )
                end
            end

        local Halo12Choose2Label = vgui.Create( "DLabel", panel2 )
            Halo12Choose2Label:SetPos( 35, 192 )
            Halo12Choose2Label:SetText( "Select:" )

        local function Halo12Choose2Options ( choice )
            if ( choice == 1 ) then
                return "Layer 1"
            elseif ( choice == 2 ) then
                return "Layer 2"
            end
        end

        local Halo12Choose2 = vgui.Create( "DComboBox", panel2 )
            local r, g, b
            Halo12Choose2:SetPos( 75, 190 )
            Halo12Choose2:SetSize( 123, 25 )
            local choice = GetConVar( "cel_h_12_selected_halo" ):GetInt()
            Halo12Choose2:SetValue( Halo12Choose2Options(choice) )
            Halo12Choose2:AddChoice( "Layer 1", 1 )
            Halo12Choose2:AddChoice( "Layer 2", 2 )
            Halo12Choose2.OnSelect = function( panel, value )
                RunConsoleCommand( "cel_h_12_selected_halo", tostring( value ) )
                if ( value == 1 || not GetConVar( "cel_h_12_two_layers" ):GetInt() ) then
                    HaloSize:SetConVar( "cel_h_size" )
                    HaloShake:SetConVar( "cel_h_shake" )
                    r = GetConVar( "cel_h_colour_r" ):GetInt()
                    g = GetConVar( "cel_h_colour_g" ):GetInt()
                    b = GetConVar( "cel_h_colour_b" ):GetInt()
                    HaloColor:SetColor( Color( r, g, b ) )
                else
                    HaloSize:SetConVar( "cel_h_12_size_2" )
                    if ( GetConVar( "cel_h_12_singleshake" ):GetInt() == 1 ) then
                        HaloShake:SetConVar( "cel_h_shake" )
                    else
                        HaloShake:SetConVar( "cel_h_12_shake_2" )
                    end
                    r = GetConVar( "cel_h_12_colour_r_2" ):GetInt()
                    g = GetConVar( "cel_h_12_colour_g_2" ):GetInt()
                    b = GetConVar( "cel_h_12_colour_b_2" ):GetInt()
                    HaloColor:SetColor( Color( r, g, b ) )
                end
            end

        local Halo12SingleShake = vgui.Create( "DCheckBoxLabel", panel2 )
            Halo12SingleShake:SetPos( 35, 225 )
            Halo12SingleShake:SetText( "Single Shake" )
            Halo12SingleShake:SetValue( GetConVar( "cel_h_12_singleshake" ):GetInt() )
            function Halo12SingleShake:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                    HaloShake:SetConVar( "cel_h_shake" )
                else
                    HaloShake:SetConVar( "cel_h_12_shake_2" )
                end
                RunConsoleCommand( "cel_h_12_singleshake", tostring( aux ) )
            end

        local Halo12ExtraLayer = vgui.Create( "DCheckBoxLabel", panel2 )
            Halo12ExtraLayer:SetPos( 10, 165 )
            Halo12ExtraLayer:SetText( "Use Two Layers" )
            Halo12ExtraLayer:SetValue( GetConVar( "cel_h_12_two_layers" ):GetInt() )
            function Halo12ExtraLayer:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                    if ( GetConVar( "cel_h_mode" ):GetInt() == 2 ) then -- Used for hiding these options when reseting everything
                        Halo12Choose2Label:SetVisible( true )
                        Halo12Choose2:SetVisible( true )
                        Halo12SingleShake:SetVisible( true )
                    end
                else
                    Halo12Choose2Label:SetVisible( false )
                    Halo12Choose2:SetVisible( false )
                    Halo12SingleShake:SetVisible( false )
                end
                RunConsoleCommand( "cel_h_12_two_layers", tostring( aux ) )
            end

        local function ShowOptions( mode )
            if ( mode == 1 ) then
                SobelLabel:SetVisible( true )
                Sobel:SetVisible( true )
                HaloSizeLabel:SetVisible( false )
                HaloSize:SetVisible( false )
                HaloShakeLabel:SetVisible( false )
                HaloShake:SetVisible( false )
                Halo13PassesLabel:SetVisible( false )
                Halo13Passes:SetVisible( false )
                Halo13Aditive:SetVisible( false )
                Halo13ThroughWalls:SetVisible( false )
                HaloColorLabel:SetVisible( false )
                HaloColor:SetVisible( false )
                Halo12ExtraLayer:SetVisible( false )
                Halo12Choose2Label:SetVisible( false )
                Halo12Choose2:SetVisible( false )
                Halo12SingleShake:SetVisible( false )
                TextureMimic:SetVisible( false )
            elseif ( mode == 2 ) then
                SobelLabel:SetVisible( false )
                Sobel:SetVisible( false )
                HaloSizeLabel:SetVisible( true )
                HaloSize:SetVisible( true )
                HaloShakeLabel:SetVisible( true )
                HaloShake:SetVisible( true )
                Halo13PassesLabel:SetVisible( false )
                Halo13Passes:SetVisible( false )
                Halo13Aditive:SetVisible( false )
                Halo13ThroughWalls:SetVisible( false )
                HaloColorLabel:SetVisible( true )
                HaloColor:SetVisible( true )
                Halo12ExtraLayer:SetVisible( true )
                if ( GetConVar( "cel_h_12_two_layers" ):GetInt() == 1 ) then
                    Halo12Choose2Label:SetVisible( true )
                    Halo12Choose2:SetVisible( true )
                    Halo12SingleShake:SetVisible( true )
                end
                TextureMimic:SetVisible( true )
            elseif ( mode == 3 ) then
                SobelLabel:SetVisible( false )
                Sobel:SetVisible( false )
                HaloSizeLabel:SetVisible( true )
                HaloSize:SetVisible( true )
                HaloShakeLabel:SetVisible( true )
                HaloShake:SetVisible( true )
                Halo13PassesLabel:SetVisible( true )
                Halo13Passes:SetVisible( true )
                Halo13Aditive:SetVisible( true )
                Halo13ThroughWalls:SetVisible( true )
                HaloColorLabel:SetVisible( true )
                HaloColor:SetVisible( true )
                Halo12ExtraLayer:SetVisible( false )
                Halo12Choose2Label:SetVisible( false )
                Halo12Choose2:SetVisible( false )
                Halo12SingleShake:SetVisible( false )
                TextureMimic:SetVisible( true )
            end
        end

        local function HaloChooseOptions ( choice )
            if ( choice == 1 ) then
                return "Sobel"
            elseif ( choice == 2 ) then
                return "GMod 12 Halo"
            elseif ( choice == 3 ) then
                return "GMod 13 Halo"
            end
        end

        local HaloChoose = vgui.Create( "DComboBox", panel2 )
            HaloChoose:SetPos( 10, 30 )
            HaloChoose:SetSize( 190, 25 )
            local choice = GetConVar( "cel_h_mode" ):GetInt()
            HaloChoose:SetValue( HaloChooseOptions(choice) )
            ShowOptions( choice )
            HaloChoose:AddChoice( "Sobel", 1 )
            HaloChoose:AddChoice( "GMod 12 Halo", 2 )
            if ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) or ( GetConVar( "enable_gm13_for_players" ):GetInt() == 1 ) then
                HaloChoose:AddChoice( "GMod 13 Halo", 3 )
            end
            HaloChoose.OnSelect = function( panel, value )
                RunConsoleCommand( "cel_h_mode", tostring( value ) )
                ShowOptions( value )
            end

        -- --------
        -- TAB 1:
        -- --------

        local Description = vgui.Create( "DLabel", panel1 )
            Description:SetPos( 50, 20 )
            Description:SetSize( 490, 45)
            Description:SetText( "The rendering modes work good or bad depending on the entity, so do your tests.\n\n                    \"GMod 13 Halo\" mode is very good but causes a lot of lag!" )

        local ApplyOnYourself = vgui.Create( "DCheckBoxLabel", panel1 )
            ApplyOnYourself:SetPos( 155, 130 )
            ApplyOnYourself:SetText( "Apply The Effect On Yourself" )
            ApplyOnYourself:SetValue( GetConVar( "cel_apply_yourself" ):GetInt() )
            function ApplyOnYourself:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "cel_apply_yourself", tostring( aux ) )
                LocalPlayer().celserver = { Yourself = aux }
                LocalPlayer().cel = {}
                net.Start( "net_enable_celshading_yourself" )
                net.WriteTable( { Yourself = aux } )
                net.SendToServer()
            end

        local ApplyOnPlayers = vgui.Create( "DCheckBoxLabel", panel1 )
            ApplyOnPlayers:SetVisible( false )
            ApplyOnPlayers:SetPos( 137, 150 )
            ApplyOnPlayers:SetText( "Enable Rendering On Playermodels" )
            ApplyOnPlayers:SetValue( GetConVar( "enable_celshading_on_players" ):GetInt() )
            function ApplyOnPlayers:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "enable_celshading_on_players", tostring( aux ) )
            end

        local EnableHalo13ForPlayers = vgui.Create( "DCheckBoxLabel", panel1 )
            EnableHalo13ForPlayers:SetVisible( false )
            EnableHalo13ForPlayers:SetPos( 105, 175 )
            EnableHalo13ForPlayers:SetText( "Enable \"GMod 13 Halo\" Option On Clients Menus" )
            EnableHalo13ForPlayers:SetValue( GetConVar( "enable_gm13_for_players" ):GetInt() )
            function EnableHalo13ForPlayers:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "enable_gm13_for_players", tostring( aux ) )
            end

        if ( ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and not game.SinglePlayer() ) then
            ApplyOnYourself:SetPos( 155, 95 )
            ApplyOnPlayers:SetVisible( true )
            EnableHalo13ForPlayers:SetVisible( true )
        end

        local ResetButton = vgui.Create( "DButton", panel1 )
            local r, g, b
            ResetButton:SetPos( 180, 220 )
            ResetButton:SetText( "Reset Options!" )
            ResetButton:SetSize( 120, 30 )
            ResetButton.DoClick = function()
                HaloChoose:ChooseOption( HaloChooseOptions(1), 1)
                Halo12Choose2:ChooseOption( Halo12Choose2Options(1), 1 )
                timer.Create( "cel_Wait_", 0.3, 1, function() -- Wait for the changes
                    RunConsoleCommand( "cel_h_colour_r", "255" )
                    RunConsoleCommand( "cel_h_colour_g", "0" )
                    RunConsoleCommand( "cel_h_colour_b", "0" )
                    RunConsoleCommand( "cel_h_size", "0.3" )
                    RunConsoleCommand( "cel_h_shake", "0.00" )
                    RunConsoleCommand( "cel_h_13_passes", "1" )
                    RunConsoleCommand( "cel_h_13_additive", "1" )
                    RunConsoleCommand( "cel_h_13_throughwalls", "0" )
                    RunConsoleCommand( "cel_apply_texture", "0" )
                    RunConsoleCommand( "cel_texture", "1" )
                    RunConsoleCommand( "cel_colour_r", "255" )
                    RunConsoleCommand( "cel_colour_g", "255" )
                    RunConsoleCommand( "cel_colour_b", "255" )
                    RunConsoleCommand( "cel_sobel_thershold", "0.2" )
                    RunConsoleCommand( "cel_h_12_size_2", "0.3" )
                    RunConsoleCommand( "cel_h_12_shake_2", "0.00" )
                    RunConsoleCommand( "cel_h_12_colour_r_2", "0" )
                    RunConsoleCommand( "cel_h_12_colour_g_2", "0" )
                    RunConsoleCommand( "cel_h_12_colour_b_2", "0" )
                    RunConsoleCommand( "cel_apply_yourself", "0" )
                    RunConsoleCommand( "cel_texture_mimic_halo", "0" )

                    -- ApplyOnYourself:
                    ApplyOnYourself:SetValue( 0 )
                    -- ApplyOnPlayers:
                    ApplyOnPlayers:SetValue( 1 )
                    -- EnableHalo13ForPlayers:
                    EnableHalo13ForPlayers:SetValue( 0 )
                    timer.Create( "cel_Wait2_", 0.3, 1, function() -- Wait for the changes
                        -- HaloColor:
                        r = GetConVar( "cel_h_colour_r" ):GetInt()
                        g = GetConVar( "cel_h_colour_g" ):GetInt()
                        b = GetConVar( "cel_h_colour_b" ):GetInt()
                        HaloColor:SetColor( Color( r, g, b ) ) 
                        HaloColor:SetColor( Color( r, g, b ) ) -- It seems that GMod doesn't see this change at first, so here is another call
                        -- Halo12ExtraLayer:
                        Halo12ExtraLayer:SetValue( 1 )
                        -- Halo12SingleShake:
                        Halo12SingleShake:SetValue( 0 )
                        -- Halo13Aditive:
                        Halo13Aditive:SetValue( GetConVar( "cel_h_13_additive" ):GetInt() )
                        -- Halo13ThroughWalls:
                        Halo13ThroughWalls:SetValue( GetConVar( "cel_h_13_throughwalls" ):GetInt() )
                        -- TextureType:
                        TextureType:ChooseOption( cel_textures[1], 1 )
                        -- TextureColor:
                        r = GetConVar( "cel_colour_r" ):GetInt()
                        g = GetConVar( "cel_colour_g" ):GetInt()
                        b = GetConVar( "cel_colour_b" ):GetInt()
                        TextureColor:SetColor( Color( r, g, b ) )
                        TextureColor:SetColor( Color( r, g, b ) ) -- It seems that GMod doesn't see this change at first, so here is another call
                        -- TextureMimic:
                        TextureMimic:SetValue( GetConVar( "cel_texture_mimic_halo" ):GetInt() )
                    end)
                end)
            end
            
        local ToolVersion = vgui.Create( "DLabel", panel1 )
            ToolVersion:SetPos( 455, 245 )
            ToolVersion:SetSize( 30, 25)
            ToolVersion:SetText( "v" .. version )

    end
    concommand.Add( "cel_menu", BuildPanel )
    
    -- --------
    -- PANEL:
    -- --------
    function TOOL.BuildCPanel( CPanel )
        CPanel:AddControl( "Header", { Text = "#Tool.cel.name", Description = "#Tool.cel.desc" } )
        CPanel:Help( "" )
        CPanel:AddControl("Button" , { Text  = "Open Menu", Command = "cel_menu" })       
        CPanel:Help( "" )
        CPanel:ControlHelp( "Command: \"bind KEY cel_menu\"" )
    end
end

-- -------------
-- ACTIONS
-- -------------

if ( CLIENT ) then
    net.Receive( "net_right_click", function()
        local ent = net.ReadEntity()
        local mat = ent:GetMaterial()

        local texture_enabled = 0
        for k,v in pairs( cel_textures ) do
            if mat == v then
                texture_enabled = 1
                RunConsoleCommand ( "cel_texture", tostring( k ) )
            end
        end

        if ( ent == LocalPlayer() ) then
            RunConsoleCommand( "cel_apply_yourself", "1" )
        else
            RunConsoleCommand( "cel_apply_yourself", "0" )
        end

        RunConsoleCommand( "cel_apply_texture", tostring( texture_enabled ) )
        
        local clr = ent:GetColor()
        RunConsoleCommand( "cel_colour_r", tostring( clr.r ) )
        RunConsoleCommand( "cel_colour_g", tostring( clr.g ) )
        RunConsoleCommand( "cel_colour_b", tostring( clr.b ) )
        
        local mode = ent.cel.Mode
        RunConsoleCommand( "cel_h_mode", tostring( mode ) )

        if ( mode == 1 ) then
            RunConsoleCommand( "cel_sobel_thershold", tostring( ent.cel.SobelThershold ) )
            RunConsoleCommand( "cel_h_colour_r", tostring( 255 ) )
            RunConsoleCommand( "cel_h_colour_g", tostring( 255 ) )
            RunConsoleCommand( "cel_h_colour_b", tostring( 255 ) )
        elseif ( mode == 2 ) then
            RunConsoleCommand( "cel_h_size", tostring( ent.cel.Layer1.Size ) )
            RunConsoleCommand( "cel_h_shake", tostring( ent.cel.Layer1.Shake ) )
            RunConsoleCommand( "cel_h_colour_r", tostring( ent.cel.Layer1.Color.r ) )
            RunConsoleCommand( "cel_h_colour_g", tostring( ent.cel.Layer1.Color.g ) )
            RunConsoleCommand( "cel_h_colour_b", tostring( ent.cel.Layer1.Color.b ) )
            RunConsoleCommand( "cel_h_12_size_2", tostring( ent.cel.Layer2.Size ) )
            RunConsoleCommand( "cel_h_12_shake_2", tostring( ent.cel.Layer2.Shake ) )
            RunConsoleCommand( "cel_h_12_colour_r_2", tostring( ent.cel.Layer2.Color.r ) )
            RunConsoleCommand( "cel_h_12_colour_g_2", tostring( ent.cel.Layer2.Color.g ) )
            RunConsoleCommand( "cel_h_12_colour_b_2", tostring( ent.cel.Layer2.Color.b ) )
            RunConsoleCommand( "cel_h_12_singleshake", tostring( ent.cel.SingleShake ) )
            RunConsoleCommand( "cel_h_12_two_layers", tostring( ent.cel.Layers ) )
        elseif ( mode == 3 ) then
            RunConsoleCommand( "cel_h_size", tostring( ent.cel.Size ) )
            RunConsoleCommand( "cel_h_shake", tostring( ent.cel.Shake ) )
            RunConsoleCommand( "cel_h_colour_r", tostring( ent.cel.Color.r ) )
            RunConsoleCommand( "cel_h_colour_g", tostring( ent.cel.Color.g ) )
            RunConsoleCommand( "cel_h_colour_b", tostring( ent.cel.Color.b ) )
            RunConsoleCommand( "cel_h_13_passes", tostring( ent.cel.Passes ) )
            if ent.cel.Additive then
                RunConsoleCommand( "cel_h_13_additive", "1" )
            else
                RunConsoleCommand( "cel_h_13_additive", "0" )
            end
            if ent.cel.ThroughWalls then
                RunConsoleCommand( "cel_h_13_throughwalls", "1" )
            else
                RunConsoleCommand( "cel_h_13_throughwalls", "0" )
            end
        end
    end )

    net.Receive( "net_left_click_start", function()
        local mode = GetConVar( "cel_h_mode" ):GetInt()

        if ( mode == 3 and ( not ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and ( GetConVar( "enable_gm13_for_players" ):GetInt() == 0 ) ) ) then
            h_data = { Mode = 0 }
            net.Start( "net_left_click_finish" )
            net.WriteTable( h_data )
            net.SendToServer()
            return
        end

        local ent = net.ReadEntity()
        local h_data
        -- Halos and their color + Sobel
        if ( mode != 1 ) then
            local r = GetConVar( "cel_h_colour_r" ):GetInt()
            local g = GetConVar( "cel_h_colour_g" ):GetInt()
            local b = GetConVar( "cel_h_colour_b" ):GetInt()            
            local size = GetConVar( "cel_h_size" ):GetFloat()
            local shake = GetConVar( "cel_h_shake" ):GetFloat()
            if ( mode == 2 ) then
                size = size
                shake = shake
                local layers = GetConVar( "cel_h_12_two_layers" ):GetInt()
                local singleshake = GetConVar( "cel_h_12_singleshake" ):GetInt()
                local r2 = GetConVar( "cel_h_12_colour_r_2" ):GetInt()
                local g2 = GetConVar( "cel_h_12_colour_g_2" ):GetInt()
                local b2 = GetConVar( "cel_h_12_colour_b_2" ):GetInt()     
                local size2 = GetConVar( "cel_h_12_size_2" ):GetFloat()
                local shake2 = GetConVar( "cel_h_12_shake_2" ):GetFloat()
                h_data = {
                    Mode = mode, Layers = layers, SingleShake = singleshake,
                    Layer1 = { Color = Color( r, g, b, 255 ), Size = size , Shake = shake },
                    Layer2 = { Color = Color( r2, g2, b2, 255 ), Size = size2 , Shake = shake2 },
                }
            else
                shake = shake
                local passes = GetConVar( "cel_h_13_passes" ):GetInt()
                local additive = GetConVar( "cel_h_13_additive" ):GetBool()
                local throughwalls = GetConVar( "cel_h_13_throughwalls" ):GetBool()
                h_data = { Color = Color( r, g, b, 255 ), Size = size , Shake = shake, Mode = mode, Passes = passes, Additive = additive, ThroughWalls = throughwalls }
            end
        else
            h_data = { SobelThershold = ( GetConVar( "cel_sobel_thershold" ):GetFloat() ) , Mode = mode }
        end

        local c_data, t_data
        -- Texture and its Color
        if ( GetConVar( "cel_apply_texture" ):GetInt() == 1 ) then
            local r, g, b
            if (GetConVar( "cel_texture_mimic_halo" ):GetInt() == 1) then
                r = GetConVar( "cel_h_colour_r" ):GetInt()
                g = GetConVar( "cel_h_colour_g" ):GetInt()
                b = GetConVar( "cel_h_colour_b" ):GetInt()
            else
                r = GetConVar( "cel_colour_r" ):GetInt()
                g = GetConVar( "cel_colour_g" ):GetInt()
                b = GetConVar( "cel_colour_b" ):GetInt()
            end
            c_data = { Color = Color( r, g, b, 255 ) , Mode = mode }
            t_data = { MaterialOverride = cel_textures[GetConVar( "cel_texture" ):GetInt()] }
        end

        net.Start( "net_left_click_finish" )
        net.WriteTable( h_data or {} )
        net.WriteTable( c_data or {} )
        net.WriteTable( t_data or {} )
        net.WriteEntity( ent )
        net.SendToServer()
    end)
end

if ( SERVER ) then
    net.Receive( "net_left_click_finish", function( _, ply )
        local h_data = net.ReadTable()

        if ( h_data.Mode == 0 ) then
            ply:PrintMessage( HUD_PRINTTALK, "GM 13 Halos are admin only." )
            return
        end

        local c_data = net.ReadTable()
        local t_data = net.ReadTable()
        local ent = net.ReadEntity()

        SetHalo( nil, ent, h_data )

        if ( table.Count( c_data ) > 0 ) then
            SetColor( nil, ent, c_data )
        else
            RemoveColor( ent )
        end

        if ( table.Count( t_data ) > 0 ) then
            SetMaterial( nil, ent, t_data )
        else
            RemoveMaterial( ent )
        end
    end)
end

local function GetEnt( ply, trace )
    if ( ply.celserver != nil ) then
        if ( ( ply.celserver.Yourself == 1 ) and ( GetConVar( "enable_celshading_on_players" ):GetInt() == 1 ) ) then
            return ply
        end
    end

    local ent = trace.Entity
    
    if ( IsValid( ent.AttachedEntity ) ) then
        ent = ent.AttachedEntity
    end

    return ent
end

local function IsActionValid( ent, check_ent_cel )
    if ( check_ent_cel ) then
        if ( ent.cel == nil ) then
            return 1
        end
    end
    if ( !IsValid( ent ) ) then
        return 1
    end -- The entity is valid and isn't worldspawn

    if ( ent:IsPlayer() and ( GetConVar( "enable_celshading_on_players" ):GetInt() == 0 ) ) then
        return 1
    end
    
    return 0
end

function TOOL:LeftClick( trace )
    local ent = GetEnt( self:GetOwner(), trace )
    local check = IsActionValid( ent )

    if ( check == 1 ) then 
        return false
    end
    
    if ( CLIENT ) then return true end

    net.Start( "net_left_click_start" )
    net.WriteEntity( ent )
    net.Send( self:GetOwner() )

    return true
end

function TOOL:RightClick( trace )
    local ent = GetEnt( self:GetOwner(), trace )
    local check = IsActionValid( ent, true )

    if ( check == 1 ) then 
        return false
    end
    
    if ( CLIENT ) then return true end

    net.Start( "net_right_click" )
    net.WriteEntity( ent )
    net.Send( self:GetOwner() )
    
    return true
end

function TOOL:Reload( trace )
    local ent = GetEnt( self:GetOwner(), trace )
    local check = IsActionValid( ent, true )

    if ( check == 1 ) then 
        return false
    end

    if ( CLIENT ) then return true end

    RemoveColor ( ent )
    RemoveHalo ( ent )
    RemoveMaterial ( ent )

    return true
end
