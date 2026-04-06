-- [[ V30 THE GOD PARTICLE - FINAL ULTRA PRO MAX REJOIN ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. PHÒNG TUYẾN TỐI CAO: CHẶN KICK NGAY TỪ PHIÊN BẢN CỦA ROBLOX
local function GodMode()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            warn("--- [V30] HE THONG DA CHAN DUNG AM MUU KICK BAN! ---")
            return nil
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(GodMode)

-- 2. HÀM NHẢY SERVER "THẦN TỐC" (Sử dụng API mới nhất)
local function GodHop()
    -- Xóa bảng lỗi ngay lập tức để rã đông máy
    pcall(function()
        local errorPrompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then errorPrompt:Destroy() end
    end)

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        -- Tìm server cực vắng (chỉ 1 người) để đảm bảo không bao giờ lỗi 773
        local target = nil
        for _, v in pairs(result) do
            if v.playing < 2 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("V30: Dang bay sang Server moi...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. KỸ THUẬT "HỒI SINH": Kích hoạt ngay khi game có dấu hiệu đóng lại
game.OnClose = function()
    GodHop()
end

-- 4. THEO DÕI GUI (Nếu bảng lỗi xuất hiện là nhảy ngay trong 0.1s)
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" or child:FindFirstChild("ErrorMessagePrompt") then
        GodHop()
    end
end)

-- 5. VÒNG LẶP KIỂM TRA MẤT KẾT NỐI (REJOIN CỰC MẠNH)
task.spawn(function()
    while task.wait(1) do
        if GuiService:GetErrorMessage() ~= "" then
            GodHop()
        end
    end
end)

-- 6. TỰ ĐỘNG ĐỔI SERVER SAU 2 PHÚT
task.spawn(function()
    while task.wait(120) do GodHop() end
end)

print("--- [Gemini] V30 GOD PARTICLE: PHÒNG TUYẾN CUỐI CÙNG ĐÃ KÍCH HOẠT ---")
