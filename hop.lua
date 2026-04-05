local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Đợi game load ổn định
task.wait(15)

local function ForceJump()
    print("--- [Gemini] Dang thuc hien Cuong che Nhay Server ---")
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        -- Lay danh sach server moi nhat
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=30"))
    end)
    
    if success and result and result.data then
        for _, v in pairs(result.data) do
            -- Chon server con it nhat 3 cho trong cho chac an
            if v.playing < (v.maxPlayers - 3) and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, v.id, Players.LocalPlayer)
                task.wait(2) -- Doi 2 giay de lenh thuc thi
            end
        end
    end
    -- Neu tat ca deu fail, dung lenh rejoin mac dinh cua Roblox
    TeleportService:Teleport(PlaceId)
end

-- 1. Theo doi bang loi (Cach truyen thong)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        task.wait(3) -- Doi 3s de xoa session
        ForceJump()
    end
end)

-- 2. Theo doi bang loi xam (Cach cuong che)
task.spawn(function()
    while task.wait(3) do
        local coreGui = game:GetService("CoreGui")
        -- Neu thay bat ky bang thong bao nao hien len, tinh luon la loi
        if coreGui:FindFirstChild("RobloxPromptGui") and coreGui.RobloxPromptGui:FindFirstChild("promptOverlay") then
            if coreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt") then
                ForceJump()
            end
        end
    end
end)

-- 3. CHONG TREO (Anti-Lag): Neu dung im 2 phut khong lam gi, tu dong Hop
local lastPos = Vector3.new(0,0,0)
local timeStatic = 0
task.spawn(function()
    while task.wait(10) do
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local currentPos = char.HumanoidRootPart.Position
            if (currentPos - lastPos).Magnitude < 1 then
                timeStatic = timeStatic + 10
            else
                timeStatic = 0
            end
            lastPos = currentPos
            
            -- Neu dung im qua 120 giay (co the do server lag), tu nhay luon
            if timeStatic > 120 then
                ForceJump()
            end
        end
    end
end)

print("--- [Gemini Ultimate] Da kich hoat che do chong mat ket noi tuyet doi ---")
