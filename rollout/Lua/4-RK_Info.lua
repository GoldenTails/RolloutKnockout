--
-- RK_Info.Lua
-- Resource file for Mobj objects, states and sounds
-- 
--
-- Flame
--
-- Date: 3-21-21
--

mobjinfo[MT_ROLLOUTROCK].speed = 50*FRACUNIT

-- Lat'
SafeFreeslot("MT_DUMMY")
mobjinfo[MT_DUMMY] = {
	spawnstate = S_THOK,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	dispoffset = 32,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}

for i = 1, 3 do
	SafeFreeslot("S_AURA"..i)
end
SafeFreeslot("SPR_SUMN")
states[S_AURA1] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS30|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA2}
states[S_AURA2] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS60|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA3}
states[S_AURA3] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS80|FF_PAPERSPRITE, 5, nil, 0, 0, S_NULL}

SafeFreeslot("SPR_FRAG")
for i = 1, 5 do
	SafeFreeslot("S_FRAG"..i)
end
local trans = {TR_TRANS50, TR_TRANS60, TR_TRANS70, TR_TRANS80, TR_TRANS60}
for i = 0, 4 do
	states[S_FRAG1+i]	= {SPR_SUMN, (i+1)|FF_FULLBRIGHT|trans[i+1], 3, nil, 0, 0, i<3 and S_FRAG2+i or S_NULL}
end

SafeFreeslot("SPR_HURT")
for i = 0, 3
	SafeFreeslot("S_HURT"..i+1)
	states[S_HURT1+i] = {SPR_HURT, i|FF_FULLBRIGHT, 3, nil, 0, 0, (i<3) and S_HURT1+(i+1) or S_NULL}
end

-- Flame
SafeFreeslot("SPR_RXPL")
for i = 0, 19 do
	SafeFreeslot("S_RXPL"..i+1)
	states[S_RXPL1+i] = {SPR_RXPL, i|FF_FULLBRIGHT, 2, nil, 0, 0, (i<19) and S_RXPL1+(i+1) or S_NULL}
end

SafeFreeslot("SPR_NMBR")
for i = 1, 11 do -- 0 - 9 (10) and Percent
	SafeFreeslot("S_NMBR"..(i-1))
	states[S_NMBR0+(i-1)] = {SPR_NMBR, (i-1)|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}
end

-- [Impact]
SafeFreeslot("SPR_IPCT")
for i = 0, 9 do
	SafeFreeslot("S_IMPACT"..i+1)
	states[S_IMPACT1+i] = {SPR_IPCT, i|FF_FULLBRIGHT, (i==2) and 3 or 2, nil, 0, 0, (i<9) and S_IMPACT1+(i+1) or S_NULL}
end

-- Arrows!
SafeFreeslot("SPR_RKAW")
SafeFreeslot("S_RKAW1")
states[S_RKAW1] = {SPR_RKAW, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}

SafeFreeslot("MT_FSMOKE")
SafeFreeslot("SPR_SMKA", "SPR_SMKB", "SPR_SMKC", "SPR_SMKD", "SPR_SMKE")
SafeFreeslot("S_SMKA", "S_SMKB", "S_SMKC", "S_SMKD", "S_SMKE")
mobjinfo[MT_FSMOKE] = { -- Fancy Smoke
	spawnstate = S_SMKD,
	doomednum = 3204,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	dispoffset = 32,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}
-- Fancy smoke states. Yes... There are this many frames...
states[S_SMKA] = {SPR_SMKA, FF_ANIMATE, 27, nil, 27, 1, S_SMKB}
states[S_SMKB] = {SPR_SMKB, FF_ANIMATE, 27, nil, 27, 1, S_SMKC}
states[S_SMKC] = {SPR_SMKC, FF_ANIMATE, 27, nil, 27, 1, S_SMKD}
states[S_SMKD] = {SPR_SMKD, FF_ANIMATE, 27, nil, 27, 1, S_SMKE}
states[S_SMKE] = {SPR_SMKE, FF_ANIMATE, 27, nil, 27, 1, S_SMKA}
-- Random state upon spawn.
addHook("MobjSpawn", function(mo)
	mo.state = P_RandomRange(S_SMKA, S_SMKE)
end, MT_FSMOKE)

-- Item 'boxes'
SafeFreeslot("SPR_RKIB")
for i = 0, 1
	SafeFreeslot("S_RKITEMBOX"..i+1)
	states[S_RKITEMBOX1+i] = {SPR_RKIB, i|FF_FULLBRIGHT|FF_PAPERSPRITE, -1, nil, 0, 0, S_NULL}
end

-- Sounds
SafeFreeslot("sfx_pointu")
sfxinfo[sfx_pointu].caption = "Point up!"
SafeFreeslot("sfx_pplode")
sfxinfo[sfx_pplode].caption = "Player Explode"
SafeFreeslot("sfx_wwipe")
SafeFreeslot("sfx_whit")
SafeFreeslot("sfx_whitf")
 