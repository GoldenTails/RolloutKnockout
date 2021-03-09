freeslot(
"TOL_ROLLOUT"--,
--"TOL_ROLLOUTRACE"
)

freeslot("sfx_pointu")
sfxinfo[sfx_pointu].caption = "Point up!"

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

-- Lat'
freeslot("MT_DUMMY")
for i = 1, 3
	freeslot("S_AURA"..i)
end
freeslot("SPR_SUMN")

mobjinfo[MT_DUMMY] = {
	spawnstate = S_THOK,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	dispoffset = 32,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}

states[S_AURA1] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS30|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA2}
states[S_AURA2] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS60|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA3}
states[S_AURA3] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS80|FF_PAPERSPRITE, 5, nil, 0, 0, S_NULL}

freeslot("SPR_FRAG")
for i = 1, 5
	freeslot("S_FRAG"..i)
end
local trans = {TR_TRANS50, TR_TRANS60, TR_TRANS70, TR_TRANS80, TR_TRANS60}
for i = 0,4
	states[S_FRAG1+i]	= {SPR_SUMN, (i+1)|FF_FULLBRIGHT|trans[i+1], 3, nil, 0, 0, i<3 and S_FRAG2+i or S_NULL}
end

rawset(_G, "spawnAura", function(mo, color)	-- spawn a aura around mo
	if leveltime%2 then return end
	if not mo or not mo.valid then return end
	color = $ or SKINCOLOR_TEAL
	local baseangle = P_RandomRange(1, 360)*ANG1
	local dist = 30
	for i = 0, 12
		local angle = baseangle + i*6*ANG1
		local x, y = mo.x + dist*cos(angle), mo.y + dist*sin(angle)

		local aura = P_SpawnMobj(x, y, mo.z + mo.height/4 + i*FRACUNIT*3, MT_DUMMY)
		--if not aura or not aura.valid continue end
		aura.state = S_AURA1
		aura.angle = angle - ANGLE_90
		aura.color = color
		aura.momz = P_RandomRange(2, 5)*FRACUNIT
		aura.scale = FRACUNIT/2
		aura.destscale = FRACUNIT
		P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(1, 3))
	end

	local zoffs = mo.eflags & MFE_VERTICALFLIP and -65*mo.scale or 0
	for i = 1, 8
		local wf = 32
		local hf = P_RandomRange(65, 1)*mo.scale*P_MobjFlip(mo)
		local x, y, z = mo.x + P_RandomRange(-wf, wf)*mo.scale, mo.y + P_RandomRange(-wf, wf)*mo.scale, mo.z + zoffs + hf
		local t = P_SpawnMobj(x, y, z, MT_DUMMY)
		t.color = color or SKINCOLOR_TEAL
		t.eflags = mo.eflags & MFE_VERTICALFLIP
		t.flags2 = mo.flags2 & MF2_OBJECTFLIP
		t.state = i==7 and S_FRAG5 or S_FRAG1
		P_SetObjectMomZ(t, P_RandomRange(4, 12)*FRACUNIT)
		t.scale = mo.scale*2
		t.destscale = 1
		t.scalespeed = mo.scale/24
	end
end)

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
		if (p.weapondelay <= 2) then
			p.weapondelay = 2 -- Do not fire rings. Ever.
		end
	end
end)

