-- Script tự động nhảy sang máy chủ mục tiêu khi bị kick hoặc tự chọn theo yêu cầu
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ─── THÔNG TIN MÁY CHỦ MỤC TIÊU ───
-- Thay thế bằng ID Place của server Blox Fruit (thường là 123456789)
local TARGET_PLACE_ID = 123456789
-- Để trống TARGET_JOB_ID nếu muốn nhảy vào server ngẫu nhiên
-- Hoặc điền ID phòng cụ thể nếu muốn nhảy vào 1 phòng riêng
local TARGET_JOB_ID = ""

-- ─── Tự động nhảy khi bị kick khỏi game ───
local function autoTeleport()
    -- Chờ 2 giây để tránh bị phát hiện quá nhanh
    task.wait(2)
    if TARGET_JOB_ID ~= "" then
        -- Nhảy vào phòng cụ thể
        TeleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, TARGET_JOB_ID, LocalPlayer)
    else
        -- Nhảy vào server ngẫu nhiên của cùng game
        TeleportService:Teleport(TARGET_PLACE_ID, LocalPlayer)
    end
    print(string.format("Đã tự động nhảy sang server: %s", TARGET_JOB_ID ~= "" and TARGET_JOB_ID or "server ngẫu nhiên"))
end

-- Lắng nghe sự kiện bị kick
LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        autoTeleport()
    end
end)

-- Kiểm tra liên tục nếu bị kick ra khỏi game
while task.wait(5) do
    if not LocalPlayer:IsDescendantOf(game) then
        autoTeleport()
    end
end
