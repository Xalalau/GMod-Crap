--[[ 
Credits: tool originally created by Deco and continued by Xalalau

Version 1.2, by Deco: http://www.garrysmod.org/downloads/?a=view&id=42593 
Version 1.3 and 1.4 by Xalalau: http://steamcommunity.com/sharedfiles/filedetails/?id=121182342

https://github.com/xalalau/GMod/tree/master/NPC%20Scene
]]--

-- ----------
-- TOOL SETUP
-- ----------

TOOL.Category = "Poser"
TOOL.Name = "#Tool.npc_scene.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["scene"] = "scenes/npc/Gman/gman_intro"
TOOL.ClientConVar["actor"] = "Alyx"
TOOL.ClientConVar["loop"] = 0
TOOL.ClientConVar["key"] = 0
TOOL.ClientConVar["start"] = 0
TOOL.ClientConVar["multiple"] = 0
TOOL.ClientConVar["render"] = 1
TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" }
}

if ( CLIENT ) then
    language.Add( "Tool.npc_scene.name", "NPC Scene" )
    language.Add( "Tool.npc_scene.desc", "Make NPCs act using \".vcd\" files!" )
    language.Add( "Tool.npc_scene.left", "Left click to play entered scene." )
    language.Add( "Tool.npc_scene.right", "Right click to set the actor name." )
    language.Add( "Tool.npc_scene.reload", "Reload to stop a scene." )
end

-- -----------
-- GLOBAL VARS
-- -----------

local SceneListPanel
-- Table for controlling keys, NPC reloading and name printing
local npcscene_ent_table = {}

-- -----------------
-- GENERAL FUNCTIONS
-- -----------------

-- Stops the scene loops.
local function NPCSceneTimerStop( Index_loop )
    if ( SERVER ) then
        if ( Index_loop ) then
            timer.Stop( Index_loop )
        end
    end
end

-- Plays a scene with or without loops.
local function NPCSceneStart( ent )
    if ( SERVER ) then
        ent.npcscene.Active = 1

        -- Gets the animationg lenght and plays it.
        local lenght = ent:PlayScene( ent.npcscene.Scene ) 
        local Index_loop = ent.npcscene.Index_loop
        local Index_key = ent.npcscene.Index_key

        -- Waits for the next play (if we are using loops).
        if ( ent.npcscene.Loop != 0 ) then
            timer.Create( Index_loop, lenght, ent.npcscene.Loop, function()
                if not ( ent:IsValid() ) then
                    npcscene_ent_table[Index_key] = nil
                    NPCSceneTimerStop( Index_loop )
                elseif ( ent.npcscene.Loop == 0 ) then
                    npcscene_ent_table[Index_key] = nil
                    ent.npcscene.Active = 0
                    NPCSceneTimerStop( Index_loop )
                else
                    ent:PlayScene( ent.npcscene.Scene )
                    ent.npcscene.Loop = ent.npcscene.Loop - 1
                end
            end)
        end
    end
end

-- Reloads NPCs so we can apply new scenes.
local function ReloadEntity( ply, ent )
    if ( SERVER ) then

        local Dupe = {}

        Dupe = duplicator.Copy( ent )
        SafeRemoveEntity(ent)
        duplicator.Paste( ply, Dupe.Entities, Dupe.Constraints )

        ent = ply:GetEyeTrace().Entity

        undo.Create( "NPC " )
            undo.AddEntity( ent )
            undo.SetPlayer( ply )
        undo.Finish()

        return ent
    end
end

-- Check if a entity is valid (NPC).
local function IsValidEnt( tr )
    if tr.Hit and tr.Entity and tr.Entity:IsValid() and tr.Entity:IsNPC() then
        return true
    end
    
    return false
end

-- Populates the scenes list.
local function ParseDir( t, dir, ext )
    if ( CLIENT ) then
        local files, dirs = file.Find( dir .. "*" , "GAME" )
        for _, fdir in pairs( dirs ) do
            local n = t:AddNode( fdir )
            ParseDir( n, dir .. fdir .. "/", ext )
            n:SetExpanded( false )
        end
        for k,v in pairs( files ) do
            local n = t:AddNode( v )
            local arq = dir..v
            n.DoClick = function()
                RunConsoleCommand( "npc_scene_scene", arq )
            end
        end
    end
end

-- ---------
-- NET SETUP
-- ---------

if ( SERVER ) then
    util.AddNetworkString( "net_set_table" )
    util.AddNetworkString( "npc_scene_key_hook" )
    util.AddNetworkString( "npc_scene_play" )
