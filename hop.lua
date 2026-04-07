-- [[ V57 THE OVERDRIVE PROTOCOL - NHẢY SERVER TRƯỚC KHI ĐỨNG HÌNH ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "QUÁ TẢI" (GỬI LỆNH LIÊN TỤC)
local function OverdriveHop()
    -- Xóa bảng lỗi ngay lập tức để giải phóng Executor
    pcall(function()
        GuiService:ClearError()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server vắng (4-7 người) để load cực nhanh cho máy yếu
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 4 and v.playing <= 7 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V57: Kích hoạt Giao thức Quá tải! Đang ép nhảy server...")
            -- Gửi 3 đợt lệnh nhảy liên tiếp để bypass trạng thái treo mạng
            for i = 1, 3 do
                task.spawn(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
                end)
            end
            
            -- Dự phòng cực mạnh sau 0.3s (giống như lệnh Thoát bạn đã bấm được)
            task.delay(0.3, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK Ở TẦNG THẤP NHẤT
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Chặn Kick và gọi OverdriveHop NGAY LẬP TỨC
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(OverdriveHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN "VOID" (CHỐNG PING -1MS NHƯ TRONG ẢNH)
-- Sử dụng Heartbeat để phát hiện mất mạng trong 0.1 giây
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    if ping <= 0 then -- Khi Ping chạm mức -1ms như ảnh bạn gửi
        OverdriveHop()
    end
end)

-- 4. TỰ ĐỘNG LÀM MỚI (MỖI 20 GIÂY)
-- Nhảy liên tục để Security không kịp chuẩn bị lệnh Kick
task.spawn(function()
    while task.wait(20) do
        OverdriveHop()
    end
end)

print("--- [Gemini] V57 OVERDRIVE PROTOCOL ACTIVE ---")
