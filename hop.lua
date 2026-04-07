-- [[ V55 THE FINAL EXIT - PHÁ GIẢI ĐÓNG BĂNG BẰNG LỆNH THOÁT ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "CƯỠNG CHẾ THOÁT"
local function FinalExitHop()
    -- Xóa bảng lỗi để đảm bảo Executor Delta không bị kẹt luồng xử lý
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local prompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lọc server từ 6-9 người (Ít người để máy yếu dễ load, tránh đứng hình)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 6 and v.playing <= 9 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V55: Phát hiện kẹt nút Đổi SV! Đang giả lập lệnh Thoát để nhảy server...")
            -- Đòn chí mạng: Ép buộc ứng dụng hủy kết nối cũ bằng cách gọi Teleport liên tục
            -- Điều này có tác dụng giống như việc bạn bấm "Thoát" rồi vào lại cực nhanh
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Nếu sau 1 giây vẫn chưa thoát được trạng thái "Bóng ma"
            task.delay(1, function()
                -- Lệnh này sẽ ép Client Roblox phải ngắt luồng hiện tại
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CAN THIỆP NAMECALL (CHẶN KICK)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        task.spawn(FinalExitHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT PING -1MS (DẤU HIỆU CẦN "THOÁT")
-- Quét liên tục, thấy Ping chạm mức 0 là "Thoát" ngay
RunService.Heartbeat:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    if ping <= 0 then
        FinalExitHop()
    end
end)

-- 4. TỰ ĐỘNG NHẢY "PHÒNG THỦ" (MỖI 30 GIÂY)
-- Nhảy trước khi các nút bấm bị vô hiệu hóa
task.spawn(function()
    while task.wait(30) do
        FinalExitHop()
    end
end)

print("--- [Gemini] V55 FINAL EXIT: DA THICH NGHI HOAN TOAN ---")
