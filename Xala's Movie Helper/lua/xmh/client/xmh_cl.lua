--[[
   \   XALA'S MOVIE HELPER
 =3 ]]  Revision = "XMH.Rev.22.3 - 27/08/2016 (dd/mm/yyyy)" --[[
 =o |   License: MIT
   /   Created by: Xalalau Xubilozo
  |
   \   Garry's Mod Brasil
 =< |   http://www.gmbrblog.blogspot.com.br/
 =b |   https://github.com/xalalau/GMod/tree/master/Xala's%20Movie%20Helper
   /   Enjoy! - Aproveitem!
]]

----------------------------
-- Global variables
----------------------------

local xmh_adm = false
local shadows_combobox
local teleport_combobox
local teleport_positions = {}
local mark_clear = { -- Cleanup table
  ["Cleanup"] = 1,
  ["Display"] = 1,
  ["Flashlight"] = 1,
  ["General"] = 1,
  ["NPCMovement"] = 1,
  ["Physics"] = 1,
  ["Shadows"] = 1,
  ["ThirdPerson"] = 1,
  ["Defauts"] = 0
}
local supported_langs = {
 [1] = "en",
 [2] = "pt",
 [3] = "game",
}

----------------------------
-- General
----------------------------

-- Returns DForm ComboBoxes selected values
local function getComboBoxSelection(combo)
  if combo:GetSelected() == nil then
    return nil
  end
  local words = string.Explode(" ", combo:GetSelected())
  local name = ""
  local space = 0
  for k,v in pairs(words) do
    if v != "nil" then
      if space == 0 then
        name = name..v
        space = 1
      else
        name = name.." "..v
      end
    end
  end
  return name
end

----------------------------
-- Admin
----------------------------

-- Sets admin var on players first spawn
net.Receive("XMH_XMHAdmin",function(ply)
  xmh_adm = net.ReadBool()
end)

-- Checks admin privilegies
-- Returns true or false
local function checkAdmin()
  local ply = LocalPlayer()
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      return true
    end
  end
  return false
end

-- Renews admin privileges (Not very usefull without Derma/HTML, but ok...)
local function AdminCheck()
  if checkAdmin() == true and xmh_adm == false then
    xmh_adm = true
  elseif checkAdmin() == false and xmh_adm == true then
    xmh_adm = false
  end
end

----------------------------
-- Language
----------------------------

-- Checks if a language is supported
local function checkLanguage(language)
  for k,v in pairs(supported_langs) do
    if v == language then
      return true
    end
  end
  return false
end

-- Loads the correct language
local function loadDefaultLanguage()
  if !file.Exists(xmh_lang_file, "DATA") then
    LANG = GetConVarString('gmod_language')
    if checkLanguage(language) == false then
      LANG = "en"
    end
  else
    LANG = file.Read(xmh_lang_file, "DATA")
    print(XMH_LANG[LANG]["client_lang_forced"].."'".. LANG.."'!")
  end
  timer.Create("Lang",1.5,0,function()
    net.Start       ("XMH_Language")
    net.WriteString (LANG          )
    net.SendToServer(              )
  end)
end

-- Forces the language that the player wants
local function forceLanguage(ply,_,_,language)
  if checkLanguage(language) == false then
    print(XMH_LANG[LANG]["client_lang_not_supported"])
    for k,v in pairs(supported_langs) do
      print(v)
    end
    return
  end
  print(XMH_LANG[LANG]["client_lang_forced"].."'".. language.."'!")
  print(XMH_LANG[LANG]["client_lang_restart"])
  if language == "game" then
    file.Delete(xmh_lang_file)
    return
  end
  file.Write(xmh_lang_file, language)
end

loadDefaultLanguage()

----------------------------
-- Console variables
----------------------------

-- "Server(*)" and "Client" indicate where the code runs
-- The values of the "Server" variables (without *) need to be stored globaly in xmh_sv.lua file

