-- [[ V14 EMERGENCY EXIT - NHẢY TỨC THÌ & CHỐNG MẤT KẾT NỐI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Hàm tìm Server "Sạch" (Tránh tuyệt đối lỗi Reconnect Unsuccessful)
local function EmergencyHop()
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        -- Lấy danh sách server sắp xếp từ vắng nhất đến đầy nhất
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local safeServers = {}
        for _, v in pairs(result) do
            -- CHỈ CHỌN server trống ít nhất 5-7 chỗ (Cực kỳ quan trọng để không bị lỗi kết nối)
            if v.playing < (v.maxPlayers - 5) and v.id ~= game.JobId then
                table.insert(safeServers, v.id)
            end
        end
        
        if #safeServers > 0 then
            local target = safeServers[math.random(1, #safeServers)]
            -- Bắn lệnh nhảy 5 lần liên tục để ép hệ thống thực hiện trước khi script bị đóng băng
            for i = 1, 5 do
                TeleportService:TeleportToPlaceInstance(PlaceId, target, game.Players.LocalPlayer)
                task.wait(0.05)
            end
        else
            TeleportService:Teleport(PlaceId)
        end
    end
end

-- 1. TỰ ĐỘNG NHẢY SAU 2 PHÚT (NHƯ BẠN MUỐN)
task.spawn(function()
    while task.wait(120) do
        EmergencyHop()
    end
end)

-- 2. PHẢN XẠ TỨC THÌ KHI BỊ KICK (BẮT TÍN HIỆU TỪ LÕI GAME)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        -- Khi bị kick, nhảy ngay lập tức không chờ đợi
        EmergencyHop()
    end
end)

-- 3. CHỐNG TREO MÀN HÌNH XÁM (BẮT GUI LỖI TRONG 0.1 GIÂY)
task.spawn(function()
    while task.wait(0.1) do
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("ErrorMessagePrompt", true) then
            EmergencyHop()
            break
        end
    end
end)

print("--- [Gemini] V14 EMERGENCY EXIT: DA SAN SANG ---")
