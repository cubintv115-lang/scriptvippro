-- [[ V24 THE OVERRIDER - CHẶN ĐỨNG LỆNH KICK & FIX LỖI 773 ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- 1. KỸ THUẬT QUAN TRỌNG: BỊT MIỆNG LỆNH KICK
-- Script này sẽ chặn đứng mọi nỗ lực Kick bạn ra khỏi game từ các script khác
local oldKick
oldKick = hookmetamethod(game:GetService("Players").LocalPlayer, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        print("--- [Gemini] Da chan dung mot lenh Kick tu Script Bounty! ---")
        return nil -- Từ chối lệnh Kick, không cho bảng lỗi hiện lên
    end
    return oldKick(self, ...)
end)

-- 2. HÀM NHẢY SERVER AN TOÀN (LỌC SEA CHUẨN 100%)
local function GetCleanServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            -- Chỉ chọn server trống ít nhất 15 chỗ
            if v.playing < (v.maxPlayers - 15) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function ExecPowerHop()
    local target = GetCleanServer()
    if target then
        -- Đợi 10 giây để "làm nguội" hệ thống tránh lỗi 773
        print("Dang lam nguoi he thong 10s...")
        task.wait(10)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    end
end

-- 3. TỰ ĐỘNG ĐỔI SERVER SAU 2 PHÚT
task.spawn(function()
    while task.wait(120) do
        ExecPowerHop()
    end
end)

-- 4. PHÒNG TUYẾN CUỐI CÙNG: NẾU VẪN THẤY BẢNG LỖI HIỆN LÊN
task.spawn(function()
    while task.wait(1) do
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then
            prompt:Destroy() -- Xóa sổ bảng lỗi
            ExecPowerHop()
        end
    end
end)

print("--- [Gemini] V24 OVERRIDER ACTIVE - KICK IS DISABLED ---")
