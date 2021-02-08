
local corner1, corner2 = Vector(3665, 1368, -196), Vector(2920, 498, 168) --Spawn area config

--Set the isInSpawn metamethods
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

local inSpawn = false
local function isSelfInSpawn(s, verify)
    if verify then
        inSpawn = s:GetPos():WithinAABox(corner1, corner2)
    end

    return inSpawn
end

plyMeta.IsInSpawn = isSelfInSpawn
entMeta.IsInSpawn = isSelfInSpawn

--Drawing the spawn zone indicator
local function loadUi()
    PIXEL.RegisterFont("SpawnProtection.Title", "Open Sans Bold", 42)
    PIXEL.RegisterFont("SpawnProtection.Description", "Open Sans Bold", 24)

    local centerX = ScrW() * .5
    local titleX = PIXEL.Scale(80)

    local titleCol = PIXEL.Colors.Primary
    local descriptionCol = PIXEL.Colors.PrimaryText
    local textAlignCenter = TEXT_ALIGN_CENTER

    hook.Add("HUDPaint", "PIXEL.SpawnProtection.Indicator", function()
        local _, titleH = PIXEL.DrawSimpleText("SPAWN", "PIXEL.SpawnProtection.Title", centerX, titleX, titleCol, textAlignCenter)
        PIXEL.DrawSimpleText("You are in spawn, roleplay is not permitted here.", "PIXEL.SpawnProtection.Description", centerX, titleX + titleH, descriptionCol, textAlignCenter)
    end)
end

local function unloadUi()
    hook.Remove("HUDPaint", "PIXEL.SpawnProtection.Indicator")
end

if PIXEL.UI then
    loadUi()
else
    hook.Add("PIXEL.UI.FullyLoaded", "PIXEL.SpawnProtection.WaitForPIXELUI", loadUi)
end

--Perform the spawn area check
local localPly
timer.Create("PIXEL.SpawnProtection.AreaCheck", .5, 0, function()
    if not IsValid(localPly) then
        localPly = LocalPlayer()
        return
    end

    local oldState = inSpawn
    if isSelfInSpawn(localPly, true) == oldState then return end --If the state changes run the code below

    net.Start("PIXEL.SpawnProtection.UpdateSpawnState")
    net.SendToServer()

    if inSpawn then loadUi()
    else unloadUi() end
end)
