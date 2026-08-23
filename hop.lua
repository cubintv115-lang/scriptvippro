--[[
    BANANA HUB - UI COMPLETE EDITION
    --------------------------------
    - Giữ kiểu nút đóng/mở dạng nút tròn nổi giống ảnh mẫu.
    - Có Search for Function hoạt động.
    - Có các tab Farm / Fruit / Misc / Travel.
    - Có toggle cho các chức năng.
    - KHÔNG bao gồm anti-cheat bypass / metatable hook.

    Lưu ý:
    Các chức năng gameplay cần remote/API phù hợp với phiên bản game
    mới có thể hoạt động thực tế. Phần GUI/search/toggle hoạt động độc lập.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Character
local Humanoid
local HumanoidRootPart

local function UpdateCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end

UpdateCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- ============================================================
-- STATE
-- ============================================================

local State = {
    AutoFarm = false,
    MasteryFarm = false,
    BossFarm = false,
    SeaBeast = false,
    AutoRaid = false,
    FruitSniper = false,
    NoClip = false,
    Fly = false,
    SpeedBoost = false,

    SpeedValue = 50,
    FlySpeed = 80,
    FarmRadius = 40,
}

-- ============================================================
-- GUI ROOT
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- FLOATING OPEN/CLOSE BUTTON
-- Kiểu nút tròn nổi: nền trắng + icon ở giữa.
-- ============================================================

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "MenuToggle"
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.Position = UDim2.new(0, 20, 0.5, -29)
OpenButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
OpenButton.BorderSizePixel = 0
OpenButton.Image = "rbxassetid://7072706796"
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.AutoButtonColor = false
OpenButton.ZIndex = 100
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(220, 220, 225)
OpenStroke.Thickness = 1
OpenStroke.Transparency = 0.15
OpenStroke.Parent = OpenButton

-- ============================================================
-- DRAG FLOATING BUTTON
-- ============================================================

do
    local dragging = false
    local dragStart
    local startPos

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = OpenButton.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            OpenButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(480, 520)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 70)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Header accent
local HeaderAccent = Instance.new("Frame")
HeaderAccent.Size = UDim2.new(1, 0, 0, 4)
HeaderAccent.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
HeaderAccent.BorderSizePixel = 0
HeaderAccent.Parent = MainFrame

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 50)),
})
AccentGradient.Parent = HeaderAccent

-- ============================================================
-- TITLE BAR
-- ============================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.Position = UDim2.fromOffset(0, 4)
TitleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(16, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍌 Banana Hub"
Title.TextColor3 = Color3.fromRGB(255, 210, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -38, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.BorderSizePixel = 0
CloseButton.AutoButtonColor = false
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseButton

-- ============================================================
-- SEARCH
-- ============================================================

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchForFunction"
SearchBox.Size = UDim2.new(1, -24, 0, 34)
SearchBox.Position = UDim2.fromOffset(12, 52)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Search for Function..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(125, 125, 145)
SearchBox.TextColor3 = Color3.fromRGB(235, 235, 245)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
SearchBox.Text = ""
SearchBox.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 12)
SearchPadding.PaddingRight = UDim.new(0, 12)
SearchPadding.Parent = SearchBox

-- ============================================================
-- TAB BAR
-- ============================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.fromOffset(12, 92)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

-- ============================================================
-- CONTENT
-- ============================================================

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -24, 1, -140)
ContentFrame.Position = UDim2.fromOffset(12, 136)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 210, 50)
ContentFrame.CanvasSize = UDim2.new()
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

-- ============================================================
-- HELPERS
-- ============================================================

local FunctionRows = {}

local function RegisterFunction(row, name)
    table.insert(FunctionRows, {
        Row = row,
        Name = string.lower(name),
    })
end

local function MakeSectionLabel(parent, text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 180, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = parent
    return label
end

local function MakeToggle(parent, labelText, stateKey, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.72, 0, 1, 0)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.fromOffset(44, 24)
    toggle.Position = UDim2.new(1, -56, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.BorderSizePixel = 0
    toggle.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local click = Instance.new("TextButton")
    click.Size = UDim2.fromScale(1, 1)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = row

    local function Refresh()
        local enabled = State[stateKey]

        TweenService:Create(toggle, TweenInfo.new(0.18), {
            BackgroundColor3 = enabled
                and Color3.fromRGB(255, 180, 0)
                or Color3.fromRGB(50, 50, 70)
        }):Play()

        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = enabled
                and UDim2.new(0, 23, 0.5, -9)
                or UDim2.new(0, 3, 0.5, -9),

            BackgroundColor3 = enabled
                and Color3.fromRGB(255, 255, 255)
                or Color3.fromRGB(160, 160, 180)
        }):Play()
    end

    click.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        Refresh()

        if callback then
            callback(State[stateKey])
        end
    end)

    Refresh()
    RegisterFunction(row, labelText)

    return row
