-- [[ V56 THE GENESIS REWRITE - KHẮC PHỤC TREO KHI HIỆN THÔNG BÁO ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHÀY SERVER "KHỞI NGUYÊN" (ƯU TIÊN LUỒNG CAO NHẤT)
local function GenesisHop()
    -- Ép buộc xóa lỗi ở cấp độ phần cứng GUI
    pcall(function()
        GuiService:ClearError()
        game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true):Destroy()
    end)

    local success, result = pcall(function()
        -- Lọc server cực vắng (5-8 người) để máy FPS thấp load nhanh nhất
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 5 and v.playing <= 8 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V56: Phát hiện Kick kép! Đang thực hiện trùng sinh...")
            -- Đòn 1: Nhảy trực tiếp
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Đòn 2 (Quan trọng): Dùng lệnh nhảy thô ngay sau 0.5s để phá băng mạng
            task.delay(0.5, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHIẾM QUYỀN LỆNH THOÁT (BYPASS KICK HIỆN HÌNH)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Chặn đứng mọi lệnh ngắt kết nối từ phía Client lẫn Server
    if method == "Kick" or method == "kick" or method == "Disconnect" or method == "shutdown" then
        task.spawn(GenesisHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT (ANTI-FREEZE)
-- Trong ảnh bạn gửi Ping là -1ms
RunService.RenderStepped:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    if ping <= 0 then
        GenesisHop()
    end
end)

-- 4. THEO DÕI SỰ THAY ĐỔI CỦA BẢNG LỖI (DÙNG CHO DELTA)
GuiService.ErrorMessageChanged:Connect(function()
    GenesisHop()
end)

-- 5. CHU KỲ NHẢY "AN TOÀN" (MỖI 25 GIÂY)
-- Nhảy cực ngắn để Security không kịp chuẩn bị đòn Kick kép
task.spawn(function()
    while task.wait(25) do
        GenesisHop()
    end
end)

print("--- [Gemini] V56 GENESIS REWRITE: THÍCH NGHI HOÀN TẤT ---")