CreateClientConVar("xmh_corpses_var"       ,32  ,false,false) -- Server
CreateClientConVar("xmh_knockback_var"     ,1   ,false,false) -- Server
CreateClientConVar("xmh_noclipspeed_var"   ,5   ,false,false) -- Server
CreateClientConVar("xmh_footsteps_var"     ,1   ,false,false) -- Server
CreateClientConVar("xmh_voiceicons_var"    ,1   ,false,false) -- Server
CreateClientConVar("xmh_runspeed_var"      ,500 ,false,false) -- Server*
CreateClientConVar("xmh_walkspeed_var"     ,250 ,false,false) -- Server*
CreateClientConVar("xmh_jumpheight_var"    ,200 ,false,false) -- Server*
CreateClientConVar("xmh_npcwalkrun_var"    ,1   ,false,false) -- Server
CreateClientConVar("xmh_aidisabled_var"    ,0   ,false,false) -- Server
CreateClientConVar("xmh_aidisable_var"     ,0   ,false,false) -- Server
CreateClientConVar("xmh_person_var"        ,0   ,false,false) --   Client
CreateClientConVar("xmh_shake_var"         ,0   ,false,false) --   Client
CreateClientConVar("xmh_skybox_var"        ,0   ,false,false) --   Client
CreateClientConVar("xmh_mode_var"          ,0   ,false,false) -- Server
CreateClientConVar("xmh_invisible_var"     ,1   ,false,false) -- Server*
CreateClientConVar("xmh_invisibleall_var"  ,1   ,false,false) -- Server
CreateClientConVar("xmh_toolgun_var"       ,1   ,false,false) --   Client
CreateClientConVar("xmh_decals_var"        ,2048,false,false) --   Client (Unnecessary convar, but without this the command always starts with value 1 (game bug))
CreateClientConVar("xmh_cleanup_var"       ,0   ,false,false) -- Server
CreateClientConVar("xmh_save_var"          ,0   ,false,false) --   Client
CreateClientConVar("xmh_physgun_var"       ,1   ,false,false) --   Client
CreateClientConVar("xmh_chatvoice_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_throwforce_var"    ,1000,false,false) -- Server
CreateClientConVar("xmh_falldamage_var"    ,0   ,false,false) -- Server
CreateClientConVar("xmh_fullflashlight_var",0   ,false,false) --   Client (Unnecessary convar, but without this the command always starts with value 1 (game bug))
CreateClientConVar("xmh_timescale_var"     ,1   ,false,false) -- Server
CreateClientConVar("xmh_wfriction_var"     ,8   ,false,false) -- Server
CreateClientConVar("xmh_weapammitem_var"   ,1   ,false,false) --   Client
CreateClientConVar("xmh_error_var"         ,1   ,false,false) --   Client
CreateClientConVar("xmh_fov_var"           ,0   ,false,false) --   Client
CreateClientConVar("xmh_viewmodel_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_clcleanup_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_cldisplay_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_clfl_var"          ,1   ,false,false) --   Client
CreateClientConVar("xmh_clgeneral_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_clnpcmove_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_clphysics_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_clshadows_var"     ,1   ,false,false) --   Client
CreateClientConVar("xmh_cleartp_var"       ,1   ,false,false) --   Client
CreateClientConVar("xmh_checkuncheck_var"  ,1   ,false,false) --   Client
CreateClientConVar("xmh_removeweapons_var" ,1   ,false,false) -- Server

CreateClientConVar("xmh_make_invisibility_admin_only_var",0,false,false) -- Server (Special cvar only option)
CreateClientConVar("xmh_positionname_var" ,XMH_LANG[LANG]["client_var_teleport"],false,false) -- Client

----------------------------
-- Teleport
----------------------------

-- Loads the map saved teleport_positions file
local function loadTeleports()
  if file.Exists(xmh_teleports_file, "DATA") then
    teleport_positions = util.JSONToTable(file.Read(xmh_teleports_file, "DATA"))
    for k,v in pairs(teleport_positions) do
      teleport_combobox:AddChoice(k)
    end
  end
end

-- Adds a new teleport point and saves the teleport_positions to a file
local function createTeleport(ply)
  local name = GetConVar("xmh_positionname_var"):GetString()
  if name == "" then
    return
  end
  if teleport_positions[name] == nil then
    teleport_combobox:AddChoice(name)
  end
  teleport_positions[name] = ply:GetPos()
  file.Write(xmh_teleports_file, util.TableToJSON(teleport_positions))
end

-- Teleports the player to a point
local function teleportToPos()
  local vec = teleport_positions[getComboBoxSelection(teleport_combobox)]
  if vec == nil then
    return
  end
  net.Start       ("XMH_TeleportPlayer")
  net.WriteVector (vec                 )
  net.SendToServer(                    )
end

-- Deletes a teleport point and refreshs the teleport_positions file
local function deleteTeleportPos()
  local name = getComboBoxSelection(teleport_combobox)
  if name == nil then
    return
  end
  teleport_positions[name] = nil
  teleport_combobox:Clear()
  for k,v in pairs(teleport_positions) do
    teleport_combobox:AddChoice(k)
  end
  file.Write(xmh_teleports_file, util.TableToJSON(teleport_positions))
end

----------------------------
-- Mixed panel functions
----------------------------

-- Turns skybox into green
function XMH_Skybox(skybox_bool)
  local SourceSkyname = GetConVar("sv_skyname"):GetString()
  local SourceSkyPre  = {"lf","ft","rt","bk","dn","up"}
  local SourceSkyMat  = {
    Material("skybox/"..SourceSkyname.."lf"),
    Material("skybox/"..SourceSkyname.."ft"),
    Material("skybox/"..SourceSkyname.."rt"),
    Material("skybox/"..SourceSkyname.."bk"),
    Material("skybox/"..SourceSkyname.."dn"),
    Material("skybox/"..SourceSkyname.."up"),
  }
  local T, A

  if Material("skybox/backup"..SourceSkyPre[1]):Width() == 2 then -- Backup sky textures
    for A = 1,6 do
      T = SourceSkyMat[A]:GetTexture("$basetexture") 
      Material("skybox/backup"..SourceSkyPre[A]):SetTexture("$basetexture",T)
    end
  end
  if skybox_bool == 1 then -- Green sky
    T = Material("skybox/green"):GetTexture("$basetexture")
    for A = 1,6 do 
      SourceSkyMat[A]:SetTexture("$basetexture",T)
    end
  else -- Original sky
    for A = 1,6 do
      T = Material("skybox/backup"..SourceSkyPre[A]):GetTexture("$basetexture")
      SourceSkyMat[A]:SetTexture("$basetexture",T)
    end
  end