end

local function MakeButton(parent, text, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    button.TextColor3 = Color3.fromRGB(20, 20, 30)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Text = text
    button.BorderSizePixel = 0
    button.LayoutOrder = order
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        }):Play()

        task.delay(0.12, function()
            if button.Parent then
                TweenService:Create(button, TweenInfo.new(0.08), {
                    BackgroundColor3 = Color3.fromRGB(255, 180, 0)
                }):Play()
            end
        end)

        if callback then
            callback()
        end
    end)

    RegisterFunction(button, text)
    return button
end

local function MakeSlider(parent, labelText, minValue, maxValue, defaultValue, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 56)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 22)
    label.Position = UDim2.fromOffset(10, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0, 6)
    track.Position = UDim2.new(0.05, 0, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue),
        0, 1, 0
    )
    fill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local currentValue = defaultValue
    local sliding = false

    local function update(x)
        local relative = math.clamp(
            (x - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )

        currentValue = math.floor(
            minValue + relative * (maxValue - minValue)
        )

        fill.Size = UDim2.new(relative, 0, 1, 0)
        label.Text = labelText .. ": " .. tostring(currentValue)

        if callback then
            callback(currentValue)
        end
    end

    label.Text = labelText .. ": " .. tostring(defaultValue)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            sliding = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    RegisterFunction(row, labelText)
    return row
end

local function MakeTab(name, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(90, 36)
    button.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    button.TextColor3 = Color3.fromRGB(160, 160, 180)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Text = name
    button.BorderSizePixel = 0
    button.LayoutOrder = order
    button.AutoButtonColor = false
    button.Parent = TabBar
    return button
end

-- ============================================================
-- PAGES
-- ============================================================

local Tabs = {
    Farm = MakeTab("⚔ Farm", 1),
    Fruit = MakeTab("🍎 Fruit", 2),
    Misc = MakeTab("⚙ Misc", 3),
    Travel = MakeTab("🗺 Travel", 4),
}

local Pages = {}

for name in pairs(Tabs) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    Pages[name] = page
end

local ActiveTab = "Farm"

local function SwitchTab(name)
    ActiveTab = name

    for pageName, page in pairs(Pages) do
        page.Visible = (pageName == name)
    end

    for tabName, tab in pairs(Tabs) do
        local active = tabName == name

        tab.BackgroundColor3 = active
            and Color3.fromRGB(30, 30, 46)
            or Color3.fromRGB(18, 18, 26)

        tab.TextColor3 = active
            and Color3.fromRGB(255, 210, 50)
            or Color3.fromRGB(160, 160, 180)
    end
end

for name, button in pairs(Tabs) do
    button.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

-- ============================================================
-- FARM
-- ============================================================

local FarmPage = Pages.Farm

MakeSectionLabel(FarmPage, "AUTO COMBAT", 1)

MakeToggle(FarmPage, "Auto Farm Mobs", "AutoFarm", 2)
MakeToggle(FarmPage, "Auto Mastery Farm", "MasteryFarm", 3)
MakeToggle(FarmPage, "Boss Auto Farm", "BossFarm", 4)
MakeToggle(FarmPage, "Sea Beast Farm", "SeaBeast", 5)
MakeToggle(FarmPage, "Auto Raid", "AutoRaid", 6)

MakeSectionLabel(FarmPage, "FARM RADIUS", 7)

MakeSlider(
    FarmPage,
    "Radius",
    10,
    150,
    State.FarmRadius,
    8,
    function(value)
        State.FarmRadius = value
    end
)

-- ============================================================
-- FRUIT
-- ============================================================

local FruitPage = Pages.Fruit

MakeSectionLabel(FruitPage, "FRUIT SNIPER", 1)

MakeToggle(
    FruitPage,
    "Fruit Notifier / Sniper",
    "FruitSniper",
    2
)

MakeButton(
    FruitPage,
    "Teleport to Nearest Fruit",
    3,
    function()
        if not HumanoidRootPart then return end

        local closest
        local distance = math.huge

        for _, object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("BasePart")
                and string.find(string.lower(object.Name), "fruit") then

                local d = (object.Position - HumanoidRootPart.Position).Magnitude

                if d < distance then
                    distance = d
                    closest = object
                end
            end
        end

        if closest then
            HumanoidRootPart.CFrame =
                CFrame.new(closest.Position + Vector3.new(0, 4, 0))
        end
    end
)

MakeButton(
    FruitPage,
    "Buy Storage Fruit",
    4,
    function()
        -- Remote path có thể thay đổi theo phiên bản game.
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")

        if remotes then
            local remote = remotes:FindFirstChild("BuyFruit")

            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            end
        end
    end
)

MakeButton(
    FruitPage,
    "Eat Fruit in Inventory",
    5,
    function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")

        if remotes then
            local remote = remotes:FindFirstChild("EatFruit")

            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            end
        end
    end
)

-- ============================================================
-- MISC
-- ============================================================

local MiscPage = Pages.Misc

MakeSectionLabel(MiscPage, "MOVEMENT", 1)

MakeToggle(
    MiscPage,
    "Fly",
    "Fly",
    2,
    function(enabled)
        if not enabled and HumanoidRootPart then
            local bv = HumanoidRootPart:FindFirstChild("BananaFlyVelocity")
            local bg = HumanoidRootPart:FindFirstChild("BananaFlyGyro")

            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
)

MakeToggle(
    MiscPage,
    "Speed Boost",
    "SpeedBoost",
    3,
    function(enabled)
        if Humanoid then
            Humanoid.WalkSpeed = enabled and State.SpeedValue or 16
        end
    end
)

MakeSlider(
    MiscPage,
    "Speed Value",
    16,
    250,
    State.SpeedValue,
    4,
    function(value)
        State.SpeedValue = value

        if State.SpeedBoost and Humanoid then
            Humanoid.WalkSpeed = value
        end
    end
)

MakeSlider(
    MiscPage,
    "Fly Speed",
    20,
    300,
    State.FlySpeed,
    5,
    function(value)
        State.FlySpeed = value
    end
)

MakeSectionLabel(MiscPage, "UTILITY", 6)

MakeToggle(MiscPage, "No Clip", "NoClip", 7)

MakeButton(
    MiscPage,
    "Rejoin Server",
    8,
    function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
)

-- ============================================================
-- TRAVEL
-- ============================================================

local TravelPage = Pages.Travel

MakeSectionLabel(TravelPage, "TELEPORT LOCATIONS", 1)

local Locations = {
    {"Starter Island (Sea 1)", Vector3.new(977,124,1430)},
    {"Jungle (Sea 1)", Vector3.new(230,124,1580)},
    {"Pirate Village (Sea 1)", Vector3.new(-1371,124,-1312)},
    {"Middle Town (Sea 1)", Vector3.new(285,124,-505)},
    {"Marine Fortress (Sea 1)", Vector3.new(-3003,196,-533)},
    {"Skylands (Sea 1)", Vector3.new(-4817,845,-985)},
    {"Colosseum (Sea 1)", Vector3.new(-1345,133,3817)},
    {"Magma Village (Sea 1)", Vector3.new(-5095,124,-701)},
    {"Underwater City (Sea 1)", Vector3.new(-5085,7,1024)},
    {"Kingdom of Rose (Sea 2)", Vector3.new(-201,73,-1520)},
    {"Green Zone (Sea 2)", Vector3.new(3808,92,-2450)},
    {"Graveyard (Sea 2)", Vector3.new(4600,92,-3300)},
    {"Snow Mountain (Sea 2)", Vector3.new(3024,610,-2958)},
    {"Hot & Cold (Sea 2)", Vector3.new(5490,92,-3750)},
    {"Haunted Castle (Sea 2)", Vector3.new(5248,340,-5300)},
    {"Sea of Treats (Sea 3)", Vector3.new(-14750,92,-2376)},
    {"Floating Turtle (Sea 3)", Vector3.new(-15200,400,-1800)},
    {"Mansion (Sea 3)", Vector3.new(-15300,124,-3100)},
}

for index, location in ipairs(Locations) do
    local name = location[1]
    local position = location[2]

    MakeButton(
        TravelPage,
        "► " .. name,
        index + 1,
        function()
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = CFrame.new(position)
            end
        end
    )
end

-- ============================================================
-- SEARCH ENGINE
-- Tìm cả Toggle / Button / Slider theo tên.
-- Khi đang search, tab không liên quan sẽ tự ẩn.
-- ============================================================

local function SearchFunctions(query)
    query = string.lower(query or "")
    query = string.gsub(query, "^%s+", "")
    query = string.gsub(query, "%s+$", "")

    if query == "" then
        for _, item in ipairs(FunctionRows) do
            item.Row.Visible = true
        end

        for pageName, page in pairs(Pages) do
            page.Visible = (pageName == ActiveTab)
        end

        return
    end

    -- Khi tìm kiếm: hiện các page để kết quả không bị giới hạn
    -- bởi tab hiện tại.
    for _, page in pairs(Pages) do
        page.Visible = true
    end

    for _, item in ipairs(FunctionRows) do
        item.Row.Visible = string.find(item.Name, query, 1, true) ~= nil
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    SearchFunctions(SearchBox.Text)
end)

-- ============================================================
-- MENU VISIBILITY
-- Nút nổi vẫn tồn tại khi menu đóng.
-- ============================================================

local MenuVisible = true

local OpenSize = UDim2.fromOffset(480, 520)
local ClosedSize = UDim2.fromOffset(0, 0)

local function SetMenuVisible(visible)
    MenuVisible = visible

    local targetSize = visible and OpenSize or ClosedSize
    local targetPosition = visible
        and UDim2.new(0.5, -240, 0.5, -260)
        or UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(
        MainFrame,
        TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {
            Size = targetSize,
            Position = targetPosition,
        }
    ):Play()
end

OpenButton.MouseButton1Click:Connect(function()
    SetMenuVisible(not MenuVisible)
end)

CloseButton.MouseButton1Click:Connect(function()
    SetMenuVisible(false)
end)

-- RightShift cũng đóng/mở menu
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        SetMenuVisible(not MenuVisible)
    end
end)

