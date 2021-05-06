--
-- RK_Game.Lua
-- Resource file for some gamestate, and gameplay functions.
--
--
-- Flame
--
-- Date: 3-21-21
--

RK.game = {}
RK.game.exiting = {}
RK.game.exiting = { var = 0, ticker = 0 }

RK.game.countInGamePlayers = function()
	local playeringame = 0
	for p in players.iterate
		if p.spectator then continue end -- We're a spectator. Skip.
		if not p.mo then continue end -- Not a mo object. Skip.
		if p.bot then continue end  -- Player is a bot. Skip.
		if G_GametypeUsesLives() and (p.lives <= 0) then continue end -- Out of lives
		playeringame = $ + 1
	end
	return playeringame
end

RK.game.countTotalTeamPlayers = function(p) -- p 'host' needed too pass variable
	local totalteamplayers = 0
	for pt in players.iterate
		if pt.spectator then continue end -- Spectator? Skip
		if pt.bot then continue end  -- Player is a bot. Skip.
		if G_GametypeHasTeams() and (p.ctfteam ~= pt.ctfteam) then continue end -- On our team? Skip.
		totalteamplayers = $ + 1
	end
	return totalteamplayers
end

RK.game.countTotalPlayers = function()
	local totalplayers = 0
	for p in players.iterate
		totalplayers = $ + 1
	end
	return totalplayers
end

addHook("ThinkFrame", do
	if G_IsRolloutGametype() then
		if not RK.game.exiting.var then RK.game.exiting.ticker = 0 end
		
		if (RK.game.countTotalPlayers() > 1) -- Number of total players is > 1
		and (RK.game.countInGamePlayers() == 1) -- And the number of in-game players are 1
		or RK.game.exiting.var then -- Or if we are already "exiting"...
			RK.game.exiting.ticker = $ + 1
			RK.game.exiting.var = true
			if (RK.game.exiting.ticker == 1) then -- Music fade
				S_FadeOutStopMusic(MUSICRATE)
			elseif (RK.game.exiting.ticker >= TICRATE) then -- Also extend the p.exiting timer by another second
				for p in players.iterate do
					if p.exiting then continue end -- Already exiting? Skip
					p.exiting = 3*TICRATE-1
				end
			end
		end
	end
end)

-- Reset the exiting variables.
addHook("MapChange", function(mapnum) -- This goes unused
	if RK.game.exiting.var or RK.game.exiting.ticker then
		RK.game.exiting.var = false
		RK.game.exiting.ticker = 0
	end
end)

-- HurtMsg hook to replace the default "x's tagging hand killed y" Message
addHook("HurtMsg", function(p, i, s)
	if G_IsRolloutGametype() then
		if not p or not p.valid then return end
		if not i or not i.valid then return end
		if not s or not s.valid then return end
		
		if (i.type == s.type) and i.player and s.player then
			print(s.player.name.." killed "..p.name..".")
			return true
		else
			return false
		end
	else
		return false
	end
end)

addHook("TeamSwitch", function(p, team, fromspectators)
	if G_IsRolloutGametype() and G_GametypeUsesLives() then
		if p and p.valid then
			-- Cheeky check for those that die, become a spectator, and attempt to re-enter the game...
			if fromspectators then
				if p.lives <= 0 then
					CONS_Printf(p, "You're out of lives! Please wait to enter the next game!")
					return false
				elseif RK.game.exiting.var then
					CONS_Printf(p, "Please wait to enter the next game!")
					return false
				end
			elseif not fromspectators -- Although, becoming a spectator deducts a life by default...
			and (p.playerstate ~= PST_DEAD) then -- Not already dead?
				p.lives = $ + 1 -- Add one to be generous.
				return true
			end
		end
	end
end)

addHook("NetVars", function(net)
	RK.game.exiting = net(RK.game.exiting)
end)