end

-- Removes toolgun effects
function XMH_ToolGun(toolgun_bool)
  local GModToolgunMat = {
    Material("effects/select_ring"),
    Material("effects/tool_tracer"),
    Material("effects/select_dot" ),
  }
  local T, A

  if Material("effects/backup"..1):Width() == 2 then -- Backup toolgun textures
    for A = 1,3 do 
      T = GModToolgunMat[A]:GetTexture("$basetexture") 
      Material("effects/backup"..A):SetTexture("$basetexture",T)
    end
  end
  if toolgun_bool == 0 then -- Remove textures
    T = Material("erase"):GetTexture("$basetexture") 
    for A = 1,3 do
      GModToolgunMat[A]:SetTexture("$basetexture",T)
    end
  else -- Restore textures
    for A = 1,3 do
      T = Material("effects/backup"..A):GetTexture("$basetexture")
      GModToolgunMat[A]:SetTexture("$basetexture",T)
    end
  end
end

-- Hides missing models
function XMH_Error(error_bool)
  -- for k,v in pairs(ents.FindByModel("models/error.mdl")) do -- Didn't work
  for k,v in pairs(ents.GetAll()) do
    if v:GetModel() == "models/error.mdl" then
      if error_bool == 0 then
        v:SetNoDraw(true)
        hook.Add( "PlayerSpawnEffect", "PlayerSpawnEffect_xmh", function(ply,effect)
          return effect != "models/error.mdl"
        end)
      else
        v:SetNoDraw(false)
        hook.Remove("PlayerSpawnEffect", "PlayerSpawnEffect_xmh")
      end
    end
  end
end

-- Turns NPCs into pedestrians
local function Pedestrians()
  print("")
  print("___________________________________________________________")
  print("")
  print(XMH_LANG[LANG]["client_func_pedestrians"])
  print("___________________________________________________________")
  print("")
  RunConsoleCommand("showconsole")
end

-- Enables automatic playermodel lipsync
local function LipSync()
  print("")
  print("___________________________________________________________")
  print("")
  print(XMH_LANG[LANG]["client_func_lipsync"])
  print("___________________________________________________________")
  print("")
  RunConsoleCommand("showconsole")
end

-- Removes the crosshair
local function HideCrosshair()
  print("")
  print("___________________________________________________________")
  print("")
  print(XMH_LANG[LANG]["client_func_crosshair"])
  print("___________________________________________________________")
  print("")
  RunConsoleCommand("showconsole")
end

-- Shows the current shadows resolution
local function ShadowResChk()
  local aux = GetConVar("r_flashlightdepthres"):GetInt()
  local aux = XMH_LANG[LANG]["client_func_shadowres"].. aux .. "x" .. aux
  print("___________________________________________________________")
  print("")
  print(aux)
  print("___________________________________________________________")
  RunConsoleCommand("showconsole")
end

-- Changes the shadows resolution
function ShadowRes()
    opt = getComboBoxSelection(shadows_combobox)
    print(opt)
    if opt == nil then
      return
    end
    if (opt != "0" and opt != GetConVar("r_flashlightdepthres"):GetString()) then
      RunConsoleCommand("r_flashlightdepthres", opt)
    end
end

-- Remove dead corpses from de ground
local function ClearCorpses()
  net.Start       ("XMH_RunOneLineLua")
  net.WriteString ("xmh_clearcorpses" )
  net.SendToServer(                   )
end

-- Restores broken windows
local function RepairWindows()
  net.Start       ("XMH_RepairWindows")
  net.SendToServer(                   )
end

-- Hides decals and spraws
local function ClearDecals() 
  RunConsoleCommand("r_cleardecals") -- This removes decals
  RunConsoleCommand("r_cleardecals") -- And this removes sprays
end

-- Hides physgun effects
function XMH_PhysgunEffects(physgun_bool)
  if physgun_bool == 0 then
    RunConsoleCommand("effects_freeze"   , "0")
    RunConsoleCommand("effects_unfreeze" , "0")
    RunConsoleCommand("physgun_drawbeams", "0")
    RunConsoleCommand("physgun_halo"     , "0")
  else
    RunConsoleCommand("effects_freeze"   , "1")
    RunConsoleCommand("effects_unfreeze" , "1")
    RunConsoleCommand("physgun_drawbeams", "1")
    RunConsoleCommand("physgun_halo"     , "1")
  end
end

-- Hides the current view and world models
function XMH_ViewWorldModels()
  if GetConVar("xmh_viewmodel_var"):GetInt() == 0 then
    RunConsoleCommand("impulse", "200")
    hook.Add("PlayerSwitchWeapon", "PlayerSwitchWeapon_xmh", function(ply)
      timer.Create("Treme",0.1,1,function() -- needed delay
        RunConsoleCommand("impulse", "200")
        RunConsoleCommand("xmh_viewmodel_var", "1")
      end)
    end)
  else
    RunConsoleCommand("impulse", "200")
    hook.Remove("PlayerSwitchWeapon", "PlayerSwitchWeapon_xmh")
  end
