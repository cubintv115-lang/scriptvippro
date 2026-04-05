local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 1. HÀM NHẢY SERVER CƯỜNG ĐỘ CAO
local function ForceHop773()
    local success, result = pcall(function()
        -- Lấy danh sách server cực rộng (100 server)
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServers = {}
        for _, v in pairs(result.data) do
            -- CHỈ CHỌN SERVER TRỐNG ÍT NHẤT 6 CHỖ (Mức an toàn tuyệt đối cho lỗi 773)
            if v.playing < (v.maxPlayers - 6) and v.id ~= game.JobId then
                table.insert(targetServers, v.id)
            end
        end
        
        if #targetServers > 0 then
            local randomServer = targetServers[math.random(1, #targetServers)]
            -- ÉP ROBLOX PHẢI NHẢY
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- 2. PHÒNG BỆNH: TỰ ĐỘNG NHẢY MỖI 20 PHÚT
-- Admin thường kick sau một thời gian nhất định, nên mình nhảy trước khi bị kick.
task.spawn(function()
    while task.wait(1200) do -- 20 phút đổi server 1 lần
        print("Chu dong doi server de tranh bi Admin de y va loi 773...")
        ForceHop773()
    end
end)

-- 3. CỨU VÃN: NẾU BẢNG LỖI HIỆN LÊN
-- Dành cho Delta: Ép lệnh nhảy chạy ngay lập tức khi bảng vừa nhú lên
GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorMessage() ~= "" then
        -- Với lỗi 773, phải đợi 10s để hệ thống Teleport của Delta Reset
        task.wait(10)
        ForceHop773()
    end
end)

-- 4. ANTI-IDLE (Chống văng do đứng im)
Players.LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("--- [Delta Fix] Anti-773 Ultimate Loaded! ---")
