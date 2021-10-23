--
-- RK_Player.Lua
-- Resource file Player-specific functions and behaviors
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.plyr = {}

RK.plyr.deathThink1 = function(p)
	if not p or not p.valid then return end
	if not p.mo or not p.mo.valid then return end
	
	local mo = p.mo -- Simplify
	if (mo.fuse > 1) 
	and not (leveltime%7) then -- Buildup to explosion.
			local r = mo.radius>>FRACBITS
			local xpld = P_SpawnMobj(mo.x + (P_RandomRange(-r, r)<<FRACBITS),
							mo.y + (P_RandomRange(-r, r)<<FRACBITS),
							mo.z + (P_RandomKey(mo.height>>FRACBITS)<<FRACBITS),
							MT_SONIC3KBOSSEXPLODE)
			S_StartSound(xpld, sfx_s3kb4)
	elseif (mo.fuse == 1) then -- Explode!
		mo.momx = 0
		mo.momy = 0
		mo.momz = 0
		local xpld = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY) -- Spawn an object.
		xpld.state = S_RXPL1
		xpld.scale = 2*FRACUNIT
		/*local xpld = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY) -- Spawn an object.
		xpld.state = S_SXPA*/
		S_StartSound(xpld, sfx_pplode) -- Play a sound.
		if cv_rkquake.value then -- If the specified consvar is enabled...
			P_StartQuake(40*FRACUNIT, 5) -- Shake the screen.
		end
		
		-- We're already doing a number of flashy effects while exiting. 
		-- Don't process anything else.
		if RK.game.event.ticker then return end
		
		-- Flash the screen
		for px in players.iterate do
			if (px == p) then continue end -- Us? Skip.
			if px.spectator then continue end -- Spectator? Skip
			if not px.mo then continue end -- Mo doesn't exist? Skip
			local idist = FixedHypot(FixedHypot(px.mo.x - p.mo.x, px.mo.y - p.mo.y), px.mo.z - p.mo.z)
			if (idist < 512*FRACUNIT) then 
				P_FlashPal(px, 1, 3)
			end
		end
		P_FlashPal(p, 1, 3)
	end
end

RK.plyr.deathThink2 = function(p)
	if not p or not p.valid then return end
	if not p.mo or not p.mo.valid then return end
	
	local mo = p.mo -- Simplify
	if (mo.fuse > 1) then
		-- Nothing special
	elseif (mo.fuse == 1) then
		mo.momx = 0
		mo.momy = 0
		mo.momz = 0
		
		local xpldbg = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY) -- Spawn an object.
		xpldbg.state = S_EFXA
		xpldbg.scale = 2*FRACUNIT
		xpldbg.fuse = 5*TICRATE
		/*for i = 0, 1 do
			local xpld = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			xpld.color = SKINCOLOR_WHITE
			xpld.tics = 3*TICRATE
			xpld.fuse = xpld.tics
			xpld.threshold = 100+i
			if (i == 1) then
				xpld.destscale = 3*FRACUNIT
				xpld.scalespeed = xpld.destscale/TICRATE
			end
		end*/
		if cv_rkquake.value then -- If the specified consvar is enabled...
			P_StartQuake(35*FRACUNIT, 5) -- Shake the screen.
		end
	end
end

addHook("PreThinkFrame", do
	if G_IsRolloutGametype()
		for p in players.iterate
			-- Do not fire rings. Ever.
			if (p.weapondelay <= 2) then p.weapondelay = 2 end

			if p.spectator then continue end -- Spectating? Then you have normal spectating controls.
			local cmd = p.cmd
			cmd.buttons = $ & BT_JUMP -- Ignore anything but Jump input
		end
	end
end)

