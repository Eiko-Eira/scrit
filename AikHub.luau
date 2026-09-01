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
    Background    = Color3.fromRGB(8, 8, 10),
    Header        = Color3.fromRGB(14, 14, 16),
    Sidebar       = Color3.fromRGB(10, 10, 12),
    TabActive     = Color3.fromRGB(235, 235, 235),
    TabActiveText = Color3.fromRGB(8, 8, 10),
    TabInactive   = Color3.fromRGB(16, 16, 18),
    TabInactiveText = Color3.fromRGB(130, 130, 140),
    Accent        = Color3.fromRGB(255, 255, 255),
    AccentDim     = Color3.fromRGB(180, 180, 180),
    ElementBg     = Color3.fromRGB(18, 18, 22),
    ElementHover  = Color3.fromRGB(28, 28, 34),
    ElementActive = Color3.fromRGB(38, 38, 46),
    TextPrimary   = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(120, 120, 130),
    Border        = Color3.fromRGB(36, 36, 44),
    BorderBright  = Color3.fromRGB(70, 70, 85),
    Green         = Color3.fromRGB(80, 220, 120),
    Red           = Color3.fromRGB(220, 80, 80),
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
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
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = notifCount
    card.Parent = NotifHolder

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 5)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Theme.Border
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 2, 1, 0)
    accentBar.BackgroundColor3 = color
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card

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
    prog.BackgroundTransparency = 0.5
    prog.BorderSizePixel = 0
    prog.Parent = card

    card.Position = UDim2.new(1, 10, 0, 0)
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(prog, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 10, 0, 0)}, 0.2).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 630, 0, 470)
MainFrame.Position = UDim2.new(0.5, -315, 0.5, -235)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 7)
mfCorner.Parent = MainFrame

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Parent = MainFrame

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "NIXFloatToggle"
FloatToggle.Size = UDim2.new(0, 42, 0, 42)
FloatToggle.Position = UDim2.new(0, 16, 0.5, -21)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "NIX"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.GothamBold
FloatToggle.TextSize = 11
FloatToggle.BorderSizePixel = 0
FloatToggle.ZIndex = 150
FloatToggle.Parent = ScreenGui

local ftCorner = Instance.new("UICorner")
ftCorner.CornerRadius = UDim.new(1, 0)
ftCorner.Parent = FloatToggle

local ftStroke = Instance.new("UIStroke")
ftStroke.Color = Theme.Border
ftStroke.Thickness = 1.5
ftStroke.Parent = FloatToggle

local ftDragging, ftDragInput, ftMousePos, ftFramePos = false, nil, nil, nil
FloatToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        ftDragging = true
        ftMousePos = inp.Position
        ftFramePos = FloatToggle.Position
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then ftDragging = false end
end)
FloatToggle.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement then ftDragInput = inp end
end)
UserInputService.InputChanged:Connect(function(inp)
    if inp == ftDragInput and ftDragging then
        local d = inp.Position - ftMousePos
        FloatToggle.Position = UDim2.new(ftFramePos.X.Scale, ftFramePos.X.Offset + d.X, ftFramePos.Y.Scale, ftFramePos.Y.Offset + d.Y)
    end
end)

FloatToggle.MouseEnter:Connect(function()
    tw(FloatToggle, {BackgroundColor3 = Theme.ElementActive}, 0.12)
    tw(ftStroke, {Color = Theme.Accent}, 0.12)
end)
FloatToggle.MouseLeave:Connect(function()
    tw(FloatToggle, {BackgroundColor3 = Theme.Header}, 0.12)
    tw(ftStroke, {Color = Theme.Border}, 0.12)
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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 160, 1, 0)
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
subtitleLabel.Position = UDim2.new(0, 114, 0, 0)
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
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 4)
cbCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Red, TextColor3 = Theme.Accent}, 0.12) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12) end)

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
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + d.X, framePos.Y.Scale, framePos.Y.Offset + d.Y)
    end
end)

