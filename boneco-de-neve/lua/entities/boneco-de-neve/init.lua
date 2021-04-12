AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function SetPhysics(ent)
	ent:SetTrigger(true)
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
end

local function CreateGib(ent)
	local gib = ents.Create("prop_physics")

	gib:SetModel(ent.worldOverride or ent:GetModel())	
	gib:SetAngles(ent:GetAngles())
	gib:SetPos(ent:GetPos())
	gib:Spawn()

	timer.Simple(5, function()
		if IsValid(gib) then
			gib:Remove()
		end
	end)

	ent:Remove()
end

function ENT:Initialize()
	self.partes = {}
	self:SetModel(boneco.models.estrada[math.random(1)])
	self:SetPos(self:GetPos()+Vector(0,0,22))
	self:SetAngles(Angle(0,math.random(360),0))
	SetPhysics(self)

	local cabeca = self:CreateMember()
	cabeca.worldOverride = "models/props/cs_office/Snowman_head.mdl"
	cabeca:SetModel("models/props/cs_office/snowman_face.mdl")
	cabeca:SetPos(self:GetPos()+Vector(0,0,25))
	cabeca:SetAngles(self:GetAngles())

	local ang = self:GetAngles().y * 3.14/180

	-- Nao alterar os valores abaixo, a nao ser se quiser trocar de modelos
	local bracoEsquerda = self:CreateMember()
	bracoEsquerda:SetModel("models/props/cs_office/snowman_arm.mdl")
	bracoEsquerda:SetPos(self:GetPos()+Vector(13.5 * math.cos(ang),13.5 * math.sin(ang),18.4))
	bracoEsquerda:SetAngles(cabeca:GetAngles())

	local bracoDireita = self:CreateMember()
	bracoDireita:SetModel("models/props/cs_office/snowman_arm.mdl")
	bracoDireita:SetPos(self:GetPos()+Vector(15.5 * math.cos(ang)*-1,15.5 * math.sin(ang)*-1,18))
	bracoDireita:SetAngles(bracoEsquerda:GetAngles() + Angle(0, 180, 0))

	local efeitoDeSpawn = EffectData()
	efeitoDeSpawn:SetOrigin(self:GetPos())
	util.Effect("ManhackSparks", efeitoDeSpawn)
end

function ENT:Touch(ent)
	if not ent:IsPlayer() and ent:GetPos():Distance(self:GetPos()) < 70 then
		self:Exterminate()
	end
end

function ENT:CreateGibs()
	if self.partes and not self.morteIniciada then
		for _,ent in pairs(self.partes) do
			if IsValid(ent) and ent:IsValid() then
				CreateGib(ent)
			end
		end
	end
end

function ENT:OnRemove()
	self:CreateGibs(ent)

	local efeitoDeMorte = EffectData()
	efeitoDeMorte:SetOrigin(self:GetPos() - Vector(0,0,20))
	util.Effect("WaterSurfaceExplosion", efeitoDeMorte)
end

function ENT:CreateMember()
	local member = ents.Create("boneco-de-neve-membros")
	local index = table.insert(self.partes, member)
	local body = self
	member:SetParent(self)
	SetPhysics(member)
	member.OnTakeDamage = function(self, damage)
		table.remove(body.partes, index)
		CreateGib(member)
	end
	member:Spawn()

	return member
end

function ENT:Exterminate()
	self:CreateGibs(ent)
	self.morteIniciada = true
	self:Remove()
end