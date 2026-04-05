local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local function ServerHop()
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        if #targetServers > 0 then
            TeleportService:TeleportToPlaceInstance(PlaceId, targetServers[math.random(1, #targetServers)], Players.LocalPlayer)
        else
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        end
    end
end

GuiService.ErrorMessageChanged:Connect(function()
    local errorPrompt = GuiService:GetErrorMessage()
    if errorPrompt ~= "" then
        wait(5)
        ServerHop()
    end
end)
