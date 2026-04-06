-- [[ V35 THE INFINITE ADAPTATION - XOAY BÁNH XE LẦN CUỐI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: VÔ HIỆU HÓA HOÀN TOÀN HỆ THỐNG THÔNG BÁO LỖI
-- Khiến Roblox không thể đóng băng Script của bạn bằng bảng lỗi
local function UltimateShield()
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        coreGui.ChildAdded:Connect(function(child)
            if child.Name == "ErrorMessagePrompt" or child:FindFirstChild("ErrorMessagePrompt") then
                child.Visible = false -- Làm tàng hình bảng lỗi ngay lập tức
                child:Destroy()
            end
        end)
    end)
end
task.spawn(UltimateShield)

-- 2. HÀM NHẢY SERVER "GHOST MODE" (Lách lỗi 773 triệt để)
local function InfiniteHop()
    -- Bước quan trọng: Ép Roblox "quên" Session cũ bị lỗi
    pcall(function()
        GuiService:ClearError() 
    end)

    local success, result = pcall(function()
        -- Tìm server CỰC VẮNG (Chỉ 1 người duy nhất)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            -- Chỉ lấy server 1 người để đảm bảo kết nối 100% thành công
            if v.playing == 1 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("Mahoraga: Dang vao lai server moi (Silent Re-entry)...")
            -- Đợi 15 giây (Khoảng nghỉ vàng để Roblox mở khóa IP cho bạn)
            task.wait(15)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            -- Nếu không có server 1 người, nhảy đại để thoát khỏi trạng thái kẹt
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 3. THEO DÕI LỖI KẾT NỐI (REJOIN KHÔNG CẦN BẢNG THÔNG BÁO)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Phat hien loi ket noi! Dang xoay banh xe thich nghi...")
        InfiniteHop()
    end
end)

-- 4. TỰ ĐỘNG ĐỔI SERVER SAU 100 GIÂY (NHANH HƠN ĐỂ TRÁNH BỊ SOI)
task.spawn(function()
    while task.wait(100) do
        InfiniteHop()
    end
end)

-- 5. PHÁ ĐẢO LỖI FREEZE (Nếu game không phản hồi trong 5s là nhảy ngay)
local lastHeartbeat = tick()
game:GetService("RunService").Heartbeat:Connect(function()
    if tick() - lastHeartbeat > 5 then
        InfiniteHop()
        lastHeartbeat = tick()
    end
    lastHeartbeat = tick()
end)

print("--- [Gemini] V35 INFINITE ADAPTATION ACTIVE ---")
