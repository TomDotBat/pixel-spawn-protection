
local meta = FindMetaTable("Player")

local corner1, corner2 = Vector(3665, 1368, -196), Vector(2920, 498, 168)
function meta:IsInSpawn()
    return self:GetPos():WithinAABox(corner1, corner2)
end

local function falseInSpawn(ply)
    if ply:IsInSpawn() then return false end
end

hook.Add("PlayerSpawnProp", "PIXEL.SpawnProtection.DisableSpawning", falseInSpawn)
hook.Add("PhysgunPickup", "PIXEL.SpawnProtection.DisablePhysgun", falseInSpawn)
hook.Add("CanTool", "PIXEL.SpawnProtection.DisableToolgun", falseInSpawn)

hook.Add("PlayerShouldTakeDamage", "PIXEL.SpawnProtection.DisableDamage", function(ply, attacker)
    if ply:IsInSpawn() or (attacker.IsInSpawn and attacker:IsInSpawn()) then return false end
end)