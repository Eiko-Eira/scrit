local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

do
    local old = PlayerGui:FindFirstChild("AikBitcoinMinerUI")
    if old then old:Destroy() end
end

local blockedRemotes = {
    KickMe = true,
    Blacklisted = true,
    FullDatWipe = true,
    ManuBan = true,
    Manuunban = true,
}

local rawMeta = getrawmetatable and getrawmetatable(game)
if rawMeta and setreadonly then
    setreadonly(rawMeta, false)
    local oldNamecall = rawMeta.__namecall
    rawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
            if blockedRemotes[self.Name] then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(rawMeta, true)
end

local function getRemote(parentPath, name)
    local cur = ReplicatedStorage
    for _, part in ipairs(string.split(parentPath, ".")) do
        cur = cur and cur:FindFirstChild(part)
        if not cur then return nil end
    end
    return cur and cur:FindFirstChild(name)
end

local function safeFire(parentPath, name, ...)
    local r = getRemote(parentPath, name)
    if r and r:IsA("RemoteEvent") then
        pcall(function(...)
            r:FireServer(...)
        end, ...)
        return true
    end
    return false
end

local function safeInvoke(parentPath, name, ...)
    local r = getRemote(parentPath, name)
    if r and r:IsA("RemoteFunction") then
        local res = nil
        pcall(function(...)
            res = r:InvokeServer(...)
        end, ...)
        return res
    end
    return nil
end

local Theme = {
    Background    = Color3.fromRGB(10, 11, 14),
    Header        = Color3.fromRGB(16, 17, 22),
    Sidebar       = Color3.fromRGB(12, 13, 17),
    TabActive     = Color3.fromRGB(240, 240, 245),
    TabActiveText = Color3.fromRGB(10, 11, 14),
    TabInactive   = Color3.fromRGB(18, 19, 24),
    TabInactiveText = Color3.fromRGB(130, 135, 145),
    Accent        = Color3.fromRGB(247, 147, 26),
    AccentDim     = Color3.fromRGB(180, 110, 20),
    ElementBg     = Color3.fromRGB(20, 22, 28),
    ElementHover  = Color3.fromRGB(28, 30, 38),
    ElementActive = Color3.fromRGB(36, 38, 48),
    TextPrimary   = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(140, 145, 155),
    Border        = Color3.fromRGB(38, 40, 50),
    BorderBright  = Color3.fromRGB(75, 80, 95),
    Green         = Color3.fromRGB(80, 220, 120),
    Red           = Color3.fromRGB(230, 75, 75),
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikBitcoinMinerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 20
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "NotifHolder"
NotifHolder.Size = UDim2.new(0, 280, 1, -60)
NotifHolder.Position = UDim2.new(1, -290, 0, 30)
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
    card.Size = UDim2.new(1, 0, 0, 52)
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
    nTitle.Font = Enum.Font.Gotham
    nTitle.TextSize = 11
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.Parent = card

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -18, 0, 18)
    nDesc.Position = UDim2.new(0, 12, 0, 25)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = desc
    nDesc.TextColor3 = Theme.TextSecondary
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 10
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
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(prog, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0)}, 0.2).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MainShadow = Instance.new("Frame")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(0, 616, 0, 456)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.65
MainShadow.BorderSizePixel = 0
MainShadow.Active = false
MainShadow.ZIndex = 9
MainShadow.Parent = ScreenGui

