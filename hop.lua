local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Đợi 10 giây ban đầu để ổn định
task.wait(10)

local function AbsoluteForceHop()
    print("--- [Gemini] Dang giai phong bo nho va Reset Teleport... ---")
    
    -- BƯỚC 1: Dừng tất cả các hành động của nhân vật để tránh bị kẹt 773
    pcall(function()
        Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end)
    
    -- BƯỚC 2: Nghỉ 20 giây (Thời gian chuẩn để Reset lỗi 267/773)
    task.wait(20) 
    
    local success, result = pcall(function()
        -- Lấy danh sách server cực vắng (100 server)
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        -- Lọc server còn trống ít nhất 12 chỗ (Mức an toàn tuyệt đối)
        local safeServers = {}
        for _, v in pairs(result.data) do
            if v.playing < (v.maxPlayers - 12) and v.id ~= game.JobId then
                table.insert(safeServers, v.id)
            end
        end
        
        if #safeServers > 0 then
            -- Chọn server ngẫu nhiên trong danh sách vắng
            local targetId = safeServers[math.random(1, #safeServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    else
        -- Nếu lỗi API, dùng lệnh Rejoin của hệ thống
        TeleportService:Teleport(game.PlaceId)
    end
end

-- VÒNG LẶP KIỂM TRA BẢNG LỖI (Mỗi 3 giây)
task.spawn(function()
    while true do
        local coreGui = game:GetService("CoreGui")
        local promptGui = coreGui:FindFirstChild("RobloxPromptGui")
        
        if promptGui and promptGui:FindFirstChild("promptOverlay") then
            local errorPrompt = promptGui.promptOverlay:FindFirstChild("ErrorPrompt")
            if errorPrompt then
                -- Nếu thấy bảng lỗi hiện lên (Bất kể mã gì), ép nhảy ngay
                AbsoluteForceHop()
            end
        end
        task.wait(3)
    end
end)

-- PHÒNG NGỪA: Tự động đổi server mỗi 10 phút
-- Vì bạn bị Kick 267 liên tục, hãy nhảy server thật nhanh để xóa dấu vết farm
task.spawn(function()
    while task.wait(600) do 
        print("--- Chu dong doi server de xoa dau vet Anti-cheat ---")
        AbsoluteForceHop()
    end
end)

print("--- [Gemini V7] Ultimate Anti-267/773 Fix Loaded! ---")