local isVisible = true
local function setVisible(v)
    isVisible = v
    if v then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 630, 0, 0)
        MainFrame.BackgroundTransparency = 1
        tw(MainFrame, {Size = UDim2.new(0, 630, 0, 470), BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Back)
    else
        tw(MainFrame, {Size = UDim2.new(0, 630, 0, 0), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
            MainFrame.Visible = false
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
tabLayout.Padding = UDim.new(0, 2)
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
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local tPad = Instance.new("UIPadding")
    tPad.PaddingLeft = UDim.new(0, 10)
    tPad.Parent = tabBtn

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 4)
    tbCorner.Parent = tabBtn

    local activeLine = Instance.new("Frame")
    activeLine.Size = UDim2.new(0, 2, 0, 14)
    activeLine.Position = UDim2.new(0, -2, 0.5, -7)
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
        if activeTab and activeTab ~= tabObj then
            activeTab.Page.Visible = false
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.14)
            tw(activeTab.ActiveLine, {BackgroundTransparency = 1}, 0.14)
        end
        activeTab = tabObj
        page.Visible = true
        tw(tabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabActiveText}, 0.14)
        tw(activeLine, {BackgroundTransparency = 0}, 0.14)
    end

    tabBtn.MouseButton1Click:Connect(select)
    table.insert(AllTabs, tabObj)
    if #AllTabs == 1 then select() end

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
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Theme.Border
        bStroke.Thickness = 1
        bStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            tw(bStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementBg}, 0.12)
            tw(bStroke, {Color = Theme.Border}, 0.12)
        end)
        btn.MouseButton1Down:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementActive}, 0.06)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.06)
        end)
        btn.MouseButton1Click:Connect(function()
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
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 4)
        rCorner.Parent = row

        local rStroke = Instance.new("UIStroke")
        rStroke.Color = Theme.Border
        rStroke.Thickness = 1
        rStroke.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -54, 1, 0)
        lbl.Position = UDim2.new(0, 11, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local swTrack = Instance.new("Frame")
        swTrack.Size = UDim2.new(0, 32, 0, 16)
        swTrack.Position = UDim2.new(1, -42, 0.5, -8)
        swTrack.BackgroundColor3 = state and Theme.Accent or Theme.Header
        swTrack.BorderSizePixel = 0
        swTrack.Parent = row

        local swCorner = Instance.new("UICorner")
        swCorner.CornerRadius = UDim.new(1, 0)
        swCorner.Parent = swTrack

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
        knob.BorderSizePixel = 0
        knob.Parent = swTrack

        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob

        local function setToggle(v)
            state = v
            tw(swTrack, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.14)
            tw(knob, {
                Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
            }, 0.14)
            if cb then task.spawn(cb, state) end
        end

        row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = Theme.ElementHover}, 0.12) end)
        row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = Theme.ElementBg}, 0.12) end)
        row.MouseButton1Click:Connect(function() setToggle(not state) end)

        return setToggle
    end

    function tabObj:AddSlider(label, minV, maxV, defaultV, cb)
        local val = defaultV or minV
        minV = minV or 0
        maxV = maxV or 100

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 48)
        container.BackgroundColor3 = Theme.ElementBg
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = container

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Theme.Border
        cStroke.Thickness = 1
        cStroke.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 0, 18)
        lbl.Position = UDim2.new(0, 11, 0, 5)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 60, 0, 18)
        valLbl.Position = UDim2.new(1, -68, 0, 5)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val)
        valLbl.TextColor3 = Theme.AccentDim
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local trackBg = Instance.new("Frame")
        trackBg.Size = UDim2.new(1, -22, 0, 5)
        trackBg.Position = UDim2.new(0, 11, 0, 30)
        trackBg.BackgroundColor3 = Theme.Header
        trackBg.BorderSizePixel = 0
        trackBg.Parent = container

        local trCorner = Instance.new("UICorner")
        trCorner.CornerRadius = UDim.new(1, 0)
        trCorner.Parent = trackBg

        local fillBar = Instance.new("Frame")
        local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
        fillBar.Size = UDim2.new(initRatio, 0, 1, 0)
        fillBar.BackgroundColor3 = Theme.Accent
        fillBar.BorderSizePixel = 0
        fillBar.Parent = trackBg

        local fbCorner = Instance.new("UICorner")
        fbCorner.CornerRadius = UDim.new(1, 0)
        fbCorner.Parent = fillBar

        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 14, 0, 14)
        handle.AnchorPoint = Vector2.new(0.5, 0.5)
        handle.Position = UDim2.new(initRatio, 0, 0.5, 0)
        handle.BackgroundColor3 = Theme.Accent
        handle.Text = ""
        handle.BorderSizePixel = 0
        handle.ZIndex = 5
        handle.Parent = trackBg

        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(1, 0)
        hCorner.Parent = handle

        local hStroke = Instance.new("UIStroke")
        hStroke.Color = Theme.Background
        hStroke.Thickness = 2
        hStroke.Parent = handle

        local sliding = false

        local function applySlide(inputPos)
            local x = trackBg.AbsolutePosition.X
            local w = trackBg.AbsoluteSize.X
            local r = math.clamp((inputPos.X - x) / w, 0, 1)
            val = math.round(minV + (maxV - minV) * r)
            valLbl.Text = tostring(val)
            fillBar.Size = UDim2.new(r, 0, 1, 0)
            handle.Position = UDim2.new(r, 0, 0.5, 0)
            if cb then task.spawn(cb, val) end
        end

        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                tw(handle, {Size = UDim2.new(0, 17, 0, 17)}, 0.1)
            end
        end)
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                applySlide(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
                sliding = false
                tw(handle, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
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
FpsLabel.Size = UDim2.new(0, 130, 0, 38)
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
local aimSnap, wallCheck, teamCheck, aimRange, glideSpeed, autoShotDelay, recoilIntensity
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

local function getNearestEnemy()
    local nearest = nil
    local shortest = aimRange
    local camPos = Camera.CFrame.Position
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = getTargetPart(p.Character)
        if not part then continue end
        if wallCheck and not hasLOS(camPos, part) then continue end
        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < shortest then
            shortest = d
            nearest = part
        end
    end
    return nearest
end

local function isTargetValid(part)
    if not part or not part.Parent then return false end
    local hum = part.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if wallCheck and not hasLOS(Camera.CFrame.Position, part) then return false end
    local sp, vis = Camera:WorldToViewportPoint(part.Position)
    if not vis then return false end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
    if d > aimRange then return false end
    return true
end

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
            if (tp - camPos).Magnitude < 0.1 then return end
            local targetRot = CFrame.lookAt(camPos, tp)

            local speed = aimSnap and glideSpeed or (glideSpeed * 0.55)
            Camera.CFrame = Camera.CFrame:Lerp(targetRot, math.clamp(speed, 0.01, 1))
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
        task.delay(0.015, function()
            vim:SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 0)
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
                if not wasOnTarget or (now - lastAutoShot >= autoShotDelay) then
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
local flashlightEnabled = false
local flashlightPart = nil
local flashlightLight = nil
flashlightBrightness = 3
flashlightRange = 70
local flashlightConn = nil

function setFlashlight(enabled)
    flashlightEnabled = enabled
    flashlightConn = safeDisc(flashlightConn)
    if flashlightPart then flashlightPart:Destroy() flashlightPart = nil end

    if enabled then
        flashlightPart = Instance.new("Part")
        flashlightPart.Name = "NIXFlashlightAnchor"
        flashlightPart.Size = Vector3.one * 0.1
        flashlightPart.Transparency = 1
        flashlightPart.CanCollide = false
        flashlightPart.Anchored = true
        flashlightPart.Parent = workspace

        flashlightLight = Instance.new("SpotLight")
        flashlightLight.Brightness = flashlightBrightness
        flashlightLight.Range = flashlightRange
        flashlightLight.Angle = 75
        flashlightLight.Shadows = true
        flashlightLight.Color = Color3.fromRGB(255, 250, 240)
        flashlightLight.Parent = flashlightPart

        flashlightConn = RunService.RenderStepped:Connect(function()
            if not flashlightPart or not flashlightPart.Parent then return end
            flashlightPart.CFrame = Camera.CFrame
        end)
    end
end

function updateFlashlight()
    if flashlightLight then
        flashlightLight.Brightness = flashlightBrightness
        flashlightLight.Range = flashlightRange
    end
end

local entityRadarEnabled = false
local entityRadarConn = nil
local entityBills = {}

local function clearEntityRadar()
    for _, b in pairs(entityBills) do
        if b and b.Parent then b:Destroy() end
    end
    entityBills = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d.Name == "NIXEntityHL" then d:Destroy() end
    end
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
                if d:IsA("Model") and not playerChars[d] then
                    local hum = d:FindFirstChildOfClass("Humanoid")
                    local root = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head") or d.PrimaryPart
                    if hum and root and hum.Health > 0 then
                        local dist = math.round((myRoot.Position - root.Position).Magnitude)
                        local bill = entityBills[d]
                        if not bill or not bill.Parent then
                            bill = Instance.new("BillboardGui")
                            bill.Name = "NIXEntityBill"
                            bill.Size = UDim2.new(0, 130, 0, 26)
                            bill.StudsOffset = Vector3.new(0, 3, 0)
                            bill.AlwaysOnTop = true
                            bill.Adornee = root
                            bill.Parent = root

                            local lbl = Instance.new("TextLabel")
                            lbl.Name = "ELbl"
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 0.4
                            lbl.BackgroundColor3 = Color3.fromRGB(16, 8, 8)
                            lbl.TextColor3 = Theme.Red
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 10
                            lbl.Parent = bill

                            local elc = Instance.new("UICorner")
                            elc.CornerRadius = UDim.new(0, 4)
                            elc.Parent = lbl

                            local hl = Instance.new("Highlight")
                            hl.Name = "NIXEntityHL"
                            hl.FillTransparency = 0.7
                            hl.OutlineTransparency = 0.2
                            hl.FillColor = Theme.Red
                            hl.OutlineColor = Theme.Red
                            hl.Adornee = d
                            hl.Parent = d

                            entityBills[d] = bill
                        end
                        local lbl = bill:FindFirstChild("ELbl")
                        if lbl then
                            lbl.Text = string.format("[!] %s (%dm)", d.Name, dist)
                        end
                    end
                end
            end
        end)
    end
end

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
local flightEnabled = false
flightSpeed = 60
local flightVel = nil
local flightAtt = nil
local flightConn = nil

function setFlight(enabled)
    flightEnabled = enabled
    local root = getRoot()
    local hum = getHum()

    if flightVel then flightVel:Destroy() flightVel = nil end
    if flightAtt then flightAtt:Destroy() flightAtt = nil end
    flightConn = safeDisc(flightConn)
    if hum and not enabled then hum.PlatformStand = false end
    if not enabled or not root or not hum then return end

    hum.PlatformStand = true

    flightAtt = Instance.new("Attachment")
    flightAtt.Parent = root

    flightVel = Instance.new("LinearVelocity")
    flightVel.Attachment0 = flightAtt
    flightVel.MaxForce = math.huge
    flightVel.VectorVelocity = Vector3.zero
    flightVel.RelativeTo = Enum.ActuatorRelativeTo.World
    flightVel.Parent = root

    flightConn = RunService.RenderStepped:Connect(function()
        if not flightEnabled or not flightVel then return end
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        local dir = Vector3.zero
        if keysDown.W then dir = dir + look end
        if keysDown.S then dir = dir - look end
        if keysDown.D then dir = dir + right end
        if keysDown.A then dir = dir - right end
        if keysDown.Space then dir = dir + Vector3.new(0, 1, 0) end
        if keysDown.LeftShift then dir = dir - Vector3.new(0, 1, 0) end
        flightVel.VectorVelocity = dir.Magnitude > 0 and dir.Unit * flightSpeed or Vector3.zero
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if flightEnabled then task.wait(0.6); setFlight(true) end
end)

local infJumpConn = nil
function setInfJump(enabled)
    infJumpConn = safeDisc(infJumpConn)
    if enabled then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local root = getRoot()
            local hum = getHum()
            if root and hum then
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    math.max(hum.JumpPower or 50, 50),
                    root.AssemblyLinearVelocity.Z
                )
            end
        end)
    end