-- ============================================================
-- DRAG MAIN WINDOW
-- ============================================================

do
    local dragging = false
    local dragStart
    local startPosition

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            MainFrame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)
end

-- ============================================================
-- FLY LOOP
-- ============================================================

RunService:BindToRenderStep(
    "BananaHubFly",
    Enum.RenderPriority.Character.Value + 1,
    function()
        if not State.Fly then return end
        if not Character or not HumanoidRootPart then return end

        local bv = HumanoidRootPart:FindFirstChild("BananaFlyVelocity")
        local bg = HumanoidRootPart:FindFirstChild("BananaFlyGyro")

        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BananaFlyVelocity"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = HumanoidRootPart
        end

        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "BananaFlyGyro"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.D = 100
            bg.Parent = HumanoidRootPart
        end

        local camera = Workspace.CurrentCamera
        local velocity = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity += camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity -= camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity -= camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity += camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity += Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            velocity -= Vector3.yAxis
        end

        bv.Velocity =
            velocity.Magnitude > 0
            and velocity.Unit * State.FlySpeed
            or Vector3.zero

        bg.CFrame = camera.CFrame
    end
)

-- ============================================================
-- NOCLIP LOOP
-- ============================================================

RunService.Stepped:Connect(function()
    if not State.NoClip then return end
    if not Character then return end

    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- ============================================================
-- SIMPLE AUTO-FARM LOOP
-- ============================================================

RunService.Heartbeat:Connect(function()
    if not State.AutoFarm then return end
    if not Character or not HumanoidRootPart then return end

    local closest
    local closestDistance = math.huge

    for _, model in ipairs(Workspace:GetChildren()) do
        local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
        local targetRoot = model:FindFirstChild("HumanoidRootPart")

        if targetHumanoid
            and targetRoot
            and targetHumanoid.Health > 0
            and model ~= Character then

            local distance =
                (targetRoot.Position - HumanoidRootPart.Position).Magnitude

            if distance < closestDistance
                and distance <= State.FarmRadius then

                closestDistance = distance
                closest = targetRoot
            end
        end
    end

    if closest then
        HumanoidRootPart.CFrame =
            CFrame.new(closest.Position + Vector3.new(0, 0, 3))
    end
end)

-- ============================================================
-- FRUIT NOTIFIER
-- ============================================================

Workspace.ChildAdded:Connect(function(child)
    if not State.FruitSniper then return end

    if string.find(string.lower(child.Name), "fruit") then
        local notification = Instance.new("TextLabel")

        notification.Size = UDim2.fromOffset(320, 48)
        notification.Position = UDim2.new(0.5, -160, 0.1, 0)
        notification.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        notification.TextColor3 = Color3.fromRGB(20, 20, 30)
        notification.Font = Enum.Font.GothamBold
        notification.TextSize = 14
        notification.Text = "🍎 Fruit Spawned: " .. child.Name
        notification.ZIndex = 200
        notification.Parent = ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notification

        task.delay(5, function()
            if notification then
                notification:Destroy()
            end
        end)
    end
end)

-- ============================================================
-- INIT
-- ============================================================

SwitchTab("Farm")
SetMenuVisible(true)

print("[BananaHub] Loaded")
print("[BananaHub] Search for Function: ON")
print("[BananaHub] Menu toggle: floating button / RightShift")
