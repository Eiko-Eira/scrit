local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startT = os.clock()
    while not LocalPlayer and (os.clock() - startT) < 5 do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.1)
    end
end

if not LocalPlayer then
    warn("[NIXHub] LocalPlayer not found. NIXHub must be run as a LocalScript.")
    return
end

local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then
            local canUse = pcall(function()
                local test = Instance.new("ScreenGui")
                test.Parent = h
                test:Destroy()
            end)
            if canUse then return h end
        end
    end
    local coreGui = nil
    pcall(function()
        coreGui = game:GetService("CoreGui")
    end)
    if coreGui then
        local canUseCore = pcall(function()
            local test = Instance.new("ScreenGui")
            test.Parent = coreGui
            test:Destroy()
        end)
        if canUseCore then return coreGui end
    end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    return pg
end

local guiParent = getGuiParent()
if not guiParent then
    local startP = os.clock()
    while not guiParent and (os.clock() - startP) < 10 do
        guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        task.wait(0.2)
    end
end

if not guiParent then
    warn("[NIXHub] Could not find a valid GUI parent container.")
    return
end

local Camera = workspace.CurrentCamera
if not Camera then
    local startC = os.clock()
    while not Camera and (os.clock() - startC) < 5 do
        Camera = workspace.CurrentCamera
        task.wait(0.1)
    end
end
if not Camera then
    Camera = workspace:FindFirstChildOfClass("Camera") or workspace:WaitForChild("Camera", 5)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        Camera = workspace.CurrentCamera
    end
end)

do
    local function cleanOld(c)
        if c and typeof(c) == "Instance" then
            pcall(function()
                local old = c:FindFirstChild("NIXHubUI")
                if old then old:Destroy() end
            end)
        end
    end
    cleanOld(guiParent)
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg and pg ~= guiParent then cleanOld(pg) end
    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg and cg ~= guiParent then cleanOld(cg) end
    end)
end

local Theme = {
    Background    = Color3.fromRGB(0,  0,  0),
    Header        = Color3.fromRGB(8,  8, 10),
    Sidebar       = Color3.fromRGB(4,  4,  6),
    TabActive     = Color3.fromRGB(255,255,255),
    TabActiveText = Color3.fromRGB(0,  0,  0),
    TabInactive   = Color3.fromRGB(8,  8, 10),
    TabInactiveText = Color3.fromRGB(130,130,140),
    Accent        = Color3.fromRGB(255,255,255),
    AccentDim     = Color3.fromRGB(180,180,190),
    ElementBg     = Color3.fromRGB(10, 10, 14),
    ElementHover  = Color3.fromRGB(20, 20, 26),
    ElementActive = Color3.fromRGB(32, 32, 40),
    TextPrimary   = Color3.fromRGB(255,255,255),
    TextSecondary = Color3.fromRGB(140,140,150),
    Border        = Color3.fromRGB(36, 36, 44),
    BorderBright  = Color3.fromRGB(255,255,255),
    Green         = Color3.fromRGB(80, 240,130),
    Red           = Color3.fromRGB(240,80, 80),
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
local parentOk = pcall(function()
    ScreenGui.Parent = guiParent
end)
if not parentOk or not ScreenGui.Parent then
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pg then ScreenGui.Parent = pg end
    end)
end

local NotifHolder
local notifCount = 0
do
    NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotifHolder"
    NotifHolder.Size = UDim2.new(0, 270, 1, -60)
    NotifHolder.Position = UDim2.new(1, -280, 0, 30)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.ZIndex = 200
    NotifHolder.Parent = ScreenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.Padding = UDim.new(0, 6)
    notifLayout.Parent = NotifHolder
end

local function Notify(title, desc, duration, color)
    duration = duration or 3
    color = color or Theme.Accent
    notifCount = notifCount + 1

    local card = Instance.new("Frame")
    card.Name = "Notif_" .. notifCount
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Theme.Header
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = notifCount
    card.Parent = NotifHolder

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Theme.Border
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = color
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(1, 0)
    abCorner.Parent = accentBar

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -18, 0, 18)
    nTitle.Position = UDim2.new(0, 12, 0, 6)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = string.upper(title)
    nTitle.TextColor3 = color
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 11
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.Parent = card

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -18, 0, 18)
    nDesc.Position = UDim2.new(0, 12, 0, 26)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = desc
    nDesc.TextColor3 = Theme.TextSecondary
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 11
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.Parent = card

    local prog = Instance.new("Frame")
    prog.Size = UDim2.new(1, 0, 0, 2)
    prog.Position = UDim2.new(0, 0, 1, -2)
    prog.BackgroundColor3 = color
    prog.BackgroundTransparency = 0.4
    prog.BorderSizePixel = 0
    prog.Parent = card

    card.Position = UDim2.new(1, 30, 0, 0)
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(prog, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0)}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MainShadow = Instance.new("Frame")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(0, 646, 0, 486)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.65
MainShadow.BorderSizePixel = 0
MainShadow.ZIndex = 9
MainShadow.Parent = ScreenGui

do
    local msCorner = Instance.new("UICorner")
    msCorner.CornerRadius = UDim.new(0, 12)
    msCorner.Parent = MainShadow

    local msStroke = Instance.new("UIStroke")
    msStroke.Color = Color3.fromRGB(0, 0, 0)
    msStroke.Thickness = 6
    msStroke.Transparency = 0.8
    msStroke.Parent = MainShadow
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 630, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.12
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

do
    local mfGradient = Instance.new("UIGradient")
    mfGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 16, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 10, 13))
    })
    mfGradient.Rotation = 45
    mfGradient.Parent = MainFrame

    local mfCorner = Instance.new("UICorner")
    mfCorner.CornerRadius = UDim.new(0, 8)
    mfCorner.Parent = MainFrame

    local mfStroke = Instance.new("UIStroke")
    mfStroke.Color = Theme.Border
    mfStroke.Thickness = 1
    mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mfStroke.Parent = MainFrame

    local topNeonBar = Instance.new("Frame")
    topNeonBar.Name = "TopNeonBar"
    topNeonBar.Size = UDim2.new(1, 0, 0, 2)
    topNeonBar.Position = UDim2.new(0, 0, 0, 0)
    topNeonBar.BackgroundColor3 = Theme.Accent
    topNeonBar.BorderSizePixel = 0
    topNeonBar.ZIndex = 50
    topNeonBar.Parent = MainFrame

    local MainBgImage = Instance.new("ImageLabel")
    MainBgImage.Name = "MainBgImage"
    MainBgImage.Size = UDim2.new(1, 0, 1, 0)
    MainBgImage.BackgroundTransparency = 1
    MainBgImage.ImageTransparency = 0.5
    MainBgImage.ScaleType = Enum.ScaleType.Crop
    MainBgImage.ZIndex = 1
    MainBgImage.Parent = MainFrame

    local GlassDarkener = Instance.new("Frame")
    GlassDarkener.Name = "GlassDarkener"
    GlassDarkener.Size = UDim2.new(1, 0, 1, 0)
    GlassDarkener.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    GlassDarkener.BackgroundTransparency = 0.35
    GlassDarkener.BorderSizePixel = 0
    GlassDarkener.ZIndex = 2
    GlassDarkener.Parent = MainFrame
end

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "NIXFloatToggle"
FloatToggle.Size = UDim2.new(0, 44, 0, 44)
FloatToggle.Position = UDim2.new(0, 16, 0.5, -22)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "NIX"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.Gotham
FloatToggle.TextSize = 12
FloatToggle.BorderSizePixel = 0
FloatToggle.AutoButtonColor = false
FloatToggle.ZIndex = 150
FloatToggle.Parent = ScreenGui

do
    local ftCorner = Instance.new("UICorner")
    ftCorner.CornerRadius = UDim.new(1, 0)
    ftCorner.Parent = FloatToggle

    local ftStroke = Instance.new("UIStroke")
    ftStroke.Color = Theme.BorderBright
    ftStroke.Thickness = 1.5
    ftStroke.Parent = FloatToggle

    local ftDragging, ftDragInput, ftMousePos, ftFramePos = false, nil, nil, nil
    FloatToggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            ftDragging = true
            ftMousePos = inp.Position
            ftFramePos = FloatToggle.Position
            tw(FloatToggle, {Size = UDim2.new(0, 40, 0, 40)}, 0.08)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and ftDragging then
            ftDragging = false
            tw(FloatToggle, {Size = UDim2.new(0, 44, 0, 44), Rotation = 0}, 0.2, Enum.EasingStyle.Back)
        end
    end)
    FloatToggle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then ftDragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == ftDragInput and ftDragging then
            local d = inp.Position - ftMousePos
            local tilt = math.clamp(d.X * 0.14, -12, 12)
            FloatToggle.Position = UDim2.new(ftFramePos.X.Scale, ftFramePos.X.Offset + d.X, ftFramePos.Y.Scale, ftFramePos.Y.Offset + d.Y)
            FloatToggle.Rotation = tilt
        end
    end)

    FloatToggle.MouseEnter:Connect(function()
        tw(FloatToggle, {Size = UDim2.new(0, 48, 0, 48), BackgroundColor3 = Theme.ElementActive}, 0.14, Enum.EasingStyle.Back)
        tw(ftStroke, {Color = Theme.Accent}, 0.14)
    end)
    FloatToggle.MouseLeave:Connect(function()
        if not ftDragging then
            tw(FloatToggle, {Size = UDim2.new(0, 44, 0, 44), BackgroundColor3 = Theme.Header}, 0.14)
            tw(ftStroke, {Color = Theme.BorderBright}, 0.14)
        end
    end)
end

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BackgroundTransparency = 0.08
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 15
TopBar.Parent = MainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = Theme.ElementBg
closeBtn.Text = "x"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = TopBar

do
    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = Theme.Border
    tbStroke.Thickness = 1
    tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tbStroke.Parent = TopBar

    local TopBarAccent = Instance.new("Frame")
    TopBarAccent.Name = "AccentLine"
    TopBarAccent.Size = UDim2.new(1, 0, 0, 1)
    TopBarAccent.Position = UDim2.new(0, 0, 1, -1)
    TopBarAccent.BorderSizePixel = 0
    TopBarAccent.BackgroundColor3 = Theme.BorderBright
    TopBarAccent.Parent = TopBar

    local tbaGradient = Instance.new("UIGradient")
    tbaGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 65, 85)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 240, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 65, 85))
    })
    tbaGradient.Parent = TopBarAccent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 190, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "N I X  H U B"
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = TopBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 220, 1, 0)
    subtitleLabel.Position = UDim2.new(0, 160, 0, 0)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "RSHIFT  *  TOGGLE"
    subtitleLabel.TextColor3 = Theme.TextSecondary
    subtitleLabel.Font = Enum.Font.Code
    subtitleLabel.TextSize = 10
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = TopBar

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 6, 0, 6)
    statusDot.Position = UDim2.new(1, -52, 0.5, -3)
    statusDot.BackgroundColor3 = Theme.Green
    statusDot.BorderSizePixel = 0
    statusDot.Parent = TopBar

    local sdCorner = Instance.new("UICorner")
    sdCorner.CornerRadius = UDim.new(1, 0)
    sdCorner.Parent = statusDot

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 4)
    cbCorner.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Red, TextColor3 = Theme.Accent}, 0.14) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.14) end)

    local isDragging, dragInput, mousePos, framePos = false, nil, nil, nil
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            mousePos = inp.Position
            framePos = MainFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)
    TopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and isDragging then
            local d = inp.Position - mousePos
            local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + d.X, framePos.Y.Scale, framePos.Y.Offset + d.Y)
            MainFrame.Position = newPos
            MainShadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 3)
        end
    end)
end

local isVisible = true
local isOpening = false

local function setVisible(v)
    if isOpening then return end
    isVisible = v
    if v then
        isOpening = true
        MainFrame.Visible = true
        MainShadow.Visible = true
        MainFrame.Size = UDim2.new(0, 590, 0, 440)
        MainFrame.BackgroundTransparency = 0.8
        MainShadow.BackgroundTransparency = 0.95
        tw(MainFrame, {Size = UDim2.new(0, 630, 0, 470), BackgroundTransparency = 0.12}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(MainShadow, {Size = UDim2.new(0, 646, 0, 486), BackgroundTransparency = 0.65}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.25, function() isOpening = false end)
    else
        isOpening = true
        tw(MainShadow, {Size = UDim2.new(0, 590, 0, 440), BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(MainFrame, {Size = UDim2.new(0, 590, 0, 440), BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
            MainFrame.Visible = false
            MainShadow.Visible = false
            isOpening = false
        end)
    end
end

closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
FloatToggle.MouseButton1Click:Connect(function() setVisible(not isVisible) end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 136, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.06
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 10
Sidebar.Parent = MainFrame

do
    local sbStroke = Instance.new("UIStroke")
    sbStroke.Color = Theme.Border
    sbStroke.Thickness = 1
    sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sbStroke.Parent = Sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 3)
    tabLayout.Parent = Sidebar

    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop = UDim.new(0, 8)
    tabPad.PaddingLeft = UDim.new(0, 7)
    tabPad.PaddingRight = UDim.new(0, 7)
    tabPad.Parent = Sidebar
end

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -136, 1, -42)
ContentArea.Position = UDim2.new(0, 136, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.ZIndex = 10
ContentArea.Parent = MainFrame

local AllTabs = {}
local activeTab = nil

local tabIcons = {
    Combat = "\xE2\x9A\x94",
    Teleport = "\xE2\x86\x97",
    Visuals = "\xE2\x97\x89",
    Players = "\xE2\x99\x9F",
    Anims = "\xE2\x99\xAA",
    Physics = "\xE2\x87\x85",
    Misc = "\xE2\x9C\xA6",
    Tools = "\xE2\x9C\x92",
    Intel = "\xE2\x97\x86",
    System = "\xE2\x9A\xA1",
    Scripts = "\xE2\x9C\x8E",
    ["God & World"] = "\xE2\x98\x85",
    Settings = "\xE2\x9A\x99",
}

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    local icon = tabIcons[name] or ""
    tabBtn.Text = (icon ~= "" and (icon .. "  ") or "") .. string.upper(name)
    tabBtn.TextColor3 = Theme.TabInactiveText
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local tPad = Instance.new("UIPadding")
    tPad.PaddingLeft = UDim.new(0, 10)
    tPad.Parent = tabBtn

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 4)
    tbCorner.Parent = tabBtn

    local activeLine = Instance.new("Frame")
    activeLine.Size = UDim2.new(0, 2, 0, 4)
    activeLine.Position = UDim2.new(0, -2, 0.5, -8)
    activeLine.BackgroundColor3 = Theme.Accent
    activeLine.BorderSizePixel = 0
    activeLine.BackgroundTransparency = 1
    activeLine.Parent = tabBtn

    local alCorner = Instance.new("UICorner")
    alCorner.CornerRadius = UDim.new(1, 0)
    alCorner.Parent = activeLine

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -14, 1, -14)
    page.Position = UDim2.new(0, 7, 0, 7)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.BorderBright
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 5)
    pageLayout.Parent = page

    local tabObj = {Button = tabBtn, Page = page, Name = name, ActiveLine = activeLine}

    local function select()
        if activeTab == tabObj then return end
        if activeTab then
            local oldPage = activeTab.Page
            tw(oldPage, {Position = UDim2.new(0, 7, 0, 0), ScrollingDirection = oldPage.ScrollingDirection}, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                oldPage.Visible = false
            end)
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.15)
            tw(activeTab.ActiveLine, {Size = UDim2.new(0, 2, 0, 4), BackgroundTransparency = 1}, 0.15)
        end
        activeTab = tabObj
        page.CanvasPosition = Vector2.new(0, 0)
        page.Position = UDim2.new(0, 7, 0, 18)
        page.Visible = true
        tw(page, {Position = UDim2.new(0, 7, 0, 7)}, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        tw(tabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabActiveText}, 0.15)
        tw(activeLine, {Size = UDim2.new(0, 2, 0, 16), BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    tabBtn.MouseButton1Click:Connect(select)
    table.insert(AllTabs, tabObj)
    if #AllTabs == 1 then task.defer(select) end

    function tabObj:AddSection(label)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.Parent = page

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(label)
        lbl.TextColor3 = Theme.AccentDim
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -8, 0, 1)
        line.Position = UDim2.new(0, 4, 1, -1)
        line.BackgroundColor3 = Theme.Border
        line.BorderSizePixel = 0
        line.Parent = row
    end

    function tabObj:AddButton(label, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Theme.ElementBg
        btn.BackgroundTransparency = 0.22
        btn.Text = label
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 5)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Theme.Border
        bStroke.Thickness = 1
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.1}, 0.14)
            tw(bStroke, {Color = Theme.BorderBright}, 0.14)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementBg, BackgroundTransparency = 0.22}, 0.14)
            tw(bStroke, {Color = Theme.Border}, 0.14)
        end)
        btn.MouseButton1Down:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementActive, Size = UDim2.new(0.985, 0, 0, 31)}, 0.08)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover, Size = UDim2.new(1, 0, 0, 32)}, 0.15, Enum.EasingStyle.Back)
        end)
        btn.MouseButton1Click:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 10, 0, 10)
            ripple.Position = UDim2.new(0.5, -5, 0.5, -5)
            ripple.BackgroundColor3 = Theme.Accent
            ripple.BackgroundTransparency = 0.6
            ripple.BorderSizePixel = 0
            ripple.Parent = btn
            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(1, 0)
            rc.Parent = ripple
            tw(ripple, {Size = UDim2.new(1.2, 0, 3, 0), Position = UDim2.new(-0.1, 0, -1, 0), BackgroundTransparency = 1}, 0.28).Completed:Connect(function()
                ripple:Destroy()
            end)
            if cb then task.spawn(cb) end
        end)
        return btn
    end

    function tabObj:AddToggle(label, default, cb)
        local state = default or false

        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = Theme.ElementBg
        row.BackgroundTransparency = 0.22
        row.Text = ""
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 5)
        rCorner.Parent = row

        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 2, 0.7, 0)
        accentBar.AnchorPoint = Vector2.new(0, 0.5)
        accentBar.Position = UDim2.new(0, 1, 0.5, 0)
        accentBar.BackgroundColor3 = Theme.Green
        accentBar.BackgroundTransparency = state and 0 or 1
        accentBar.BorderSizePixel = 0
        accentBar.Parent = row

        local abCorner = Instance.new("UICorner")
        abCorner.CornerRadius = UDim.new(0, 1)
        abCorner.Parent = accentBar

        local rStroke = Instance.new("UIStroke")
        rStroke.Color = Theme.Border
        rStroke.Thickness = 1
        rStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        rStroke.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.Position = UDim2.new(0, 11, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = state and Theme.Accent or Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local swTrack = Instance.new("Frame")
        swTrack.Size = UDim2.new(0, 34, 0, 18)
        swTrack.Position = UDim2.new(1, -44, 0.5, -9)
        swTrack.BackgroundColor3 = state and Theme.Accent or Theme.Header
        swTrack.BorderSizePixel = 0
        swTrack.Parent = row

        local swCorner = Instance.new("UICorner")
        swCorner.CornerRadius = UDim.new(1, 0)
        swCorner.Parent = swTrack

        local swStroke = Instance.new("UIStroke")
        swStroke.Color = state and Theme.Accent or Theme.Border
        swStroke.Thickness = 1
        swStroke.Parent = swTrack

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
        knob.BorderSizePixel = 0
        knob.Parent = swTrack

        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob

        local function setToggle(v)
            state = v
            tw(lbl, {TextColor3 = state and Theme.Accent or Theme.TextPrimary}, 0.15)
            tw(swTrack, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.18)
            tw(swStroke, {Color = state and Theme.Accent or Theme.Border}, 0.18)
            tw(accentBar, {BackgroundTransparency = state and 0 or 1}, 0.18)

            tw(knob, {
                Size = UDim2.new(0, 18, 0, 14),
                Position = state and UDim2.new(1, -20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }, 0.08, Enum.EasingStyle.Quad).Completed:Connect(function()
                tw(knob, {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
                }, 0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end)

            if cb then task.spawn(cb, state) end
        end

        row.MouseEnter:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.1}, 0.12)
            tw(rStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        row.MouseLeave:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementBg, BackgroundTransparency = 0.22}, 0.12)
            tw(rStroke, {Color = Theme.Border}, 0.12)
        end)
        row.MouseButton1Click:Connect(function() setToggle(not state) end)

        return setToggle
    end

    function tabObj:AddSlider(label, minV, maxV, defaultV, cb)
        local val = defaultV or minV
        minV = minV or 0
        maxV = maxV or 100

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundColor3 = Theme.ElementBg
        container.BackgroundTransparency = 0.22
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner", container)
        cCorner.CornerRadius = UDim.new(0, 5)

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Theme.Border
        cStroke.Thickness = 1
        cStroke.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 0, 18)
        lbl.Position = UDim2.new(0, 11, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 60, 0, 18)
        valLbl.Position = UDim2.new(1, -68, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val)
        valLbl.TextColor3 = Theme.AccentDim
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local trackBg = Instance.new("Frame")
        trackBg.Size = UDim2.new(1, -22, 0, 6)
        trackBg.Position = UDim2.new(0, 11, 0, 31)
        trackBg.BackgroundColor3 = Theme.Header
        trackBg.BorderSizePixel = 0
        trackBg.Parent = container

        Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

        local fillBar = Instance.new("Frame")
        local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
        fillBar.Size = UDim2.new(initRatio, 0, 1, 0)
        fillBar.BackgroundColor3 = Theme.Accent
        fillBar.BorderSizePixel = 0
        fillBar.Parent = trackBg

        Instance.new("UICorner", fillBar).CornerRadius = UDim.new(1, 0)

        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 14, 0, 14)
        handle.AnchorPoint = Vector2.new(0.5, 0.5)
        handle.Position = UDim2.new(initRatio, 0, 0.5, 0)
        handle.BackgroundColor3 = Theme.Accent
        handle.Text = ""
        handle.BorderSizePixel = 0
        handle.AutoButtonColor = false
        handle.ZIndex = 5
        handle.Parent = trackBg

        Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

        local hStroke = Instance.new("UIStroke", handle)
        hStroke.Color = Theme.Background
        hStroke.Thickness = 2

        local sliding = false

        local function applySlide(inputPos)
            local x = trackBg.AbsolutePosition.X
            local w = trackBg.AbsoluteSize.X
            local r = math.clamp((inputPos.X - x) / w, 0, 1)
            val = math.round(minV + (maxV - minV) * r)
            valLbl.Text = tostring(val)
            valLbl.TextColor3 = Theme.Accent
            fillBar.Size = UDim2.new(r, 0, 1, 0)
            handle.Position = UDim2.new(r, 0, 0.5, 0)
            if cb then task.spawn(cb, val) end
        end

        container.MouseEnter:Connect(function()
            tw(cStroke, {Color = Theme.BorderBright}, 0.12)
            tw(container, {BackgroundColor3 = Theme.ElementHover}, 0.12)
        end)
        container.MouseLeave:Connect(function()
            if not sliding then
                tw(cStroke, {Color = Theme.Border}, 0.12)
                tw(container, {BackgroundColor3 = Theme.ElementBg}, 0.12)
            end
        end)

        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                tw(handle, {Size = UDim2.new(0, 18, 0, 18)}, 0.12, Enum.EasingStyle.Back)
            end
        end)
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                tw(handle, {Size = UDim2.new(0, 18, 0, 18)}, 0.12, Enum.EasingStyle.Back)
                applySlide(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
                sliding = false
                tw(handle, {Size = UDim2.new(0, 14, 0, 14)}, 0.12)
                tw(valLbl, {TextColor3 = Theme.AccentDim}, 0.2)
                tw(cStroke, {Color = Theme.Border}, 0.12)
                tw(container, {BackgroundColor3 = Theme.ElementBg}, 0.12)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                applySlide(inp.Position)
            end
        end)
    end

    return tabObj
end

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.new(0, 20, 0, 20)
CrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.Parent = ScreenGui

for _, cfg in ipairs({
    {UDim2.new(0.5, 0, 0, -5), UDim2.new(0, 1, 0, 4)},
    {UDim2.new(0.5, 0, 1, 1), UDim2.new(0, 1, 0, 4)},
    {UDim2.new(0, -5, 0.5, 0), UDim2.new(0, 4, 0, 1)},
    {UDim2.new(1, 1, 0.5, 0), UDim2.new(0, 4, 0, 1)},
}) do
    local line = Instance.new("Frame")
    line.Position = cfg[1]
    line.Size = cfg[2]
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Parent = CrosshairFrame
end

local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 300, 0, 300)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui

local fcStroke = Instance.new("UIStroke")
fcStroke.Color = Color3.fromRGB(255, 255, 255)
fcStroke.Thickness = 1
fcStroke.Transparency = 0.55
fcStroke.Parent = FovCircle

local fcCorner = Instance.new("UICorner")
fcCorner.CornerRadius = UDim.new(1, 0)
fcCorner.Parent = FovCircle

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 140, 0, 48)
FpsLabel.Position = UDim2.new(0, 10, 0, 10)
FpsLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
FpsLabel.BackgroundTransparency = 0.3
FpsLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
FpsLabel.Font = Enum.Font.Code
FpsLabel.TextSize = 11
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.BorderSizePixel = 0
FpsLabel.Visible = false
FpsLabel.Parent = ScreenGui

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 5)
fpsCorner.Parent = FpsLabel

local fpsPad = Instance.new("UIPadding")
fpsPad.PaddingLeft = UDim.new(0, 8)
fpsPad.Parent = FpsLabel

local HoverHud = Instance.new("TextLabel")
HoverHud.Size = UDim2.new(0, 280, 0, 26)
HoverHud.AnchorPoint = Vector2.new(0.5, 1)
HoverHud.Position = UDim2.new(0.5, 0, 1, -16)
HoverHud.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
HoverHud.BackgroundTransparency = 0.25
HoverHud.TextColor3 = Color3.fromRGB(200, 200, 215)
HoverHud.Font = Enum.Font.Code
HoverHud.TextSize = 10
HoverHud.BorderSizePixel = 0
HoverHud.Visible = false
HoverHud.Parent = ScreenGui

local hhCorner = Instance.new("UICorner")
hhCorner.CornerRadius = UDim.new(0, 4)
hhCorner.Parent = HoverHud

local hhStroke = Instance.new("UIStroke")
hhStroke.Color = Theme.Border
hhStroke.Thickness = 1
hhStroke.Parent = HoverHud

local savedWaypoints = {}

local function safeDisc(c)
    if c then c:Disconnect() end
    return nil
end

local function getChar() return LocalPlayer.Character end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function teleportToRaycast()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    local char = getChar()
    if char then
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
    end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if result then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3.5, 0))
            Notify("Teleport", "Moved to cursor position", 1.5, Theme.AccentDim)
        end
    end
end

local cyclePlayerIndex = 1

local function getOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    return list
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = getRoot()
    if targetRoot and myRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
        Notify("Teleport", "Teleported to " .. targetPlayer.Name, 1.8, Theme.Green)
    end
end

local function teleportToNearestPlayer()
    local myRoot = getRoot()
    if not myRoot then return end
    local nearest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d = (myRoot.Position - tr.Position).Magnitude
                if d < shortest then
                    shortest = d
                    nearest = p
                end
            end
        end
    end
    if nearest then
        teleportToPlayer(nearest)
    else
        Notify("Teleport", "No other players found", 1.8, Theme.Red)
    end
end

