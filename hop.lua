-- [[ V19 THE LAST STAND - KHẮC PHỤC TRIỆT ĐỂ LỖI KẾT NỐI KHI TREO ĐÊM ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. HÀM LẤY SERVER CỰC VẮNG (ƯU TIÊN SERVER MỚI MỞ)
local function GetSuperSafeServer()
    local success, result = pcall(function()
        -- Lấy danh sách server sắp xếp theo kiểu ngẫu nhiên để tránh bị trùng lặp
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            -- Chỉ chọn server trống ít nhất 10 chỗ (Cực kỳ quan trọng để load nhanh)
            if v.playing < (v.maxPlayers - 10) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

-- 2. HÀM NHẢY SERVER CÓ "KHOẢNG NGHỈ" (ANT-BLOCK)
local function SafetyHop()
    -- Xóa bảng lỗi cũ nếu có
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local target = GetSuperSafeServer()
    if target then
        -- CHIẾN THUẬT: Đợi 15 giây để hệ thống Roblox "nhả" Session cũ hoàn toàn
        -- Đây là cách duy nhất để trị lỗi Reconnect Unsuccessful khi treo máy liên tục
        print("He thong dang nghi ngoi 15s de tranh bi chan ket noi...")
        task.wait(15)
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 3. TỰ ĐỘNG ĐỔI SERVER SAU 2 PHÚT (120 GIÂY)
task.spawn(function()
    while task.wait(120) do
        print("Da den 2 phut, dang thuc hien Safety Hop...")
        SafetyHop()
    end
end)

-- 4. PHẢN XẠ KHI BỊ KICK (CHỜ 15S RỒI MỚI NHẢY ĐỂ ĐẢM BẢO THÀNH CÔNG)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Phat hien loi ket noi! Dang cho 15s de tu dong ket noi lai...")
        SafetyHop()
    end
end)

-- 5. TỐI ƯU HÓA NETWORK (GIẢM LAG KHI LOAD SERVER)
settings().Network.IncomingReplicationLag = 0

print("--- [Gemini] V19 THE LAST STAND: TREO MAY AN TOAN ---")
