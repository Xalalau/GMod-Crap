hook.Add("AtmosStartStorm", "Default", function()
    if MR then
        MR.SV.Load:Start(MR.SV.Ply:GetFakeHostPly(), "storm")
    end

end)

hook.Add("AtmosStopStorm", "Default", function()
    if MR then
        MR.SV.Materials:RemoveAll(MR.SV.Ply:GetFakeHostPly())
    end
end)

hook.Add("AtmosStartSnow", "Default", function()
    if MR then
        MR.SV.Load:Start(MR.SV.Ply:GetFakeHostPly(), "snow")
	end
    if boneco then
        Bonequizar()
    end
end)

hook.Add("AtmosStopSnow", "Default", function()
    if MR then
        MR.SV.Materials:RemoveAll(MR.SV.Ply:GetFakeHostPly())
    end
    if boneco then
        Desbonequizar()
    end
end)
