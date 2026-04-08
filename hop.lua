-- Blox Fruits INSTANT Anti-Kick Hop
-- HOP NGAY LẬP TỨC khi phát hiện kick message!

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

getgenv().InstantHop = {
    Enabled = true,
    InstantHop = true
}

-- Danh sách KICK MESSAGES (cập nhật mới nhất)
local KICK_MESSAGES = {
    "You have been kicked",
    "Kicked from this game", 
    "Kicked from server",
    "Anti-Cheat detected",
    "You are using exploits",
    "Blox Fruits Anti-Cheat",
    "Server hop detected",
    "Unauthorized script",
    "Exploit detected",
    "You have been banned",
    "Kick",
    "kicked"
}

-- 🔥 FUNCTION HOP SIÊU NHANH
local function INSTANT_HOP()
    spawn(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "🚀 INSTANT HOP";
            Text = "KICK detected! Hopping NOW...";
            Duration = 1
        })
        
        wait(0.1) -- Delay siêu nhỏ
        
        -- Hop ngay lập tức
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

-- 🕵️ CHECK KICK MESSAGE SIÊU NHANH (0.1s)
spawn(function()
    while getgenv().InstantHop.Enabled do
        pcall(function()
            -- Scan tất cả TextLabel/TextButton
            for _, obj in pairs(playerGui:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text then
                    local text = string.lower(obj.Text)
                    
                    -- Check từng kick message
                    for _, kickMsg in pairs(KICK_MESSAGES) do
                        if text:find(string.lower(kickMsg)) then
                            print("🔥 KICK MESSAGE DETECTED:", obj.Text)
                            INSTANT_HOP()
                            return -- Thoát ngay lập tức
                        end
                    end
                end
            end
        end)
        wait(0.1) -- Scan cực nhanh 10 lần/giây
    end
end)

-- 🛡️ BLOCK KICK FUNCTION (Backup)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().InstantHop.Enabled and method == "Kick" then
        print("🛡️ BLOCKED KICK:", args[1])
        INSTANT_HOP()
        return
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 📱 GUI SIÊU NHỎ (F1 toggle)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InstantHopGUI"
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 40)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "🚀 Instant Hop"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, 0, 0.5, 0)
Toggle.Position = UDim2.new(0, 0, 0.5, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Toggle.Text = "✅ ACTIVE"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    getgenv().InstantHop.Enabled = not getgenv().InstantHop.Enabled
    Toggle.Text = getgenv().InstantHop.Enabled and "✅ ACTIVE" or "❌ OFF"
    Toggle.BackgroundColor3 = getgenv().InstantHop.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- F1 HOTKEY
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        Toggle.MouseButton1Click:Fire()
    end
end)

print("✅ INSTANT HOP LOADED!")
print("⚡ Scan 10 lần/giây - Hop NGAY LẬP TỨC!")
print("📱 F1 toggle | GUI góc trên trái")

game.StarterGui:SetCore("SendNotification", {
    Title = "🚀 Instant Hop";
    Text = "Hop NGAY khi có kick! F1 toggle";
    Duration = 4
})
