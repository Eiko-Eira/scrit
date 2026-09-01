local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

do
    local old = PlayerGui:FindFirstChild("NIXHubUI")
    if old then old:Destroy() end
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
ScreenGui.DisplayOrder = 10
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

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
    if #AllTabs == 0 then task.defer(select) end
    table.insert(AllTabs, tabObj)

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
        params.FilterType = RaycastFilterType.Exclude
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

local recoilEnabled = false
local recoilIntensity = 5
local recoilConn = nil
local targetRecoil = Vector3.zero
local currentRecoil = Vector3.zero

local function fireRecoil()
    if not recoilEnabled then return end
    targetRecoil = Vector3.new(
        recoilIntensity * (0.5 + math.random() * 0.5),
        (math.random() - 0.5) * recoilIntensity * 0.4,
        0
    )
end

local function setRecoil(enabled)
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

local function spawnBulletTracer()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    local char = getChar()
    if char then
        params.FilterDescendantsInstances = {char}
        params.FilterType = RaycastFilterType.Exclude
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

local aimEnabled = false
local aimRange = 300
local aimSnap = false
local glideSpeed = 0.12
local wallCheck = false
local teamCheck = false
local aimConn = nil
local rmbHeld = false
local lockedTarget = nil

local autoShotEnabled = false
local autoShotDelay = 0.14
local autoShotConn = nil
local lastAutoShot = 0
local wasOnTarget = false

local keysDown = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

UserInputService.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbHeld = true end
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then setVisible(not isVisible) end
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
    lockedTarget = nil
    if fcStroke then fcStroke.Color = Theme.Accent end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = false
        lockedTarget = nil
        if fcStroke then fcStroke.Color = Theme.Accent end
    end
    if inp.KeyCode == Enum.KeyCode.W then keysDown.W = false end
    if inp.KeyCode == Enum.KeyCode.A then keysDown.A = false end
    if inp.KeyCode == Enum.KeyCode.S then keysDown.S = false end
    if inp.KeyCode == Enum.KeyCode.D then keysDown.D = false end
    if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = false end
    if inp.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = false end
end)

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
    params.FilterType = RaycastFilterType.Exclude
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

local function setAimAssist(enabled)
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
    params.FilterType = RaycastFilterType.Exclude
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

local function setAutoShot(enabled)
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

local function forAllCharacters(onCharAdded, onCharRemoved)
    local connections = {}
    local function setupPlayer(player)
        if player == LocalPlayer then return end
        if player.Character then
            task.spawn(onCharAdded, player, player.Character)
        end
        local cConn = player.CharacterAdded:Connect(function(char)
            task.wait(0.4)
            if char and char.Parent then
                onCharAdded(player, char)
            end
        end)
        local rConn = player.CharacterRemoving:Connect(function(char)
            if onCharRemoved then onCharRemoved(player, char) end
        end)
        table.insert(connections, cConn)
        table.insert(connections, rConn)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        setupPlayer(p)
    end
    local pConn = Players.PlayerAdded:Connect(setupPlayer)
    table.insert(connections, pConn)

    return function()
        for _, c in ipairs(connections) do safeDisc(c) end
    end
end

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

local function setHighlights(enabled)
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
local function setFullbright(enabled)
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

local function setNightVision(enabled)
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
local cameraShakeIntensity = 3
local cameraShakeConn = nil
local shakeTime = 0

local function setCameraShake(enabled)
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

local function setHeadbob(enabled)
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

local function setSpeedlines(enabled)
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

local function setNameTags(enabled)
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

local function setHealthBars(enabled)
    if hbCleanup then hbCleanup(); hbCleanup = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeHealthBar(p, p.Character) end
    end
    if enabled then
        hbCleanup = forAllCharacters(applyHealthBar, removeHealthBar)
    end
end

local distConn = nil
local function setDistanceTags(enabled)
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

local flightEnabled = false
local flightSpeed = 60
local flightVel = nil
local flightAtt = nil
local flightConn = nil

local function setFlight(enabled)
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
local function setInfJump(enabled)
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
local function setDayCycle(enabled)
    dayCycleConn = safeDisc(dayCycleConn)
    if enabled then
        dayCycleConn = RunService.Heartbeat:Connect(function(dt)
            Lighting.ClockTime = (Lighting.ClockTime + dt * 0.6) % 24
        end)
    end
end

local fpsConn = nil
local inspectorConn = nil

local function setFPSHud(enabled)
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