local function teleportToRandomPlayer()
    local others = getOtherPlayers()
    if #others > 0 then
        local p = others[math.random(1, #others)]
        teleportToPlayer(p)
    else
        Notify("Teleport", "No other players found", 1.8, Theme.Red)
    end
end

local function cycleTeleportPlayer()
    local others = getOtherPlayers()
    if #others == 0 then
        Notify("Teleport", "No other players found", 1.8, Theme.Red)
        return
    end
    if cyclePlayerIndex > #others then cyclePlayerIndex = 1 end
    local target = others[cyclePlayerIndex]
    cyclePlayerIndex = cyclePlayerIndex + 1
    if target then teleportToPlayer(target) end
end


local keysDown = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

UserInputService.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = true
    end
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift or inp.KeyCode == Enum.KeyCode.RightControl or inp.KeyCode == Enum.KeyCode.Insert then
        setVisible(not isVisible)
    end
    if inp.KeyCode == Enum.KeyCode.W then keysDown.W = true end
    if inp.KeyCode == Enum.KeyCode.A then keysDown.A = true end
    if inp.KeyCode == Enum.KeyCode.S then keysDown.S = true end
    if inp.KeyCode == Enum.KeyCode.D then keysDown.D = true end
    if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = true end
    if inp.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = true end
    if inp.KeyCode == Enum.KeyCode.T then teleportToRaycast() end
end)

UserInputService.WindowFocusReleased:Connect(function()
    rmbHeld = false
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = false
    end
    if inp.KeyCode == Enum.KeyCode.W then keysDown.W = false end
    if inp.KeyCode == Enum.KeyCode.A then keysDown.A = false end
    if inp.KeyCode == Enum.KeyCode.S then keysDown.S = false end
    if inp.KeyCode == Enum.KeyCode.D then keysDown.D = false end
    if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = false end
    if inp.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = false end
end)

local function forAllCharacters(onCharAdded, onCharRemoved)
    local connections = {}

    local function setupPlayer(player)
        if player == LocalPlayer then return end
        local pConns = {}

        local function onAdded(char)
            task.spawn(function()
                char:WaitForChild("HumanoidRootPart", 5)
                onCharAdded(player, char)
            end)
        end

        local function onRemoving(char)
            onCharRemoved(player, char)
        end

        pConns.added = player.CharacterAdded:Connect(onAdded)
        pConns.removing = player.CharacterRemoving:Connect(onRemoving)
        if player.Character then onAdded(player.Character) end
        connections[player] = pConns
    end

    local function cleanupPlayer(player)
        local pConns = connections[player]
        if pConns then
            if pConns.added then pConns.added:Disconnect() end
            if pConns.removing then pConns.removing:Disconnect() end
            connections[player] = nil
        end
        if player.Character then onCharRemoved(player, player.Character) end
    end

    for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
    local addedConn = Players.PlayerAdded:Connect(setupPlayer)
    local removingConn = Players.PlayerRemoving:Connect(cleanupPlayer)

    return function()
        addedConn:Disconnect()
        removingConn:Disconnect()
        for player in pairs(connections) do cleanupPlayer(player) end
    end
end

local fireRecoil, setRecoil, spawnBulletTracer, setAimAssist, setAutoShot
local aimSnap, wallCheck, teamCheck, aimRange, glideSpeed, autoShotDelay, recoilIntensity, aimLeadEnabled, aimLeadFactor, aimNoiseEnabled, aimNoiseIntensity, aimPriority, aimBone
local setHitboxExpander, setNoclip, setAirWalk, setGhostMode
ghostModeEnabled = false
hitboxDisplaceEnabled = false
inspectorConn = nil
local hitboxSize, updateHitboxSizes, flightSpeed, cameraShakeIntensity
local setFlashlight, updateFlashlight, setEntityRadar, setClearVision
local setTouchShield, setAntiFall, setDeathShield, setGodmode, setSpeedBoost
local setInstantPrompts, setInfZoom, setHitboxDisplace, setUnlockFirstPerson
local setAutoClearAttributes, clearRestrictions, toggleAllScripts
local customWalkSpeed, flashlightBrightness, flashlightRange, hitboxDisplaceDist
local setHighlights, setFullbright, setNightVision, setDayCycle, setCameraShake
local setHeadbob, setSpeedlines, setNameTags, setHealthBars, setDistanceTags
local setFlight, setInfJump, setFPSHud, applyAnimPack

do
local recoilEnabled = false
recoilIntensity = 5
local recoilConn = nil
local targetRecoil = Vector3.zero
local currentRecoil = Vector3.zero

function fireRecoil()
    if not recoilEnabled then return end
    targetRecoil = Vector3.new(
        recoilIntensity * (0.5 + math.random() * 0.5),
        (math.random() - 0.5) * recoilIntensity * 0.4,
        0
    )
end

function setRecoil(enabled)
    recoilEnabled = enabled
    recoilConn = safeDisc(recoilConn)
    if enabled then
        recoilConn = RunService.RenderStepped:Connect(function(dt)
            currentRecoil = currentRecoil:Lerp(targetRecoil, math.min(dt * 18, 1))
            targetRecoil = targetRecoil:Lerp(Vector3.zero, math.min(dt * 10, 1))
            if currentRecoil.Magnitude > 0.001 then
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(currentRecoil.X), math.rad(currentRecoil.Y), 0)
            end
        end)
    end
end

function spawnBulletTracer()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    local char = getChar()
    if char then
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
    end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    local origin = ray.Origin
    local endPos = result and result.Position or (ray.Origin + ray.Direction * 500)

    local function makeAnchor(pos)
        local p = Instance.new("Part")
        p.Size = Vector3.one * 0.01
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = false
        p.Position = pos
        p.Parent = workspace
        local a = Instance.new("Attachment", p)
        return p, a
    end

    local p1, a1 = makeAnchor(origin)
    local p2, a2 = makeAnchor(endPos)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a1
    beam.Attachment1 = a2
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    beam.Width0 = 0.12
    beam.Width1 = 0.04
    beam.FaceCamera = true
    beam.LightEmission = 0.8
    beam.LightInfluence = 0.2
    beam.Parent = p1

    if result then
        local impact = Instance.new("Part")
        impact.Size = Vector3.one * 0.3
        impact.Transparency = 1
        impact.Anchored = true
        impact.CanCollide = false
        impact.CFrame = CFrame.new(result.Position, result.Position + result.Normal)
        impact.Parent = workspace

        local ring = Instance.new("ParticleEmitter")
        ring.Rate = 0
        ring.SpreadAngle = Vector2.new(60, 60)
        ring.Speed = NumberRange.new(2, 5)
        ring.Lifetime = NumberRange.new(0.05, 0.15)
        ring.Size = NumberSequence.new(0.15, 0)
        ring.Color = ColorSequence.new(Color3.fromRGB(255, 240, 200))
        ring.LightEmission = 1
        ring.Parent = impact
        ring:Emit(8)
        task.delay(0.2, function() impact:Destroy() end)
    end

    tw(beam, {Width0 = 0, Width1 = 0}, 0.18).Completed:Connect(function()
        p1:Destroy()
        p2:Destroy()
    end)
end

end

do
local aimEnabled = false
aimRange = 300
aimSnap = false
glideSpeed = 0.12
wallCheck = false
teamCheck = false
local aimConn = nil
local rmbHeld = false
local lockedTarget = nil

local autoShotEnabled = false
autoShotDelay = 0.14
local autoShotConn = nil
local lastAutoShot = 0
local wasOnTarget = false
local function isRmbHeld()
    if rmbHeld then return true end
    local ok, down = pcall(function()
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end)
    return ok and down or false
end

local function getTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function hasLOS(origin, targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    local filter = {}
    local char = getChar()
    if char then table.insert(filter, char) end
    table.insert(filter, targetPart.Parent)
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    return workspace:Raycast(origin, dir, params) == nil
end

local targetNpcs = false
function setTargetNpcs(enabled) targetNpcs = enabled; Notify("Aim Assist", enabled and "Target NPCs ON" or "Target NPCs OFF", 1.5) end

local function getNearestEnemy()
    local nearest = nil
    local shortest = aimRange
    local camPos = Camera.CFrame.Position
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team) then
                table.insert(candidates, p.Character)
            end
        end
    end

    if targetNpcs then
        local myChar = getChar()
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and child ~= myChar then
                local hum = child:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and (child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")) then
                    if not Players:GetPlayerFromCharacter(child) then
                        table.insert(candidates, child)
                    end
                end
            elseif child:IsA("Folder") and (string.find(string.lower(child.Name), "npc") or string.find(string.lower(child.Name), "enem") or string.find(string.lower(child.Name), "zomb") or string.find(string.lower(child.Name), "mob") or string.find(string.lower(child.Name), "monster")) then
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("Model") and sub ~= myChar then
                        local hum = sub:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 and (sub:FindFirstChild("HumanoidRootPart") or sub:FindFirstChild("Head")) then
                            if not Players:GetPlayerFromCharacter(sub) then
                                table.insert(candidates, sub)
                            end
                        end
                    end
                end
            end
        end
    end

    for _, char in ipairs(candidates) do
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = getTargetPart(char)
        if not part then continue end
        if wallCheck and not hasLOS(camPos, part) then continue end
        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d > aimRange then continue end

        local score = d
        if aimPriority == "Distance" then
            score = (camPos - part.Position).Magnitude
        elseif aimPriority == "LowestHP" then
            score = hum.Health
        end

        if score < shortest then
            shortest = score
            nearest = part
        end
    end
    return nearest
end

    local lastSeenTargetTime = 0
    local targetStickinessGrace = 0.35
    local stickyLock = true

    function setStickyLock(enabled)
        stickyLock = enabled
        Notify("Aim Assist", enabled and "Sticky Lock ON (Holds Target)" or "Sticky Lock OFF", 1.5)
    end

    local function isTargetValid(part)
        if not part or not part.Parent then return false end
        local hum = part.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        local camPos = Camera.CFrame.Position
        local dist = (camPos - part.Position).Magnitude
        if dist > 450 then return false end

        if wallCheck then
            if hasLOS(camPos, part) then
                lastSeenTargetTime = os.clock()
            else
                if (os.clock() - lastSeenTargetTime) > targetStickinessGrace then
                    return false
                end
            end
        else
            lastSeenTargetTime = os.clock()
        end

        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen and (os.clock() - lastSeenTargetTime) > targetStickinessGrace then
            return false
        end

        if not stickyLock then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if d > (aimRange * 1.5) then return false end
        end

        return true
    end

    function setAimLead(enabled) aimLeadEnabled = enabled end
    function setAimLeadFactor(val) aimLeadFactor = val end

    function setAimAssist(enabled)
    aimEnabled = enabled
    pcall(function()
        RunService:UnbindFromRenderStep("NIXAimAssist")
    end)
    aimConn = safeDisc(aimConn)
    lockedTarget = nil
    if fcStroke then fcStroke.Color = Theme.Accent end

    if enabled then
        RunService:BindToRenderStep("NIXAimAssist", Enum.RenderPriority.Camera.Value + 1, function()
            if not isRmbHeld() then
                if lockedTarget then
                    lockedTarget = nil
                    if fcStroke then fcStroke.Color = Theme.Accent end
                end
                return
            end

            if not isTargetValid(lockedTarget) then
                lockedTarget = getNearestEnemy()
            end

            if not lockedTarget then
                if fcStroke then fcStroke.Color = Theme.Accent end
                return
            end

            if fcStroke then fcStroke.Color = Theme.Green end

            local tp = lockedTarget.Position
            local camPos = Camera.CFrame.Position
            if aimLeadEnabled then
                local vel = lockedTarget.AssemblyLinearVelocity or Vector3.zero
                local dist = (lockedTarget.Position - camPos).Magnitude
                local leadTime = math.clamp(dist / 600, 0.02, 0.35) * (aimLeadFactor / 0.12)
                tp = tp + (vel * leadTime)
            end
            if aimNoiseEnabled then
                local t = os.clock() * 7.5
                local jx = (math.noise(t, 12.34) or 0) * (aimNoiseIntensity or 1) * 0.45
                local jy = (math.noise(t, 56.78) or 0) * (aimNoiseIntensity or 1) * 0.45
                tp = tp + Vector3.new(jx, jy, 0)
            end
            if (tp - camPos).Magnitude < 0.1 then return end
            local targetRot = CFrame.lookAt(camPos, tp)

            if aimSnap then
                Camera.CFrame = targetRot
            else
                local factor = 1 - (1 - math.clamp(glideSpeed, 0.04, 0.6)) ^ 3
                Camera.CFrame = Camera.CFrame:Lerp(targetRot, factor)
            end
        end)
    end
end

local function getEnemyFromPart(part)
    if not part then return nil end
    local cur = part
    while cur and cur ~= workspace do
        if cur:IsA("Model") then
            local p = Players:GetPlayerFromCharacter(cur)
            if p and p ~= LocalPlayer then
                if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then return nil end
                local hum = cur:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then return cur end
            end
            local hum = cur:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and cur ~= getChar() then
                return cur
            end
        end
        cur = cur.Parent
    end
    return nil
end

end

do
local function castRayAt(screenPoint)
    local ray = Camera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
    local params = RaycastParams.new()
    local char = getChar()
    local filter = {}
    if char then table.insert(filter, char) end
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if res and res.Instance then
        return getEnemyFromPart(res.Instance)
    end
    return nil
end

local function isCursorOnTarget()
    local mp = UserInputService:GetMouseLocation()
    local hit = castRayAt(mp)
    if hit then return hit end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    hit = castRayAt(center)
    if hit then return hit end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = getTargetPart(p.Character)
        if not part then continue end
        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local sp2 = Vector2.new(sp.X, sp.Y)
        local d1 = (sp2 - mp).Magnitude
        local d2 = (sp2 - center).Magnitude
        if (d1 < 26 or d2 < 26) and hasLOS(Camera.CFrame.Position, part) then
            return p.Character
        end
    end

    if lockedTarget and isTargetValid(lockedTarget) then
        local sp, vis = Camera:WorldToViewportPoint(lockedTarget.Position)
        if vis then
            local sp2 = Vector2.new(sp.X, sp.Y)
            if (sp2 - mp).Magnitude < 32 or (sp2 - center).Magnitude < 32 then
                return lockedTarget.Parent
            end
        end
    end

    return nil
end

local function triggerFire()
    spawnBulletTracer()
    fireRecoil()

    local char = getChar()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end

    local mp = UserInputService:GetMouseLocation()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(mp.X, mp.Y, 0, true, game, 0)
        task.defer(function()
            pcall(function() vim:SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 0) end)
        end)
    end)
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton1(Vector2.zero)
    end)
end

function setAutoShot(enabled)
    autoShotEnabled = enabled
    autoShotConn = safeDisc(autoShotConn)
    wasOnTarget = false
    if enabled then
        autoShotConn = RunService.RenderStepped:Connect(function()
            local target = isCursorOnTarget()
            if target then
                local now = os.clock()
                if autoShotDelay <= 0.005 or not wasOnTarget or (now - lastAutoShot >= autoShotDelay) then
                    lastAutoShot = now
                    wasOnTarget = true
                    triggerFire()
                end
            else
                wasOnTarget = false
            end
        end)
    end
end
end

do
local hitboxExpanderEnabled = false
hitboxSize = 10
local hitboxOriginals = {}
local hitboxCleanup = nil

local function applyHitbox(player, char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 4)
    if not root then return end
    if not hitboxOriginals[char] then
        hitboxOriginals[char] = {
            Size = root.Size,
            Transparency = root.Transparency,
            Material = root.Material,
            CanCollide = root.CanCollide,
            Color = root.Color
        }
    end
    if hitboxExpanderEnabled then
        root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        root.Transparency = 0.72
        root.Material = Enum.Material.Neon
        root.Color = Color3.fromRGB(240, 60, 60)
        root.CanCollide = false
    end
end

local function revertHitbox(player, char)
    if char and hitboxOriginals[char] then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local orig = hitboxOriginals[char]
            root.Size = orig.Size
            root.Transparency = orig.Transparency
            root.Material = orig.Material
            root.CanCollide = orig.CanCollide
            root.Color = orig.Color
        end
        hitboxOriginals[char] = nil
    end
end

function updateHitboxSizes()
    if not hitboxExpanderEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            end
        end
    end
end

function setHitboxExpander(enabled)
    hitboxExpanderEnabled = enabled
    if hitboxCleanup then hitboxCleanup(); hitboxCleanup = nil end

    if enabled then
        hitboxCleanup = forAllCharacters(applyHitbox, revertHitbox)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                applyHitbox(p, p.Character)
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                revertHitbox(p, p.Character)
            end
        end
    end
end

local noclipEnabled = false
local noclipConn = nil

function setNoclip(enabled)
    noclipEnabled = enabled
    noclipConn = safeDisc(noclipConn)
    if enabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local airWalkEnabled = false
local airWalkPart = nil
local airWalkConn = nil
local airWalkY = 0

function setAirWalk(enabled)
    airWalkEnabled = enabled
    airWalkConn = safeDisc(airWalkConn)
    if airWalkPart then airWalkPart:Destroy() airWalkPart = nil end

    if enabled then
        local root = getRoot()
        airWalkY = root and (root.Position.Y - 3.2) or 0

        airWalkPart = Instance.new("Part")
        airWalkPart.Name = "NIXAirWalkFloor"
        airWalkPart.Size = Vector3.new(7, 1, 7)
        airWalkPart.Transparency = 0.65
        airWalkPart.Material = Enum.Material.Neon
        airWalkPart.Color = Color3.fromRGB(160, 220, 255)
        airWalkPart.Anchored = true
        airWalkPart.CanCollide = true
        airWalkPart.Parent = workspace

        local pCorner = Instance.new("CylinderMesh")
        pCorner.Scale = Vector3.new(1, 0.4, 1)
        pCorner.Parent = airWalkPart

        airWalkConn = RunService.Heartbeat:Connect(function(dt)
            local myRoot = getRoot()
            if not myRoot or not airWalkPart then return end

            if keysDown.Space then
                airWalkY = airWalkY + dt * 18
            elseif keysDown.LeftShift then
                airWalkY = airWalkY - dt * 18
            end

            airWalkPart.Position = Vector3.new(myRoot.Position.X, airWalkY, myRoot.Position.Z)
        end)
    end
end

local ghostModeEnabled = false
local ghostOriginals = {}

function setGhostMode(enabled)
    ghostModeEnabled = enabled
    local char = getChar()
    if not char then return end

    if enabled then
        for _, d in ipairs(char:GetDescendants()) do
            if (d:IsA("BasePart") or d:IsA("Decal")) and d.Name ~= "HumanoidRootPart" then
                if ghostOriginals[d] == nil then
                    ghostOriginals[d] = d.Transparency
                end
                d.Transparency = 0.72
            end
        end
    else
        for d, orig in pairs(ghostOriginals) do
            if d and d.Parent then
                d.Transparency = orig
            end
        end
        ghostOriginals = {}
    end
end

end



do
    local chatSpyEnabled = false
    local chatSpyConns = {}
    local recentChats = {}

    local chatLogFrame = Instance.new("Frame")
    chatLogFrame.Name = "NIXChatLogFrame"
    chatLogFrame.Size = UDim2.new(0, 320, 0, 190)
    chatLogFrame.Position = UDim2.new(0, 16, 1, -210)
    chatLogFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
    chatLogFrame.BorderSizePixel = 0
    chatLogFrame.ZIndex = 120
    chatLogFrame.Visible = false
    chatLogFrame.Parent = ScreenGui

    local clfCorner = Instance.new("UICorner")
    clfCorner.CornerRadius = UDim.new(0, 6)
    clfCorner.Parent = chatLogFrame

    local clfStroke = Instance.new("UIStroke")
    clfStroke.Color = Theme.BorderBright
    clfStroke.Thickness = 1
    clfStroke.Parent = chatLogFrame

    local clfTopBar = Instance.new("Frame")
    clfTopBar.Name = "TopBar"
    clfTopBar.Size = UDim2.new(1, 0, 0, 26)
    clfTopBar.BackgroundColor3 = Theme.Header
    clfTopBar.BorderSizePixel = 0
    clfTopBar.Parent = chatLogFrame

    local clftCorner = Instance.new("UICorner")
    clftCorner.CornerRadius = UDim.new(0, 6)
    clftCorner.Parent = clfTopBar

    local clTitle = Instance.new("TextLabel")
    clTitle.Size = UDim2.new(1, -70, 1, 0)
    clTitle.Position = UDim2.new(0, 8, 0, 0)
    clTitle.BackgroundTransparency = 1
    clTitle.Text = "CHAT SPY LOG (0)"
    clTitle.TextColor3 = Theme.Accent
    clTitle.Font = Enum.Font.GothamBold
    clTitle.TextSize = 10
    clTitle.TextXAlignment = Enum.TextXAlignment.Left
    clTitle.Parent = clfTopBar

    local clClearBtn = Instance.new("TextButton")
    clClearBtn.Size = UDim2.new(0, 36, 0, 18)
    clClearBtn.Position = UDim2.new(1, -62, 0.5, -9)
    clClearBtn.BackgroundColor3 = Theme.ElementBg
    clClearBtn.Text = "Clear"
    clClearBtn.TextColor3 = Theme.TextSecondary
    clClearBtn.Font = Enum.Font.Gotham
    clClearBtn.TextSize = 9
    clClearBtn.BorderSizePixel = 0
    clClearBtn.Parent = clfTopBar

    local clcCorner = Instance.new("UICorner")
    clcCorner.CornerRadius = UDim.new(0, 3)
    clcCorner.Parent = clClearBtn

    local clCloseBtn = Instance.new("TextButton")
    clCloseBtn.Size = UDim2.new(0, 20, 0, 18)
    clCloseBtn.Position = UDim2.new(1, -24, 0.5, -9)
    clCloseBtn.BackgroundColor3 = Theme.ElementBg
    clCloseBtn.Text = "x"
    clCloseBtn.TextColor3 = Theme.TextSecondary
    clCloseBtn.Font = Enum.Font.GothamBold
    clCloseBtn.TextSize = 10
    clCloseBtn.BorderSizePixel = 0
    clCloseBtn.Parent = clfTopBar

    local clxCorner = Instance.new("UICorner")
    clxCorner.CornerRadius = UDim.new(0, 3)
    clxCorner.Parent = clCloseBtn

    clCloseBtn.MouseButton1Click:Connect(function() chatLogFrame.Visible = false end)

    local clScroll = Instance.new("ScrollingFrame")
    clScroll.Size = UDim2.new(1, -12, 1, -34)
    clScroll.Position = UDim2.new(0, 6, 0, 29)
    clScroll.BackgroundTransparency = 1
    clScroll.BorderSizePixel = 0
    clScroll.ScrollBarThickness = 2
    clScroll.ScrollBarImageColor3 = Theme.BorderBright
    clScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    clScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    clScroll.Parent = chatLogFrame

    local clLayout = Instance.new("UIListLayout")
    clLayout.SortOrder = Enum.SortOrder.LayoutOrder
    clLayout.Padding = UDim.new(0, 3)
    clLayout.Parent = clScroll

    local clDrag, clDragInp, clMousePos, clFramePos = false, nil, nil, nil
    clfTopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            clDrag = true
            clMousePos = inp.Position
            clFramePos = chatLogFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then clDrag = false end
    end)
    clfTopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then clDragInp = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == clDragInp and clDrag then
            local d = inp.Position - clMousePos
            chatLogFrame.Position = UDim2.new(clFramePos.X.Scale, clFramePos.X.Offset + d.X, clFramePos.Y.Scale, clFramePos.Y.Offset + d.Y)
        end
    end)

    local function addChatLogEntry(senderName, msg)
        local timeStr = os.date("%X")
        local entryText = string.format("[%s] [%s]: %s", timeStr, senderName, msg)
        table.insert(recentChats, entryText)

        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, 0, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.BackgroundTransparency = 1
        row.Text = entryText
        row.TextColor3 = Color3.fromRGB(230, 230, 240)
        row.Font = Enum.Font.Code
        row.TextSize = 10
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextWrapped = true
        row.LayoutOrder = #recentChats
        row.Parent = clScroll

        clTitle.Text = string.format("CHAT SPY LOG (%d)", #recentChats)
        clScroll.CanvasPosition = Vector2.new(0, 99999)
    end

    clClearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(clScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        recentChats = {}
        clTitle.Text = "CHAT SPY LOG (0)"
        Notify("ChatSpy", "Chat logs cleared", 1.5)
    end)

    local function onPlayerChat(player, msg)
        if not chatSpyEnabled or player == LocalPlayer then return end
        addChatLogEntry(player.Name, msg)

        pcall(function()
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = string.format("[SPY] [%s]: %s", player.Name, msg),
                Color = Color3.fromRGB(255, 220, 90),
                Font = Enum.Font.GothamBold,
                FontSize = Enum.FontSize.Size14
            })
        end)
    end

    local function hookPlayer(p)
        if p == LocalPlayer then return end
        local c = p.Chatted:Connect(function(msg) onPlayerChat(p, msg) end)
        chatSpyConns[p] = c
    end

    function setChatSpy(enabled)
        chatSpyEnabled = enabled
        for _, c in pairs(chatSpyConns) do safeDisc(c) end
        chatSpyConns = {}
        if enabled then
            chatLogFrame.Visible = true
            for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
            chatSpyConns.added = Players.PlayerAdded:Connect(hookPlayer)
            chatSpyConns.removed = Players.PlayerRemoving:Connect(function(p)
                if chatSpyConns[p] then safeDisc(chatSpyConns[p]); chatSpyConns[p] = nil end
            end)

            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                chatSpyConns.tcs = TextChatService.MessageReceived:Connect(function(tcm)
                    local src = tcm.TextSource
                    local p = src and Players:GetPlayerByUserId(src.UserId)
                    if p and p ~= LocalPlayer and tcm.Text then
                        onPlayerChat(p, tcm.Text)
                    end
                end)
            end)
            Notify("ChatSpy", "Chat Spy ON  *  Monitoring Server", 2, Theme.Green)
        else
            Notify("ChatSpy", "Chat Spy OFF", 1.5)
        end
    end

    function setChatLogVisible(v)
        chatLogFrame.Visible = v
    end

    function dumpAllChatLogs()
        if #recentChats == 0 then
            Notify("ChatSpy", "No chat logs recorded yet", 1.8, Theme.Red)
            return
        end
        local fullText = table.concat(recentChats, "\n")
        print("\n=== CHAT SPY LOGS ===\n" .. fullText .. "\n=====================\n")
        if setclipboard then
            pcall(setclipboard, fullText)
            Notify("ChatSpy", "Copied " .. #recentChats .. " logs to clipboard + console", 2, Theme.Green)
        else
            Notify("ChatSpy", "Dumped " .. #recentChats .. " logs to console (F9)", 2, Theme.Green)
        end
    end

    function getLastSpiedChat()
        return recentChats[#recentChats] or "No messages intercepted yet"
    end
end



do
    local entityRadarEnabled = false
    local entityRadarConn = nil
    local entityBills = {}

    local itemRadarEnabled = false
    local itemRadarConn = nil
    local itemBills = {}

    local function clearEntityRadar()
        for _, b in pairs(entityBills) do if b and b.Parent then b:Destroy() end end
        entityBills = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if d.Name == "NIXEntityHL" then d:Destroy() end
        end
    end

    local function clearItemRadar()
        for _, b in pairs(itemBills) do if b and b.Parent then b:Destroy() end end
        itemBills = {}
    end

    local threatKeywords = {
        "monster", "entity", "killer", "creature", "demon", "ghost",
        "screech", "rush", "ambush", "figure", "seek", "nextbot",
        "stalker", "beast", "hazard", "danger", "chaser", "eyes", "halt",
        "mimic", "shadow", "flesh", "anomaly", "npc"
    }

    local function isThreatName(name)
        local low = string.lower(name)
        for _, kw in ipairs(threatKeywords) do
            if string.find(low, kw) then return true end
        end
        return false
    end

    function setEntityRadar(enabled)
        entityRadarEnabled = enabled
        entityRadarConn = safeDisc(entityRadarConn)
        clearEntityRadar()
        if enabled then
            entityRadarConn = RunService.Heartbeat:Connect(function()
                local myRoot = getRoot()
                if not myRoot then return end

                local playerChars = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then playerChars[p.Character] = true end
                end

                for _, d in ipairs(workspace:GetChildren()) do
                    if not playerChars[d] then
                        local rootPart = nil
                        local isThreat = false
                        local threatLabel = d.Name
                        local speed = 0

                        if d:IsA("Model") then
                            local hum = d:FindFirstChildOfClass("Humanoid")
                            local animCtrl = d:FindFirstChildOfClass("AnimationController")
                            local mainPart = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head") or d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")

                            if hum and hum.Health > 0 and mainPart then
                                isThreat = true
                                rootPart = mainPart
                                speed = math.floor(mainPart.AssemblyLinearVelocity.Magnitude)
                            elseif animCtrl and mainPart then
                                isThreat = true
                                rootPart = mainPart
                                speed = math.floor(mainPart.AssemblyLinearVelocity.Magnitude)
                            elseif mainPart then
                                local vel = mainPart.AssemblyLinearVelocity.Magnitude
                                if vel > 2.5 or isThreatName(d.Name) then
                                    isThreat = true
                                    rootPart = mainPart
                                    speed = math.floor(vel)
                                end
                            end
                        elseif d:IsA("BasePart") and not d.Anchored then
                            local vel = d.AssemblyLinearVelocity.Magnitude
                            if vel > 4 or isThreatName(d.Name) then
                                isThreat = true
                                rootPart = d
                                speed = math.floor(vel)
                            end
                        end

                        if isThreat and rootPart and rootPart.Parent then
                            local dist = math.round((myRoot.Position - rootPart.Position).Magnitude)
                            if dist <= 380 then
                                local bill = entityBills[d]
                                if not bill or not bill.Parent then
                                    bill = Instance.new("BillboardGui")
                                    bill.Name = "NIXEntityBill"
                                    bill.Size = UDim2.new(0, 140, 0, 26)
                                    bill.StudsOffset = Vector3.new(0, 3.2, 0)
                                    bill.AlwaysOnTop = true
                                    bill.Adornee = rootPart
                                    bill.Parent = rootPart

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Name = "ELbl"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 0.35
                                    lbl.BackgroundColor3 = Color3.fromRGB(18, 6, 6)
                                    lbl.TextColor3 = Theme.Red
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 10
                                    lbl.Parent = bill

                                    local elc = Instance.new("UICorner")
                                    elc.CornerRadius = UDim.new(0, 4)
                                    elc.Parent = lbl

                                    local els = Instance.new("UIStroke")
                                    els.Color = Theme.Red
                                    els.Thickness = 1
                                    els.Parent = lbl

                                    local hl = Instance.new("Highlight")
                                    hl.Name = "NIXEntityHL"
                                    hl.FillTransparency = 0.72
                                    hl.OutlineTransparency = 0.15
                                    hl.FillColor = Theme.Red
                                    hl.OutlineColor = Theme.Red
                                    hl.Adornee = d
                                    hl.Parent = d
                                    entityBills[d] = bill
                                end
                                local lbl = bill:FindFirstChild("ELbl")
                                if lbl then
                                    if speed > 1 then
                                        lbl.Text = string.format("[!] %s (%dm | %d s/s)", threatLabel, dist, speed)
                                    else
                                        lbl.Text = string.format("[!] %s (%dm)", threatLabel, dist)
                                    end
                                end
                            end
                        else
                            if entityBills[d] then
                                if entityBills[d].Parent then entityBills[d]:Destroy() end
                                entityBills[d] = nil
                            end
                        end
                    end
                end
            end)
        end
    end

    local itemKeywords = {"key", "battery", "fuse", "note", "book", "card", "lever", "generator", "flashlight", "crowbar", "wrench", "hammer", "code"}

    local function isItemName(name)
        local low = string.lower(name)
        for _, kw in ipairs(itemKeywords) do
            if string.find(low, kw) then return true end
        end
        return false
    end

    function setItemRadar(enabled)
        itemRadarEnabled = enabled
        itemRadarConn = safeDisc(itemRadarConn)
        clearItemRadar()
        if enabled then
            local cachedTargets = {}
            local lastScan = 0

            itemRadarConn = RunService.Heartbeat:Connect(function()
                local myRoot = getRoot()
                if not myRoot then return end
                local now = os.clock()

                if now - lastScan > 1.8 then
                    lastScan = now
                    cachedTargets = {}
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d:IsA("Tool") or d:IsA("ProximityPrompt") or isItemName(d.Name) then
                            local tp = d:IsA("BasePart") and d or (d:FindFirstChildWhichIsA("BasePart") or (d.Parent and d.Parent:IsA("BasePart") and d.Parent))
                            if tp and not tp:IsDescendantOf(LocalPlayer.Character) then
                                table.insert(cachedTargets, {obj = d, part = tp, name = d.Name})
                            end
                        end
                    end
                end

                for _, item in ipairs(cachedTargets) do
                    if item.part and item.part.Parent then
                        local dist = math.round((myRoot.Position - item.part.Position).Magnitude)
                        if dist <= 260 then
                            local bill = itemBills[item.obj]
                            if not bill or not bill.Parent then
                                bill = Instance.new("BillboardGui")
                                bill.Name = "NIXItemBill"
                                bill.Size = UDim2.new(0, 130, 0, 22)
                                bill.StudsOffset = Vector3.new(0, 2, 0)
                                bill.AlwaysOnTop = true
                                bill.Adornee = item.part
                                bill.Parent = item.part

                                local lbl = Instance.new("TextLabel")
                                lbl.Name = "ILbl"
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 0.4
                                lbl.BackgroundColor3 = Color3.fromRGB(6, 16, 20)
                                lbl.TextColor3 = Color3.fromRGB(80, 220, 255)
                                lbl.Font = Enum.Font.GothamBold
                                lbl.TextSize = 10
                                lbl.Parent = bill

                                local ilc = Instance.new("UICorner")
                                ilc.CornerRadius = UDim.new(0, 4)
                                ilc.Parent = lbl

                                itemBills[item.obj] = bill
                            end
                            local lbl = bill:FindFirstChild("ILbl")
                            if lbl then lbl.Text = string.format("[*] %s (%dm)", item.name, dist) end
                        end
                    end
                end
            end)
        end
    end
end

do
local clearVisionEnabled = false
local clearVisionConn = nil

function setClearVision(enabled)
    clearVisionEnabled = enabled
    clearVisionConn = safeDisc(clearVisionConn)

    if enabled then
        clearVisionConn = RunService.Heartbeat:Connect(function()
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("BlurEffect") and v.Enabled then
                    v.Enabled = false
                end
                if v:IsA("Atmosphere") and v.Density > 0.3 then
                    v.Density = 0.1
                end
            end
        end)
    end
end

end

do
local touchShieldEnabled = false
local touchShieldConn = nil

function setTouchShield(enabled)
    touchShieldEnabled = enabled
    touchShieldConn = safeDisc(touchShieldConn)

    local char = getChar()
    if not enabled and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = true
            end
        end
    end

    if enabled then
        touchShieldConn = RunService.Stepped:Connect(function()
            local c = getChar()
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanTouch then
                        part.CanTouch = false
                    end
                end
            end
        end)
    end
end

local antiFallEnabled = false
local antiFallConn = nil

function setAntiFall(enabled)
    antiFallEnabled = enabled
    antiFallConn = safeDisc(antiFallConn)

    if enabled then
        antiFallConn = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if not root then return end

            if root.AssemblyLinearVelocity.Y < -55 then
                local ray = Ray.new(root.Position, Vector3.new(0, -15, 0))
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {getChar()})
                if hit then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
                end
            end
        end)
    end
