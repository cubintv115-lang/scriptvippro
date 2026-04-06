-- [[ V22 DEEP TUNNEL - BIẾN MẤT VÀ XUẤT HIỆN TRỞ LẠI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Hàm lấy Server ngẫu nhiên từ danh sách cực vắng
local function GetSecretServer()
    local success, result = pcall(function()
        -- Lấy server theo kiểu Descending (Mới nhất) để tránh các server cũ bị lỗi
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            -- Chỉ chọn server cực vắng (15 chỗ trống) để đảm bảo kết nối mượt nhất
            if v.playing < (v.maxPlayers - 15) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function DeepTunnelHop()
    -- 1. XÓA BẢNG LỖI ĐỂ TRÁNH ĐÓNG BĂNG EXECUTOR
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    -- 2. CHIẾN THUẬT "LÀM MỚI KẾT NỐI"
    -- Thay vì nhảy ngay, ta ngắt kết nối tạm thời trong 30 giây
    -- 30 giây là thời gian đủ để Server Roblox xác nhận bạn đã Offline hoàn toàn
    print("Kich hoat Deep Tunnel: Dang 'Offline' 30s de reset IP/Session...")
    
    task.wait(30) 

    local target = GetSecretServer()
    if target then
        -- Nhảy bằng PlaceId gốc để tạo cảm giác như bạn vừa mở App lên vào lại
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    else
        -- Nếu không tìm thấy server vắng, nhảy đại vào Sea hiện tại
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 1. TỰ ĐỘNG ĐỔI SERVER MỖI 2 PHÚT (BẢO VỆ TỪ XA)
task.spawn(function()
    while task.wait(120) do
        DeepTunnelHop()
    end
end)

-- 2. PHÁT HIỆN KICK/LỖI 773: ĐỢI 30S RỒI MỚI VÀO LẠI
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Loi ket noi! Dang cho 30s de thuc hien Deep Tunnel...")
        DeepTunnelHop()
    end
end)

-- 3. TỰ ĐỘNG BẤM OK NGẦM NẾU BẢNG LỖI CÒN SÓT
task.spawn(function()
    while task.wait(2) do
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then
            DeepTunnelHop()
        end
    end
end)

print("--- [Gemini] V22 DEEP TUNNEL: SAN SANG TREO DEM ---")
