local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Hàm thực hiện nhảy ngay lập tức
local function InstantHop()
    local PlaceId = game.PlaceId
    -- Lấy danh sách server nhanh nhất có thể
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=20"))
    end)
    
    if success and result and result.data then
        for _, v in pairs(result.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, v.id, game.Players.LocalPlayer)
                return -- Thoát hàm ngay khi tìm thấy 1 server
            end
        end
    end
    -- Nếu lỗi hoặc không tìm thấy server cụ thể, nhảy đại vào server ngẫu nhiên của Roblox
    TeleportService:Teleport(PlaceId)
end

-- Bắt sự kiện lỗi là nhảy ngay không đợi 1 giây nào
GuiService.ErrorMessageChanged:Connect(function()
    local errorMsg = GuiService:GetErrorMessage()
    if errorMsg ~= "" then
        InstantHop()
    end
end)

-- Theo dõi bảng thông báo lỗi để ép nhảy
spawn(function()
    while true do
        local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("promptOverlay") then
            InstantHop()
        end
        task.wait(0.5) -- Kiểm tra mỗi 0.5 giây
    end
end)

print("--- [Instant Hop] Đã kích hoạt chế độ nhảy thần tốc ---")
