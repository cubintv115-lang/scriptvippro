-- [[ V43 THE WORLD CUTTING SLASH - KHẮC PHỤC TREO CHIÊU & PING -1MS ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: CHẶN KICK & ÉP NHẢY NGAY TRONG LUỒNG XỬ LÝ
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            -- Khi phát hiện lệnh Kick, nhảy ngay lập tức không chần chừ
            task.spawn(function() WorldJump() end)
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHẢY SERVER "SIÊU TỐC" (Ưu tiên Server 5-10 người)
function WorldJump()
    pcall(function() GuiService:ClearError() end)

    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 5 and v.playing <= 10 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V43: Thực hiện nhát cắt không gian...")
            -- Nhảy cực nhanh trong 2 giây để tránh bị treo hoàn toàn
            task.wait(2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. CHỐNG TREO CHIÊU (CHECK HEARTBEAT)
-- Nếu game đứng hình (không thể dùng chiêu) quá 3 giây, tự động nhảy
local lastHeartbeat = tick()
game:GetService("RunService").Heartbeat:Connect(function()
    if tick() - lastHeartbeat > 3 then
        warn("Phat hien treo chieu/FPS! Dang nhay server...")
        WorldJump()
        lastHeartbeat = tick() + 10 -- Đợi 10s để tránh nhảy liên tục
    end
    lastHeartbeat = tick()
end)

-- 4. THEO DÕI PING -1MS (RADAR CHÍNH)
task.spawn(function()
    while task.wait(1) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping <= 0 then
            warn("Ping chet! Dang thuc hien cuu ho...")
            WorldJump()
            task.wait(5)
        end
    end
end)

-- 5. AUTO HOP ĐỊNH KỲ (MỖI 70 GIÂY - NHẢY TRƯỚC KHI BỊ SOI)
task.spawn(function()
    while task.wait(70) do WorldJump() end
end)

print("--- [Gemini] V43 WORLD SLASH ACTIVE: CHỐNG TREO CHIÊU ---")