addHook("PlayerThink", function(player)
	if G_IsRolloutGametype()
	and (player.mo and player.mo.valid) 
	and player.playerstate ~= PST_DEAD then
		local cmd = player.cmd
		local mo = player.mo
		
		-- On the rock?
		if (player.powers[pw_carry] & CR_ROLLOUT) then
			player.pflags = $|PF_JUMPSTASIS -- NO JUMP
		end
		
		if not player.powers[pw_nocontrol] -- Have control?
		and not (player.powers[pw_carry] & CR_ROLLOUT) then -- Not on the rock?
			P_DamageMobj(mo,nil,nil,1,DMG_INSTAKILL) -- Die
		end
				
		if mapheaderinfo[gamemap].airdrown
		and mo.state == S_PLAY_DEAD then
			mo.state = S_PLAY_DRWN
			S_StartSound(mo,sfx_drown)
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
				if mo.rock and mo.rock.valid
					P_InstaThrust(mo.rock, mo.angle, player.normalspeed/2)
					P_SetObjectMomZ(mo.rock, 5*FRACUNIT, true)
				else
					P_InstaThrust(mo, mo.angle, player.normalspeed/2)
					P_SetObjectMomZ(mo, 5*FRACUNIT, true)
				end
			end
		end
		
		if mo.rock and mo.rock.valid
		and not P_IsObjectOnGround(mo.rock)
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
			
			/*-- Did your target player suddenly die?
			if mo.target.player and mo.target.player.valid
			and (mo.target.player.playerstate == PST_DEAD) then
				P_RemoveMobj(mo) -- So should you!
				return
			end*/
        else -- Oops, your target dissappeared?
			P_RemoveMobj(mo) -- So should you!
			return
        end
		
		if mo.fxtimer and (mo.fxtimer > 0) then
			mo.fxtimer = $ - 1
			spawnAura(mo, mo.color)
		end
    end
end, MT_ROLLOUTROCK)

addHook("MobjThinker", function(mo)
    if mo and mo.valid
    and G_IsRolloutGametype() 
	and (mo.state == S_NIGHTSCORE100) then
		mo.color = (leveltime%69) -- NICE
		if (mo.fuse < TICRATE)
			mo.flags2 = $ ^^ MF2_DONTDRAW
		end
	end
end, MT_DUMMY)

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
			
			-- Your host is already dead". Eg. Your host died before you.
			if (mobj.target.player.playerstate == PST_DEAD) then 
				if mobj.lastbumper and mobj.lastbumper.valid
				and mobj.lastbumper.player 
				and mobj.lastbumper.player.valid then -- Validity check
					-- There would be occurances where your host dies before the rock disappears, and no points for score are awarded
					-- This 'hopefully' fixes that.
					P_AddPlayerScore(mobj.lastbumper.player, 100)
					mobj.lastbumper.rock.fxtimer = 3*TICRATE/2
					S_StartSound(mobj.lastbumper.rock, sfx_pointu)
					
					local dummy = P_SpawnMobj(mobj.lastbumper.rock.x, 
												mobj.lastbumper.rock.y, 
												mobj.lastbumper.rock.height/2 + mobj.lastbumper.rock.z, 
												MT_DUMMY)
					P_SetMobjStateNF(dummy, S_NIGHTSCORE100)
					P_SetObjectMomZ(dummy, FRACUNIT, false)
					dummy.fuse = 3*TICRATE
					dummy.scalespeed = FRACUNIT/25
					dummy.destscale = 2*FRACUNIT
				end
			else -- You died before your host.
				if mobj.lastbumper and mobj.lastbumper.valid then
					P_DamageMobj(mobj.target,mobj.lastbumper.rock,mobj.lastbumper,1,DMG_INSTAKILL) -- Kill your host
					mobj.lastbumper.rock.fxtimer = 3*TICRATE/2
					S_StartSound(mobj.lastbumper.rock, sfx_pointu)
					
					local dummy = P_SpawnMobj(mobj.lastbumper.rock.x, 
												mobj.lastbumper.rock.y, 
												mobj.lastbumper.rock.height/2 + mobj.lastbumper.rock.z, 
												MT_DUMMY)
					P_SetMobjStateNF(dummy, S_NIGHTSCORE100)
					P_SetObjectMomZ(dummy, FRACUNIT, false)
					dummy.fuse = 3*TICRATE
					dummy.scalespeed = FRACUNIT/25
					dummy.destscale = 2*FRACUNIT
				else
					P_DamageMobj(mobj.target,nil,nil,1,DMG_INSTAKILL) -- Kill your host
				end
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