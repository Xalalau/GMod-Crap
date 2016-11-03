--[[
   \   Cel Shading Tool
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

local cel_textures = { "models/debug/debugwhite", "models/shiny" }
local cel_ent_tbl = { }

if ( SERVER ) then
    util.AddNetworkString( "net_left_click_start" )
    util.AddNetworkString( "net_left_click_finish" )
    util.AddNetworkString( "net_right_click" )
    util.AddNetworkString( "net_set_halo" )
    util.AddNetworkString( "net_remove_halo" )
end

if ( CLIENT ) then
    language.Add( "Tool.cel.name", "Cel Shading" )
    language.Add( "Tool.cel.desc", "Adds a Cel Shading like effect to entities" )
    language.Add( "Tool.cel.left", "Apply" )
    language.Add( "Tool.cel.right", "Copy" )
    language.Add( "Tool.cel.reload", "Reset" )

    CreateClientConVar( "cel_h_mode" , 1, false, false )
    CreateClientConVar( "cel_h_colour_r" , 0, false, false )
    CreateClientConVar( "cel_h_colour_g" , 0, false, false )
    CreateClientConVar( "cel_h_colour_b" , 0, false, false )
    CreateClientConVar( "cel_h_size_12" , 0.03, false, false )
    CreateClientConVar( "cel_h_size_13" , 2, false, false )
    CreateClientConVar( "cel_h_shake" , 0, false, false )
    CreateClientConVar( "cel_apply_texture" , 0, false, false )
    CreateClientConVar( "cel_shiny_texture" , 0, false, false )
    CreateClientConVar( "cel_colour_r" , 255, false, false )
    CreateClientConVar( "cel_colour_g" , 255, false, false )
    CreateClientConVar( "cel_colour_b" , 255, false, false )
    CreateClientConVar( "cel_sobel_thershold" , 0.2, false, false )
end

-- -------------
-- HALO
-- -------------

if ( CLIENT ) then
    local pos, ang, size

    local cel_mat = Material( "pp/sobel" )
    cel_mat:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )

    -- https://facepunch.com/showthread.php?t=1337232
    hook.Add( "PostDrawOpaqueRenderables", "PlayerBorders", function( )
        if table.Count( cel_ent_tbl ) > 0 then
            for k,v in pairs( cel_ent_tbl ) do
                if ( !IsValid( v[1] ) ) then
                    cel_ent_tbl[k] = nil  -- Clean the table
                else
                    if (v[1].cel.Mode == 1) then -- Sobel PP effect (light / works / players)
                        render.ClearStencil( )
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
                            v[1]:DrawModel( )
                            render.SetBlend( 1 )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            render.UpdateScreenEffectTexture( );
                            cel_mat:SetFloat( "$threshold", v[1].cel.SobelThershold )
                            v[1]:DrawModel( )
                            render.SetMaterial( cel_mat );
                            render.DrawScreenQuad( );
                        render.SetStencilEnable( false )
                    elseif (v[1].cel.Mode == 2) then -- GMod 12 halos (light / scale bugs / players)
                        pos = LocalPlayer( ):EyePos( )+LocalPlayer( ):EyeAngles( ):Forward( )*10
                        ang = LocalPlayer( ):EyeAngles( )
                        ang = Angle(ang.p+90,ang.y,0)
                        render.ClearStencil( )
                        render.SetStencilEnable( true )
                            render.SetStencilWriteMask( 255 )
                            render.SetStencilTestMask( 255 )
                            render.SetStencilReferenceValue( 15 )
                            render.SetStencilFailOperation(STENCILOPERATION_KEEP)
                            render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
                            render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
                            render.SetBlend( 0 )
                            v[1]:SetModelScale( v[1].cel.Size + 1.00 + math.Rand( 0, v[1].cel.Shake ), 0 )
                            v[1]:DrawModel( )
                            v[1]:SetModelScale( 1,0 )
                            render.SetBlend( 1 )
                            render.SetStencilPassOperation( STENCIL_KEEP )
                            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                            cam.Start3D2D( pos,ang,1 )
                                surface.SetDrawColor( v[1].cel.Color )
                                surface.DrawRect( -ScrW( ), -ScrH( ), ScrW( )*2, ScrH( )*2 )
                            cam.End3D2D( )
                            v[1]:DrawModel( )
                        render.SetStencilEnable( false )
                    elseif (v[1].cel.Mode == 3) then -- GMod 13 halos (heavy / work / admins)
                        size = v[1].cel.Size + math.Rand( 0, v[1].cel.Shake * 7 )
                        halo.Add( v, v[1].cel.Color, size, size, 1, false, false )
                    end
                end
            end
        end
    end )

    net.Receive( "net_set_halo", function( )
        local ent = net.ReadEntity( )
        local h_data = net.ReadTable( )

        for k,v in pairs( cel_ent_tbl ) do
            if ( table.HasValue( v, ent ) ) then
                cel_ent_tbl[k] = nil
            end
        end

        ent.cel = h_data
        table.insert( cel_ent_tbl, { ent } )
    end )

    net.Receive( "net_remove_halo", function( )
        local ent = net.ReadEntity( )

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

        timer.Create( "DuplicatorFix", 0.1, 1, function( )
            for _,v in pairs( player.GetAll( ) ) do
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

        for _,v in pairs( player.GetAll( ) ) do
            net.Start( "net_remove_halo" )
            net.WriteEntity( ent )
            net.Send( v )
        end
    end
end

if ( SERVER ) then
    hook.Add( "PlayerInitialSpawn", "set halo table", function ( ply )
        if ( table.Count( cel_ent_tbl ) > 0 ) then
            timer.Create( "FSpawnFix", 3, 1, function( )
                for _,v in pairs( cel_ent_tbl ) do
                    Msg(v[1].cel.Mode)
                    net.Start( "net_set_halo" )
                    net.WriteEntity( v[1] )
                    net.WriteTable( v[1].cel )
                    net.Send( ply )
                end
            end)
        end
    end)
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
                ent:PhysWake( )
            end
        end

        duplicator.StoreEntityModifier( ent, "Cel_Colour", c_data )
    end
    duplicator.RegisterEntityModifier( "Cel_Colour", SetColor )
end

local function RemoveColor ( ent )
    if ( SERVER ) then
        SetColor( nil, ent, { Color = Color( 255, 255, 255, 255 ), Mode = ent.cel.Mode } )
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
    end
end

-- -------------------
-- HALO/COLOR/MATERIAL
-- -------------------

local function ResetOptions( )
    if ( CLIENT ) then
        RunConsoleCommand( "cel_h_colour_r", "0" )
        RunConsoleCommand( "cel_h_colour_g", "0" )
        RunConsoleCommand( "cel_h_colour_b", "0" )
        RunConsoleCommand( "cel_h_size_12", "0.03" )
        RunConsoleCommand( "cel_h_size_13", "2" )
        RunConsoleCommand( "cel_h_shake", "0.00" )
        RunConsoleCommand( "cel_apply_texture", "0" )
        RunConsoleCommand( "cel_shiny_texture", "0" )
        RunConsoleCommand( "cel_colour_r", "255" )
        RunConsoleCommand( "cel_colour_g", "255" )
        RunConsoleCommand( "cel_colour_b", "255" )
        RunConsoleCommand( "cel_sobel_thershold", "0.2" )
        RunConsoleCommand( "cel_h_mode", "1" )
    end
end

if ( CLIENT ) then
    concommand.Add( "cel_reset_options", ResetOptions )

    net.Receive( "net_right_click", function( )
        local ent = net.ReadEntity( )
        local result = { }
        
        local mat = ent:GetMaterial( )

        if ( mat == cel_textures[1] ) then
            RunConsoleCommand( "cel_shiny_texture", "0" )
            RunConsoleCommand( "cel_apply_texture", "1" )
        elseif ( mat == cel_textures[2] ) then
            RunConsoleCommand( "cel_shiny_texture", "1" )
            RunConsoleCommand( "cel_apply_texture", "1" )
        else
            RunConsoleCommand( "cel_apply_texture", "0" )
        end

        local clr = ent:GetColor( )
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
                RunConsoleCommand( "cel_h_size_12", tostring( ent.cel.Size ) )
            else
                RunConsoleCommand( "cel_h_size_13", tostring( ent.cel.Size ) )
            end
            RunConsoleCommand( "cel_h_shake", tostring( ent.cel.Shake ) )
        end
    end )

    net.Receive( "net_left_click_start", function( )
        local mode = GetConVar( "cel_h_mode" ):GetInt( )

        if ( mode == 3 && (! (LocalPlayer( ):IsAdmin( ) or LocalPlayer( ):IsSuperAdmin( ) ) ) ) then
            h_data = { Mode = 0 }
            net.Start( "net_left_click_finish" )
            net.WriteTable( h_data )
            net.SendToServer( )
            return
        end

        local ent = net.ReadEntity( )
        local c_data, h_data, t_data

        -- Halo
        if ( mode != 1 ) then
            local r = GetConVar( "cel_h_colour_r" ):GetInt( )
            local g = GetConVar( "cel_h_colour_g" ):GetInt( )
            local b = GetConVar( "cel_h_colour_b" ):GetInt( )            
            local shake = GetConVar( "cel_h_shake" ):GetFloat( )
            local size
            if ( mode == 2 ) then
                size = GetConVar( "cel_h_size_12" ):GetFloat( )
            else
                size = GetConVar( "cel_h_size_13" ):GetInt( )
            end
            h_data = { Color = Color( r, g, b, 255 ), Size = size , Shake = shake, Mode = mode }    
        else
            h_data = { SobelThershold = GetConVar( "cel_sobel_thershold" ):GetFloat( ), Mode = mode }
        end

        -- Texture and Color
        if ( GetConVar( "cel_apply_texture" ):GetInt( ) == 1 ) then
            local r = GetConVar( "cel_colour_r" ):GetInt( )
            local g = GetConVar( "cel_colour_g" ):GetInt( )
            local b = GetConVar( "cel_colour_b" ):GetInt( )
            if ( mode != 1 ) then
                c_data = { Color = Color( r, g, b, 255 ) , Mode = mode }
            else
                h_data.SobelColor = Color( r, g, b, 255 )
            end
            local texture = GetConVar( "cel_shiny_texture" ):GetInt( )
            t_data = { MaterialOverride = cel_textures[texture + 1] }
        end

        net.Start( "net_left_click_finish" )
        net.WriteTable( h_data or { } )
        net.WriteTable( c_data or { } )
        net.WriteTable( t_data or { } )
        net.WriteEntity( ent )
        net.SendToServer( )
    end)
end

if ( SERVER ) then
    net.Receive( "net_left_click_finish", function( _, ply )
        local h_data = net.ReadTable( )

        if ( h_data.Mode == 0 ) then
            ply:PrintMessage( HUD_PRINTTALK, "GM 13 Halos are admin only." )
            return
        end

        local c_data = net.ReadTable( )
        local t_data = net.ReadTable( )
        local ent = net.ReadEntity( )

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

-- -------------
-- ACTIONS
-- -------------

function TOOL:LeftClick( trace )
    if ( CLIENT ) then return true end

    local ent = trace.Entity
    if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end

    if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn
    if ( ent:IsPlayer( ) ) then return false end

    net.Start( "net_left_click_start" )
    net.WriteEntity( ent )
    net.Send( self:GetOwner( ) )

    return true
end

function TOOL:RightClick( trace )
    if ( CLIENT ) then return true end

    local ent = trace.Entity
    if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end

    if ( ent.cel == nil ) then return false end
    if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn
    if ( ent:IsPlayer( ) ) then return false end

    net.Start( "net_right_click" )
    net.WriteEntity( ent )
    net.Send( self:GetOwner( ) )

    return true
end

function TOOL:Reload( trace )
    if ( CLIENT ) then return true end
    
    local ent = trace.Entity
    if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end

    if ( ent.cel == nil ) then return false end
    if ( !IsValid( ent ) ) then return false end -- The entity is valid and isn't worldspawn
    if ( ent:IsPlayer( ) ) then return false end

    RemoveColor ( ent )
    RemoveHalo ( ent )
    RemoveMaterial ( ent )

    return true
end

if ( CLIENT ) then
    function TOOL.BuildCPanel( CPanel )
        CPanel:AddControl( "Header", { Text = "#Tool.cel.name", Description = "#Tool.cel.desc" } )
        CPanel:Help( "" )
        local params = {Label = "Cell Shading Mode:", MenuButton = "0", Options = {}}
        params.Options["Sobel"] = {cel_h_mode = "1"}
        params.Options["GM 12 Halo"] = {cel_h_mode = "2"}
        if LocalPlayer( ):IsAdmin( ) or LocalPlayer( ):IsSuperAdmin( ) then
            params.Options["GM 13 Halo"] = {cel_h_mode = "3"}
        end
        CPanel:AddControl( "ComboBox", params )
        CPanel:Help( "" )
        CPanel:ControlHelp( "[Note] The rendering modes work good or bad depending on the entity. GMod 13 Halo is very good, but is set to only admins because it's super heavy." )
        if LocalPlayer( ):IsAdmin( ) or LocalPlayer( ):IsSuperAdmin( ) then
            CPanel:AddControl( "Color", { Label = "GM 12/13 Halo Color:", Red = "cel_h_colour_r", Green = "cel_h_colour_g", Blue = "cel_h_colour_b" } )
            CPanel:AddControl( "Slider" , { Label = "GM 12/13 Halo Shake", Type = "float", Min = "0.00", Max = "1.00", Command = "cel_h_shake"} ) 
            CPanel:AddControl( "Slider" , { Label = "GM 13 Halo Size", Type = "int", Min = "0", Max = "10", Command = "cel_h_size_13"} )
        else
            CPanel:AddControl( "Color", { Label = "GM 12 Halo Color:", Red = "cel_h_colour_r", Green = "cel_h_colour_g", Blue = "cel_h_colour_b" } )
            CPanel:AddControl( "Slider" , { Label = "GM 12 Halo Shake", Type = "float", Min = "0.00", Max = "1.00", Command = "cel_h_shake"} ) 
        end
        CPanel:AddControl( "Slider" , { Label = "GM 12 Halo Size", Type = "float", Min = "0.00", Max = "0.50", Command = "cel_h_size_12"} )
        CPanel:AddControl( "Slider" , { Label = "Sobel Thershold", Type = "float", Min = "0.00", Max = "0.3", Command = "cel_sobel_thershold"} )
        CPanel:Help( "" )
        CPanel:AddControl( "CheckBox", { Label = "Enable Flat Texture", Command = "cel_apply_texture" } )     
        CPanel:AddControl( "Color", { Label = "Select Texture Color:", Red = "cel_colour_r", Green = "cel_colour_g", Blue = "cel_colour_b" } )
        CPanel:AddControl( "CheckBox", { Label = "Enable Texture Reflection", Command = "cel_shiny_texture" } )
        CPanel:Help( "" )
        CPanel:AddControl("Button" , { Text  = "Reset options", Command = "cel_reset_options" })
        CPanel:Help( "" )
        timer.Create( "SetCommandsFix", 0.1, 1, function( )
            ResetOptions( )
        end)
    end
end
