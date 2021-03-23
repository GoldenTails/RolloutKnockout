--
-- RK_Mobj.Lua
-- Resource file Mobj-specific functions and behavior
-- 
-- 
-- Flame
--
-- Date: 3-21-21
--

RK.mobj = {}

-- Lat'
RK.mobj.spawnAura = function(mo, color)	-- spawn a aura around mo
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
end

RK.mobj.SpawnArrow = function(mo, target, dist)
	-- Need both a source 'mo' and a target 'mo'
	if not mo or not mo.valid then return end
	if not target or not target.valid then return end
	
	local arw = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
	arw.state = S_RKAW1
	arw.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y) + ANGLE_180
	arw.target = mo
	arw.color = target.color or SKINCOLOR_GREEN -- Opponent's color
	-- Fancy maths. Ensure your papersprite angle points towards your opponent.
	local ft = FixedAngle((leveltime%45)*(8*FRACUNIT))
	P_TeleportMove(arw, mo.x + FixedMul(cos(arw.angle-ANGLE_180), 3*mo.radius + FixedMul(sin(ft), 4*FRACUNIT)),
						mo.y + FixedMul(sin(arw.angle-ANGLE_180), 3*mo.radius + FixedMul(sin(ft), 4*FRACUNIT)),
						mo.z + mo.height/2)

	-- Some more fancy maths. Grow/shrink according to your target's distance
	arw.scale = FixedDiv(FixedMul(FRACUNIT, dist), R_PointToDist2(mo.x, mo.y, target.x, target.y))/2
end

-- Search for other player objects around 'mo' and return the count.
-- Because I hate 'searchBlockmap'
-- Flame
/*RK.mobj.CountPlayersInRadius = function(mo, dist)
	local pcount = 0
	if not mo or not mo.valid then return pcount end
	for p in players.iterate do
		if p.spectator then continue end -- We're a spectator. Skip.
		if (p.playerstate ~= PST_LIVE) continue end -- Skip anyone not alive
		if not p.mo then continue end -- Not a mo object. Skip.
		if not p.mo.rock or not p.mo.rock.valid then continue end -- No rock to reference. Skip.
		if (p.mo.rock == mo) then continue end -- Our rock? Skip us
		if (FixedHypot(FixedHypot(p.mo.x - mo.x, p.mo.y - mo.y), 
									p.mo.z - mo.z) > dist) then
			continue -- Out of range
		end
		pcount = $ + 1
	end
	return pcount
end*/


