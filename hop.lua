local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Đợi game ổn định hoàn toàn
task.wait(10)

local function SafeHop()
    local PlaceId = game.PlaceId
    -- Lấy danh sách server (SortOrder=Asc để lấy server cũ, ổn định hơn)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            -- Chỉ chọn server còn trống ít nhất 3 chỗ để tránh lỗi 773 (Server đầy/đang đóng)
            if v.playing < (v.maxPlayers - 3) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            -- Thử nhảy 
            local randomServer = targetServers[math.random(1, #targetServers)]
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, game.Players.LocalPlayer)
        else
            -- Nếu không có server ưng ý, quay lại server mặc định
            TeleportService:Teleport(PlaceId)
        end
    end
end

-- Xử lý khi hiện bảng lỗi (Bao gồm lỗi 773)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        print("Phat hien loi: " .. msg .. ". Dang chuan bi nhay sau 10s...")
        -- Nghỉ 10 giây để reset dữ liệu Teleport của Roblox
        task.wait(10)
        SafeHop()
    end
end)

-- Quét bảng lỗi cứng đầu trong UI
task.spawn(function()
    while task.wait(5) do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") and gui.promptOverlay:FindFirstChild("ErrorPrompt") then
            SafeHop()
        end
    end
end)

print("--- [Gemini] Anti-Error 773 Loaded! ---")
