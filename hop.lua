-- [[ V53 THE WORLD REBIRTH - ÉP NHẢY SERVER KHI PING -1MS ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- 1. HÀM NHẢY SERVER "TÁI SINH" (CƯỠNG CHẾ KẾT NỐI MỚI)
local function RebirthHop()
    -- Xóa bảng lỗi và reset trạng thái GUI ngay lập tức
    pcall(function()
        GuiService:ClearError()
        local coreGui = game:GetService("CoreGui")
        local prompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    -- Lấy danh sách server (Ưu tiên server 6-10 người để lách lỗi 773)
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing >= 6 and v.playing <= 10 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            warn("V53: Phát hiện kẹt mạng! Đang ép nhảy server...")
            -- Đòn 1: Nhảy trực tiếp vào server cụ thể
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
            
            -- Đòn 2 (Dự phòng cực mạnh): Nếu sau 1.5s chưa nhảy được, dùng lệnh nhảy thô
            task.delay(1.5, function()
                TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
        end
    end
end

-- 2. XOAY BÁNH XE: CHẶN KICK & GỌI NHẢY ĐỒNG THỜI
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" or method == "Disconnect" then
        -- Vừa chặn vừa gọi lệnh nhảy ngay lập tức trong 1 micro giây
        task.spawn(RebirthHop)
        return nil 
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- 3. CẢM BIẾN TỬ HUYỆT (FIX PING -1MS TRONG ẢNH)
-- Sử dụng RenderStepped để quét nhanh hơn cả nhịp tim của game
RunService.RenderStepped:Connect(function()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    -- Trong ảnh bạn gửi Ping luôn là -1ms (<= 0)
    if ping <= 0 then
        RebirthHop()
    end
end)

-- 4. THEO DÕI BẢNG LỖI 773/267 (DÙNG CHO DELTA)
GuiService.ErrorMessageChanged:Connect(function()
    RebirthHop()
end)

-- 5. CHU KỲ NHẢY "DU KÍCH" (MỖI 30 GIÂY)
-- Nhảy cực nhanh để Security không kịp khóa luồng dữ liệu của bạn
task.spawn(function()
    while task.wait(30) do
        RebirthHop()
    end
end)

print("--- [Gemini] V53 WORLD REBIRTH: PHÁ GIẢI ĐỨNG HÌNH ---")