end

-- Alternates between first person and third person
function XMH_Person(person_bool)
  if person_bool == 1 then
    RunConsoleCommand("thirdperson")
  else
    RunConsoleCommand("firstperson")
  end
end

-- """Earthquake""" simulator
function XMH_Shake(shake_bool)
  if shake_bool == 1 then
    timer.Create("Shake",1,1000,function() util.ScreenShake(LocalPlayer():GetPos(), 5, 5, 10, 5000) end)
  else
    timer.Remove("Shake")
    RunConsoleCommand("shake_stop")
  end
end

-- Enables client automatic game saving
function XMH_AutoSave(save_bool)
  if save_bool == 1 then
    timer.Create("AutoSave",360,0,function()
      print(XMH_LANG[LANG]["client_func_game_saved"])
      RunConsoleCommand("gm_save")
    end)
  else
    timer.Destroy("AutoSave");
  end
end

-- Runs a command (it's used for the sub_type "fix" from commands_table.lua file)
function XMH_RunCommand(command, value)
  RunConsoleCommand(command, tostring(value))
end

-- Resets the decals and changes it's quantity
function XMH_DecalsQuantity(decals_quant)
  ClearDecals()
  RunConsoleCommand("r_decals", tostring(decals_quant))
end

-- Adds/Deletes hooks for derma invisibility
function XMH_SetInvisibilityHook(hook_name, hook_bool)
  if hook_bool == 0 then
    hook.Add(hook_name, hook_name.."_xmh", function(ply)
      return 0
    end)
  else
    hook.Remove(hook_name, hook_name.."_xmh")
  end
end

----------------------------
-- [Import] Commands table
----------------------------

-- It needs to be here! Do not move this section
include("xmh/client/commands_table.lua")

----------------------------
-- "Defaults"
----------------------------

-- Checks or unchecks all the sections at once
local function CheckUncheck()
  local value = GetConVar("xmh_checkuncheck_var"):GetInt()

  if value == 1 then
    value = 0
    RunConsoleCommand("xmh_checkuncheck_var", "0")
  else
    value = 1
    RunConsoleCommand("xmh_checkuncheck_var", "1")
  end
  for k,_ in pairs(xmh_commands) do
    if xmh_commands[k].category == "Defaults" then
      RunConsoleCommand(k, tostring(value))
    end
  end
end

-- Checks or unchecks a section
local function SetSectionsToReset(section, value) 
  mark_clear[section] = value
end

-- Sets all the commands in the checked sections to defaults
local function Defaults()
  local stored_value, actual_value

  for k,_ in pairs(xmh_commands) do
    if mark_clear[xmh_commands[k].category] == 1 then -- Is the category marked for cleaning?
      if (xmh_commands[k].cheat == true and GetConVar("sv_cheats"):GetInt() == 1) or xmh_commands[k].cheat == false then -- Is the cheats sittuation ok?
        if (xmh_commands[k].admin == true and checkAdmin() == true) or xmh_commands[k].admin == false then -- Is admin or user ok?
          actual_value = tonumber(string.format("%.2f", GetConVar(k):GetFloat())) -- Getting the value...
          if (xmh_commands[k].default != actual_value) then -- Are the values different?
            RunConsoleCommand (k, tostring(xmh_commands[k].default))
          end
        end
      end
    end
  end
end

-- Sends a "defaults order" to all players
local function DefaultsAll()
  net.Start        ("XMH_DefaultsAll"           )
  net.WriteInt     (mark_clear["Cleanup"]    , 2)
  net.WriteInt     (mark_clear["Display"]    , 2)
  net.WriteInt     (mark_clear["Flashlight"] , 2)
  net.WriteInt     (mark_clear["General"]    , 2)
  net.WriteInt     (mark_clear["NPCMovement"], 2)
  net.WriteInt     (mark_clear["Physics"]    , 2)
  net.WriteInt     (mark_clear["Shadows"]    , 2)
  net.WriteInt     (mark_clear["ThirdPerson"], 2)
  net.SendToServer (                            )
end

-- Receives a "defaults order" and run it
net.Receive("XMH_DefaultsAll",function(_,ply)
  local backup = table.Copy(mark_clear)
  mark_clear["Cleanup"]     = net.ReadInt(2)
  mark_clear["Display"]     = net.ReadInt(2)
  mark_clear["Flashlight"]  = net.ReadInt(2)
  mark_clear["General"]     = net.ReadInt(2)
  mark_clear["NPCMovement"] = net.ReadInt(2)
  mark_clear["Physics"]     = net.ReadInt(2)
  mark_clear["Shadows"]     = net.ReadInt(2)
  mark_clear["ThirdPerson"] = net.ReadInt(2)
  Defaults()
  mark_clear["Cleanup"]     = backup["Cleanup"]
  mark_clear["Display"]     = backup["Display"]
  mark_clear["Flashlight"]  = backup["Flashlight"]
  mark_clear["General"]     = backup["General"]
  mark_clear["NPCMovement"] = backup["NPCMovement"]
  mark_clear["Physics"]     = backup["Physics"]
  mark_clear["Shadows"]     = backup["Shadows"]
  mark_clear["ThirdPerson"] = backup["ThirdPerson"]
end)

----------------------------
-- Syncing
----------------------------

-- Gets net "int 2" infos
net.Receive("XMH_SyncValuesInt2",function()
  local value = net.ReadInt(2)
  local command = net.ReadString()
  xmh_commands[command].value = value
  RunConsoleCommand(command, tostring(value))
end)

-- Gets net "int 16" infos
net.Receive("XMH_SyncValuesInt16",function()
  local value = net.ReadInt(16)
  local command = net.ReadString()
  xmh_commands[command].value = value
  RunConsoleCommand(command, tostring(value))
end)

-- Gets net "float" infos
net.Receive("XMH_SyncValuesFloat",function()
  local value = net.ReadFloat()
  local command = net.ReadString()
  xmh_commands[command].value = value
  RunConsoleCommand(command, tostring(value))
end)

-- Doesn't let some options reset at players respawn
net.Receive("XMH_PlayerRespawn",function()
  xmh_commands["xmh_runspeed_var"].value   = 500
  xmh_commands["xmh_walkspeed_var"].value  = 250
  xmh_commands["xmh_jumpheight_var"].value = 200
  -- Is "ivisible all" set to 1 and you aren't the guy who turned it on? yes = get invisible.
  -- Did you set yourself to be invisible and it's permitted for players OR you are admin? Yes = get invisible.
  if (net.ReadInt(2) == 0 and net.ReadString() != LocalPlayer():Nick()) or 
  (GetConVar("xmh_invisible_var"):GetInt() == 0 and (GetConVar("xmh_make_invisibility_admin_only_var"):GetInt() == 0 or checkAdmin() == true)) then
    net.Start       ("XMH_Invisible")
    net.WriteInt    (0, 2           )
    net.SendToServer(               )
  end
end)

-- This timer syncs our "xmh_" cvars with their menu states and applies the changes to the game
timer.Create("Sync",0.7,0,function()
  local actual_value, prefix, var_type

  AdminCheck()

  for k,_ in pairs(xmh_commands) do
    prefix = string.Explode("_", k)
    if prefix[1] == "xmh" then -- Is it a "xmh_" var?
      if xmh_commands[k].command_type == "net" or xmh_commands[k].command_type == "hook" or xmh_commands[k].command_type == "function" then -- Is the type ok?
        if (xmh_commands[k].cheat == true and GetConVar("sv_cheats"):GetInt() == 1) or xmh_commands[k].cheat == false then -- Is the cheats sittuation ok?
          if (xmh_commands[k].admin == true and checkAdmin() == true) or xmh_commands[k].admin == false then -- Is admin or user ok?
            actual_value = tonumber(string.format("%.2f", GetConVar(k):GetFloat())) -- Getting the value...
            if (xmh_commands[k].value != actual_value) then -- Are the values different?
              -- Yes = applying changes...
              if xmh_commands[k].command_type == "net" then
                if xmh_commands[k].var_type == "int2" then
                  net.Start       (xmh_commands[k].func)
                  net.WriteString (k                   )
                  net.WriteInt    (actual_value, 2     )
                  net.SendToServer(                    )
                elseif xmh_commands[k].var_type == "int16" then
                  net.Start       (xmh_commands[k].func)
                  net.WriteString (k                   )
                  net.WriteInt    (actual_value, 16    )
                  net.SendToServer(                    )
                elseif xmh_commands[k].var_type == "float" then
                  net.Start       (xmh_commands[k].func)
                  net.WriteString (k                   )
                  net.WriteFloat  (actual_value        )
                  net.SendToServer(                    )
                end
              elseif xmh_commands[k].command_type == "function" then
                if xmh_commands[k].sub_type == nil then
                  if xmh_commands[k].category == "Defaults" then
                    SetSectionsToReset(xmh_commands[k].value2, actual_value)
                  else
                    xmh_commands[k].func(actual_value)
                  end
                elseif xmh_commands[k].sub_type == "fix" then
                  xmh_commands[k].func(xmh_commands[k].real_command, actual_value)
                end
              elseif xmh_commands[k].command_type == "hook" then
                xmh_commands[k].func(xmh_commands[k].value2, actual_value)
              end
              xmh_commands[k].value = actual_value -- Setting the auxiliar commands[k].value var...
            end
          end
        end
      end
    end
  end
end)

----------------------------
-- Console commands
----------------------------

-- These are used for options that can interact normally/directly with the tool's functions
concommand.Add("xmh_defaults"         , Defaults         )
concommand.Add("xmh_defaultsall"      , DefaultsAll      )
concommand.Add("xmh_cleardecals"      , ClearDecals      )
concommand.Add("xmh_clearcorpses"     , ClearCorpses     )
concommand.Add("xmh_shadowres"        , ShadowRes        )
concommand.Add("xmh_shadowreschk"     , ShadowResChk     )
concommand.Add("xmh_pedestrians"      , Pedestrians      )
concommand.Add("xmh_repairwindows"    , RepairWindows    )
concommand.Add("xmh_lipsync"          , LipSync          )
concommand.Add("xmh_crosshair"        , HideCrosshair    )
concommand.Add("xmh_checkuncheck"     , CheckUncheck     )
concommand.Add("xmh_forcelanguage"    , forceLanguage    )
concommand.Add("xmh_saveteleport"     , createTeleport   )
concommand.Add("xmh_teleporttopos"    , teleportToPos    )
concommand.Add("xmh_deleteteleportpos", deleteTeleportPos)

----------------------------
-- Panel
----------------------------

function Informations(Panel)
  Panel:Help          ("Xala's Movie Helper"                             )
  if checkAdmin() == true then
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_info_admin_on"       ])
  else
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_info_admin_off"      ])
  end
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_sv_cheats_msg"  ])
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_info_sv_cheats_desc" ])
  Panel:Help          (""                                                )
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags"           ])
  if checkAdmin() == true then
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_info_tags_desc_admin"])
  else
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_info_tags_desc_ply"  ])
  end
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_1"         ])
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_2"         ])
  if checkAdmin() == true then
    Panel:Help        (XMH_LANG[LANG]["client_menu_info_tags_3"         ])
  end
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_4"         ])
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_5"         ])
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_6"         ])
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_tags_7"         ])
  Panel:Help          (""                                                )
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_hint_1"         ])
  Panel:Help          (XMH_LANG[LANG]["client_menu_info_hint_2"         ])
  Panel:Help          (""                                                )
  Panel:Help          (Revision                                          )
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_info_credits"        ])
end

local function Cleanup(Panel)
  if checkAdmin() == true then
    Panel:Button      (XMH_LANG[LANG]["client_menu_cleanup_corpses"         ], "xmh_clearcorpses")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_cleanup_corpses_desc"    ])
  end
  Panel:Button        (XMH_LANG[LANG]["client_menu_cleanup_decals"          ], "xmh_cleardecals")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_cleanup_decals_desc"     ])
  Panel:Button        (XMH_LANG[LANG]["client_menu_cleanup_decalsmodel"     ], "cl_removedecals")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_cleanup_decalsmodel_desc"])
  Panel:Button        (XMH_LANG[LANG]["client_menu_cleanup_sounds"          ], "stopsound")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_cleanup_sounds_desc"     ])
  if checkAdmin() == true then
    Panel:Button      (XMH_LANG[LANG]["client_menu_cleanup_windows"         ], "xmh_repairwindows")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_cleanup_windows_desc"    ])
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_cleanup_auto"            ], "xmh_cleanup_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_cleanup_auto_desc"       ])
  end
end

local function HideOrShow(Panel)
  Panel:Button        (XMH_LANG[LANG]["client_menu_hideshow_crosshair"        ], "xmh_crosshair")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_crosshair_desc"   ]                 )
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_wvmodels"         ], "xmh_viewmodel_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_wvmodels_desc"    ])
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_hideshow_hl2w"             ], "xmh_removeweapons_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_hl2w_desc"        ])
  end
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_vmodels"          ], "r_drawviewmodel")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_vmodels_desc"     ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_invisible"        ], "xmh_invisible_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_invisible_desc"   ])
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_hideshow_invisibleall"     ], "xmh_invisibleall_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_invisibleall_desc"])
  end
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_tgun"             ], "xmh_toolgun_var" )
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_tgun_desc"        ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_pgun"             ], "xmh_physgun_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_pgun_desc"        ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_errors"           ], "xmh_error_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_errors_desc"      ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_misc"             ], "xmh_weapammitem_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_misc_desc"        ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_voicen"           ], "xmh_chatvoice_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_voicen_desc"      ])
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_hideshow_voicei"           ], "xmh_voiceicons_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_voicei_desc"      ])
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_hideshow_foot"             ], "xmh_footsteps_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_foot_desc"        ])
  end
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_decmod"           ], "r_drawmodeldecals")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_decmod_desc"      ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_particles"        ], "r_drawparticles")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_particles_desc"   ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_3dskybox"         ], "r_3dsky")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_3dskybox_desc"    ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_water"            ], "cl_show_splashes")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_water_desc"       ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_ropes"            ], "r_drawropes")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_ropes_desc"       ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_laser"            ], "r_DrawBeams")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_laser_desc"       ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_hideshow_ents"             ], "r_drawentities")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_ents_desc"        ])
  if checkAdmin() == true then
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_hideshow_corpses"          ], "xmh_corpses_var", 0, 200)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_corpses_desc"     ])
  end
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_hideshow_deathn"           ], "hud_deathnotice_time", 0, 12)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_deathn_desc"      ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_hideshow_bchat"            ], "hud_saytext_time", 0, 24)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_bchat_desc"       ])
  if checkAdmin() == true then
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_hideshow_decals"           ], "xmh_decals_var", 1, 5096)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_hideshow_decals_desc"      ])
  end
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_hideshow_detail"           ], "cl_detaildist", 0, 20000)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_hideshow_detail_desc"      ])
end