end

customWalkSpeed = 16
local speedBoostEnabled = false
local speedBoostConn = nil

function setSpeedBoost(enabled)
    speedBoostEnabled = enabled
    speedBoostConn = safeDisc(speedBoostConn)
    if enabled then
        speedBoostConn = RunService.Heartbeat:Connect(function()
            local hum = getHum()
            if hum and hum.WalkSpeed ~= customWalkSpeed then
                hum.WalkSpeed = customWalkSpeed
            end
        end)
    else
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    end
end

local godmodeEnabled = false
local godmodeConn = nil

function setGodmode(enabled)
    godmodeEnabled = enabled
    godmodeConn = safeDisc(godmodeConn)
    setDeathShield(enabled)
    setTouchShield(enabled)
    setAntiFall(enabled)

    local hum = getHum()
    if enabled and hum then
        godmodeConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godmodeEnabled and hum and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end

local deathShieldEnabled = false
local deathShieldConn = nil

function setDeathShield(enabled)
    deathShieldEnabled = enabled
    deathShieldConn = safeDisc(deathShieldConn)

    local hum = getHum()
    if not enabled and hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end)
    end

    if enabled and hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end)
        deathShieldConn = hum.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Dead or newState == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end

local promptEnabled = false
local promptConn = nil
local originalPrompts = {}

local function applyPrompt(p)
    if not p:IsA("ProximityPrompt") then return end
    if originalPrompts[p] == nil then
        originalPrompts[p] = {
            HoldDuration = p.HoldDuration,
            RequiresLineOfSight = p.RequiresLineOfSight,
            MaxActivationDistance = p.MaxActivationDistance
        }
    end
    p.HoldDuration = 0
    p.RequiresLineOfSight = false
    p.MaxActivationDistance = math.max(p.MaxActivationDistance, 25)
end

function setInstantPrompts(enabled)
    promptEnabled = enabled
    promptConn = safeDisc(promptConn)

    if enabled then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then applyPrompt(d) end
        end
        promptConn = workspace.DescendantAdded:Connect(function(d)
            if promptEnabled and d:IsA("ProximityPrompt") then
                task.wait(0.1)
                applyPrompt(d)
            end
        end)
    else
        for p, orig in pairs(originalPrompts) do
            if p and p.Parent then
                p.HoldDuration = orig.HoldDuration
                p.RequiresLineOfSight = orig.RequiresLineOfSight
                p.MaxActivationDistance = orig.MaxActivationDistance
            end
        end
        originalPrompts = {}
    end
end

local infZoomEnabled = false
local origMaxZoom = 128
local origMinZoom = 0.5
local origCamMode = Enum.CameraMode.Classic

function setInfZoom(enabled)
    infZoomEnabled = enabled
    if enabled then
        origMaxZoom = LocalPlayer.CameraMaxZoomDistance
        origMinZoom = LocalPlayer.CameraMinZoomDistance
        origCamMode = LocalPlayer.CameraMode
        LocalPlayer.CameraMaxZoomDistance = 100000
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    else
        LocalPlayer.CameraMaxZoomDistance = origMaxZoom
        LocalPlayer.CameraMinZoomDistance = origMinZoom
        LocalPlayer.CameraMode = origCamMode
    end
end

local unlockFirstPersonEnabled = false
local unlockFirstPersonConn = nil

function setUnlockFirstPerson(enabled)
    unlockFirstPersonEnabled = enabled
    unlockFirstPersonConn = safeDisc(unlockFirstPersonConn)
    if enabled then
        unlockFirstPersonConn = RunService.RenderStepped:Connect(function()
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
            end
            if LocalPlayer.CameraMaxZoomDistance < 1000 then
                LocalPlayer.CameraMaxZoomDistance = 100000
            end
            if LocalPlayer.CameraMinZoomDistance > 0.5 then
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
            if Camera.CameraType ~= Enum.CameraType.Custom then
                Camera.CameraType = Enum.CameraType.Custom
            end
        end)
    end
end

end

do
local autoClearAttributesEnabled = false
local autoClearAttributesConn = nil

function clearRestrictions()
    local targets = {LocalPlayer, getChar(), workspace, Camera}
    local count = 0
    for _, obj in ipairs(targets) do
        if obj then
            for name, _ in pairs(obj:GetAttributes()) do
                obj:SetAttribute(name, nil)
                count = count + 1
            end
        end
    end
    local hum = getHum()
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
            if state ~= Enum.HumanoidStateType.None then
                hum:SetStateEnabled(state, true)
            end
        end
    end
    return count
end

function setAutoClearAttributes(enabled)
    autoClearAttributesEnabled = enabled
    autoClearAttributesConn = safeDisc(autoClearAttributesConn)
    if enabled then
        autoClearAttributesConn = RunService.Heartbeat:Connect(function()
            clearRestrictions()
        end)
    end
end

function toggleAllScripts(state)
    local count = 0
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        for _, d in ipairs(ps:GetDescendants()) do
            if d:IsA("LocalScript") and d.Name ~= "NIXHub" and not d.Name:lower():find("camera") then
                d.Disabled = not state
                count = count + 1
            end
        end
    end
    return count
end

end

do
local hitboxDisplaceEnabled = false
hitboxDisplaceDist = 25
local origRootJointC0 = nil

local function getRootJoint()
    local root = getRoot()
    if not root then return nil end
    local rj = root:FindFirstChild("RootJoint")
    if rj then return rj end
    local char = getChar()
    local lt = char and char:FindFirstChild("LowerTorso")
    return lt and lt:FindFirstChild("Root")
end

function setHitboxDisplace(enabled)
    hitboxDisplaceEnabled = enabled
    local rj = getRootJoint()
    if not rj then return end

    if origRootJointC0 == nil then
        origRootJointC0 = rj.C0
    end

    if enabled then
        rj.C0 = origRootJointC0 * CFrame.new(0, 0, hitboxDisplaceDist)
    else
        if origRootJointC0 then
            rj.C0 = origRootJointC0
            origRootJointC0 = nil
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    origRootJointC0 = nil
    if godmodeEnabled then
        task.wait(0.6)
        setGodmode(true)
    end
    if speedBoostEnabled then
        task.wait(0.6)
        setSpeedBoost(true)
    end
    if ghostModeEnabled then
        task.wait(0.6)
        setGhostMode(true)
    end
    if deathShieldEnabled then
        task.wait(0.6)
        setDeathShield(true)
    end
    if touchShieldEnabled then
        task.wait(0.6)
        setTouchShield(true)
    end
    if hitboxDisplaceEnabled then
        task.wait(0.6)
        setHitboxDisplace(true)
    end
end)

end

do
local highlightsEnabled = false
local hlCleanup = nil

local function applyHighlight(player, char)
    if not char then return end
    local old = char:FindFirstChild("NIXHighlight")
    if old then old:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "NIXHighlight"
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0.1
    hl.FillColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function removeHighlight(player, char)
    if char then
        local old = char:FindFirstChild("NIXHighlight")
        if old then old:Destroy() end
    end
end

function setHighlights(enabled)
    highlightsEnabled = enabled
    if hlCleanup then hlCleanup(); hlCleanup = nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeHighlight(p, p.Character) end
    end

    if enabled then
        hlCleanup = forAllCharacters(applyHighlight, removeHighlight)
    end
end

local fullbrightConn = nil
function setFullbright(enabled)
    fullbrightConn = safeDisc(fullbrightConn)
    if enabled then
        fullbrightConn = RunService.Heartbeat:Connect(function()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
        end)
    else
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end
end

local nightVisionEffect = nil
local origAmbient, origOutdoorAmbient, origBrightness = nil, nil, nil

function setNightVision(enabled)
    if not nightVisionEffect then
        nightVisionEffect = Instance.new("ColorCorrectionEffect")
        nightVisionEffect.Name = "NIXNightVision"
        nightVisionEffect.Parent = Lighting
    end
    if enabled then
        origAmbient = Lighting.Ambient
        origOutdoorAmbient = Lighting.OutdoorAmbient
        origBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(20, 220, 80)
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 220, 80)
        Lighting.Brightness = 3.5
        nightVisionEffect.TintColor = Color3.fromRGB(130, 255, 140)
        nightVisionEffect.Brightness = 0.2
        nightVisionEffect.Contrast = 0.45
        nightVisionEffect.Saturation = -0.2
        nightVisionEffect.Enabled = true
    else
        if origAmbient then Lighting.Ambient = origAmbient end
        if origOutdoorAmbient then Lighting.OutdoorAmbient = origOutdoorAmbient end
        if origBrightness then Lighting.Brightness = origBrightness end
        nightVisionEffect.Enabled = false
    end
end

local cameraShakeEnabled = false
cameraShakeIntensity = 3
local cameraShakeConn = nil
local shakeTime = 0

function setCameraShake(enabled)
    cameraShakeEnabled = enabled
    cameraShakeConn = safeDisc(cameraShakeConn)
    if enabled then
        cameraShakeConn = RunService.RenderStepped:Connect(function(dt)
            shakeTime = shakeTime + dt * 8
            local i = cameraShakeIntensity * 0.0008
            Camera.CFrame = Camera.CFrame
                * CFrame.Angles(math.sin(shakeTime * 1.3) * i, math.sin(shakeTime * 0.9) * i * 0.7, 0)
        end)
    end
end

local headbobConn = nil
local bobTime = 0

function setHeadbob(enabled)
    headbobConn = safeDisc(headbobConn)
    if enabled then
        headbobConn = RunService.RenderStepped:Connect(function(dt)
            local hum = getHum()
            if not hum then return end
            local moving = hum.MoveDirection.Magnitude > 0.1
            if moving then
                bobTime = bobTime + dt * (hum.WalkSpeed * 0.25)
                Camera.CFrame = Camera.CFrame * CFrame.new(
                    math.sin(bobTime * 2.2) * 0.055,
                    math.abs(math.sin(bobTime)) * 0.04,
                    0
                )
            else
                bobTime = 0
            end
        end)
    end
end

local slFrame = nil
local slConn = nil

function setSpeedlines(enabled)
    if slFrame then slFrame:Destroy() slFrame = nil end
    slConn = safeDisc(slConn)
    if not enabled then return end

    slFrame = Instance.new("Frame")
    slFrame.Size = UDim2.new(1, 0, 1, 0)
    slFrame.BackgroundTransparency = 1
    slFrame.ZIndex = 5
    slFrame.Parent = ScreenGui

    slConn = RunService.RenderStepped:Connect(function(dt)
        local root = getRoot()
        if not root or not slFrame then return end
        local spd = root.AssemblyLinearVelocity.Magnitude
        local intensity = math.clamp((spd - 24) / 70, 0, 1)

        for _, line in ipairs(slFrame:GetChildren()) do
            local prog = (line:GetAttribute("p") or 0) + dt * (5 + spd * 0.06)
            if prog > 1 then
                line:Destroy()
            else
                line:SetAttribute("p", prog)
                local ease = 1 - (1 - prog) ^ 2
                line.BackgroundTransparency = 1 - intensity * (1 - ease)
                local ox = line:GetAttribute("ox") or 0.5
                local oy = line:GetAttribute("oy") or 0.5
                line.Position = UDim2.new(
                    0.5 + (ox - 0.5) * (1 + ease * 2.4), 0,
                    0.5 + (oy - 0.5) * (1 + ease * 2.4), 0
                )
            end
        end

        if intensity > 0.04 and math.random() < intensity * 0.5 then
            local ang = math.random() * math.pi * 2
            local r = 0.04 + math.random() * 0.06
            local ox = 0.5 + math.cos(ang) * r
            local oy = 0.5 + math.sin(ang) * r
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 1, 0, math.random(25, 80))
            line.Position = UDim2.new(ox, 0, oy, 0)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Rotation = math.deg(ang) + 90
            line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            line.BackgroundTransparency = 1
            line.BorderSizePixel = 0
            line.ZIndex = 5
            line:SetAttribute("p", 0)
            line:SetAttribute("ox", ox)
            line:SetAttribute("oy", oy)
            line.Parent = slFrame
        end
    end)
end

end

do
local ntCleanup = nil
local function applyNameTag(player, char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local old = head:FindFirstChild("NIXNameTag")
    if old then old:Destroy() end

    local bill = Instance.new("BillboardGui")
    bill.Name = "NIXNameTag"
    bill.Size = UDim2.new(0, 130, 0, 30)
    bill.StudsOffset = Vector3.new(0, 2.6, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = head

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel = 0
    bg.Parent = bill

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player.Name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Parent = bill
end

local function removeNameTag(player, char)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local old = head:FindFirstChild("NIXNameTag")
            if old then old:Destroy() end
        end
    end
end

function setNameTags(enabled)
    if ntCleanup then ntCleanup(); ntCleanup = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeNameTag(p, p.Character) end
    end
    if enabled then
        ntCleanup = forAllCharacters(applyNameTag, removeNameTag)
    end
end

local hbCleanup = nil
local function applyHealthBar(player, char)
    local head = char:WaitForChild("Head", 5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    local old = head:FindFirstChild("NIXHealthBar")
    if old then old:Destroy() end

    local bill = Instance.new("BillboardGui")
    bill.Name = "NIXHealthBar"
    bill.Size = UDim2.new(0, 90, 0, 9)
    bill.StudsOffset = Vector3.new(0, 1.8, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = head

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bg.BorderSizePixel = 0
    bg.Parent = bill

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Green
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not fill or not fill.Parent then return end
        local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        tw(fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.1)
        fill.BackgroundColor3 = Color3.fromRGB(
            math.floor((1 - ratio) * 220),
            math.floor(ratio * 200 + 20),
            40
        )
    end)
end

local function removeHealthBar(player, char)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local old = head:FindFirstChild("NIXHealthBar")
            if old then old:Destroy() end
        end
    end
end

function setHealthBars(enabled)
    if hbCleanup then hbCleanup(); hbCleanup = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeHealthBar(p, p.Character) end
    end
    if enabled then
        hbCleanup = forAllCharacters(applyHealthBar, removeHealthBar)
    end
end

local distConn = nil
function setDistanceTags(enabled)
    distConn = safeDisc(distConn)
    local function clearDist()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("Head")
                if h then
                    local b = h:FindFirstChild("NIXDistBill")
                    if b then b:Destroy() end
                end
            end
        end
    end
    if not enabled then clearDist(); return end

    distConn = RunService.Heartbeat:Connect(function()
        local myRoot = getRoot()
        if not myRoot then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer or not p.Character then continue end
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            if not tr or not head then continue end
            local dist = math.round((myRoot.Position - tr.Position).Magnitude)
            local bill = head:FindFirstChild("NIXDistBill")
            if not bill then
                bill = Instance.new("BillboardGui")
                bill.Name = "NIXDistBill"
                bill.Size = UDim2.new(0, 70, 0, 16)
                bill.StudsOffset = Vector3.new(0, 3.8, 0)
                bill.AlwaysOnTop = true
                bill.Adornee = head
                bill.Parent = head

                local lbl = Instance.new("TextLabel")
                lbl.Name = "DistLbl"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
                lbl.Font = Enum.Font.Code
                lbl.TextSize = 10
                lbl.TextStrokeTransparency = 0.4
                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lbl.Parent = bill
            end
            local lbl = bill:FindFirstChild("DistLbl")
            if lbl then lbl.Text = dist .. "m" end
        end
    end)
end

end


local discoveredScripts = {}
local discoveredRemotes = {}
local scanAccessibleScripts = nil
local scanRemotes = nil
local scanAndRefreshScripts = nil
local scanAndRefreshRemotes = nil
do
    local selectedIndex = 1
    local codeTextBox = nil
    local statusInfoLabel = nil

    scanAccessibleScripts = function()
        discoveredScripts = {}
        local seen = {}

        pcall(function()
            if getscripts then
                local slist = getscripts()
                if type(slist) == "table" then
                    for _, s in ipairs(slist) do
                        if typeof(s) == "Instance" and (s:IsA("LocalScript") or s:IsA("ModuleScript") or s:IsA("Script")) and not s.Name:find("NIX") then
                            if not seen[s] then
                                seen[s] = true
                                table.insert(discoveredScripts, s)
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if getloadedmodules then
                local mlist = getloadedmodules()
                if type(mlist) == "table" then
                    for _, m in ipairs(mlist) do
                        if typeof(m) == "Instance" and m:IsA("ModuleScript") and not m.Name:find("NIX") then
                            if not seen[m] then
                                seen[m] = true
                                table.insert(discoveredScripts, m)
                            end
                        end
                    end
                end
            end
        end)

        local searchRoots = {
            LocalPlayer:FindFirstChild("PlayerScripts"),
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("Backpack"),
            getChar(),
            game:GetService("ReplicatedStorage"),
            game:GetService("ReplicatedFirst"),
            workspace,
            game:GetService("StarterGui"),
            game:GetService("StarterPack"),
            game:GetService("StarterPlayer")
        }

        for _, root in ipairs(searchRoots) do
            if root then
                pcall(function()
                    if (root:IsA("LocalScript") or root:IsA("ModuleScript") or root:IsA("Script")) and not root.Name:find("NIX") then
                        if not seen[root] then
                            seen[root] = true
                            table.insert(discoveredScripts, root)
                        end
                    end
                    for _, d in ipairs(root:GetDescendants()) do
                        pcall(function()
                            if (d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script")) and not d.Name:find("NIX") then
                                if not seen[d] then
                                    seen[d] = true
                                    table.insert(discoveredScripts, d)
                                end
                            end
                        end)
                    end
                end)
            end
        end

        return #discoveredScripts
    end

    scanAndRefreshScripts = function()
        local cnt = scanAccessibleScripts()
        selectedIndex = 1
        updateScriptViewerUI()
        Notify("Scripts", "Found " .. cnt .. " accessible scripts", 2, Theme.Green)
    end

    function nextScriptViewer()
        if #discoveredScripts == 0 then scanAccessibleScripts() end
        if #discoveredScripts == 0 then return end
        selectedIndex = selectedIndex + 1
        if selectedIndex > #discoveredScripts then selectedIndex = 1 end
        updateScriptViewerUI()
    end

    function prevScriptViewer()
        if #discoveredScripts == 0 then scanAccessibleScripts() end
        if #discoveredScripts == 0 then return end
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then selectedIndex = #discoveredScripts end
        updateScriptViewerUI()
    end

    function toggleSelectedScript()
        if #discoveredScripts == 0 then return end
        local target = discoveredScripts[selectedIndex]
        if target and target:IsA("LocalScript") then
            target.Disabled = not target.Disabled
            updateScriptViewerUI()
            Notify("Scripts", target.Name .. " is now " .. (target.Disabled and "DISABLED" or "ENABLED"), 1.8, target.Disabled and Theme.Red or Theme.Green)
        else
            Notify("Scripts", "ModuleScripts cannot be disabled", 1.8, Theme.Red)
        end
    end

    function printSelectedScript()
        if #discoveredScripts == 0 then return end
        local target = discoveredScripts[selectedIndex]
        if target then
            local info = inspectScript(target)
            print("\n" .. info .. "\n")
            if setclipboard then
                pcall(setclipboard, info)
                Notify("Scripts", "Copied to clipboard + printed to console", 2, Theme.Green)
            else
                Notify("Scripts", "Dumped script info to console (F9)", 2, Theme.Green)
            end
        end
    end

    function bindScriptViewerElements(tb, lbl)
        codeTextBox = tb
        statusInfoLabel = lbl
    end
end



do
    local promptAuraEnabled = false
    local promptAuraConn = nil
    local promptAuraRadius = 30

    function setPromptAura(enabled)
        promptAuraEnabled = enabled
        promptAuraConn = safeDisc(promptAuraConn)
        if enabled then
            promptAuraConn = RunService.Heartbeat:Connect(function()
                local myRoot = getRoot()
                if not myRoot then return end
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pPart = prompt.Parent
                        local pos = pPart and (pPart:IsA("BasePart") and pPart.Position or (pPart:IsA("Model") and pPart:GetPivot().Position))
                        if pos and (myRoot.Position - pos).Magnitude <= promptAuraRadius then
                            prompt.HoldDuration = 0
                            prompt.RequiresLineOfSight = false
                            if fireproximityprompt then
                                pcall(fireproximityprompt, prompt)
                            else
                                pcall(function()
                                    prompt:InputHoldBegin()
                                    prompt:InputHoldEnd()
                                end)
                            end
                        end
                    end
                end
            end)
            Notify("Auto-Prompt", "Auto-Prompt Aura ON (Radius 30)", 1.8, Theme.Green)
        else
            Notify("Auto-Prompt", "Auto-Prompt Aura OFF", 1.5)
        end
    end
end

do
    local touchMagnetEnabled = false
    local touchMagnetConn = nil
    local lastMagnetScan = 0
    local cachedPickups = {}

    function setTouchMagnet(enabled)
        touchMagnetEnabled = enabled
        touchMagnetConn = safeDisc(touchMagnetConn)
        if enabled then
            touchMagnetConn = RunService.Heartbeat:Connect(function()
                local myRoot = getRoot()
                if not myRoot then return end
                local now = os.clock()
                if now - lastMagnetScan > 1.2 then
                    lastMagnetScan = now
                    cachedPickups = {}
                    for _, p in ipairs(workspace:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanTouch and not p:IsDescendantOf(LocalPlayer.Character) then
                            if p:FindFirstChildWhichIsA("TouchTransmitter") or string.find(string.lower(p.Name), "coin") or string.find(string.lower(p.Name), "gem") or string.find(string.lower(p.Name), "star") or string.find(string.lower(p.Name), "token") or string.find(string.lower(p.Name), "candy") or string.find(string.lower(p.Name), "drop") then
                                table.insert(cachedPickups, p)
                            end
                        end
                    end
                end
                for _, p in ipairs(cachedPickups) do
                    if p and p.Parent and p.CanTouch then
                        if (myRoot.Position - p.Position).Magnitude <= 35 then
                            if firetouchinterest then
                                pcall(firetouchinterest, myRoot, p, 0)
                                pcall(firetouchinterest, myRoot, p, 1)
                            else
                                pcall(function()
                                    p.CFrame = myRoot.CFrame
                                end)
                            end
                        end
                    end
                end
            end)
            Notify("Magnet", "Coin & Pickup Magnet ON (Radius 35)", 1.8, Theme.Green)
        else
            Notify("Magnet", "Coin & Pickup Magnet OFF", 1.5)
        end
    end
end

do
    local antiFlingEnabled = false
    local antiFlingConn = nil

    function setAntiFling(enabled)
        antiFlingEnabled = enabled
        antiFlingConn = safeDisc(antiFlingConn)
        if enabled then
            antiFlingConn = RunService.Stepped:Connect(function()
                local myRoot = getRoot()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                if myRoot and (part.Position - myRoot.Position).Magnitude <= 10 then
                                    if part.AssemblyLinearVelocity.Magnitude > 60 or part.AssemblyAngularVelocity.Magnitude > 60 then
                                        part.AssemblyLinearVelocity = Vector3.zero
                                        part.AssemblyAngularVelocity = Vector3.zero
                                    end
                                end
                            end
                        end
                    end
                end
                if myRoot and myRoot.AssemblyAngularVelocity.Magnitude > 120 then
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end
            end)
            Notify("Anti-Fling", "Anti-Fling Physics Shield ON", 1.8, Theme.Green)
        else
            Notify("Anti-Fling", "Anti-Fling Physics Shield OFF", 1.5)
        end
    end
end

do
    local freecamEnabled = false
    local freecamConn = nil
    local freecamCamCF = nil
    local btoolsEnabled = false
    local btoolsConn = nil

    function setFreecam(enabled)
        freecamEnabled = enabled
        freecamConn = safeDisc(freecamConn)
        if enabled then
            freecamCamCF = Camera.CFrame
            freecamConn = RunService.RenderStepped:Connect(function(dt)
                local move = Vector3.zero
                if keysDown.W then move = move + freecamCamCF.LookVector end
                if keysDown.S then move = move - freecamCamCF.LookVector end
                if keysDown.D then move = move + freecamCamCF.RightVector end
                if keysDown.A then move = move - freecamCamCF.RightVector end
                if keysDown.Space then move = move + Vector3.new(0, 1, 0) end
                if keysDown.LeftShift then move = move - Vector3.new(0, 1, 0) end
                local speed = 65
                freecamCamCF = freecamCamCF + (move.Magnitude > 0 and move.Unit * speed * dt or Vector3.zero)
                Camera.CFrame = freecamCamCF
            end)
            Notify("Freecam", "Freecam ON  *  WASD to Fly", 2, Theme.Green)
        else
            local root = getRoot()
            if root then Camera.CameraSubject = getHum() end
            Notify("Freecam", "Freecam OFF", 1.5)
        end
    end

    function setBTools(enabled)
        btoolsEnabled = enabled
        btoolsConn = safeDisc(btoolsConn)
        if enabled then
            btoolsConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local isCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                    local isAlt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
                    if isCtrl or isAlt then
                        local mp = UserInputService:GetMouseLocation()
                        local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
                        local params = RaycastParams.new()
                        local char = getChar()
                        if char then
                            params.FilterDescendantsInstances = {char}
                            params.FilterType = Enum.RaycastFilterType.Exclude
                        end
                        local res = workspace:Raycast(ray.Origin, ray.Direction * 3000, params)
                        if res and res.Instance then
                            if isCtrl then
                                local target = res.Instance
                                local name = target.Name
                                target:Destroy()
                                Notify("BTools", "Deleted: " .. name, 1.5, Theme.Red)
                            elseif isAlt then
                                local root = getRoot()
                                if root then
                                    root.CFrame = CFrame.new(res.Position + Vector3.new(0, 3.5, 0))
                                    Notify("BTools", "Teleported to surface", 1.5, Theme.Green)
                                end
                            end
                        end
                    end
                end
            end)
            Notify("BTools", "BTools ON: Ctrl+Click to Delete, Alt+Click to TP", 2.5, Theme.Green)
        else
            Notify("BTools", "BTools OFF", 1.5)
        end
    end
end

do
    local antiRagdollEnabled = false
    local antiRagdollConn = nil
    local infStaminaEnabled = false
    local infStaminaConn = nil

    function setAntiRagdoll(enabled)
        antiRagdollEnabled = enabled
        antiRagdollConn = safeDisc(antiRagdollConn)
        local hum = getHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not enabled)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not enabled)
            end)
        end
        if enabled then
            antiRagdollConn = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then
                    local state = h:GetState()
                    if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
                        h:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)
            Notify("Anti-Ragdoll", "Anti-Ragdoll ON  *  Immune to Knockdown", 1.8, Theme.Green)
        else
            Notify("Anti-Ragdoll", "Anti-Ragdoll OFF", 1.5)
        end
    end

    function setInfStamina(enabled)
        infStaminaEnabled = enabled
        infStaminaConn = safeDisc(infStaminaConn)
        if enabled then
            infStaminaConn = RunService.Heartbeat:Connect(function()
                local char = getChar()
                local targets = {LocalPlayer, char}
                for _, t in ipairs(targets) do
                    if t then
                        for _, attr in ipairs({"Stamina", "stamina", "Energy", "energy", "Sprint", "sprint", "Breath", "RunStamina"}) do
                            if t:GetAttribute(attr) ~= nil then
                                t:SetAttribute(attr, 100)
                            end
                        end
                        for _, d in ipairs(t:GetDescendants()) do
                            if d:IsA("NumberValue") or d:IsA("IntValue") then
                                local name = string.lower(d.Name)
                                if string.find(name, "stamina") or string.find(name, "energy") or string.find(name, "sprint") then
                                    d.Value = 100
                                end
                            end
                        end
                    end
                end
            end)
            Notify("Stamina", "Infinite Stamina ON  *  Locked at 100%", 1.8, Theme.Green)
        else
            Notify("Stamina", "Infinite Stamina OFF", 1.5)
        end
    end
