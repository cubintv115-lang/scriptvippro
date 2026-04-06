-- [[ V29 THE EXECUTIONER - ULTRA PRO MAX PROTECTION ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. SIÊU CẤP CHẶN KICK (HOOKING CẤP ĐỘ HỆ THỐNG)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Chặn đứng mọi lệnh Kick, Disconnect từ bất kỳ script nào
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        print("--- [V29] DA CHAN DUNG AM MUU KICK BAN! ---")
        return nil -- Trả về rỗng, khiến lệnh Kick vô tác dụng
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- 2. TỰ ĐỘNG XÓA BẢNG LỖI TRONG 0.01 GIÂY (DÙNG RUNSERVICE)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local errorPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then
            errorPrompt.Visible = false
            errorPrompt:Destroy()
            -- Khi thấy bảng lỗi, lập tức kích hoạt nhảy server khẩn cấp
            task.spawn(function()
                local success, target = pcall(function()
                    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
                    for _, v in pairs(servers) do
                        if v.playing < 5 and v.id ~= game.JobId then return v.id end
                    end
                end)
                if success and target then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
                end
            end)
        end
    end)
end)

-- 3. HÀM NHẢY SERVER "PRO MAX" (PHÒNG THỦ LỖI 773)
local function UltraHop()
    print("V29: Dang tim kiem Server an toan...")
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local target = nil
        -- Ưu tiên server cực vắng (1-2 người) để tránh lỗi Reconnect
        for _, v in pairs(result) do
            if v.playing < 3 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            -- "Làm nguội" hệ thống 12 giây để xóa sạch dấu vết Security Kick
            task.wait(12)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        else
            -- Nhảy ngẫu nhiên nếu không tìm thấy server vắng
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 4. TỰ ĐỘNG ĐỔI SERVER SAU 120 GIÂY (2 PHÚT)
task.spawn(function()
    while task.wait(120) do
        UltraHop()
    end
end)

-- 5. GIÁM SÁT TRẠNG THÁI KẾT NỐI (RECONNECT)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        print("V29: Phat hien mat ket noi, dang cuu ho...")
        UltraHop()
    end
end)

print("--- [Gemini] V29 ULTRA PRO MAX ACTIVE - BAT TU KICK ---")
