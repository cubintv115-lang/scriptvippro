-- [[ V23 GHOST PROTOCOL - VƯỢT RÀO 267 & 773 TRIỆT ĐỂ ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Hàm lấy Server vắng cực độ (15+ chỗ trống)
local function GetGhostServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            if v.playing < (v.maxPlayers - 15) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function ExecGhostJump()
    -- 1. XÓA BẢNG LỖI ĐỂ GIẢI PHÓNG ĐÓNG BĂNG
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    -- 2. ĐẶT LỆNH NHẢY VÀO HÀNG CHỜ (QUEUE)
    -- Đây là kỹ thuật giúp lệnh nhảy tồn tại KỂ CẢ KHI BẠN BỊ KICK
    local target = GetGhostServer()
    if target then
        local code = [[
            local ts = game:GetService("TeleportService")
            local p = game:GetService("Players").LocalPlayer
            ts:TeleportToPlaceInstance(]]..game.PlaceId..[[, "]]..target..[[", p)
        ]]
        
        -- Thử dùng QueueTeleport nếu Executor hỗ trợ (Delta thường hỗ trợ)
        if queue_on_teleport then
            queue_on_teleport(code)
        end
        
        -- 3. NGHỈ 15 GIÂY ĐỂ ROBLOX RESET TRẠNG THÁI SECURITY
        print("GHOST PROTOCOL: Dang cho 15s de xoa Blacklist...")
        task.wait(15)
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    end
end

-- TỰ ĐỘNG NHẢY MỖI 2 PHÚT ĐỂ TRÁNH BỊ SOI
task.spawn(function()
    while task.wait(120) do ExecGhostJump() end
end)

-- PHẢN XẠ KHI THẤY BẢNG LỖI 267 HOẶC 773
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if game:GetService("GuiService"):GetErrorMessage() ~= "" then
        ExecGhostJump()
    end
end)

-- QUÉT LIÊN TỤC 1S/LẦN ĐỂ DIỆT BẢNG LỖI
task.spawn(function()
    while task.wait(1) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            ExecGhostJump()
        end
    end
end)

print("--- [Gemini] V23 GHOST PROTOCOL ACTIVE ---")