end

do
    local antiVoidEnabled = false
    local antiVoidConn = nil
    local lastGroundCF = nil

    function setAntiVoid(enabled)
        antiVoidEnabled = enabled
        antiVoidConn = safeDisc(antiVoidConn)
        if enabled then
            local root = getRoot()
            if root then lastGroundCF = root.CFrame end
            antiVoidConn = RunService.Heartbeat:Connect(function()
                local myRoot = getRoot()
                local hum = getHum()
                if not myRoot or not hum then return end

                if hum.FloorMaterial ~= Enum.Material.Air then
                    lastGroundCF = myRoot.CFrame
                end

                if myRoot.Position.Y < -40 or myRoot.AssemblyLinearVelocity.Y < -140 then
                    if lastGroundCF then
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        myRoot.CFrame = lastGroundCF + Vector3.new(0, 3.5, 0)
                        Notify("Anti-Void", "Void Fall Saved  *  Returned to Platform", 1.5, Theme.Green)
                    end
                end
            end)
            Notify("Anti-Void", "Anti-Void Fall Rebound ON", 1.8, Theme.Green)
        else
            Notify("Anti-Void", "Anti-Void Fall Rebound OFF", 1.5)
        end
    end
end

do
    local spiderWalkEnabled = false
    local spiderWalkConn = nil

    function setSpiderWalk(enabled)
        spiderWalkEnabled = enabled
        spiderWalkConn = safeDisc(spiderWalkConn)
        if enabled then
            spiderWalkConn = RunService.Heartbeat:Connect(function(dt)
                local root = getRoot()
                local hum = getHum()
                if not root or not hum then return end
                if hum.MoveDirection.Magnitude > 0.1 then
                    local ray = Ray.new(root.Position, hum.MoveDirection * 2.5)
                    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {getChar()})
                    if hit and hit.CanCollide then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 35, root.AssemblyLinearVelocity.Z)
                    end
                end
            end)
            Notify("Spider-Walk", "Spider Wall Climb ON  *  Walk into Walls to Climb", 2, Theme.Green)
        else
            Notify("Spider-Walk", "Spider Wall Climb OFF", 1.5)
        end
    end
end

do
    local ghostDesyncEnabled = false
    local ghostDummy = nil
    local ghostAnchorPos = nil
    local ghostDesyncConn = nil

    function setGhostDesync(enabled)
        ghostDesyncEnabled = enabled
        ghostDesyncConn = safeDisc(ghostDesyncConn)
        local char = getChar()
        local root = getRoot()
        if not char or not root then return end

        if enabled then
            ghostAnchorPos = root.CFrame
            local clone = Instance.new("Model")
            clone.Name = "NIXGhostDummy"
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    local cp = p:Clone()
                    cp.Anchored = true
                    cp.CanCollide = false
                    cp.Transparency = 0.5
                    cp.Material = Enum.Material.ForceField
                    cp.Color = Color3.fromRGB(180, 200, 255)
                    cp.Parent = clone
                end
            end
            clone.Parent = workspace
            ghostDummy = clone

            ghostDesyncConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    settings().Physics.PhysicsSendRate = 1
                end)
            end)
            Notify("Ghost Desync", "Ghost Desync ON  *  Body Frozen for Enemies", 2, Theme.Green)
        else
            if ghostDummy then ghostDummy:Destroy() ghostDummy = nil end
            pcall(function()
                settings().Physics.PhysicsSendRate = 20
            end)
            Notify("Ghost Desync", "Ghost Desync OFF", 1.5)
        end
    end
end



do
    local audioSonarEnabled = false
    local audioSonarConn = nil
    local maxSonarDist = 120

    local function getSoundCategory(sound)
        local name = string.lower(sound.Name)
        if string.find(name, "step") or string.find(name, "walk") or string.find(name, "run") then
            return "Footstep", Color3.fromRGB(80, 180, 255), "👟"
        elseif string.find(name, "shot") or string.find(name, "fire") or string.find(name, "gun") or string.find(name, "shoot") or string.find(name, "blast") then
            return "Gunshot", Color3.fromRGB(255, 70, 70), "💥"
        elseif string.find(name, "reload") or string.find(name, "equip") or string.find(name, "click") then
            return "Weapon", Color3.fromRGB(255, 200, 60), "⚙️"
        elseif string.find(name, "jump") or string.find(name, "land") then
            return "Movement", Color3.fromRGB(160, 255, 120), "💨"
        else
            return "Audio", Color3.fromRGB(220, 220, 240), "🔊"
        end
    end

    local function spawnSonarPulse(sound, part)
        local myRoot = getRoot()
        if not myRoot or not part or not part.Parent then return end
        if part:IsDescendantOf(LocalPlayer.Character) then return end

        local dist = math.round((myRoot.Position - part.Position).Magnitude)
        if dist > maxSonarDist or dist < 2 then return end

        local category, color, icon = getSoundCategory(sound)

        local pulsePart = Instance.new("Part")
        pulsePart.Size = Vector3.new(0.5, 0.5, 0.5)
        pulsePart.Position = part.Position
        pulsePart.Anchored = true
        pulsePart.CanCollide = false
        pulsePart.Transparency = 1
        pulsePart.Parent = workspace

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 110, 0, 22)
        bill.StudsOffset = Vector3.new(0, 1.5, 0)
        bill.AlwaysOnTop = true
        bill.Adornee = pulsePart
        bill.Parent = pulsePart

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        lbl.BackgroundTransparency = 0.3
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.Text = string.format("%s %s (%dm)", icon, category, dist)
        lbl.Parent = bill

        local lc = Instance.new("UICorner")
        lc.CornerRadius = UDim.new(0, 4)
        lc.Parent = lbl

        local ls = Instance.new("UIStroke")
        ls.Color = color
        ls.Thickness = 1
        ls.Parent = lbl

        tw(bill, {StudsOffset = Vector3.new(0, 3.2, 0)}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        tw(lbl, {BackgroundTransparency = 1, TextTransparency = 1}, 1.2).Completed:Connect(function()
            pulsePart:Destroy()
        end)
    end

    function setAudioSonar(enabled)
        audioSonarEnabled = enabled
        audioSonarConn = safeDisc(audioSonarConn)
        if enabled then
            local monitoredSounds = {}
            audioSonarConn = RunService.Heartbeat:Connect(function()
                for _, s in ipairs(workspace:GetDescendants()) do
                    if s:IsA("Sound") and s.IsPlaying and s.Volume > 0.1 then
                        local p = s.Parent
                        if p and p:IsA("BasePart") and not monitoredSounds[s] then
                            monitoredSounds[s] = true
                            spawnSonarPulse(s, p)
                            task.delay(0.6, function() monitoredSounds[s] = nil end)
                        end
                    end
                end
            end)
            Notify("Audio Sonar", "3D Audio Sonar ON  *  Visualizing Sounds", 2, Theme.Green)
        else
            Notify("Audio Sonar", "3D Audio Sonar OFF", 1.5)
        end
    end
end

do
    local selectedRemoteIndex = 1
    local remoteStatusLabel = nil
    local remoteSpamEnabled = false
    local remoteSpamConn = nil

    scanRemotes = function()
        discoveredRemotes = {}
        local roots = {game:GetService("ReplicatedStorage"), workspace, game:GetService("Players")}
        for _, r in ipairs(roots) do
            if r then
                for _, d in ipairs(r:GetDescendants()) do
                    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                        table.insert(discoveredRemotes, d)
                    end
                end
            end
        end
        return #discoveredRemotes
    end

    local function getRemotePath(rem)
        if not rem then return "None" end
        local parts = {}
        local cur = rem
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

    local function updateRemoteUI()
        if not remoteStatusLabel then return end
        if #discoveredRemotes == 0 then
            remoteStatusLabel.Text = "No remotes found. Click 'Scan Remotes'."
            return
        end
        if selectedRemoteIndex > #discoveredRemotes then selectedRemoteIndex = 1 end
        if selectedRemoteIndex < 1 then selectedRemoteIndex = #discoveredRemotes end
        local rem = discoveredRemotes[selectedRemoteIndex]
        if rem then
            local cmd = getExecutableCommand and getExecutableCommand(rem) or getRemotePath(rem)
            remoteStatusLabel.Text = string.format("(%d/%d) %s [%s]\nCMD: %s", selectedRemoteIndex, #discoveredRemotes, rem.Name, rem.ClassName, cmd)
        end
    end

    scanAndRefreshRemotes = function()
        local cnt = scanRemotes()
        selectedRemoteIndex = 1
        updateRemoteUI()
        task.spawn(function() task.wait(0.2); compileGameLogbook() end)
        task.spawn(function() task.wait(0.2); compileGameLogbook() end)
        Notify("Remotes", "Discovered " .. cnt .. " Server Remotes", 2, Theme.Green)
    end

    function nextRemote()
        if #discoveredRemotes == 0 then scanRemotes() end
        if #discoveredRemotes == 0 then return end
        selectedRemoteIndex = selectedRemoteIndex + 1
        if selectedRemoteIndex > #discoveredRemotes then selectedRemoteIndex = 1 end
        updateRemoteUI()
    end

    function prevRemote()
        if #discoveredRemotes == 0 then scanRemotes() end
        if #discoveredRemotes == 0 then return end
        selectedRemoteIndex = selectedRemoteIndex - 1
        if selectedRemoteIndex < 1 then selectedRemoteIndex = #discoveredRemotes end
        updateRemoteUI()
    end

    function fireCurrentRemote(argType)
        if #discoveredRemotes == 0 then scanRemotes() end
        local rem = discoveredRemotes[selectedRemoteIndex]
        if not rem then return end

        pcall(function()
            if rem:IsA("RemoteEvent") then
                if argType == "None" then
                    rem:FireServer()
                elseif argType == "Player" then
                    rem:FireServer(LocalPlayer)
                elseif argType == "Number" then
                    rem:FireServer(100)
                elseif argType == "String" then
                    rem:FireServer("Claim")
                end
            elseif rem:IsA("RemoteFunction") then
                if argType == "None" then
                    rem:InvokeServer()
                elseif argType == "Player" then
                    rem:InvokeServer(LocalPlayer)
                end
            end
        end)
        Notify("Remote Invoker", "Fired: " .. rem.Name .. " (" .. argType .. ")", 1.5, Theme.Green)
    end

    function setRemoteSpam(enabled)
        remoteSpamEnabled = enabled
        remoteSpamConn = safeDisc(remoteSpamConn)
        if enabled then
            remoteSpamConn = RunService.Heartbeat:Connect(function()
                local rem = discoveredRemotes[selectedRemoteIndex]
                if rem and rem:IsA("RemoteEvent") then
                    pcall(function() rem:FireServer() end)
                end
            end)
            Notify("Remote Spam", "Spam Loop ON  *  Firing 60x/sec", 1.8, Theme.Green)
        else
            Notify("Remote Spam", "Spam Loop OFF", 1.5)
        end
    end

    function bindRemoteStatusLabel(lbl)
        remoteStatusLabel = lbl
    end
end

do
    local logbookFrame = Instance.new("Frame")
    logbookFrame.Name = "NIXLogbookFrame"
    logbookFrame.Size = UDim2.new(0, 360, 0, 260)
    logbookFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
    logbookFrame.BackgroundColor3 = Theme.Background
    logbookFrame.BorderSizePixel = 0
    logbookFrame.ZIndex = 130
    logbookFrame.Visible = false
    logbookFrame.Parent = ScreenGui

    local lbfCorner = Instance.new("UICorner", logbookFrame)
    lbfCorner.CornerRadius = UDim.new(0, 6)

    local lbfStroke = Instance.new("UIStroke", logbookFrame)
    lbfStroke.Color = Theme.Border
    lbfStroke.Thickness = 1

    local lbfTopBar = Instance.new("Frame")
    lbfTopBar.Size = UDim2.new(1, 0, 0, 30)
    lbfTopBar.BackgroundColor3 = Theme.Header
    lbfTopBar.BorderSizePixel = 0
    lbfTopBar.ZIndex = 131
    lbfTopBar.Parent = logbookFrame

    local lbfTopCorner = Instance.new("UICorner", lbfTopBar)
    lbfTopCorner.CornerRadius = UDim.new(0, 6)

    local lbfTitle = Instance.new("TextLabel")
    lbfTitle.Size = UDim2.new(0, 190, 1, 0)
    lbfTitle.Position = UDim2.new(0, 10, 0, 0)
    lbfTitle.BackgroundTransparency = 1
    lbfTitle.Text = "NIX LOGBOOK  *  GAME DOSSIER"
    lbfTitle.TextColor3 = Theme.Accent
    lbfTitle.Font = Enum.Font.GothamBold
    lbfTitle.TextSize = 10
    lbfTitle.TextXAlignment = Enum.TextXAlignment.Left
    lbfTitle.ZIndex = 132
    lbfTitle.Parent = lbfTopBar

    local lbfCloseBtn = Instance.new("TextButton")
    lbfCloseBtn.Size = UDim2.new(0, 22, 0, 22)
    lbfCloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
    lbfCloseBtn.BackgroundColor3 = Theme.ElementBg
    lbfCloseBtn.Text = "x"
    lbfCloseBtn.TextColor3 = Theme.TextSecondary
    lbfCloseBtn.Font = Enum.Font.GothamBold
    lbfCloseBtn.TextSize = 11
    lbfCloseBtn.BorderSizePixel = 0
    lbfCloseBtn.ZIndex = 132
    lbfCloseBtn.Parent = lbfTopBar

    local lbfCopyBtn = Instance.new("TextButton")
    lbfCopyBtn.Size = UDim2.new(0, 46, 0, 20)
    lbfCopyBtn.Position = UDim2.new(1, -76, 0.5, -10)
    lbfCopyBtn.BackgroundColor3 = Theme.ElementBg
    lbfCopyBtn.Text = "COPY"
    lbfCopyBtn.TextColor3 = Theme.TextPrimary
    lbfCopyBtn.Font = Enum.Font.Code
    lbfCopyBtn.TextSize = 9
    lbfCopyBtn.BorderSizePixel = 0
    lbfCopyBtn.ZIndex = 132
    lbfCopyBtn.Parent = lbfTopBar

    local lbfScroll = Instance.new("ScrollingFrame")
    lbfScroll.Size = UDim2.new(1, -12, 1, -40)
    lbfScroll.Position = UDim2.new(0, 6, 0, 34)
    lbfScroll.BackgroundTransparency = 1
    lbfScroll.BorderSizePixel = 0
    lbfScroll.ScrollBarThickness = 3
    lbfScroll.ScrollBarImageColor3 = Theme.BorderBright
    lbfScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    lbfScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lbfScroll.ZIndex = 131
    lbfScroll.Parent = logbookFrame

    local lbfLayout = Instance.new("UIListLayout")
    lbfLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lbfLayout.Padding = UDim.new(0, 3)
    lbfLayout.Parent = lbfScroll

    local lbfDragging, lbfDragInput, lbfMousePos, lbfFramePos = false, nil, nil, nil
    lbfTopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            lbfDragging = true
            lbfMousePos = inp.Position
            lbfFramePos = logbookFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then lbfDragging = false end
    end)
    lbfTopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then lbfDragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == lbfDragInput and lbfDragging then
            local d = inp.Position - lbfMousePos
            logbookFrame.Position = UDim2.new(lbfFramePos.X.Scale, lbfFramePos.X.Offset + d.X, lbfFramePos.Y.Scale, lbfFramePos.Y.Offset + d.Y)
        end
    end)

    lbfCloseBtn.MouseButton1Click:Connect(function() logbookFrame.Visible = false end)

    local cachedDossierText = ""

        local function getExecutableCommand(inst)
        if not inst then return "" end
        local parts = {}
        local cur = inst
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        local service = parts[1]
        local path = ""
        if service then
            path = string.format('game:GetService("%s")', service)
            for i = 2, #parts do
                local pName = parts[i]
                if string.match(pName, "^[a-zA-Z_][a-zA-Z0-9_]*$") then
                    path = path .. "." .. pName
                else
                    path = string.format('%s["%s"]', path, pName)
                end
            end
        else
            path = inst:GetFullName()
        end
        if inst:IsA("RemoteEvent") then
            return path .. ":FireServer()"
        elseif inst:IsA("RemoteFunction") then
            return path .. ":InvokeServer()"
        end
        return path
    end

    local function getFullInstancePath(inst)
        if not inst then return "" end
        local parts = {}
        local cur = inst
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

        local function addEntryCard(tag, title, detail, col)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = Theme.ElementBg
        card.BorderSizePixel = 0
        card.ZIndex = 132
        card.Parent = lbfScroll

        local cCorner = Instance.new("UICorner", card)
        cCorner.CornerRadius = UDim.new(0, 4)

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Size = UDim2.new(0, 48, 0, 14)
        tagLbl.Position = UDim2.new(0, 6, 0, 4)
        tagLbl.BackgroundColor3 = Theme.Header
        tagLbl.TextColor3 = col or Theme.Accent
        tagLbl.Font = Enum.Font.Code
        tagLbl.TextSize = 8
        tagLbl.Text = tag
        tagLbl.ZIndex = 133
        tagLbl.Parent = card

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -62, 0, 14)
        nameLbl.Position = UDim2.new(0, 58, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Theme.TextPrimary
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 9
        nameLbl.Text = title
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 133
        nameLbl.Parent = card

        local pathLbl = Instance.new("TextLabel")
        pathLbl.Size = UDim2.new(1, -12, 0, 12)
        pathLbl.Position = UDim2.new(0, 6, 0, 18)
        pathLbl.BackgroundTransparency = 1
        pathLbl.TextColor3 = Theme.TextSecondary
        pathLbl.Font = Enum.Font.Code
        pathLbl.TextSize = 8
        pathLbl.Text = detail
        pathLbl.TextXAlignment = Enum.TextXAlignment.Left
        pathLbl.ZIndex = 133
        pathLbl.Parent = card
    end

    function compileGameLogbook()
        lbfScroll:ClearAllChildren()
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 3)
        layout.Parent = lbfScroll

        local remotesCount = #discoveredRemotes
        local scriptsCount = #discoveredScripts
        local placeId = tostring(game.PlaceId)
        local jobId = string.sub(tostring(game.JobId), 1, 8)

        local lines = {}
        table.insert(lines, "=== NIX GAME ARCHITECTURE LOGBOOK ===")
        table.insert(lines, "Place ID: " .. placeId)
        table.insert(lines, "Job ID: " .. jobId)
        table.insert(lines, "Remotes Discovered: " .. remotesCount)
        table.insert(lines, "Scripts Discovered: " .. scriptsCount)
        table.insert(lines, "")
        table.insert(lines, "=== SERVER REMOTES ===")

        addEntryCard("INFO", "Game Place ID: " .. placeId, "Remotes: " .. remotesCount .. " | Scripts: " .. scriptsCount, Theme.Green)

        for _, r in ipairs(discoveredRemotes) do
            local p = getFullInstancePath(r)
            local tag = r:IsA("RemoteEvent") and "EVENT" or "FUNC"
            local cmd = getExecutableCommand(r)
            addEntryCard(tag, r.Name, cmd, Theme.Accent)
            table.insert(lines, string.format("[%s] %s\n      CMD: %s", tag, r.Name, cmd))
        end

        table.insert(lines, "")
        table.insert(lines, "=== CLIENT SCRIPTS ===")
        for _, s in ipairs(discoveredScripts) do
            local p = getFullInstancePath(s)
            local tag = s:IsA("LocalScript") and "LOCAL" or "MODULE"
            addEntryCard(tag, s.Name, p, Theme.TextSecondary)
            table.insert(lines, string.format("[%s] %s -> %s", tag, s.Name, p))
        end

        cachedDossierText = table.concat(lines, "\n")
        logbookFrame.Visible = true
        Notify("Logbook", "Dossier Compiled (" .. remotesCount .. " Remotes, " .. scriptsCount .. " Scripts)", 2.5, Theme.Accent)
    end

    function copyLogbookDossier()
        if cachedDossierText == "" then
            compileGameLogbook()
        end
        pcall(function()
            if setclipboard then
                setclipboard(cachedDossierText)
            end
        end)
        print(cachedDossierText)
        Notify("Logbook", "Copied to Clipboard & Console", 2, Theme.Green)
    end

    lbfCopyBtn.MouseButton1Click:Connect(copyLogbookDossier)

    
    function fullScanAndCopyClipboard()
        local rCnt = scanRemotes and scanRemotes() or 0
        local sCnt = scanAccessibleScripts and scanAccessibleScripts() or 0

        compileGameLogbook()
        copyLogbookDossier()

        Notify("Intel", string.format("COPIED! %d Remotes & %d Scripts on Clipboard", rCnt, sCnt), 3.5, Theme.Green)
        return rCnt, sCnt
    end

    function setLogbookVisible(v)
        logbookFrame.Visible = v
        if v and cachedDossierText == "" then
            compileGameLogbook()
        end
    end
end



do
    local bhopEnabled = false
    local bhopConn = nil
    local bhopStateConn = nil

    local function doBhopJump()
        local hum = getHum()
        local root = getRoot()
        if not hum or not root or hum.Health <= 0 then return end
        if hum.MoveDirection.Magnitude > 0.05 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local pwr = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight * 3.5)
            if pwr <= 0 then pwr = 50 end
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, pwr, root.AssemblyLinearVelocity.Z)
        end
    end

    function setBhop(enabled)
        bhopEnabled = enabled
        bhopConn = safeDisc(bhopConn)
        bhopStateConn = safeDisc(bhopStateConn)
        if enabled then
            bhopConn = RunService.Heartbeat:Connect(function()
                local hum = getHum()
                if hum and hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0.05 then
                    doBhopJump()
                end
            end)
            local hum = getHum()
            if hum then
                bhopStateConn = hum.StateChanged:Connect(function(_, newState)
                    if newState == Enum.HumanoidStateType.Landed then
                        doBhopJump()
                    end
                end)
            end
            Notify("B-Hop", "Bunnyhop ON  *  Auto-Jumping", 1.8, Theme.Green)
        else
            Notify("B-Hop", "Bunnyhop OFF", 1.5)
        end
    end
end

do
    local infJumpEnabled = false
    local infJumpConn = nil

    function setInfJump(enabled)
        infJumpEnabled = enabled
        infJumpConn = safeDisc(infJumpConn)
        if enabled then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getHum()
                local root = getRoot()
                if hum and root and hum.Health > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    local pwr = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight * 3.5)
                    if pwr <= 0 then pwr = 50 end
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, pwr, root.AssemblyLinearVelocity.Z)
                end
            end)
            Notify("Infinite Jump", "Infinite Jump ON  *  Jump Infinitely in Air", 1.8, Theme.Green)
        else
            Notify("Infinite Jump", "Infinite Jump OFF", 1.5)
        end
    end
end

