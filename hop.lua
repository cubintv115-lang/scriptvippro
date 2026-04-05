-- [[ SPAM JOIN & BRUTE FORCE HOP V9 - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Biến kiểm soát để không bị treo máy do spam quá đà
local isHopping = false

local function SpamJoin()
    if isHopping then return end
    isHopping = true
    
    warn("!!! PHAT HIEN BI KICK - DANG SPAM JOIN SERVER MOI !!!")
    
    -- Lấy danh sách server sẵn sàng
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and result then
        -- Lọc ra 10 server tốt nhất (trống nhiều chỗ)
        local bestServers = {}
        for _, v in pairs(result) do
            if v.playing < (v.maxPlayers - 3) and v.id ~= game.JobId then
                table.insert(bestServers, v.id)
            end
        end

        -- VÒNG LẶP SPAM: Bắn lệnh liên tục mỗi 0.5 giây
        task.spawn(function()
            local attempts = 0
            while isHopping and attempts < 20 do -- Thử tối đa 20 lần
                attempts = attempts + 1
                local targetId = bestServers[math.random(1, #bestServers)]
                
                pcall(function()
                    if targetId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Players.LocalPlayer)
                    else
                        TeleportService:Teleport(game.PlaceId)
                    end
                end)
                
                task.wait(0.5) -- Tốc độ spam cực nhanh
            end
            isHopping = false -- Reset nếu sau 20 lần vẫn k thoát được (hiếm)
        end)
    end
end

-- 1. KÍCH HOẠT KHI BẢNG LỖI XUẤT HIỆN (KICK/LAG/DISCONNECT)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        SpamJoin()
    end
end)

-- 2. KÍCH HOẠT KHI PHÁT HIỆN BẢNG THÔNG BÁO LỖI TRONG CORE GUI
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" or child.Name == "ErrorPrompt" then
        SpamJoin()
    end
end)

-- 3. TỰ ĐỘNG BẤM NÚT "RECONNECT" HOẶC "LEAVE" NGẦM
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
            if prompt then
                -- Ép buộc đóng bảng lỗi để lộ nút bấm ngầm
                local button = prompt:FindFirstChild("Button", true)
                if button then
                    -- Giả lập nhấn nút để kích hoạt lệnh nhảy nhanh hơn
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                end
                SpamJoin()
            end
        end)
    end
end)

print("--- [Gemini] V9 BRUTE FORCE: SPAM JOIN ACTIVE ---")
