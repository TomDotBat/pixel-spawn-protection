
local function loadAddon()
    PIXEL.RegisterFont("SpawnProtection.Title", "Open Sans Bold", 42)
    PIXEL.RegisterFont("SpawnProtection.Description", "Open Sans Bold", 24)

    local localPly
    local inSpawn = false
    local corner1, corner2 = Vector(3665, 1368, -196), Vector(2920, 498, 168)
    timer.Create("PIXEL.SpawnProtection.AreaCheck", .5, 0, function()
        if not IsValid(localPly) then
            localPly = LocalPlayer()
            return
        end

        inSpawn = localPly:GetPos():WithinAABox(corner1, corner2)
    end)

    local meta = FindMetaTable("Player")

    function meta:IsInSpawn()
        return inSpawn
    end

    hook.Add("HUDPaint", "PIXEL.SpawnProtection.Indicator", function(depth, skybox)
        if skybox then return end
        if not inSpawn then return end

        local centerX = ScrW() * .5
        local titleX = PIXEL.Scale(80)

        local _, titleH = PIXEL.DrawSimpleText("SPAWN", "PIXEL.SpawnProtection.Title", centerX, titleX, PIXEL.Colors.Primary, TEXT_ALIGN_CENTER)
        PIXEL.DrawSimpleText("You are in spawn, roleplay is not permitted here.", "PIXEL.SpawnProtection.Description", centerX, titleX + titleH, PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER)
    end)
end

if PIXEL.UI then
    loadAddon()
    return
end

hook.Add("PIXEL.UI.FullyLoaded", "PIXEL.SpawnProtection.WaitForPIXELUI", loadAddon)