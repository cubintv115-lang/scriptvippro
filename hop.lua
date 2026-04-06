-- [[ V36 THE NETWORK VOID - HOA GIAI PING -1MS & FREEZE ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. XOAY BÁNH XE: VÔ HIỆU HÓA HOÀN TOÀN HỆ THỐNG THÔNG BÁO LỖI (ANTI-GUI)
pcall(function()
    local coreGui = game:GetService("CoreGui")
    coreGui.ChildAdded:Connect(function(child)
        if child.Name == "ErrorMessagePrompt" or child:FindFirstChild("ErrorMessagePrompt") then
            child.Visible = false -- Làm tàng hình bảng lỗi ngay lập tức
            child:Destroy()
        end
    end)
end)

-- 2. HÀM NHẢY SERVER "XUYÊN KHÔNG" (NHẢY THẲNG VÀO SERVER VẮNG NHẤT)
local function VoidJump()
    local success, result = pcall(function()
        -- Chỉ tìm server có 1 ĐẾN 2 NGƯỜI (Cực kỳ an toàn)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
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
            print("V36: Dang tien hanh nhay server khau cap...")
            -- Đợi 8 giây để Roblox reset kết nối hoàn toàn, tránh lỗi 773
            task.wait(8)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. CƠ CHẾ "TRỰC GIÁC": PING WATCHER (CHỐNG LỖI PING -1MS)
-- Đây là vũ khí chính để phá đòn Network Freeze trong ảnh
local lastPing = 0
local freezeTimer = 0
task.spawn(function()
    while task.wait(1) do
        local success, currentPing = pcall(function()
            -- Lấy giá trị Ping thực tế từ game
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        
        if success then
            -- Nếu Ping đứng im quá 4 giây (Freeze), lập tức nhảy server
            if currentPing == lastPing and lastPing ~= 0 then
                freezeTimer = freezeTimer + 1
                if freezeTimer >= 4 then
                    warn("!!! MAHORAGA PHAT HIEN FREEZE !!! Dang nhay server khau cap...")
                    VoidJump()
                    freezeTimer = 0
                end
            else
                freezeTimer = 0
            end
            lastPing = currentPing
        end
    end
end)

-- 4. PHẢN XẠ KHI CÓ LỖI (MÀN HÌNH XÁM)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Phat hien don danh moi! Dang thich nghi...")
        VoidJump()
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER ĐỊNH KỲ (MỖI 100 GIÂY)
task.spawn(function()
    while task.wait(100) do
        print("V36: Tu dong doi dia ban san Bounty...")
        VoidJump()
    end
end)

print("--- [Gemini] V36 NETWORK VOID ACTIVE: BAN DA THICH NGHI VOI NETFREEZE ---")