local function Flashlight(Panel)
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_flashlight_lock"           ], "r_flashlightlockposition")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_lock_desc"      ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_flashlight_brightness"     ], "xmh_fullflashlight_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_brightness_desc"])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_flashlight_area"           ], "r_flashlightdrawfrustum")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_area_desc"      ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_flashlight_minr"           ], "r_flashlightnear", 1, 1000)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_minr_desc"      ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_flashlight_maxr"           ], "r_flashlightfar", 1, 10000)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_maxr_desc"      ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_flashlight_fov"            ], "r_flashlightfov", 1, 179)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_flashlight_fov_desc"       ])
end

local function General(Panel)
  Panel:Button        (XMH_LANG[LANG]["client_menu_general_editor"       ], "xmh_texteditor")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_editor_desc"  ])
  Panel:Button        (XMH_LANG[LANG]["client_menu_general_lipsync"      ], "xmh_lipsync")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_lipsync_desc" ])
  Panel:CheckBox      (XMH_LANG[LANG]["client_menu_general_shake"        ], "xmh_shake_var")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_shake_desc"   ])
  if (SourceSkyname != "painted") then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_general_green"        ], "xmh_skybox_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_general_green_desc"   ])
  end
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_general_autosave"     ], "xmh_save_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_general_autosave_desc"])
  end
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_general_pupil"        ], "r_eyesize", -0.5, -0.5, 2)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_pupil_desc"   ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_general_fov"          ], "xmh_fov_var", 0, 90)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_fov_desc"     ])
  Panel:NumSlider     (XMH_LANG[LANG]["client_menu_general_vfov"         ], "viewmodel_fov", 0, 360)
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_general_vfov_desc"    ])
end

