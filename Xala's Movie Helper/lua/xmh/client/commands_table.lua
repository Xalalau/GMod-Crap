--[[
##############################
##### SHORT DESCRIPTION ######
##############################

This table must store ALL the xmh's command data!

Here we can control which commands are cheat, admin only, what are their
functions, categories, standards, etc. This is an effort to keep the
maintenance easy and the updates uncomplicated.


##############################
#### FORMATTING STANDARTS ####
##############################

The commands are organized by types, each with its own personality.

These are the general terms:
    COMMAND = (real) game command
    XMH_COMMAND_VAR = The custom command that we created
    XMH_CATEGORY = If we want to enable syncing or cleanup it has to be one of "mark_clear" table keys, othewise we can invent a name

And these are the formats:
________________________________________________________________________
RunConsoleCommand commands (client / executed directly in the menu)
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
    [COMMAND] = {
      command_type    = "runconsolecommand",
      category        = XMH_CATEGORY,
      default         = Number,
      cheat           = Boolean,
      admin           = Boolean
    },

________________________________________________________________________
Function commands (client)
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
    [XMH_COMMAND_VAR] = {
      command_type    = "function",
      sub_type        = "fix" or "defaults" or remove it,
      category        = XMH_CATEGORY,
      default         = GetConVar("XMH_COMMAND_VAR"):GetInt() or remove this field,
      value           = GetConVar("XMH_COMMAND_VAR"):GetInt(),
      value2          = XMH_CATEGORY,
      cheat           = Boolean,
      func            = Fucntion or remove it,
      admin           = Boolean
    },

sub_type:
    -- "fix" is for commands that have bugs on showing its initial value or its changes
    -- "defaults" is for setting a function for the "Defaults" section. To use it remove the "default" and "func" fields.
    -- If we don't set a sub type we can remove this field
value2:
    -- If the sub_type is "defaults" we'll need to pass a XMH_CATEGORY argument in this field, otherwise we can remove it

________________________________________________________________________
Net commands (client --> server)
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  ["XMH_COMMAND_VAR"] = {
    command_type    = "net",
    category        = XMH_CATEGORY,
    default         = GetConVar("XMH_COMMAND_VAR"):GetInt() or GetConVar("XMH_COMMAND_VAR"):GetFloat(),
    value           = GetConVar("XMH_COMMAND_VAR"):GetInt() or GetConVar("XMH_COMMAND_VAR"):GetFloat(),
    cheat           = Boolean,
    var_type        = "int2" or "int16" or "float",
    func            = String,
    admin           = Boolean,
  },

default and value:
    -- "GetInt()" or "GetFloat()" will depend on what var_type we'll choose
var_type:
    -- 2 bits = 0 or 1
    -- 16 bits = 65536 max value
    -- float = 32 bits with decimal places

________________________________________________________________________
Hook commands (client)
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  ["XMH_COMMAND_VAR"] = {
    command_type    = "hook"
    category        = XMH_CATEGORY,
    default         = GetConVar("XMH_COMMAND_VAR"):GetInt(),
    value           = GetConVar("XMH_COMMAND_VAR"):GetInt(),
    value2          = String,
    cheat           = Boolean
    func            = Fuction,
    admin           = Boolean
  },

value2:
    -- This field has to be the hook name
]]--