end

local dayCycleConn = nil
function setDayCycle(enabled)
    dayCycleConn = safeDisc(dayCycleConn)
    if enabled then
        dayCycleConn = RunService.Heartbeat:Connect(function(dt)
            Lighting.ClockTime = (Lighting.ClockTime + dt * 0.6) % 24
        end)
    end
end

local fpsConn = nil
local inspectorConn = nil

function setFPSHud(enabled)
    FpsLabel.Visible = enabled
    fpsConn = safeDisc(fpsConn)
    if enabled then
        local last = os.clock()
        local frames = 0
        fpsConn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = os.clock()
            if now - last >= 0.5 then
                local fps = math.floor(frames / (now - last))
                frames = 0
                last = now
                local root = getRoot()
                local spd = root and math.floor(root.AssemblyLinearVelocity.Magnitude) or 0
                FpsLabel.Text = string.format("FPS  %d\nSPD  %d", fps, spd)
            end
        end)
    end
end

end

do
local AnimPacks = {
    ["Jotaro Jojo"] = {
        idle = {"rbxassetid://92883235513581"},
        walk = "rbxassetid://107733938306246",
        run = "rbxassetid://118070939457409",
        jump = "rbxassetid://111275681956878",
        fall = "rbxassetid://134305657928484",
        climb = "rbxassetid://75384982493358",
        swim = "rbxassetid://81127024518716",
    },
    ["Crawling Horror"] = {
        idle = {"rbxassetid://95586132222206"},
        walk = "rbxassetid://92145639084611",
        run = "rbxassetid://117974469147570",
        jump = "rbxassetid://72245411845039",
        fall = "rbxassetid://117701092748261",
        climb = "rbxassetid://127030796276137",
        swim = "rbxassetid://83651822331459",
    },
    Ninja = {
        idle = {"rbxassetid://656111159", "rbxassetid://656111812"},
        walk = "rbxassetid://656121766",
        run = "rbxassetid://656118852",
        jump = "rbxassetid://656117878",
        fall = "rbxassetid://656115606",
        climb = "rbxassetid://656114359",
        swim = "rbxassetid://656120899",
    },
    Mage = {
        idle = {"rbxassetid://707742142"},
        walk = "rbxassetid://707897766",
        run = "rbxassetid://707861613",
        jump = "rbxassetid://707853694",
        fall = "rbxassetid://707829703",
        climb = "rbxassetid://707826056",
        swim = "rbxassetid://707876402",
    },
    Vampire = {
        idle = {"rbxassetid://1083445855"},
        walk = "rbxassetid://1083473930",
        run = "rbxassetid://1083462077",
        jump = "rbxassetid://1083455352",
        fall = "rbxassetid://1083449352",
        climb = "rbxassetid://1083439238",
        swim = "rbxassetid://1083467667",
    },
    Superhero = {
        idle = {"rbxassetid://616111295"},
        walk = "rbxassetid://616122287",
        run = "rbxassetid://616117076",
        jump = "rbxassetid://616115533",
        fall = "rbxassetid://616113456",
        climb = "rbxassetid://616104706",
        swim = "rbxassetid://616119972",
    },
    Zombie = {
        idle = {"rbxassetid://616158929"},
        walk = "rbxassetid://616168032",
        run = "rbxassetid://616163605",
        jump = "rbxassetid://616161997",
        fall = "rbxassetid://616157476",
        climb = "rbxassetid://616156119",
        swim = "rbxassetid://616165109",
    },
    Toy = {
        idle = {"rbxassetid://782841498"},
        walk = "rbxassetid://782845354",
        run = "rbxassetid://782844588",
        jump = "rbxassetid://782843869",
        fall = "rbxassetid://782842708",
        climb = "rbxassetid://782843869",
        swim = "rbxassetid://782844596",
    },
    Levitation = {
        idle = {"rbxassetid://616006778"},
        walk = "rbxassetid://616013216",
        run = "rbxassetid://616010382",
        jump = "rbxassetid://616008975",
        fall = "rbxassetid://616005863",
        climb = "rbxassetid://616003713",
        swim = "rbxassetid://616011509",
    },
}