local function NPCMovement(Panel)
  Panel:Button        (XMH_LANG[LANG]["client_menu_npcmov_select"        ], "npc_select")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_npcmov_select_desc"   ])
  Panel:Button        (XMH_LANG[LANG]["client_menu_npcmov_move"          ], "npc_go")
  Panel:ControlHelp   (XMH_LANG[LANG]["client_menu_npcmov_move_desc"     ])
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_npcmov_run"           ], "xmh_npcwalkrun_var") -- Bug: npc_go_do_run allways returns 1...
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_npcmov_run_desc"      ])
  end
  -- Panel:AddControl    ("Button",   { Text = "Randomly move (running) (c)"     , "npc_go_random" ) -- Bug: npc_go_random stopped working after an update...
  -- Panel:ControlHelp   ("The NPCs start to walk randomly around the maps.")
  if checkAdmin() == true then
    Panel:Button      (XMH_LANG[LANG]["client_menu_npcmov_turnpedestrian"], "xmh_pedestrians" )
  end
  Panel:Help          ("________________________________"                 )
  Panel:Help          (""                                                 )
  if checkAdmin() == true then
    Panel:Help        (XMH_LANG[LANG]["client_menu_npcmov_mov_msg"       ])
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_npcmov_ai_disabled"   ], "xmh_aidisabled_var")
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_npcmov_ai_disable"    ], "xmh_aidisable_var")
  else
    Panel:Help        (XMH_LANG[LANG]["client_menu_npcmov_note"          ])
  end
end

local function Physics(Panel)
  if checkAdmin() == true then
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_physics_motion"       ], "xmh_mode_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_motion_desc"  ])
    Panel:CheckBox    (XMH_LANG[LANG]["client_menu_physics_fall"         ], "xmh_falldamage_var")
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_fall_desc"    ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_time"         ], "xmh_timescale_var", 0.06, 2.99, 2)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_time_desc"    ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_push"         ], "xmh_knockback_var", -9999, 9999)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_push_desc"    ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_pgunf"        ], "physgun_wheelspeed", 0, 100)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_pgunf_desc"   ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_throw"        ], "xmh_throwforce_var", 0, 20000)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_throw_desc"   ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_noclip"       ], "xmh_noclipspeed_var", 1, 300)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_noclip_desc"  ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_walk"         ], "xmh_walkspeed_var", 1, 10000)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_walk_desc"    ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_run"          ], "xmh_runspeed_var", 1, 10000)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_run_desc"     ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_jump"         ], "xmh_jumpheight_var", 0, 4000)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_jump_desc"    ])
    Panel:NumSlider   (XMH_LANG[LANG]["client_menu_physics_friction"     ], "xmh_wfriction_var", -20, 50)
    Panel:ControlHelp (XMH_LANG[LANG]["client_menu_physics_friction_desc"])
  else
    Panel:Help        (XMH_LANG[LANG]["client_menu_physics_ply"          ])
  end
