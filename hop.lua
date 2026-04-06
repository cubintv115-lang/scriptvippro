-- [[ V21 SILENT SHADOW - KHẮC PHỤC TRIỆT ĐỂ LỖI 773 KHI TREO ĐÊM ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Hàm lấy Server cực vắng (Chống nghẽn mạng)
local function GetVerySafeServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            -- Chỉ chọn server trống ít nhất 12 chỗ
            if v.playing < (v.maxPlayers - 12) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function UltimateSilentHop()
    -- 1. XÓA BẢNG LỖI NGAY LẬP TỨC ĐỂ GIẢI PHÓNG MÀN HÌNH
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    -- 2. CHIẾN THUẬT "LÀM NGUỘI": Đợi đúng 20 giây
    -- Đây là thời gian bắt buộc để Roblox xóa Session bị Blacklist của bạn
    -- Nếu nhảy nhanh hơn 20s, bạn sẽ LUÔN LUÔN bị lỗi 773
    print("He thong dang nghi ngoi 20s de xoa dau vet (Anti-773)...")
    task.wait(20)

    local target = GetVerySafeServer()
    if target then
        -- Nhảy 1 lần duy nhất nhưng cực kỳ chất lượng
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 1. TỰ ĐỘNG ĐỔI SERVER MỖI 2 PHÚT (NHƯ Ý BẠN)
task.spawn(function()
    while task.wait(120) do
        UltimateSilentHop()
    end
end)

-- 2. PHẢN XẠ KHI BỊ KICK (CHỜ 20S RỒI MỚI NHẢY)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Bi Kick! Dang cho 20s de vao lai mượt mà...")
        UltimateSilentHop()
    end
end)

-- 3. QUÉT BẢNG LỖI 773 ĐỂ TỰ ĐỘNG NHẢY LẠI (SAU 20S)
task.spawn(function()
    while task.wait(1) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            UltimateSilentHop()
        end
    end
end)

print("--- [Gemini] V21 SILENT SHADOW: DA KICH HOAT ---")
