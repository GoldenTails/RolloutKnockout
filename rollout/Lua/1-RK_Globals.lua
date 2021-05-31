--
-- RK_Globals.Lua
-- Resource file for tables and functionsto be used throughout the Lua code.
-- 
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

rawset(_G, "spairs", function(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end)

rawset(_G, "FixedRemap", function(up1, low1, up2, low2, n)
    return up2 + FixedDiv(FixedMul(n-up1, low2-up2),low1-up1)
end)

-- From Bomberman
-- Eases from 'a' to 'b', with time value 't' being from 0 to 'tmax'
-- Thanks to SwitchKaze for the original code
rawset(_G, "cosEase", function(a, b, t, tmax)
	local F = FRACUNIT
    local ang = FixedAngle(FixedRemap(0,tmax*F,0,180*F,t*F))
    local fac = -cos(ang)+F
    return FixedRemap(0, F*2, a, b, fac)
end)