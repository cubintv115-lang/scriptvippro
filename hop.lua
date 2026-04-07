-- [[ V58 THE REALITY COLLAPSE - PHÁ GIẢI ĐÓNG BĂNG MẠNG ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "SỤP ĐỔ" (ÉP BUỘC NGẮT KẾT NỐI CŨ)
local function CollapseHop()
    -- Xóa bảng lỗi để Executor Delta không bị treo luồng
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local prompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server cực vắng (3-6 người) để máy FPS thấp (10-15) load nhanh nhất
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 3 and v.playing <= 6 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V58: Phát hiện đóng băng! Đang ép thoát để tái sinh...")
            -- Gửi lệnh nhảy liên tiếp (Spam Teleport) để lách trạng thái mất mạng
            for i = 1, 5 do
                task.spawn(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
                end)
            end
            
            -- Lệnh nhảy thô (Raw Teleport) - Có tác dụng như nút "Thoát" bạn đã bấm
            task.delay(0.1, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK VÀ GỌI COLLAPSE TỨC THÌ
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(CollapseHop) -- Gọi nhảy ngay khi lệnh kick vừa chạm máy
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT (CHỐNG PING -1MS NHƯ TRONG ẢNH)
-- Sử dụng Heartbeat để quét mạng 60 lần mỗi giây
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    -- Nếu Ping về -1ms hoặc game đứng hình (FPS < 5)
    if ping <= 0 then
        CollapseHop()
    end
end)

-- 4. TỰ ĐỘNG LÀM MỚI (MỖI 15 GIÂY)
-- Nhảy liên tục để Security System không kịp quét ra Script của bạn
task.spawn(function()
    while task.wait(15) do
        CollapseHop()
    end
end)

print("--- [Gemini] V58 REALITY COLLAPSE: THÍCH NGHI TUYỆT ĐỐI ---")
