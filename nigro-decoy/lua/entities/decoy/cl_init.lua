include("shared.lua")

-- Renderizar o modelo

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end