end

-- -------------
-- NET FUNCTIONS
-- -------------

-- Plays scenes with keys associated.
if ( SERVER ) then
    net.Receive( "npc_scene_play", function()
        local ent = net.ReadEntity()
        local multiple = net.ReadInt( 2 )

        if ( ent.npcscene.Active == 0 or multiple == 1 ) then
            NPCSceneStart( ent )
        end
    end )
end

-- Sets the ent table for new palyers.
if ( CLIENT ) then
    net.Receive( "net_set_table", function()
        ent = net.ReadEntity()
        data = net.ReadTable()
        
        ent.npcscene = data
        
        table.insert( npcscene_ent_table, ent.npcscene.Index_key, ent )
    end )
end

-- Sets the keys ("Tick" hook).
if ( CLIENT ) then
    net.Receive( "npc_scene_key_hook", function( _, ply )
        local ent = net.ReadEntity()
        local Index_key = ent.npcscene.Index_key

        if ( hook.GetTable()[Index_key] ) then
            return
        end

        local multiple = GetConVar( "npc_scene_multiple" ):GetInt()
        
        if ( ent.npcscene.Start == 1 ) then
            net.Start( "npc_scene_play" )
            net.WriteEntity( ent )
            net.WriteInt( multiple, 2 )
            net.SendToServer()
        end

        hook.Add( "Tick", "hook_" .. Index_key, function()
            if not ( ent:IsValid() ) then
                npcscene_ent_table[Index_key] = nil
                hook.Remove( "Tick", "hook_" .. Index_key )
            elseif ( input.IsKeyDown( ent.npcscene.Key ) ) then
                net.Start( "npc_scene_play" )
                net.WriteEntity( ent )
                net.WriteInt( multiple, 2 )
                net.SendToServer()
            end
        end )
    end )
end

-- -------------
-- INITIAL HOOKS
-- -------------

-- Sets the ent table for new palyers.
if ( SERVER ) then
    hook.Add( "PlayerInitialSpawn", "set npc_scene ent table", function ( ply )
        if ( table.Count( npcscene_ent_table ) > 0 ) then
            timer.Create( "FSpawnFixNPCScene", 3, 1, function()
                for _,v in pairs( npcscene_ent_table ) do
                    net.Start( "net_set_table" )
                    net.WriteEntity( v )
                    net.WriteTable( v.npcscene )
                    net.Send( ply )
                end
            end)
        end
    end)
end

-- Renders the NPC names
if ( CLIENT ) then
    hook.Add("HUDPaint", "ShowNPCHealthAboveHeadNPCScene", function()
        if ( GetConVar( "npc_scene_render" ):GetInt() == 1 ) then
            for _,ent in pairs( npcscene_ent_table ) do
                if ( ent:IsValid() ) then
                    local pos = ent:GetPos()
                    local drawposscreen = Vector( 0, 0, 0 )
                    local head = ent:LookupBone( "ValveBiped.Bip01_Head1" )

                    if head then
                        local headpos, headang = ent:GetBonePosition( head )
                        drawposscreen = ( headpos + Vector( 0, 0, 10 ) ):ToScreen()
                    else
                        local min, max = ent:WorldSpaceAABB()
                        local drawpos = Vector( pos.x, pos.y, max.z )
                        drawposscreen = drawpos:ToScreen()
                    end

                    if ( ( ent.npcscene.name != "" ) and ( LocalPlayer():GetPos():Distance( ent:GetPos() ) < 300 ) ) then
                        draw.DrawText( ent.npcscene.name, "TargetID", drawposscreen.x, drawposscreen.y, Color( 255, 255, 255, 255 ) )
                    end
                end
            end
        end
    end)
end

-- --------------
-- TOOL FUNCTIONS
-- --------------

