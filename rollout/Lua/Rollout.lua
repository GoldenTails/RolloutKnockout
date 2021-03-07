freeslot(
"TOL_ROLLOUT"--,
--"TOL_ROLLOUTRACE"
)

G_AddGametype({
    name = "Rollout Knockout",
    identifier = "ROLLOUT",
    typeoflevel = TOL_ROLLOUT,
    rules = GTR_SPECTATORS|GTR_HURTMESSAGES|GTR_NOSPECTATORSPAWN|GTR_DEATHMATCHSTARTS|GTR_TIMELIMIT,
    intermissiontype = int_match,
	rankingtype = GT_MATCH,
    headercolor = 148,
	description = "You and your opponents are all on rocks, whaddya do? Knock them off the area, of course!"
})

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

rawset(_G, "G_IsRolloutGametype", function()
	return (gametype == GT_ROLLOUT)-- or (gametype == GT_RROLLOUT)
end)

-- Collision detect for objects (Z)
-- Kaysakado
-- "The issue with getting around SRB2's P_CheckPosition is that the floorz won't properly be updated"
rawset(_G, "FreeSetZ", function(mo, newz)
    local clip = (mo.flags & MF_NOCLIPTHING) ^^ MF_NOCLIPTHING

    mo.flags = $ | clip
    mo.z = newz
    mo.flags = $ & ~clip
end)

addHook("PlayerSpawn", function(player)
	if G_IsRolloutGametype() and (player.mo and player.mo.valid) then
		player.powers[pw_nocontrol] = TICRATE/3
		local rheight = mobjinfo[MT_ROLLOUTROCK].height -- Rock Height
		P_TeleportMove(player.mo, player.mo.x, player.mo.y, player.mo.z + rheight + 5*FRACUNIT) -- Offset to be above the rock slightly
		player.mo.rock = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.floorz, MT_ROLLOUTROCK) -- Spawn rock on the player's current floorz
		player.mo.rock.target = player.mo -- Target the player that spawned you. See "MobjThinker"
		if not (mapheaderinfo[gamemap].rockfloat) then
			player.mo.rock.flags2 = $ | MF2_AMBUSH
		end
		player.mo.rock.colorized = true
	end
end)

addHook("PreThinkFrame", do
	for p in players.iterate
		if (p.weapondelay <= 2)
			p.weapondelay = 2 -- Do not fire rings. Ever.
		end
	end
end)

addHook("PlayerThink", function(player)
	if G_IsRolloutGametype() and (player.mo and player.mo.valid) then
		local cmd = player.cmd
		local mo = player.mo
		if player.powers[pw_carry] & CR_ROLLOUT then
			player.pflags = $ |PF_JUMPSTASIS
		end
		if player.powers[pw_nocontrol] == 0
		and not (player.powers[pw_carry] & CR_ROLLOUT) then
			P_DamageMobj(mo,nil,nil,1,DMG_INSTAKILL)
		end
		if mapheaderinfo[gamemap].airdrown then
			if mo.state == S_PLAY_DEAD then
				mo.state = S_PLAY_DRWN
				S_StartSound(mo,sfx_drown)
			end
		end
		
		if (cmd.buttons & BT_ATTACK) and not (player.pflags & PF_ATTACKDOWN) -- Pressing the attack button
			player.pflags = $ | PF_ATTACKDOWN
			--if (p.currentweapon == WEP_AUTO) -- Automatic Ring (Speed Burst) selected
			--and (p.ringweapons & RW_AUTO) -- Weapon ring able to be fired
			--and (p.powers[pw_automaticring] > 0) -- Player has Auto rings to spare?
			--and (p.weapondelay <= 4)
			if (player.weapondelay <= 4)
				-- Let's give your character a dashing ability
				--p.pflags = $ & ~PF_ATTACKDOWN -- Attack is repeatable
				if not player.powers[pw_flashing] and not player.powers[pw_sneakers] -- Just starting from a dash...
					player.powers[pw_flashing] = TICRATE/3
					S_StopSound(mo)
					--S_StartSound(mo, sfx_mswarp) -- Zoom!
					S_StartSound(mo, sfx_s3kb6) -- Spin Launch
				end
				player.powers[pw_sneakers] = TICRATE
				player.powers[pw_nocontrol] = TICRATE/2
				player.weapondelay = 3*TICRATE
				if mo.tracer and mo.tracer.valid
					P_InstaThrust(mo.tracer, mo.angle, player.normalspeed/2)
					P_SetObjectMomZ(mo.tracer, 5*FRACUNIT, true)
				else
					P_InstaThrust(mo, mo.angle, player.normalspeed/2)
					P_SetObjectMomZ(mo, 5*FRACUNIT, true)
				end
			end
		end
		
		
		if mo.tracer and mo.tracer.valid
		and not P_IsObjectOnGround(mo.tracer)
		and ((leveltime%3) == 0)
		and player.powers[pw_sneakers]
			P_SpawnGhostMobj(mo)
		end
	end
end)