do
    local autoWalkEnabled = false
    local autoWalkConn = nil

    function setAutoWalk(enabled)
        autoWalkEnabled = enabled
        autoWalkConn = safeDisc(autoWalkConn)
        if enabled then
            autoWalkConn = RunService.RenderStepped:Connect(function()
                local hum = getHum()
                if hum and hum.Health > 0 then
                    local x = (keysDown.D and 1 or 0) - (keysDown.A and 1 or 0)
                    local moveVec = Vector3.new(x, 0, -1)
                    if moveVec.Magnitude > 0 then
                        hum:Move(moveVec.Unit, true)
                    end
                end
            end)
            Notify("Movement", "Hold W Toggle ON", 1.5, Theme.Green)
        else
            Notify("Movement", "Hold W Toggle OFF", 1.5)
        end
    end

    local airStrafeEnabled = false
    local airStrafeConn = nil
    local airStrafeInputConn = nil
    local strafeBoost = 0
    local maxStrafeBoost = 35
    local lastStrafeKey = nil
    local lastSwitchTime = 0

    local function onStrafeKey(key)
        if key == Enum.KeyCode.A or key == Enum.KeyCode.D then
            local now = os.clock()
            if lastStrafeKey and lastStrafeKey ~= key then
                lastSwitchTime = now
            elseif not lastStrafeKey then
                lastSwitchTime = now
            end
            lastStrafeKey = key
        end
    end

    function setAirStrafe(enabled)
        airStrafeEnabled = enabled
        airStrafeConn = safeDisc(airStrafeConn)
        airStrafeInputConn = safeDisc(airStrafeInputConn)
        strafeBoost = 0
        lastStrafeKey = nil
        lastSwitchTime = 0
        if enabled then
            airStrafeInputConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and (inp.KeyCode == Enum.KeyCode.A or inp.KeyCode == Enum.KeyCode.D) then
                    onStrafeKey(inp.KeyCode)
                end
            end)
            airStrafeConn = RunService.Heartbeat:Connect(function(dt)
                local root = getRoot()
                local hum = getHum()
                if not root or not hum or hum.Health <= 0 then
                    strafeBoost = 0
                    return
                end

                local inAir = (hum.FloorMaterial == Enum.Material.Air)
                local isStrafing = inAir and (os.clock() - lastSwitchTime < 1.5) and (keysDown.A or keysDown.D)

                if inAir and isStrafing then
                    strafeBoost = math.clamp(strafeBoost + dt * 18, 0, maxStrafeBoost)
                    local vel = root.AssemblyLinearVelocity
                    local camCF = Camera.CFrame
                    local moveDir = Vector3.zero
                    if keysDown.A then moveDir = moveDir - camCF.RightVector end
                    if keysDown.D then moveDir = moveDir + camCF.RightVector end
                    if keysDown.W or autoWalkEnabled then moveDir = moveDir + camCF.LookVector end
                    if keysDown.S then moveDir = moveDir - camCF.LookVector end
                    moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

                    if moveDir.Magnitude > 0.05 then
                        moveDir = moveDir.Unit
                        local targetHVel = moveDir * (hum.WalkSpeed + strafeBoost)
                        local curHVel = Vector3.new(vel.X, 0, vel.Z)
                        local newHVel = curHVel:Lerp(targetHVel, math.clamp(dt * 7, 0.05, 0.45))

                        local newY = vel.Y
                        if newY < 0 then
                            newY = newY + math.abs(newY) * math.clamp(dt * 3.5, 0.02, 0.28) + dt * 15
                        else
                            newY = newY + dt * 6
                        end
                        root.AssemblyLinearVelocity = Vector3.new(newHVel.X, newY, newHVel.Z)
                    end
                else
                    if strafeBoost > 0 then
                        strafeBoost = math.max(0, strafeBoost - dt * 20)
                    end
                    if not inAir then
                        lastSwitchTime = 0
                        lastStrafeKey = nil
                    end
                end
            end)
            Notify("Physics", "Air-Strafing ON", 1.8, Theme.Green)
        else
            Notify("Physics", "Air-Strafing OFF", 1.5)
        end
    end

    function setAirStrafeBoost(val)
        maxStrafeBoost = val
    end
end

do
    local customAnimTrack = nil
    local customAnimSpeed = 1
    local customAnimLooped = true

    function playCustomAnimation(inputStr)
        local animId = string.match(tostring(inputStr), "%d+")
        if not animId then
            Notify("Animation", "Invalid Link or ID. Paste a valid Roblox ID.", 2, Theme.Red)
            return
        end

        local char = getChar()
        local hum = getHum()
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not char or not animator then
            Notify("Animation", "Character or Animator not found", 2, Theme.Red)
            return
        end

        if customAnimTrack then
            customAnimTrack:Stop()
            customAnimTrack:Destroy()
            customAnimTrack = nil
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId

        local ok, track = pcall(function()
            return animator:LoadAnimation(anim)
        end)

        if ok and track then
            customAnimTrack = track
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = customAnimLooped
            track:Play()
            track:AdjustSpeed(customAnimSpeed)
            Notify("Animation", "Playing Anim ID: " .. animId, 2, Theme.Green)
        else
            Notify("Animation", "Failed to load animation ID: " .. animId, 2, Theme.Red)
        end
    end

    function stopCustomAnimation()
        if customAnimTrack then
            customAnimTrack:Stop()
            customAnimTrack:Destroy()
            customAnimTrack = nil
            Notify("Animation", "Custom Animation Stopped", 1.5)
        end
    end

    function setCustomAnimSpeed(val)
        customAnimSpeed = val
        if customAnimTrack and customAnimTrack.IsPlaying then
            customAnimTrack:AdjustSpeed(val)
        end
    end

    function setCustomAnimLooped(val)
        customAnimLooped = val
        if customAnimTrack then
            customAnimTrack.Looped = val
        end
    end
end

do
    local tracersEnabled = false
    local tracersConn = nil
    local tracerLines = {}
    local tracerFolder = Instance.new("Folder")
    tracerFolder.Name = "NIXTracers"
    tracerFolder.Parent = ScreenGui

    local function clearTracers()
        for _, line in pairs(tracerLines) do
            if line and line.Parent then line:Destroy() end
        end
        tracerLines = {}
    end

    local function drawTracerLine(id, p1, p2, color)
        local line = tracerLines[id]
        if not line or not line.Parent then
            line = Instance.new("Frame")
            line.Name = "Tracer_" .. tostring(id)
            line.BorderSizePixel = 0
            line.ZIndex = 50
            line.Parent = tracerFolder
            tracerLines[id] = line
        end

        local dx = p2.X - p1.X
        local dy = p2.Y - p1.Y
        local dist = math.sqrt(dx * dx + dy * dy)
        local angle = math.deg(math.atan2(dy, dx))

        line.Size = UDim2.new(0, dist, 0, 1.5)
        line.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Rotation = angle
        line.BackgroundColor3 = color or Theme.Accent
        line.BackgroundTransparency = 0.25
        line.Visible = true
    end

    function setTracers(enabled)
        tracersEnabled = enabled
        tracersConn = safeDisc(tracersConn)
        clearTracers()
        if enabled then
            tracersConn = RunService.RenderStepped:Connect(function()
                local vp = Camera.ViewportSize
                local origin = Vector2.new(vp.X / 2, vp.Y)
                local seen = {}

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                seen[p.UserId] = true
                                local color = (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team) and Theme.Green or Theme.Accent
                                drawTracerLine(p.UserId, origin, Vector2.new(sp.X, sp.Y), color)
                            end
                        end
                    end
                end

                for id, line in pairs(tracerLines) do
                    if not seen[id] then
                        line.Visible = false
                    end
                end
            end)
            Notify("Tracers", "ESP Tracers ON", 1.5, Theme.Accent)
        else
            Notify("Tracers", "ESP Tracers OFF", 1.5)
        end
    end

    function setAimNoise(enabled) aimNoiseEnabled = enabled end
    function setAimNoiseIntensity(val) aimNoiseIntensity = val end
end



do
    local keybinds = {
        ToggleUI = Enum.KeyCode.RightShift,
        Fly = Enum.KeyCode.F,
        CursorTP = Enum.KeyCode.T,
        AirWalk = Enum.KeyCode.X
    }
    local listeningKey = nil

    function startRebind(actionName, btn)
        listeningKey = actionName
        btn.Text = "Press any key..."
        local conn = nil
        conn = UserInputService.InputBegan:Connect(function(inp, gpe)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                keybinds[actionName] = inp.KeyCode
                btn.Text = string.format("%s: [%s]", actionName, inp.KeyCode.Name)
                safeDisc(conn)
                listeningKey = nil
                Notify("Keybind", actionName .. " set to " .. inp.KeyCode.Name, 1.5, Theme.Accent)
            end
        end)
    end

    function getKeybind(actionName)
        return keybinds[actionName]
    end
end

do
    local themeElements = {}

    function registerThemeAccent(obj, prop)
        table.insert(themeElements, {Object = obj, Property = prop})
    end

    function setAccentColor(col, name)
        Theme.Accent = col
        Theme.BorderBright = col
        for _, item in ipairs(themeElements) do
            if item.Object and item.Object.Parent then
                pcall(function() item.Object[item.Property] = col end)
            end
        end
        if topNeonBar then topNeonBar.BackgroundColor3 = col end
        Notify("Theme", "Accent set to " .. (name or "Custom"), 1.5, col)
    end
end

do
    local cornerEspEnabled = false
    local cornerEspConn = nil
    local espBoxes = {}
    local espFolder = Instance.new("Folder")
    espFolder.Name = "NIXCornerESP"
    espFolder.Parent = ScreenGui

    local function clearCornerEsp()
        for _, box in pairs(espBoxes) do
            if box.Container and box.Container.Parent then box.Container:Destroy() end
        end
        espBoxes = {}
    end

    local function createBoxGui(id)
        local c = Instance.new("Frame")
        c.Name = "Box_" .. tostring(id)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ZIndex = 40
        c.Parent = espFolder

        local lines = {}
        for i = 1, 8 do
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Theme.Accent
            f.ZIndex = 41
            f.Parent = c
            lines[i] = f
        end

        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(0, 3, 1, 0)
        hpBg.Position = UDim2.new(0, -6, 0, 0)
        hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        hpBg.BorderSizePixel = 0
        hpBg.ZIndex = 41
        hpBg.Parent = c

        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.Position = UDim2.new(0, 0, 1, 0)
        hpFill.AnchorPoint = Vector2.new(0, 1)
        hpFill.BackgroundColor3 = Theme.Green
        hpFill.BorderSizePixel = 0
        hpFill.ZIndex = 42
        hpFill.Parent = hpBg

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, 0, 0, 14)
        distLbl.Position = UDim2.new(0, 0, 1, 3)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3 = Theme.TextPrimary
        distLbl.Font = Enum.Font.Code
        distLbl.TextSize = 9
        distLbl.ZIndex = 42
        distLbl.Parent = c

        local boxData = {Container = c, Lines = lines, HpFill = hpFill, DistLabel = distLbl}
        espBoxes[id] = boxData
        return boxData
    end

    local function updateCornerLines(lines, w, h, col)
        local t = 1.5
        local s = math.clamp(w * 0.28, 4, 14)

        lines[1].Size = UDim2.new(0, s, 0, t)
        lines[1].Position = UDim2.new(0, 0, 0, 0)
        lines[2].Size = UDim2.new(0, t, 0, s)
        lines[2].Position = UDim2.new(0, 0, 0, 0)

        lines[3].Size = UDim2.new(0, s, 0, t)
        lines[3].Position = UDim2.new(1, -s, 0, 0)
        lines[4].Size = UDim2.new(0, t, 0, s)
        lines[4].Position = UDim2.new(1, -t, 0, 0)

        lines[5].Size = UDim2.new(0, s, 0, t)
        lines[5].Position = UDim2.new(0, 0, 1, -t)
        lines[6].Size = UDim2.new(0, t, 0, s)
        lines[6].Position = UDim2.new(0, 0, 1, -s)

        lines[7].Size = UDim2.new(0, s, 0, t)
        lines[7].Position = UDim2.new(1, -s, 1, -t)
        lines[8].Size = UDim2.new(0, t, 0, s)
        lines[8].Position = UDim2.new(1, -t, 1, -s)

        for i = 1, 8 do lines[i].BackgroundColor3 = col end
    end

    function setCornerEsp(enabled)
        cornerEspEnabled = enabled
        cornerEspConn = safeDisc(cornerEspConn)
        clearCornerEsp()
        if enabled then
            cornerEspConn = RunService.RenderStepped:Connect(function()
                local seen = {}
                local myRoot = getRoot()

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                seen[p.UserId] = true
                                local topPoint = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
                                local btmPoint = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
                                local h = math.abs(btmPoint.Y - topPoint.Y)
                                local w = h * 0.65

                                local box = espBoxes[p.UserId] or createBoxGui(p.UserId)
                                box.Container.Visible = true
                                box.Container.Size = UDim2.new(0, w, 0, h)
                                box.Container.Position = UDim2.new(0, sp.X - w / 2, 0, topPoint.Y)

                                local col = (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team) and Theme.Green or Theme.Accent
                                updateCornerLines(box.Lines, w, h, col)

                                local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                box.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
                                box.HpFill.BackgroundColor3 = Color3.fromRGB(math.floor((1 - hpRatio) * 240), math.floor(hpRatio * 220 + 20), 40)

                                if myRoot then
                                    local dist = math.round((myRoot.Position - root.Position).Magnitude)
                                    box.DistLabel.Text = string.format("%dm", dist)
                                end
                            end
                        end
                    end
                end

                for id, box in pairs(espBoxes) do
                    if not seen[id] then box.Container.Visible = false end
                end
            end)
            Notify("ESP", "2D Corner Box ESP ON", 1.5, Theme.Accent)
        else
            Notify("ESP", "Corner Box ESP OFF", 1.5)
        end
    end
end


local function resetAll()
    setAirStrafe(false)
    setAutoWalk(false)
    setStickyLock(true)
    setTargetNpcs(false)
    setCornerEsp(false)
    setTracers(false)
    stopCustomAnimation()
    setBhop(false)
    setAudioSonar(false)
    setRemoteSpam(false)
    setPromptAura(false)
    setTouchMagnet(false)
    setAntiFling(false)
    setFreecam(false)
    setBTools(false)
    setAntiRagdoll(false)
    setInfStamina(false)
    setAntiVoid(false)
    setSpiderWalk(false)
    setGhostDesync(false)
    setAimAssist(false)
    setAutoShot(false)
    setHitboxExpander(false)
    setGodmode(false)
    setSpeedBoost(false)
    setNoclip(false)
    setAirWalk(false)
    setGhostMode(false)
    setFlashlight(false)
    setEntityRadar(false)
    setItemRadar(false)
    setChatSpy(false)
    setClearVision(false)
    setTouchShield(false)
    setAntiFall(false)
    setDeathShield(false)
    setInstantPrompts(false)
    setInfZoom(false)
    setHitboxDisplace(false)
    setUnlockFirstPerson(false)
    setAutoClearAttributes(false)
    setHighlights(false)
    setFullbright(false)
    setFlight(false)
    setInfJump(false)
    setNightVision(false)
    setDayCycle(false)
    setCameraShake(false)
    setHeadbob(false)
    setSpeedlines(false)
    setNameTags(false)
    setHealthBars(false)
    setDistanceTags(false)
    setRecoil(false)
    setFPSHud(false)
    setOverheadFlex(false)
    workspace.Gravity = 196
    Camera.FieldOfView = 70
    CrosshairFrame.Visible = false
    FovCircle.Visible = false
    if fcStroke then fcStroke.Color = Theme.Accent end
    Notify("System", "All features reset to defaults", 2.5, Theme.Red)
end

local CombatTab = createTab("Combat")
CombatTab:AddSection("Target Lock  [ Hold RMB ]")
CombatTab:AddToggle("Target Lock Assist", false, function(v) setAimAssist(v); Notify("Combat", v and "Hold RMB to lock nearest target" or "Target Lock OFF", 2) end)
CombatTab:AddToggle("Fast Snap Glide", false, function(v) aimSnap = v; Notify("Combat", v and "Snap Glide ON" or "Smooth Lock ON", 1.5) end)
CombatTab:AddToggle("Target NPCs & Monsters", false, function(v) setTargetNpcs(v) end)
CombatTab:AddToggle("Sticky Target Lock (Anti-Target Hop)", true, function(v) setStickyLock(v) end)


CombatTab:AddToggle("Predictive Lead Aim (Movement Tracking)", false, function(v) aimLeadEnabled = v; Notify("Combat", v and "Lead Prediction ON" or "Lead Prediction OFF", 1.5) end)
CombatTab:AddSlider("Lead Prediction (ms)", 0, 300, 120, function(v) aimLeadFactor = v / 1000 end)
CombatTab:AddToggle("Humanized Aim (Perlin Micro-Noise)", false, function(v) setAimNoise(v) end)
CombatTab:AddSlider("Aim Noise Intensity", 1, 20, 10, function(v) setAimNoiseIntensity(v / 10) end)
CombatTab:AddSlider("Glide Speed (%)", 2, 40, 12, function(v) glideSpeed = v / 100 end)
CombatTab:AddToggle("Wall Check (Line of Sight)", false, function(v) wallCheck = v end)
CombatTab:AddToggle("Team Check (Skip Allies)", false, function(v) teamCheck = v end)
CombatTab:AddToggle("Draw FOV Circle", false, function(v) FovCircle.Visible = v end)
CombatTab:AddSlider("FOV Radius (px)", 40, 700, 300, function(v) aimRange = v; FovCircle.Size = UDim2.new(0, v*2, 0, v*2) end)

CombatTab:AddSection("Auto Fire")
CombatTab:AddToggle("Auto Shot (Triggerbot)", false, function(v) setAutoShot(v); Notify("Combat", v and "Auto Shot ON" or "Auto Shot OFF", 1.5) end)
CombatTab:AddSlider("Shot Delay (ms)", 60, 350, 140, function(v) autoShotDelay = v / 1000 end)

CombatTab:AddSection("Hitbox Manipulation")
CombatTab:AddToggle("Hitbox Expander", false, function(v) setHitboxExpander(v); Notify("Combat", v and "Hitboxes Expanded" or "Hitboxes Normal", 1.5) end)
CombatTab:AddSlider("Hitbox Size (studs)", 4, 30, 10, function(v) hitboxSize = v; updateHitboxSizes() end)

CombatTab:AddSection("Camera & Feedback")
CombatTab:AddToggle("Procedural Recoil Sim", false, function(v) setRecoil(v) end)
CombatTab:AddButton("Trigger Recoil Kick", function() fireRecoil() end)
CombatTab:AddSlider("Recoil Intensity", 1, 20, 5, function(v) recoilIntensity = v end)
CombatTab:AddToggle("Camera Shake", false, function(v) setCameraShake(v) end)
CombatTab:AddSlider("Shake Intensity", 1, 12, 3, function(v) cameraShakeIntensity = v end)
CombatTab:AddButton("Fire Test Bullet Tracer", function() spawnBulletTracer() end)
CombatTab:AddToggle("Crosshair Overlay", false, function(v) CrosshairFrame.Visible = v end)
CombatTab:AddSlider("Camera FOV", 40, 120, 70, function(v) Camera.FieldOfView = v end)

local TeleportTab = createTab("Teleport")
TeleportTab:AddSection("Movement")
TeleportTab:AddButton("Teleport to Cursor  [ T ]", function() teleportToRaycast() end)
TeleportTab:AddSection("Player Teleport")
TeleportTab:AddButton("Teleport to Nearest Player", function() teleportToNearestPlayer() end)
TeleportTab:AddButton("Teleport to Random Player", function() teleportToRandomPlayer() end)
TeleportTab:AddButton("Cycle Next Player", function() cycleTeleportPlayer() end)

TeleportTab:AddSection("Waypoints  [ 3 Slots ]")
for _, slot in ipairs({"A", "B", "C"}) do
    TeleportTab:AddButton("Save Waypoint " .. slot, function()
        local root = getRoot()
        if root then
            savedWaypoints[slot] = root.CFrame
            Notify("Waypoint", "Slot " .. slot .. " saved", 1.5, Theme.Green)
        end
    end)
    TeleportTab:AddButton("Go to Waypoint " .. slot, function()
        local root = getRoot()
        if root and savedWaypoints[slot] then
            root.CFrame = savedWaypoints[slot]
            Notify("Waypoint", "Teleported to " .. slot, 1.5)
        else
            Notify("Waypoint", "Slot " .. slot .. " not saved yet", 1.5, Theme.Red)
        end
    end)
end

local VisualsTab = createTab("Visuals")
VisualsTab:AddSection("World Rendering")
VisualsTab:AddToggle("Player Highlights", false, function(v) setHighlights(v); Notify("Visuals", v and "Highlights ON" or "Highlights OFF", 1.5) end)
VisualsTab:AddToggle("Player ESP Tracers", false, function(v) setTracers(v) end)
VisualsTab:AddToggle("2D Corner Box ESP", false, function(v) setCornerEsp(v) end)
VisualsTab:AddToggle("Fullbright (Lock)", false, function(v) setFullbright(v); Notify("Visuals", v and "Fullbright ON" or "Fullbright OFF", 1.5) end)
VisualsTab:AddToggle("Night Vision", false, function(v) setNightVision(v) end)
VisualsTab:AddToggle("Auto Day/Night Cycle", false, function(v) setDayCycle(v) end)
VisualsTab:AddSlider("Time of Day", 0, 24, 14, function(v) Lighting.ClockTime = v end)
VisualsTab:AddSlider("Fog End Distance", 100, 6000, 2000, function(v) Lighting.FogEnd = v; Lighting.FogStart = v * 0.3 end)

VisualsTab:AddSection("Character Effects")
VisualsTab:AddToggle("Ghost Mode (Camo)", false, function(v) setGhostMode(v); Notify("Visuals", v and "Ghost Mode ON" or "Ghost Mode OFF", 1.5) end)
VisualsTab:AddToggle("Head Bob", false, function(v) setHeadbob(v) end)
VisualsTab:AddToggle("Speed Lines", false, function(v) setSpeedlines(v) end)

local PlayersTab = createTab("Players")
PlayersTab:AddSection("Chat Intelligence")
PlayersTab:AddToggle("Chat Spy (Global Interceptor)", false, function(v) setChatSpy(v) end)
PlayersTab:AddToggle("Show Chat Spy Window", false, function(v) setChatLogVisible(v) end)
PlayersTab:AddButton("Copy All Logs to Clipboard", function() dumpAllChatLogs() end)
PlayersTab:AddButton("View Last Spied Chat", function() Notify("ChatSpy", getLastSpiedChat(), 4, Color3.fromRGB(255, 220, 90)) end)
PlayersTab:AddSection("Player Indicators")
PlayersTab:AddToggle("Name Tags", false, function(v) setNameTags(v); Notify("Players", v and "Name Tags ON" or "Name Tags OFF", 1.5) end)
PlayersTab:AddToggle("Health Bars", false, function(v) setHealthBars(v); Notify("Players", v and "Health Bars ON" or "Health Bars OFF", 1.5) end)
PlayersTab:AddToggle("Distance Indicators", false, function(v) setDistanceTags(v) end)

local AnimsTab = createTab("Anims")
AnimsTab:AddSection("Custom Animation Link & Asset Loader")
local animInputBox = Instance.new("TextBox")
animInputBox.Size = UDim2.new(1, 0, 0, 32)
animInputBox.BackgroundColor3 = Theme.ElementBg
animInputBox.PlaceholderText = "Paste Roblox Catalog URL or Asset ID..."
animInputBox.PlaceholderColor3 = Theme.TextSecondary
animInputBox.Text = ""
animInputBox.TextColor3 = Theme.TextPrimary
animInputBox.Font = Enum.Font.Code
animInputBox.TextSize = 11
animInputBox.BorderSizePixel = 0
animInputBox.Parent = AnimsTab.Page

local aibCorner = Instance.new("UICorner")
aibCorner.CornerRadius = UDim.new(0, 4)
aibCorner.Parent = animInputBox

local aibStroke = Instance.new("UIStroke")
aibStroke.Color = Theme.Border
aibStroke.Thickness = 1
aibStroke.Parent = animInputBox

AnimsTab:AddButton("Load & Play Custom Animation", function()
    if animInputBox.Text ~= "" then
        playCustomAnimation(animInputBox.Text)
    else
        Notify("Animation", "Please enter a URL or Asset ID first", 1.8, Theme.Red)
    end
end)
AnimsTab:AddButton("Stop Animation", function() stopCustomAnimation() end)
AnimsTab:AddSlider("Playback Speed (x100)", 10, 300, 100, function(v) setCustomAnimSpeed(v / 100) end)
AnimsTab:AddToggle("Loop Animation", true, function(v) setCustomAnimLooped(v) end)

AnimsTab:AddSection("Avatar Rig Control")
AnimsTab:AddToggle("Force R15 Rig (Client Converter)", false, function(v) setForceR15(v) end)
AnimsTab:AddSection("UGC Animation Packs")
AnimsTab:AddButton("Jotaro Jojo Pack  [ UGC ]", function() applyAnimPack("Jotaro Jojo") end)
AnimsTab:AddButton("Crawling Horror Pack  [ UGC ]", function() applyAnimPack("Crawling Horror") end)
AnimsTab:AddSection("Universal Catalog Packs")
for _, pName in ipairs({"Ninja", "Mage", "Vampire", "Superhero", "Zombie", "Toy", "Levitation"}) do
    AnimsTab:AddButton(pName .. " Pack", function() applyAnimPack(pName) end)
end
AnimsTab:AddSection("Controls")
AnimsTab:AddButton("Stop Active Animations", function() stopAllAnimations(); Notify("Animations", "Animations stopped", 1.5) end)

local PhysicsTab = createTab("Physics")
PhysicsTab:AddSection("Flight  [ WASD / Space / Shift ]")
PhysicsTab:AddToggle("Creative Flight", false, function(v) setFlight(v); Notify("Physics", v and "Flight ON" or "Flight OFF", 1.5) end)
PhysicsTab:AddSlider("Flight Speed", 10, 250, 60, function(v) flightSpeed = v end)

PhysicsTab:AddSection("Locomotion")
PhysicsTab:AddToggle("Auto-Jump / Bunnyhop (B-Hop)", false, function(v) setBhop(v) end)
PhysicsTab:AddToggle("Noclip (Phase Walls)", false, function(v) setNoclip(v); Notify("Physics", v and "Noclip ON" or "Noclip OFF", 1.5) end)
PhysicsTab:AddToggle("Air Walk (Sky Floor)", false, function(v) setAirWalk(v); Notify("Physics", v and "Air Walk ON" or "Air Walk OFF", 1.5) end)
PhysicsTab:AddToggle("Infinite Jump", false, function(v) setInfJump(v); Notify("Physics", v and "Infinite Jump ON" or "Infinite Jump OFF", 1.5) end)
PhysicsTab:AddToggle("Air-Strafing (A/D Alternating)", false, function(v) setAirStrafe(v) end)
PhysicsTab:AddToggle("Hold W Toggle (Auto-Walk)", false, function(v) setAutoWalk(v) end)
PhysicsTab:AddSlider("Air-Strafe Max Boost", 10, 80, 35, function(v) setAirStrafeBoost(v) end)
PhysicsTab:AddToggle("Speed Boost (Lock)", false, function(v)
    setSpeedBoost(v)
    Notify("Physics", v and ("Speed locked to " .. customWalkSpeed) or "Speed default", 1.5)
end)
PhysicsTab:AddSlider("Walk Speed", 16, 250, 16, function(v)
    customWalkSpeed = v
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end)
PhysicsTab:AddSlider("Jump Power", 20, 300, 50, function(v)
    local hum = getHum()
    if hum then
        if hum.UseJumpPower then hum.JumpPower = v else hum.JumpHeight = v / 7.2 end
    end
end)
PhysicsTab:AddSlider("Workspace Gravity", 0, 400, 196, function(v) workspace.Gravity = v end)
PhysicsTab:AddButton("Respawn Character", function()
    local hum = getHum()
    if hum then hum.Health = 0 end
end)

local MiscTab = createTab("Misc")
MiscTab:AddSection("Survival & Immunity")
MiscTab:AddToggle("Godmode (Invulnerability)", false, function(v)
    setGodmode(v)
    Notify("Misc", v and "Godmode ON" or "Godmode OFF", 2, v and Theme.Green or Theme.Red)
end)
MiscTab:AddToggle("Killbrick Shield (Anti-Touch)", false, function(v) setTouchShield(v); Notify("Misc", v and "Touch Shield ON" or "Touch Shield OFF", 1.5) end)
MiscTab:AddToggle("Prevent Death State", false, function(v) setDeathShield(v); Notify("Misc", v and "Death State Disabled" or "Death State Default", 1.5) end)
MiscTab:AddToggle("Anti-Fall Damage", false, function(v) setAntiFall(v); Notify("Misc", v and "Anti-Fall ON" or "Anti-Fall OFF", 1.5) end)

