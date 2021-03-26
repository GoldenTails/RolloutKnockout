--
-- RK_Mobj.Lua
-- Resource file Player-specific functions and behaviors
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

addHook("PreThinkFrame", do
	for p in players.iterate
		if (p.weapondelay <= 2) then
			p.weapondelay = 2 -- Do not fire rings. Ever.
		end
	end
end)

addHook("PlayerSpawn", function(player)
	if G_IsRolloutGametype() and (player.mo and player.mo.valid) then
		player.powers[pw_nocontrol] = TICRATE/3
		local rheight = mobjinfo[MT_ROLLOUTROCK].height -- Rock Height
		P_TeleportMove(player.mo, player.mo.x, player.mo.y, player.mo.z + rheight + 5*FRACUNIT) -- Offset to be above the rock slightly
		player.ingametics = 0
		
		player.mo.rock = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.floorz, MT_ROLLOUTROCK) -- Spawn rock on the player's current floorz
		
		local rock = player.mo.rock
		rock.target = player.mo -- Target the player that spawned you. See "MobjThinker"
		rock.colorized = true
		if not (mapheaderinfo[gamemap].rockfloat) then
			rock.flags2 = $ | MF2_AMBUSH
		end
		rock.bumpcount = 0
		rock.rkability = 0
		rock.rkabilitytics = 0
	end
end)

addHook("JumpSpecial", function(p)
	if G_IsRolloutGametype() then
		if p.mo and p.mo.valid
		and p.mo.rock and p.mo.rock.valid then
			local mo = p.mo
			if (P_IsObjectOnGround(mo.rock) -- On ground
			or (mo.rock.eflags & MFE_TOUCHWATER) -- Or touching Water
			or (mo.rock.eflags & MFE_GOOWATER) -- Or touching goo
			or (mo.rock.eflags & MFE_TOUCHLAVA)) -- Or touching Lava
			and not (p.pflags & PF_JUMPDOWN) then -- Not holding the jump button
				p.pflags = $ | PF_JUMPDOWN
				
				if not p.currentweapon -- No weapon selected
				and (p.weapondelay <= 2) then -- Not on cooldown
					S_StopSound(mo)
					--S_StartSound(mo, sfx_mswarp) -- Zoom!
					S_StartSound(mo, sfx_s3kb6) -- Spin Launch
					
					p.weapondelay = (3*TICRATE)
					p.mo.rock.rkability = WEP_RAIL
					p.mo.rock.rkabilitytics = (3*TICRATE)/4
					p.powers[pw_flashing] = TICRATE/3
					p.powers[pw_nocontrol] = TICRATE/2
					P_InstaThrust(mo.rock, mo.angle, p.normalspeed/2)
					P_SetObjectMomZ(mo.rock, 5*FRACUNIT, true)

				elseif (p.currentweapon == WEP_AUTO) -- Automatic Ring
				and (p.ringweapons & RW_AUTO) -- Weapon ring able to be fired
				and (p.powers[pw_automaticring] > 0) -- Player has Auto rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmoAmmo(p, pw_automaticring) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
					
				elseif (p.currentweapon == WEP_BOUNCE) -- Automatic Ring
				and (p.ringweapons & RW_BOUNCE) -- Weapon ring able to be fired
				and (p.powers[pw_bouncering] > 0) -- Player has Auto rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmoAmmo(p, pw_bouncering) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
					
				elseif (p.currentweapon == WEP_SCATTER) -- Scatter Ring
				and (p.ringweapons & RW_SCATTER) -- Weapon ring able to be fired
				and (p.powers[pw_scatterring] > 0) -- Player has Scatter rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmoAmmo(p, pw_scatterring) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
					
				elseif (p.currentweapon == WEP_GRENADE) -- Grenade Ring
				and (p.ringweapons & RW_GRENADE) -- Weapon ring able to be fired
				and (p.powers[pw_grenadering] > 0) -- Player has Scatter rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmoAmmo(p, pw_grenadering) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
					
				elseif (p.currentweapon == WEP_EXPLODE) -- Explosion Ring
				and (p.ringweapons & RW_EXPLODE) -- Weapon ring able to be fired
				and (p.powers[pw_explosionring] > 0) -- Player has Scatter rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmoAmmo(p, pw_explosionring) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
					
				elseif (p.currentweapon == WEP_RAIL) -- Rail ring
				and (p.ringweapons & RW_RAIL) -- Weapon ring able to be fired
				and (p.powers[pw_railring] > 0) -- Player has Rail rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					--RK.DrainAmmoAmmo(p, pw_railring) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					p.mo.rock.rkability = p.currentweapon
					p.mo.rock.rkabilitytics = (3*TICRATE)/4
					p.powers[pw_nocontrol] = TICRATE
					P_SetObjectMomZ(mo.rock, p.jumpfactor, false)
					
				elseif (p.weapondelay <= 2) then
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					CONS_Printf(p, "Ability not implemented yet!")
				end
			end
		end
		return (p.powers[pw_carry] & CR_ROLLOUT)
	else
		return false
	end
end)

addHook("AbilitySpecial", function(p)
	if G_IsRolloutGametype() then
		return true
	else
		return false
	end
end)

addHook("JumpSpinSpecial", function(p)
	if G_IsRolloutGametype() then
		return true
	else
		return false
	end
end)

addHook("SpinSpecial", function(p)
	if G_IsRolloutGametype() then
		return true
	else
		return false
	end
end)

addHook("PlayerThink", function(p)
	if G_IsRolloutGametype()
	and (p.mo and p.mo.valid)
	and (p.mo.rock and p.mo.rock.valid)
	and p.playerstate ~= PST_DEAD then
		local mo = p.mo
		if (p.playerstate == PST_LIVE) then p.ingametics = $ + 1 end
		
		-- Respawn failsafe
		if (p.ingametics < 2*TICRATE)
		and p.mo.rock.bumpcount and (p.mo.rock.bumpcount > 15) then
			p.playerstate = PST_REBORN
		end
	end
end)

/*addHook("MobjDeath", function(mo)
	-- Check to see if the player died before the rock despawned
	if G_IsRolloutGametype() then
		if mo and mo.valid
		and mo.player and mo.player.valid
		and mo.rock and mo.rock.valid -- Rock is still valid
			P_RemoveMobj(mo.rock) -- If the rock still exists, remove it
		end
	end
end, MT_PLAYER)*/