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
freeslot("MT_DUMMY")
mobjinfo[MT_DUMMY] = {
	spawnstate = S_THOK,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	dispoffset = 32,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}

for i = 1, 3 do
	freeslot("S_AURA"..i)
end
freeslot("SPR_SUMN")
states[S_AURA1] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS30|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA2}
states[S_AURA2] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS60|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA3}
states[S_AURA3] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS80|FF_PAPERSPRITE, 5, nil, 0, 0, S_NULL}

freeslot("SPR_FRAG")
for i = 1, 5 do
	freeslot("S_FRAG"..i)
end
local trans = {TR_TRANS50, TR_TRANS60, TR_TRANS70, TR_TRANS80, TR_TRANS60}
for i = 0, 4 do
	states[S_FRAG1+i]	= {SPR_SUMN, (i+1)|FF_FULLBRIGHT|trans[i+1], 3, nil, 0, 0, i<3 and S_FRAG2+i or S_NULL}
end

freeslot("SPR_HURT")
for i = 0, 3
	freeslot("S_HURT"..i+1)
	states[S_HURT1+i] = {SPR_HURT, i|FF_FULLBRIGHT, 3, nil, 0, 0, (i<3) and S_HURT1+(i+1) or S_NULL}
end

-- Flame
freeslot("SPR_RXPL")
for i = 0, 19 do
	freeslot("S_RXPL"..i+1)
	states[S_RXPL1+i] = {SPR_RXPL, i|FF_FULLBRIGHT, 2, nil, 0, 0, (i<19) and S_RXPL1+(i+1) or S_NULL}
end

freeslot("SPR_NMBR")
for i = 1, 11 do -- 0 - 9 (10) and Percent
	freeslot("S_NMBR"..(i-1))
	states[S_NMBR0+(i-1)] = {SPR_NMBR, (i-1)|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}
end

-- [Impact]
freeslot("SPR_IPCT")
for i = 0, 3 do
	freeslot("S_IMPACT"..i+1)
	states[S_IMPACT1+i] = {SPR_IPCT, i|FF_FULLBRIGHT, 4, nil, 0, 0, (i<3) and S_IMPACT1+(i+1) or S_NULL}
end

-- Arrows!
freeslot("S_RKAW1")
freeslot("SPR_RKAW")
states[S_RKAW1] = {SPR_RKAW, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 2, nil, 0, 0, S_NULL}

-- Sounds
freeslot("sfx_pointu")
sfxinfo[sfx_pointu].caption = "Point up!"
freeslot("sfx_pplode")
sfxinfo[sfx_pplode].caption = "Player Explode"
freeslot("sfx_wwipe")
freeslot("sfx_whit")
freeslot("sfx_whitf")
 