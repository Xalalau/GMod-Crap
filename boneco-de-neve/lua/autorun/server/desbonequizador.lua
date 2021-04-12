function Desbonequizar()
    for _,ent in pairs(ents.FindByClass("boneco-de-neve")) do
        timer.Simple(math.Rand(1, 10), function()
            ent:Exterminate()
        end)
    end
end

concommand.Add("desbonequizar", function()
    Desbonequizar()
end)