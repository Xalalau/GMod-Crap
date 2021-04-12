
-- ULX Trazer jogador (Analisa um grid e teleporta no local livre)
-- https://github.com/TeamUlysses/ulx/blob/master/lua/ulx/modules/sh/teleport.lua

--[[
local function spiralGrid(rings)
	local grid = {}
	local col, row

	for ring=1, rings do -- For each ring...
		row = ring
		for col=1-ring, ring do -- Walk right across top row
			table.insert( grid, {col, row} )
		end

		col = ring
		for row=ring-1, -ring, -1 do -- Walk down right-most column
			table.insert( grid, {col, row} )
		end

		row = -ring
		for col=ring-1, -ring, -1 do -- Walk left across bottom row
			table.insert( grid, {col, row} )
		end

		col = -ring
		for row=1-ring, ring do -- Walk up left-most column
			table.insert( grid, {col, row} )
		end
	end

	return grid
end
local tpGrid = spiralGrid( 24 )

-- Based on code donated by Timmy (https://github.com/Toxsa)
function ulx.bring( calling_ply, target_plys )
	local cell_size = 50 -- Constance spacing value

  if not calling_ply:IsValid() then
    Msg( "If you brought someone to you, they would instantly be destroyed by the awesomeness that is console.\n" )
    return
  end

  if ulx.getExclusive( calling_ply, calling_ply ) then
    ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
    return
  end

  if not calling_ply:Alive() then
    ULib.tsayError( calling_ply, "You are dead!", true )
    return
  end

  if calling_ply:InVehicle() then
    ULib.tsayError( calling_ply, "Please leave the vehicle first!", true )
    return
  end

	local t = {
		start = calling_ply:GetPos(),
		filter = { calling_ply },
		endpos = calling_ply:GetPos(),
	}
	local tr = util.TraceEntity( t, calling_ply )

  if tr.Hit then
    ULib.tsayError( calling_ply, "Can't teleport when you're inside the world!", true )
    return
  end

  local teleportable_plys = {}

  for i=1, #target_plys do
    local v = target_plys[ i ]
    if ulx.getExclusive( v, calling_ply ) then
      ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
    elseif not v:Alive() then
      ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
    else
      table.insert( teleportable_plys, v )
    end
  end
	local players_involved = table.Copy( teleportable_plys )
	table.insert( players_involved, calling_ply )

  local affected_plys = {}

  for i=1, #tpGrid do
		local c = tpGrid[i][1]
		local r = tpGrid[i][2]
    local target = table.remove( teleportable_plys )
		if not target then break end

		local yawForward = calling_ply:EyeAngles().yaw
		local offset = Vector( r * cell_size, c * cell_size, 0 )
		offset:Rotate( Angle( 0, yawForward, 0 ) )

		local t = {}
		t.start = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
		t.filter = players_involved
		t.endpos = t.start + offset
		local tr = util.TraceEntity( t, target )

    if tr.Hit then
      table.insert( teleportable_plys, target )
    else
      if target:InVehicle() then target:ExitVehicle() end
			target.ulx_prevpos = target:GetPos()
			target.ulx_prevang = target:EyeAngles()
      target:SetPos( t.endpos )
      target:SetEyeAngles( (calling_ply:GetPos() - t.endpos):Angle() )
      target:SetLocalVelocity( Vector( 0, 0, 0 ) )
      table.insert( affected_plys, target )
    end
  end

  if #teleportable_plys > 0 then
    ULib.tsayError( calling_ply, "Not enough free space to bring everyone!", true )
  end

	if #affected_plys > 0 then
  	ulx.fancyLogAdmin( calling_ply, "#A brought #T", affected_plys )
	end
end
local bring = ulx.command( CATEGORY_NAME, "ulx bring", ulx.bring, "!bring" )
bring:addParam{ type=ULib.cmds.PlayersArg, target="!^" }
bring:defaultAccess( ULib.ACCESS_ADMIN )
bring:help( "Brings target(s) to you." )
--]]






-- LIB-LAU
local function GetEntitykeyValue(entityKeyTable, keysToFind)
    local read = ""
    local found = {}
    local capturing = false

    local totalKeys = #keysToFind
    local keysFound = 0

    local keyMatch = false

    for k,v in ipairs(string.ToTable(entityKeyTable)) do
        if v == "\"" then
            capturing = not capturing
        elseif capturing then
            read = read .. v
        end

        if read ~= "" and not capturing then
            if not keyMatch then
                for _,key in pairs(keysToFind) do
                    if read == key then
                        keysFound = keysFound + 1
                        keyMatch = key
                        break
                    end
                end
            elseif keyMatch then
                found[keyMatch] = read
                keyMatch = false
            elseif keysFound == totalKeys then
                break
            end

            read = ""
        end
    end

    return found
end



-- -------------------------------------

-- O mundo com bonecos:

local boneco_pasta = "boneco/"
local boneco_arquivo = "entidades_" .. game.GetMap() .. ".txt"

-- Inicialização
hook.Add("OnGamemodeLoaded", "Inicializar", function()    
    if not file.Exists(boneco_pasta, "Data") then
        file.CreateDir(boneco_pasta)
    end

    if not file.Exists(boneco_pasta .. boneco_arquivo, "Data") then
        PrintMessage(HUD_PRINTTALK, "Boneco de neve incializado, arquivo salvo.")

        local entidadesBSP = {}

        if table.Count(entidadesBSP) == 0 then
            for _,entityKeyTable in pairs(MR.OpenBSP():ReadEntities()) do
                table.insert(entidadesBSP, GetEntitykeyValue(entityKeyTable, { "classname", "origin" }))
            end
        end

        file.Write(boneco_pasta .. boneco_arquivo, util.TableToJSON(entidadesBSP, true))
    end
end)

-- Procurar por entidades visíveis em Lua
local function PegarPontosEntidades(lista)
    local classes = { }

    for _,class in pairs(classes) do
        local encontrado = ents.FindByClass(class)

        if #encontrado > 0 then
            for _,ent in pairs(ents.FindByClass(class)) do
                table.insert(lista, ent)
            end
        end
    end
end

-- Procurar por entidades visíveis no BSP
-- Nota: não se alteram
-- Nota2: prop_static não vira uma entidade, portanto não aparece aqui
local function PegarPontosEntidadesBSP(lista, entidadesBSP)
    local classes = {
        "player",
        "prop_dynamic",
        "prop_dynamic_override",
        "info_player_start",
        "prop_physics",
        "func_door",
        "prop_door_rotating",
        "func_areaportal",
    }

    for _,entidade in pairs(entidadesBSP) do
        for _,classe in pairs(classes) do
            if entidade["classname"] == classe then
                table.insert(lista, entidade)
            end
        end
    end
end

-- Escolho um número aleatório de pontos na nossa lista - entre 5 e um máximo
local function FiltrarPontosAleatorios(lista)
    if #lista == 0 then return end

    local maximo = 40

    local quantidadeDeBonecos = math.random(5, #lista >= maximo and maximo or #lista)
    local selecionados = {}
    local selecionadosAux = {}

    for i=1, #lista, 1 do
        local aleatorio = math.random(#lista)

        if not selecionados[aleatorio] then
            selecionados[aleatorio] = lista[aleatorio]
        else
            i = i - 1
        end

        if i > quantidadeDeBonecos then
            break
        end
    end

    local i = 1
    for k,v in pairs(selecionados)do
        selecionadosAux[i] = v
        i = i + 1
    end

    table.Empty(lista)
    for k,v in pairs(selecionadosAux)do
        table.insert(lista, v)
    end
end

-- Valido a posição dos pontos selecionados, removo os ruins
local function ValidarPosicoes(lista)
    if #lista == 0 then return end

    local entidadeTestadora = ents.Create("boneco-de-neve-membros")

    for k,v in pairs(lista) do
        if not IsValid(v) and not v["classname"] then
            table.remove(lista, k)
        else
            local livre = 0
            local validado = false
            local posSave

            -- Vou fazer uma varredura 360º para achar um local livre
            for i=1, 359, 1 do
                local origin = IsValid(v) and v:GetPos() or Vector(v["origin"])
                local classname = not IsValid(v) and v["classname"] or v

                local ang = i * 3.14/180
                local raio = math.Rand(50, 350)
                local pos = origin + Vector(raio * math.cos(ang), raio * math.sin(ang), 0)

                local caixaPonto1 = pos + Vector(-30, -30, 30)
                local caixaPonto2 = pos + Vector(30, 30, -30)

                -- Checo se está esbarrando em uma entidade sólida
                local esbarrando = false
                for _,proximo in pairs(ents.FindInBox(caixaPonto1, caixaPonto2)) do
                    if proximo:IsSolid() then
                        esbarrando = true

                        break
                    end
                end

                entidadeTestadora:SetPos(pos)

                -- Checo se está no mundo
                if entidadeTestadora:IsInWorld() and not esbarrando then
                    -- Marco graus livres. Quando juntar 45, coloco o boneco em 23
                    livre = livre + 1

                    if livre == 23 then
                        posSave = pos
                    end

                    if livre == 45 then
                        lista[k] = { classname = classname, origin = posSave }
                        validado = true

                        break
                    end
                else
                    livre = livre - 1
                end
            end

            -- Caso não encontre local vazio, tiro o boneco da lista de spawn
            if not validado then
                lista[k] = nil
            end
        end
    end
end

-- Crio os bonecos
local function PosicionarBonecos(lista)
    if #lista == 0 then return end

    for k,v in pairs(lista) do
        timer.Simple(math.Rand(1, 20), function()
            local boneco = ents.Create("boneco-de-neve")
            local pos = not IsValid(v) and Vector(v["origin"]) or v:GetPos()
            boneco:SetPos(pos)
            boneco:Initialize()
        end)
    end
end

-- Função principal
function Bonequizar()
    local lista = {}

    local entidadesBSP = util.JSONToTable(file.Read(boneco_pasta .. boneco_arquivo, "Data"))

    -- Processando bonecos
    PegarPontosEntidades(lista)
    PegarPontosEntidadesBSP(lista, entidadesBSP)
    FiltrarPontosAleatorios(lista)
    ValidarPosicoes(lista)
    PosicionarBonecos(lista)
end

-- Comando de console
concommand.Add("bonequizar", function()
    Bonequizar()
end)
