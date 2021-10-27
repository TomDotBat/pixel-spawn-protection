
--[[
    PIXEL Spawn Protection

    Copyright (C) 2021 Tom O'Sullivan (Tom.bat)
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local corner1, corner2 = Vector(-10284, 10948, -3004), Vector(-11506, 9924, -2440) --Spawn area config
local corner3, corner4 = Vector(-9927, 10092, -30044), Vector(-10370, 10780, -2820)

--Set the isInSpawn metamethods
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

local inSpawn = false
local function isSelfInSpawn(s, verify)
    if verify then
        inSpawn = s:GetPos():WithinAABox(corner1, corner2) or s:GetPos():WithinAABox(corner3, corner4)
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
        local _, titleH = PIXEL.DrawSimpleText("SPAWN", "SpawnProtection.Title", centerX, titleX, titleCol, textAlignCenter)
        PIXEL.DrawSimpleText("You are in spawn, roleplay is not permitted here.", "SpawnProtection.Description", centerX, titleX + titleH, descriptionCol, textAlignCenter)
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
