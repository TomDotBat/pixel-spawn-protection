
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

local corner1, corner2 = Vector(3665, 1368, -196), Vector(2920, 498, 168)
local function isSelfInSpawn(s)
    return s:GetPos():WithinAABox(corner1, corner2)
end

plyMeta.IsInSpawn = isSelfInSpawn
entMeta.IsInSpawn = isSelfInSpawn

local function falseInSpawn(ply)
    if ply:IsInSpawn() then return false end
end

hook.Add("PlayerSpawnProp", "PIXEL.SpawnProtection.DisableSpawning", falseInSpawn)
hook.Add("PhysgunPickup", "PIXEL.SpawnProtection.DisablePhysgun", falseInSpawn)
hook.Add("CanTool", "PIXEL.SpawnProtection.DisableToolgun", falseInSpawn)

hook.Add("PlayerShouldTakeDamage", "PIXEL.SpawnProtection.DisableDamage", function(ply, attacker)
    if ply:IsInSpawn() or (attacker.IsInSpawn and attacker:IsInSpawn()) then return false end
end)