local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 12)
msCorner.Parent = MainShadow

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 440)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.12
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

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

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BackgroundTransparency = 0.08
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 15
TopBar.Parent = MainFrame

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Theme.Border
tbStroke.Thickness = 1
tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tbStroke.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 240, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AIKHUB * BITCOIN MINER"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.Gotham
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 16
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 220, 1, 0)
subtitleLabel.Position = UDim2.new(0, 200, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "GAMEID: 943733974 | RSHIFT"
subtitleLabel.TextColor3 = Theme.TextSecondary
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 10
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 16
subtitleLabel.Parent = TopBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(1, -56, 0.5, -3)
statusDot.BackgroundColor3 = Theme.Green
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 16
statusDot.Parent = TopBar

local sdCorner = Instance.new("UICorner")
sdCorner.CornerRadius = UDim.new(1, 0)
sdCorner.Parent = statusDot

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -36, 0.5, -13)
closeBtn.BackgroundColor3 = Theme.ElementBg
closeBtn.Text = "x"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 16
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 4)
cbCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Red, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.12) end)
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
        local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + d.X, framePos.Y.Scale, framePos.Y.Offset + d.Y)
        MainFrame.Position = newPos
        MainShadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 3)
    end
end)

local isVisible = true
local function setVisible(v)
    isVisible = v
    if v then
        MainFrame.Visible = true
        MainShadow.Visible = true
        tw(MainFrame, {Size = UDim2.new(0, 600, 0, 440), BackgroundTransparency = 0.12}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(MainShadow, {Size = UDim2.new(0, 616, 0, 456), BackgroundTransparency = 0.65}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tw(MainShadow, {Size = UDim2.new(0, 560, 0, 400), BackgroundTransparency = 1}, 0.18)
        tw(MainFrame, {Size = UDim2.new(0, 560, 0, 400), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
            MainFrame.Visible = false
            MainShadow.Visible = false
        end)
    end
end

closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "AikFloatToggle"
FloatToggle.Size = UDim2.new(0, 40, 0, 40)
FloatToggle.Position = UDim2.new(0, 16, 0.5, -20)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "BTC"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.Gotham
FloatToggle.TextSize = 11
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

FloatToggle.MouseButton1Click:Connect(function()
    setVisible(not isVisible)
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 136, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 10
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
ContentArea.ZIndex = 10
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
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local tabObj = {Button = tabBtn, Page = page, Name = name, ActiveLine = activeLine}

    local function select()
        if activeTab == tabObj then return end
        if activeTab then
            local oldPage = activeTab.Page
            tw(oldPage, {Position = UDim2.new(0, 7, 0, 0)}, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                oldPage.Visible = false
            end)
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.15)
            tw(activeTab.ActiveLine, {Size = UDim2.new(0, 2, 0, 4), BackgroundTransparency = 1}, 0.15)
        end
        activeTab = tabObj
        page.CanvasPosition = Vector2.new(0, 0)
        page.Position = UDim2.new(0, 7, 0, 16)
        page.Visible = true
        tw(page, {Position = UDim2.new(0, 7, 0, 7)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        tw(tabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabActiveText}, 0.15)
        tw(activeLine, {Size = UDim2.new(0, 2, 0, 16), BackgroundTransparency = 0}, 0.15)
    end

    tabBtn.MouseButton1Click:Connect(select)
    table.insert(AllTabs, tabObj)
    if #AllTabs == 1 then task.defer(select) end

    function tabObj:AddSection(label)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = page

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(label)
        lbl.TextColor3 = Theme.AccentDim
        lbl.Font = Enum.Font.Gotham
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
        btn.BackgroundTransparency = 0.2
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
            tw(btn, {BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.08}, 0.12)
            tw(bStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementBg, BackgroundTransparency = 0.2}, 0.12)
            tw(bStroke, {Color = Theme.Border}, 0.12)
        end)
        btn.MouseButton1Down:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementActive}, 0.08)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
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
        row.BackgroundTransparency = 0.2
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
            tw(accentBar, {BackgroundTransparency = state and 0 or 1}, 0.18)
            tw(knob, {
                Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
            }, 0.14)
            if cb then task.spawn(cb, state) end
        end

        row.MouseEnter:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.08}, 0.12)
            tw(rStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        row.MouseLeave:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementBg, BackgroundTransparency = 0.2}, 0.12)
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
        container.Size = UDim2.new(1, 0, 0, 48)
        container.BackgroundColor3 = Theme.ElementBg
        container.BackgroundTransparency = 0.2
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner", container)
        cCorner.CornerRadius = UDim.new(0, 5)

        local cStroke = Instance.new("UIStroke", container)
        cStroke.Color = Theme.Border
        cStroke.Thickness = 1

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
        valLbl.TextColor3 = Theme.Accent
        valLbl.Font = Enum.Font.Gotham
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local trackBg = Instance.new("Frame")
        trackBg.Size = UDim2.new(1, -22, 0, 5)
        trackBg.Position = UDim2.new(0, 11, 0, 30)
        trackBg.BackgroundColor3 = Theme.Header
        trackBg.BorderSizePixel = 0
        trackBg.Parent = container

        local trCorner = Instance.new("UICorner", trackBg)
        trCorner.CornerRadius = UDim.new(1, 0)

        local fillBar = Instance.new("Frame")
        local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
        fillBar.Size = UDim2.new(initRatio, 0, 1, 0)
        fillBar.BackgroundColor3 = Theme.Accent
        fillBar.BorderSizePixel = 0
        fillBar.Parent = trackBg

        local fbCorner = Instance.new("UICorner", fillBar)
        fbCorner.CornerRadius = UDim.new(1, 0)

        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 14, 0, 14)
        handle.AnchorPoint = Vector2.new(0.5, 0.5)
        handle.Position = UDim2.new(initRatio, 0, 0.5, 0)
        handle.BackgroundColor3 = Theme.Accent
        handle.Text = ""
        handle.BorderSizePixel = 0
        handle.ZIndex = 5
        handle.Parent = trackBg

        local hCorner = Instance.new("UICorner", handle)
        hCorner.CornerRadius = UDim.new(1, 0)

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
            end
        end)
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                applySlide(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
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

local CurrencyTab = createTab("Currency")
local ExchangeTab = createTab("Exchange")
local PlotTab     = createTab("Plot & Cards")
local MoveTab     = createTab("Movement")
local SafetyTab   = createTab("Safety")

local autoSuperCash = false
local autoPremCoins = false
local autoXp = false
local autoSnowflake = false
local autoGrass = false

CurrencyTab:AddSection("Auto Currency Loops")
CurrencyTab:AddToggle("Auto Super Cash (AddSCash)", false, function(v)
    autoSuperCash = v
    if v then
        task.spawn(function()
            while autoSuperCash do
                safeInvoke("Events", "AddSCash")
                task.wait(0.2)
            end
        end)
        Notify("Currency", "Auto Super Cash loop running", 1.5, Theme.Green)
    end
end)

CurrencyTab:AddToggle("Auto Premium Coins", false, function(v)
    autoPremCoins = v
    if v then
        task.spawn(function()
            while autoPremCoins do
                safeFire("Events", "GivePremiumCoins")
                task.wait(0.25)
            end
        end)
        Notify("Currency", "Auto Premium Coins loop running", 1.5, Theme.Green)
    end
end)

CurrencyTab:AddToggle("Auto XP Leveler (AddXp)", false, function(v)
    autoXp = v
    if v then
        task.spawn(function()
            while autoXp do
                safeInvoke("Events", "AddXp")
                task.wait(0.3)
            end
        end)
        Notify("Currency", "Auto XP leveling loop running", 1.5, Theme.Green)
    end
end)

CurrencyTab:AddSection("Milestones & Rewards")
CurrencyTab:AddButton("Claim 200M Milestone Gift", function()
    local ok = safeFire("Events", "Open200MGift")
    Notify("Milestone", ok and "Claimed 200M Gift!" or "Gift remote not found", 2, ok and Theme.Green or Theme.Red)
end)

CurrencyTab:AddButton("Redeem Event Tickets", function()
    local ok = safeFire("Events", "TicketReedem")
    Notify("Rewards", ok and "Redeemed Event Tickets!" or "Ticket remote not found", 2, ok and Theme.Green or Theme.Red)
end)

CurrencyTab:AddButton("Refresh / Sync Cash Balance", function()
    local res = safeInvoke("Events", "CashRefresh")
    Notify("Balance", "Cash balance refreshed with server", 1.5, Theme.Accent)
end)

CurrencyTab:AddSection("Seasonal & World Farming")
CurrencyTab:AddToggle("Auto Collect Snowflakes", false, function(v)
    autoSnowflake = v
    if v then
        task.spawn(function()
            while autoSnowflake do
                safeFire("Events", "SpawnSnowFlakes")
                safeFire("Events", "CollectSnowflake")
                task.wait(0.2)
            end
        end)
        Notify("Seasonal", "Auto Snowflake collector active", 1.5, Theme.Green)
    end
end)

CurrencyTab:AddToggle("Auto Search Grass for Loot", false, function(v)
    autoGrass = v
    if v then
        task.spawn(function()
            while autoGrass do
                safeInvoke("Events", "SearchGrass")
                task.wait(0.4)
            end
        end)
        Notify("Loot", "Auto Grass searcher running", 1.5, Theme.Green)
    end
end)

local autoSimpleExchange = false
local autoSimpleCollect = false

ExchangeTab:AddSection("Automated Exchange")
ExchangeTab:AddToggle("Auto Convert Crypto (SimpleExchange)", false, function(v)
    autoSimpleExchange = v
    if v then
        task.spawn(function()
            while autoSimpleExchange do
                safeFire("Events.Exchanger", "SimpleExchange")
                task.wait(0.5)
            end
        end)
        Notify("Exchange", "Auto Crypto converter active", 1.5, Theme.Green)
    end
end)

ExchangeTab:AddToggle("Auto Collect Exchange Cash", false, function(v)
    autoSimpleCollect = v
    if v then
        task.spawn(function()
            while autoSimpleCollect do
                safeFire("Events.Exchanger", "SimpleCollect")
                task.wait(0.5)
            end
        end)
        Notify("Exchange", "Auto Cash collector active", 1.5, Theme.Green)
    end
end)

ExchangeTab:AddSection("Rate Modifiers & Boosters")
ExchangeTab:AddButton("Trigger Free Rate Refresh", function()
    local ok = safeFire("Events", "FreeCngRate")
    safeFire("Events", "ChangeRate")
    Notify("Rates", ok and "Triggered free rate refresh!" or "Rate remote dispatched", 1.5, Theme.Accent)
end)

ExchangeTab:AddButton("Apply Exchange Coupon Boost", function()
    local ok = safeFire("Events.Exchanger", "UseCoupon")
    Notify("Booster", ok and "Applied booster coupon!" or "Coupon remote dispatched", 1.5, Theme.Green)
end)

local autoSolar = false
local autoOpenCase = false

PlotTab:AddSection("Plot Permissions & Unlocks")
PlotTab:AddButton("Unlock All Barriers (DisableBarriers)", function()
    local ok = safeFire("Events", "DisableBarriers")
    Notify("Plot", ok and "All barriers disabled on server!" or "Barrier remote dispatched", 2, Theme.Green)
end)

PlotTab:AddButton("Open All Plot Doors", function()
    safeFire("Events", "OpenDoor")
    safeFire("Events", "MoveDoors")
    safeFire("Events", "MoveDoorz")
    Notify("Plot", "Dispatched all door open triggers", 1.5, Theme.Accent)
end)

PlotTab:AddToggle("Infinite Solar Generator Always ON", false, function(v)
    autoSolar = v
    if v then
        task.spawn(function()
            while autoSolar do
                safeFire("Events", "SolarSwitch")
                task.wait(1.5)
            end
        end)
        Notify("Power", "Solar power auto-switch active", 1.5, Theme.Green)
    end
end)

PlotTab:AddSection("Mining Rig & Card Automations")
PlotTab:AddButton("Merge Platinum Rigs (PlatiniumMerge)", function()
    local ok = safeFire("Events", "PlatiniumMerge")
    Notify("Merge", ok and "Dispatched Platinum Merge!" or "Merge remote not found", 2, Theme.Green)
end)

PlotTab:AddToggle("Auto Unbox Crates / Cases", false, function(v)
    autoOpenCase = v
    if v then
        task.spawn(function()
            while autoOpenCase do
                safeInvoke("Events", "OpenCase")
                task.wait(0.5)
            end
        end)
        Notify("Cases", "Auto Case unboxer loop active", 1.5, Theme.Green)
    end
end)

PlotTab:AddButton("Auto-Equip Highest Hashrate Cards", function()
    safeInvoke("Events", "GetBestCard")
    safeInvoke("Events", "BatchCardChange")
    Notify("Cards", "Requested best card loadout change", 2, Theme.Green)
end)

MoveTab:AddSection("World Teleports")
MoveTab:AddButton("Teleport to Plot (Teltodata)", function()
    local ok = safeFire("Events", "Teltodata")
    Notify("Teleport", ok and "Dispatched plot teleport" or "Teleport remote called", 1.5)
end)

MoveTab:AddButton("Teleport to Shop", function()
    local ok = safeFire("Events", "ShopEnter")
    Notify("Teleport", ok and "Teleporting to Shop" or "Shop remote called", 1.5)
end)

MoveTab:AddButton("Teleport to Train Station", function()
    local ok = safeFire("Events", "TrainTel")
    Notify("Teleport", ok and "Teleporting to Train" or "Train remote called", 1.5)
end)

MoveTab:AddSection("Physical Movement Modifiers")
local customSpeed = 16
MoveTab:AddSlider("WalkSpeed", 16, 120, 16, function(val)
    customSpeed = val
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and customSpeed ~= 16 then hum.WalkSpeed = customSpeed end
end)

local noclipConn = nil
MoveTab:AddToggle("Noclip (Phase Walls)", false, function(v)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if v then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Notify("Movement", "Noclip active", 1.5, Theme.Green)
    else
        Notify("Movement", "Noclip disabled", 1.5)
    end
end)

local infJumpConn = nil
MoveTab:AddToggle("Infinite Jump", false, function(v)
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    if v then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z)
            end
        end)
        Notify("Movement", "Infinite Jump active", 1.5, Theme.Green)
    else
        Notify("Movement", "Infinite Jump disabled", 1.5)
    end
