local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Đợi game ổn định
task.wait(10)

local function FinalFixHop()
    -- BƯỚC 1: Hiện thông báo giả để "đánh lừa" Roblox chuẩn bị đóng Session
    print("Dang xu ly loi ket noi... Vui long doi 5 giay.")
    task.wait(5) 
    
    -- BƯỚC 2: Lấy danh sách server
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=20"))
    end)
    
    if success and result and result.data then
        -- Tìm server vắng người nhất để dễ vào (tránh bị Full)
        local target = nil
        for _, v in pairs(result.data) do
            if v.playing < (v.maxPlayers - 2) and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            -- BƯỚC 3: Nhảy server với cơ chế bảo vệ
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    else
        -- Nếu lỗi API mạng, dùng lệnh rejoin mặc định
        TeleportService:Teleport(game.PlaceId)
    end
end

-- Theo dõi lỗi mạng
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        FinalFixHop()
    end
end)

-- Quét bảng lỗi cứng đầu (Cái bảng xám chết tiệt)
task.spawn(function()
    while true do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") then
            local errorPrompt = gui.promptOverlay:FindFirstChild("ErrorPrompt")
            if errorPrompt then
                FinalFixHop()
            end
        end
        task.wait(2)
    end
end)

print("--- [Gemini Fix] Anti-Disconnect Loaded! ---")
