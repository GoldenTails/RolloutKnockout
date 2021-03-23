--
-- RK_Misc.Lua
-- Resource file for HUD functions and other goodies that don't fit elsewhere
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.hud = function()
	if G_IsRolloutGametype()
		hud.disable("rings")
		hud.disable("lives")
		hud.disable("weaponrings")
		hud.disable("nightslink")
		hud.disable("nightsdrill")
		hud.disable("nightsrings")
		hud.disable("nightsscore")
		hud.disable("nightstime")
		hud.disable("nightsrecords")
	else
		hud.enable("rings")
		hud.enable("lives")
		hud.enable("weaponrings")
		hud.enable("nightslink")
		hud.enable("nightsdrill")
		hud.enable("nightsrings")
		hud.enable("nightsscore")
		hud.enable("nightstime")
		hud.enable("nightsrecords")
	end
end
hud.add(RK.hud, "game")


-- HurtMsg hook to replace the default "x's tagging hand killed y" Message
addHook("HurtMsg", function(p, i, s)
	if G_IsRolloutGametype() then
		if not p or not p.valid then return end
		if not i or not i.valid then return end
		if not s or not s.valid then return end
		
		if (i.type == MT_PLAYER) and i.player
		and (s.type == MT_PLAYER) and s.player then
			CONS_Printf(p,s.player.name.." killed "..p.name..".")
			return true
		else
			return false
		end
	else
		return false
	end
end, MT_PLAYER)