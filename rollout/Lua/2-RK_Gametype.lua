--
-- RK_Gametype.Lua
-- Resource file for Gametype-related information
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.gt = {}

freeslot(
"TOL_ROLLOUT"--,
--"TOL_ROLLOUTRACE"
)

table.insert(RK.gt, {
	name = "Rollout Knockout (Time)",
	identifier = "ROLLOUT_TIME", -- GT_ROLLOUT_TIME
	typeoflevel = TOL_ROLLOUT,
	rules = GTR_SPECTATORS|GTR_HURTMESSAGES|GTR_NOSPECTATORSPAWN|GTR_DEATHMATCHSTARTS|GTR_TIMELIMIT,
	intermissiontype = int_match,
	rankingtype = GT_MATCH,
	defaulttimelimit = 5,
	headercolor = 148,
	description = "You and your opponents are all on rocks! Knock everyone off the stage and come out on top!"
})

table.insert(RK.gt, {
	name = "Rollout Knockout (Stock)",
	identifier = "ROLLOUT_STOCK", -- GT_ROLLOUT_STOCK
	typeoflevel = TOL_ROLLOUT,
	rules = GTR_SPECTATORS|GTR_HURTMESSAGES|GTR_NOSPECTATORSPAWN|GTR_DEATHMATCHSTARTS|GTR_TIMELIMIT|GTR_LIVES,
	intermissiontype = int_match,
	rankingtype = GT_MATCH,
	defaulttimelimit = 8,
	headercolor = 148,
	description = "You and your opponents are all on rocks! Knock everyone off the stage and come out on top! Super Bash Sisters style!"
})

-- Create dynamic-size gametype table. All we have to do is call table.insert.
for i = 1, #RK.gt do
	G_AddGametype(RK.gt[i])
end

/*G_AddGametype({
    name = "Rollout Race",
    identifier = "RROLLOUT",
    typeoflevel = TOL_ROLLOUTRACE,
    rules = GTR_SPECTATORS|GTR_HURTMESSAGES|GTR_NOSPECTATORSPAWN|GTR_RACE|GTR_ALLOWEXIT,
    intermissiontype = int_race,
	rankingtype = GT_RACE,
    headercolor = 188,
	description = 
		"Well, of course this was gonna happen, Rollout Racing."..
		"'It's a race to the finish, you say?' HELL YES!"
})*/

-- Check to see if we are in a Rollout Gametype
rawset(_G, "G_IsRolloutGametype", function()
	return (gametype == GT_ROLLOUT_TIME) or (gametype == GT_ROLLOUT_STOCK)-- or (gametype == GT_RROLLOUT)
end)

-- Re-index ROLLOUT gamemodes to an index of 1
rawset(_G, "G_GetCurrentRKGametype", function()
	local numgametypes = GT_ROLLOUT_TIME - 1
	return (gametype - numgametypes)
end)

RK.DrainAmmo = function(p, power, amount)
	if power and amount then
		-- Drain power by specific amount
		p.powers[power] = $ - amount
		p.rings = $ - amount
		if (p.powers[power] < 0) then p.powers[power] = 0 end
	elseif power and not amount then
		-- Drain power by default amount (1)
		p.powers[power] = $ - 1
		p.rings = $ - 1
		if (p.powers[power] < 0) then p.powers[power] = 0 end
	elseif amount and not power then
		-- Drain rings by specific amount
		p.rings = $ - amount
		if (p.rings < 0) then p.rings = 0 end
	else
		-- Drain power by default amount (1)
		p.rings = $ - 1
		if (p.rings < 0) then p.rings = 0 end
	end
	if (p.rings < 0) then p.rings = 0 end
	
	-- Copied from SRB2 Source
	/*if (p.rings < 1)
		p.ammoremovalweapon = p.currentweapon
		p.ammoremovaltimer = ammoremovaltics -- 2*TICRATE
		
		if (p.powers[power] > 0)
			p.powers[power] = $ - 1
			p.ammoremoval = 2
		else
			p.ammoremoval = 1
		end
	else
		p.rings = $ - 1
	end*/
end
