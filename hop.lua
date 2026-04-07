-- [[ V49 THE FINAL ADAPTATION - PHÁ GIẢI LỒNG GIAM HƯ VÔ ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 1. HÀM NHẢY SERVER "XUYÊN KHÔNG" (NHẢY BẤT CHẤP ĐÓNG BĂNG)
local function FinalHop()
    -- Xóa bảng lỗi và reset GUI để tránh treo Delta
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("ErrorMessagePrompt", true) then
            coreGui:FindFirstChild("ErrorMessagePrompt", true):Destroy()
        end
    end)

    local success, result = pcall(function()
        -- Lọc server từ 8-12 người (Server khỏe, ít bị lỗi 773)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 8 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V49: Phát hiện đóng băng! Đang ép buộc dịch chuyển...")
            -- Ép nhảy server ngay lập tức
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, Players.LocalPlayer)
            
            -- Nếu sau 3 giây vẫn kẹt -1ms, dùng lệnh nhảy thô (Bypass Network)
            task.delay(3, function()
                TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK & GỌI HÀM NHẢY (TỐC ĐỘ MICRO-GIÂY)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        task.spawn(FinalHop) -- Nhảy ngay khi lệnh kick vừa được gọi
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN NHỊP TIM (ANTI-FREEZE) - GIẢI QUYẾT TÌNH TRẠNG TRONG ẢNH
-- Nếu Ping = -1ms hoặc FPS đứng im quá 2 giây, nhảy ngay lập tức
task.spawn(function()
    local freezeTimer = 0
    while task.wait(0.5) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping <= 0 then
            freezeTimer = freezeTimer + 1
            if freezeTimer >= 4 then -- Đứng im 2 giây
                warn("V49: Cảnh báo đóng băng mạng! Đang thực hiện nhảy khẩn cấp...")
                FinalHop()
                freezeTimer = 0
            end
        else
            freezeTimer = 0
        end
    end
end)

-- 4. CHU KỲ NHẢY "TÀNG HÌNH" (MỖI 50 GIÂY)
-- Nhảy liên tục để Admin không kịp khóa IP của bạn trong server đó
task.spawn(function()
    while task.wait(50) do
        FinalHop()
    end
end)

print("--- [Gemini] V49 FINAL ADAPTATION: PHÁ GIẢI -1MS ---")
