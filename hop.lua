local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Đợi game ổn định
task.wait(15)

local function UltimateFix773()
    print("--- [Gemini] Dang xu ly loi 773... Vui long doi 15s ---")
    
    -- BƯỚC 1: Đợi 15 giây (Thời gian vàng để Delta và Roblox reset kết nối)
    task.wait(15) 
    
    -- BƯỚC 2: Lấy danh sách server (Lấy 100 server để có nhiều lựa chọn)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            -- CHỈ CHỌN SERVER CÒN TRỐNG ÍT NHẤT 7 CHỖ (Chắc chắn không bị Full/773)
            if v.playing < (v.maxPlayers - 7) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            -- BƯỚC 3: Nhảy sang server vắng nhất
            local randomServer = targetServers[math.random(1, #targetServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Players.LocalPlayer)
        else
            -- Nếu không tìm thấy, nhảy đại vào game
            TeleportService:Teleport(game.PlaceId)
        end
    else
        -- Lỗi API thì tự Rejoin sau 5s
        task.wait(5)
        TeleportService:Teleport(game.PlaceId)
    end
end

-- Theo dõi bảng lỗi (773, 277, 279,...)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        print("Phat hien loi: " .. msg)
        UltimateFix773()
    end
end)

-- Quét bảng lỗi xám (Force Hop cho Delta)
task.spawn(function()
    while task.wait(5) do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") then
            if gui.promptOverlay:FindFirstChild("ErrorPrompt") then
                UltimateFix773()
            end
        end
    end
end)

-- PHÒNG NGỪA: Tự động nhảy sau mỗi 30 phút để "làm mới" IP
task.spawn(function()
    while task.wait(1800) do 
        print("Chu dong doi server de tranh bi kick vinh vien...")
        UltimateFix773()
    end
end)

print("--- [Gemini V5] Anti-Kick & 773 Fixed! ---")
