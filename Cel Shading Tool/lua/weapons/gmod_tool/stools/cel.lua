--[[
   \   Cel Shading Tool ]] local version = "1.1" --[[
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

local enable_gm13_for_players = 0
local enable_celshading_on_players = 1

if ( SERVER ) then
    util.AddNetworkString( "net_left_click_start" )
    util.AddNetworkString( "net_left_click_finish" )
    util.AddNetworkString( "net_right_click" )
    util.AddNetworkString( "net_set_halo" )
    util.AddNetworkString( "net_remove_halo" )
    util.AddNetworkString( "net_enable_gm13_for_players" )
    util.AddNetworkString( "net_enable_gm13_for_players_plys" )
    util.AddNetworkString( "net_enable_celshading_yourself" )
    util.AddNetworkString( "net_enable_celshading_on_players" )
    util.AddNetworkString( "net_enable_celshading_on_players_plys" )
end

if ( CLIENT ) then
    language.Add( "Tool.cel.name", "Cel Shading" )
    language.Add( "Tool.cel.desc", "Adds a Cel Shading like effect to entities" )
    language.Add( "Tool.cel.left", "Apply" )
    language.Add( "Tool.cel.right", "Copy" )
    language.Add( "Tool.cel.reload", "Remove" )
    
    CreateClientConVar( "cel_h_mode" , 1, false, false )
    CreateClientConVar( "cel_h_colour_r" , 255, false, false )
    CreateClientConVar( "cel_h_colour_g" , 0, false, false )
    CreateClientConVar( "cel_h_colour_b" , 0, false, false )
    CreateClientConVar( "cel_h_size" , 0.3, false, false )
    CreateClientConVar( "cel_h_shake" , 0, false, false )
    CreateClientConVar( "cel_h_passes" , 1, false, false )
    CreateClientConVar( "cel_apply_texture" , 0, false, false )
    CreateClientConVar( "cel_texture" , 1, false, false )
    CreateClientConVar( "cel_colour_r" , 255, false, false )
    CreateClientConVar( "cel_colour_g" , 255, false, false )
    CreateClientConVar( "cel_colour_b" , 255, false, false )
    CreateClientConVar( "cel_sobel_thershold" , 0.2, false, false )
    CreateClientConVar( "cel_h_12_two_layers" , 1, false, false )
    CreateClientConVar( "cel_apply_yourself" , 0, false, false )
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
                            if ( v[1].cel.SobelColor ) then
                                v[1]:SetColor( v[1].cel.SobelColor )
                            end
                            v[1]:DrawModel()
                            render.SetBlend( 1 )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            render.UpdateScreenEffectTexture();
                            cel_mat:SetFloat( "$threshold", v[1].cel.SobelThershold )
                            v[1]:DrawModel()
                            render.SetMaterial( cel_mat );
                            render.DrawScreenQuad();
                        render.SetStencilEnable( false )
                    elseif ( v[1].cel.Mode == 2 ) then -- GMod 12 halos (light / scale bugs / players)
                        pos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 10
                        ang = LocalPlayer():EyeAngles()
                        ang = Angle( ang.p + 90, ang.y, 0 )
                        shake = math.Rand( 0, v[1].cel.Shake )
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
                            v[1]:SetModelScale( v[1].cel.Size + 1.00 + shake, 0 )
                            v[1]:DrawModel()
                            v[1]:SetModelScale( 1,0 )
                            render.SetBlend( 1 )
                            render.SetStencilPassOperation( STENCIL_KEEP )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            cam.Start3D2D( pos,ang,1 )
                                surface.SetDrawColor( v[1].cel.Color )
                                surface.DrawRect( -ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2 )
                            cam.End3D2D()
                            v[1]:DrawModel()
                        render.SetStencilEnable( false )
                        if ( v[1].cel.Layers == 1 ) then
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
                                v[1]:SetModelScale( v[1].cel.Size / 2 + 1.00 + shake, 0 )
                                v[1]:DrawModel()
                                v[1]:SetModelScale( 1,0 )
                                render.SetBlend( 1 )
                                render.SetStencilPassOperation( STENCIL_KEEP )
                                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                                cam.Start3D2D( pos,ang,1 )
                                    surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
                                    surface.DrawRect( -ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2 )
                                cam.End3D2D()
                                v[1]:DrawModel()
                            render.SetStencilEnable( false )
                        end
                    elseif ( v[1].cel.Mode == 3 ) then -- GMod 13 halos (heavy / work / admins)
                        size = v[1].cel.Size + math.Rand( 0, v[1].cel.Shake * 7 )
                        halo.Add( v, v[1].cel.Color, size, size, v[1].cel.Passes, false, false )
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

    net.Receive( "net_enable_gm13_for_players", function()
        enable_gm13_for_players = net.ReadInt( 2 )
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

if ( SERVER ) then
    net.Receive( "net_enable_gm13_for_players_plys", function()
        local value = net.ReadInt( 2 )

        for _,v in pairs( player.GetAll() ) do
            net.Start( "net_enable_gm13_for_players" )
            net.WriteInt( value, 2 )
            net.Send( v )
        end
    end )
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
    hook.Add( "PlayerInitialSpawn", "set halo table", function ( ply )
        if ( table.Count( cel_ent_tbl ) > 0 ) then
            timer.Create( "FSpawnFix", 3, 1, function()
                for _,v in pairs( cel_ent_tbl ) do
                    net.Start( "net_set_halo" )
                    net.WriteEntity( v[1] )
                    net.WriteTable( v[1].cel )
                    net.Send( ply )
                end
                net.Start( "net_enable_gm13_for_players" )
                net.WriteInt( enable_gm13_for_players, 2 )
                net.Send( ply )
                net.Start( "net_enable_celshading_on_players" )
                net.WriteInt( enable_celshading_on_players, 2 )
                net.Send( ply )
            end)
        end
    end)

    net.Receive( "net_enable_celshading_yourself", function( _, ply )
        ply.celserver = net.ReadTable()
        ply.cel = {}
    end)

    net.Receive( "net_enable_celshading_on_players_plys", function( _, ply )
        local value = net.ReadInt( 2 )

        enable_celshading_on_players = value

        for _,v in pairs( player.GetAll() ) do
            net.Start( "net_enable_celshading_on_players" )
            net.WriteInt( value, 2 )
            net.Send( v )
        end
    end)
end

if ( CLIENT ) then
    net.Receive( "net_enable_celshading_on_players", function( _, ply )
        enable_celshading_on_players = net.ReadInt( 2 )
    end)
end

-- -------------
-- PANEL
-- -------------

if ( CLIENT ) then

    function BuildPanel()
        local r, b, b

        -- PANELS:
        local panelw = 510
        local panelh = 340
        
        local Frame = vgui.Create( "DFrame" )
            Frame:SetSize( panelw, panelh )
            Frame:SetPos( (ScrW() - panelw) / 2, (ScrH() - panelh) / 2 )
            Frame:SetTitle( "#Tool.cel.name" )
            Frame:SetVisible( false )
            Frame:SetDraggable( true )
            Frame:ShowCloseButton( true )
            Frame:SetDeleteOnClose( true )

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
            sheet:AddSheet( "Texture", panel3, "icon16/picture.png" )

        -- --------
        -- PANEL 1:
        -- --------

        local Description = vgui.Create( "DLabel", panel1 )
            Description:SetPos( 50, 20 )
            Description:SetSize( 490, 45)
            Description:SetText( "The rendering modes work good or bad depending on the entity, so do your tests.\n\n           \"GMod 13 Halo\" mode is very good, but it causes a lot of lag!" )

        local ApplyToYourself = vgui.Create( "DCheckBoxLabel", panel1 )
            ApplyToYourself:SetPos( 155, 130 )
            ApplyToYourself:SetText( "Apply Cel Shading On Yourself" )
            ApplyToYourself:SetValue( GetConVar( "cel_apply_yourself" ):GetInt() )
            function ApplyToYourself:OnChange( val )
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

        local HaloEnable = vgui.Create( "DCheckBoxLabel", panel1 )
            HaloEnable:SetVisible( false )
            HaloEnable:SetPos( 155, 150 )
            HaloEnable:SetText( "Enable Cel Shading On Players" )
            HaloEnable:SetValue( enable_celshading_on_players )
            function HaloEnable:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                net.Start( "net_enable_celshading_on_players_plys" )
                net.WriteInt( aux, 2 )
                net.SendToServer()
            end

        local ApplyToPlayers = vgui.Create( "DCheckBoxLabel", panel1 )
            ApplyToPlayers:SetVisible( false )
            ApplyToPlayers:SetPos( 145, 175 )
            ApplyToPlayers:SetText( "Enable \"GMod 13 Halo\" for players" )
            ApplyToPlayers:SetValue( enable_gm13_for_players )
            function ApplyToPlayers:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                net.Start( "net_enable_gm13_for_players_plys" )
                net.WriteInt( aux, 2 )
                net.SendToServer()
            end

        if ( ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and not game.SinglePlayer() ) then
            ApplyToYourself:SetPos( 155, 95 )
            HaloEnable:SetVisible( true )
            ApplyToPlayers:SetVisible( true )
        end

        local ResetButton = vgui.Create( "DButton", panel1 )
            ResetButton:SetPos( 180, 220 )
            ResetButton:SetText( "Reset options!" )
            ResetButton:SetSize( 120, 30 )
            ResetButton.DoClick = function()
                RunConsoleCommand( "cel_reset_options" )
                Frame:Remove()
                timer.Create( "ReloadMenu", 0.01, 1, function()
                    RunConsoleCommand( "cel_menu" )
                end)
            end

        local ToolVersion = vgui.Create( "DLabel", panel1 )
            ToolVersion:SetPos( 455, 245 )
            ToolVersion:SetSize( 30, 25)
            ToolVersion:SetText( "v" .. version )

        -- --------
        -- PANEL 2:
        -- --------

        local HaloModelLabel = vgui.Create( "DLabel", panel2 )
            HaloModelLabel:SetPos( 10, 5 )
            HaloModelLabel:SetText( "Mode:" )

        local HaloSobelLabel = vgui.Create( "DLabel", panel2 )
            HaloSobelLabel:SetPos( 10, 60 )
            HaloSobelLabel:SetText( "Thershold:" )

        local HaloSobel = vgui.Create( "DNumSlider", panel2 )
            HaloSobel:SetPos( -130, 75 )
            HaloSobel:SetSize( 340, 35 )
            HaloSobel:SetMin( 0.09 )
            HaloSobel:SetMax( 0.99 )
            HaloSobel:SetDecimals( 2 )
            HaloSobel:SetConVar( "cel_sobel_thershold" )

        local HaloSizeLabel = vgui.Create( "DLabel", panel2 )
            HaloSizeLabel:SetPos( 10, 60 )
            HaloSizeLabel:SetText( "Size:" )

        local HaloSize = vgui.Create( "DNumSlider", panel2 )
            HaloSize:SetPos( -130, 75 )
            HaloSize:SetSize( 340, 35 )
            HaloSize:SetMin( 0 )
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

        local HaloPassesLabel = vgui.Create( "DLabel", panel2 )
            HaloPassesLabel:SetPos( 10, 150 )
            HaloPassesLabel:SetText( "Passes:" )

        local HaloPasses = vgui.Create( "DNumSlider", panel2 )
            HaloPasses:SetPos( -130, 165 )
            HaloPasses:SetSize( 340, 35 )
            HaloPasses:SetMin( 0 )
            HaloPasses:SetMax( 10 )
            HaloPasses:SetDecimals( 0 )
            HaloPasses:SetConVar( "cel_h_passes" )

        local HaloColorLabel = vgui.Create( "DLabel", panel2 )
            HaloColorLabel:SetPos( 210, 5 )
            HaloColorLabel:SetText( "Color:" )

        local HaloColor = vgui.Create( "DColorMixer", panel2 )
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

                RunConsoleCommand( "cel_h_colour_r", tostring( ChosenColor.r ) )
                RunConsoleCommand( "cel_h_colour_g", tostring( ChosenColor.g ) )
                RunConsoleCommand( "cel_h_colour_b", tostring( ChosenColor.b ) )
            end

        local Extralayer = vgui.Create( "DCheckBoxLabel", panel2 )
            Extralayer:SetPos( 10, 245 )
            Extralayer:SetText( "Use 2 layers" )
            Extralayer:SetValue( GetConVar( "cel_h_12_two_layers" ):GetInt() )
            function Extralayer:OnChange( val )
                local aux = 0
                if ( val ) then
                    aux = 1
                end
                RunConsoleCommand( "cel_h_12_two_layers", tostring( aux ) )
            end

        local function ShowOptions( mode )
            if ( mode == 1 ) then
                HaloSobelLabel:SetVisible( true )
                HaloSobel:SetVisible( true )
                HaloSizeLabel:SetVisible( false )
                HaloSize:SetVisible( false )
                HaloShakeLabel:SetVisible( false )
                HaloShake:SetVisible( false )
                HaloPassesLabel:SetVisible( false )
                HaloPasses:SetVisible( false )
                HaloColorLabel:SetVisible( false )
                HaloColor:SetVisible( false )
                Extralayer:SetVisible( false )
            elseif ( mode == 2 ) then
                HaloSobelLabel:SetVisible( false )
                HaloSobel:SetVisible( false )
                HaloSizeLabel:SetVisible( true )
                HaloSize:SetVisible( true )
                HaloShakeLabel:SetVisible( true )
                HaloShake:SetVisible( true )
                HaloPassesLabel:SetVisible( false )
                HaloPasses:SetVisible( false )
                HaloColorLabel:SetVisible( true )
                HaloColor:SetVisible( true )
                Extralayer:SetVisible( true )
            elseif ( mode == 3 ) then
                HaloSobelLabel:SetVisible( false )
                HaloSobel:SetVisible( false )
                HaloSizeLabel:SetVisible( true )
                HaloSize:SetVisible( true )
                HaloShakeLabel:SetVisible( true )
                HaloShake:SetVisible( true )
                HaloPassesLabel:SetVisible( true )
                HaloPasses:SetVisible( true )
                HaloColorLabel:SetVisible( true )
                HaloColor:SetVisible( true )
                Extralayer:SetVisible( false )
            end
        end

        local HaloChoose = vgui.Create( "DComboBox", panel2 )
            HaloChoose:SetPos( 10, 30 )
            HaloChoose:SetSize( 190, 25 )
            local choice = GetConVar( "cel_h_mode" ):GetInt()
            if ( choice == 1 ) then
                HaloChoose:SetValue( "Sobel" )
            elseif ( choice == 2 ) then
                HaloChoose:SetValue( "GMod 12 Halo" )
            elseif ( choice == 3 ) then
                HaloChoose:SetValue( "GMod 13 Halo" )
            end
            ShowOptions( choice )
            HaloChoose:AddChoice( "Sobel", 1 )
            HaloChoose:AddChoice( "GMod 12 Halo", 2 )

            if ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) or ( enable_gm13_for_players == 1 ) then
                HaloChoose:AddChoice( "GMod 13 Halo", 3 )
            end
            HaloChoose.OnSelect = function( panel, index, value )
                RunConsoleCommand( "cel_h_mode", tostring( index ) )
                ShowOptions( index )
            end

        -- --------
        -- PANEL 3:
        -- --------

        local TextureColorLabel = vgui.Create( "DLabel", panel3 )
            TextureColorLabel:SetPos( 210, 5 )
            TextureColorLabel:SetText( "Color:" )

        local TextureColor = vgui.Create( "DColorMixer", panel3 )
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

        local HaloSizeLabel = vgui.Create( "DLabel", panel3 )
            HaloSizeLabel:SetPos( 10, 5 )
            HaloSizeLabel:SetText( "Texture:" )

        local TextureType = vgui.Create( "DComboBox", panel3 )
            TextureType:SetPos( 10, 30 )
            TextureType:SetSize( 190, 25 )
            TextureType:SetValue( cel_textures[GetConVar( "cel_texture" ):GetInt()] )
            for k,v in pairs( cel_textures ) do
                TextureType:AddChoice( cel_textures[k], k )
            end
            TextureType.OnSelect = function( panel, index, value )
                RunConsoleCommand( "cel_texture", tostring( index ) )
            end

        local HaloSizeLabel = vgui.Create( "DLabel", panel3 )
            HaloSizeLabel:SetPos( 10, 65 )
            HaloSizeLabel:SetText( "Options:" )

        local TextureEnable = vgui.Create( "DCheckBoxLabel", panel3 )
            TextureEnable:SetPos( 10, 90 )
            TextureEnable:SetText( "Enable Textures" )
            TextureEnable:SetConVar( "cel_apply_texture" )
            TextureEnable:SetValue( GetConVar( "cel_apply_texture" ):GetInt() )
            TextureEnable:SizeToContents()

		Frame:SetVisible( true )
		Frame:MakePopup()
    end
    concommand.Add( "cel_menu", BuildPanel )

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

local function ResetOptions()
    if ( CLIENT ) then
        RunConsoleCommand( "cel_h_colour_r", "255" )
        RunConsoleCommand( "cel_h_colour_g", "0" )
        RunConsoleCommand( "cel_h_colour_b", "0" )
        RunConsoleCommand( "cel_h_size", "0.3" )
        RunConsoleCommand( "cel_h_shake", "0.00" )
        RunConsoleCommand( "cel_apply_texture", "0" )
        RunConsoleCommand( "cel_texture", "1" )
        RunConsoleCommand( "cel_colour_r", "255" )
        RunConsoleCommand( "cel_colour_g", "255" )
        RunConsoleCommand( "cel_colour_b", "255" )
        RunConsoleCommand( "cel_sobel_thershold", "0.2" )
        RunConsoleCommand( "cel_h_mode", "1" )
        RunConsoleCommand( "cel_h_12_two_layers", "1" )
        RunConsoleCommand( "cel_apply_yourself", "0" )
    end
end

if ( CLIENT ) then
    concommand.Add( "cel_reset_options", ResetOptions )

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
        
        if ( mode != 1 ) then
            RunConsoleCommand( "cel_h_colour_r", tostring( ent.cel.Color.r ) )
            RunConsoleCommand( "cel_h_colour_g", tostring( ent.cel.Color.g ) )
            RunConsoleCommand( "cel_h_colour_b", tostring( ent.cel.Color.b ) )
            if ( mode == 2 ) then
                RunConsoleCommand( "cel_h_size", tostring( ent.cel.Size * 2 ) )
                RunConsoleCommand( "cel_h_shake", tostring( ent.cel.Shake * 15 ) )
                RunConsoleCommand( "cel_h_12_two_layers", tostring( ent.cel.Layers ) )
            elseif ( mode == 3 ) then
                RunConsoleCommand( "cel_h_size", tostring( ent.cel.Size ) / 5 )
                RunConsoleCommand( "cel_h_shake", tostring( ent.cel.Shake * 10 ) )
                RunConsoleCommand( "cel_h_passes", tostring( ent.cel.Passes ) )
            end
        end
    end )

    net.Receive( "net_left_click_start", function()
        local mode = GetConVar( "cel_h_mode" ):GetInt()

        if ( mode == 3 and ( not ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and ( enable_gm13_for_players == 0 ) ) ) then
            h_data = { Mode = 0 }
            net.Start( "net_left_click_finish" )
            net.WriteTable( h_data )
            net.SendToServer()
            return
        end

        local ent = net.ReadEntity()
        local c_data, h_data, t_data

        -- Halos and their color + Sobel
        if ( mode != 1 ) then
            local r = GetConVar( "cel_h_colour_r" ):GetInt()
            local g = GetConVar( "cel_h_colour_g" ):GetInt()
            local b = GetConVar( "cel_h_colour_b" ):GetInt()            
            local shake = GetConVar( "cel_h_shake" ):GetFloat()
            local size = GetConVar( "cel_h_size" ):GetFloat()
            local layers
            local passes
            if ( mode == 2 ) then
                size = size / 2
                shake = shake / 15
                layers = GetConVar( "cel_h_12_two_layers" ):GetInt()
            else
                size = math.floor( size * 5 )
                shake = shake / 10
                passes = GetConVar( "cel_h_passes" ):GetFloat()
            end
            h_data = { Color = Color( r, g, b, 255 ), Size = size , Shake = shake, Passes = passes, Layers = layers, Mode = mode }    
        else
            h_data = { SobelThershold = ( 0.15 - GetConVar( "cel_sobel_thershold" ):GetFloat() * 0.15 ) , Mode = mode }
        end

        -- Texture and its Color
        if ( GetConVar( "cel_apply_texture" ):GetInt() == 1 ) then
            local r = GetConVar( "cel_colour_r" ):GetInt()
            local g = GetConVar( "cel_colour_g" ):GetInt()
            local b = GetConVar( "cel_colour_b" ):GetInt()
            if ( mode != 1 ) then
                c_data = { Color = Color( r, g, b, 255 ) , Mode = mode }
            else
                h_data.SobelColor = Color( r, g, b, 255 )
            end
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
        if ( ( ply.celserver.Yourself == 1 ) and ( enable_celshading_on_players == 1 ) ) then
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

    if ( ent:IsPlayer() and ( enable_celshading_on_players == 0 ) ) then
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
