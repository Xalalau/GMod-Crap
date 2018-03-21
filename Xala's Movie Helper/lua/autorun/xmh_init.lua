--Sends materials
resource.AddFile("materials/effects/backup1.vmt")
resource.AddFile("materials/effects/backup2.vmt")
resource.AddFile("materials/effects/backup3.vmt")

resource.AddFile("materials/erase.vmt")

resource.AddFile("materials/skybox/backuplf.vmt")
resource.AddFile("materials/skybox/backupft.vmt")
resource.AddFile("materials/skybox/backuprt.vmt")
resource.AddFile("materials/skybox/backupbk.vmt")
resource.AddFile("materials/skybox/backupdn.vmt")
resource.AddFile("materials/skybox/backupup.vmt")

resource.AddFile("materials/skybox/green.vmt")

-- Language
local LANG = ""
include("xmh/language.lua" )

if SERVER then
  -- Sends the client files
    AddCSLuaFile()
    AddCSLuaFile("xmh/client/xmh_cl.lua"         )
    AddCSLuaFile("xmh/client/commands_table.lua" )
    AddCSLuaFile("xmh/client/modules/XMHText.lua")
    AddCSLuaFile("xmh/language.lua")
  
  -- Starts the server side
  include("xmh/server/xmh_sv.lua" )
end

if CLIENT then
  -- Folders and files into DATA
  xmh_data_folder = "xmh"
  xmh_teleports_folder = xmh_data_folder.."/teleports"

  xmh_text_file = xmh_data_folder.."/text_editor.txt"
  xmh_lang_file = xmh_data_folder.."/language.txt"
  xmh_teleports_file = xmh_teleports_folder.."/"..game.GetMap()..".txt"

  -- Creates xmh_data_folder
  if !file.Exists(xmh_data_folder, "DATA") then
    file.CreateDir(xmh_data_folder)
  end

  -- Creates xmh_teleports_folder
  if !file.Exists(xmh_teleports_folder, "DATA") then
    file.CreateDir(xmh_teleports_folder)
  end

  -- Loads the XMHText
  include("xmh/client/modules/XMHText.lua")
  
  -- Starts the client side
  include("xmh/client/xmh_cl.lua")
end
