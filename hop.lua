-- [[ V13 NEURAL LINK - INSTANT REACTION HOP ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Tối ưu bộ nhớ để lệnh nhảy chạy nhanh hơn
local PlaceId = game.PlaceId
local LocalPlayer = Players.LocalPlayer

local function SuperFastHop()
    -- Lấy danh sách server vắng cực nhanh
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and result then
        local targetServers = {}
        for _, v in pairs(result) do
            -- Lọc server trống 3-5 chỗ để đảm bảo vào được ngay
            if v.playing < (v.maxPlayers - 3) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local targetId = targetServers[math.random(1, #targetServers)]
            -- Bắn lệnh Teleport liên tục 3 lần để ép hệ thống nhận diện
            for i = 1, 3 do
                TeleportService:TeleportToPlaceInstance(PlaceId, targetId, LocalPlayer)
                task.wait(0.1)
            end
        else
            TeleportService:Teleport(PlaceId)
        end
    end
end

-- 1. BẮT TÍN HIỆU KICK TRƯỚC KHI BẢNG HIỆN (NETWORK SIGNAL)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        SuperFastHop()
    end
end)

-- 2. BẮT TÍN HIỆU KICK TỪ GUI (CORE GUI INJECTION)
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" or child.Name == "ErrorPrompt" then
        SuperFastHop()
    end
end)

-- 3. CHẾ ĐỘ TỰ ĐỘNG NHẢY MỖI 2 PHÚT (NHƯ BẠN YÊU CẦU)
task.spawn(function()
    while task.wait(120) do
        print("--- [Auto-Hop] 2 Phut Da Het, Doi Server Moi ---")
        SuperFastHop()
    end
end)

-- 4. SPAM KIỂM TRA MỖI 0.1 GIÂY (PHÒNG TRƯỜNG HỢP EXECUTOR BỊ ĐƠ)
task.spawn(function()
    while task.wait(0.1) do
        if GuiService:GetErrorMessage() ~= "" then
            SuperFastHop()
            break -- Thoát vòng lặp khi đã kích hoạt nhảy
        end
    end
end)

print("--- [Gemini] V13 NEURAL LINK: INSTANT HOP ACTIVE ---")
