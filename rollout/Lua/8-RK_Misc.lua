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
RK.hud.obj = {} -- Hud Object container
RK.hud.obj.t = {} -- Hud object table
RK.ptable = {} -- Player table container
RK.ptable.u = {} -- Player table (Unsorted)
RK.ptable.s = {} -- Player table (Sorted)

RK.hud.toggle = function()
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

RK.hud.obj.Think = function()
	for k, hobj in ipairs(RK.hud.obj.t) do
		if hobj.fuse and (hobj.fuse > 0) then
			hobj.fuse = $ - 1
			if (hobj.fuse == 1) then table.remove(RK.hud.obj.t, k) end
		end
	end
end

RK.hud.gameSET = function(v, p, ticker)
	local ghzpatch = v.cachePatch("HUDGHZW")
	local vsize = { x = v.width()/v.dupx(), y = v.height()/v.dupy() }
	local voffsset = { x = 0, y = vsize.y/2 - ghzpatch.height/2 }
	local vidflags = V_SNAPTOTOP|V_SNAPTOLEFT
	local txtgame, txtset = v.cachePatch("HUDGAME"), v.cachePatch("HUDSET")
	
	if (ticker == 2) then S_StartSound(nil, sfx_wwipe, p) end
	
	-- Black bars
	v.drawFill(0,0,vsize.x, (ticker*4 < vsize.y/5) and ticker*4 or vsize.y/5, 31|vidflags)
	v.drawFill(0,vsize.y - ((ticker*4 < vsize.y/5) and ticker*4 or vsize.y/5),vsize.x, vsize.y/5, 31|vidflags)
	
	-- White line
	v.drawFill(0,vsize.y/2 - (max(4, vsize.y/ticker))/2, vsize.x, max(4, vsize.y/ticker), vidflags)
	
	-- Text shake at >60 tics
	if (ticker > 50) then
		v.drawScaled((v.RandomRange(-1, 1) + vsize.x/2 - 17*ghzpatch.width/12)*FRACUNIT, 
					(v.RandomRange(-1, 1) + ghzpatch.height/4 + voffsset.y)*FRACUNIT,
					FRACUNIT, txtgame, vidflags)
		v.drawScaled((v.RandomRange(-1, 1) + vsize.x/2 + ghzpatch.width/4)*FRACUNIT, 
					(v.RandomRange(-1, 1) + ghzpatch.height/4 + voffsset.y)*FRACUNIT,
					FRACUNIT, txtset, vidflags)
	else -- Otherwise the text is covered by GFZFLR01
		v.drawScaled((vsize.x/2 - 17*ghzpatch.width/12)*FRACUNIT, 
					(ghzpatch.height/4 + voffsset.y)*FRACUNIT,
					FRACUNIT, txtgame, vidflags)
		v.drawScaled((vsize.x/2 + ghzpatch.width/4)*FRACUNIT, 
					(ghzpatch.height/4 + voffsset.y)*FRACUNIT,
					FRACUNIT, txtset, vidflags)

		for i = -2, 3, 1 do -- Width
			for j = 1, 2 do -- Height
				if (ticker > 20) then
					v.drawScaled((v.RandomRange(-1, 1) + vsize.x/2 + ((i-1)*ghzpatch.width/2))*FRACUNIT, 
								--(v.RandomRange(-1, 1) + vsize.y/3 + ((j-1)*ghzpatch.height/2))*FRACUNIT, 
								(v.RandomRange(-1, 1) + voffsset.y + ((j-1)*ghzpatch.height/2))*FRACUNIT, 
								FRACUNIT/2, ghzpatch, vidflags)
				else
					v.drawScaled((vsize.x/2 + ((i-1)*ghzpatch.width/2))*FRACUNIT, 
								--(vsize.y/3 + ((j-1)*ghzpatch.height/2))*FRACUNIT, 
								(voffsset.y + ((j-1)*ghzpatch.height/2))*FRACUNIT, 
								FRACUNIT/2, ghzpatch, vidflags)
				end
			end
		end
	end

	-- Let's get real fancy with this...
	if (ticker >= 20)
	and (ticker <= 44)
	and not ((ticker - 20)%6) then
		table.insert(RK.hud.obj.t, { x = vsize.x/2 + v.RandomRange((0-3)*ghzpatch.width/2, 3*ghzpatch.width/2),
						--y = vsize.y/3 + v.RandomRange(0, ghzpatch.height),
						y = voffsset.y + v.RandomRange(0, ghzpatch.height),
						patch = { v.getSpritePatch(SPR_HURT, A, 0),
								v.getSpritePatch(SPR_HURT, B, 0),
								v.getSpritePatch(SPR_HURT, C, 0),
								v.getSpritePatch(SPR_HURT, D, 0)
								},
						f = vidflags,
						c = v.getColormap(TC_DEFAULT, p.skincolor),
						fuse = 12})
		S_StartSound(nil, sfx_whit, p) -- Since our function triggers right after, no harm in calling a sound function here.
	end
	
	RK.hud.obj.Think()
	if (#RK.hud.obj.t > 0) then
		for _, hobj in ipairs(RK.hud.obj.t) do
			v.draw(hobj.x,hobj.y, hobj.patch[4-(hobj.fuse/3)], hobj.f, hobj.c)
		end
	end
	
	if (ticker > 50) then
		-- TODO: Something cooler other than flashing the screen white?
		-- Maybe Break this "wall" into pieces at some point.
		if (ticker == 51) then S_StartSound(nil, sfx_whitf, p) end
		if (ticker < 60) then
			v.fadeScreen(1, 60-ticker)
		end
	end
	
	if (ticker < 10) then v.fadeScreen(1, 10-ticker) end
end

RK.hud.game = function(v, p)
	RK.hud.toggle()
	if not v then return end
	if not p or not p.valid then return end
	if not G_IsRolloutGametype() then return end

	if not RK.game.exiting.var then
		local vsize = { x = v.width(), y = v.height() }
		local rkhud = { x = hudinfo[HUD_LIVES].x,
						y = hudinfo[HUD_LIVES].y,
						full = v.cachePatch("RKLA75"),
						high = v.cachePatch("RKLH"),
						med = v.cachePatch("RKLM"),
						low = v.cachePatch("RKLL")
						}
		local vflags = V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER
		if p.spectator then vflags = $|V_HUDTRANSHALF end
		local pname = p.name
		local mo = p.mo or p.realmo
		if not mo then return end -- Stop here if `mo` is not found
		local pface, pface2 = v.getSprite2Patch(mo.skin, SPR2_SIGN, 0, 0), v.getSprite2Patch(mo.skin, SPR2_LIFE, 0, 0) -- Get this player's icon!
		local pcolor = v.getColormap(TC_DEFAULT, p.skincolor)
		
		-- Trim the characters to a Max of 8 characters.
		if pname and (string.len(pname) >= 8) then pname = string.sub($, 1, 8) end

		-- Cooldown meter
		if (p.weapondelay-2 > 0)
			local cooldownPercentage = (((p.weapondelay-2) * 17) / 100)
			if (leveltime&1)
				v.drawFill(rkhud.x+39, rkhud.y+7, cooldownPercentage, 1, 178)
				v.drawFill(rkhud.x+38, rkhud.y+8, cooldownPercentage, 1, 178)
			else
				v.drawFill(rkhud.x+39, rkhud.y+7, cooldownPercentage, 1, 180)
				v.drawFill(rkhud.x+38, rkhud.y+8, cooldownPercentage, 1, 180)
			end
		end

		-- Player Hud Graphic
		v.draw(rkhud.x,
				rkhud.y - 8 ,
				rkhud.full,
				vflags, pcolor)

		-- Draw the Player Portrait
		v.drawScaled((rkhud.x+17)*FRACUNIT, 
					(rkhud.y+15)*FRACUNIT,
					3*FRACUNIT/4,
					pface, 
					vflags, pcolor)
		
		-- Stock icon
		if G_GametypeUsesLives() and (p.lives > 0)
			if (p.lives < 5) -- Lives count is less than 5
				for i = 0, p.lives-1 do
					v.drawScaled((rkhud.x + 43 + (i*11))*FRACUNIT, 
								(rkhud.y - 10)*FRACUNIT,
								FRACUNIT/2, 
								pface2, 
								vflags, pcolor)
				end
			else -- Lives count is 5 or more
				-- [icon] x 5
				v.drawScaled((rkhud.x + 43)*FRACUNIT, 
							(rkhud.y - 10)*FRACUNIT,
							FRACUNIT/2, 
							pface2, 
							vflags, pcolor)
				v.drawString((rkhud.x + 54),
							(rkhud.y - 12), "x", 
							vflags|V_ALLOWLOWERCASE, "small-right")
				v.drawString((rkhud.x + 56),
							(rkhud.y - 16), p.lives, 
							vflags|V_ALLOWLOWERCASE, "left")
			end
		end
		
		-- Rock Percentage or NaN
		if mo and mo.valid and mo.rock and mo.rock.valid
			local rkhrandtics = mo.rock.bumpcounttics and mo.rock.bumpcounttics/4 or 0
			local rkhrand = { x = (rkhrandtics > 0) and v.RandomRange(-1, 1) or 0, 
							y = (rkhrandtics > 0) and v.RandomRange(-1, 1) or 0 }
			v.drawString(rkhrand.x + rkhud.x + 60, rkhrand.y + rkhud.y - 4, mo.rock.percent, vflags, "right")
		else
			v.drawString(rkhud.x + 60, rkhud.y - 4, "NaN", vflags|V_ALLOWLOWERCASE, "right")
		end
		v.drawString(rkhud.x + 60, rkhud.y - 4, "%", vflags, "left") -- "Percent" character
		v.drawString(rkhud.x + 39, rkhud.y + 14, pname, vflags|V_YELLOWMAP|V_ALLOWLOWERCASE, "thin") -- Player Name
		if (p.weapondelay-2 > 0) and not (leveltime%2) then
			local text = "\x86"..G_TicsToSeconds(p.weapondelay-2).."."..G_TicsToCentiseconds(p.weapondelay-2)
			v.drawString(rkhud.x+43,rkhud.y+6,text,vflags|V_HUDTRANS,"small-thin")
		end
	else
		RK.hud.gameSET(v, p, RK.game.exiting.ticker)
	end
end

RK.hud.scores = function(v)
	if not v then return end
	if RK.game.exiting.var then return end
	
	if G_IsRolloutGametype() then
		hud.disable("rankings")
		
		local vsize = { x = (v.width()), y = (v.height()) }
		local offset = { x = vsize.x/13,
						xh = (vsize.x/13)/2,
						xh2 = ((vsize.x/13)/2) + (vsize.x/2)
						}
		local vflags = V_NOSCALESTART

		-- White Divider line
		v.drawFill(20, vsize.y/8, vsize.x-40, 4, vflags|SKINCOLOR_WHITE)
		
		-- Collect the current player userdata structures.
 		RK.ptable.u = {}
		for p in players.iterate do
			if G_GametypeUsesLives() then
				table.insert(RK.ptable.u, {p, p.lives})
			else
				table.insert(RK.ptable.u, {p, p.score})
			end
		end
		
		-- And sort those player userdata structures by score.
		RK.ptable.s = {}
		for k,v in spairs(RK.ptable.u, function(t,a,b) return t[b][2] < t[a][2] end) do
			--print(k, #v) -- Table length "v" is 2
			
			-- For ease of reading:
			-- v[1] is the player_t userdata structure
			-- v[2] is the score that was used for sorting this table. From High -> Low
			--print(k .. " - " .. v[1].name .. " - ".. v[2])
			table.insert(RK.ptable.s, v[1])
		end

		if (#RK.ptable.s <= 8) then
			-- Headers
			v.drawString(offset.x, vsize.y/12, "#", vflags|V_YELLOWMAP)
			v.drawString((offset.x + 136), vsize.y/12, "Name", vflags|V_YELLOWMAP)
			v.drawString(7*offset.x, vsize.y/12, "R. DMG", vflags|V_YELLOWMAP)
			if G_GametypeUsesLives() then
				v.drawString(10*offset.x, vsize.y/12, "Lives", vflags|V_YELLOWMAP) -- Lives count in STOCK
			else
				v.drawString(10*offset.x, vsize.y/12, "Score", vflags|V_YELLOWMAP) -- Score #
			end
		else
			-- Headers
			-- Left side
			v.drawString(offset.xh, vsize.y/12, "#", vflags|V_YELLOWMAP, "thin")
			v.drawString((offset.xh + 136), vsize.y/12, "Name", vflags|V_YELLOWMAP, "thin")
			v.drawString(7*offset.xh, vsize.y/12, "R. DMG", vflags|V_YELLOWMAP, "thin")
			if G_GametypeUsesLives() then
				v.drawString(10*offset.xh, vsize.y/12, "Lives", vflags|V_YELLOWMAP, "thin")
			else
				v.drawString(10*offset.xh, vsize.y/12, "Score", vflags|V_YELLOWMAP, "thin")
			end
			
			-- Right side
			v.drawString(offset.xh2, vsize.y/12, "#", vflags|V_YELLOWMAP, "thin")
			v.drawString((offset.xh2 + 136), vsize.y/12, "Name", vflags|V_YELLOWMAP, "thin")
			v.drawString(7*offset.xh + vsize.x/2, vsize.y/12, "R. DMG", vflags|V_YELLOWMAP, "thin")
			if G_GametypeUsesLives() then
				v.drawString(10*offset.xh + vsize.x/2, vsize.y/12, "Lives", vflags|V_YELLOWMAP, "thin") -- Lives count in STOCK
			else
				v.drawString(10*offset.xh + vsize.x/2, vsize.y/12, "Score", vflags|V_YELLOWMAP, "thin") -- Score #
			end
			-- White line divider
			v.drawFill(vsize.x/2, vsize.y/8, 4, vsize.y, vflags|SKINCOLOR_WHITE)
		end

		for i = 1, #RK.ptable.s do
			local p = RK.ptable.s[i] -- We've come full circle now.
			local mo = p.mo or p.realmo
			local pname = p.name
			local pface = v.getSprite2Patch(mo.skin, SPR2_XTRA, 0, 0) -- Get this player's icon!
			local pcolor = v.getColormap(TC_DEFAULT, p.skincolor)
			
			-- Trim the characters to a Max of 12 characters.
			if pname and (string.len(pname) >= 12) then pname = string.sub($, 1, 12) end

			if (#RK.ptable.s <= 8) then -- Less than 8 players
				v.drawString(offset.x, vsize.y/6 + (i-1)*70, i, vflags) -- Player node number
				if p.spectator or (p.playerstate == PST_DEAD) then
					v.drawScaled((offset.x + 64)*FRACUNIT, 
									(vsize.y/7 + (i-1)*70)*FRACUNIT, 
									FRACUNIT/2, pface,
									V_50TRANS|vflags, pcolor) -- Player Portrait w/ current player color (Transparent)
				else
					v.drawScaled((offset.x + 64)*FRACUNIT, 
									(vsize.y/7 + (i-1)*70)*FRACUNIT, 
									FRACUNIT/2, pface,
									vflags, pcolor) -- Player Portrait w/ current player color
				end
				v.drawString(offset.x + 136, vsize.y/6 + (i-1)*70, pname, vflags|V_ALLOWLOWERCASE) -- Player Name
				if mo.rock and mo.rock.valid then
					v.drawString(8*offset.x + offset.xh, vsize.y/6 + (i-1)*70, p.mo.rock.percent.."%", vflags, "right") -- Rock Damage
				else
					v.drawString(8*offset.x + offset.xh, vsize.y/6 + (i-1)*70, "NaN".."%", vflags|V_ALLOWLOWERCASE, "right") -- Rock Damage
				end

				-- Gametype differences
				if G_GametypeUsesLives() then
					v.drawString(11*offset.x + offset.xh, vsize.y/6 + (i-1)*70, p.lives, vflags, "right") -- Lives count in STOCK
				else
					v.drawString(11*offset.x + offset.xh, vsize.y/6 + (i-1)*70, p.score, vflags, "right") -- Score #
				end
				
			else -- More than 8 players
				if (i <= 8) then
					v.drawString(offset.xh, vsize.y/6 + (i-1)*70, i, vflags, "thin") -- Player node number
					if p.spectator or (p.playerstate == PST_DEAD) then
						v.drawScaled((offset.xh + 64)*FRACUNIT, 
										(vsize.y/7 + 8 + (i-1)*70)*FRACUNIT, 
										FRACUNIT/3, pface,
										V_50TRANS|vflags, pcolor) -- Player Portrait w/ current player color (Transparent)
					else
						v.drawScaled((offset.xh + 64)*FRACUNIT, 
										(vsize.y/7 + 8 + (i-1)*70)*FRACUNIT, 
										FRACUNIT/3, pface,
										vflags, pcolor) -- Player Portrait w/ current player color
					end
					v.drawString(offset.xh + 136, vsize.y/6 + (i-1)*70, pname, vflags|V_ALLOWLOWERCASE, "thin") -- Player Name
					if mo.rock and mo.rock.valid then
						v.drawString((9*offset.x)/2, vsize.y/6 + (i-1)*70, p.mo.rock.percent.."%", vflags, "thin-right") -- Rock Damage
					else
						v.drawString((9*offset.x)/2, vsize.y/6 + (i-1)*70, "NaN".."%", vflags|V_ALLOWLOWERCASE, "thin-right") -- Rock Damage
					end

					-- Gametype differences
					if G_GametypeUsesLives() then
						v.drawString(11*offset.xh + offset.x/4, vsize.y/6 + (i-1)*70, p.lives, vflags, "thin-right") -- Lives count in STOCK
					else
						v.drawString(11*offset.xh + offset.x/4, vsize.y/6 + (i-1)*70, p.score, vflags, "thin-right") -- Score #
					end
				elseif (i <= 16) then
					v.drawString(offset.xh2, vsize.y/6 + (i-9)*70, i, vflags, "thin") -- Player node number
					if p.spectator or (p.playerstate == PST_DEAD) then
						v.drawScaled((offset.xh2 + 64)*FRACUNIT, 
										(vsize.y/7 + 8 + (i-9)*70)*FRACUNIT, 
										FRACUNIT/3, pface,
										V_50TRANS|vflags, pcolor) -- Player Portrait w/ current player color (Transparent)
					else
						v.drawScaled((offset.xh2 + 64)*FRACUNIT, 
										(vsize.y/7 + 8 + (i-9)*70)*FRACUNIT, 
										FRACUNIT/3, pface,
										vflags, pcolor) -- Player Portrait w/ current player color
					end
					v.drawString(offset.xh2 + 136, vsize.y/6 + (i-9)*70, pname, vflags|V_ALLOWLOWERCASE, "thin") -- Player Name
					if mo.rock and mo.rock.valid then
						v.drawString((9*offset.x)/2 + vsize.x/2, vsize.y/6 + (i-9)*70, p.mo.rock.percent.."%", vflags, "thin-right") -- Rock Damage
					else
						v.drawString((9*offset.x)/2 + vsize.x/2, vsize.y/6 + (i-9)*70, "NaN".."%", vflags|V_ALLOWLOWERCASE, "thin-right") -- Rock Damage
					end
					
					-- Gametype differences
					if G_GametypeUsesLives() then
						v.drawString(11*offset.xh + offset.x/4 + vsize.x/2, vsize.y/6 + (i-9)*70, p.lives, vflags, "thin-right") -- Lives count in STOCK
					else
						v.drawString(11*offset.xh + offset.x/4 + vsize.x/2, vsize.y/6 + (i-9)*70, p.score, vflags, "thin-right") -- Score #
					end
				end
			end
		end

		v.drawString(5,(95*vsize.y)/100,RK.gt[G_GetCurrentRKGametype()].name, vflags) -- Gamemode name
	else
		hud.enable("rankings")
	end
end

hud.add(RK.hud.game, "game")
hud.add(RK.hud.scores, "scores")