local currentPackName = nil
local forceR15Enabled = false
local r15FakeModel = nil
local r15FakeHum = nil
local r15FakeAnimator = nil
local activeTracks = {}
local animLoopConn = nil
local currentAnimState = "none"

function stopAllAnimations()
    for _, tr in pairs(activeTracks) do
        pcall(function() tr:Stop(0.1) end)
    end
    activeTracks = {}
    currentAnimState = "none"
    currentPackName = nil
end

local function getActiveAnimator()
    if r15FakeAnimator and r15FakeAnimator.Parent then
        return r15FakeAnimator
    end
    local hum = getHum()
    if hum then
        return hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    end
    return nil
end

local function playTrack(animId, isLoop)
    if not animId or animId == "" then return nil end
    local animator = getActiveAnimator()
    if not animator then return nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = isLoop or false
    track:Play(0.12)
    return track
end

local function updateActiveAnim()
    if not currentPackName then return end
    local pack = AnimPacks[currentPackName]
    if not pack then return end
    local hum = getHum()
    if not hum then return end

    local moving = hum.MoveDirection.Magnitude > 0.08
    local newState = "idle"
    local speed = hum.WalkSpeed
    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Freefall then
        newState = "fall"
    elseif state == Enum.HumanoidStateType.Jumping then
        newState = "jump"
    elseif state == Enum.HumanoidStateType.Climbing then
        newState = "climb"
    elseif state == Enum.HumanoidStateType.Swimming then
        newState = "swim"
    elseif moving then
        if speed > 18 and pack.run then
            newState = "run"
        else
            newState = "walk"
        end
    else
        newState = "idle"
    end

    if newState ~= currentAnimState then
        currentAnimState = newState
        for _, tr in pairs(activeTracks) do
            pcall(function() tr:Stop(0.1) end)
        end
        activeTracks = {}
        local animId = nil
        if newState == "idle" and pack.idle then
            animId = pack.idle[1]
        elseif newState == "walk" then
            animId = pack.walk or pack.run
        elseif newState == "run" then
            animId = pack.run or pack.walk
        elseif newState == "jump" then
            animId = pack.jump
        elseif newState == "fall" then
            animId = pack.fall
        elseif newState == "climb" then
            animId = pack.climb
        elseif newState == "swim" then
            animId = pack.swim
        end
        if animId then
            local isLoop = (newState == "idle" or newState == "walk" or newState == "run" or newState == "swim" or newState == "climb")
            local tr = playTrack(animId, isLoop)
            if tr then
                activeTracks[newState] = tr
            end
        end
    end