MiscTab:AddSection("Horror Utilities")
MiscTab:AddToggle("Camera Flashlight", false, function(v) setFlashlight(v); Notify("Misc", v and "Flashlight ON" or "Flashlight OFF", 1.5) end)
MiscTab:AddSlider("Light Brightness", 1, 10, 3, function(v) flashlightBrightness = v; updateFlashlight() end)
MiscTab:AddSlider("Light Range (studs)", 20, 180, 70, function(v) flashlightRange = v; updateFlashlight() end)
MiscTab:AddToggle("Entity / Monster Radar", false, function(v) setEntityRadar(v); Notify("Misc", v and "Monster Radar ON" or "Monster Radar OFF", 1.5) end)
MiscTab:AddToggle("Anti-Horror Blur (Clear Screen)", false, function(v) setClearVision(v); Notify("Misc", v and "Clear Vision ON" or "Clear Vision OFF", 1.5) end)

MiscTab:AddSection("World & Interactions")
MiscTab:AddToggle("Instant Proximity Prompts", false, function(v) setInstantPrompts(v); Notify("Misc", v and "Instant Prompts ON" or "Instant Prompts OFF", 1.5) end)
MiscTab:AddToggle("Infinite Zoom & Unlock View", false, function(v) setInfZoom(v); Notify("Misc", v and "Infinite Zoom ON" or "Infinite Zoom OFF", 1.5) end)
MiscTab:AddToggle("Hitbox Displace (Desync)", false, function(v) setHitboxDisplace(v); Notify("Misc", v and "Hitbox Displaced" or "Hitbox Reset", 1.5) end)
MiscTab:AddSlider("Displace Distance", 5, 80, 25, function(v) hitboxDisplaceDist = v; if hitboxDisplaceEnabled then setHitboxDisplace(true) end end)

MiscTab:AddSection("Camera & Attribute Bypasses")
MiscTab:AddToggle("Force-Unlock First Person", false, function(v)
    setUnlockFirstPerson(v)
    Notify("Misc", v and "Forced First Person Unlocked" or "Camera Lock Default", 1.5)
end)
MiscTab:AddToggle("Auto-Clear Restricting Attributes", false, function(v)
    setAutoClearAttributes(v)
    Notify("Misc", v and "Auto-Clear Attributes ON" or "Auto-Clear OFF", 1.5)
end)
MiscTab:AddButton("Wipe All Attributes Now", function()
    local cnt = clearRestrictions()
    Notify("Misc", "Wiped " .. cnt .. " attributes", 1.5, Theme.Green)
end)

local ToolsTab = createTab("Tools")
ToolsTab:AddSection("PlayerScripts Controller")
ToolsTab:AddButton("Disable All Game LocalScripts", function()
    local c = toggleAllScripts(false)
    Notify("Tools", "Disabled " .. c .. " game scripts", 2, Theme.Red)
end)
ToolsTab:AddButton("Enable All Game LocalScripts", function()
    local c = toggleAllScripts(true)
    Notify("Tools", "Enabled " .. c .. " game scripts", 2, Theme.Green)
end)

ToolsTab:AddSection("Inspector")
ToolsTab:AddToggle("Hover Instance Inspector", false, function(v)
    HoverHud.Visible = v
    inspectorConn = safeDisc(inspectorConn)
    if v then
        inspectorConn = RunService.RenderStepped:Connect(function()
            local mp = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result and result.Instance then
                HoverHud.Text = string.format("  [%s]  %s", result.Instance.ClassName, result.Instance.Name)
            else
                HoverHud.Text = "  Hover over any instance..."
            end
        end)
    end
end)

ToolsTab:AddSection("Cleanup")
ToolsTab:AddButton("Clear Tagged Objects", function()
    local removed = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d.Name and (d.Name:find("NIX") or d.Name == "NIXAirWalkFloor" or d.Name == "NIXFlashlightAnchor") and (d:IsA("BasePart") or d:IsA("Beam") or d:IsA("Highlight")) then
            d:Destroy(); removed = removed + 1
        end
    end
    Notify("Tools", "Removed " .. removed .. " tagged objects", 2)
end)


local IntelTab = createTab("Intel")
IntelTab:AddSection("Game Architecture Intelligence")
IntelTab:AddButton("RUN RSEADMIN VULNERABILITY PROBE", function()
        local rse = game:GetService("ReplicatedStorage"):FindFirstChild("RSEAdmin")
        if not rse then
            Notify("Admin Probe", "RSEAdmin folder not found in this game", 2, Theme.Red)
            return
        end
        local req = rse:FindFirstChild("Request")
        local evt = rse:FindFirstChild("Event")
        local payloads = {"Admin", "GetAdmin", "GiveAdmin", "Cash", "Money", "Coins", "Speed", "BTools", "God", {"Admin"}}
        local vulns = 0
        local lines = {"=== RSEADMIN PROBE RESULTS ==="}
        for _, p in ipairs(payloads) do
            local pStr = type(p) == "table" and ("table: " .. tostring(p[1])) or tostring(p)
            if req and req:IsA("RemoteFunction") then
                local ok, res = pcall(function() return req:InvokeServer(p) end)
                if ok and res ~= nil and res ~= false then
                    vulns = vulns + 1
                    table.insert(lines, "[VULN] Request(" .. pStr .. ") -> " .. tostring(res))
                else
                    table.insert(lines, "[Blocked] Request(" .. pStr .. ")")
                end
            end
            if evt and evt:IsA("RemoteEvent") then pcall(function() evt:FireServer(p) end) end
            task.wait(0.06)
        end
        local resStr = table.concat(lines, "\n")
        print(resStr)
        if setclipboard then pcall(function() setclipboard(resStr) end) end
        Notify("Admin Probe", string.format("Probe Done! %d vulnerabilities. Copied to clipboard.", vulns), 3.5, vulns > 0 and Theme.Green or Theme.Red)
    end)
IntelTab:AddButton("FULL SCAN & INSTANT COPY (REMOTES + SCRIPTS)", function() fullScanAndCopyClipboard() end)
IntelTab:AddButton("Open Logbook Window", function() setLogbookVisible(true) end)
IntelTab:AddButton("Re-Copy Dossier to Clipboard", function() copyLogbookDossier() end)

IntelTab:AddSection("Individual Scanners")
IntelTab:AddButton("Scan Server Remotes Only", function() scanAndRefreshRemotes() end)
IntelTab:AddButton("Scan Client Scripts Only", function() scanAndRefreshScripts() end)

local SystemTab = createTab("System")
SystemTab:AddSection("Diagnostics")
SystemTab:AddToggle("FPS + Speed HUD", false, function(v) setFPSHud(v) end)
SystemTab:AddSection("Controls")
SystemTab:AddButton("Hide Menu  [ RShift ]", function() setVisible(false) end)
SystemTab:AddButton("Reset All Features", function() resetAll() end)

do
    local SettingsTab = createTab("Settings")

    SettingsTab:AddSection("Background Wallpaper")
    SettingsTab:AddButton("No Wallpaper (Clean Glass)", function()
        MainBgImage.Image = ""
        Notify("Wallpaper", "Set to clean frosted glass", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Preset: Cyberpunk Grid", function()
        MainBgImage.Image = "rbxassetid://13106539420"
        Notify("Wallpaper", "Loaded Cyberpunk Grid", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Preset: Deep Space Nebula", function()
        MainBgImage.Image = "rbxassetid://6071575925"
        Notify("Wallpaper", "Loaded Deep Space Nebula", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Preset: Minimal Hexagon", function()
        MainBgImage.Image = "rbxassetid://5107152095"
        Notify("Wallpaper", "Loaded Minimal Hexagon", 2, Theme.Accent)
    end)

    SettingsTab:AddSection("Glass & Visibility Sliders")
    SettingsTab:AddSlider("Wallpaper Opacity %", 0, 100, 50, function(val)
        MainBgImage.ImageTransparency = (100 - val) / 100
    end)
    SettingsTab:AddSlider("Glass Block Darkness %", 0, 100, 65, function(val)
        GlassDarkener.BackgroundTransparency = (100 - val) / 100
    end)
    SettingsTab:AddSlider("UI Glass Opacity %", 0, 100, 88, function(val)
        MainFrame.BackgroundTransparency = (100 - val) / 100
    end)

    SettingsTab:AddSection("Accent Color Themes")
    SettingsTab:AddButton("Monochrome Pure White", function()
        Theme.Accent = Color3.fromRGB(255, 255, 255)
        topNeonBar.BackgroundColor3 = Theme.Accent
        FloatToggle.TextColor3 = Theme.Accent
        Notify("Theme", "Switched to Pure White", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Cyber Neon Cyan", function()
        Theme.Accent = Color3.fromRGB(0, 235, 255)
        topNeonBar.BackgroundColor3 = Theme.Accent
        FloatToggle.TextColor3 = Theme.Accent
        Notify("Theme", "Switched to Cyber Cyan", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Electric Purple", function()
        Theme.Accent = Color3.fromRGB(185, 90, 255)
        topNeonBar.BackgroundColor3 = Theme.Accent
        FloatToggle.TextColor3 = Theme.Accent
        Notify("Theme", "Switched to Electric Purple", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Emerald Green", function()
        Theme.Accent = Color3.fromRGB(60, 240, 130)
        topNeonBar.BackgroundColor3 = Theme.Accent
        FloatToggle.TextColor3 = Theme.Accent
        Notify("Theme", "Switched to Emerald Green", 2, Theme.Accent)
    end)
    SettingsTab:AddButton("Crimson Strike Red", function()
        Theme.Accent = Color3.fromRGB(255, 60, 80)
        topNeonBar.BackgroundColor3 = Theme.Accent
        FloatToggle.TextColor3 = Theme.Accent
        Notify("Theme", "Switched to Crimson Red", 2, Theme.Accent)
    end)

    SettingsTab:AddSection("Automation & QoL")
    local antiAfkConn = nil
    SettingsTab:AddToggle("Anti-AFK (Prevent 20m Kick)", false, function(enabled)
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
        if enabled then
            local vu = nil
            pcall(function() vu = game:GetService("VirtualUser") end)
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                if vu then
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.zero)
                    end)
                end
            end)
            Notify("Anti-AFK", "Enabled - 20min kick protection active", 3, Theme.Green)
        else
            Notify("Anti-AFK", "Disabled", 2, Theme.Red)
        end
    end)

    SettingsTab:AddButton("Rejoin Same Server", function()
        local ts = game:GetService("TeleportService")
        pcall(function() ts:Teleport(game.PlaceId, LocalPlayer) end)
    end)
    SettingsTab:AddButton("Copy Server JobId", function()
        if setclipboard then pcall(function() setclipboard(game.JobId) end) end
        Notify("JobId", "Server JobId copied to clipboard", 2.5, Theme.Accent)
    end)
end

task.defer(function()
    print("[NIXHub] Loaded successfully!")
    Notify("NIXHub", "Loaded  *  RShift / Float Icon to toggle", 4, Theme.Green)
end)



local ScriptsTab = createTab("Scripts")
ScriptsTab:AddSection("Script Discovery")
ScriptsTab:AddButton("Scan All Accessible Scripts", function() scanAndRefreshScripts() end)

ScriptsTab:AddSection("Active Script Selection")

local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 32)
statusCard.BackgroundColor3 = Theme.ElementBg
statusCard.BorderSizePixel = 0
statusCard.Parent = ScriptsTab.Page

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 5)
scCorner.Parent = statusCard

local scStroke = Instance.new("UIStroke")
scStroke.Color = Theme.BorderBright
scStroke.Thickness = 1
scStroke.Parent = statusCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 1, 0)
statusLabel.Position = UDim2.new(0, 8, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "No scripts loaded. Click 'Scan All Accessible Scripts'."
statusLabel.TextColor3 = Theme.Accent
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusCard

ScriptsTab:AddButton("Next Script  >", function() nextScriptViewer() end)
ScriptsTab:AddButton("<  Previous Script", function() prevScriptViewer() end)
ScriptsTab:AddButton("Toggle Disable / Enable Active Script", function() toggleSelectedScript() end)
ScriptsTab:AddButton("Copy / Dump Script Info to Console", function() printSelectedScript() end)

ScriptsTab:AddSection("Source & Metadata Viewer")

local viewerFrame = Instance.new("Frame")
viewerFrame.Size = UDim2.new(1, 0, 0, 220)
viewerFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
viewerFrame.BorderSizePixel = 0
viewerFrame.Parent = ScriptsTab.Page

local vfCorner = Instance.new("UICorner")
vfCorner.CornerRadius = UDim.new(0, 5)
vfCorner.Parent = viewerFrame

local vfStroke = Instance.new("UIStroke")
vfStroke.Color = Theme.Border
vfStroke.Thickness = 1
vfStroke.Parent = viewerFrame

local scrollBox = Instance.new("ScrollingFrame")
scrollBox.Size = UDim2.new(1, -12, 1, -12)
scrollBox.Position = UDim2.new(0, 6, 0, 6)
scrollBox.BackgroundTransparency = 1
scrollBox.BorderSizePixel = 0
scrollBox.ScrollBarThickness = 3
scrollBox.ScrollBarImageColor3 = Theme.BorderBright
scrollBox.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollBox.AutomaticCanvasSize = Enum.AutomaticSize.XY
scrollBox.Parent = viewerFrame

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, 0, 1, 0)
codeBox.BackgroundTransparency = 1
codeBox.BorderSizePixel = 0
codeBox.Text = "Click 'Scan All Accessible Scripts' above to inspect game scripts..."
codeBox.TextColor3 = Color3.fromRGB(200, 205, 225)
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 10
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.ClearTextOnFocus = false
codeBox.TextEditable = false
codeBox.MultiLine = true
codeBox.Parent = scrollBox

bindScriptViewerElements(codeBox, statusLabel)



local PowerTab = createTab("God & World")
PowerTab:AddSection("World Interaction Exploits")
PowerTab:AddToggle("Auto-Prompt Aura (Instant Interact)", false, function(v) setPromptAura(v) end)
PowerTab:AddToggle("Coin & Pickup Magnet (Auto-Farm)", false, function(v) setTouchMagnet(v) end)

PowerTab:AddSection("Invulnerability & Defense")
PowerTab:AddToggle("Anti-Fling Physics Shield (Immunity)", false, function(v) setAntiFling(v) end)
PowerTab:AddToggle("Anti-Ragdoll (No Knockdown / Trip)", false, function(v) setAntiRagdoll(v) end)
PowerTab:AddToggle("Infinite Stamina Lock (100%)", false, function(v) setInfStamina(v) end)
PowerTab:AddToggle("Anti-Void Fall Rebound (Save Falls)", false, function(v) setAntiVoid(v) end)
PowerTab:AddToggle("Ghost Desync (Freeze Replica)", false, function(v) setGhostDesync(v) end)

PowerTab:AddSection("Locomotion & BTools")
PowerTab:AddToggle("Spider Wall Climb (Climb Any Surface)", false, function(v) setSpiderWalk(v) end)
PowerTab:AddToggle("6-DOF Freecam (Fly Camera Through Walls)", false, function(v) setFreecam(v) end)
PowerTab:AddToggle("BTools (Ctrl+Click Delete, Alt+Click TP)", false, function(v) setBTools(v) end)



ScriptsTab:AddSection("Server Remote Explorer & Invoker")
ScriptsTab:AddButton("Scan All Server Remotes", function() scanAndRefreshRemotes() end)

local remCard = Instance.new("Frame")
remCard.Size = UDim2.new(1, 0, 0, 36)
remCard.BackgroundColor3 = Theme.ElementBg
remCard.BorderSizePixel = 0
remCard.Parent = ScriptsTab.Page

local rmcCorner = Instance.new("UICorner")
rmcCorner.CornerRadius = UDim.new(0, 5)
rmcCorner.Parent = remCard

local rmcStroke = Instance.new("UIStroke")
rmcStroke.Color = Theme.BorderBright
rmcStroke.Thickness = 1
rmcStroke.Parent = remCard

local remLabel = Instance.new("TextLabel")
remLabel.Size = UDim2.new(1, -16, 1, 0)
remLabel.Position = UDim2.new(0, 8, 0, 0)
remLabel.BackgroundTransparency = 1
remLabel.Text = "No remotes loaded. Click 'Scan All Server Remotes'."
remLabel.TextColor3 = Theme.Accent
remLabel.Font = Enum.Font.Code
remLabel.TextSize = 10
remLabel.TextXAlignment = Enum.TextXAlignment.Left
remLabel.Parent = remCard

bindRemoteStatusLabel(remLabel)

ScriptsTab:AddButton("Next Remote  >", function() nextRemote() end)
ScriptsTab:AddButton("<  Previous Remote", function() prevRemote() end)
ScriptsTab:AddButton("Fire Remote (No Arguments)", function() fireCurrentRemote("None") end)
ScriptsTab:AddButton("Fire Remote (Pass LocalPlayer)", function() fireCurrentRemote("Player") end)
ScriptsTab:AddButton("Fire Remote (Pass Number 100)", function() fireCurrentRemote("Number") end)
ScriptsTab:AddButton("Fire Remote (Pass String 'Claim')", function() fireCurrentRemote("String") end)
ScriptsTab:AddToggle("Auto-Spam Selected Remote (60x/s)", false, function(v) setRemoteSpam(v) end)

do
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(0, 26, 0, 26)
    discordBtn.AnchorPoint = Vector2.new(1, 1)
    discordBtn.Position = UDim2.new(1, -10, 1, -10)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.AutoButtonColor = false
    discordBtn.ZIndex = 80
    discordBtn.Image = "rbxassetid://9078696883"
    discordBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.Parent = MainFrame

    local dcCorner = Instance.new("UICorner")
    dcCorner.CornerRadius = UDim.new(0, 6)
    dcCorner.Parent = discordBtn

    local dcStroke = Instance.new("UIStroke")
    dcStroke.Color = Color3.fromRGB(120, 135, 255)
    dcStroke.Thickness = 1
    dcStroke.Parent = discordBtn

    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "DiscordTooltip"
    tooltip.Size = UDim2.new(0, 130, 0, 22)
    tooltip.AnchorPoint = Vector2.new(1, 0.5)
    tooltip.Position = UDim2.new(0, -6, 0.5, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    tooltip.BackgroundTransparency = 0.1
    tooltip.Text = "Join Discord Server"
    tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    tooltip.Font = Enum.Font.GothamMedium
    tooltip.TextSize = 10
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.ZIndex = 85
    tooltip.Parent = discordBtn

    local ttCorner = Instance.new("UICorner")
    ttCorner.CornerRadius = UDim.new(0, 4)
    ttCorner.Parent = tooltip

    local ttStroke = Instance.new("UIStroke")
    ttStroke.Color = Color3.fromRGB(88, 101, 242)
    ttStroke.Thickness = 1
    ttStroke.Parent = tooltip

    discordBtn.MouseEnter:Connect(function()
        tooltip.Visible = true
        tw(discordBtn, {Size = UDim2.new(0, 28, 0, 28), BackgroundColor3 = Color3.fromRGB(105, 118, 255)}, 0.12)
    end)
    discordBtn.MouseLeave:Connect(function()
        tooltip.Visible = false
        tw(discordBtn, {Size = UDim2.new(0, 26, 0, 26), BackgroundColor3 = Color3.fromRGB(88, 101, 242)}, 0.12)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        local inviteLink = "https://discord.gg/P7fuzYj5xK"
        if setclipboard then
            pcall(setclipboard, inviteLink)
        elseif toclipboard then
            pcall(toclipboard, inviteLink)
        end
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            pcall(function()
                req({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        cmd = "INVITE_BROWSER",
                        args = {
                            code = "P7fuzYj5xK"
                        },
                        nonce = game:GetService("HttpService"):GenerateGUID(false)
                    })
                })
            end)
        end
        Notify("Discord", "Invite copied to clipboard!", 3, Color3.fromRGB(88, 101, 242))
    end)
end

do
    local watermark = Instance.new("TextLabel")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 240, 0, 14)
    watermark.AnchorPoint = Vector2.new(0, 1)
    watermark.Position = UDim2.new(0, 10, 1, -6)
    watermark.BackgroundTransparency = 1
    watermark.Text = "v2.0.0  Â·  discord.gg/P7fuzYj5xK"
    watermark.TextColor3 = Theme.TextSecondary
    watermark.TextTransparency = 0.5
    watermark.Font = Enum.Font.Gotham
    watermark.TextSize = 8
    watermark.TextXAlignment = Enum.TextXAlignment.Left
    watermark.ZIndex = 12
    watermark.Parent = MainFrame
end

do
    local resizer = Instance.new("TextButton")
    resizer.Name = "WindowResizerGrip"
    resizer.Size = UDim2.new(0, 18, 0, 18)
    resizer.Position = UDim2.new(1, -18, 1, -18)
    resizer.BackgroundTransparency = 1
    resizer.Text = "â²"
    resizer.TextColor3 = Theme.TextSecondary
    resizer.TextSize = 13
    resizer.Font = Enum.Font.Gotham
    resizer.ZIndex = 60
    resizer.Parent = MainFrame

    local isResizing = false
    local resizeStart = nil
    local frameStartSize = nil

    resizer.MouseEnter:Connect(function()
        tw(resizer, {TextColor3 = Theme.Accent}, 0.12)
    end)
    resizer.MouseLeave:Connect(function()
        if not isResizing then
            tw(resizer, {TextColor3 = Theme.TextSecondary}, 0.12)
        end
    end)

    resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            resizeStart = input.Position
            frameStartSize = MainFrame.AbsoluteSize
            tw(resizer, {TextColor3 = Theme.Accent}, 0.1)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
            isResizing = false
            tw(resizer, {TextColor3 = Theme.TextSecondary}, 0.15)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newW = math.clamp(frameStartSize.X + delta.X, 480, 960)
            local newH = math.clamp(frameStartSize.Y + delta.Y, 360, 720)
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
            MainShadow.Size = UDim2.new(0, newW + 16, 0, newH + 16)
        end
    end)
end

do
    local collapseBtn = Instance.new("TextButton")
    collapseBtn.Name = "SidebarCollapseBtn"
    collapseBtn.Size = UDim2.new(0, 26, 0, 26)
    collapseBtn.Position = UDim2.new(0, 8, 0.5, -13)
    collapseBtn.BackgroundColor3 = Theme.ElementBg
    collapseBtn.BackgroundTransparency = 0.2
    collapseBtn.Text = "â¡"
    collapseBtn.TextColor3 = Theme.TextSecondary
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.TextSize = 14
    collapseBtn.BorderSizePixel = 0
    collapseBtn.AutoButtonColor = false
    collapseBtn.ZIndex = 16
    collapseBtn.Parent = TopBar

    local ccCorner = Instance.new("UICorner")
    ccCorner.CornerRadius = UDim.new(0, 4)
    ccCorner.Parent = collapseBtn

    local ccStroke = Instance.new("UIStroke")
    ccStroke.Color = Theme.Border
    ccStroke.Thickness = 1
    ccStroke.Parent = collapseBtn

    collapseBtn.MouseEnter:Connect(function()
        tw(collapseBtn, {BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Accent}, 0.12)
        tw(ccStroke, {Color = Theme.BorderBright}, 0.12)
    end)
    collapseBtn.MouseLeave:Connect(function()
        tw(collapseBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12)
        tw(ccStroke, {Color = Theme.Border}, 0.12)
    end)

    local titleLbl = TopBar:FindFirstChild("TextLabel")
    if titleLbl then
        titleLbl.Position = UDim2.new(0, 42, 0, 0)
    end

    Sidebar.ClipsDescendants = true
    local isCollapsed = false

    collapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        if isCollapsed then
            tw(Sidebar, {Size = UDim2.new(0, 40, 1, -42), BackgroundTransparency = 0.2}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tw(ContentArea, {Size = UDim2.new(1, -40, 1, -42), Position = UDim2.new(0, 40, 0, 42)}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            for _, tabObj in ipairs(AllTabs) do
                if tabObj and tabObj.Button then
                    local iconOnly = tabIcons[tabObj.Name] or string.sub(tabObj.Name, 1, 2)
                    tabObj.Button.Text = iconOnly
                    tabObj.Button.TextXAlignment = Enum.TextXAlignment.Center
                    local pad = tabObj.Button:FindFirstChildOfClass("UIPadding")
                    if pad then pad.PaddingLeft = UDim.new(0, 0) end
                end
            end
        else
            tw(Sidebar, {Size = UDim2.new(0, 136, 1, -42), BackgroundTransparency = 0.06}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tw(ContentArea, {Size = UDim2.new(1, -136, 1, -42), Position = UDim2.new(0, 136, 0, 42)}, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            for _, tabObj in ipairs(AllTabs) do
                if tabObj and tabObj.Button then
                    local icon = tabIcons[tabObj.Name] or ""
                    tabObj.Button.Text = (icon ~= "" and (icon .. "  ") or "") .. string.upper(tabObj.Name)
                    tabObj.Button.TextXAlignment = Enum.TextXAlignment.Left
                    local pad = tabObj.Button:FindFirstChildOfClass("UIPadding")
                    if pad then pad.PaddingLeft = UDim.new(0, 10) end
                end
            end
        end
    end)
end

do
    local profileCard = Instance.new("Frame")
    profileCard.Name = "UserProfileCard"
    profileCard.Size = UDim2.new(1, -12, 0, 48)
    profileCard.Position = UDim2.new(0, 6, 1, -54)
    profileCard.BackgroundColor3 = Theme.ElementBg
    profileCard.BackgroundTransparency = 0.2
    profileCard.BorderSizePixel = 0
    profileCard.ZIndex = 12
    profileCard.Parent = Sidebar

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 5)
    pcCorner.Parent = profileCard

    local pcStroke = Instance.new("UIStroke")
    pcStroke.Color = Theme.Border
    pcStroke.Thickness = 1
    pcStroke.Parent = profileCard

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 32, 0, 32)
    avatarImg.Position = UDim2.new(0, 8, 0.5, -16)
    avatarImg.BackgroundColor3 = Theme.Background
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=100&h=100"
    avatarImg.Parent = profileCard

    local aiCorner = Instance.new("UICorner")
    aiCorner.CornerRadius = UDim.new(1, 0)
    aiCorner.Parent = avatarImg

    local liveDot = Instance.new("Frame")
    liveDot.Size = UDim2.new(0, 6, 0, 6)
    liveDot.Position = UDim2.new(1, -6, 1, -6)
    liveDot.BackgroundColor3 = Theme.Green
    liveDot.BorderSizePixel = 0
    liveDot.Parent = avatarImg

    local ldCorner = Instance.new("UICorner")
    ldCorner.CornerRadius = UDim.new(1, 0)
    ldCorner.Parent = liveDot

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -50, 0, 14)
    nameLabel.Position = UDim2.new(0, 46, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.TextColor3 = Theme.TextPrimary
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = profileCard

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -50, 0, 12)
    subLabel.Position = UDim2.new(0, 46, 0, 24)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "@" .. LocalPlayer.Name .. "  Â·  " .. tostring(LocalPlayer.AccountAge) .. "d"
    subLabel.TextColor3 = Theme.TextSecondary
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 9
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subLabel.Parent = profileCard
end

