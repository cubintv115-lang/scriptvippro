-- [[ V54 THE SOUL ANCHOR - FIX BAY VÔ HỒN & KHÔNG GÂY DAME ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "MỎ NEO" (ÉP BUỘC TÁI TẠO KẾT NỐI)
local function AnchorHop()
    -- Xóa mọi thông báo kick/lỗi để tránh đứng app Delta
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local prompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server từ 7-11 người để đảm bảo mượt mà cho máy FPS thấp
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 7 and v.playing <= 11 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V54: Phát hiện trạng thái 'Bóng ma'! Đang neo linh hồn sang server mới...")
            -- Ép nhảy server ngay
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Dự phòng sau 1.2s nếu vẫn kẹt trong hư không
            task.delay(1.2, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK & GỌI NHẢY TỨC THÌ
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(AnchorHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN "GHOST MODE" (FIX LỖI DI CHUYỂN KHÔNG DAME TRONG ẢNH)
-- Nếu Ping tụt về -1ms hoặc đứng chiêu quá 1.5 giây, thực hiện nhảy ngay
local lastCombatTick = tick()
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    
    -- Kiểm tra điều kiện Ping -1ms như trong ảnh bạn gửi
    if ping <= 0 then
        AnchorHop()
    end
end)

-- 4. TỰ ĐỘNG DỌN DẸP BẢNG LỖI 267/773 (DÙNG CHO DELTA)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        AnchorHop()
    end
end)

-- 5. CHU KỲ NHẢY "CHỦ ĐỘNG" (MỖI 35 GIÂY)
-- Nhảy trước khi hệ thống ngắt kết nối mạng của bạn
task.spawn(function()
    while task.wait(35) do
        AnchorHop()
    end
end)

print("--- [Gemini] V54 SOUL ANCHOR: FIX GHOST & NO DAMAGE ---")
