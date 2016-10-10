----------------------------
-- Global vars
----------------------------

  local xmh_first_respawn = 1
  local xmh_func_breakable_table = { 0 }

-- ---------------------------
-- "xmh_" cvars syncing table
-- ---------------------------

-- These custon client cvars need to have a single value between all players, so they are stored/synced here!

local sync_table = {
  ["xmh_corpses_var"] = {                           -- "xmh_" convar
    [1] = GetConVar("g_ragdoll_maxcount"):GetInt(), -- Default command value
    [2] = "g_ragdoll_maxcount",                     -- GMod convar
    [3] = "int16"                                   -- Value type (int2, int16 or float)
  },
  ["xmh_knockback_var"] = {
    [1] = GetConVar("phys_pushscale"):GetInt(),
    [2] = "phys_pushscale",
    [3] = "int16"
  },
  ["xmh_noclipspeed_var"] = {
    [1] = GetConVar("sv_noclipspeed"):GetInt(),
    [2] = "sv_noclipspeed",
    [3] = "int16"
  },
  ["xmh_wfriction_var"] = {
    [1] = GetConVar("sv_friction"):GetInt(),
    [2] = "sv_friction",
    [3] = "int16"
  },
  ["xmh_throwforce_var"] = {
    [1] = GetConVar("player_throwforce"):GetInt(),
    [2] = "player_throwforce",
    [3] = "int16"
  },
  ["xmh_footsteps_var"] = {
    [1] = GetConVar("sv_footsteps"):GetInt(),
    [2] = "sv_footsteps",
    [3] = "int2"
  },
  ["xmh_voiceicons_var"] = {
    [1] = GetConVar("mp_show_voice_icons"):GetInt(),
    [2] = "mp_show_voice_icons",
    [3] = "int2"
  },
  ["xmh_npcwalkrun_var"] = {
    [1] = GetConVar("npc_go_do_run"):GetInt(),
    [2] = "npc_go_do_run",
    [3] = "int2"
  },
  ["xmh_aidisabled_var"] = {
    [1] = GetConVar("ai_disabled"):GetInt(),
    [2] = "ai_disabled",
    [3] = "int2"
  },
  ["xmh_aidisable_var"] = { -- I'm using an "random" "useless" command here to make it work correctly
    [1] = GetConVar("commentary_available"):GetInt(), 
    [2] = "commentary_available",
    [3] = "int2"
  },
  ["xmh_timescale_var"] = {
    [1] = GetConVar("host_timescale"):GetFloat(),
    [2] = "host_timescale",
    [3] = "float"
  },
  ["xmh_falldamage_var"] = {
    [1] = 0,
    [3] = "int2"
  },
  ["xmh_make_invisibility_admin_only_var"] = {
    [1] = 0,
    [3] = "int2"
  },
  ["xmh_invisibleall_var"] = {
    [1] = 1,
    [3] = "int2",
    [4] = "" -- Extra field to store the name of the person who turned on this option
  },
  ["xmh_mode_var"] = {
    [1] = 0,
    [3] = "int2"
  },
  ["xmh_cleanup_var"] = {
    [1] = 0,
    [3] = "int2"
  },
  ["xmh_removeweapons_var"] = {
    [1] = 1,
    [3] = "int2"
  },
}

-- ---------------------------
-- Net identifiers
-- ---------------------------

util.AddNetworkString("XMH_Language"         )
util.AddNetworkString("XMH_XMHAdmin"         )
util.AddNetworkString("XMH_SyncValuesInt2"   )
util.AddNetworkString("XMH_SyncValuesInt16"  )
util.AddNetworkString("XMH_SyncValuesFloat"  )
util.AddNetworkString("XMH_SetInt2Command"   )
util.AddNetworkString("XMH_SetInt16Command"  )
util.AddNetworkString("XMH_SetFloatCommand"  )
util.AddNetworkString("XMH_RunOneLineLua"    )
util.AddNetworkString("XMH_Mode"             )
util.AddNetworkString("XMH_ClearCorpDec"     )
util.AddNetworkString("XMH_Defaults"         )
util.AddNetworkString("XMH_DefaultsAll"      )
util.AddNetworkString("XMH_Invisible"        )
util.AddNetworkString("XMH_InvisibleAll"     )
util.AddNetworkString("XMH_AiDisable"        )
util.AddNetworkString("XMH_RepairWindows"    )
util.AddNetworkString("XMH_PlayerRespawn"    )
util.AddNetworkString("XMH_TimeScale"        )
util.AddNetworkString("XMH_BlockInvisibility")
util.AddNetworkString("XMH_RemoveWeapons"    )
util.AddNetworkString("XMH_TeleportPlayer"   )

