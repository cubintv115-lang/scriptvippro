-- [[ V34 THE WORLD SLASH - CẮT PHĂNG MỌI LỖI KẾT NỐI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. XOAY BÁNH XE: VÔ HIỆU HÓA LỆNH KICK (HOOK CẤP CAO)
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            return nil 
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHẢY SERVER "XUYÊN KHÔNG" (NHẢY THẲNG VÀO SERVER VẮNG NHẤT)
local function WorldSlashHop()
    -- Xóa bảng lỗi để giải phóng RAM cho Delta
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Chỉ tìm server có 1 ĐẾN 2 NGƯỜI (Cực kỳ vắng)
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing > 0 and v.playing < 3 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("Mahoraga: Nhay server trong 5s...")
            task.wait(5) -- Giảm thời gian chờ xuống để nhảy nhanh hơn
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. CƠ CHẾ "TRỰC GIÁC": NHẢY TRƯỚC KHI BỊ KICK
-- Nếu game bị đứng hình (FPS = 0) hoặc Ping không nhảy trong 3s, lập tức nhảy server
local lastUpdate = tick()
RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate > 3 then -- Nếu game bị "đứng" quá 3 giây
        warn("Phat hien game bi treo! Tu dong nhay server...")
        WorldSlashHop()
        lastUpdate = tick()
    end
    lastUpdate = tick()
end)

-- 4. PHẢN XẠ KHI CÓ LỖI (MÀN HÌNH XÁM)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        WorldSlashHop()
    end
end)

-- 5. QUÉT BẢNG LỖI SIÊU TỐC (Dành cho lỗi 267)
task.spawn(function()
    while task.wait(0.1) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            WorldSlashHop()
        end
    end
end)

-- 6. TỰ ĐỘNG NHẢY ĐỊNH KỲ (MỖI 90 GIÂY - NHANH HƠN BẢN CŨ)
task.spawn(function()
    while task.wait(90) do
        WorldSlashHop()
    end
end)

print("--- [Gemini] V34 WORLD SLASH: THICH NGHI HOAN TAT ---")
