-- [[ V15 BLACK HOLE - ULTIMATE FORCE JOIN & ANTI-KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local ReservedServer = nil

-- HÀM 1: LUÔN LUÔN LẤY SẴN 1 SERVER DỰ PHÒNG (PRE-FETCH)
local function UpdateReservedServer()
    pcall(function()
        local result = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        local safe = {}
        for _, v in pairs(result) do
            -- Chỉ lấy server cực vắng (trống 8 chỗ) để đảm bảo KHÔNG BAO GIỜ lỗi kết nối
            if v.playing < (v.maxPlayers - 8) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        if #safe > 0 then
            ReservedServer = safe[math.random(1, #safe)]
        end
    end)
end

-- Cập nhật "vé dự phòng" mỗi 30 giây
task.spawn(function()
    while task.wait(30) do
        UpdateReservedServer()
    end
end)
UpdateReservedServer() -- Chạy lần đầu

-- HÀM 2: ÉP NHẢY NGAY LẬP TỨC (DÙNG VÉ CÓ SẴN)
local function InstantBlackHoleHop()
    if ReservedServer then
        -- Nhảy liên tục 10 lần (Spam cực mạnh trong 0.1 giây)
        for i = 1, 10 do
            TeleportService:TeleportToPlaceInstance(game.PlaceId, ReservedServer, Players.LocalPlayer)
        end
    else
        -- Nếu chưa kịp có vé dự phòng, nhảy đại theo PlaceId
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 1. CHẾ ĐỘ 2 PHÚT TỰ ĐỔI SERVER (NHƯ Ý BẠN)
task.spawn(function()
    while task.wait(120) do
        InstantBlackHoleHop()
    end
end)

-- 2. PHẢN XẠ "TỬ THẦN": NHẢY KHI THẤY BẤT KỲ LỖI NÀO
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        InstantBlackHoleHop()
    end
end)

-- 3. QUÉT CORE GUI SIÊU TỐC (0.05 GIÂY)
task.spawn(function()
    while task.wait(0.05) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            InstantBlackHoleHop()
            break
        end
    end
end)

-- 4. TỰ ĐỘNG BẤM NÚT RECONNECT NGẦM (DÙNG VIRTUAL INPUT)
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" then
        InstantBlackHoleHop()
    end
end)

print("--- [Gemini] V15 BLACK HOLE: KHOA MUC TIEU SAN SANG ---")