-- ---------------------------
-- General Functions
-- ---------------------------

net.Receive("XMH_Language",function(_,ply)
  if ply:IsValid() then
    LANG = net.ReadString()
  end
end)

local function SetGroup(ply)
  if ply:IsValid() then
  local xmh_adm
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      xmh_adm = true
    else
      xmh_adm = false
    end
    net.Start    ("XMH_XMHAdmin")
    net.WriteBool(xmh_adm       )
    net.Send     (ply           )
  end
end

local function send(k, ply)
  if sync_table[k][3] == "int2" then
    net.Start      ("XMH_SyncValuesInt2")
    net.WriteInt   (sync_table[k][1],2  )
    net.WriteString(k                   )
    net.Send       (ply                 )
  elseif sync_table[k][3] == "int16" then
    net.Start      ("XMH_SyncValuesInt16")
    net.WriteInt   (sync_table[k][1],16  )
    net.WriteString(k                    )
    net.Send       (ply                  )
  elseif sync_table[k][3] == "float" then
    net.Start      ("XMH_SyncValuesFloat")
    net.WriteFloat (sync_table[k][1],16  )
    net.WriteString(k                    )
    net.Send       (ply                  )
  end
end

local function SyncValuesFirstJoin(ply)
  if ply:IsValid() then
    for k, _ in pairs(sync_table) do
      send(k, ply)
    end
  end
end

local function SyncValues(ply,command,value)
  sync_table[command][1] = value
  for _, v in pairs(player.GetAll()) do
    if v:IsValid() and v:Nick() != ply:Nick() then
      send(command, v)
    end
  end
end

function ClearCorpses()
  RunConsoleCommand(sync_table["xmh_corpses_var"][2],"0"  )
  timer.Create("timer", 0.5, 1, function()
    RunConsoleCommand(sync_table["xmh_corpses_var"][2],tostring(sync_table["xmh_corpses_var"][1]))
  end)
end

local function CreateFuncBreakableTable(run)
  if xmh_func_breakable_table[1] == 0 or run == 1 then
    local i = 2
    for k,v in pairs(ents.FindByClass("func_breakable")) do
      if (v:GetMaterialType() == 89) then -- Glass
        xmh_func_breakable_table[i] = v
        xmh_func_breakable_table[i+1] = v:GetPos()
        xmh_func_breakable_table[i+2] = v:GetModel()
        xmh_func_breakable_table[i+3] = v:GetMaterial()
        xmh_func_breakable_table[i+4] = v:GetColor()
        xmh_func_breakable_table[i+5] = v:GetFlags()
        xmh_func_breakable_table[i+6] = v:Health()
        i = i + 7
      else
        i = i - 1
      end
    end
    xmh_func_breakable_table[1] = 1
  end
end

local function SpawnFBBlock(k)
  local block = ents.Create( 'func_breakable' )
    block.Coords = { xmh_func_breakable_table[k+1] }
    block:SetPos(xmh_func_breakable_table[k+1])
    block:SetModel(xmh_func_breakable_table[k+2])
    block:SetKeyValue('material', xmh_func_breakable_table[k+3])
    block:SetColor(xmh_func_breakable_table[k+4])
    block:SetKeyValue('spawnflags', xmh_func_breakable_table[k+5])
    block:SetKeyValue('health', xmh_func_breakable_table[k+6])
    block:SetKeyValue('disablereceiveshadows',1)
    block:SetKeyValue('disableshadows',1)
    block:SetKeyValue('PerformanceMode',3)
  block:Spawn()
end

