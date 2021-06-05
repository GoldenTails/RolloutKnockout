--
-- RK_Cons.Lua
-- Resource file Console commands and related functions.
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.cons = {}

-- Respawn consvar
-- Respawns the player
RK.cons.Respawn = function(p)
	if G_IsRolloutGametype() then
		if p and p.valid then p.playerstate = PST_REBORN end
	else
		CONS_Printf(p, "Sorry. This command can only be used in Rollout Knockout maps!")
	end
end

COM_AddCommand("rk_respawn", RK.cons.Respawn)

-- Manually set the lives in RK
rawset(_G, "cv_rklives", {value = 3}) -- This avoids a console warning. This table gets overwritten.
cv_rklives = CV_RegisterVar({
	name = "rk_setlives",
	defaultvalue = 3,
	flags = CV_NETVAR|CV_CALL,
	PossibleValue = {MIN = 1, MAX = 99},
	Func = function()
		local serverornil = isdedicatedserver and nil or server
		COM_BufInsertText(serverornil, "startinglives "..cv_rklives.value)
		--print("Player lives has been set to "..cv_rklives.value)
		if not (gametyperules & GTR_LIVES) then return end
		for p in players.iterate
			p.lives = cv_rklives.value
		end
	end,
})