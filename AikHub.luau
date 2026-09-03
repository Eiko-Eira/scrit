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
        if ok and h then return h end
    end
    local coreGui = nil
    pcall(function()
        coreGui = game:GetService("CoreGui")
    end)
    if coreGui then
        local canUseCore = pcall(function()
            local test = Instance.new("Folder")
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
ScreenGui.Parent = guiParent

local NotifHolder = Instance.new("Frame")
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

local notifCount = 0

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

local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 12)
msCorner.Parent = MainShadow

local msStroke = Instance.new("UIStroke")
msStroke.Color = Color3.fromRGB(0, 0, 0)
msStroke.Thickness = 6
msStroke.Transparency = 0.8
msStroke.Parent = MainShadow

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 630, 0, 470)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

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

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "NIXFloatToggle"
FloatToggle.Size = UDim2.new(0, 44, 0, 44)
FloatToggle.Position = UDim2.new(0, 16, 0.5, -22)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "NIX"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.GothamBlack
FloatToggle.TextSize = 12
FloatToggle.BorderSizePixel = 0
FloatToggle.AutoButtonColor = false
FloatToggle.ZIndex = 150
FloatToggle.Parent = ScreenGui

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

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

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
        tw(MainFrame, {Size = UDim2.new(0, 630, 0, 470), BackgroundTransparency = 0}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

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

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -136, 1, -42)
ContentArea.Position = UDim2.new(0, 136, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

local AllTabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.Text = string.upper(name)
    tabBtn.TextColor3 = Theme.TabInactiveText
    tabBtn.Font = Enum.Font.GothamMedium
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
            activeTab.Page.Visible = false
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.15)
            tw(activeTab.ActiveLine, {Size = UDim2.new(0, 2, 0, 4), BackgroundTransparency = 1}, 0.15)
        end
        activeTab = tabObj
        page.Position = UDim2.new(0, 7, 0, 15)
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
            tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.14)
            tw(bStroke, {Color = Theme.BorderBright}, 0.14)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementBg}, 0.14)
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
        row.Text = ""
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 5)
        rCorner.Parent = row

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
            tw(row, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            tw(rStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        row.MouseLeave:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementBg}, 0.12)
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