end)

SafetyTab:AddSection("Anticheat & Trap Status")
SafetyTab:AddButton("Blocked: KickMe (Honeypot Remote)", function()
    Notify("Shield", "KickMe remote is safely blocked by metamethod hook", 2.5, Theme.Green)
end)
SafetyTab:AddButton("Blocked: Blacklisted (Trap Remote)", function()
    Notify("Shield", "Blacklisted remote is safely blocked", 2.5, Theme.Green)
end)
SafetyTab:AddButton("Blocked: FullDatWipe (Data Wipe Trap)", function()
    Notify("Shield", "FullDatWipe remote is safely blocked", 2.5, Theme.Green)
end)
SafetyTab:AddButton("Blocked: ManuBan (Manual Ban Remote)", function()
    Notify("Shield", "ManuBan remote is safely blocked", 2.5, Theme.Green)
end)

SafetyTab:AddSection("Information")
SafetyTab:AddButton("Game: Bitcoin Miner", function() end)
SafetyTab:AddButton("Game ID: 943733974", function()
    if setclipboard then pcall(setclipboard, "943733974") end
    Notify("Copied", "Copied Game ID to clipboard", 1.5, Theme.Accent)
end)
SafetyTab:AddButton("Place ID: 2629642516", function()
    if setclipboard then pcall(setclipboard, "2629642516") end
    Notify("Copied", "Copied Place ID to clipboard", 1.5, Theme.Accent)
end)

Notify("AIKHUB", "Bitcoin Miner script loaded! Press RShift to toggle", 4, Theme.Accent)
