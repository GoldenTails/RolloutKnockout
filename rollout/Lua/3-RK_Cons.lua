--
-- RK_Mobj.Lua
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