RK.mobj.SearchForPlayersInRadius = function(mo, dist, avar)
	if not avar then return end -- Now arrows to display, stop here!
	if not mo or not mo.valid then return end
	
	local closestmo = nil
	local closestdist = dist -- Maximum possible distance to search.
	if (avar == 2) then -- Spawn arrows for all players around you
		for p in players.iterate
			if p.spectator then continue end -- We're a spectator. Skip.
			if (p.playerstate ~= PST_LIVE) continue end -- Skip anyone not alive
			if not p.mo then continue end -- Not a mo object. Skip.
			if not p.mo.rock or not p.mo.rock.valid then continue end -- No rock to reference. Skip.
			if (p.mo.rock == mo) then continue end -- Our rock? Skip us
			
			local idist = FixedHypot(FixedHypot(p.mo.rock.x - mo.x, p.mo.rock.y - mo.y), p.mo.rock.z - mo.z)
			if (idist < 8*mo.radius) then
				continue -- TOO CLOSE!!
			end
			
			RK.mobj.SpawnArrow(mo, p.mo, dist)
		end
	elseif (avar == 1) then -- Spawn arrows for the closest player seen
		for p in players.iterate
			if p.spectator then continue end -- We're a spectator. Skip.
			if (p.playerstate ~= PST_LIVE) continue end -- Skip anyone not alive
			if not p.mo then continue end -- Not a mo object. Skip.
			if not p.mo.rock or not p.mo.rock.valid then continue end -- No rock to reference. Skip.
			if (p.mo.rock == mo) then continue end -- Our rock? Skip us
			
			local idist = FixedHypot(FixedHypot(p.mo.rock.x - mo.x, p.mo.rock.y - mo.y), p.mo.rock.z - mo.z)
			if (idist < 8*mo.radius) then
				return -- TOO CLOSE!! (Don't process anything else)
			end
			
			if (idist < closestdist) then -- There's a mobj that's closer?
				closestmo = p.mo -- Then we're the real closest player mobj!
				closestdist = idist
			end
		end
		
		if closestmo then
			RK.mobj.SpawnArrow(mo, closestmo, dist)
		end
	end
end

addHook("MobjThinker", function(mo)
    if mo and mo.valid
    and G_IsRolloutGametype() then
		if mo.target and mo.target.valid then -- Valid target
			-- Did your target player suddenly die?
			if mo.target.player and mo.target.player.valid
			and (mo.target.player.playerstate == PST_DEAD) then
				P_RemoveMobj(mo) -- So should you!
				return
			end
			
			-- Your ball is colored!
			if mo.colorized then
				-- If you have a lastbumper, set your color to your lastbumper for a bit!
				if mo.lastbumper and mo.lastbumper.valid
				and (mo.lastbumpertics > 9*TICRATE)
				and not (leveltime%2) then
					mo.color = mo.lastbumper.color
				else
					-- Otherwise, set your color to your target
					mo.color = mo.target.color
				end
			end
			
			-- Rock Ability stuff
			if mo.rkabilitytics and (mo.rkabilitytics > 0) then
				mo.rkabilitytics = $ - 1 -- Decrease each tic
				if RK.WepRings -- Weapon rings are enabled
				and mo.rkability then
					if (mo.rkability == WEP_RAIL) then
						mo.extravalue1 = $ or 0
						mo.extravalue2 = $ or 0
						mo.extravalue1 = $ + ANGLE_11hh
						mo.extravalue2 = mo.extravalue1 + ANGLE_180
						
						--if ((leveltime%2) == 0)
							local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
							trail.color = SKINCOLOR_WHITE
							trail.tics = 2*TICRATE
							trail.scale = 2*FRACUNIT
							trail.destscale = FRACUNIT/16
							trail.scalespeed = trail.scale/TICRATE
						--end
						
						local orb1 = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
						orb1.color = mo.color or SKINCOLOR_RED
						orb1.angle = mo.extravalue1
						P_TeleportMove(orb1, 
										mo.x + FixedMul(cos(orb1.angle), 3*mo.radius/2), 
										mo.y + FixedMul(sin(orb1.angle), 3*mo.radius/2), 
										mo.z + mo.height/2)
						orb1.fuse = TICRATE/3
						orb1.destscale = FRACUNIT/16
						orb1.scalespeed = (FRACUNIT/5)
						
						local orb2 = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
						orb2.color = mo.color or SKINCOLOR_RED
						orb2.angle = mo.extravalue2
						P_TeleportMove(orb2, 
										mo.x + FixedMul(cos(orb2.angle), 3*mo.radius/2), 
										mo.y + FixedMul(sin(orb2.angle), 3*mo.radius/2), 
										mo.z + mo.height/2)
						orb2.fuse = orb1.fuse
						orb2.destscale = orb1.destscale
						orb2.scalespeed = orb1.scalespeed
					end
				else
					if not P_IsObjectOnGround(mo) and ((leveltime%3) == 0) then P_SpawnGhostMobj(mo) end -- Default dashing.
				end
			else
				mo.rkability = 0
				mo.rkabilitytics = 0
			end
        else -- Oops, your target dissappeared?
			P_RemoveMobj(mo) -- So should you!
			return
        end
		
		-- Last bumper for score calculation
		if mo.lastbumper and mo.lastbumper.valid -- Validity check
		and (mo.lastbumpertics > 0) then
			mo.lastbumpertics = $ - 1
			if (mo.lastbumpertics == 1) then -- Last tic
				mo.lastbumper = nil -- Nil out your last bumper
			end
		else -- mo.lastbumper not valid
			mo.lastbumpertics = 0
			mo.lastbumper = nil -- Nil out your last bumper
		end

		-- Bump count for Player Respawning
		mo.bumpcount = $ or 0
		if mo.bumpcount and (mo.bumpcounttics > 0) then
			mo.bumpcounttics = $ - 1
			if (mo.bumpcounttics == 1) then -- Last tic
				mo.bumpcount = 0 -- Reset the bump count
			end
		end
		
		if mo.fxtimer and (mo.fxtimer > 0) then
			mo.fxtimer = $ - 1
			RK.mobj.spawnAura(mo, mo.target.color)
		end
		
		RK.mobj.SearchForPlayersInRadius(mo, 512*FRACUNIT, RK.cons.Arrows.value)
    end
end, MT_ROLLOUTROCK)

-- Score object
addHook("MobjThinker", function(mo)
    if mo and mo.valid
    and G_IsRolloutGametype() 
	and (mo.state == S_NIGHTSCORE100) then
		mo.color = (leveltime%69) -- NICE
		if (mo.fuse < TICRATE) then mo.flags2 = $ ^^ MF2_DONTDRAW end
	end
end, MT_DUMMY)

-- Rock v rock
addHook("MobjCollide", function(thing, tmthing)
	if thing and thing.valid
	and tmthing and tmthing.valid then
		if (thing.z > (tmthing.z + tmthing.height)) -- No Z collision? Let's fix that!
		or ((thing.z + thing.height) < tmthing.z) then
			return -- Out of range
		end
		
		if (thing.type == MT_ROLLOUTROCK) and (tmthing.type == MT_ROLLOUTROCK) then
			thing.bumpcount = $ + 1
			thing.bumpcounttics = TICRATE/2
		end
	end
end, MT_ROLLOUTROCK)

-- Moving rock v rock
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
				thing.lastbumpertics = 10*TICRATE -- 10 second cooldown
			end

			local impact = P_SpawnMobj((tmthing.x + thing.x)/2,
										(tmthing.y + thing.y)/2,
										((tmthing.z + tmthing.height/2) + (thing.z + thing.height/2))/2,
										MT_DUMMY)
			impact.state = S_IMPACT1

			-- This following bit may seem backwards, but it's not
			if (tmthing.eflags & MFE_VERTICALFLIP) then
				FreeSetZ(tmthing, thing.z + thing.height) -- Upside down 
			else
				FreeSetZ(tmthing, thing.z)
			end
			
			-- If I need to play around with the collision intensity... this works...
			--thing.momx = 2*tmthing.momx
			--thing.momy = 2*tmthing.momy
			--return true
		end
	end
end, MT_ROLLOUTROCK) -- Our tmthing

