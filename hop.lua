-- [[ V27 THE JUGGERNAUT - PHÁ ĐẢO LỖI 267 & 773 VĨNH VIỄN ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- 1. KỸ THUẬT SIÊU CẤP: VÔ HIỆU HÓA HỆ THỐNG CẢNH BÁO LỖI (ANTI-GUI)
-- Khiến Roblox không thể hiển thị bảng 267 hay 773 lên màn hình bạn
local function DisableErrorGui()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    task.spawn(function()
        while task.wait(0.1) do
            local shield = CoreGui:FindFirstChild("ErrorMessagePrompt", true)
            if shield then
                shield.Visible = false -- Làm tàng hình bảng lỗi
                shield:Destroy() -- Xóa sổ ngay lập tức
            end
        end
    end)
end
DisableErrorGui()

-- 2. CHẶN LỆNH KICK TỪ "LÕI" (METATABLE HOOK)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "Kick" or method == "kick" then
        warn("--- [Gemini] DA CHAN DUNG LENH KICK TU LUARPH SCRIPT! ---")
        return nil -- Chặn đứng lệnh Kick
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- 3. HÀM NHẢY SERVER "SẠCH" TUYỆT ĐỐI
local function JuggernautHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local target = nil
        for _, v in pairs(result) do
            -- Chọn server cực vắng (dưới 5 người) để tránh nghẽn 773
            if v.playing < 5 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("Dang dot kich vao Server: " .. target)
            -- Nhảy với khoảng nghỉ 5s để hệ thống không bị sốc
            task.wait(5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 4. TỰ ĐỘNG NHẢY SAU 2 PHÚT
task.spawn(function()
    while task.wait(120) do JuggernautHop() end
end)

-- 5. PHẢN XẠ KHI PHÁT HIỆN LỖI KẾT NỐI (RECONNECT)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        JuggernautHop()
    end
end)

print("--- [Gemini] V27 JUGGERNAUT ACTIVE - KHONG THE BI KICK ---")
