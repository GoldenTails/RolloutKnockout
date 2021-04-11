--
-- RK_Game.Lua
-- Resource file for some gamestate, and gameplay functions.
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.game = {}
RK.game.exiting = {}
RK.game.exiting = { var = 0, ticker = 0, endtime = 0 }

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

RK.game.countTotalPlayers = function()
	local totalplayers = 0
	for p in players.iterate
		totalplayers = $ + 1
	end
	return totalplayers	
end

addHook("ThinkFrame", do
	if (RK.game.countTotalPlayers() > 1)
	and (RK.game.countInGamePlayers() == 1) then
		RK.game.exiting.ticker = $ + 1
		RK.game.exiting.endtime = 3*TICRATE
		RK.game.exiting.var = true
		print("We are exiting now!")
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