addHook("MobjThinker", function(mo)
    if mo and mo.valid
    and G_IsRolloutGametype() then
		if mo.target and mo.target.valid then -- Valid target
			-- Last bumper for score calculation
			if mo.lastbumper and (mo.lastbumpertics > 0) then
				mo.lastbumpertics = $ - 1 -- Tic countdown timer
				if (mo.lastbumpertics == 1) then -- Last tic
					mo.lastbumper = nil -- Nil out your last bumper
				end
			end

			-- Set your color to your target
			if mo.colorized then
                mo.color = mo.target.color
            end
			
            if mo.standingslope -- On a slope
			and (mapheaderinfo[gamemap].slopefall) then
                local slope = mo.standingslope -- Simplify ourselves
                P_InstaThrust(mo, slope.xydirection, FRACUNIT*2) -- Push the rock down the slope
            end
        else -- Oops, your target dissappeared?
            P_RemoveMobj(mo) -- So should you!
            return
        end
    end
end, MT_ROLLOUTROCK)

addHook("MobjMoveCollide", function(tmthing, thing)
	if tmthing and tmthing.valid
	and thing and thing.valid then
		if (tmthing.z > (thing.z + thing.height)) -- No Z collision? Let's fix that!
		or ((tmthing.z + tmthing.height) < thing.z) then
			return -- Out of range
		end

		if (tmthing.type == MT_ROLLOUTROCK) and (thing.type == MT_ROLLOUTROCK) then
			local intensity = tmthing.momx + tmthing.momy
			P_StartQuake(intensity, 5)
			
			if tmthing.target and tmthing.target.valid then
				-- Collision! for points!
				thing.lastbumper = tmthing.target
				thing.lastbumpertics = 10 * TICRATE -- 10 second cooldown
			end

			-- This following bit may seem backwards, but it's not
			if (tmthing.eflags & MFE_VERTICALFLIP) then
				FreeSetZ(tmthing, thing.z + thing.height) -- Upside down 
			else
				FreeSetZ(tmthing, thing.z)
			end
		end
	end
end, MT_ROLLOUTROCK) -- Our tmthing

addHook("MobjRemoved", function(mobj)
	-- Check to see if the rock was removed right from underneath the player.
	-- Eg. Rock despawned but player still exists
	if G_IsRolloutGametype() then
		if mobj and mobj.valid -- Valid check
		and mobj.target -- Do you have a target?
		and mobj.target.player and mobj.target.player.valid then -- Is it a player?
			-- Poof goes the rock!
			local poof = P_SpawnMobj(mobj.x, mobj.y, mobj.z + FRACUNIT*32, MT_EXPLODE)
			P_SetMobjStateNF(poof, S_FBOMB_EXPL1)
			S_StartSound(poof, sfx_s3k4e)
			
			if mobj.lastbumper then
				P_DamageMobj(mobj.target,mobj,mobj.lastbumper,1,DMG_INSTAKILL) -- Kill your host
			else
				P_DamageMobj(mobj.target,nil,nil,1,DMG_INSTAKILL) -- Kill your host
			end
		end
    end
end, MT_ROLLOUTROCK)

addHook("MobjDeath", function(mo)
	-- Check to see if the player died before the rock despawned
	if G_IsRolloutGametype() then
		if mo and mo.valid
		and mo.player and mo.player.valid
		and mo.rock and mo.rock.valid -- Rock is still valid
			if mo.rock.lastbumper and mo.rock.lastbumper.valid -- Our last bumper is valid
			and mo.rock.lastbumper.player and mo.rock.lastbumper.player.valid then -- Our last bumper is a player
				P_AddPlayerScore(mo.rock.lastbumper.player, 100)
			end
			
			-- Poof goes the rock!
			local poof = P_SpawnMobj(mo.rock.x, mo.rock.y, mo.rock.z, MT_EXPLODE)
			P_SetMobjStateNF(poof, S_FBOMB_EXPL1)
			S_StartSound(poof, sfx_s3k4e)
			P_RemoveMobj(mo.rock) -- If the rock still exists, remove it
		end
	end
end, MT_PLAYER)

rawset(_G, "RolloutHudToggle", function()
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
end)
hud.add(RolloutHudToggle, "game")