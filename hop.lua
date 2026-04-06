-- [[ V13 SONIC HOP & HYPER SPAM - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Hàm tìm Server cực vắng và thực hiện ép nhảy (Ưu tiên tốc độ)
local function ForceServerHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and result then
        local targetServers = {}
        for _, v in pairs(result) do
            -- Với tốc độ 1 phút, mình chọn server trống 3 chỗ để tìm nhanh hơn
            if v.playing < (v.maxPlayers - 3) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local targetId = targetServers[math.random(1, #targetServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 1. CHẾ ĐỘ TỰ ĐỘNG ĐỔI SERVER SAU 1 PHÚT (60 GIÂY)
task.spawn(function()
    while task.wait(60) do -- Đã chỉnh xuống 1 phút theo ý bạn
        print("Da den 1 phut, dang tu dong doi Server de san muc tieu moi...")
        ForceServerHop()
    end
end)

-- 2. CHẾ ĐỘ KIỂM TRA LỖI SIÊU TỐC (0.5 GIÂY)
task.spawn(function()
    while task.wait(0.5) do
        local hasError = GuiService:GetErrorMessage() ~= "" 
        local hasPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        
        if hasError or hasPrompt then
            ForceServerHop()
            task.wait(2) -- Nghỉ ngắn để tiếp tục nã lệnh nếu chưa nhảy được
        end
    end
end)

-- 3. CHỐNG TREO LOADING (Nếu load server quá 15s không xong thì nhảy tiếp)
task.spawn(function()
    task.wait(15)
    if #Players:GetPlayers() <= 1 then
        ForceServerHop()
    end
end)

print("--- [Gemini] V13 SONIC: AUTO HOP 1 MIN ACTIVE ---")
