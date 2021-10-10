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

/*table.insert(RK.gt, {
    name = "Rollout Race",
    identifier = "RROLLOUT",
    typeoflevel = TOL_ROLLOUTRACE,
    rules = GTR_SPECTATORS|GTR_HURTMESSAGES|GTR_NOSPECTATORSPAWN|GTR_RACE|GTR_ALLOWEXIT,
    intermissiontype = int_race,
	rankingtype = GT_RACE,
    headercolor = 188,
	description = 
		"Well, of course this was gonna happen, Rollout Racing."..
		"It's a race to the finish!"
})*/

-- Create dynamic-size gametype table. All we have to do is call table.insert.
for i = 1, #RK.gt do
	G_AddGametype(RK.gt[i])
end

-- Check to see if we are in a Rollout Gametype
rawset(_G, "G_IsRolloutGametype", function()
	return (gametype == GT_ROLLOUT_TIME) or (gametype == GT_ROLLOUT_STOCK)-- or (gametype == GT_RROLLOUT)
end)

-- Re-index ROLLOUT gamemodes to an index of 1
rawset(_G, "G_GetCurrentRKGametype", function()
	local numgametypes = GT_ROLLOUT_TIME - 1
	return (gametype - numgametypes)
end)