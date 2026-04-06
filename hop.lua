-- [[ V16 SEA-CHECK & ANTI-ERROR 773 - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId -- Tự động lấy ID của Sea hiện tại (Sea 1, 2 hoặc 3)
local ReservedServer = nil

-- HÀM 1: LẤY SERVER CÙNG SEA (TRÁNH LỖI 773)
local function UpdateSafeServer()
    pcall(function()
        -- Lấy danh sách server của đúng PlaceId bạn đang đứng
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local result = HttpService:JSONDecode(game:HttpGet(url)).data
        local safe = {}
        
        for _, v in pairs(result) do
            -- Lọc server vắng (trống 8 chỗ) và không phải server hiện tại
            if v.playing < (v.maxPlayers - 8) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        
        if #safe > 0 then
            ReservedServer = safe[math.random(1, #safe)]
        end
    end)
end

-- Cập nhật vé dự phòng mỗi 30s
task.spawn(function()
    while task.wait(30) do UpdateSafeServer() end
end)
UpdateSafeServer()

-- HÀM 2: ÉP NHẢY BẤT CHẤP (FORCED JOIN)
local function ForceSeaHop()
    if ReservedServer then
        -- Nhảy liên tục để xuyên qua lỗi
        for i = 1, 5 do
            TeleportService:TeleportToPlaceInstance(PlaceId, ReservedServer, Players.LocalPlayer)
            task.wait(0.1)
        end
    else
        -- Nếu chưa có vé, nhảy mặc định vào Sea hiện tại
        TeleportService:Teleport(PlaceId)
    end
end

-- 1. CHẾ ĐỘ 2 PHÚT TỰ ĐỔI SERVER (NHƯ Ý BẠN)
task.spawn(function()
    while task.wait(120) do
        print("--- [Auto-Hop] 2 Phut - Dang doi Server cung Sea ---")
        ForceSeaHop()
    end
end)

-- 2. XỬ LÝ LỖI 773 VÀ CÁC LỖI DỊCH CHUYỂN KHÁC (NHẢY LẠI NGAY)
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        warn("Phat hien loi: " .. msg)
        task.wait(2) -- Nghỉ 2s để hệ thống reset rồi nhảy lại
        ForceSeaHop()
    end
end)

-- 3. QUÉT BẢNG "DỊCH CHUYỂN THẤT BẠI" ĐỂ TỰ ĐỘNG BẤM OK/NHẢY TIẾP
task.spawn(function()
    while task.wait(0.5) do
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then
            ForceSeaHop()
        end
    end
end)

print("--- [Gemini] V16 SEA-CHECK ACTIVE - CHONG LOI 773 ---")
