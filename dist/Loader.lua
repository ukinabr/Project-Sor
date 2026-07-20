local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local teleportScript = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/dist/Loader.lua"))()
]]

local queue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

if queue then
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress then
            queue(teleportScript)
        end
    end)
end

local function isPhantoms()
    return pcall(function()
        return workspace:FindFirstChild("FRIGHT") ~= nil
    end)
end

local scripts = {
    [4823392707] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/XOR%2BITP-Control",
    [108015301318511] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/FNAF1",
    [17673168111] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/SisterLocation",
    [12402976334] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/GoldenF",
    [79589802006248] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/PigFrog",
    [92827819645934] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/Foxy",
    [17163559210] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/Endo",
    [74221148357881] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/Moon",
    [71731529216768] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/Orvillie",
    [1343871267] = "https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/main-game.lua",
}

if isPhantoms() then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ukinabr/Aureal-B-X/refs/heads/main/Games/FMR/Minigames/Phantoms"))()
else

    local url = scripts[game.PlaceId] or scripts[game.GameId]
    if url then
        loadstring(game:HttpGet(url))()
    else
        warn("This script is not supported for this game. PlaceId: " .. tostring(game.PlaceId) .. " | GameId: " .. tostring(game.GameId))
    end
end
