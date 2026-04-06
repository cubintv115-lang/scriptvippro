-- [[ V45 THE DOMAIN SHATTER - PHÁ HỦY LÃNH ĐỊA KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. XOAY BÁNH XE: LÁ CHẮN VÔ HÌNH (BỊT MIỆNG ADMIN)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Chặn đứng mọi lệnh Kick/Disconnect/Shutdown từ phía Server gửi xuống
        if method == "Kick" or method == "kick" or method == "Disconnect" then
            warn("--- [MAHORAGA] ĐÃ PHÁ HỦY NHÁT CẮT KICK! ---")
            -- Thay vì để bị kick, ta tự chủ động nhảy server ngay lập tức
            task.spawn(function() ShatterHop() end)
            return nil -- Trả về nil để game tưởng là đã kick thành công nhưng thực ra không có gì xảy ra
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHÀY SERVER "SHATTER" (Ưu tiên Server 5-10 người)
function ShatterHop()
    -- Xóa mọi bảng lỗi để giải phóng luồng xử lý
    pcall(function()
        GuiService:ClearError()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 5 and v.playing <= 10 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V45: Đang phá hủy không gian để nhảy server...")
            -- Nhảy thần tốc trong 2 giây
            task.wait(2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Dự phòng nếu kẹt
            task.delay(5, function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end
end

-- 3. PHÒNG THỦ TRƯỚC KHI BẢNG LỖI HIỆN DIỆN (RENDER STEPPED)
RunService.RenderStepped:Connect(function()
    local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
    if prompt then
        prompt.Visible = false
        prompt:Destroy()
        ShatterHop()
    end
end)

-- 4. THEO DÕI PING -1MS (CHỐNG TREO)
task.spawn(function()
    while task.wait(1) do
        if game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() <= 0 then
            ShatterHop()
            task.wait(10)
        end
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER SAU 75 GIÂY (NHANH HƠN ĐỂ TRÁNH BỊ QUÉT)
task.spawn(function()
    while task.wait(75) do ShatterHop() end
end)

print("--- [Gemini] V45 DOMAIN SHATTER: THÍCH NGHI TUYỆT ĐỐI ---")