net.Receive("XMH_Mode",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      SyncValues(ply,xmh_command,value)
      if value == 1 then
        RunConsoleCommand("sv_gravity"         ,"300" )
        RunConsoleCommand("host_timescale"     ,"0.4" )
        RunConsoleCommand("phys_timescale"     ,"0.2" )
        RunConsoleCommand("g_ragdoll_maxcount" ,"500" )
        RunConsoleCommand("phys_pushscale"     ,"9999")
        RunConsoleCommand("mp_show_voice_icons","0"   )
        SyncValues(ply,"xmh_corpses_var"   ,500 )
        SyncValues(ply,"xmh_knockback_var" ,9999)
        SyncValues(ply,"xmh_voiceicons_var",0   )
        for k,v in pairs(player.GetAll()) do
          if v:IsValid() then
            v:SendLua('RunConsoleCommand("physgun_wheelspeed"  ,"100")')
            v:SendLua('RunConsoleCommand("hud_deathnotice_time","0"  )')
            v:SendLua('RunConsoleCommand("hud_saytext_time"    ,"0"  )')
            v:SendLua('RunConsoleCommand("cl_showhints"        ,"0"  )')
          end
        end
      else
        RunConsoleCommand("sv_gravity"         ,"600" )
        RunConsoleCommand("host_timescale"     ,"1.00")
        RunConsoleCommand("phys_timescale"     ,"1.00")
        RunConsoleCommand("g_ragdoll_maxcount" ,"32"  )
        RunConsoleCommand("phys_pushscale"     ,"1"   )
        RunConsoleCommand("mp_show_voice_icons","1"   )
        SyncValues(ply,"xmh_corpses_var"   ,32)
        SyncValues(ply,"xmh_knockback_var" ,1 )
        SyncValues(ply,"xmh_voiceicons_var",1 )
        for k,v in pairs(player.GetAll()) do
          if v:IsValid() then
            v:SendLua('RunConsoleCommand("physgun_wheelspeed"  ,"10")')
            v:SendLua('RunConsoleCommand("hud_deathnotice_time","6" )')
            v:SendLua('RunConsoleCommand("hud_saytext_time"    ,"12")')
            v:SendLua('RunConsoleCommand("cl_showhints"        ,"1" )')
          end
        end
      end
    end
  end
end)

net.Receive("XMH_SetInt2Command",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      if sync_table[xmh_command][2] != nil then 
        RunConsoleCommand(sync_table[xmh_command][2],tostring(value))
      end
      SyncValues(ply,xmh_command,value)
    end
  end
end)

net.Receive("XMH_SetInt16Command",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(16)
      if sync_table[xmh_command][2] != nil then 
        RunConsoleCommand(sync_table[xmh_command][2],tostring(value))
      end
      SyncValues(ply,xmh_command,value)
    end
  end
end)

net.Receive("XMH_SetFloatCommand",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadFloat()
      if sync_table[xmh_command][2] != nil then 
        RunConsoleCommand(sync_table[xmh_command][2],tostring(value))
      end
      SyncValues(ply,xmh_command,value)
    end
  end
end)

net.Receive("XMH_DefaultsAll",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      for k,v in pairs(player.GetAll()) do
        if v:IsValid() then
          net.Start   ("XMH_DefaultsAll")
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.WriteInt(net.ReadInt(2),2 )
          net.Send    (v                )
        end
      end
    end
  end
end)

net.Receive("XMH_BlockInvisibility",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      SyncValues(ply,xmh_command,value)
      if value == 1 then
        for k,v in pairs(player.GetAll()) do
          if not v:IsAdmin() or not v:IsSuperAdmin() then
            v:SetNoDraw(false)
          end
        end
        PrintMessage( HUD_PRINTTALK, XMH_LANG[LANG]["server_invisibility_console_off"] )
      else 
        PrintMessage( HUD_PRINTTALK, XMH_LANG[LANG]["server_invisibility_console_on"] )
      end
    end
  end
end)

net.Receive("XMH_Invisible",function(_,ply)
  local trash = net.ReadString()
  if ply:IsValid() then
    if (ply:IsAdmin() or ply:IsSuperAdmin()) or sync_table["xmh_make_invisibility_admin_only_var"][1] == 0 then
      if net.ReadInt(2) == 0 then
        ply:SetNoDraw(true)
      else
        ply:SetNoDraw(false)
      end
    elseif sync_table["xmh_make_invisibility_admin_only_var"][1] == 1 then
      ply:SendLua(XMH_LANG[LANG]["server_invisibility_warning_off"])
    end
  end
end)