-- Plays scenes.
function TOOL:LeftClick( tr )
    if not IsValidEnt( tr ) then
        return false
    elseif ( CLIENT ) then
        return true
    end

    local ply = self:GetOwner()
    local ent = tr.Entity
    local scene = string.gsub( self:GetClientInfo( "scene" ), ".vcd", "" )
    local name = ""
    
    -- Loads the actor name (if there is one)
    if ( ent.npcscene ) then
        if ( ent.npcscene.name ) then
            name = ent.npcscene.name
        end
    end
    
    -- Reloads the scenes (by deleting the loops and reloading the NPCs)
    if ( ent.npcscene ) then 
        if ( ent.npcscene.Active == 1 and self:GetClientNumber( "multiple" ) == 0 ) then
            NPCSceneTimerStop( ent.npcscene.Index_loop )
            ent = ReloadEntity( ply, ent )
        end
    end

    -- Adds the configurations to the entity.
    local data = {
        Active     = 0,
        Index_loop = "loop_" .. ent:EntIndex(),
        Index_key  = ent:EntIndex(),
        Loop       = self:GetClientNumber( "loop" ),
        Scene      = scene,
        name       = name,
        Key        = self:GetClientNumber( "key" ),
        Start      = self:GetClientNumber( "start" ),
    }

    timer.Create( "AvoidSpawnErrorsNPCSceneLeft", 0.1, 1, function() -- Timer to avoid spawning errors
        ent.npcscene = data
        
        -- Register the entity in our internal table.
        table.insert( npcscene_ent_table, ent:EntIndex(), ent )
        net.Start( "net_set_table" )
        net.WriteEntity( ent )
        net.WriteTable( ent.npcscene )
        net.Send( ply )

        -- Plays the scene.
        timer.Create( "AvoidSpawnErrorsNPCSceneLeft2", 0.15, 1, function() -- Timer to avoid spawning errors
            if ( ent.npcscene.Key == 0 ) then -- Not using keys? Let's play it.
                NPCSceneStart( ent )
            else -- Using keys? Let's bind it.
                net.Start( "npc_scene_key_hook" )
                net.WriteEntity( ent )
                net.Send( ply )
            end
        end)
    end)

    return true
end

-- Sets actor names.
function TOOL:RightClick( tr )
    if not IsValidEnt( tr ) then
        return false
    elseif ( CLIENT ) then
        return true
    end 

    local ent = tr.Entity
    local name = self:GetClientInfo( "actor" )


    timer.Create( "AvoidSpawnErrorsNPCSceneRight", 0.15, 1, function() -- Timer to avoid spawning errors
        -- Sets the name
        ent:SetName( name )

        -- Adds the name to the entity.
        if not ( ent.npcscene ) then
            ent.npcscene = {}
            ent.npcscene.Index_key  = ent:EntIndex()
        end
        ent.npcscene.name = name

        -- Register the entity in our internal table.
        table.insert( npcscene_ent_table, ent:EntIndex(), ent )
        for _, v in pairs(player.GetAll()) do
            net.Start( "net_set_table" )
            net.WriteEntity( ent )
            net.WriteTable( ent.npcscene )
            net.Send( v )
        end
    end)

    return true
end

function TOOL:Reload( tr )
    if not IsValidEnt( tr ) then
        return false
    end

    local ent = tr.Entity

    -- Deletes the loops and reloads the NPCs
    if ( ent.npcscene ) then 
        timer.Create( "AvoidSpawnErrorsNPCSceneReload", 0.15, 1, function() -- Timer to avoid spawning errors
            NPCSceneTimerStop( ent.npcscene.Index_loop )
            ReloadEntity( self:GetOwner(), ent )
        end)
    else
        return false
    end

    return true
end

-- Builds CPanel.
if ( CLIENT ) then
    function TOOL.BuildCPanel( CPanel )
        CPanel:AddControl( "Header"  , { Text  = '#Tool.npc_scene.name', Description = '#Tool.npc_scene.desc' } )
        CPanel:AddControl( "Numpad"  , { Label = "Scene key", Command = "npc_scene_key" } )
        CPanel:AddControl( "TextBox" , { Label = "Scene Name" , Command = "npc_scene_scene", MaxLength = 500 } )
        CPanel:AddControl( "TextBox" , { Label = "Actor Name" , Command = "npc_scene_actor", MaxLength = 500 } )
        CPanel:AddControl( "Slider"  , { Label = "Loop", Type = "int", Min = "0", Max = "100", Command = "npc_scene_loop"} )
        CPanel:AddControl( "CheckBox", { Label = "Allow Applying Scenes Multiple Times", Command = "npc_scene_multiple" } )
        CPanel:AddControl( "CheckBox", { Label = "Start On (When Using a Key)", Command = "npc_scene_start" } )
        CPanel:AddControl( "CheckBox", { Label = "Show Actors' Names Over Their Heads", Command = "npc_scene_render" } )
        CPanel:Help      ("")
        local ctrl = vgui.Create( "DTree", CPanel )
            ctrl:Dock( FILL )
            ctrl:DockMargin( 5, 0, 5, 0 )
        local node = ctrl:AddNode( "Scenes! (click one to select)" )
        ParseDir( node, "scenes/", ".vcd" )
    end
end

-- Manter tabela limpa