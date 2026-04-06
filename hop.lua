-- [[ V41 THE ORIGIN ADAPTATION - FIX REJOIN SAU UPDATE BLOX FRUITS ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: CHẶN ĐỨNG SỰ ĐÌNH CHỈ CỦA ROBLOX
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            warn("--- [MAHORAGA] DA CHAN DON KICK TU ADMIN! ---")
            -- Thay vì đứng im, ta ra lệnh nhảy server ngay tại đây
            task.spawn(function() OriginHop() end)
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHẢY SERVER "NGUYÊN THỦY" (KHÔNG ƯU TIÊN SERVER 1 NGƯỜI)
function OriginHop()
    -- Xóa lỗi để mở đường cho kết nối mới
    pcall(function() GuiService:ClearError() end)

    local success, result = pcall(function()
        -- Lấy server có lượng người vừa phải (6-12 người) để trà trộn
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            -- Tránh server 1 người, chọn server từ 6 đến 12 người
            if v.playing >= 6 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V41: Dang thuc hien cu nhay nguyen thuy sang Server ".. tostring(target) .." nguoi...")
            -- Đợi 8 giây để lách bộ lọc Anti-Hopping của Roblox
            task.wait(8)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. FIX LỖI 773 (KẾT NỐI KHÔNG THÀNH CÔNG)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        OriginHop()
    end
end)

-- 4. THEO DÕI PING FREEZE (Nếu Ping đứng im 4s là nhảy ngay)
task.spawn(function()
    local lastPing = 0
    local count = 0
    while task.wait(1) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping == lastPing and lastPing ~= 0 then
            count = count + 1
            if count >= 4 then OriginHop() end
        else
            count = 0
        end
        lastPing = ping
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER SAU 100 GIÂY
task.spawn(function()
    while task.wait(100) do OriginHop() end
end)

print("--- [Gemini] V41 ORIGIN ACTIVE: DA FIX LOI SAU UPDATE ---")
