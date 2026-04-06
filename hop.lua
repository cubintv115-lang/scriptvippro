-- [[ V42 THE VOID WALKER - FIX TREO MAY KHI CHAN KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: CHẶN KICK & KÍCH HOẠT NHẢY KHẨN CẤP
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            warn("--- [MAHORAGA] PHÁT HIỆN LỆNH KICK -> NHẢY SERVER NGAY ---")
            task.spawn(function() OriginHop() end) -- Nhảy ngay khi lệnh kick vừa được gọi
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHẢY SERVER "XUYÊN KHÔNG" (Ưu tiên Server 6-12 người)
function OriginHop()
    -- Xóa lỗi để giải phóng bộ nhớ cho Delta
    pcall(function() GuiService:ClearError() end)

    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            -- Tránh server 1 người, chọn server đông người để trà trộn
            if v.playing >= 6 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V42: Đang thực hiện bước nhảy hư không...")
            -- Không đợi lâu, nhảy trong 3s trước khi Delta bị treo hoàn toàn
            task.wait(3)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 3. THEO DÕI PING -1MS (PHÒNG THỦ TỐI CAO)
-- Nếu Ping = -1ms, nghĩa là máy bạn đã mất kết nối ngầm, phải ép nhảy ngay
task.spawn(function()
    while task.wait(1) do
        local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        local ping = stats:GetValue()
        
        if ping <= 0 then -- Đây là trạng thái trong ảnh của bạn
            warn("Ping am! May da bi treo. Dang cuu ho...")
            OriginHop()
            task.wait(10) -- Đợi 10s để lệnh teleport có thời gian xử lý
        end
    end
end)

-- 4. FIX LỖI KẾT NỐI (773)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        OriginHop()
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER ĐỊNH KỲ (90 GIÂY)
task.spawn(function()
    while task.wait(90) do OriginHop() end
end)

print("--- [Gemini] V42 VOID WALKER ACTIVE ---")
