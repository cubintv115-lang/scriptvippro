-- [[ V50 THE ABSOLUTE VOID BYPASS - FIX LỖI ĐỨNG HÌNH SAU KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")

-- 1. HÀM NHẢY SERVER "THỦY TỔ" (BYPASS MẠNG)
local function VoidHop()
    -- Xóa mọi dấu vết bảng lỗi ngay lập tức
    pcall(function()
        GuiService:ClearError()
        local errorPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then errorPrompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server từ 7-12 người để đảm bảo server sống và lách lỗi 773
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 7 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V50: Phát hiện nhát cắt không gian! Đang nhảy server khẩn cấp...")
            -- Nhảy ngay lập tức không chờ đợi
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Đòn dự phòng: Nếu kẹt 3 giây không nhảy được, dùng Teleport thô
            task.delay(3, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CAN THIỆP SÂU VÀO NAME CALL
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Chặn Kick/Disconnect và kích hoạt nhảy server cùng lúc
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(VoidHop) -- Nhảy server TRƯỚC khi trả về nil
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. THEO DÕI PING -1MS (KHẮC PHỤC TRẠNG THÁI TRONG ẢNH)
-- Nếu Ping tụt về -1ms (mất mạng ngầm), ép nhảy server ngay
task.spawn(function()
    while task.wait(0.5) do
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping <= 0 then
            warn("Ping chet! Dang thuc hien Void Hop...")
            VoidHop()
            task.wait(5)
        end
    end
end)

-- 4. TỰ ĐỘNG NHẢY SERVER TRƯỚC KHI BỊ SOI (MỖI 45 GIÂY)
-- Rút ngắn thời gian để hệ thống không kịp ra lệnh Kick
task.spawn(function()
    while task.wait(45) do
        VoidHop()
    end
end)

print("--- [Gemini] V50 VOID BYPASS: DA THICH NGHI HOAN TOAN ---")
