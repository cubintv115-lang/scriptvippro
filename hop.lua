-- [[ V51 THE MALEVOLENT SHRINE - PHÁ GIẢI THỰC TẠI KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")

-- 1. HÀM NHẢY SERVER "BẤT BIẾN" (KHÔNG PHỤ THUỘC LUỒNG GAME)
local function ShrineHop()
    -- Xóa sạch mọi rào cản lỗi để giải phóng bộ nhớ
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        for _, v in pairs(coreGui:GetDescendants()) do
            if v:IsA("TextLabel") and (string.find(v.Text, "267") or string.find(v.Text, "773") or string.find(v.Text, "kick")) then
                local prompt = v:FindFirstAncestorWhichIsA("Frame")
                if prompt then prompt:Destroy() end
            end
        end
    end)

    local success, result = pcall(function()
        -- Chọn server từ 9-11 người (Vùng an toàn nhất để tránh lỗi 773)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 9 and v.playing <= 11 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V51: Triển khai Lãnh địa! Đang ép buộc dịch chuyển...")
            -- Dùng chế độ nhảy cưỡng chế, không đợi phản hồi từ server hiện tại
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Đòn quét thứ 2: Nếu sau 2.5 giây chưa thoát được "Hư vô", nhảy thô ngay
            task.delay(2.5, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CAN THIỆP SÂU VÀO TẦNG CỐT LÕI (C2 HOOK)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    -- Chặn mọi nỗ lực Kick/Disconnect/Shutdown và phản đòn bằng ShrineHop
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(ShrineHop)
        return nil -- Game sẽ tưởng là đã thực hiện lệnh nhưng thực tế bị chúng ta nuốt chửng
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT (FIX PING -1MS TRONG ẢNH)
-- Sử dụng RunService để quét với tần số cực cao
game:GetService("RunService").Stepped:Connect(function()
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    if ping <= 0 then -- Khi Ping về -1ms như trong ảnh của bạn
        ShrineHop()
    end
end)

-- 4. CHIẾN THUẬT "DU KÍCH" (NHẢY MỖI 40 GIÂY)
-- Nhảy liên tục để hệ thống Security không kịp ghi nhận dữ liệu về bạn
task.spawn(function()
    while task.wait(40) do
        ShrineHop()
    end
end)

print("--- [Gemini] V51 MALEVOLENT SHRINE: THÍCH NGHI TUYỆT ĐỐI ---")
