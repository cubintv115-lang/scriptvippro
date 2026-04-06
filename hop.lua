-- [[ V28 THE ETERNAL GUARDIAN - CHỐNG KICK & NHẢY SERVER SONG HÀNH ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. CƠ CHẾ "BẤT TỬ": Tự động chạy lại các hàm bảo vệ nếu bị script khác can thiệp
local function ProtectEnvironment()
    -- Chặn lệnh Kick (Dùng HookMetamethod để bảo mật cao nhất)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            warn("--- [Gemini] DA CHAN MOT LENH KICK TU SCRIPT BOUNTY ---")
            return nil -- Vô hiệu hóa lệnh Kick
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(ProtectEnvironment)

-- 2. HÀM TÌM SERVER "VẮNG NHƯ CHÙA BÀ ĐANH" (Tránh lỗi 773/772)
local function FindGhostServer()
    local success, result = pcall(function()
        -- Lấy server và lọc các server chỉ có 1-3 người (Cực kỳ an toàn để Rejoin)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    
    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing < 4 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        return target
    end
    return nil
end

-- 3. HÀM NHẢY SERVER KHẨN CẤP (FORCE JOIN)
local function EmergencyJump()
    -- Xóa sạch các bảng thông báo lỗi trên màn hình (Fix lỗi Disconnect/Kick bảng xám)
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local errorPrompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if errorPrompt then
            errorPrompt.Visible = false
            errorPrompt:Destroy()
        end
    end)

    local serverId = FindGhostServer()
    if serverId then
        print("Giam sat: Dang chuyen huong sang Server an toan...")
        -- Đợi 8 giây để hệ thống Roblox 'nhả' Session cũ, tránh lỗi 773
        task.wait(8)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, game.Players.LocalPlayer)
    else
        -- Nếu không tìm thấy server vắng, nhảy ngẫu nhiên để thoát khỏi server hiện tại
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 4. VÒNG LẶP GIÁM SÁT SONG HÀNH (Chạy độc lập với Script Bounty)
task.spawn(function()
    while task.wait(1) do
        -- Kiểm tra nếu có bảng lỗi xuất hiện hoặc bị mất kết nối
        if GuiService:GetErrorMessage() ~= "" or game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            EmergencyJump()
        end
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER MỖI 2 PHÚT (Để script Bounty không bị soi)
task.spawn(function()
    while task.wait(120) do
        print("V28: Den gio thay doi dia ban san Bounty...")
        EmergencyJump()
    end
end)

print("--- [Gemini] V28 ETERNAL ACTIVE: DANG CHAY SONG HANH VOI SCRIPT BOUNTY ---")