do
    local searchBar = Instance.new("Frame")
    searchBar.Name = "UniversalSearchBar"
    searchBar.Size = UDim2.new(1, 0, 0, 26)
    searchBar.BackgroundColor3 = Theme.ElementBg
    searchBar.BackgroundTransparency = 0.25
    searchBar.BorderSizePixel = 0
    searchBar.LayoutOrder = -1000
    searchBar.Parent = Sidebar

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = searchBar

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = Theme.Border
    sStroke.Thickness = 1
    sStroke.Parent = searchBar

    local sIcon = Instance.new("TextLabel")
    sIcon.Size = UDim2.new(0, 22, 1, 0)
    sIcon.Position = UDim2.new(0, 2, 0, 0)
    sIcon.BackgroundTransparency = 1
    sIcon.Text = "â"
    sIcon.TextColor3 = Theme.TextSecondary
    sIcon.Font = Enum.Font.Gotham
    sIcon.TextSize = 12
    sIcon.Parent = searchBar

    local sInput = Instance.new("TextBox")
    sInput.Size = UDim2.new(1, -38, 1, 0)
    sInput.Position = UDim2.new(0, 24, 0, 0)
    sInput.BackgroundTransparency = 1
    sInput.Text = ""
    sInput.PlaceholderText = "Search..."
    sInput.TextColor3 = Theme.TextPrimary
    sInput.PlaceholderColor3 = Theme.TextSecondary
    sInput.Font = Enum.Font.Gotham
    sInput.TextSize = 10
    sInput.TextXAlignment = Enum.TextXAlignment.Left
    sInput.ClearTextOnFocus = false
    sInput.Parent = searchBar

    local sClear = Instance.new("TextButton")
    sClear.Size = UDim2.new(0, 14, 0, 14)
    sClear.Position = UDim2.new(1, -18, 0.5, -7)
    sClear.BackgroundTransparency = 1
    sClear.Text = "x"
    sClear.TextColor3 = Theme.TextSecondary
    sClear.Font = Enum.Font.GothamBold
    sClear.TextSize = 9
    sClear.Visible = false
    sClear.Parent = searchBar

    sInput.Focused:Connect(function()
        tw(sStroke, {Color = Theme.Accent}, 0.15)
        tw(sIcon, {TextColor3 = Theme.Accent}, 0.15)
    end)
    sInput.FocusLost:Connect(function()
        tw(sStroke, {Color = Theme.Border}, 0.15)
        tw(sIcon, {TextColor3 = Theme.TextSecondary}, 0.15)
    end)

    sClear.MouseButton1Click:Connect(function()
        sInput.Text = ""
        sClear.Visible = false
    end)

    sInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(sInput.Text)
        sClear.Visible = query ~= ""
        for _, tabObj in ipairs(AllTabs) do
            if tabObj and tabObj.Page then
                for _, elem in ipairs(tabObj.Page:GetChildren()) do
                    if not elem:IsA("UIListLayout") and not elem:IsA("UIPadding") and elem.Name ~= "Page" then
                        if query == "" then
                            elem.Visible = true
                        else
                            local txt = ""
                            if elem:IsA("TextButton") then txt = elem.Text end
                            local lbl = elem:FindFirstChildOfClass("TextLabel")
                            if lbl then txt = txt .. " " .. lbl.Text end
                            for _, child in ipairs(elem:GetChildren()) do
                                if child:IsA("TextLabel") then
                                    txt = txt .. " " .. child.Text
                                end
                            end
                            if string.find(string.lower(txt), query, 1, true) then
                                elem.Visible = true
                            else
                                elem.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

do
    local favTab = createTab("Favorites")
    favTab:AddSection("Starred Features")

    local favEmptyNote = Instance.new("TextLabel")
    favEmptyNote.Size = UDim2.new(1, 0, 0, 40)
    favEmptyNote.BackgroundTransparency = 1
    favEmptyNote.Text = "Right-click any button or toggle to add to Favorites."
    favEmptyNote.TextColor3 = Theme.TextSecondary
    favEmptyNote.Font = Enum.Font.Gotham
    favEmptyNote.TextSize = 10
    favEmptyNote.TextWrapped = true
    favEmptyNote.Parent = favTab.Page

    local KModal = {}
    KModal.Overlay = Instance.new("Frame")
    KModal.Overlay.Size = UDim2.new(1, 0, 1, 0)
    KModal.Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    KModal.Overlay.BackgroundTransparency = 0.5
    KModal.Overlay.BorderSizePixel = 0
    KModal.Overlay.ZIndex = 700
    KModal.Overlay.Visible = false
    KModal.Overlay.Parent = ScreenGui

    do
        local kmCard = Instance.new("Frame")
        kmCard.Size = UDim2.new(0, 320, 0, 150)
        kmCard.AnchorPoint = Vector2.new(0.5, 0.5)
        kmCard.Position = UDim2.new(0.5, 0, 0.5, 0)
        kmCard.BackgroundColor3 = Theme.Header
        kmCard.BorderSizePixel = 0
        kmCard.ZIndex = 701
        kmCard.Parent = KModal.Overlay

        local kmCorner = Instance.new("UICorner")
        kmCorner.CornerRadius = UDim.new(0, 6)
        kmCorner.Parent = kmCard

        local kmStroke = Instance.new("UIStroke")
        kmStroke.Color = Theme.Border
        kmStroke.Thickness = 1
        kmStroke.Parent = kmCard

        local kmTitle = Instance.new("TextLabel")
        kmTitle.Size = UDim2.new(1, -20, 0, 24)
        kmTitle.Position = UDim2.new(0, 10, 0, 12)
        kmTitle.BackgroundTransparency = 1
        kmTitle.Text = "KEYBIND CONFIGURATION"
        kmTitle.TextColor3 = Theme.Accent
        kmTitle.Font = Enum.Font.GothamBold
        kmTitle.TextSize = 11
        kmTitle.TextXAlignment = Enum.TextXAlignment.Left
        kmTitle.ZIndex = 702
        kmTitle.Parent = kmCard

        local kmDesc = Instance.new("TextLabel")
        kmDesc.Size = UDim2.new(1, -20, 0, 40)
        kmDesc.Position = UDim2.new(0, 10, 0, 38)
        kmDesc.BackgroundTransparency = 1
        kmDesc.Text = "Press any key on your keyboard to bind\n[Backspace] to remove  Â·  [Escape] to cancel"
        kmDesc.TextColor3 = Theme.TextSecondary
        kmDesc.Font = Enum.Font.Gotham
        kmDesc.TextSize = 10
        kmDesc.TextXAlignment = Enum.TextXAlignment.Left
        kmDesc.ZIndex = 702
        kmDesc.Parent = kmCard

        KModal.TargetLbl = Instance.new("TextLabel")
        KModal.TargetLbl.Size = UDim2.new(1, -20, 0, 24)
        KModal.TargetLbl.Position = UDim2.new(0, 10, 0, 84)
        KModal.TargetLbl.BackgroundColor3 = Theme.ElementBg
        KModal.TargetLbl.TextColor3 = Theme.Green
        KModal.TargetLbl.Font = Enum.Font.Code
        KModal.TargetLbl.TextSize = 10
        KModal.TargetLbl.BorderSizePixel = 0
        KModal.TargetLbl.ZIndex = 702
        KModal.TargetLbl.Parent = kmCard

        local kmtCorner = Instance.new("UICorner")
        kmtCorner.CornerRadius = UDim.new(0, 4)
        kmtCorner.Parent = KModal.TargetLbl
    end

    local KeybindRegistry = {}
    local pendingKeybindTarget = nil
    local pendingKeybindName = ""

    local Ctx = {}
    Ctx.Menu = Instance.new("Frame")
    Ctx.Menu.Size = UDim2.new(0, 140, 0, 96)
    Ctx.Menu.BackgroundColor3 = Theme.Header
    Ctx.Menu.BorderSizePixel = 0
    Ctx.Menu.Visible = false
    Ctx.Menu.ZIndex = 650
    Ctx.Menu.Parent = ScreenGui

    do
        local cmCorner = Instance.new("UICorner")
        cmCorner.CornerRadius = UDim.new(0, 5)
        cmCorner.Parent = Ctx.Menu

        local cmStroke = Instance.new("UIStroke")
        cmStroke.Color = Theme.BorderBright
        cmStroke.Thickness = 1
        cmStroke.Parent = Ctx.Menu

        local cmLayout = Instance.new("UIListLayout")
        cmLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cmLayout.Padding = UDim.new(0, 2)
        cmLayout.Parent = Ctx.Menu

        local cmPad = Instance.new("UIPadding")
        cmPad.PaddingTop = UDim.new(0, 4)
        cmPad.PaddingBottom = UDim.new(0, 4)
        cmPad.PaddingLeft = UDim.new(0, 4)
        cmPad.PaddingRight = UDim.new(0, 4)
        cmPad.Parent = Ctx.Menu
    end

    local currentContextTarget = nil
    local currentContextName = ""

    local function makeContextBtn(text, order, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = Theme.ElementBg
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.LayoutOrder = order
        btn.ZIndex = 651
        btn.Parent = Ctx.Menu

        local bPad = Instance.new("UIPadding")
        bPad.PaddingLeft = UDim.new(0, 8)
        bPad.Parent = btn

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 3)
        bCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.ElementHover}, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundTransparency = 1}, 0.1)
        end)
        btn.MouseButton1Click:Connect(function()
            Ctx.Menu.Visible = false
            if onClick then onClick() end
        end)
        return btn
    end

    makeContextBtn("â Toggle Favorite", 1, function()
        if not currentContextTarget then return end
        favEmptyNote.Visible = false
        local target = currentContextTarget
        local name = currentContextName
        if target:IsA("TextButton") then
            local isToggle = target:FindFirstChild("Frame") and target:FindFirstChild("Frame"):FindFirstChild("Frame")
            if isToggle then
                favTab:AddToggle(name, false, function()
                    pcall(function()
                        local fires = getconnections and getconnections(target.MouseButton1Click)
                        if fires then
                            for _, c in ipairs(fires) do
                                if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                            end
                        elseif firesignal then
                            firesignal(target.MouseButton1Click)
                        end
                    end)
                end)
            else
                favTab:AddButton(name, function()
                    pcall(function()
                        local fires = getconnections and getconnections(target.MouseButton1Click)
                        if fires then
                            for _, c in ipairs(fires) do
                                if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                            end
                        elseif firesignal then
                            firesignal(target.MouseButton1Click)
                        end
                    end)
                end)
            end
        end
        Notify("Favorites", "Added '" .. name .. "' to Favorites", 2, Theme.Green)
    end)

    makeContextBtn("â¨ Bind Key", 2, function()
        if not currentContextTarget then return end
        pendingKeybindTarget = currentContextTarget
        pendingKeybindName = currentContextName
        KModal.TargetLbl.Text = "Target: " .. currentContextName
        KModal.Overlay.Visible = true
    end)

    makeContextBtn("â Copy Name", 3, function()
        if currentContextName ~= "" then
            if setclipboard then pcall(setclipboard, currentContextName)
            elseif toclipboard then pcall(toclipboard, currentContextName) end
            Notify("Copied", currentContextName, 2)
        end
    end)

    makeContextBtn("âº Reset Control", 4, function()
        if currentContextTarget and currentContextTarget:IsA("TextButton") then
            Notify("Reset", "Reset control state", 1.5)
        end
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if KModal.Overlay.Visible then
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local kc = inp.KeyCode
                if kc == Enum.KeyCode.Escape then
                    KModal.Overlay.Visible = false
                    pendingKeybindTarget = nil
                elseif kc == Enum.KeyCode.Backspace then
                    for k, v in pairs(KeybindRegistry) do
                        if v.target == pendingKeybindTarget then
                            KeybindRegistry[k] = nil
                        end
                    end
                    KModal.Overlay.Visible = false
                    Notify("Keybind", "Keybind cleared for " .. pendingKeybindName, 2)
                    pendingKeybindTarget = nil
                else
                    KeybindRegistry[kc] = {
                        target = pendingKeybindTarget,
                        name = pendingKeybindName
                    }
                    KModal.Overlay.Visible = false
                    Notify("Keybind", "Bound [" .. kc.Name .. "] to " .. pendingKeybindName, 2.5, Theme.Green)
                    pendingKeybindTarget = nil
                end
            end
            return
        end

        if not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
            local entry = KeybindRegistry[inp.KeyCode]
            if entry and entry.target and entry.target.Parent then
                pcall(function()
                    local fires = getconnections and getconnections(entry.target.MouseButton1Click)
                    if fires then
                        for _, c in ipairs(fires) do
                            if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                        end
                    elseif firesignal then
                        firesignal(entry.target.MouseButton1Click)
                    end
                end)
                Notify("Keybind", "Activated " .. entry.name .. " [" .. inp.KeyCode.Name .. "]", 1.2)
            end
        end

        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if Ctx.Menu.Visible then
                local mPos = UserInputService:GetMouseLocation()
                local cPos = Ctx.Menu.AbsolutePosition
                local cSize = Ctx.Menu.AbsoluteSize
                if mPos.X < cPos.X or mPos.X > cPos.X + cSize.X or mPos.Y < cPos.Y or mPos.Y > cPos.Y + cSize.Y then
                    Ctx.Menu.Visible = false
                end
            end
        end
    end)

    local function hookContext(elem)
        if elem:IsA("TextButton") or (elem:IsA("Frame") and elem.Name ~= "Page") then
            elem.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                    currentContextTarget = elem
                    local lbl = elem:FindFirstChildOfClass("TextLabel")
                    currentContextName = lbl and lbl.Text or (elem:IsA("TextButton") and elem.Text or "Feature")
                    local mPos = UserInputService:GetMouseLocation()
                    Ctx.Menu.Position = UDim2.new(0, mPos.X + 4, 0, mPos.Y - 20)
                    Ctx.Menu.Visible = true
                end
            end)
        end
    end

    for _, tabObj in ipairs(AllTabs) do
        if tabObj ~= favTab and tabObj.Page then
            for _, child in ipairs(tabObj.Page:GetChildren()) do
                hookContext(child)
            end
            tabObj.Page.ChildAdded:Connect(function(child)
                task.wait()
                hookContext(child)
            end)
        end
    end
end

do
    local chatFadeEnabled = true
    UserInputService.TextBoxFocused:Connect(function(textBox)
        if not chatFadeEnabled then return end
        local p = textBox.Parent
        local isChat = false
        while p and p ~= game do
            if string.find(string.lower(p.Name), "chat") or p.Name == "ChatBar" or p.Name == "ChatChannelParentFrame" then
                isChat = true
                break
            end
            p = p.Parent
        end
        if isChat or string.find(string.lower(textBox.Name), "chat") then
            tw(MainFrame, {BackgroundTransparency = 0.92}, 0.2)
            tw(MainShadow, {BackgroundTransparency = 1}, 0.2)
        end
    end)

    UserInputService.TextBoxFocusReleased:Connect(function(textBox)
        if isVisible then
            tw(MainFrame, {BackgroundTransparency = 0.12}, 0.2)
            tw(MainShadow, {BackgroundTransparency = 0.65}, 0.2)
        end
    end)
end

do
    for _, tabObj in ipairs(AllTabs) do
        if tabObj and tabObj.Page then
            for _, elem in ipairs(tabObj.Page:GetChildren()) do
                if elem:IsA("Frame") and elem.Size == UDim2.new(1, 0, 0, 28) and elem.BackgroundTransparency == 1 then
                    local lbl = elem:FindFirstChildOfClass("TextLabel")
                    if lbl and lbl.Font == Enum.Font.GothamBold and lbl.TextSize == 9 then
                        local masterBtn = Instance.new("TextButton")
                        masterBtn.Size = UDim2.new(0, 38, 0, 16)
                        masterBtn.Position = UDim2.new(1, -44, 0.5, -8)
                        masterBtn.BackgroundColor3 = Theme.ElementBg
                        masterBtn.Text = "ALL"
                        masterBtn.TextColor3 = Theme.TextSecondary
                        masterBtn.Font = Enum.Font.GothamBold
                        masterBtn.TextSize = 9
                        masterBtn.BorderSizePixel = 0
                        masterBtn.Parent = elem

                        local mbCorner = Instance.new("UICorner")
                        mbCorner.CornerRadius = UDim.new(0, 3)
                        mbCorner.Parent = masterBtn

                        local mbStroke = Instance.new("UIStroke")
                        mbStroke.Color = Theme.Border
                        mbStroke.Thickness = 1
                        mbStroke.Parent = masterBtn

                        local isMasterOn = false
                        masterBtn.MouseButton1Click:Connect(function()
                            isMasterOn = not isMasterOn
                            tw(masterBtn, {
                                BackgroundColor3 = isMasterOn and Theme.Accent or Theme.ElementBg,
                                TextColor3 = isMasterOn and Theme.Background or Theme.TextSecondary
                            }, 0.14)
                            local allElems = tabObj.Page:GetChildren()
                            local inSection = false
                            for _, sib in ipairs(allElems) do
                                if sib == elem then
                                    inSection = true
                                elseif inSection then
                                    if sib:IsA("Frame") and sib.Size == UDim2.new(1, 0, 0, 28) and sib.BackgroundTransparency == 1 then
                                        break
                                    end
                                    if sib:IsA("TextButton") and sib:FindFirstChild("Frame") then
                                        local fires = getconnections and getconnections(sib.MouseButton1Click)
                                        if fires then
                                            for _, c in ipairs(fires) do c:Fire() end
                                        else
                                            pcall(function() if firesignal then firesignal(sib.MouseButton1Click) end end)
                                        end
                                    end
                                end
                            end
                            Notify("Section Master", isMasterOn and "Batch toggled ON" or "Batch toggled OFF", 1.5)
                        end)

                        local accordBtn = Instance.new("TextButton")
                        accordBtn.Size = UDim2.new(0, 16, 0, 16)
                        accordBtn.Position = UDim2.new(1, -66, 0.5, -8)
                        accordBtn.BackgroundTransparency = 1
                        accordBtn.Text = "â¼"
                        accordBtn.TextColor3 = Theme.AccentDim
                        accordBtn.Font = Enum.Font.Gotham
                        accordBtn.TextSize = 9
                        accordBtn.Parent = elem

                        local isCollapsed = false
                        accordBtn.MouseButton1Click:Connect(function()
                            isCollapsed = not isCollapsed
                            tw(accordBtn, {Rotation = isCollapsed and -90 or 0}, 0.15)
                            local allElems = tabObj.Page:GetChildren()
                            local inSection = false
                            for _, sib in ipairs(allElems) do
                                if sib == elem then
                                    inSection = true
                                elseif inSection then
                                    if sib:IsA("Frame") and sib.Size == UDim2.new(1, 0, 0, 28) and sib.BackgroundTransparency == 1 then
                                        break
                                    end
                                    if not sib:IsA("UIListLayout") and not sib:IsA("UIPadding") then
                                        sib.Visible = not isCollapsed
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

do
    local activeStateSnapshot = {
        flight = false,
        infJump = false,
        highlights = false,
        nightVision = false,
        walkSpeed = 16,
        jumpPower = 50,
        lastTool = nil
    }

    local function updateSnapshot()
        activeStateSnapshot.flight = flightEnabled or false
        activeStateSnapshot.highlights = highlightsEnabled or false
        local c = LocalPlayer.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                activeStateSnapshot.walkSpeed = hum.WalkSpeed
                activeStateSnapshot.jumpPower = hum.JumpPower
            end
            local t = c:FindFirstChildOfClass("Tool")
            if t then activeStateSnapshot.lastTool = t.Name end
        end
    end

    LocalPlayer.CharacterRemoving:Connect(function()
        updateSnapshot()
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.8)
        local hum = newChar:WaitForChild("Humanoid", 5)
        local root = newChar:WaitForChild("HumanoidRootPart", 5)
        if not hum or not root then return end

        local restoredCount = 0
        if activeStateSnapshot.flight and setFlight then
            setFlight(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.infJump and setInfJump then
            setInfJump(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.highlights and setHighlights then
            setHighlights(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.nightVision and setNightVision then
            setNightVision(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.walkSpeed and activeStateSnapshot.walkSpeed > 16 then
            hum.WalkSpeed = activeStateSnapshot.walkSpeed
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.jumpPower and activeStateSnapshot.jumpPower > 50 then
            hum.JumpPower = activeStateSnapshot.jumpPower
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.lastTool then
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then
                local tool = bp:FindFirstChild(activeStateSnapshot.lastTool)
                if tool then
                    hum:EquipTool(tool)
                    restoredCount = restoredCount + 1
                end
            end
        end

        if restoredCount > 0 then
            Notify("Loadout Restore", "Restored " .. restoredCount .. " active features automatically.", 2.5, Theme.Green)
        end
    end)
end

do
    local function executeSilentCommand(msg)
        if string.sub(msg, 1, 1) ~= ";" and string.sub(msg, 1, 1) ~= "/" then return false end
        local args = string.split(string.sub(msg, 2), " ")
        local cmd = string.lower(args[1] or "")

        if cmd == "fly" then
            local spd = tonumber(args[2]) or 60
            if setFlight then setFlight(true) end
            Notify("Command", "Flight enabled (Speed " .. spd .. ")", 2)
            return true
        elseif cmd == "unfly" then
            if setFlight then setFlight(false) end
            Notify("Command", "Flight disabled", 2)
            return true
        elseif cmd == "speed" then
            local spd = tonumber(args[2]) or 32
            local hum = getHum and getHum()
            if hum then hum.WalkSpeed = spd end
            Notify("Command", "WalkSpeed set to " .. spd, 2)
            return true
        elseif cmd == "jump" then
            local pwr = tonumber(args[2]) or 80
            local hum = getHum and getHum()
            if hum then hum.JumpPower = pwr end
            Notify("Command", "JumpPower set to " .. pwr, 2)
            return true
        elseif cmd == "esp" then
            if setHighlights then setHighlights(not highlightsEnabled) end
            Notify("Command", "ESP toggled", 2)
            return true
        elseif cmd == "rejoin" then
            Notify("Command", "Rejoining server...", 2)
            task.wait(0.2)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            return true
        elseif cmd == "hub" then
            setVisible(not isVisible)
            return true
        elseif cmd == "tp" and args[2] then
            local targetName = string.lower(args[2])
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (string.find(string.lower(p.Name), targetName, 1, true) or string.find(string.lower(p.DisplayName), targetName, 1, true)) then
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local myRoot = getRoot and getRoot()
                        if myRoot then
                            myRoot.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            Notify("Command", "Teleported to " .. p.DisplayName, 2)
                            return true
                        end
                    end
                end
            end
            Notify("Command", "Player not found", 2, Theme.Red)
            return true
        elseif cmd == "nix" then
            Notify("NIXHub", "Running v2.0.0 (Elite Architecture)", 3, Theme.Accent)
            return true
        end
        return false
    end

    LocalPlayer.Chatted:Connect(function(msg)
        executeSilentCommand(msg)
    end)

    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.SendingMessage:Connect(function(message)
                if string.sub(message.Text, 1, 1) == ";" then
                    local ok = executeSilentCommand(message.Text)
                    if ok and message.Cancel then message:Cancel() end
                end
            end)
        end
    end)
end

do
    local profileTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Settings" then
            profileTab = t
            break
        end
    end

    if profileTab then
        profileTab:AddSection("Configuration Profiles")

        local activeProfileName = "Default"
        local Profiles = {
            Default = {},
            PvP = {},
            Stealth = {},
            Farming = {}
        }

        local function captureHubState()
            local state = {}
            for _, tabObj in ipairs(AllTabs) do
                if tabObj and tabObj.Page then
                    for _, child in ipairs(tabObj.Page:GetChildren()) do
                        if child:IsA("TextButton") and child:FindFirstChild("Frame") then
                            local lbl = child:FindFirstChildOfClass("TextLabel")
                            if lbl then
                                state[lbl.Text] = child.BackgroundColor3 == Theme.Accent
                            end
                        end
                    end
                end
            end
            return state
        end

        local function applyHubState(state)
            if not state then return end
            for _, tabObj in ipairs(AllTabs) do
                if tabObj and tabObj.Page then
                    for _, child in ipairs(tabObj.Page:GetChildren()) do
                        if child:IsA("TextButton") and child:FindFirstChild("Frame") then
                            local lbl = child:FindFirstChildOfClass("TextLabel")
                            if lbl and state[lbl.Text] ~= nil then
                                local targetVal = state[lbl.Text]
                                local currentVal = child.BackgroundColor3 == Theme.Accent
                                if targetVal ~= currentVal then
                                    local fires = getconnections and getconnections(child.MouseButton1Click)
                                    if fires then
                                        for _, c in ipairs(fires) do c:Fire() end
                                    else
                                        pcall(function() if firesignal then firesignal(child.MouseButton1Click) end end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        profileTab:AddButton("Save Profile [PvP]", function()
            Profiles.PvP = captureHubState()
            Notify("Profile", "Saved active configuration to 'PvP' profile", 2, Theme.Green)
        end)

        profileTab:AddButton("Load Profile [PvP]", function()
            if next(Profiles.PvP) then
                applyHubState(Profiles.PvP)
                Notify("Profile", "Loaded 'PvP' configuration profile", 2, Theme.Accent)
            else
                Notify("Profile", "'PvP' profile is empty. Save it first.", 2, Theme.Red)
            end
        end)

        profileTab:AddButton("Save Profile [Stealth]", function()
            Profiles.Stealth = captureHubState()
            Notify("Profile", "Saved active configuration to 'Stealth' profile", 2, Theme.Green)
        end)

        profileTab:AddButton("Load Profile [Stealth]", function()
            if next(Profiles.Stealth) then
                applyHubState(Profiles.Stealth)
                Notify("Profile", "Loaded 'Stealth' configuration profile", 2, Theme.Accent)
            else
                Notify("Profile", "'Stealth' profile is empty. Save it first.", 2, Theme.Red)
            end
        end)

        profileTab:AddButton("Export Config to Clipboard (JSON)", function()
            local payload = {
                version = "2.0.0",
                hub = "NIXHub",
                timestamp = os.time(),
                state = captureHubState()
            }
            local json = game:GetService("HttpService"):JSONEncode(payload)
            if setclipboard then pcall(setclipboard, json)
            elseif toclipboard then pcall(toclipboard, json) end
            Notify("Config Export", "Configuration copied to clipboard successfully!", 2.5, Theme.Green)
        end)

        profileTab:AddButton("Import Config from Clipboard", function()
            local clip = ""
            pcall(function()
                if getclipboard then clip = getclipboard()
                elseif toclipboard then clip = toclipboard() end
            end)
            if clip and clip ~= "" then
                local ok, parsed = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(clip)
                end)
                if ok and parsed and parsed.state then
                    applyHubState(parsed.state)
                    Notify("Config Import", "Configuration imported successfully!", 2.5, Theme.Green)
                else
                    Notify("Config Import", "Invalid configuration clipboard format.", 2.5, Theme.Red)
                end
            end
        end)
    end
end

do
    local desyncActive = false
    local desyncMode = "Burst"
    local desyncBurstTimer = 0

    local desyncHud = Instance.new("TextLabel")
    desyncHud.Name = "DesyncHudIndicator"
    desyncHud.Size = UDim2.new(0, 150, 0, 20)
    desyncHud.Position = UDim2.new(0, 10, 0, 52)
    desyncHud.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    desyncHud.BackgroundTransparency = 0.3
    desyncHud.TextColor3 = Theme.Green
    desyncHud.Font = Enum.Font.Code
    desyncHud.TextSize = 10
    desyncHud.Text = "DESYNC: INACTIVE"
    desyncHud.BorderSizePixel = 0
    desyncHud.Visible = false
    desyncHud.ZIndex = 80
    desyncHud.Parent = ScreenGui

    local dhCorner = Instance.new("UICorner")
    dhCorner.CornerRadius = UDim.new(0, 4)
    dhCorner.Parent = desyncHud

    local dhStroke = Instance.new("UIStroke")
    dhStroke.Color = Theme.Border
    dhStroke.Thickness = 1
    dhStroke.Parent = desyncHud

    local function toggleDesync(v)
        desyncActive = v
        desyncHud.Visible = v
        local root = getRoot and getRoot()
        if not desyncActive then
            if root then root.Anchored = false end
            Notify("Desync", "Network Desync DISABLED", 1.5)
        else
            Notify("Desync", "Network Desync ENABLED [F4]", 1.5, Theme.Green)
        end
    end

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == Enum.KeyCode.F4 then
            toggleDesync(not desyncActive)
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        if not desyncActive then return end
        local root = getRoot and getRoot()
        if not root then return end
        desyncBurstTimer = desyncBurstTimer + dt
        if desyncBurstTimer < 1.1 then
            root.Anchored = true
            desyncHud.Text = string.format("DESYNC: CHOKING (%.1fs)", 1.1 - desyncBurstTimer)
            desyncHud.TextColor3 = Theme.Red
        elseif desyncBurstTimer < 1.4 then
            root.Anchored = false
            desyncHud.Text = "DESYNC: RE-SYNCING"
            desyncHud.TextColor3 = Theme.Green
        else
            desyncBurstTimer = 0
        end
    end)

    local scriptsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Scripts" then
            scriptsTab = t
            break
        end
    end

    if scriptsTab then
        scriptsTab:AddSection("Exploit Network Modules")
        scriptsTab:AddToggle("Desync / Micro Lag Switch [F4]", false, function(v)
            toggleDesync(v)
        end)
    end
end

do
    local scriptsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Scripts" then
            scriptsTab = t
            break
        end
    end

    if scriptsTab then
        scriptsTab:AddSection("Remote Event Trigger Automator")

        local automatorActive = false
        local selectedTrigger = ""
        local selectedActionType = "Remote"
        local selectedActionRemote = ""
        local selectedActionKey = "E"
        local automatorLatency = 0.5
        local triggerConnections = {}
        local activeRules = {}

        local autoContainer = Instance.new("Frame")
        autoContainer.Size = UDim2.new(1, 0, 0, 320)
        autoContainer.BackgroundColor3 = Theme.ElementBg
        autoContainer.BackgroundTransparency = 0.15
        autoContainer.BorderSizePixel = 0
        autoContainer.Parent = scriptsTab.Page

        local acCorner = Instance.new("UICorner")
        acCorner.CornerRadius = UDim.new(0, 6)
        acCorner.Parent = autoContainer

        local acStroke = Instance.new("UIStroke")
        acStroke.Color = Theme.Border
        acStroke.Thickness = 1
        acStroke.Parent = autoContainer

        local acTitle = Instance.new("TextLabel")
        acTitle.Size = UDim2.new(1, -20, 0, 24)
        acTitle.Position = UDim2.new(0, 10, 0, 8)
        acTitle.BackgroundTransparency = 1
        acTitle.Text = "EVENT MACRO & REACTION BUILDER"
        acTitle.TextColor3 = Theme.Accent
        acTitle.Font = Enum.Font.GothamBold
        acTitle.TextSize = 10
        acTitle.TextXAlignment = Enum.TextXAlignment.Left
        acTitle.Parent = autoContainer

        local triggerInput = Instance.new("TextBox")
        triggerInput.Size = UDim2.new(1, -20, 0, 26)
        triggerInput.Position = UDim2.new(0, 10, 0, 36)
        triggerInput.BackgroundColor3 = Theme.Header
        triggerInput.Text = ""
        triggerInput.PlaceholderText = "Trigger Remote Name (e.g. DamageEvent, HitRemote)"
        triggerInput.TextColor3 = Theme.TextPrimary
        triggerInput.PlaceholderColor3 = Theme.TextSecondary
        triggerInput.Font = Enum.Font.Code
        triggerInput.TextSize = 10
        triggerInput.BorderSizePixel = 0
        triggerInput.TextXAlignment = Enum.TextXAlignment.Left
        triggerInput.Parent = autoContainer

        local tiCorner = Instance.new("UICorner")
        tiCorner.CornerRadius = UDim.new(0, 4)
        tiCorner.Parent = triggerInput

        local tiPad = Instance.new("UIPadding")
        tiPad.PaddingLeft = UDim.new(0, 8)
        tiPad.Parent = triggerInput

        local actionTypeBtn = Instance.new("TextButton")
        actionTypeBtn.Size = UDim2.new(0.48, 0, 0, 24)
        actionTypeBtn.Position = UDim2.new(0, 10, 0, 70)
        actionTypeBtn.BackgroundColor3 = Theme.Header
        actionTypeBtn.Text = "ACTION: REMOTE EVENT"
        actionTypeBtn.TextColor3 = Theme.Accent
        actionTypeBtn.Font = Enum.Font.GothamBold
        actionTypeBtn.TextSize = 9
        actionTypeBtn.BorderSizePixel = 0
        actionTypeBtn.Parent = autoContainer

        local atbCorner = Instance.new("UICorner")
        atbCorner.CornerRadius = UDim.new(0, 4)
        atbCorner.Parent = actionTypeBtn

        local keySelectBtn = Instance.new("TextButton")
        keySelectBtn.Size = UDim2.new(0.48, -10, 0, 24)
        keySelectBtn.Position = UDim2.new(0.52, 0, 0, 70)
        keySelectBtn.BackgroundColor3 = Theme.Header
        keySelectBtn.Text = "KEY: [ E ]"
        keySelectBtn.TextColor3 = Theme.TextSecondary
        keySelectBtn.Font = Enum.Font.Code
        keySelectBtn.TextSize = 10
        keySelectBtn.BorderSizePixel = 0
        keySelectBtn.Parent = autoContainer

        local ksbCorner = Instance.new("UICorner")
        ksbCorner.CornerRadius = UDim.new(0, 4)
        ksbCorner.Parent = keySelectBtn

        local actionRemoteInput = Instance.new("TextBox")
        actionRemoteInput.Size = UDim2.new(1, -20, 0, 26)
        actionRemoteInput.Position = UDim2.new(0, 10, 0, 102)
        actionRemoteInput.BackgroundColor3 = Theme.Header
        actionRemoteInput.Text = ""
        actionRemoteInput.PlaceholderText = "Action Remote Name to Fire (e.g. BlockRemote, Parry)"
        actionRemoteInput.TextColor3 = Theme.TextPrimary
        actionRemoteInput.PlaceholderColor3 = Theme.TextSecondary
        actionRemoteInput.Font = Enum.Font.Code
        actionRemoteInput.TextSize = 10
        actionRemoteInput.BorderSizePixel = 0
        actionRemoteInput.TextXAlignment = Enum.TextXAlignment.Left
        actionRemoteInput.Parent = autoContainer

        local ariCorner = Instance.new("UICorner")
        ariCorner.CornerRadius = UDim.new(0, 4)
        ariCorner.Parent = actionRemoteInput

        local ariPad = Instance.new("UIPadding")
        ariPad.PaddingLeft = UDim.new(0, 8)
        ariPad.Parent = actionRemoteInput

        local latencyLabel = Instance.new("TextLabel")
        latencyLabel.Size = UDim2.new(1, -20, 0, 16)
        latencyLabel.Position = UDim2.new(0, 10, 0, 136)
        latencyLabel.BackgroundTransparency = 1
        latencyLabel.Text = "Reaction Latency: 500ms"
        latencyLabel.TextColor3 = Theme.TextSecondary
        latencyLabel.Font = Enum.Font.Gotham
        latencyLabel.TextSize = 10
        latencyLabel.TextXAlignment = Enum.TextXAlignment.Left
        latencyLabel.Parent = autoContainer

        local latencyTrack = Instance.new("Frame")
        latencyTrack.Size = UDim2.new(1, -20, 0, 6)
        latencyTrack.Position = UDim2.new(0, 10, 0, 156)
        latencyTrack.BackgroundColor3 = Theme.Header
        latencyTrack.BorderSizePixel = 0
        latencyTrack.Parent = autoContainer

        local ltCorner = Instance.new("UICorner")
        ltCorner.CornerRadius = UDim.new(1, 0)
        ltCorner.Parent = latencyTrack

        local latencyFill = Instance.new("Frame")
        latencyFill.Size = UDim2.new(0.25, 0, 1, 0)
        latencyFill.BackgroundColor3 = Theme.Accent
        latencyFill.BorderSizePixel = 0
        latencyFill.Parent = latencyTrack

        local lfCorner = Instance.new("UICorner")
        lfCorner.CornerRadius = UDim.new(1, 0)
        lfCorner.Parent = latencyFill

        local latencySliderBtn = Instance.new("TextButton")
        latencySliderBtn.Size = UDim2.new(1, 0, 1, 0)
        latencySliderBtn.BackgroundTransparency = 1
        latencySliderBtn.Text = ""
        latencySliderBtn.Parent = latencyTrack

        latencySliderBtn.MouseButton1Down:Connect(function()
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = latencyTrack.AbsolutePosition.X
                    local w = latencyTrack.AbsoluteSize.X
                    local r = math.clamp((inp.Position.X - x) / w, 0, 1)
                    automatorLatency = math.round(r * 2000) / 1000
                    latencyFill.Size = UDim2.new(r, 0, 1, 0)
                    latencyLabel.Text = string.format("Reaction Latency: %dms", math.round(automatorLatency * 1000))
                end
            end)
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if conn then conn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end)

        actionTypeBtn.MouseButton1Click:Connect(function()
            if selectedActionType == "Remote" then
                selectedActionType = "Key"
                actionTypeBtn.Text = "ACTION: KEYBOARD KEY"
                actionRemoteInput.Visible = false
                keySelectBtn.TextColor3 = Theme.Accent
            else
                selectedActionType = "Remote"
                actionTypeBtn.Text = "ACTION: REMOTE EVENT"
                actionRemoteInput.Visible = true
                keySelectBtn.TextColor3 = Theme.TextSecondary
            end
        end)

        local availableKeys = {"E", "Q", "F", "R", "C", "V", "X", "Z", "Space", "One", "Two", "Three"}
        local keyIdx = 1
        keySelectBtn.MouseButton1Click:Connect(function()
            keyIdx = (keyIdx % #availableKeys) + 1
            selectedActionKey = availableKeys[keyIdx]
            keySelectBtn.Text = "KEY: [ " .. selectedActionKey .. " ]"
        end)

        local addRuleBtn = Instance.new("TextButton")
        addRuleBtn.Size = UDim2.new(1, -20, 0, 28)
        addRuleBtn.Position = UDim2.new(0, 10, 0, 172)
        addRuleBtn.BackgroundColor3 = Theme.ElementActive
        addRuleBtn.Text = "CREATE AUTOMATION RULE"
        addRuleBtn.TextColor3 = Theme.Accent
        addRuleBtn.Font = Enum.Font.GothamBold
        addRuleBtn.TextSize = 10
        addRuleBtn.BorderSizePixel = 0
        addRuleBtn.Parent = autoContainer

        local arbCorner = Instance.new("UICorner")
        arbCorner.CornerRadius = UDim.new(0, 4)
        arbCorner.Parent = addRuleBtn

        local rulesScroll = Instance.new("ScrollingFrame")
        rulesScroll.Size = UDim2.new(1, -20, 0, 100)
        rulesScroll.Position = UDim2.new(0, 10, 0, 208)
        rulesScroll.BackgroundColor3 = Theme.Header
        rulesScroll.BorderSizePixel = 0
        rulesScroll.ScrollBarThickness = 2
        rulesScroll.ScrollBarImageColor3 = Theme.BorderBright
        rulesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        rulesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        rulesScroll.Parent = autoContainer

        local rsCorner = Instance.new("UICorner")
        rsCorner.CornerRadius = UDim.new(0, 4)
        rsCorner.Parent = rulesScroll

        local rsLayout = Instance.new("UIListLayout")
        rsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rsLayout.Padding = UDim.new(0, 4)
        rsLayout.Parent = rulesScroll

        local rsPad = Instance.new("UIPadding")
        rsPad.PaddingTop = UDim.new(0, 4)
        rsPad.PaddingBottom = UDim.new(0, 4)
        rsPad.PaddingLeft = UDim.new(0, 4)
        rsPad.PaddingRight = UDim.new(0, 4)
        rsPad.Parent = rulesScroll

        local function registerRule(rule)
            table.insert(activeRules, rule)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 28)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = rulesScroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 4)
            cCorner.Parent = card

            local cardLbl = Instance.new("TextLabel")
            cardLbl.Size = UDim2.new(1, -54, 1, 0)
            cardLbl.Position = UDim2.new(0, 6, 0, 0)
            cardLbl.BackgroundTransparency = 1
            local actDesc = rule.actionType == "Remote" and rule.actionRemote or ("Key: " .. rule.actionKey)
            cardLbl.Text = rule.triggerRemote .. " â " .. actDesc .. " (" .. math.round(rule.latency * 1000) .. "ms)"
            cardLbl.TextColor3 = Theme.TextPrimary
            cardLbl.Font = Enum.Font.Code
            cardLbl.TextSize = 9
            cardLbl.TextXAlignment = Enum.TextXAlignment.Left
            cardLbl.Parent = card

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 20, 0, 20)
            delBtn.Position = UDim2.new(1, -24, 0.5, -10)
            delBtn.BackgroundColor3 = Theme.Red
            delBtn.Text = "x"
            delBtn.TextColor3 = Theme.Accent
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 10
            delBtn.BorderSizePixel = 0
            delBtn.Parent = card

            local dbCorner = Instance.new("UICorner")
            dbCorner.CornerRadius = UDim.new(0, 3)
            dbCorner.Parent = delBtn

            delBtn.MouseButton1Click:Connect(function()
                if rule.connection then rule.connection:Disconnect() end
                for i, r in ipairs(activeRules) do
                    if r == rule then
                        table.remove(activeRules, i)
                        break
                    end
                end
                card:Destroy()
                Notify("Automator", "Rule removed", 1.5)
            end)

            pcall(function()
                for _, inst in ipairs(game:GetDescendants()) do
                    if inst:IsA("RemoteEvent") and inst.Name == rule.triggerRemote then
                        rule.connection = inst.OnClientEvent:Connect(function(...)
                            if not automatorActive then return end
                            local args = {...}
                            task.delay(rule.latency, function()
                                if rule.actionType == "Remote" then
                                    local targetRem = nil
                                    for _, d in ipairs(game:GetDescendants()) do
                                        if d:IsA("RemoteEvent") and d.Name == rule.actionRemote then
                                            targetRem = d
                                            break
                                        end
                                    end
                                    if targetRem then targetRem:FireServer() end
                                else
                                    pcall(function()
                                        local vim = game:GetService("VirtualInputManager")
                                        local kc = Enum.KeyCode[rule.actionKey] or Enum.KeyCode.E
                                        vim:SendKeyEvent(true, kc, false, game)
                                        task.wait(0.05)
                                        vim:SendKeyEvent(false, kc, false, game)
                                    end)
                                end
                            end)
                        end)
                        break
                    end
                end
            end)
        end

        addRuleBtn.MouseButton1Click:Connect(function()
            local trig = triggerInput.Text
            if trig == "" then
                Notify("Automator", "Enter a trigger remote name first!", 2, Theme.Red)
                return
            end
            local rule = {
                triggerRemote = trig,
                actionType = selectedActionType,
                actionRemote = actionRemoteInput.Text,
                actionKey = selectedActionKey,
                latency = automatorLatency,
                connection = nil
            }
            registerRule(rule)
            triggerInput.Text = ""
            actionRemoteInput.Text = ""
            Notify("Automator", "Rule active! Listening for " .. trig, 2.5, Theme.Green)
        end)

        scriptsTab:AddToggle("Automator Master Switch", false, function(v)
            automatorActive = v
            Notify("Automator", v and "Automator rules ACTIVE" or "Automator rules PAUSED", 2, v and Theme.Green or Theme.Red)
        end)
    end
