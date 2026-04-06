-- [[ V26 THE GOD MODE - FIX MOI LOI DISCONNECT & KICK ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. CHẶN LỆNH KICK (KHÔNG CHO HIỆN BẢNG LỖI 267)
local oldKick
oldKick = hookmetamethod(game:GetService("Players").LocalPlayer, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        warn("--- [Gemini] Da chan 1 lenh Kick tu Script Bounty! ---")
        return nil 
    end
    return oldKick(self, ...)
end)

-- 2. HÀM NHẢY SERVER SIÊU VẮNG (DÀNH RIÊNG CHO MÁY ANDROID/DELTA)
local function GetVeryEmptyServer()
    local success, result = pcall(function()
        -- Lấy danh sách server và chọn cái vắng nhất có thể
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            -- Chọn server trống ít nhất 12 chỗ để tránh lỗi 772 (Full)
            if v.playing < (v.maxPlayers - 12) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        return safe[math.random(1, #safe)]
    end
    return nil
end

local function ForcedJump()
    -- Xóa mọi bảng lỗi đang hiện trên màn hình (Diệt lỗi Disconnect)
    pcall(function()
        local errorGui = game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true)
        if errorGui then 
            errorGui:Destroy() 
        end
    end)

    local target = GetVeryEmptyServer()
    if target then
        -- Nghỉ 15 giây để Roblox reset kết nối hoàn toàn (Chống lỗi 773)
        print("He thong dang nghi 15s de Reset Session...")
        task.wait(15)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 3. TỰ ĐỘNG ĐỔI SERVER MỖI 2 PHÚT (CHỦ ĐỘNG TRÁNH SOI)
task.spawn(function()
    while task.wait(120) do
        print("Tu dong doi Server de tiep tuc san Bounty...")
        ForcedJump()
    end
end)

-- 4. PHÒNG TUYẾN CUỐI: XỬ LÝ KHI SCRIPT BOUNTY 'BỎ QUÊN' LỖI DISCONNECT
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg ~= "" then
        warn("Phat hien loi: " .. msg .. " - Dang kich hoat Force Jump!")
        ForcedJump()
    end
end)

-- 5. QUÉT BẢNG LỖI MỖI 1 GIÂY (DÀNH CHO LỖI 267)
task.spawn(function()
    while task.wait(1) do
        if game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            ForcedJump()
        end
    end
end)

print("--- [Gemini] V26 GOD MODE: TREO MAY BAT TU ---")
