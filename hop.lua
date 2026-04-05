-- [[ ANTI-KICK & AUTO REJOIN V6 "IMMORTAL" - BY GEMINI ]]
if not game:IsLoaded() then game.Loaded:Wait() end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Hàm tìm Server cực vắng (Tránh lỗi Reconnect Unsuccessful)
local function SafeHop()
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result and result.data then
        local validServers = {}
        for _, v in pairs(result.data) do
            -- Chỉ chọn server còn trống ít nhất 5 chỗ (Cực kỳ an toàn)
            if v.playing < (v.maxPlayers - 5) and v.id ~= game.JobId then
                table.insert(validServers, v.id)
            end
        end
        
        if #validServers > 0 then
            local target = validServers[math.random(1, #validServers)]
            TeleportService:TeleportToPlaceInstance(PlaceId, target, Players.LocalPlayer)
        else
            TeleportService:Teleport(PlaceId)
        end
    end
end

-- 1. CHẾ ĐỘ CỨU HỘ KHI HIỆN BẢNG LỖI (KICK/DISCONNECT)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        print("Loi he thong: " .. msg .. ". Dang nghi 15s de xoa Cache...")
        task.wait(15) -- Đợi 15s để server Roblox ghi nhận bạn đã thoát
        SafeHop()
    end
end)

-- 2. CHẾ ĐỘ "NHỊP TIM" (PHÒNG TRƯỜNG HỢP GAME BỊ TREO IM KHÔNG HIỆN LỖI)
task.spawn(function()
    while task.wait(30) do -- Cứ 30 giây kiểm tra một lần
        -- Nếu bạn ở trong server một mình quá lâu (lỗi server)
        if #Players:GetPlayers() <= 1 then
            SafeHop()
        end
    end
end)

-- 3. TỰ ĐỘNG BẤM NÚT LỖI (DÀNH CHO EXECUTOR BỊ ĐƠ)
local coreGui = game:GetService("CoreGui")
coreGui.ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" then
        task.wait(5)
        SafeHop()
    end
end)

-- 4. TỐI ƯU HÓA TREO MÁY (GIẢM LAG ĐỂ TRÁNH BỊ KICK DO QUÁ NHIỆT)
if settings().Network.IncomingReplicationLag then
    settings().Network.IncomingReplicationLag = 0
end

print("--- [Gemini] V6 IMMORTAL: DA KICH HOAT. CHUC BAN TREO MAY NGON! ---")
