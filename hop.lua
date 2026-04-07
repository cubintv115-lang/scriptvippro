-- [[ V47 THE ABSOLUTE ADAPTATION - PHÁ GIẢI TRẠNG THÁI ZOMBIE ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- 1. HÀM NHẢY SERVER "FORCE" (ÉP BUỘC KẾT NỐI)
local function ForceHop()
    -- Xóa bảng lỗi ngay lập tức để giải phóng Executor
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local errorPrompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then errorPrompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lấy server có từ 6-12 người (Tránh server 1 người để lách lỗi 773)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 6 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V47: Phát hiện Kick! Đang thực hiện bước nhảy cưỡng chế...")
            -- Dùng lệnh nhảy trực tiếp nhất của Roblox
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, Players.LocalPlayer)
            
            -- Dự phòng nhảy thô sau 4 giây nếu kẹt Ping -1ms
            task.delay(4, function()
                TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK VÀ GỌI NHẢY ĐỒNG THỜI (HỆ THỐNG SONG SONG)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        -- Chặn đứng mọi nỗ lực ngắt kết nối
        if method == "Kick" or method == "kick" or method == "Disconnect" then
            warn("--- [V47] ĐÃ CHẶN KICK! ĐANG NHẢY SERVER NGAY ---")
            -- Kích hoạt nhảy server ngay trong luồng namecall để đạt tốc độ cao nhất
            task.spawn(ForceHop)
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 3. THEO DÕI "DẤU HIỆU TỬ VONG" (DÙNG HEARTBEAT ĐỂ KHÔNG BỊ TREO)
-- Nếu FPS hoặc Ping đứng im quá 2 giây, tự động nhảy
local lastTick = tick()
RunService.Heartbeat:Connect(function()
    if tick() - lastTick > 2.5 then
        warn("Game bị treo luồng! Đang thực hiện nhảy cứu hộ...")
        task.spawn(ForceHop)
        lastTick = tick() + 10 -- Đợi 10s để tiến trình nhảy hoàn tất
    end
    lastTick = tick()
end)

-- 4. THEO DÕI PING -1MS (QUÉT SIÊU TỐC 0.5S)
task.spawn(function()
    while task.wait(0.5) do
        local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        if stats:GetValue() <= 0 then
            warn("Ping chết (-1ms)! Đang thực hiện Force Hop...")
            ForceHop()
            task.wait(8)
        end
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER ĐỊNH KỲ (60 GIÂY - NHẢY TRƯỚC KHI BỊ KICK)
task.spawn(function()
    while task.wait(60) do
        print("V47: Đổi server định kỳ để giữ an toàn...")
        ForceHop()
    end
end)

print("--- [Gemini] V47 ABSOLUTE ADAPTATION ACTIVE ---")
