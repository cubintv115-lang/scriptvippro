-- [[ V48 THE DIMENSIONAL SHIFT - BIẾN KICK THÀNH NHẢY SERVER ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 1. HÀM NHẢY SERVER "DỊCH CHUYỂN" (Bỏ qua kiểm tra lỗi)
local function DimensionalHop()
    -- Xóa mọi rào cản thông báo để tránh đứng app
    pcall(function()
        GuiService:ClearError()
        local errorPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then errorPrompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Ưu tiên server có lượng người ổn định (7-12 người)
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
            warn("V48: Đang thực hiện dịch chuyển đa chiều...")
            -- Nhảy trực tiếp, không dùng task.wait dài dòng
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, Players.LocalPlayer)
            
            -- Dự phòng nhảy thô ngay lập tức nếu lệnh trên bị kẹt
            task.delay(2, function()
                TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: BẮT THỚI ĐIỂM KICK (EVENT-BASED)
-- Thay vì hook namecall, ta nghe trực tiếp lệnh Kick từ Client
pcall(function()
    Players.LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Failed then
            DimensionalHop()
        end
    end)
    
    -- Vẫn giữ lớp chặn Kick để tránh văng app tức thì
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            task.spawn(DimensionalHop)
            return nil
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 3. THEO DÕI PING -1MS & FPS DROP (CHỐNG TREO NHƯ TRONG ẢNH CŨ)
task.spawn(function()
    while task.wait(1) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping <= 0 then
            DimensionalHop()
            task.wait(5)
        end
    end
end)

-- 4. TỰ ĐỘNG LÀM MỚI SERVER (MỖI 55 GIÂY)
-- Nhảy trước khi hệ thống kịp quét ra bất thường
task.spawn(function()
    while task.wait(55) do
        DimensionalHop()
    end
end)

print("--- [Gemini] V48 DIMENSIONAL SHIFT: THÍCH NGHI HOÀN TẤT ---")
