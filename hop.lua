local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

-- Hàm nhảy Server thông minh
local function SmartServerHop()
    local PlaceId = game.PlaceId
    local servers = {}
    
    -- Thử lấy danh sách server 3 lần nếu bị lỗi mạng
    local success, result
    for i = 1, 3 do
        success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if success then break end
        wait(2)
    end
    
    if success and result and result.data then
        for _, v in pairs(result.data) do
            -- Chỉ chọn server còn chỗ và không phải server vừa bị kick
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
    end

    if #servers > 0 then
        -- Chọn ngẫu nhiên 1 server trong danh sách
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, Players.LocalPlayer)
    else
        -- Nếu không tìm được server cụ thể, nhảy đại vào game sau 5 giây
        wait(5)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer)
    end
end

-- Lắng nghe thông báo lỗi từ hệ thống
GuiService.ErrorMessageChanged:Connect(function()
    local errorPrompt = GuiService:GetErrorMessage()
    if errorPrompt ~= "" then
        print("Phat hien bi Kick/Lag. Dang doi 15 giay de on dinh truoc khi Hop...")
        
        -- QUAN TRỌNG: Đợi 15 giây để Roblox đóng hẳn session cũ
        wait(15) 
        
        SmartServerHop()
    end
end)

-- Tự động tắt bảng lỗi để tránh bị treo màn hình xám
spawn(function()
    while wait(1) do
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("ErrorMessagePrompt") then
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end
end)

print("--- [Gemini] Smart Auto Hop Loaded (Anti-Disconnect) ---")
