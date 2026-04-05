local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Đợi 15 giây để game và các script khác load xong hoàn toàn rồi mới chạy
task.wait(15) 

local function InstantHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=20"))
    end)
    
    if success and result and result.data then
        for _, v in pairs(result.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, game.Players.LocalPlayer)
                return 
            end
        end
    end
    TeleportService:Teleport(game.PlaceId)
end

-- Chỉ bắt đầu canh lỗi sau khi đã vào game ổn định
GuiService.ErrorMessageChanged:Connect(function()
    local errorMsg = GuiService:GetErrorMessage()
    if errorMsg ~= "" then
        InstantHop()
    end
end)

-- Kiểm tra bảng lỗi định kỳ nhưng bỏ qua 15 giây đầu
task.spawn(function()
    while true do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") and gui.promptOverlay:FindFirstChild("ErrorPrompt") then
            InstantHop()
        end
        task.wait(1) 
    end
end)

print("--- [Gemini] Auto Hop đã sẵn sàng (Sau 15s load game) ---")