do
    local discoveredScripts = {}
    local selectedIndex = 1
    local codeTextBox = nil
    local statusInfoLabel = nil

    local function scanAccessibleScripts()
        discoveredScripts = {}
        local roots = {
            LocalPlayer:FindFirstChild("PlayerScripts"),
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("Backpack"),
            getChar(),
            game:GetService("ReplicatedFirst"),
            game:GetService("ReplicatedStorage"),
            workspace
        }

        for _, root in ipairs(roots) do
            if root then
                if (root:IsA("LocalScript") or root:IsA("ModuleScript")) and not root.Name:find("NIX") then
                    table.insert(discoveredScripts, root)
                end
                for _, d in ipairs(root:GetDescendants()) do
                    if (d:IsA("LocalScript") or d:IsA("ModuleScript")) and not d.Name:find("NIX") then
                        table.insert(discoveredScripts, d)
                    end
                end
            end
        end
        return #discoveredScripts
    end

    local function getScriptPath(scr)
        if not scr then return "None" end
        local parts = {}
        local cur = scr
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

    local function inspectScript(scr)
        if not scr then return "No script selected.\n\nClick 'Scan All Accessible Scripts' above." end
        local out = {}
        table.insert(out, "=== SCRIPT METADATA ===")
        table.insert(out, "Name: " .. scr.Name)
        table.insert(out, "Class: " .. scr.ClassName)
        table.insert(out, "Path: " .. getScriptPath(scr))
        if scr:IsA("LocalScript") then
            table.insert(out, "Disabled: " .. tostring(scr.Disabled))
        end

        local attrs = scr:GetAttributes()
        local attrList = {}
        for k, v in pairs(attrs) do
            table.insert(attrList, string.format("  [%s] = %s (%s)", tostring(k), tostring(v), typeof(v)))
        end
        table.insert(out, "Attributes (" .. #attrList .. "):")
        for _, l in ipairs(attrList) do table.insert(out, l) end

        table.insert(out, "\n=== SOURCE / EXPORTS ===")
        local hasSource, src = pcall(function() return scr.Source end)
        if hasSource and type(src) == "string" and #src > 0 then
            table.insert(out, src)
        elseif decompile then
            local okD, dRes = pcall(decompile, scr)
            if okD and type(dRes) == "string" and #dRes > 0 then
                table.insert(out, dRes)
            else
                table.insert(out, "[Source protected by Roblox engine. View in Studio or use decompiler]")
            end
        else
            if scr:IsA("ModuleScript") then
                local okReq, res = pcall(require, scr)
                if okReq then
                    table.insert(out, "[ModuleScript Return Value]: " .. typeof(res))
                    if type(res) == "table" then
                        for k, v in pairs(res) do
                            table.insert(out, string.format("  .%s = %s (%s)", tostring(k), tostring(v), typeof(v)))
                        end
                    else
                        table.insert(out, "  Value = " .. tostring(res))
                    end
                else
                    table.insert(out, "[Module require error: " .. tostring(res) .. "]")
                end
            else
                table.insert(out, "[LocalScript bytecode protected by engine sandbox]")
            end
        end

        return table.concat(out, "\n")
    end

    function updateScriptViewerUI()
        if not codeTextBox or not statusInfoLabel then return end
        if #discoveredScripts == 0 then
            statusInfoLabel.Text = "No scripts loaded. Click Scan."
            codeTextBox.Text = "Click 'Scan All Accessible Scripts' above to discover all scripts."
            return
        end
        if selectedIndex > #discoveredScripts then selectedIndex = 1 end
        if selectedIndex < 1 then selectedIndex = #discoveredScripts end

        local target = discoveredScripts[selectedIndex]
        if target then
            local disText = target:IsA("LocalScript") and (target.Disabled and " [DISABLED]" or " [ACTIVE]") or ""
            statusInfoLabel.Text = string.format("(%d/%d) %s [%s]%s", selectedIndex, #discoveredScripts, target.Name, target.ClassName, disText)
            codeTextBox.Text = inspectScript(target)
        end
    end

    function scanAndRefreshScripts()
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
    local discoveredRemotes = {}
    local selectedRemoteIndex = 1
    local remoteStatusLabel = nil
    local remoteSpamEnabled = false
    local remoteSpamConn = nil

    local function scanRemotes()
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
            remoteStatusLabel.Text = string.format("(%d/%d) %s [%s]\nPath: %s", selectedRemoteIndex, #discoveredRemotes, rem.Name, rem.ClassName, getRemotePath(rem))
        end
    end

    function scanAndRefreshRemotes()
        local cnt = scanRemotes()
        selectedRemoteIndex = 1
        updateRemoteUI()
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
    local airStrafeEnabled = false
    local airStrafeConn = nil
    local airStrafeInputConn = nil
    local strafeBoost = 0
    local maxStrafeBoost = 35
    local lastStrafeKey = nil
    local lastStrafeTime = 0
    local strafeChain = 0

    local function updateStrafeInput(key)
        if key == Enum.KeyCode.A or key == Enum.KeyCode.D then
            local now = os.clock()
            if lastStrafeKey and lastStrafeKey ~= key and (now - lastStrafeTime) < 0.65 then
                strafeChain = math.clamp(strafeChain + 1, 0, 10)
            elseif (now - lastStrafeTime) > 0.85 then
                strafeChain = 1
            end
            lastStrafeKey = key
            lastStrafeTime = now
        end
    end

    function setAirStrafe(enabled)
        airStrafeEnabled = enabled
        airStrafeConn = safeDisc(airStrafeConn)
        airStrafeInputConn = safeDisc(airStrafeInputConn)
        strafeBoost = 0
        strafeChain = 0
        lastStrafeKey = nil
        if enabled then
            airStrafeInputConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and (inp.KeyCode == Enum.KeyCode.A or inp.KeyCode == Enum.KeyCode.D) then
                    updateStrafeInput(inp.KeyCode)
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
                local isStrafing = (os.clock() - lastStrafeTime < 0.5) and (keysDown.A or keysDown.D) and strafeChain >= 2

                if inAir and isStrafing then
                    strafeBoost = math.clamp(strafeBoost + dt * (18 + strafeChain * 4), 0, maxStrafeBoost)
                    local vel = root.AssemblyLinearVelocity
                    local camCF = Camera.CFrame
                    local moveDir = Vector3.zero
                    if keysDown.A then moveDir = moveDir - camCF.RightVector end
                    if keysDown.D then moveDir = moveDir + camCF.RightVector end
                    if keysDown.W then moveDir = moveDir + camCF.LookVector end
                    if keysDown.S then moveDir = moveDir - camCF.LookVector end
                    moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

                    if moveDir.Magnitude > 0.05 then
                        moveDir = moveDir.Unit
                        local targetHVel = moveDir * (hum.WalkSpeed + strafeBoost)
                        local curHVel = Vector3.new(vel.X, 0, vel.Z)
                        local newHVel = curHVel:Lerp(targetHVel, math.clamp(dt * 7, 0.05, 0.45))

                        local newY = vel.Y
                        if newY < 0 then
                            newY = newY + math.abs(newY) * math.clamp(dt * 3.2, 0.02, 0.25) + dt * 14
                        else
                            newY = newY + dt * 6
                        end
                        root.AssemblyLinearVelocity = Vector3.new(newHVel.X, newY, newHVel.Z)
                    end
                else
                    if strafeBoost > 0 then
                        strafeBoost = math.max(0, strafeBoost - dt * 24)
                    end
                    if not inAir then
                        strafeChain = 0
                    end
                end
            end)
            Notify("Physics", "Air-Strafing ON  *  A/D Glide", 1.8, Theme.Green)
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
PhysicsTab:AddToggle("Air-Strafing (A/D Momentum & Glide)", false, function(v) setAirStrafe(v) end)
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

local SystemTab = createTab("System")
SystemTab:AddSection("Diagnostics")
SystemTab:AddToggle("FPS + Speed HUD", false, function(v) setFPSHud(v) end)
SystemTab:AddSection("Controls")
SystemTab:AddButton("Hide Menu  [ RShift ]", function() setVisible(false) end)
SystemTab:AddButton("Reset All Features", function() resetAll() end)

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
