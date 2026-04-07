-- [[ V59 THE VOID SANCTUM - FIX LỖI 773 & ĐÓNG BĂNG MẠNG ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "TẨY TRẮNG" (BYPASS LỖI 773)
local function SanctumHop()
    -- Xóa sạch bảng lỗi 773/267 để lách bộ lọc của Roblox
    pcall(function()
        GuiService:ClearError()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server từ 4-8 người (Tránh server quá vắng bị lỗi 773 cao hơn)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        -- Thuật toán chọn server ngẫu nhiên trong danh sách an toàn để tránh bị "soi" IP
        local safeServers = {}
        for _, v in pairs(result) do
            if v.playing >= 4 and v.playing <= 8 and v.id ~= game.JobId then
                table.insert(safeServers, v.id)
            end
        end
        target = safeServers[math.random(1, #safeServers)]
        
        if target then
            warn("V59: Phát hiện lỗi 773/267! Đang tẩy trắng để nhảy server...")
            -- Đòn 1: Ép nhảy bằng lệnh thô (như nút Thoát bạn bấm được)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Đòn 2: Nếu sau 0.5s vẫn kẹt màn hình lỗi, nhảy về server ngẫu nhiên khác
            task.delay(0.5, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CAN THIỆP SÂU VÀO LUỒNG THOÁT
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Chặn Kick/Disconnect/TeleportError
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(SanctumHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT (FIX PING -1MS TRONG ẢNH)
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    -- Nếu Ping chết hoặc FPS quá thấp (dấu hiệu đóng băng mạng)
    if ping <= 0 then
        SanctumHop()
    end
end)

-- 4. BẮT LỖI 773 TỨC THÌ (KHI VỪA HIỆN THÔNG BÁO)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        warn("V59: Phát hiện lỗi: " .. msg .. ". Đang xử lý...")
        SanctumHop()
    end
end)

-- 5. CHU KỲ NHẢY "TÀNG HÌNH" (MỖI 20 GIÂY)
task.spawn(function()
    while task.wait(20) do
        SanctumHop()
    end
end)

print("--- [Gemini] V59 VOID SANCTUM: FIX 773 & FREEZE ---")
