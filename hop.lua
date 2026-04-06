-- [[ V20 THE FINAL KEY - BREAKING ERROR 267 FREEZE ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Hàm tìm Server trống 12 chỗ (Cực vắng để load thần tốc)
local function GetSuperSafeServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            if v.playing < (v.maxPlayers - 12) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function ForcedJump()
    local target = GetSuperSafeServer()
    if target then
        -- KHÔNG CHỜ ĐỢI: Khi phát hiện biến là 'nhồi' lệnh Teleport liên tục
        -- Tốc độ nhồi lệnh 0.01s giúp lách qua khe hẹp trước khi bị Freeze
        for i = 1, 10 do
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            task.wait(0.01)
        end
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 1. CHẾ ĐỘ 2 PHÚT TỰ ĐỔI SERVER (PHÒNG THỦ TỪ XA)
task.spawn(function()
    while task.wait(120) do 
        ForcedJump() 
    end
end)

-- 2. "TRẠM GÁC" PHÁT HIỆN KICK (QUÉT SIÊU TỐC 0.01S)
-- Quét thẳng vào CoreGui để tìm bảng lỗi trước khi nó kịp hiển thị hoàn toàn
game:GetService("RunService").Stepped:Connect(function()
    local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
    if prompt or GuiService:GetErrorMessage() ~= "" then
        ForcedJump()
    end
end)

-- 3. CHỐNG TREO MÀN HÌNH XÁM (TỰ ĐỘNG XÓA BẢNG LỖI ĐỂ GIẢI PHÓNG SCRIPT)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local errorPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
            if errorPrompt then
                errorPrompt:Destroy() -- Xóa sổ bảng lỗi để tránh bị đứng Script
                ForcedJump()
            end
        end)
    end
end)

print("--- [Gemini] V20 FINAL: ANTI-FREEZE ACTIVE ---")
