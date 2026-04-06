-- [[ V33 MAHORAGA ADAPTATION - THÍCH NGHI TỐI THƯỢNG ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. XOAY BÁNH XE: CHẶN MỌI ĐÒN ĐÁNH (KICK/DISCONNECT)
local function Adapt()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" or method == "Disconnect" then
            warn("--- [MAHORAGA] DA THICH NGHI VOI LENH KICK! ---")
            return nil 
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(Adapt)

-- 2. HÀM NHẢY SERVER (KỸ THUẬT PHÁT ĐẢO LỖI 773)
local function UltimateHop()
    -- Xóa bảng lỗi ngay lập tức
    pcall(function()
        local prompt = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if prompt then prompt:Destroy() end
    end)

    local success, result = pcall(function()
        -- Lấy server vắng nhất (1-2 người)
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)

    if success and result then
        local target = nil
        for _, v in pairs(result) do
            if v.playing < 3 and v.id ~= game.JobId then
                target = v.id
                break
            end
        end
        
        if target then
            print("Mahoraga: Dang nhay sang server moi sau 12s thich nghi...")
            task.wait(12) -- Thơi gian "xoay bánh xe" để Roblox không nhận diện IP
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. THÍCH NGHI VỚI LỖI MẤT KẾT NỐI (REJOIN TRỰC TIẾP)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        warn("Phat hien don danh moi! Dang thich nghi...")
        UltimateHop()
    end
end)

-- 4. QUÉT SIÊU TỐC 0.1S (KHÔNG CHO BẢNG LỖI HIỆN DIỆN)
task.spawn(function()
    while task.wait(0.1) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            UltimateHop()
        end
    end
end)

-- 5. TỰ ĐỘNG ĐỔI SERVER ĐỊNH KỲ (MỖI 2 PHÚT)
task.spawn(function()
    while task.wait(120) do
        UltimateHop()
    end
end)

print("--- [Gemini] V33 MAHORAGA ACTIVE: BAN DA THICH NGHI VOI MOI LOI ---")