end

do
    pcall(function()
        for _, tabObj in ipairs(AllTabs) do
            if tabObj and tabObj.Page then
                local page = tabObj.Page
                local velY = 0
                UserInputService.PointerAction:Connect(function(w, pan, pinch, gpe)
                    if page.Visible and not gpe and typeof(w) == "number" then
                        velY = velY + (w * 18)
                    end
                end)
                RunService.RenderStepped:Connect(function(dt)
                    if math.abs(velY) > 0.5 then
                        page.CanvasPosition = Vector2.new(0, math.clamp(page.CanvasPosition.Y - velY, 0, math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y)))
                        velY = velY * 0.88
                    else
                        velY = 0
                    end
                end)
            end
        end
    end)
end

do
    local clogOverlay = Instance.new("Frame")
    clogOverlay.Name = "ChangelogOverlayModal"
    clogOverlay.Size = UDim2.new(1, 0, 1, 0)
    clogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    clogOverlay.BackgroundTransparency = 1
    clogOverlay.BorderSizePixel = 0
    clogOverlay.ZIndex = 300
    clogOverlay.Visible = false
    clogOverlay.Parent = ScreenGui

    local clogModal = Instance.new("Frame")
    clogModal.Size = UDim2.new(0, 460, 0, 310)
    clogModal.AnchorPoint = Vector2.new(0.5, 0.5)
    clogModal.Position = UDim2.new(0.5, 0, 0.5, 20)
    clogModal.BackgroundColor3 = Theme.Header
    clogModal.BackgroundTransparency = 1
    clogModal.BorderSizePixel = 0
    clogModal.ZIndex = 301
    clogModal.Parent = clogOverlay

    local cmCorner = Instance.new("UICorner")
    cmCorner.CornerRadius = UDim.new(0, 6)
    cmCorner.Parent = clogModal

    local cmStroke = Instance.new("UIStroke")
    cmStroke.Color = Theme.Border
    cmStroke.Thickness = 1
    cmStroke.Transparency = 1
    cmStroke.Parent = clogModal

    local cmTitle = Instance.new("TextLabel")
    cmTitle.Size = UDim2.new(1, -40, 0, 36)
    cmTitle.Position = UDim2.new(0, 14, 0, 0)
    cmTitle.BackgroundTransparency = 1
    cmTitle.Text = "NIXHUB v2.0.0 RELEASE NOTES"
    cmTitle.TextColor3 = Theme.Accent
    cmTitle.TextTransparency = 1
    cmTitle.Font = Enum.Font.GothamBold
    cmTitle.TextSize = 12
    cmTitle.TextXAlignment = Enum.TextXAlignment.Left
    cmTitle.ZIndex = 302
    cmTitle.Parent = clogModal

    local closeClog = Instance.new("TextButton")
    closeClog.Size = UDim2.new(0, 24, 0, 24)
    closeClog.Position = UDim2.new(1, -32, 0, 6)
    closeClog.BackgroundColor3 = Theme.ElementBg
    closeClog.BackgroundTransparency = 1
    closeClog.Text = "x"
    closeClog.TextColor3 = Theme.TextSecondary
    closeClog.TextTransparency = 1
    closeClog.Font = Enum.Font.GothamBold
    closeClog.TextSize = 11
    closeClog.BorderSizePixel = 0
    closeClog.ZIndex = 302
    closeClog.Parent = clogModal

    local ccCorner = Instance.new("UICorner")
    ccCorner.CornerRadius = UDim.new(0, 4)
    ccCorner.Parent = closeClog

    closeClog.MouseEnter:Connect(function()
        tw(closeClog, {BackgroundColor3 = Theme.Red, TextColor3 = Theme.Accent}, 0.12)
    end)
    closeClog.MouseLeave:Connect(function()
        tw(closeClog, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12)
    end)

    local clScroll = Instance.new("ScrollingFrame")
    clScroll.Size = UDim2.new(1, -24, 1, -50)
    clScroll.Position = UDim2.new(0, 12, 0, 40)
    clScroll.BackgroundTransparency = 1
    clScroll.BorderSizePixel = 0
    clScroll.ScrollBarThickness = 2
    clScroll.ScrollBarImageColor3 = Theme.BorderBright
    clScroll.ScrollBarImageTransparency = 1
    clScroll.CanvasSize = UDim2.new(0, 0, 0, 420)
    clScroll.ZIndex = 302
    clScroll.Parent = clogModal

    local clText = Instance.new("TextLabel")
    clText.Size = UDim2.new(1, -10, 1, 0)
    clText.BackgroundTransparency = 1
    clText.Text = "Welcome to NIXHub v2.0.0!\n\n[ UI & VISUAL ENGINE ]\nÂ· Glassmorphism & Frosted Glass Blocks with neon glow borders\nÂ· Mini-mode Collapsible Sidebar with smooth UTF-8 icon centering\nÂ· Tactile Window Resizer Grip with boundary clamping\nÂ· Player Profile Card (Avatar Headshot, Username, Live Account Age)\nÂ· Section Accordion Collapsers & Dynamic Hover Tooltips\nÂ· Animated Typewriter Boot Splash Screen & Clean Typography\n\n[ QUALITY OF LIFE SUITE ]\nÂ· Universal Real-Time Feature Search Bar with instant filtering\nÂ· Interactive Right-Click Context Menu on all hub controls\nÂ· Dedicated Favorites Tab with linked bidirectional control sync\nÂ· Custom Keybind Rebinding Engine with keyboard capture modal\nÂ· Auto-Fade on Roblox Chat Focus (smooth 90% opacity drop)\nÂ· Inertia Momentum Scrolling across all hub tabs\nÂ· Auto-Respawn Loadout Restore (Flight, Speed, ESP, Tools auto-applied)\nÂ· Silent Chat Interceptor (;fly, ;noclip, ;speed, ;esp, ;tp, ;rejoin)\nÂ· Section Master Switches ([ALL] batch toggles)\nÂ· Multi-Profile Config Engine & JSON Clipboard Exporter/Importer\n\n[ SCRIPT & EXPLOIT ENGINE ]\nÂ· Desync & Micro Lag Switch [F4] with HUD status monitor\nÂ· Custom Remote Event Trigger Automator & Macro Builder\nÂ· 0-Register Scope Isolation avoiding Luau 200 crash limit\nÂ· Client-Side Only Strict LocalScript Security"
    clText.TextColor3 = Theme.TextPrimary
    clText.TextTransparency = 1
    clText.Font = Enum.Font.Gotham
    clText.TextSize = 10
    clText.TextXAlignment = Enum.TextXAlignment.Left
    clText.TextYAlignment = Enum.TextYAlignment.Top
    clText.TextWrapped = true
    clText.ZIndex = 302
    clText.Parent = clScroll

    local function openChangelog()
        clogOverlay.Visible = true
        tw(clogOverlay, {BackgroundTransparency = 0.4}, 0.25)
        tw(clogModal, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(cmStroke, {Transparency = 0}, 0.25)
        tw(cmTitle, {TextTransparency = 0}, 0.25)
        tw(closeClog, {BackgroundTransparency = 0, TextTransparency = 0}, 0.25)
        tw(clText, {TextTransparency = 0}, 0.25)
        tw(clScroll, {ScrollBarImageTransparency = 0}, 0.25)
    end

    closeClog.MouseButton1Click:Connect(function()
        tw(clogOverlay, {BackgroundTransparency = 1}, 0.18)
        tw(clogModal, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -20)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(cmStroke, {Transparency = 1}, 0.18)
        tw(cmTitle, {TextTransparency = 1}, 0.18)
        tw(closeClog, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
        tw(clText, {TextTransparency = 1}, 0.18)
        tw(clScroll, {ScrollBarImageTransparency = 1}, 0.18).Completed:Connect(function()
            clogOverlay.Visible = false
        end)
    end)

    task.spawn(function()
        task.wait(3)
        openChangelog()
    end)

    local settingsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Settings" then
            settingsTab = t
            break
        end
    end
    if settingsTab then
        settingsTab:AddButton("View Patch Notes (Changelog)", function()
            openChangelog()
        end)
    end
end

do
    local ttFrame = Instance.new("Frame")
    ttFrame.Name = "GlobalTooltipHud"
    ttFrame.Size = UDim2.new(0, 160, 0, 24)
    ttFrame.BackgroundColor3 = Theme.Header
    ttFrame.BorderSizePixel = 0
    ttFrame.Visible = false
    ttFrame.ZIndex = 850
    ttFrame.Parent = ScreenGui

    local ttCorner = Instance.new("UICorner")
    ttCorner.CornerRadius = UDim.new(0, 4)
    ttCorner.Parent = ttFrame

    local ttStroke = Instance.new("UIStroke")
    ttStroke.Color = Theme.BorderBright
    ttStroke.Thickness = 1
    ttStroke.Parent = ttFrame

    local ttLbl = Instance.new("TextLabel")
    ttLbl.Size = UDim2.new(1, -12, 1, 0)
    ttLbl.Position = UDim2.new(0, 6, 0, 0)
    ttLbl.BackgroundTransparency = 1
    ttLbl.Text = ""
    ttLbl.TextColor3 = Theme.TextPrimary
    ttLbl.Font = Enum.Font.Gotham
    ttLbl.TextSize = 10
    ttLbl.TextXAlignment = Enum.TextXAlignment.Center
    ttLbl.Parent = ttFrame

    local activeHover = false
    for _, tabObj in ipairs(AllTabs) do
        if tabObj and tabObj.Page then
            for _, elem in ipairs(tabObj.Page:GetChildren()) do
                if not elem:IsA("UIListLayout") and not elem:IsA("UIPadding") and elem.Name ~= "Page" then
                    elem.MouseEnter:Connect(function()
                        activeHover = true
                        task.delay(0.6, function()
                            if activeHover then
                                local name = ""
                                local lbl = elem:FindFirstChildOfClass("TextLabel")
                                if lbl then name = lbl.Text
                                elseif elem:IsA("TextButton") then name = elem.Text end
                                if name and string.len(name) > 1 then
                                    ttLbl.Text = name
                                    local mPos = UserInputService:GetMouseLocation()
                                    ttFrame.Position = UDim2.new(0, mPos.X + 12, 0, mPos.Y + 12)
                                    ttFrame.Visible = true
                                end
                            end
                        end)
                    end)
                    elem.MouseLeave:Connect(function()
                        activeHover = false
                        ttFrame.Visible = false
                    end)
                end
            end
        end
    end
end
do
    MainFrame.Visible = false
    MainShadow.Visible = false
    FloatToggle.Visible = true

    task.delay(2.2, function()
        if not isVisible and not MainFrame.Visible then
            isVisible = true
            MainFrame.Visible = true
            MainShadow.Visible = true
            FloatToggle.Visible = true
            tw(MainFrame, {Size = UDim2.new(0, 630, 0, 470), BackgroundTransparency = 0.12}, 0.25)
            tw(MainShadow, {Size = UDim2.new(0, 646, 0, 486), BackgroundTransparency = 0.65}, 0.25)
        end
    end)

    local splash = Instance.new("Frame")
    splash.Name = "SplashScreen"
    splash.Size = UDim2.new(0, 280, 0, 160)
    splash.AnchorPoint = Vector2.new(0.5, 0.5)
    splash.Position = UDim2.new(0.5, 0, 0.5, 0)
    splash.BackgroundColor3 = Theme.Background
    splash.BackgroundTransparency = 0.05
    splash.BorderSizePixel = 0
    splash.ZIndex = 300
    splash.Parent = ScreenGui

    local splashCorner = Instance.new("UICorner")
    splashCorner.CornerRadius = UDim.new(0, 8)
    splashCorner.Parent = splash

    local splashStroke = Instance.new("UIStroke")
    splashStroke.Color = Theme.Border
    splashStroke.Thickness = 1
    splashStroke.Parent = splash

    local splashNeon = Instance.new("Frame")
    splashNeon.Size = UDim2.new(1, 0, 0, 2)
    splashNeon.BackgroundColor3 = Theme.Accent
    splashNeon.BorderSizePixel = 0
    splashNeon.ZIndex = 301
    splashNeon.Parent = splash

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(1, 0, 0, 40)
    logoLabel.Position = UDim2.new(0, 0, 0, 30)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = "N I X  H U B"
    logoLabel.TextColor3 = Theme.Accent
    logoLabel.TextTransparency = 1
    logoLabel.Font = Enum.Font.GothamBlack
    logoLabel.TextSize = 22
    logoLabel.ZIndex = 302
    logoLabel.Parent = splash

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 16)
    subLabel.Position = UDim2.new(0, 0, 0, 72)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = ""
    subLabel.TextColor3 = Theme.TextSecondary
    subLabel.TextTransparency = 0.3
    subLabel.Font = Enum.Font.GothamMedium
    subLabel.TextSize = 10
    subLabel.ZIndex = 302
    subLabel.Parent = splash

    local progBg = Instance.new("Frame")
    progBg.Size = UDim2.new(0.6, 0, 0, 3)
    progBg.AnchorPoint = Vector2.new(0.5, 0)
    progBg.Position = UDim2.new(0.5, 0, 0, 110)
    progBg.BackgroundColor3 = Theme.ElementBg
    progBg.BorderSizePixel = 0
    progBg.ZIndex = 302
    progBg.Parent = splash

    local progBgCorner = Instance.new("UICorner")
    progBgCorner.CornerRadius = UDim.new(0, 2)
    progBgCorner.Parent = progBg

    local progFill = Instance.new("Frame")
    progFill.Size = UDim2.new(0, 0, 1, 0)
    progFill.BackgroundColor3 = Theme.Accent
    progFill.BorderSizePixel = 0
    progFill.ZIndex = 303
    progFill.Parent = progBg

    local progFillCorner = Instance.new("UICorner")
    progFillCorner.CornerRadius = UDim.new(0, 2)
    progFillCorner.Parent = progFill

    task.spawn(function()
        tw(logoLabel, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quad)
        task.wait(0.2)

        local loadText = "L O A D I N G . . ."
        for i = 1, #loadText do
            subLabel.Text = string.sub(loadText, 1, i)
            task.wait(0.03)
        end

        tw(progFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        task.wait(0.7)

        tw(splash, {BackgroundTransparency = 1}, 0.25)
        tw(logoLabel, {TextTransparency = 1}, 0.2)
        tw(subLabel, {TextTransparency = 1}, 0.2)
        tw(progFill, {BackgroundTransparency = 1}, 0.2)
        tw(progBg, {BackgroundTransparency = 1}, 0.2)
        tw(splashStroke, {Transparency = 1}, 0.2)
        tw(splashNeon, {BackgroundTransparency = 1}, 0.2)
        task.wait(0.3)

        splash:Destroy()

        isVisible = true
        MainFrame.Visible = true
        MainShadow.Visible = true
        FloatToggle.Visible = true
        MainFrame.Size = UDim2.new(0, 590, 0, 440)
        MainFrame.BackgroundTransparency = 0.8
        MainShadow.BackgroundTransparency = 0.95
        tw(MainFrame, {Size = UDim2.new(0, 630, 0, 470), BackgroundTransparency = 0.12}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(MainShadow, {Size = UDim2.new(0, 646, 0, 486), BackgroundTransparency = 0.65}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end
