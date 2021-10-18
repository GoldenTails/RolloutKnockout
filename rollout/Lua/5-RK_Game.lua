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
RK.game.gsenum = {}

createEnum(RK.game.gsenum, {
	"RKGS_PRE", -- Pregame
	"RKGS_PREP", -- Prep
	"RKGS_GAME", -- Game
	"RKGS_EXIT", -- Exiting
}, 1)
for i = 1, #RK.game.gsenum
    print("RK.game.gsenum[" + RK.game.gsenum[i].string + "] allocated. "+ RK.game.gsenum[i].string +" has enum of "+RK.game.gsenum[i].value)
end
RK.game.event = {}
RK.game.event.state = RKGS_PRE -- RK Gamestate event handling
RK.game.event.ticker = 0

RK.game.countTotalPlayers = function() -- Counts total number of in-game players
	local totalplayers = 0
	for p in players.iterate
		totalplayers = $ + 1
	end
	return totalplayers
end

RK.game.countInGamePlayers = function()
	local pcount = 0
	for p in players.iterate
		if p.spectator then continue end -- We're a spectator. Skip.
		if not p.realmo then continue end -- Player does not have a mo object. Skip.
		if p.bot then continue end  -- Player is a bot. Skip.
		pcount = $ + 1
	end
	return pcount
end

RK.game.countPlayersWithLives = function()
	local pcount = 0
	for p in players.iterate
		if not p.realmo then continue end -- Player does not have a mo object. Skip.
		if p.bot then continue end  -- Player is a bot. Skip.
		if (gametyperules & GTR_LIVES) and (p.lives <= 0) then continue end -- Out of lives
		pcount = $ + 1
	end
	return pcount
end

RK.game.countSpectators = function()
	local scount, iscount = 0
	for p in players.iterate
		if not p.spectator then continue end -- Not a spectator. Count spectators.
		scount = $ + 1
		if (p.spectatortime < 30*TICRATE) then continue end -- Spectator for 30 seconds or less. Skip.
		iscount = $ + 1
	end
	return { scount, iscount }
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

addHook("ThinkFrame", do
	if G_IsRolloutGametype() then
		local timelimit = CV_FindVar("timelimit").value
		--if true then return end
		if (RK.game.event.state == RKGS_PREP)
		or (RK.game.event.state == RKGS_EXIT) then
			RK.game.event.ticker = $ + 1
		else
			RK.game.event.ticker = 0
		end

		-- Event handler
		if (RK.game.event.state == RKGS_PRE) -- Pre-game state
		and (RK.game.countTotalPlayers() > 1)
		and (RK.game.countInGamePlayers() > 1) then
			RK.game.event.ticker = 0
			RK.game.event.state = RKGS_PREP -- Start the Gamestate preparation
			S_StartSound(nil, sfx_s3k63, consoleplayer)
			return -- Don't process anything else this tic
		elseif (RK.game.event.state ~= RKGS_PRE) -- Not Pre-game, so at any point...
		and ((RK.game.countTotalPlayers() <= 1) -- Our total player count is <= 1 (One or less)
		or ((RK.game.countTotalPlayers() > 1) -- Or Our total player count is > 1 (Two or more)...
		and (RK.game.countInGamePlayers() <= 1))) then -- AND our in-game player count is <= 1 (One or less)
			RK.game.event.ticker = 0
			RK.game.event.state = RKGS_PRE
			S_StartSound(nil, sfx_s3kb2, consoleplayer)
			return -- Don't process anything else this tic
		end

		if (RK.game.event.state == RKGS_PREP) -- Preparation State
		and (RK.game.event.ticker == 5*TICRATE) then
			RK.game.event.state = RKGS_GAME
			G_SetCustomExitVars(gamemap, 1) -- Nextmap will be the same map, skip stats
			G_ExitLevel() -- Reload!
			return -- Don't process anything else this tic
		end

		if cv_rkdefaulttime.value then
			if (RK.game.event.state < RKGS_GAME) 
			and timelimit then
				COM_BufInsertText(server, "timelimit 0")
			elseif (RK.game.event.state == RKGS_GAME) 
			and not timelimit then
				COM_BufInsertText(server, "timelimit 5")
			end
		end

		-- Stock (Lives) match shenanigans
		if (gametyperules & GTR_LIVES)
		and (RK.game.event.state == RKGS_GAME) then
			if (RK.game.countTotalPlayers() > 1)
			and (RK.game.countInGamePlayers() > 1)
			and (RK.game.countPlayersWithLives() == 1) then
				RK.game.event.state = RKGS_EXIT -- Start the exit process
				return -- Don't process anything else this tic
			end
		end
		
		-- Timelimit shenanigans
		if (gametyperules & GTR_TIMELIMIT) -- Gametype has a timelimit
		and (RK.game.event.state == RKGS_GAME) then
			if timelimit and (leveltime > (((timelimit*TICRATE)*60) - 4*TICRATE)) then -- 4 seconds before 'Timelimit' console variable
				RK.game.event.state = RKGS_EXIT -- Start the exit process
				return -- Don't process anything else this tic
			end
		end
		
		if (RK.game.event.state == RKGS_EXIT) then -- Are we already "exiting"?
			if (RK.game.event.ticker == 1) then -- Music fade
				S_FadeOutStopMusic(MUSICRATE)
				for p in players.iterate do
					if p.powers[pw_nocontrol] then continue end
					p.powers[pw_nocontrol] = 4*TICRATE
				end
			elseif (RK.game.event.ticker >= TICRATE) then -- Also extend the p.exiting timer by another second
				for p in players.iterate do
					if not p.realmo then continue end
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
	if (RK.game.event.state > RKGS_GAME) then RK.game.event.state = RKGS_PRE end
	RK.game.event.ticker = 0
end)
addHook("IntermissionThinker", do
	if (RK.game.event.state > RKGS_GAME) then RK.game.event.state = RKGS_PRE end
	RK.game.event.ticker = 0
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
				elseif (RK.game.event.state == RKGS_PREP) 
				or (RK.game.event.state == RKGS_EXIT) then
					CONS_Printf(p, "Please wait to enter the game!")
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
	RK.game.event.state = net($)
	RK.game.event.ticker = net($)
end)