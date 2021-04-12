include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	local corNome = Color(66, 147, 245)
	local nome = "["..boneco.nomes[math.random(#boneco.nomes)].."] "
	local corMensagem = Color(166, 147, 255)
	local mensagem = boneco.Frases[math.random(#boneco.Frases)]

	chat.AddText(corNome, nome, corMensagem, mensagem)
end