end

local function Shadows(Panel)
  local resolution = XMH_LANG[LANG]["client_menu_shadows_res_p1"]..GetConVar("r_flashlightdepthres"):GetInt()..XMH_LANG[LANG]["client_menu_shadows_res_p2"]
  Panel:Button      (XMH_LANG[LANG]["client_menu_shadows_res_desc"       ], "xmh_shadowreschk")
  Panel:ControlHelp (resolution)
  shadows_combobox = Panel:ComboBox (XMH_LANG[LANG]["client_menu_shadows_combo"])
  shadows_combobox:AddChoice("1024 x 1024", "1024")
  shadows_combobox:AddChoice("2048 x 2048", "2048")
  shadows_combobox:AddChoice("4096 x 4096", "4096")
  shadows_combobox:AddChoice("8192 x 8192", "8192")
  Panel:Button      (XMH_LANG[LANG]["client_menu_shadows_change"         ], "xmh_shadowres")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_shadows_notes"          ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_shadows_bleeding"       ], "mat_slopescaledepthbias_shadowmap", 1, 16)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_shadows_bleeding_desc"  ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_shadows_blur"           ], "r_projectedtexture_filter", 0, 20, 2)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_shadows_blur_desc"      ])
  Panel:CheckBox    (XMH_LANG[LANG]["client_menu_shadows_brightness"     ], "mat_fullbright")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_shadows_brightness_desc"])
  Panel:CheckBox    (XMH_LANG[LANG]["client_menu_shadows_match"          ], "r_shadowrendertotexture")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_shadows_match_desc"     ])
