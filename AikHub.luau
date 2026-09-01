--[[
    ========================================================================
    AikHub - Universal Developer Sandbox & Tooling Suite (Single File)
    ========================================================================
    A standalone, single-file Luau script. Can be executed directly in
    Roblox Studio (StarterPlayerScripts / Command Bar) or via an in-game runner.

    Controls:
    - [Right Shift] : Toggle Window Visibility
    - Click & Drag Topbar : Move Window
    - [X] Button : Minimize / Hide
    ========================================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Prevent duplicate UI instances if re-executed
local existingUI = PlayerGui:FindFirstChild("AikHubUI")
if existingUI then
    existingUI:Destroy()
end

-- ========================================================================
-- 1. THEME DEFINITIONS
-- ========================================================================
local Theme = {
    Background = Color3.fromRGB(22, 22, 26),
    Header = Color3.fromRGB(16, 16, 20),
    Sidebar = Color3.fromRGB(18, 18, 22),
    TabActive = Color3.fromRGB(36, 36, 44),
    TabInactive = Color3.fromRGB(24, 24, 30),
    Accent = Color3.fromRGB(0, 162, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    ElementBackground = Color3.fromRGB(30, 30, 36),
    ElementHover = Color3.fromRGB(40, 40, 48),
    TextPrimary = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(150, 150, 160),
    Border = Color3.fromRGB(42, 42, 52),
    Success = Color3.fromRGB(46, 204, 113),
}

local function tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local anim = TweenService:Create(instance, tweenInfo, properties)
    anim:Play()
    return anim
end

-- ========================================================================
-- 2. CORE SCREEN GUI & CONTAINERS
-- ========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Floating Toast Notifications
local notifContainer = Instance.new("Frame")
notifContainer.Name = "NotificationContainer"
notifContainer.Size = UDim2.new(0, 280, 1, -40)
notifContainer.Position = UDim2.new(1, -290, 0, 20)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 100
notifContainer.Parent = ScreenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)
notifLayout.Parent = notifContainer

local function Notify(titleText, descText, duration)
    duration = duration or 3.5

    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 56)
    notif.BackgroundColor3 = Theme.Header
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.Parent = notifContainer

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 6)
    nCorner.Parent = notif

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Theme.Border
    nStroke.Thickness = 1
    nStroke.Transparency = 1
    nStroke.Parent = notif

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -16, 0, 20)
    nTitle.Position = UDim2.new(0, 10, 0, 6)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = titleText
    nTitle.TextColor3 = Theme.Accent
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 13
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.TextTransparency = 1
    nTitle.Parent = notif

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -16, 0, 22)
    nDesc.Position = UDim2.new(0, 10, 0, 26)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = descText
    nDesc.TextColor3 = Theme.TextSecondary
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 11
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.TextTransparency = 1
    nDesc.Parent = notif

    tween(notif, {BackgroundTransparency = 0}, 0.2)
    tween(nStroke, {Transparency = 0}, 0.2)
    tween(nTitle, {TextTransparency = 0}, 0.2)
    tween(nDesc, {TextTransparency = 0}, 0.2)

    task.delay(duration, function()
        if notif and notif.Parent then
            local fadeOut = tween(notif, {BackgroundTransparency = 1}, 0.2)
            tween(nStroke, {Transparency = 1}, 0.2)
            tween(nTitle, {TextTransparency = 1}, 0.2)
            tween(nDesc, {TextTransparency = 1}, 0.2)
            fadeOut.Completed:Connect(function()
                notif:Destroy()
            end)
        end
    end)
end

-- ========================================================================
-- 3. MAIN WINDOW & DRAGGING
-- ========================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 400)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Border
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0, 260, 0, 20)
titleLabel.Position = UDim2.new(0, 14, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AikHub Console"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "SubtitleLabel"
subtitleLabel.Size = UDim2.new(0, 260, 0, 14)
subtitleLabel.Position = UDim2.new(0, 14, 0, 24)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Developer Sandbox & Testing [RightShift to Toggle]"
subtitleLabel.TextColor3 = Theme.TextSecondary
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 10
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 9)
closeBtn.BackgroundColor3 = Theme.ElementBackground
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Window Dragging
local isDragging = false
local dragInput, mousePos, framePos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- Keybind Toggle
local isVisible = true
local function setVisible(vis)
    isVisible = vis
    MainFrame.Visible = vis
end

closeBtn.MouseButton1Click:Connect(function()
    setVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

-- Sidebar & Content Frame
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 4)
tabListLayout.Parent = Sidebar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 8)
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -44)
ContentArea.Position = UDim2.new(0, 150, 0, 44)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ========================================================================
-- 4. TAB & CONTROL CONSTRUCTORS
-- ========================================================================
local Tabs = {}

