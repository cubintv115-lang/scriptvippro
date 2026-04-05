-- [[ INSTANT SERVER HOP V7 - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

-- Hàm lấy Server dự phòng sẵn trong bộ nhớ
local function InstantHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local targetServers = {}
        for _, v in pairs(result) do
            if v.playing < (v.maxPlayers - 2) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            -- Nhảy ngay lập tức không delay
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServers[math.random(1, #targetServers)], Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 1. NHẢY NGAY KHI CÓ THÔNG BÁO LỖI (KHÔNG ĐỢI GIÂY NÀO)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        InstantHop()
    end
end)

-- 2. NHẢY NGAY KHI BẢNG LỖI XUẤT HIỆN TRONG GUI
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" then
        InstantHop()
    end
end)

-- 3. NHẢY KHI SERVER VẮNG NGƯỜI (DƯỚI 2 NGƯỜI LÀ NHẢY LIỀN)
Players.PlayerRemoving:Connect(function()
    if #Players:GetPlayers() <= 2 then
        InstantHop()
    end
end)

-- 4. TỰ ĐỘNG BẤM "LEAVE" TRONG CORE GUI ĐỂ ÉP GAME NHẢY
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
            if prompt then
                InstantHop()
            end
        end)
    end
end)

print("--- [Gemini] V7 INSTANT: DA KICH HOAT ---")
