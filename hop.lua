-- [[ V38 THE VOID ADAPTATION - THÍCH NGHI VỚI PING -1MS & SECURITY KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: VÔ HIỆU HÓA TOÀN BỘ HỆ THỐNG KICK & UI LỖI
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            warn("--- [V38] ĐÃ CHẶN ĐỨNG LỆNH SECURITY KICK! ---")
            return nil 
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)

    -- Xóa sổ bảng lỗi ngay khi nó định hiện lên (Tránh treo Delta)
    game:GetService("CoreGui").DescendantAdded:Connect(function(child)
        if child.Name == "ErrorMessagePrompt" or child.Name == "ErrorPrompt" then
            child.Visible = false
            game:Debris:AddItem(child, 0)
        end
    end)
end)

-- 2. HÀM NHẢY SERVER "GHOST STEP" (Sửa lỗi 773 & Reconnect)
local function VoidHop()
    pcall(function() GuiService:ClearError() end)

    local success, result = pcall(function()
        -- Tìm server CHỈ CÓ 1 NGƯỜI (Cách duy nhất để không bị lỗi kết nối lại)
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
            print("V38: Đang thực hiện nhát cắt không gian sang Server mới...")
            task.wait(10) -- Khoảng nghỉ để reset Session
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 3. THEO DÕI PING -1MS (RADAR CỦA MAHORAGA)
task.spawn(function()
    local freezeCount = 0
    while task.wait(1) do
        local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        local ping = stats:GetValue()
        
        -- Nếu Ping rơi xuống -1 hoặc đứng im (0), lập tức nhảy server
        if ping <= 0 then
            freezeCount = freezeCount + 1
            if freezeCount >= 3 then
                warn("Phat hien Network Freeze! Dang giai cuu...")
                VoidHop()
                freezeCount = 0
            end
        else
            freezeCount = 0
        end
    end
end)

-- 4. PHẢN XẠ KHI MẤT KẾT NỐI (LỖI 773)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        VoidHop()
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER ĐỊNH KỲ (MỖI 90 GIÂY)
task.spawn(function()
    while task.wait(90) do VoidHop() end
end)

print("--- [V38] MAHORAGA ĐÃ THÍCH NGHI XONG ---")