end

local function cleanR15Fake()
    for _, tr in pairs(activeTracks) do
        pcall(function() tr:Stop(0.1) end)
    end
    activeTracks = {}
    currentAnimState = "none"
    if r15FakeModel then
        pcall(function() r15FakeModel:Destroy() end)
        r15FakeModel = nil
        r15FakeHum = nil
        r15FakeAnimator = nil
    end
    local char = getChar()
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Transparency = 0
            elseif p:IsA("Decal") then
                p.Transparency = 0
            end
        end
    end
end

local function applyAnimateScriptIds(pack)
    local char = getChar()
    if not char then return end
    local animScript = char:FindFirstChild("Animate")
    if not animScript then return end
    animScript.Disabled = false

    local function setContainer(parentName, animId)
        local c = animScript:FindFirstChild(parentName)
        if c then
            for _, child in ipairs(c:GetChildren()) do
                if child:IsA("Animation") then child.AnimationId = animId end
            end
        end
    end

    if pack.idle then
        local idl = animScript:FindFirstChild("idle")
        if idl then
            local a1 = idl:FindFirstChild("Animation1")
            local a2 = idl:FindFirstChild("Animation2")
            if a1 and pack.idle[1] then a1.AnimationId = pack.idle[1] end
            if a2 and pack.idle[2] then a2.AnimationId = pack.idle[2] end
        end
    end
    if pack.walk then setContainer("walk", pack.walk) end
    if pack.run then setContainer("run", pack.run) end
    if pack.jump then setContainer("jump", pack.jump) end
    if pack.fall then setContainer("fall", pack.fall) end
    if pack.climb then setContainer("climb", pack.climb) end
    if pack.swim then setContainer("swim", pack.swim) end