local AnimPacks = {
    Ninja = {
        idle = {"rbxassetid://656111159", "rbxassetid://656111812"},
        walk = "rbxassetid://656121766",
        run = "rbxassetid://656118852",
        jump = "rbxassetid://656117878",
        fall = "rbxassetid://656115606",
        swim = "rbxassetid://656120899",
    },
    Mage = {
        idle = {"rbxassetid://707742142"},
        walk = "rbxassetid://707897766",
        run = "rbxassetid://707861613",
        jump = "rbxassetid://707853694",
        fall = "rbxassetid://707829703",
        swim = "rbxassetid://707876402",
    },
    Vampire = {
        idle = {"rbxassetid://1083445855"},
        walk = "rbxassetid://1083473930",
        run = "rbxassetid://1083462077",
        jump = "rbxassetid://1083455352",
        fall = "rbxassetid://1083449352",
    },
    Superhero = {
        idle = {"rbxassetid://616111295"},
        walk = "rbxassetid://616122287",
        run = "rbxassetid://616117076",
        jump = "rbxassetid://616115533",
        fall = "rbxassetid://616113456",
    },
    Zombie = {
        idle = {"rbxassetid://616158929"},
        walk = "rbxassetid://616168032",
        run = "rbxassetid://616163605",
        jump = "rbxassetid://616161997",
        fall = "rbxassetid://616157476",
    },
    Toy = {
        idle = {"rbxassetid://782841498"},
        walk = "rbxassetid://782845354",
        run = "rbxassetid://782844588",
        jump = "rbxassetid://782843869",
        fall = "rbxassetid://782842708",
    },
    Levitation = {
        idle = {"rbxassetid://616006778"},
        walk = "rbxassetid://616013216",
        run = "rbxassetid://616010382",
        jump = "rbxassetid://616008975",
        fall = "rbxassetid://616005863",
    },
}

local currentPackName = nil

local function applyAnimPack(packName)
    local pack = AnimPacks[packName]
    if not pack then return end
    currentPackName = packName
    local char = getChar()
    if not char then return end
    local animScript = char:FindFirstChild("Animate")
    if not animScript then return end

    local function setAnim(parentName, animId)
        local container = animScript:FindFirstChild(parentName)
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Animation") then
                    child.AnimationId = animId
                end
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
    if pack.walk then setAnim("walk", pack.walk) end
    if pack.run then setAnim("run", pack.run) end
    if pack.jump then setAnim("jump", pack.jump) end
    if pack.fall then setAnim("fall", pack.fall) end
    if pack.swim then setAnim("swim", pack.swim) end

    local hum = getHum()
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0.1)
            end
        end
    end
    Notify("Animations", packName .. " pack applied", 1.8, Theme.Green)
end

LocalPlayer.CharacterAdded:Connect(function()
    if currentPackName then
        task.wait(0.8)
        applyAnimPack(currentPackName)
    end
end)

local function resetAll()
    setAimAssist(false)
    setAutoShot(false)
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

VisualsTab:AddSection("Camera Effects")
VisualsTab:AddToggle("Head Bob", false, function(v) setHeadbob(v) end)
VisualsTab:AddToggle("Speed Lines", false, function(v) setSpeedlines(v) end)

local PlayersTab = createTab("Players")
PlayersTab:AddSection("Player Indicators")
PlayersTab:AddToggle("Name Tags", false, function(v) setNameTags(v); Notify("Players", v and "Name Tags ON" or "Name Tags OFF", 1.5) end)
PlayersTab:AddToggle("Health Bars", false, function(v) setHealthBars(v); Notify("Players", v and "Health Bars ON" or "Health Bars OFF", 1.5) end)
PlayersTab:AddToggle("Distance Indicators", false, function(v) setDistanceTags(v) end)

local AnimsTab = createTab("Anims")
AnimsTab:AddSection("Universal R15 Packs")
for _, pName in ipairs({"Ninja", "Mage", "Vampire", "Superhero", "Zombie", "Toy", "Levitation"}) do
    AnimsTab:AddButton(pName .. " Pack", function()
        applyAnimPack(pName)
    end)
end

local PhysicsTab = createTab("Physics")
PhysicsTab:AddSection("Flight  [ WASD / Space / Shift ]")
PhysicsTab:AddToggle("Creative Flight", false, function(v) setFlight(v); Notify("Physics", v and "Flight ON" or "Flight OFF", 1.5) end)
PhysicsTab:AddSlider("Flight Speed", 10, 250, 60, function(v) flightSpeed = v end)

PhysicsTab:AddSection("Locomotion")
PhysicsTab:AddToggle("Infinite Jump", false, function(v) setInfJump(v); Notify("Physics", v and "Infinite Jump ON" or "Infinite Jump OFF", 1.5) end)
PhysicsTab:AddSlider("Walk Speed", 8, 200, 16, function(v)
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

local ToolsTab = createTab("Tools")
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
        if d.Name and d.Name:find("NIX") and (d:IsA("BasePart") or d:IsA("Beam") or d:IsA("Highlight")) then
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
    Notify("NIXHub", "Loaded  *  Right Shift to toggle", 4, Theme.Green)
end)
