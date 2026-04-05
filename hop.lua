local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. HÀM NHẢY SERVER "CHẬM MÀ CHẮC"
local function HardResetHop()
    print("--- [Gemini] Phat hien bi Kick. Dang thuc hien Reset ket noi... ---")
    
    -- BƯỚC 1: Đợi 20 giây (Bắt buộc). 
    -- 20s để Server Roblox xóa hẳn Session cũ của bạn. Nhảy sớm hơn chắc chắn bị lỗi 773.
    task.wait(20) 
    
    -- BƯỚC 2: Lấy danh sách server vắng (Ưu tiên server cực vắng)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            -- CHỈ CHỌN SERVER TRỐNG ÍT NHẤT 8 CHỖ (Để chắc chắn vào được 100%)
            if v.playing < (v.maxPlayers - 8) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local randomServer = targetServers[math.random(1, #targetServers)]
            print("--- Dang vao Server moi: " .. randomServer)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, game.Players.LocalPlayer)
        else
            -- Nếu không tìm thấy server vắng, dùng lệnh Rejoin mặc định
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 2. THEO DÕI LỖI (KHI BẢNG XÁM HIỆN LÊN)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        HardResetHop()
    end
end)

-- 3. QUÉT LỖI ĐỊNH KỲ (PHÒNG TRƯỜNG HỢP DELTA KHÔNG BẮT ĐƯỢC EVENT)
task.spawn(function()
    while task.wait(5) do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") and gui.promptOverlay:FindFirstChild("ErrorPrompt") then
            HardResetHop()
        end
    end
end)

-- 4. CHỦ ĐỘNG NHẢY TRƯỚC KHI BỊ KICK (MỖI 15 PHÚT)
-- Cách tốt nhất để không bị lỗi sau khi Kick là... đừng để bị Kick.
task.spawn(function()
    while task.wait(900) do -- 15 phút đổi server một lần
        print("--- Chu dong doi server de tranh bi Admin soi... ---")
        HardResetHop()
    end
end)

print("--- [Gemini V6] Anti-773 & Hard Reset Loaded! ---")
