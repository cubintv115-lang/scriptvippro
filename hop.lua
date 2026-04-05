-- [[ ANTI-DISCONNECT & ULTIMATE SERVER HOP V4 ]]
if not game:IsLoaded() then game.Loaded:Wait() end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

-- Chống lỗi đứng Script khi nhảy Server
if syn and syn.queue_on_teleport then
    syn.queue_on_teleport([[print("Dang tiep tuc thuc thi Script sau khi Hop...")]])
elseif queue_on_teleport then
    queue_on_teleport([[print("Dang tiep tuc thuc thi Script sau khi Hop...")]])
end

local function UltimateHop()
    print("--- Dang tim kiem Server 'Sach' de tranh loi ket noi ---")
    local PlaceId = game.PlaceId
    local Success, Servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)

    if Success and Servers then
        local BestServers = {}
        for _, v in pairs(Servers) do
            -- Chỉ chọn server còn trống ít nhất 2 chỗ để tránh bị Full khi đang vào
            if type(v) == "table" and v.playing < (v.maxPlayers - 2) and v.id ~= game.JobId then
                table.insert(BestServers, v.id)
            end
        end

        if #BestServers > 0 then
            local Target = BestServers[math.random(1, #BestServers)]
            -- Thủ thuật: Đợi 3 giây để xóa Cache phiên cũ trước khi thực hiện Teleport
            task.wait(3)
            TeleportService:TeleportToPlaceInstance(PlaceId, Target, Players.LocalPlayer)
        else
            -- Nếu không tìm được server vắng, nhảy đại vào server bất kỳ
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        end
    end
end

-- BỘ LỌC LỖI TRIỆT ĐỂ
GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    -- Bắt tất cả các loại lỗi: Kick, Disconnect, Internet, Teleport Failed
    if msg ~= "" then
        warn("Loi he thong: " .. msg)
        -- QUAN TRỌNG: Nghỉ 10 giây để Server Roblox xác nhận bạn đã Offline hoàn toàn
        task.wait(10) 
        UltimateHop()
    end
end)

-- AUTO RECONNECT NẾU GAME BỊ ĐỨNG (IDLE)
spawn(function()
    while task.wait(5) do
        -- Nếu bị treo ở màn hình loading quá lâu
        if #Players:GetPlayers() <= 1 and game.Loaded then
            task.wait(5)
            UltimateHop()
        end
    end
end)

-- Tự động bấm nút "Leave" hoặc "Reconnect" ngầm để kích hoạt Script
local coreGui = game:GetService("CoreGui")
coreGui.ChildAdded:Connect(function(child)
    if child.Name == "ErrorMessagePrompt" then
        task.wait(2)
        UltimateHop()
    end
end)

print("--- [Gemini] Ultimate Hop V4: DA KICH HOAT ---")