net.Receive("XMH_InvisibleAll",function(_,ply) --s
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      SyncValues(ply,xmh_command,value)
      if value == 0 then
        sync_table[xmh_command][2] = ply:Nick()
      end
      for k,v in pairs(player.GetAll()) do
        if ply:Nick() != v:Nick() then
          if value == 0 then
            v:SetNoDraw(true)
          else
            v:SetNoDraw(false)
          end
        end
      end
    end
  end
end)

net.Receive("XMH_RepairWindows",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      for k,v in pairs(ents.FindByClass("func_breakable_surf")) do
        if v:Health() <= 0 then
          v:Spawn()
          v:PhysicsInit(SOLID_BSP)
          v:SetMoveType(MOVETYPE_NONE)
          v:SetSolid(SOLID_BSP)
        end
      end

      local RecreateFBTable = 0

      for k,v in pairs(xmh_func_breakable_table) do
        k = k - 2
        if k % 7 == 0 then
          if not v:IsValid() then
            SpawnFBBlock(k+2)
            if RecreateFBTable == 0 then
              RecreateFBTable = 1
            end
          end
        end
      end
      if RecreateFBTable == 1 then
        CreateFuncBreakableTable(1)
      end
    end
  end
end)

net.Receive("XMH_RunOneLineLua",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(16)
      if xmh_command == "xmh_clearcorpses" then
        ClearCorpses()
      elseif xmh_command == "xmh_runspeed_var" then
        ply:SetRunSpeed(value)
      elseif xmh_command == "xmh_walkspeed_var" then
        ply:SetWalkSpeed(value)
      elseif xmh_command == "xmh_jumpheight_var" then
        ply:SetJumpPower(value)
      end
    end
  end
end)

net.Receive("XMH_ClearCorpDec",function(_,ply)
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      SyncValues(ply,xmh_command,value)
      if (value == 1) then
        timer.Create("ClearCorpDec",30,0,function(ply)
          ClearCorpses()
          for k,v in pairs(player.GetAll()) do
            if v:IsValid() then
              v:SendLua('RunConsoleCommand("xmh_cleardecals")')
            end
          end
        end)
      else
        timer.Destroy("ClearCorpDec");
      end
    end
  end
end)

net.Receive("XMH_AiDisable",function(_,ply) -- special case
  if ply:IsValid() then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local xmh_command = net.ReadString()
      local value = net.ReadInt(2)
      RunConsoleCommand(sync_table[xmh_command][2],tostring(value))
      RunConsoleCommand("ai_disable")
      SyncValues(ply,xmh_command,value)
    end
  end
end)

net.Receive("XMH_RemoveWeapons",function(_,ply)
  if ply:IsValid() then
    local xmh_command = net.ReadString()
    local value = net.ReadInt(2)
    SyncValues(ply,xmh_command,value)
    RunConsoleCommand("sbox_weapons", tostring(value))
    for k,v in pairs(player.GetAll()) do
      if v:IsValid() then
        v:Kill()
      end
    end
  end
end)

net.Receive("XMH_TeleportPlayer",function(_,ply)
  if ply:IsValid() then
    ply:SetPos(net.ReadVector())
  end
end)

-- ---------------------------
-- Hooks
-- ---------------------------

hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn_xmh", function (ply)
  SetGroup(ply)
  SyncValuesFirstJoin(ply)
  xmh_first_respawn = 0
  CreateFuncBreakableTable(0)
  timer.Create("ClearCorpDec",2,1,function(ply) -- Delay to wait the client to be ready
    xmh_first_respawn = 1
  end)
end)

hook.Add("PlayerSpawn", "PlayerSpawn_xmh", function(ply) 
  if xmh_first_respawn == 1 then
    if ply:IsValid() then
      net.Start      ("XMH_PlayerRespawn"                    )
      net.WriteInt   (sync_table["xmh_invisibleall_var"][1],2)
      net.WriteString(sync_table["xmh_invisibleall_var"][4]  )
      net.Send       (ply                                    )
    end
  end
end)

hook.Add("GetFallDamage", "GetFallDamage_xmh", function(ply, speed)
  if ply:IsValid() and sync_table["xmh_falldamage_var"][1] == 1 then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      return math.max(0, math.ceil(0.2418*speed - 141.75 ))
    end
  end
end)
