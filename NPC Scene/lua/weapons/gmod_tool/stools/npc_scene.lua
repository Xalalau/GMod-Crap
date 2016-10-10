--[[ 
Credits: tool originally created by Deco and continued by Xalalau

Version 1.2, by Deco     : http://www.garrysmod.org/downloads/?a=view&id=42593 
Version 1.3.1, by Xalalau: http://steamcommunity.com/sharedfiles/filedetails/?id=121182342

https://github.com/xalalau/GMod/tree/master/NPC%20Scene
]]--

TOOL.Category	= "Poser"
TOOL.Name		= "#Tool.npc_scene.name"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["name" ] = "scenes/npc/Gman/gman_intro"
TOOL.ClientConVar["actor"] = "Alyx"

if (CLIENT) then
	CreateClientConVar( "npc_scene_loop", 0, true, false ) 

	language.Add( "Tool.npc_scene.name", "NPC Scene" )
	language.Add( "Tool.npc_scene.desc", "Make NPCs act!" )
	language.Add( "Tool.npc_scene.0", "Left click to play entered scene, right to set the actor name." )

	local function ParseDir(t, dir, ext)
		local files, dirs = file.Find(dir.."*", "GAME")
		for _, fdir in pairs(dirs) do
			local n = t:AddNode(fdir)
			ParseDir(n, dir..fdir.."/", ext) 
			n:SetExpanded(false) 
		end
		for k,v in pairs(files) do
			local n = t:AddNode(v)
			local arq = dir..v
			n.DoClick = function() RunConsoleCommand("npc_scene_name", arq ) end 
		end
	end

	local SceneListPanel = vgui.Create("DFrame")
	SceneListPanel:SetTitle			("Scenes"	)
	SceneListPanel:SetSize			(300,	700	)
	SceneListPanel:SetPos			(10,	10	)
	SceneListPanel:SetDeleteOnClose	(false		)
	SceneListPanel:SetVisible		(false		) 

	local ctrl = vgui.Create("DTree", SceneListPanel)
	ctrl:SetPadding					(5			)
	ctrl:SetSize					(300,	675	)
	ctrl:SetPos						(0,		25	)
	
	local node = ctrl:AddNode("Scenes! (click one to select)")
	ParseDir(node, "scenes/", ".vcd")
	
	local function ListScenes()
		SceneListPanel:SetVisible(true)
		SceneListPanel:MakePopup()
	end
	
	concommand.Add("npc_scene_list", ListScenes)
		
	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl("Header" , { Text  = '#Tool.npc_scene.name', Description = '#Tool.npc_scene.desc' })
		CPanel:AddControl("TextBox", { Label = "Scene Name" , Command = "npc_scene_name", MaxLength = 500 })
		CPanel:AddControl("Button" , { Text  = "List Scenes", Command = "npc_scene_list" })
		CPanel:AddControl("TextBox", { Label = "Actor Name" , Command = "npc_scene_actor", MaxLength = 500 })
		CPanel:AddControl("Slider" , { Label = "Loop (SP Only)", Type = "int", Min = "0", Max = "100", Command = "npc_scene_loop"})
	end
end
 
function TOOL:LeftClick(tr)
	if tr.Hit and tr.Entity and tr.Entity:IsValid() and tr.Entity:IsNPC() then
		local loop  = GetConVar("npc_scene_loop"):GetInt()
		local scene = self:GetClientInfo("name")
		if (loop == 0) then
			tr.Entity:PlayScene(string.gsub(scene, ".vcd", ""))
		elseif (loop > 0) then
			if i == nil then i = 0 end
			i = i + 1
			local id = tostring(i)
			local lenght = tr.Entity:PlayScene(string.gsub(scene, ".vcd", ""))
			timer.Create(id, lenght, loop, function() 
				if tr.Entity:IsValid() then
					tr.Entity:PlayScene(string.gsub(scene, ".vcd", ""))
				else
					timer.Stop(id)
				end
			end)
		end
	end
	return true
end

function TOOL:RightClick(tr)
	if tr.Hit and tr.Entity and tr.Entity:IsValid() and tr.Entity:IsNPC() then
		tr.Entity:SetName(self:GetClientInfo("actor"))
	end
	return true
end
