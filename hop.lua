-- [[ V10 GHOST JUMP - TỰ ĐỘNG NHẢY TRƯỚC KHI BỊ KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Hàm ép nhảy Server (Dùng API trực tiếp của Roblox)
local function ForceJoin()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local targetServers = {}
        for _, v in pairs(result) do
            -- Chọn server cực vắng (trống 5 chỗ) để đảm bảo KHÔNG BAO GIỜ lỗi Reconnect
            if v.playing < (v.maxPlayers - 5) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local target = targetServers[math.random(1, #targetServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 1. TÍNH NĂNG "NHẢY TRƯỚC": Cứ 15 phút tự đổi server 1 lần để reset session
task.spawn(function()
    while task.wait(900) do -- 900 giây = 15 phút
        print("He thong tu dong lam moi Session de tranh bi Kick...")
        ForceJoin()
    end
end)

-- 2. TÍNH NĂNG "BẮT TÍN HIỆU NGẦM": Nhảy ngay khi ping cao hoặc lag (Dấu hiệu sắp bị Kick)
task.spawn(function()
    while task.wait(5) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping > 1000 then -- Nếu ping vọt lên trên 1000ms (sắp văng)
            ForceJoin()
        end
    end
end)

-- 3. CHỐNG MÀN HÌNH XÁM (Xử lý lỗi CoreGui cực nhanh)
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" or child:FindFirstChild("ErrorTitle") then
        ForceJoin()
    end
end)

-- 4. ÉP NHẢY NẾU CHỈ CÓ 1 MÌNH (Server lỗi)
if #Players:GetPlayers() <= 1 then
    task.wait(5)
    ForceJoin()
end

print("--- [Gemini] V10 GHOST JUMP: TREO XUYÊN DEM ---")
