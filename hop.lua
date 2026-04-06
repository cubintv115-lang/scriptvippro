-- [[ V44 THE GENESIS REWRITE - BẢN THÍCH NGHI CUỐI CÙNG ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: PHÁ VỠ SỰ CÔ LẬP MẠNG
pcall(function()
    -- Xóa mọi bảng lỗi và reset trạng thái network của Client
    GuiService:ClearError()
    
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        -- Chặn đứng mọi lệnh Kick ngầm làm treo máy
        if method == "Kick" or method == "kick" then
            task.spawn(function() GenesisHop() end)
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- 2. HÀM NHẢY SERVER "TÁI SINH" (Ép buộc kết nối mới)
function GenesisHop()
    -- Cố gắng xóa bảng lỗi nếu nó vừa hiện ra trong 0.01s
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lấy danh sách server đông người (6-12) để đảm bảo server đó đang "sống"
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 6 and v.playing <= 12 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("Genesis: Đang phá vỡ đóng băng để nhảy Server...")
            -- Dùng chế độ Force Teleport
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Nếu sau 5s vẫn chưa nhảy được (do kẹt Ping -1ms), dùng lệnh nhảy dự phòng
            task.delay(5, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 3. THEO DÕI "TỬ HUYỆT" PING -1MS (CHỐNG TREO NHƯ TRONG ẢNH)
task.spawn(function()
    local checkCount = 0
    while task.wait(1) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        
        if ping <= 0 then
            checkCount = checkCount + 1
            -- Nếu kẹt quá 3 giây, thực hiện nhát cắt Genesis
            if checkCount >= 3 then
                warn("Phát hiện đóng băng mạng! Đang thực hiện Genesis Hop...")
                GenesisHop()
                checkCount = 0
                task.wait(10) -- Đợi tiến trình xử lý
            end
        else
            checkCount = 0
        end
    end
end)

-- 4. TỰ ĐỘNG LÀM MỚI SERVER MỖI 80 GIÂY
task.spawn(function()
    while task.wait(80) do GenesisHop() end
end)

print("--- [Gemini] V44 GENESIS REWRITE: HOÀN TẤT THÍCH NGHI ---")
