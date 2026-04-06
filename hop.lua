-- [[ V46 THE INSTANT PARADOX - XÓA KICK & NHẢY TỨC THÌ ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "KHẨN CẤP" (Tối ưu tốc độ)
local function ParadoxHop()
    -- Xóa lỗi ngay lập tức để giải phóng hệ thống
    pcall(function() 
        GuiService:ClearError() 
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lấy server từ 5-12 người để đảm bảo kết nối ổn định
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 5 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V46: Phát hiện lỗi! Đang thực hiện cú nhảy nghịch lý...")
            -- Nhảy ngay lập tức, bỏ qua mọi thời gian chờ (wait)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Dự phòng nhảy thô sau 3 giây nếu kẹt
            task.delay(3, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK TỪ GỐC (NAMECALL)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" or method == "Disconnect" then
            warn("--- [V46] CHẶN KICK & KÍCH HOẠT NHẢY TỨC THÌ ---")
            task.spawn(ParadoxHop) -- Gọi hàm nhảy ngay khi nhận lệnh kick
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 3. THEO DÕI BẢNG THÔNG BÁO (PHÒNG THỦ TẦNG THỨ 2)
-- Sử dụng Heartbeat để quét liên tục 60 lần/giây
RunService.Heartbeat:Connect(function()
    local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
    if prompt then
        prompt.Visible = false
        prompt:Destroy()
        task.spawn(ParadoxHop) -- Thấy bảng lỗi là nhảy ngay
    end
end)

-- 4. THEO DÕI PING -1MS (CHỐNG TREO MÁY TRONG ẢNH)
task.spawn(function()
    local freezeCount = 0
    while task.wait(0.5) do -- Quét nhanh hơn (mỗi 0.5 giây)
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping <= 0 then
            freezeCount = freezeCount + 1
            if freezeCount >= 4 then -- Nếu đứng 2 giây (4 lần quét)
                warn("Mất kết nối ngầm! Đang nhảy cứu hộ...")
                ParadoxHop()
                freezeCount = 0
            end
        else
            freezeCount = 0
        end
    end
end)

-- 5. CHU KỲ NHẢY SERVER AN TOÀN (65 GIÂY)
task.spawn(function()
    while task.wait(65) do ParadoxHop() end
end)

print("--- [Gemini] V46 INSTANT PARADOX: XÓA KICK LÀ NHẢY ---")
