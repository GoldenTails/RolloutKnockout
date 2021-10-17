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
RK.game.pregame = { var = true, ticker = 0, warped = false }
RK.game.exiting = {}
RK.game.exiting = { var = false, ticker = 0 }

RK.game.countInGamePlayers = function()
	local playeringame = 0
	for p in players.iterate
		if p.spectator then continue end -- We're a spectator. Skip.
		if not p.realmo then continue end -- Player does not have a mo object. Skip.
		if p.bot then continue end  -- Player is a bot. Skip.
		if (gametyperules & GTR_LIVES) and (p.lives <= 0) then continue end -- Out of lives
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

/*RK.game.countActiveSpectators = function() -- Self explainitory
	local actSpec = 0
	for p in players.iterate
		if not p.spectator then continue end -- Not a spectator. Skip.
		if not p.realmo then continue end -- Player does not have a mo object. Skip.
		if pt.bot then continue end  -- Player is a bot. Skip.
		
		-- TODO: If I ever uncomment this, make a check for when a player is a spectator and hasn't *moved* in a period of time.
		-- Most of that is already here, but checking if a spectator player hasn't pressed a button  for some time isn't here.
		actSpec = $ + 1
	end
	return actSpec
end*/

RK.game.countTotalPlayers = function() -- Counts total number of in-game players
	local totalplayers = 0
	for p in players.iterate
		totalplayers = $ + 1
	end
	return totalplayers
end

addHook("ThinkFrame", do
	if G_IsRolloutGametype() then
		local timelimit = CV_FindVar("timelimit").value
			
		if not RK.game.exiting.var then
			RK.game.exiting.ticker = 0
		else
			RK.game.exiting.ticker = $ + 1
		end
		
		if not RK.game.pregame.warped then -- Did not warp to an in-game map yet.
			if RK.game.pregame.var then -- Still pregame?
				RK.game.pregame.ticker = 0 -- Keep the value reset
			else -- Otherwise, if we're no longer in the pregame...
				if (RK.game.pregame.ticker == 4*TICRATE) then -- Current pregame ticker value is more than 4 seconds
					RK.game.pregame.warped = true -- Set the 'warped' variable so this doesn't trigger more than once.
					RK.game.pregame.ticker = 0 -- Reset the pregame ticker value
					G_SetCustomExitVars(gamemap, 1) -- Nextmap will be the same map, skip stats
					G_ExitLevel() -- Reload!
					return -- Don't process anything else
				end
				RK.game.pregame.ticker = $ + 1 -- Increment the value if no longer in the pregame.
				return -- Don't process anything else
			end
		else
			-- OK so, what if we warped, but the total player count went back down to 1?
			-- How do we mitigate against an infinite loop?
			if (RK.game.countInGamePlayers() <= 1) then
				RK.game.pregame.warped = false
				RK.game.pregame.var = true
				S_StartSound(nil, sfx_s3kb2, consoleplayer) -- Play a little jingle [Failure]
				COM_BufInsertText(nil, "timelimit 0") -- Set the timer!
				return -- Don't process anything else
			end
			
			-- If the default timer isn't set...
			if cv_rkdefaulttime.value and not timelimit then
				COM_BufInsertText(nil, "timelimit 8") -- Set the timer!
			end
		end
		
		-- Timelimit shenanigans
		if (gametyperules & GTR_TIMELIMIT) then -- Gametype has a timelimit
			if timelimit and (leveltime > (((timelimit*TICRATE)*60) - 4*TICRATE))  -- 4 seconds before 'Timelimit' console variable
			and not RK.game.exiting.ticker then -- Not already exiting
				RK.game.exiting.var = true -- Start the exit process
			end
		end
		
		-- Stock (Lives) match shenanigans
		if (gametyperules & GTR_LIVES) then
			if RK.game.pregame.var -- Are we in the pregame?
			and (RK.game.countInGamePlayers() > 1) then -- The number of in-game players are > 1 (Two or more)
				RK.game.pregame.var = false -- Start the in-game process
				S_StartSound(nil, sfx_s3k63, consoleplayer) -- Play a little jingle [Checkpoint]
			elseif not RK.game.pregame.var -- No longer in the pregame?
			and (RK.game.countTotalPlayers() > 1) -- Number of total players is > 1 (Two or more)
			and (RK.game.countInGamePlayers() == 1) -- And the number of in-game players are 1
			and not RK.game.exiting.ticker then -- Not already exiting
				RK.game.exiting.var = true -- Start the exit process
			end
		end
		
		if RK.game.exiting.var then -- Are we already "exiting"?
			if (RK.game.exiting.ticker == 1) then -- Music fade
				S_FadeOutStopMusic(MUSICRATE)
				for p in players.iterate do
					if p.powers[pw_nocontrol] then continue end
					p.powers[pw_nocontrol] = 4*TICRATE
				end
			elseif (RK.game.exiting.ticker >= TICRATE) then -- Also extend the p.exiting timer by another second
				for p in players.iterate do
					if not p.mo then continue end
					local rock = p.mo.rock
					if rock and rock.valid
					and rock.lastbumper then 
						rock.lastbumpertics = 0
						rock.lastbumper = nil 
					end
					
					if p.exiting then continue end -- Already exiting? Skip
					p.exiting = 3*TICRATE-1
				end
			end
		end
	end
end)

-- Reset the exiting variables.
addHook("MapChange", function(mapnum) -- mapnum goes unused
	RK.game.exiting.var = false
	RK.game.exiting.ticker = 0
	RK.game.pregame.ticker = 0
end)
addHook("IntermissionThinker", do
	RK.game.exiting.var = false
	RK.game.exiting.ticker = 0
	RK.game.pregame.ticker = 0
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
	if G_IsRolloutGametype() and (gamestate == GS_LEVEL) 
	and G_GametypeUsesLives() then
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
	RK.game.exiting = net($)
	RK.game.pregame = net($)
end)