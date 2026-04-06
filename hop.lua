-- [[ V12 DOUBLE TIME & HYPER SPAM JOIN - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Hàm tìm Server cực vắng và thực hiện ép nhảy
local function ForceServerHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and result then
        local targetServers = {}
        for _, v in pairs(result) do
            -- Chọn server cực vắng (trống 5 chỗ) để đảm bảo vào được 100%
            if v.playing < (v.maxPlayers - 5) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local targetId = targetServers[math.random(1, #targetServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Players.LocalPlayer)
        else
            -- Nếu không tìm được server vắng, nhảy đại vào game
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 1. CHẾ ĐỘ TỰ ĐỘNG ĐỔI SERVER SAU 2 PHÚT (120 GIÂY)
task.spawn(function()
    while task.wait(120) do -- Đã chỉnh xuống 2 phút theo ý bạn
        print("Da den 2 phut, dang tu dong doi Server de lam moi Session...")
        ForceServerHop()
    end
end)

-- 2. CHẾ ĐỘ SPAM KHI BỊ KICK (KIỂM TRA LIÊN TỤC MỖI 0.5 GIÂY)
task.spawn(function()
    while task.wait(0.5) do
        -- Kiểm tra lỗi hệ thống hoặc bảng ErrorPrompt
        local hasError = GuiService:GetErrorMessage() ~= "" 
        local hasPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        
        if hasError or hasPrompt then
            print("Phat hien bi Kick/Loi! Dang thuc hien Spam Join ngay lap tuc...")
            ForceServerHop()
            task.wait(3) -- Nghỉ 3s để tránh bị spam quá tải rồi lại tiếp tục nếu chưa nhảy được
        end
    end
end)

-- 3. TỰ ĐỘNG BẤM NÚT RECONNECT/LEAVE TRÊN MÀN HÌNH (DÀNH CHO MÁY TREO)
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" or child:FindFirstChild("ErrorTitle") then
        ForceServerHop()
    end
end)

-- 4. TỐI ƯU TREO MÁY (GIẢM GIẬT LAG KHI LOAD SERVER LIÊN TỤC)
settings().Network.IncomingReplicationLag = 0

print("--- [Gemini] V12 DOUBLE TIME: AUTO HOP 2 MINS & HYPER SPAM ACTIVE ---")