-- Rock removed
addHook("MobjRemoved", function(mobj)
	if G_IsRolloutGametype() then
		if mobj and mobj.valid -- Valid check
		and mobj.target -- Do you have a target?
		and mobj.target.player and mobj.target.player.valid then -- Is it a player?
			-- Poof goes the rock!
			local poof = P_SpawnMobj(mobj.x, mobj.y, mobj.z + FRACUNIT*32, MT_EXPLODE)
			P_SetMobjStateNF(poof, S_FBOMB_EXPL1)
			S_StartSound(poof, sfx_s3k4e)
			
			-- Your host is already dead. Eg. Your host died before you.
			if (mobj.target.player.playerstate == PST_DEAD) then 
				if mobj.lastbumper and mobj.lastbumper.valid
				and mobj.lastbumper.player and mobj.lastbumper.player.valid then -- Validity check
					-- There would be occurances where your host dies before the rock disappears, and no points for score are awarded
					-- This 'hopefully' fixes that.
					--print("Player died before the Rock despawned!")
					P_AddPlayerScore(mobj.lastbumper.player, 100)
					if mobj.lastbumper.rock and mobj.lastbumper.rock.valid then
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
				end
			else -- You died before your host.
				if mobj.lastbumper and mobj.lastbumper.valid
				and mobj.lastbumper.rock and mobj.lastbumper.rock.valid then
					--print("Rock died before the player! Killing player!")
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
				elseif mobj.lastbumper and mobj.lastbumper.valid then
					-- Goto: HURTMSG Hook for this
					P_DamageMobj(mobj.target,mobj.lastbumper,mobj.lastbumper,1,DMG_INSTAKILL) -- Kill your host
				else
					P_DamageMobj(mobj.target,nil,nil,1,DMG_INSTAKILL) -- Kill your host
				end
			end
		end
    end
end, MT_ROLLOUTROCK)