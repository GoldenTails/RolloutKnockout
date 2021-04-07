--
-- RK_Globals.Lua
-- Resource file for tables and functionsto be used throughout the Lua code.
-- 
-- Flame
--
-- Date: 3-21-21
--
rawset(_G, "RK", {}) -- Start the Rollout Knockout Global Table
rawset(_G, "INFLIVES", 0x7F) -- From SRB2 Source

RK.WepRings = 0 -- Change to 1 to experiment with EXPERIMENTAL weapon ring abilities

-- Collision detect for objects (Z)
-- Kaysakado
-- "The issue with getting around SRB2's P_CheckPosition is that the floorz won't properly be updated"
rawset(_G, "FreeSetZ", function(mo, newz)
    local clip = (mo.flags & MF_NOCLIPTHING) ^^ MF_NOCLIPTHING

    mo.flags = $ | clip
    mo.z = newz
    mo.flags = $ & ~clip
end)

rawset(_G, "createFlags", function(tname, t)
    for i = 1,#t do
		rawset(_G, t[i], 2^(i-1))
		table.insert(tname, {string = t[i], value = 2^(i-1)} )
    end
end)

rawset(_G, "createEnum", function(tname, t, from)
    if from == nil then from = 0 end
    for i = 1,#t do
		rawset(_G, t[i], from+(i-1))
		table.insert(tname, {string = t[i], value = from+(i-1)} )
    end
end)

