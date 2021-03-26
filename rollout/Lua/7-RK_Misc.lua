--
-- RK_Misc.Lua
-- Resource file for HUD functions and other goodies that don't fit elsewhere
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.hud = {}

RK.hud.game = function()
	if G_IsRolloutGametype() then
		hud.disable("rings")
		hud.disable("lives")
		hud.disable("weaponrings")
		hud.disable("nightslink")
		hud.disable("nightsdrill")
		hud.disable("nightsrings")
		hud.disable("nightsscore")
		hud.disable("nightstime")
		hud.disable("nightsrecords")
		hud.disable("rankings")
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
		hud.enable("rankings")
	end
end
hud.add(RK.hud.game, "game")

RK.hud.scores = function(v)
	if not v then return end
	if G_IsRolloutGametype() then
		hud.disable("rankings")
		
		local vsize = { x = (v.width()), y = (v.height()) }
		local offset = { x = vsize.x/13, y = 0}
		local vflags = V_NOSCALESTART

		v.drawString(offset.x, vsize.y/12, "#", vflags|V_YELLOWMAP)
		v.drawString((offset.x + 136), vsize.y/12, "Name", vflags|V_YELLOWMAP)
		v.drawString(7*offset.x, vsize.y/12, "R. DMG", vflags|V_YELLOWMAP)
		v.drawString(10*offset.x, vsize.y/12, "Score", vflags|V_YELLOWMAP)
		v.drawFill(20, vsize.y/8, vsize.x-40, 4, vflags|SKINCOLOR_WHITE)
		
		for p in players.iterate do
			local mo = p.mo or p.realmo
			local pname = p.name
			local pface = v.getSprite2Patch(mo.skin, SPR2_XTRA, 0, 0) -- Get this player's icon!
			
			-- Trim the characters to a Max of 12 characters.
			if pname and string.len(pname) >= 12
				pname = string.sub($, 1, 12)
			end

			if #p <= 8 then
				v.drawString(offset.x, vsize.y/6 + #p*70, #p + 1, vflags) -- Player node number + 1
				if p.spectator or (p.playerstate == PST_DEAD) then
					v.drawScaled((offset.x + 64)*FRACUNIT, 
									(vsize.y/7 + #p*70)*FRACUNIT, 
									FRACUNIT/2, pface,
									V_50TRANS|vflags, v.getColormap(-1, p.skincolor)) -- Player Portrait w/ current player color (Transparent)
				else
					v.drawScaled((offset.x + 64)*FRACUNIT, 
									(vsize.y/7 + #p*70)*FRACUNIT, 
									FRACUNIT/2, pface,
									vflags, v.getColormap(-1, p.skincolor)) -- Player Portrait w/ current player color
				end
				v.drawString(offset.x + 136, vsize.y/6 + #p*70, pname, vflags|V_ALLOWLOWERCASE) -- Player Name
				if mo.rock and mo.rock.valid then
					v.drawString(8*offset.x + offset.x/2, vsize.y/6 + #p*70, p.mo.rock.percent.."%", vflags, "right") -- Rock Damage
				else
					v.drawString(8*offset.x + offset.x/2, vsize.y/6 + #p*70, "NaN".."%", vflags|V_ALLOWLOWERCASE, "right") -- Rock Damage
				end
				v.drawString(11*offset.x + offset.x/2, vsize.y/6 + #p*70, p.score, vflags, "right") -- Score #
			
			else
				--for p=0, 32 do
				--end
			end
		end

		v.drawString(5,(95*vsize.y)/100,RK.gt.rk.name, vflags)
	else
		hud.enable("rankings")
	end
end
hud.add(RK.hud.scores, "scores")

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