end

local function Teleport(Panel)
  Panel:TextEntry   (XMH_LANG[LANG]["client_menu_teleport_name"       ], "xmh_positionname_var")
  Panel:Button      (XMH_LANG[LANG]["client_menu_teleport_save"       ], "xmh_saveteleport")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_teleport_save_desc"  ])
  Panel:Help        (""                                                )
  teleport_combobox = Panel:ComboBox(XMH_LANG[LANG]["client_menu_teleport_destination"])
  loadTeleports()
  Panel:Button      (XMH_LANG[LANG]["client_menu_teleport_delete"     ], "xmh_deleteteleportpos")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_teleport_delete_desc"])
  Panel:Button      (XMH_LANG[LANG]["client_menu_teleport_go"         ], "xmh_teleporttopos")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_teleport_go_desc"    ])
end

local function ThirdPerson(Panel)
  Panel:CheckBox    (XMH_LANG[LANG]["client_menu_thirdp_enable"            ], "xmh_person_var")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_enable_desc"       ])
  Panel:CheckBox    (XMH_LANG[LANG]["client_menu_thirdp_info"              ], "cam_showangles")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_info_desc"         ])
  Panel:CheckBox    (XMH_LANG[LANG]["client_menu_thirdp_colision"          ], "cam_collision")
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_colision_desc"     ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_distance"          ], "cam_idealdist", 30, 200)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_distance_desc"     ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_cam_downup"        ], "cam_idealdistup", -120, 120)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_cam_downup_desc"   ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_cam_leftright"     ], "cam_idealdistright", -200, 200)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_cam_leftright_desc"])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_ang_downup"        ], "cam_idealpitch", 0, 90)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_ang_downup_desc"   ])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_and_leftright"     ], "cam_idealyaw", -135, 135)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_and_leftright_desc"])
  Panel:NumSlider   (XMH_LANG[LANG]["client_menu_thirdp_spinvel"           ], "cam_ideallag", 0, 6000)
  Panel:ControlHelp (XMH_LANG[LANG]["client_menu_thirdp_spinvel_desc"      ])
end

local function Defaults(Panel)
  Panel:Button     (XMH_LANG[LANG]["client_menu_defaults_select_"        ], "xmh_checkuncheck")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section1"], "xmh_clcleanup_var")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section2"], "xmh_cldisplay_var")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section3"], "xmh_clfl_var")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section4"], "xmh_clgeneral_var")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section5"], "xmh_clnpcmove_var")
  if checkAdmin() == true then
    Panel:CheckBox (XMH_LANG[LANG]["client_menu_defaults_select_section6"], "xmh_clphysics_var")
  end
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section7"], "xmh_clshadows_var")
  Panel:CheckBox   (XMH_LANG[LANG]["client_menu_defaults_select_section8"], "xmh_cleartp_var")
  if checkAdmin() == false then
    Panel:Button   (XMH_LANG[LANG]["client_menu_defaults_set_ply"        ], "xmh_defaults")
  elseif checkAdmin() == true then
    Panel:Button   (XMH_LANG[LANG]["client_menu_defaults_set_admin"      ], "xmh_defaults")
    Panel:Button   (XMH_LANG[LANG]["client_menu_defaults_set_admin_all"  ], "xmh_defaultsall")
  end
end

hook.Add("PopulateToolMenu", "All hail the menus", function ()
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section1"] , XMH_LANG[LANG]["client_populate_menu_section1"] , "", "", Informations)
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section2"] , XMH_LANG[LANG]["client_populate_menu_section2"] , "", "", Cleanup     )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section3"] , XMH_LANG[LANG]["client_populate_menu_section3"] , "", "", HideOrShow  )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section4"] , XMH_LANG[LANG]["client_populate_menu_section4"] , "", "", Flashlight  )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section5"] , XMH_LANG[LANG]["client_populate_menu_section5"] , "", "", General     )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section6"] , XMH_LANG[LANG]["client_populate_menu_section6"] , "", "", NPCMovement )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section7"] , XMH_LANG[LANG]["client_populate_menu_section7"] , "", "", Physics     )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section8"] , XMH_LANG[LANG]["client_populate_menu_section8"] , "", "", Shadows     )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section9"] , XMH_LANG[LANG]["client_populate_menu_section9"] , "", "", Teleport    )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section10"], XMH_LANG[LANG]["client_populate_menu_section10"], "", "", ThirdPerson )
  spawnmenu.AddToolMenuOption("Utilities", "Xala's Movie Helper", XMH_LANG[LANG]["client_populate_menu_section11"], XMH_LANG[LANG]["client_populate_menu_section11"], "", "", Defaults    )
end)