xmh_commands = {
  -- ##################### CLEANUP
  ["xmh_cleanup_var"] = {
    command_type    = "net",
    category        = "Cleanup",
    default         = GetConVar("xmh_cleanup_var"):GetInt(),
    value           = GetConVar("xmh_cleanup_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_ClearCorpDec",
    admin           = true,
  },
  -- ##################### DISPLAY
  ["xmh_viewmodel_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_viewmodel_var"):GetInt(),
    value           = GetConVar("xmh_viewmodel_var"):GetInt(),
    cheat           = true,
    func            = XMH_ViewWorldModels,
    admin           = false
  },
  ["r_drawviewmodel"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_drawviewmodel"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["xmh_invisible_var"] = {
    command_type    = "net",
    category        = "Display",
    default         = GetConVar("xmh_invisible_var"):GetInt(),
    value           = GetConVar("xmh_invisible_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_Invisible",
    admin           = false
  },
  ["xmh_invisibleall_var"] = {
    command_type    = "net",
    category        = "Display",
    default         = GetConVar("xmh_invisibleall_var"):GetInt(),
    value           = GetConVar("xmh_invisibleall_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_InvisibleAll",
    admin           = true
  },
  ["xmh_toolgun_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_toolgun_var"):GetInt(),
    value           = GetConVar("xmh_toolgun_var"):GetInt(),
    cheat           = false,
    func            = XMH_ToolGunEffect,
    admin           = false
  },
  ["xmh_toolgunmute_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_toolgunmute_var"):GetInt(),
    value           = GetConVar("xmh_toolgunmute_var"):GetInt(),
    cheat           = false,
    func            = XMH_ToolGunMute,
    admin           = true
  },
  ["xmh_physgun_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_physgun_var"):GetInt(),
    value           = GetConVar("xmh_physgun_var"):GetInt(),
    cheat           = false,
    func            = XMH_PhysgunEffects,
    admin           = false
  },
  ["xmh_error_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_error_var"):GetInt(),
    value           = GetConVar("xmh_error_var"):GetInt(),
    cheat           = false,
    func            = XMH_Error,
    admin           = false
  },
  ["xmh_weapammitem_var"] = {
    command_type    = "hook",
    category        = "Display",
    default         = GetConVar("xmh_weapammitem_var"):GetInt(),
    value           = GetConVar("xmh_weapammitem_var"):GetInt(),
    value2          = "HUDDrawPickupHistory",
    cheat           = false,
    func            = XMH_SetInvisibilityHook,
    admin           = false
  },
  ["xmh_chatvoice_var"] = {
    command_type    = "hook",
    category        = "Display",
    default         = GetConVar("xmh_chatvoice_var"):GetInt(),
    value           = GetConVar("xmh_chatvoice_var"):GetInt(),
    value2          = "PlayerStartVoice",
    cheat           = false,
    func            = XMH_SetInvisibilityHook,
    admin           = false
  },
  ["xmh_voiceicons_var"] = {
    command_type    = "net",
    category        = "Display",
    default         = GetConVar("xmh_voiceicons_var"):GetInt(),
    value           = GetConVar("xmh_voiceicons_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  ["xmh_footsteps_var"] = {
    command_type    = "net",
    category        = "Display",
    default         = GetConVar("xmh_footsteps_var"):GetInt(),
    value           = GetConVar("xmh_footsteps_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  ["r_drawmodeldecals"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_drawmodeldecals"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["r_drawparticles"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_drawparticles"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_3dsky"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_3dsky"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["cl_show_splashes"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("cl_show_splashes"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["r_drawropes"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_drawropes"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_DrawBeams"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_DrawBeams"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_drawentities"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("r_drawentities"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["xmh_corpses_var"] = {
    command_type    = "net",
    category        = "Display",
    default         = GetConVar("xmh_corpses_var"):GetInt(),
    value           = GetConVar("xmh_corpses_var"):GetInt(),
    cheat           = false,
    var_type        = "int16",
    func            = "XMH_SetInt16Command",
    admin           = true
  },
  ["hud_deathnotice_time"] = {
    category        = "Display",
    default         = GetConVar("hud_deathnotice_time"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["hud_saytext_time"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("hud_saytext_time"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["xmh_decals_var"] = {
    command_type    = "function",
    category        = "Display",
    default         = GetConVar("xmh_decals_var"):GetInt(),
    value           = GetConVar("xmh_decals_var"):GetInt(),
    cheat           = false,
    func            = XMH_DecalsQuantity,
    admin           = false
  },
  ["cl_detaildist"] = {
    command_type    = "runconsolecommand",
    category        = "Display",
    default         = GetConVar("cl_detaildist"):GetInt(),
    cheat           = false,
    admin           = false
  },
  -- ##################### FLASHLIGHT
  ["r_flashlightlockposition"] = {
    command_type    = "runconsolecommand",
    category        = "Flashlight",
    default         = GetConVar("r_flashlightlockposition"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["xmh_fullflashlight_var"] = {
    command_type    = "function",
    sub_type        = "fix",
    category        = "Flashlight",
    real_command    = "r_flashlightconstant",
    default         = GetConVar("xmh_fullflashlight_var"):GetInt(),
    value           = GetConVar("xmh_fullflashlight_var"):GetInt(),
    cheat           = true,
    func            = XMH_RunCommand,
    admin           = false
  },
  ["r_flashlightdrawfrustum"] = {
    command_type    = "runconsolecommand",
    category        = "Flashlight",
    default         = GetConVar("r_flashlightdrawfrustum"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["r_flashlightnear"] = {
    command_type    = "runconsolecommand",
    category        = "Flashlight",
    default         = GetConVar("r_flashlightnear"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_flashlightfar"] = {
    command_type    = "runconsolecommand",
    category        = "Flashlight",
    default         = GetConVar("r_flashlightfar"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_flashlightfov"] = {
    command_type    = "runconsolecommand",
    category        = "Flashlight",
    default         = GetConVar("r_flashlightfov"):GetInt(),
    cheat           = true,
    admin           = false
  },
  -- ##################### GENERAL
  ["xmh_textfont_var"] = {
    command_type    = "runconsolecommand",
    category        = "General",
    default         = GetConVar("xmh_textfont_var"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["xmh_shake_var"] = {
    command_type    = "function",
    category        = "General",
    default         = GetConVar("xmh_shake_var"):GetInt(),
    value           = GetConVar("xmh_shake_var"):GetInt(),
    cheat           = true,
    func            = XMH_Shake,
    admin           = false
  },
  ["xmh_skybox_var"] = {
    command_type    = "function",
    category        = "General",
    default         = GetConVar("xmh_skybox_var"):GetInt(),
    value           = GetConVar("xmh_skybox_var"):GetInt(),
    cheat           = false,
    func            = XMH_GreenSkybox,
    admin           = false
  },
  ["xmh_save_var"] = {
    command_type    = "function",
    category        = "General",
    default         = GetConVar("xmh_save_var"):GetInt(),
    value           = GetConVar("xmh_save_var"):GetInt(),
    cheat           = false,
    func            = XMH_AutoSave,
    admin           = true
  },
  ["r_lod"] = {
    command_type    = "runconsolecommand",
    category        = "General",
    default         = GetConVar("r_lod"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["r_eyesize"] = {
    command_type    = "runconsolecommand",
    category        = "General",
    default         = GetConVar("r_eyesize"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["xmh_fov_var"] = {
    command_type    = "function",
    sub_type        = "fix",
    category        = "General",
    real_command    = "fov",
    default         = GetConVar("xmh_fov_var"):GetInt(),
    value           = GetConVar("xmh_fov_var"):GetInt(),
    cheat           = true,
    func            = XMH_RunCommand,
    admin           = false
  },
  ["viewmodel_fov"] = {
    command_type    = "runconsolecommand",
    category        = "General",
    default         = GetConVar("viewmodel_fov"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["xmh_camera_fov"] = {
    command_type    = "runconsolecommand",
    category        = "General",
    default         = GetConVar("xmh_camera_fov"):GetInt(),
    cheat           = true,
    admin           = false
  },
  -- ##################### NPC MOVEMENT
  ["xmh_npcwalkrun_var"] = {
    command_type    = "net",
    category        = "NPCMovement",
    default         = GetConVar("xmh_npcwalkrun_var"):GetInt(),
    value           = GetConVar("xmh_npcwalkrun_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  ["xmh_aidisabled_var"] = {
    command_type    = "net",
    category        = "NPCMovement",
    default         = GetConVar("xmh_aidisabled_var"):GetInt(),
    value           = GetConVar("xmh_aidisabled_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  ["xmh_aidisable_var"] = {
    command_type    = "net",
    category        = "NPCMovement",
    default         = GetConVar("xmh_aidisable_var"):GetInt(),
    value           = GetConVar("xmh_aidisable_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_AiDisable",
    admin           = true
  },
  -- ##################### PHYSICS
  ["xmh_mode_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_mode_var"):GetInt(),
    value           = GetConVar("xmh_mode_var"):GetInt(),
    cheat           = true,
    var_type        = "int2",
    func            = "XMH_Mode",
    admin           = true
  },
  ["xmh_falldamage_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_falldamage_var"):GetInt(),
    value           = GetConVar("xmh_falldamage_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  ["xmh_timescale_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_timescale_var"):GetInt(),
    value           = GetConVar("xmh_timescale_var"):GetInt(),
    cheat           = true,
    var_type        = "float",
    func            = "XMH_SetFloatCommand",
    admin           = true
  },
  ["xmh_knockback_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_knockback_var"):GetInt(),
    value           = GetConVar("xmh_knockback_var"):GetInt(),
    cheat           = true,
    var_type        = "int16",
    func            = "XMH_SetInt16Command",
    admin           = true
  },
  ["physgun_wheelspeed"] = {
    command_type    = "runconsolecommand",
    category        = "Physics",
    default         = GetConVar("physgun_wheelspeed"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["xmh_throwforce_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_throwforce_var"):GetInt(),
    value           = GetConVar("xmh_throwforce_var"):GetInt(),
    cheat           = true,
    var_type        = "int16",
    func            = "XMH_SetInt16Command",
    admin           = true
  },
  ["xmh_noclipspeed_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_noclipspeed_var"):GetInt(),
    value           = GetConVar("xmh_noclipspeed_var"):GetInt(),
    cheat           = true,
    var_type        = "int16",
    func            = "XMH_SetInt16Command",
    admin           = true
  },
  ["xmh_walkspeed_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_walkspeed_var"):GetInt(),
    value           = GetConVar("xmh_walkspeed_var"):GetInt(),
    cheat           = false,
    var_type        = "int16",
    func            = "XMH_RunOneLineLua",
    admin           = false
  },
  ["xmh_runspeed_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_runspeed_var"):GetInt(),
    value           = GetConVar("xmh_runspeed_var"):GetInt(),
    cheat           = false,
    var_type        = "int16",
    func            = "XMH_RunOneLineLua",
    admin           = false
  },
  ["xmh_jumpheight_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_jumpheight_var"):GetInt(),
    value           = GetConVar("xmh_jumpheight_var"):GetInt(),
    cheat           = false,
    var_type        = "int16",
    func            = "XMH_RunOneLineLua",
    admin           = false
  },
  ["xmh_wfriction_var"] = {
    command_type    = "net",
    category        = "Physics",
    default         = GetConVar("xmh_wfriction_var"):GetInt(),
    value           = GetConVar("xmh_wfriction_var"):GetInt(),
    cheat           = false,
    var_type        = "int16",
    func            = "XMH_SetInt16Command",
    admin           = true
  },
  -- ##################### SHADOWS
  ["mat_slopescaledepthbias_shadowmap"] = {
    command_type    = "runconsolecommand",
    category        = "Shadows",
    default         = GetConVar("mat_slopescaledepthbias_shadowmap"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["r_projectedtexture_filter"] = {
    command_type    = "runconsolecommand",
    category        = "Shadows",
    default         = GetConVar("r_projectedtexture_filter"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["mat_fullbright"] = {
    command_type    = "runconsolecommand",
    category        = "Shadows",
    default         = GetConVar("mat_fullbright"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["r_shadowrendertotexture"] = {
    command_type    = "runconsolecommand",
    category        = "Shadows",
    default         = GetConVar("r_shadowrendertotexture"):GetInt(),
    cheat           = false,
    admin           = false
  },
  -- ##################### THIRD PERSON
  ["xmh_person_var"] = {
    command_type    = "function",
    category        = "ThirdPerson",
    default         = GetConVar("xmh_person_var"):GetInt(),
    value           = GetConVar("xmh_person_var"):GetInt(),
    cheat           = true,
    func            = XMH_Person,
    admin           = false
  },
  ["cam_showangles"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_showangles"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_collision"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_collision"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_idealdist"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_idealdist"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_idealdistup"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_idealdistup"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_idealdistright"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_idealdistright"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_idealpitch"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_idealpitch"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_idealyaw"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_idealyaw"):GetInt(),
    cheat           = true,
    admin           = false
  },
  ["cam_ideallag"] = {
    command_type    = "runconsolecommand",
    category        = "ThirdPerson",
    default         = GetConVar("cam_ideallag"):GetInt(),
    cheat           = true,
    admin           = false
  },
  -- ##################### WEAPONS
  ["xmh_editallweapons_var"] = {
    command_type    = "runconsolecommand",
    category        = "Weapons",
    default         = GetConVar("xmh_editallweapons_var"):GetInt(),
    cheat           = false,
    admin           = false
  },
  ["xmh_editweaponsallplys_var"] = {
    command_type    = "net",
    category        = "Weapons",
    default         = GetConVar("xmh_editweaponsallplys_var"):GetInt(),
    value           = GetConVar("xmh_editweaponsallplys_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_SetInt2Command",
    admin           = true
  },
  -- ##################### DEFAULTS
  ["xmh_clcleanup_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clcleanup_var"):GetInt(),
    value2          = "Cleanup",
    cheat           = false,
    admin           = false
  },
  ["xmh_cldisplay_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_cldisplay_var"):GetInt(),
    value2          = "Display",
    cheat           = false,
    admin           = false
  },
  ["xmh_clfl_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clfl_var"):GetInt(),
    value2          = "Flashlight",
    cheat           = false,
    admin           = false
  },
  ["xmh_clgeneral_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clgeneral_var"):GetInt(),
    value2          = "General",
    cheat           = false,
    admin           = false
  },
  ["xmh_clnpcmove_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clnpcmove_var"):GetInt(),
    value2          = "NPCMovement",
    cheat           = false,
    admin           = false
  },
  ["xmh_clphysics_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clphysics_var"):GetInt(),
    value2          = "Physics",
    cheat           = false,
    admin           = false
  },
  ["xmh_clshadows_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clshadows_var"):GetInt(),
    value2          = "Shadows",
    cheat           = false,
    admin           = false
  },
  ["xmh_cltp_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_cltp_var"):GetInt(),
    value2          = "ThirdPerson",
    cheat           = false,
    admin           = false
  },
  ["xmh_clweapons_var"] = {
    command_type    = "function",
    category        = "Defaults",
    value           = GetConVar("xmh_clweapons_var"):GetInt(),
    value2          = "Weapons",
    cheat           = false,
    admin           = false
  },
  -- ##################### CVAR ONLY
  ["xmh_make_invisibility_admin_only_var"] = {
    command_type    = "net",
    category        = "Cvar",
    default         = GetConVar("xmh_make_invisibility_admin_only_var"):GetInt(),
    value           = GetConVar("xmh_make_invisibility_admin_only_var"):GetInt(),
    cheat           = false,
    var_type        = "int2",
    func            = "XMH_BlockInvisibility",
    admin           = true
  },
}