addHook("PlayerSpawn", function(player)
	player.ingametics = 0
	player.spectatortime = 0
	
	local mo = player.mo or player.realmo
	if G_IsRolloutGametype() and (mo and mo.valid) and not player.spectator then
		player.powers[pw_nocontrol] = TICRATE/3
		mo.rock = P_SpawnMobj(mo.x, mo.y, mo.z, MT_ROLLOUTROCK) -- Spawn rock at Player's current x/y/z.
		if not mo.rock or not mo.rock.valid then return end -- Something has gone horribly wrong
		local rock = mo.rock -- Simplify
		if (mo.eflags & MFE_VERTICALFLIP) then -- Place player "on" the rock
			P_TeleportMove(mo, mo.x, mo.y, mo.z - FRACUNIT)
		else
			P_TeleportMove(mo, mo.x, mo.y, mo.z + rock.height)
		end
		
		rock.target = player.mo -- Target the player that spawned you. See "MobjThinker"
		rock.colorized = true
		-- Make your rock float in water if level header options dictate it.
		if not (mapheaderinfo[gamemap].rockfloat) then rock.flags2 = $ | MF2_AMBUSH end
		
		rock.percent = 0
		rock.bumpcount = 0
		rock.rkability = 0
		rock.rkabilitytics = 0
	end
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
					--p.mo.rock.rkability = WEP_RAIL
					mo.rock.rkabilitytics = (3*TICRATE)/4
					p.powers[pw_flashing] = TICRATE/3
					p.powers[pw_nocontrol] = TICRATE/2
					P_InstaThrust(mo.rock, mo.angle, 3*p.normalspeed/5) -- Thrust forward
					local zDashfactor = 5*FRACUNIT
					if (mo.rock.eflags & MFE_UNDERWATER) then zDashfactor = $ / 2 end -- Underwater? Half height
					zDashfactor = $ * P_MobjFlip(mo) -- Reverse gravity check
					P_SetObjectMomZ(mo.rock, zDashfactor, true)
				elseif (p.currentweapon == WEP_AUTO) -- Automatic Ring
				and (p.ringweapons & RW_AUTO) -- Weapon ring able to be fired
				and (p.powers[pw_automaticring] > 0) -- Player has Auto rings to spare?
				and (p.weapondelay <= 2) -- Not on cooldown
				and RK.WepRings then
					-- Code
					RK.DrainAmmo(p, pw_automaticring) -- Decrease your weapon ring count by one
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
					RK.DrainAmmo(p, pw_bouncering) -- Decrease your weapon ring count by one
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
					RK.DrainAmmo(p, pw_scatterring) -- Decrease your weapon ring count by one
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
					RK.DrainAmmo(p, pw_grenadering) -- Decrease your weapon ring count by one
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
					RK.DrainAmmo(p, pw_explosionring) -- Decrease your weapon ring count by one
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
					--RK.DrainAmmo(p, pw_railring) -- Decrease your weapon ring count by one
					--S_StartSound(mo, sfx_antiri) -- Play a sound...
					S_StartSound(mo.target, sfx_kc65)
					p.weapondelay = 5*TICRATE -- Cooldown
					mo.rock.rkability = p.currentweapon
					mo.rock.rkabilitytics = (3*TICRATE)/4
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
	if G_IsRolloutGametype() then
		if (p.playerstate ~= PST_DEAD) then
			if (p.playerstate == PST_LIVE) then
				if not p.spectator then 
					p.ingametics = $ + 1
				else
					p.spectatortime = $ + 1
				end
			end
			--print(p.ingametics, p.spectatortime)
		elseif (p.playerstate == PST_DEAD) then
			RK.plyr.deathThink1(p)
		end
	end
end)

addHook("MobjDeath", function(mo)
	if G_IsRolloutGametype() then
		if mo and mo.valid
		and mo.player and mo.player.valid then
			local p = mo.player
			mo.flags = $ & ~(MF_SOLID|MF_SHOOTABLE)
			mo.flags = $ | (MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY)

			if not p.bot and not p.spectator and (p.lives ~= INFLIVES) and G_GametypeUsesLives() then
				if not (p.pflags & PF_FINISHED) then p.lives = $ - 1 end
			end
			
			mo.fuse = TICRATE -- NEEDS to be set to have the player visible on death.
			mo.state = S_PLAY_PAIN
			p.playerstate = PST_DEAD
			mo.momx = $/4
			mo.momy = $/4
			P_SetObjectMomZ(mo, 20*FRACUNIT, false)
			return true
		end
	end
end, MT_PLAYER)