end

function applyAnimPack(packName)
    local pack = AnimPacks[packName]
    if not pack then return end
    currentPackName = packName
    applyAnimateScriptIds(pack)

    local hum = getHum()
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0.1)
            end
        end
    end

    animLoopConn = safeDisc(animLoopConn)
    currentAnimState = "none"
    animLoopConn = RunService.Heartbeat:Connect(updateActiveAnim)
    updateActiveAnim()

    Notify("Animations", packName .. " Applied", 1.8, Theme.Green)
end

function setForceR15(enabled)
    forceR15Enabled = enabled
    cleanR15Fake()
    if not enabled then
        Notify("Animations", "Force R15 Disabled", 1.5)
        return
    end
    local char = getChar()
    local hum = getHum()
    local root = getRoot()
    if not char or not hum or not root then return end

    if hum.RigType == Enum.RigType.R6 then
        task.spawn(function()
            local desc = nil
            pcall(function()
                desc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
            end)
            if not desc then
                pcall(function() desc = hum:GetAppliedDescription() end)
            end
            if not desc then
                desc = Instance.new("HumanoidDescription")
            end
            local ok, m = pcall(function()
                return Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
            end)
            if ok and m then
                r15FakeModel = m
                r15FakeModel.Name = "NIXForceR15"
                local fakeRoot = r15FakeModel:WaitForChild("HumanoidRootPart", 5)
                r15FakeHum = r15FakeModel:FindFirstChildOfClass("Humanoid")
                if r15FakeHum then
                    r15FakeAnimator = r15FakeHum:FindFirstChildOfClass("Animator") or Instance.new("Animator", r15FakeHum)
                end

                for _, part in ipairs(r15FakeModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                    end
                end

                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Transparency = 1
                    elseif p:IsA("Decal") then
                        p.Transparency = 1
                    end
                end

                if fakeRoot then
                    fakeRoot.CFrame = root.CFrame
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = fakeRoot
                    weld.Parent = fakeRoot
                end

                r15FakeModel.Parent = char

                if currentPackName then
                    applyAnimPack(currentPackName)
                end
                Notify("Animations", "R6 to R15 Rig Active", 2, Theme.Green)
            else
                Notify("Animations", "R15 conversion unavailable", 2, Theme.Red)
            end
        end)
    else
        local animScript = char:FindFirstChild("Animate")
        if animScript then animScript.Disabled = false end
        Notify("Animations", "R15 Rig Enforced", 2, Theme.Green)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    cleanR15Fake()
    if forceR15Enabled then
        task.wait(0.7)
        setForceR15(true)
    end
    if currentPackName then
        task.wait(0.8)
        applyAnimPack(currentPackName)
    end
end)
end

local function resetAll()
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
PlayersTab:AddSection("Player Indicators")
PlayersTab:AddToggle("Name Tags", false, function(v) setNameTags(v); Notify("Players", v and "Name Tags ON" or "Name Tags OFF", 1.5) end)
PlayersTab:AddToggle("Health Bars", false, function(v) setHealthBars(v); Notify("Players", v and "Health Bars ON" or "Health Bars OFF", 1.5) end)
PlayersTab:AddToggle("Distance Indicators", false, function(v) setDistanceTags(v) end)

local AnimsTab = createTab("Anims")
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
PhysicsTab:AddToggle("Noclip (Phase Walls)", false, function(v) setNoclip(v); Notify("Physics", v and "Noclip ON" or "Noclip OFF", 1.5) end)
PhysicsTab:AddToggle("Air Walk (Sky Floor)", false, function(v) setAirWalk(v); Notify("Physics", v and "Air Walk ON" or "Air Walk OFF", 1.5) end)
PhysicsTab:AddToggle("Infinite Jump", false, function(v) setInfJump(v); Notify("Physics", v and "Infinite Jump ON" or "Infinite Jump OFF", 1.5) end)
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