local function createTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 30)
    tabButton.BackgroundColor3 = Theme.TabInactive
    tabButton.Text = tabName
    tabButton.TextColor3 = Theme.TextSecondary
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 12
    tabButton.BorderSizePixel = 0
    tabButton.Parent = Sidebar

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 5)
    tCorner.Parent = tabButton

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Border
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local tabObj = {
        Button = tabButton,
        Page = page,
        Name = tabName,
    }

    local function selectTab()
        for _, t in ipairs(Tabs) do
            t.Page.Visible = false
            tween(t.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TextSecondary}, 0.15)
        end
        page.Visible = true
        tween(tabButton, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.Accent}, 0.15)
    end

    tabButton.MouseButton1Click:Connect(selectTab)
    if #Tabs == 0 then
        selectTab()
    end

    table.insert(Tabs, tabObj)

    -- Section Header
    function tabObj:AddSection(text)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, 0, 0, 22)
        sec.BackgroundTransparency = 1
        sec.Text = text
        sec.TextColor3 = Theme.Accent
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 12
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = page
        return sec
    end

    -- Button
    function tabObj:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Theme.ElementBackground
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 5)
        bCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback) end
        end)
        return btn
    end

    -- Toggle Switch
    function tabObj:AddToggle(text, defaultState, callback)
        local state = defaultState or false

        local container = Instance.new("TextButton")
        container.Size = UDim2.new(1, 0, 0, 32)
        container.BackgroundColor3 = Theme.ElementBackground
        container.Text = ""
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 5)
        cCorner.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local swBg = Instance.new("Frame")
        swBg.Size = UDim2.new(0, 34, 0, 18)
        swBg.Position = UDim2.new(1, -42, 0.5, -9)
        swBg.BackgroundColor3 = state and Theme.Accent or Theme.Header
        swBg.BorderSizePixel = 0
        swBg.Parent = container

        local swCorner = Instance.new("UICorner")
        swCorner.CornerRadius = UDim.new(1, 0)
        swCorner.Parent = swBg

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        knob.BackgroundColor3 = Theme.TextPrimary
        knob.BorderSizePixel = 0
        knob.Parent = swBg

        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob

        local function update(newState)
            state = newState
            tween(swBg, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.15)
            tween(knob, {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}, 0.15)
            if callback then task.spawn(callback, state) end
        end

        container.MouseButton1Click:Connect(function()
            update(not state)
        end)
    end

    -- Slider
    function tabObj:AddSlider(text, minVal, maxVal, defaultVal, callback)
        local val = defaultVal or minVal
        minVal = minVal or 0
        maxVal = maxVal or 100

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 46)
        container.BackgroundColor3 = Theme.ElementBackground
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 5)
        cCorner.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 0, 18)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 50, 0, 18)
        valLbl.Position = UDim2.new(1, -58, 0, 4)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val)
        valLbl.TextColor3 = Theme.Accent
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(1, -20, 0, 6)
        track.Position = UDim2.new(0, 10, 0, 28)
        track.BackgroundColor3 = Theme.Header
        track.BorderSizePixel = 0
        track.Text = ""
        track.Parent = container

        local trkCorner = Instance.new("UICorner")
        trkCorner.CornerRadius = UDim.new(1, 0)
        trkCorner.Parent = track

        local fill = Instance.new("Frame")
        local ratio = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(1, 0)
        fCorner.Parent = fill

        local isSliding = false

        local function updateSlide(input)
            local trackX = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            local relX = math.clamp(input.Position.X - trackX, 0, trackWidth)
            local r = relX / trackWidth
            val = math.floor(minVal + (maxVal - minVal) * r)
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(r, 0, 1, 0)
            if callback then task.spawn(callback, val) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                updateSlide(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlide(input)
            end
        end)
    end

    -- Text Box
    function tabObj:AddTextBox(placeholder, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundColor3 = Theme.ElementBackground
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 5)
        cCorner.Parent = container

        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -20, 1, 0)
        tb.Position = UDim2.new(0, 10, 0, 0)
        tb.BackgroundTransparency = 1
        tb.PlaceholderText = placeholder or "Enter text..."
        tb.PlaceholderColor3 = Theme.TextSecondary
        tb.Text = ""
        tb.TextColor3 = Theme.TextPrimary
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 12
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = false
        tb.Parent = container

        tb.FocusLost:Connect(function(enterPressed)
            if callback then task.spawn(callback, tb.Text, enterPressed) end
        end)
    end

    return tabObj
end

-- ========================================================================
-- 5. REGISTER TABS & HOOK ACTIONS
-- ========================================================================

-- TAB: Player Movement & Physics
local PlayerTab = createTab("Player")
PlayerTab:AddSection("Locomotion Controls")

PlayerTab:AddSlider("WalkSpeed", 16, 150, 16, function(v)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then humanoid.WalkSpeed = v end
end)

PlayerTab:AddSlider("Jump Power", 50, 250, 50, function(v)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid.UseJumpPower then
            humanoid.JumpPower = v
        else
            humanoid.JumpHeight = v / 7.2
        end
    end
end)

PlayerTab:AddButton("Reset Character", function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then humanoid.Health = 0 end
    Notify("Character", "Character reset", 2)
end)

-- TAB: Diagnostics
local DiagTab = createTab("Diagnostics")
DiagTab:AddSection("Client Inspections")

DiagTab:AddToggle("FPS & Ping Overlay", false, function(enabled)
    Notify("Monitor", enabled and "FPS monitor active" or "FPS monitor stopped", 2)
end)

DiagTab:AddTextBox("Run Print Command", function(text, enter)
    if enter and text ~= "" then
        print("[AikHub Output]:", text)
        Notify("Command Output", text, 2.5)
    end
end)

-- TAB: Settings
local SettingsTab = createTab("Settings")
SettingsTab:AddSection("Console Config")

SettingsTab:AddButton("Send Test Alert", function()
    Notify("AikHub", "Single-file bundle running perfectly!", 3)
end)

SettingsTab:AddButton("Hide Window (RightShift to Open)", function()
    setVisible(false)
end)

-- Final Startup Notice
Notify("AikHub Active", "Loaded standalone script. Press Right Shift to toggle.", 4)
print("[AikHub] Single-file script loaded successfully.")
