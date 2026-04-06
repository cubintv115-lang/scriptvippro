-- [[ V31 THE SINGULARITY - GIẢI PHÁP CUỐI CÙNG CHO DELTA & LURAPH ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. TỐI ƯU HÓA HỆ THỐNG ĐỂ GIẢM TẢI (TRÁNH FREEZE DELTA)
setfpscap(10) -- Ép FPS xuống 10 để dành RAM cho việc Teleport khi bị Kick
settings().Physics.PhysicsEnvironmentalThrottle = 1 -- Giảm tải vật lý

-- 2. HÀM LẤY SERVER "SIÊU TRỐNG" (ƯU TIÊN SERVER 1-2 NGƯỜI)
local function GetEmptyServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if success and result then
        for _, v in pairs(result) do
            if v.playing < 3 and v.id ~= game.JobId then return v.id end
        end
    end
    return nil
end

-- 3. KỸ THUẬT "NHẢY TRƯỚC KHI CHẾT" (PRE-KICK JUMP)
local function SingularityJump()
    local target = GetEmptyServer()
    if target then
        -- Xóa bảng lỗi (nếu có)
        pcall(function()
            game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true):Destroy()
        end)
        
        -- Nhảy ngay lập tức, không chờ đợi
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        
        -- Nếu sau 5 giây không nhảy được, thử lại bằng cách nhảy ngẫu nhiên
        task.delay(5, function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
end

-- 4. THEO DÕI "DẤU HIỆU SINH TỒN" CỦA KẾT NỐI
-- Thay vì đợi bảng lỗi, ta theo dõi Ping. Nếu Ping đứng im quá lâu = Bị Kick/Freeze
local lastPing = 0
task.spawn(function()
    while task.wait(2) do
        local currentPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if currentPing == lastPing and lastPing ~= 0 then
            warn("Phat hien Freeze! Dang nhay server khan cap...")
            SingularityJump()
        end
        lastPing = currentPing
    end
end)

-- 5. CHẶN KICK VÀO LỖI UI (DÙNG CHO DELTA)
GuiService.ErrorMessageChanged:Connect(function()
    SingularityJump()
end)

-- 6. TỰ ĐỘNG NHẢY ĐỊNH KỲ (ĐỂ TRÁNH BỊ SCRIPT BOUNTY 'SOI')
task.spawn(function()
    while task.wait(120) do SingularityJump() end
end)

print("--- [Gemini] V31 THE SINGULARITY ACTIVE ---")
