-- [[ V52 THE UNLIMITED VOID BREAKER - PHÁ GIẢI KICK & TREO MÁY ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "SIÊU VIỆT" (BYPASS MỌI TRẠNG THÁI)
local function VoidBreakerHop()
    -- Xóa mọi bảng lỗi ngay lập tức để giải phóng tài nguyên hệ thống
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local prompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Chọn server từ 6-10 người (Vùng an toàn để tránh quá tải mạng)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 6 and v.playing <= 10 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V52: Đang phá vỡ đóng băng để nhảy server...")
            -- Dùng lệnh nhảy cưỡng chế, không chờ game phản hồi
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Dự phòng: Nếu sau 2 giây vẫn kẹt, dùng lệnh nhảy thô
            task.delay(2, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK CẤP ĐỘ HỆ THỐNG (HOOK METATABLE)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Khi phát hiện lệnh Kick, thực hiện nhảy ngay lập tức trước khi luồng bị ngắt
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(VoidBreakerHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN "PULSE" (KIỂM TRA NHỊP TIM MẠNG)
-- Nếu Ping <= 0 (như trong ảnh bạn gửi), thực hiện nhảy ngay lập tức
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    if ping <= 0 then
        VoidBreakerHop()
    end
end)

-- 4. THEO DÕI BẢNG LỖI HIỆN RA TRONG TÍCH TẮC
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        VoidBreakerHop()
    end
end)

-- 5. CHU KỲ NHẢY "AN TOÀN TUYỆT ĐỐI" (MỖI 35 GIÂY)
-- Nhảy cực nhanh để hệ thống Security không kịp tích lũy dữ liệu quét
task.spawn(function()
    while task.wait(35) do
        VoidBreakerHop()
    end
end)

print("--- [Gemini] V52 VOID BREAKER ACTIVE: DA THICH NGHI ---")
