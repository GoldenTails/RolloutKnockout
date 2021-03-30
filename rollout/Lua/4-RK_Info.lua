--
-- RK_Info.Lua
-- Resource file for Mobj objects, states and sounds
-- 
-- Flame
--
-- Date: 3-21-21
--

mobjinfo[MT_ROLLOUTROCK].speed = 50*FRACUNIT

-- Lat'
freeslot("MT_DUMMY")
mobjinfo[MT_DUMMY] = {
	spawnstate = S_THOK,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	dispoffset = 32,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}

freeslot("SPR_NMBR")
for i = 1, 11 -- 0 - 9 (10) and Percent
	freeslot("S_NMBR"..(i-1))
	states[S_NMBR0+(i-1)] = {SPR_NMBR, (i-1)|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}
end

for i = 1, 3
	freeslot("S_AURA"..i)
end
freeslot("SPR_SUMN")
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

-- [Impact]
for i = 1, 4
	freeslot("S_IMPACT"..i)
end
freeslot("SPR_IPCT")
states[S_IMPACT1] = {SPR_IPCT, A|FF_FULLBRIGHT, 3, nil, 0, 0, S_IMPACT2}
states[S_IMPACT2] = {SPR_IPCT, B|FF_FULLBRIGHT, 3, nil, 0, 0, S_IMPACT3}
states[S_IMPACT3] = {SPR_IPCT, C|FF_FULLBRIGHT, 3, nil, 0, 0, S_IMPACT4}
states[S_IMPACT4] = {SPR_IPCT, D|FF_FULLBRIGHT, 3, nil, 0, 0, S_NULL}

-- Arrows!
freeslot("S_RKAW1")
freeslot("SPR_RKAW")
states[S_RKAW1] = {SPR_RKAW, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}

-- Sounds
freeslot("sfx_pointu")
sfxinfo[sfx_pointu].caption = "Point up!"
 