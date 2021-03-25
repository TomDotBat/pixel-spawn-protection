
local corner1, corner2 = Vector(-10284, 10948, -3004), Vector(-11506, 9924, -2440) --Spawn area config
local corner3, corner4 = Vector(-9927, 10092, -30044), Vector(-10370, 10780, -2820)
local verificationFrequency = 2

--Set the isInSpawn metamethods
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

local function isSelfInSpawn(s, verify)
    if verify then
        local inSpawn = s:GetPos():WithinAABox(corner1, corner2) or s:GetPos():WithinAABox(corner3, corner4)
        s.PIXELIsInSpawn = inSpawn

        if not inSpawn then return inSpawn end --If they're in spawn we should create the serverside verification timer

        local ident = "PIXEL.SpawnProtection.AreaCheck:" .. s:SteamID64()
        timer.Create(ident, verificationFrequency, 0, function() --Serverside verify every x seconds
            if not IsValid(s) then
                timer.Remove(ident)
                return
            end

            if not isSelfInSpawn(s, true) then --They're no longer in spawn so we've changed the state manually and removed the timer
                timer.Remove(ident)
            end
        end)
    end

    return s.PIXELIsInSpawn
end

plyMeta.IsInSpawn = isSelfInSpawn
entMeta.IsInSpawn = isSelfInSpawn

--Spawn state checking
hook.Add("PlayerSpawn", "PIXEL.SpawnProtection.ResetState", function(ply, attacker)
    timer.Simple(0, function() --Wait 1 tick to check their pos and update their inSpawn state
        if not IsValid(ply) then return end
        isSelfInSpawn(ply, true)
    end)
end)

net.Receive("PIXEL.SpawnProtection.UpdateSpawnState", function(len, ply) isSelfInSpawn(ply, true) end) --Update the spawn state as requested
util.AddNetworkString("PIXEL.SpawnProtection.UpdateSpawnState")

--Disable sandbox/damage in spawn
local function falseInSpawn(ply)
    if ply.PIXELIsInSpawn then return false end
end

hook.Add("PlayerSpawnProp", "PIXEL.SpawnProtection.DisableSpawning", falseInSpawn)
hook.Add("PhysgunPickup", "PIXEL.SpawnProtection.DisablePhysgun", falseInSpawn)
hook.Add("CanTool", "PIXEL.SpawnProtection.DisableToolgun", falseInSpawn)

hook.Add("PlayerShouldTakeDamage", "PIXEL.SpawnProtection.DisableDamage", function(ply, attacker)
    if ply.PIXELIsInSpawn or attacker.PIXELIsInSpawn then return false end
end)
