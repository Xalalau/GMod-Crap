-- Mandar arquivos para client e shared os clientes
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Incluir shared
include("shared.lua")

-- Modelo spawnado pelo menu Q
function ENT:SpawnFunction(ply, tr)
	-- Criar entidade
	local ent = ents.Create(self.ClassName)

	-- Salvar o player como o criador da entidade
	ent:SetCreator(ply)

	-- Colocar o ângulo dela para a mesma direção do jogador
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	ent:SetAngles(angle)

	-- Posicionar a entidade na esquerda ou direita do jogador aleatoriamente
	math.randomseed(CurTime())
	local rand = math.random(0, 1) > 0 and 1 or 3
	local newAng = angle.y + 90 * rand -- Copiar o ângulo do eixo y (yaw) (direção do olhar) do jogador e desviá-lo para a esquerda ou direita aleatoriamente
	local newAngRad = (newAng) * 3.14/180 -- Passar o novo ângulo para radianos
	local movePos = Vector(math.cos(newAngRad) * 60, math.sin(newAngRad) * 60, 0) -- Criar um vetor de deslocamento
	ent:SetPos(ply:GetPos() + movePos) -- Colocar a entidade na posição do jogador e desviá-la usando o vetor movePos

	-- Spawn
	ent:Spawn()
	ent:Activate()

	return ent
end

-- Função chamada por ent:Spawn()
function ENT:Initialize()
	self.fadeInTime = 2 -- Tempo de fade in
	self.fadeOutTime = 1 -- Tempo de fade out
	self.maxAlpha = 130 -- Máxima translucidez

	-- Usar modelo do jogador
	self:SetModel(self:GetCreator():GetModel())

	-- Não atingir obstáculos
	self:SetSolid(SOLID_NONE)

	-- Trasnlúcido em 150
	self:SetColor(Color(255, 255, 255, 150))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)

	-- Iniciar fading in
	self.fadingIn = CurTime() + self.fadeInTime
end

-- Animações
function ENT:RunBehaviour()
	local tr = self:GetCreator():GetEyeTrace()

	-- Nadar até o local observado
	self:StartActivity(ACT_HL2MP_SWIM)
	self.loco:SetDesiredSpeed(self.maxAlpha)
	self:MoveToPos(tr.HitPos + tr.HitNormal * 1)

	-- Dança do robô por 10 segundos
	self:StartActivity(ACT_GMOD_TAUNT_ROBOT)
	coroutine.wait(10)

	-- Ficar parado por self.fadeOutTime segundos
	self:StartActivity(ACT_HL2MP_IDLE)
	coroutine.wait(self.fadeOutTime)

	-- Iniciar fading out
	self.fadingOut = CurTime() + self.fadeOutTime
end

-- Efeitos de fade
function ENT:Think()
	-- Aparecer lentamente
	if self.fadingIn then
		local alpha = self.maxAlpha - (self.fadingIn - CurTime())/self.fadeInTime * self.maxAlpha

		self:SetColor(Color(255, 255, 255, alpha))

		if CurTime() - self.fadingIn >= 0 then
			self.fadingIn = nil
		end
	end

	-- Desaparecer lentamente
	if self.fadingOut then
		local alpha = (self.fadingOut - CurTime())/self.fadeOutTime * self.maxAlpha

		self:SetColor(Color(255, 255, 255, alpha))

		if CurTime() - self.fadingOut >= 0 then
			self:Remove()
		end
	end
end