--[[

#########################
## Xalascript do poder ##
#########################
https://github.com/xalalau/GMod/tree/master/Xalascript
Isso aqui é uma porcaria de script para fazer testes e coisas bestas.

Por Xalalau Xubilozo.
Versão: ???

]]--


Msg("\n---------------------------------------------------------------------------------\n");
Msg(" O Xalascript esta em funcionamento - Digite /help no chat para mais informacoes");
Msg("\n---------------------------------------------------------------------------------\n");


-- Server 
-- ------

if SERVER then
    AddCSLuaFile("xalascript.lua") -- Clientes baixam o script
end

timer.Simple(1, function() PrintMessage( HUD_PRINTTALK, "Xalascript em funcionamento") end); -- Mostra a msg de "Em funcionamento"

-- Client
-- -----------------

if CLIENT then 
function playersay(ply, text, public)

	prefixo = "/"; -- Prefixo que sai na frente dos comandos. É obrigatório ter um.

	tabela={}; -- Tabela de comandos

	tabela.com1={};tabela.des1={};
	tabela.com1[1],tabela.des1[1] = prefixo.."help","   - Mostra os comandos do xalascript.";
	tabela.com1[2],tabela.des1[2] = prefixo.."cvar","   - Usa comandos de console (alguns comandos sao bloqueados).";
	tabela.com1[3],tabela.des1[3] = prefixo.."dc","     - Remove decals e corpses.";

	tabela.com2={};tabela.des2={};
	tabela.com2[1],tabela.des2[1] = prefixo.."8000","   - Mais de 8000 de armour e hp."
	tabela.com2[2],tabela.des2[2] = prefixo.."kill","   - Suicidio."
	tabela.com2[3],tabela.des2[3] = prefixo.."noclip"," - Ativa/desativa o modo de voo.";
	tabela.com2[4],tabela.des2[4] = prefixo.."person"," - Alterna entre a primeira e terceira pessoa (por sv_cheats 1).";

	tabela.com3={};tabela.des3={};
	tabela.com3[1],tabela.des3[1] = prefixo.."act","    - agree, becon, cheer, disagree, laugh, muscle, wave, zombie";
	tabela.com3[2],tabela.des3[2] = prefixo.."hair","   - cria um monte de bolas cabeludas (por sv_cheats 1).";

	if (string.sub(text, 1, 1)) == prefixo then -- não roda se não tiver "!" no começo da frase

		if text == tabela.com1[1] then -- HELP
			print"\n-------------------";
			print"    Xalascript";
			print"-------------------";
			tit={}; n={};
			n[1], tit[1] = table.maxn(tabela.com1), "Gerais";
			n[2], tit[2] = table.maxn(tabela.com2), "Player";
			n[3], tit[3] = table.maxn(tabela.com3), "Troll";
			libtit={};
			for i = 1,3 do
				if libtit[i] == nil then
					libtit[i] = 1;
					print("\n"..tit[i]);
					MsgC(Color(153,50,205), "------\n")
				end
				if i == 1 then
					for j = 1,n[i] do
						Msg(tabela.com1[j]);
						Msg(tabela.des1[j].."\n");
					end
				end
				if i == 2 then
					for j = 1,n[i] do
						Msg(tabela.com2[j]);
						Msg(tabela.des2[j].."\n");
					end
				end	
				if i == 3 then
					for j = 1,n[i] do
						Msg(tabela.com3[j]);
						Msg(tabela.des3[j].."\n");
					end
				end
			end
			print("");
			ply:SendLua("RunConsoleCommand( \"showconsole\")");

		elseif (string.sub(text, 1, 5)) ==  tabela.com1[2] then -- CVAR
			text = string.sub(text, 7);
			text = string.Explode(" ", text);
			n = table.maxn(text);
			aa = text[1]; bb = text[2]; cc = text[3]; dd = text[4]; ee = text[5]; ff = text[6]; gg = text[7]; hh = text[8];
			if n == 1 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\")");
			elseif n == 2 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\" , \""..bb.."\")");
			elseif n == 3 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\")");
			elseif n == 4 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\", \""..dd.."\")");
			elseif n == 5 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\", \""..dd.."\", \""..ee.."\")");
			elseif n == 6 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\", \""..dd.."\", \""..ee.."\", \""..ff.."\")");
			elseif n == 7 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\", \""..dd.."\", \""..ee.."\", \""..ff.."\", \""..gg.."\")");
			elseif n == 8 then
				ply:SendLua("RunConsoleCommand( \""..aa.."\", \""..bb.."\", \""..cc.."\", \""..dd.."\", \""..ee.."\", \""..ff.."\", \""..gg.."\", \""..hh.."\")");
			end

		elseif text == tabela.com1[3] then -- DC
			ply:SendLua("RunConsoleCommand(\"r_cleardecals\")");	
			temp = GetConVarNumber("g_ragdoll_maxcount")
			ply:SendLua("RunConsoleCommand(\"g_ragdoll_maxcount\", \"0\")")
			timer.Simple(1, function() ply:SendLua("RunConsoleCommand( \"g_ragdoll_maxcount\", "..tostring(temp).." )") end )

		elseif text == tabela.com2[1] then -- 8000
			ply:SetHealth(8001);
			ply:SetArmor(8001);

		elseif text == tabela.com2[2] then -- KILL
			ply:SendLua("RunConsoleCommand( \"kill\")");

		elseif text == tabela.com2[3] then -- NOCLIP
			ply:SendLua("RunConsoleCommand( \"noclip\")");

		elseif text == tabela.com2[4] then -- FIRST/THIRD PERSON
			if libpess == nil then
				ply:SendLua("RunConsoleCommand( \"thirdperson\")");
				libpess = 1;
			else
				ply:SendLua("RunConsoleCommand( \"firstperson\")");
				libpess = nil;
			end

		elseif (string.sub(text, 1, 4)) == tabela.com3[1] then -- ACT
			text = string.sub(text, 6);
			ply:SendLua("RunConsoleCommand( \"act\", \""..text.."\")");

		elseif text == tabela.com3[2] then -- HAIR
			ply:SendLua("RunConsoleCommand(\"CreateHairball\")");

		end
		return(false);
	end
end

hook.Add("PlayerSay", "xalarizador", playersay);
end
