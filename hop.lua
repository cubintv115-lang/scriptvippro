-- [[ V37 THE UNTOUCHABLE - CHIẾN THUẬT THÍCH NGHI CUỐI CÙNG ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: VÔ HIỆU HÓA HOÀN TOÀN CƠ CHẾ HIỂN THỊ LỖI
-- (Khiến Roblox không thể đóng băng app bằng bảng thông báo)
pcall(function()
    local coreGui = game:GetService("CoreGui")
    coreGui.DescendantAdded:Connect(function(child)
        if child.Name == "ErrorMessagePrompt" or child.Name == "ErrorPrompt" then
            child.Visible = false
            task.defer(function() child:Destroy() end)
        end
    end)
end)

-- 2. HÀM NHẢY SERVER "GHOST STEP" (Lách lỗi 773)
local function GhostStepHop()
    -- Ép hệ thống xóa trạng thái lỗi cũ
    pcall(function() GuiService:ClearError() end)

    local success, result = pcall(function()
        -- Tìm server CHỈ CÓ 1 NGƯỜI (Tránh tuyệt đối việc server đầy hoặc lỗi kết nối)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing == 1 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("Mahoraga: Thich nghi thanh cong! Dang vao server moi...")
            -- Nghỉ 15 giây (Khoảng thời gian vàng để Roblox gỡ Blacklist IP tạm thời)
            task.wait(15)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            -- Nếu không có server 1 người, nhảy ngẫu nhiên để thoát kẹt
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 3. THEO DÕI "MẤT KẾT NỐI" (DÙNG CHO LỖI 773 TRONG ẢNH)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        warn("Phat hien don danh: " .. msg .. "! Dang xoay banh xe...")
        GhostStepHop()
    end
end)

-- 4. QUÉT PING -1MS (CHỐNG FREEZE TRƯỚC KHI BỊ KICK)
task.spawn(function()
    local freezeCount = 0
    while task.wait(1) do
        local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        local ping = stats:GetValue()
        
        if ping <= 0 then
            freezeCount = freezeCount + 1
            if freezeCount >= 3 then
                warn("Game dung hinh! Dang nhay server khẩn cấp...")
                GhostStepHop()
                freezeCount = 0
            end
        else
            freezeCount = 0
        end
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER SAU 90 GIÂY
task.spawn(function()
    while task.wait(90) do GhostStepHop() end
end)

print("--- [V37] MAHORAGA DA THICH NGHI HOAN TOAN ---")
