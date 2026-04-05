local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 1. CƠ CHẾ NHẢY SERVER AN TOÀN TUYỆT ĐỐI
local function UltimateSafeHop()
    print("--- [Gemini] Dang thuc hien lam moi ket noi... ---")
    local success, result = pcall(function()
        -- Lay danh sach server voi bo loc rong rai hon (100 server)
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            -- CHỈ CHỌN SERVER CÒN TRỐNG ÍT NHẤT 5 CHỖ (De tranh loi 773 va mat ket noi)
            if v.playing < (v.maxPlayers - 5) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local randomServer = targetServers[math.random(1, #targetServers)]
            -- Truoc khi nhay, doi 5s de Roblox xoa cache cu
            task.wait(5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 2. TỰ ĐỘNG LÀM MỚI SAU 1 TIẾNG (Tránh treo quá lâu dẫn đến lag IP)
task.spawn(function()
    while task.wait(3600) do -- Cu moi 1 tieng (3600 giay) tu dong chuyen server 1 lan
        print("--- Treo da lau, tu dong doi server de tranh lag Session ---")
        UltimateSafeHop()
    end
end)

-- 3. THEO DÕI LỖI MẠNG (Mã lỗi 773, 277, 279,...)
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        print("Phat hien loi ket noi. Dang doi 15s de Reset...")
        task.wait(15) -- Doi 15s la thoi gian vang de nha mang nha IP
        UltimateSafeHop()
    end
end)

-- 4. QUÉT BẢNG LỖI CỨNG ĐẦU
task.spawn(function()
    while task.wait(10) do
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("RobloxPromptGui") and coreGui.RobloxPromptGui:FindFirstChild("promptOverlay") then
            if coreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt") then
                UltimateSafeHop()
            end
        end
    end
end)

print("--- [Gemini V4] Anti-Disconnect & Auto Refresh Loaded! ---")
