local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

do
    local old = PlayerGui:FindFirstChild("AikSpiderCrawlUI")
    if old then old:Destroy() end
end

local Theme = {
    Background    = Color3.fromRGB(10, 10, 12),
    Header        = Color3.fromRGB(16, 16, 20),
    CardBg        = Color3.fromRGB(20, 20, 26),
    CardHover     = Color3.fromRGB(30, 30, 38),
    CardActive    = Color3.fromRGB(40, 40, 50),
    TextPrimary   = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Accent        = Color3.fromRGB(255, 255, 255),
    AccentDim     = Color3.fromRGB(180, 180, 180),
    Border        = Color3.fromRGB(38, 38, 48),
    BorderBright  = Color3.fromRGB(75, 75, 90),
    Crimson       = Color3.fromRGB(235, 50, 65),
    Green         = Color3.fromRGB(80, 220, 120),
    Purple        = Color3.fromRGB(160, 90, 240),
    LogBg         = Color3.fromRGB(12, 12, 16),
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function copyToClipboard(text)
    local fn = setclipboard or toclipboard or set_clipboard or writeclipboard
    if not fn and syn and syn.write_clipboard then
        fn = syn.write_clipboard
    end
    if not fn and Clipboard and Clipboard.set then
        fn = Clipboard.set
    end
    if fn then
        local ok = pcall(fn, text)
        return ok
    end
    return false
end

local logEntries = {}
local maxLogEntries = 150
local logScrollFrame = nil

local function addLog(category, text, col)
    local timestamp = os.date("%H:%M:%S")
    local lineStr = string.format("[%s] [%s] %s", timestamp, category, text)
    table.insert(logEntries, lineStr)
    if #logEntries > maxLogEntries then
        table.remove(logEntries, 1)
    end

    if logScrollFrame and logScrollFrame.Parent then
        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, -8, 0, 16)
        row.BackgroundTransparency = 1
        row.Text = lineStr
        row.TextColor3 = col or Theme.TextSecondary
        row.Font = Enum.Font.Gotham
        row.TextSize = 9
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.Parent = logScrollFrame

        logScrollFrame.CanvasPosition = Vector2.new(0, 99999)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikSpiderCrawlUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local ToastHolder = Instance.new("Frame")
ToastHolder.Name = "ToastHolder"
ToastHolder.Size = UDim2.new(0, 260, 0, 70)
ToastHolder.Position = UDim2.new(1, -274, 0, 16)
ToastHolder.BackgroundTransparency = 1
ToastHolder.ZIndex = 200
ToastHolder.Parent = ScreenGui

local function notify(title, desc, duration, col)
    duration = duration or 2.5
    col = col or Theme.Crimson

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Theme.Header
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = ToastHolder

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 5)
    cCorner.Parent = card

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1
    cStroke.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0
    bar.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -20, 0, 16)
    tLbl.Position = UDim2.new(0, 12, 0, 4)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = string.upper(title)
    tLbl.TextColor3 = col
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 10
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(1, -20, 0, 16)
    dLbl.Position = UDim2.new(0, 12, 0, 20)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = Theme.TextSecondary
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 10
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = card

    card.Position = UDim2.new(1, 20, 0, 0)
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.2)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.2).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 8)
mfCorner.Parent = MainFrame

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Theme.Border
tbStroke.Thickness = 1
tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tbStroke.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 180, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SPIDER CRAWLER v5"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 160, 1, 0)
subtitleLabel.Position = UDim2.new(0, 175, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "by eikovo * scriptblox"
subtitleLabel.TextColor3 = Theme.Crimson
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 10
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Theme.CardBg
closeBtn.Text = "x"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 4)
cbCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Crimson, TextColor3 = Theme.Accent}, 0.12) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.CardBg, TextColor3 = Theme.TextSecondary}, 0.12) end)

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
        MainFrame.Size = UDim2.new(0, 420, 0, 0)
        MainFrame.BackgroundTransparency = 1
        tw(MainFrame, {Size = UDim2.new(0, 420, 0, 500), BackgroundTransparency = 0}, 0.2)
    else
        tw(MainFrame, {Size = UDim2.new(0, 420, 0, 0), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
end

closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local ControlsHolder = Instance.new("Frame")
ControlsHolder.Name = "ControlsHolder"
ControlsHolder.Size = UDim2.new(1, -20, 0, 245)
ControlsHolder.Position = UDim2.new(0, 10, 0, 46)
ControlsHolder.BackgroundTransparency = 1
ControlsHolder.Parent = MainFrame

local cLayout = Instance.new("UIListLayout")
cLayout.SortOrder = Enum.SortOrder.LayoutOrder
cLayout.Padding = UDim.new(0, 4)
cLayout.Parent = ControlsHolder

local function addToggle(label, default, cb)
    local state = default or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = Theme.CardBg
    row.Text = ""
    row.BorderSizePixel = 0
    row.Parent = ControlsHolder

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 4)
    rCorner.Parent = row

    local rStroke = Instance.new("UIStroke")
    rStroke.Color = Theme.Border
    rStroke.Thickness = 1
    rStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.TextPrimary
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local swTrack = Instance.new("Frame")
    swTrack.Size = UDim2.new(0, 30, 0, 16)
    swTrack.Position = UDim2.new(1, -40, 0.5, -8)
    swTrack.BackgroundColor3 = state and Theme.Crimson or Theme.Header
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
        tw(swTrack, {BackgroundColor3 = state and Theme.Crimson or Theme.Header}, 0.14)
        tw(knob, {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
        }, 0.14)
        if cb then task.spawn(cb, state) end
    end

    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = Theme.CardHover}, 0.12) end)
    row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = Theme.CardBg}, 0.12) end)
    row.MouseButton1Click:Connect(function() setToggle(not state) end)

    return setToggle
end

local function addSlider(label, minV, maxV, defaultV, cb)
    local val = defaultV or minV
    minV = minV or 16
    maxV = maxV or 80

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Theme.CardBg
    container.BorderSizePixel = 0
    container.Parent = ControlsHolder

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1
    cStroke.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.TextPrimary
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 16)
    valLbl.Position = UDim2.new(1, -58, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.TextColor3 = Theme.AccentDim
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -20, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 0, 21)
    trackBg.BackgroundColor3 = Theme.Header
    trackBg.BorderSizePixel = 0
    trackBg.Parent = container

    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(1, 0)
    trCorner.Parent = trackBg

    local fillBar = Instance.new("Frame")
    local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
    fillBar.Size = UDim2.new(initRatio, 0, 1, 0)
    fillBar.BackgroundColor3 = Theme.Crimson
    fillBar.BorderSizePixel = 0
    fillBar.Parent = trackBg

    local fbCorner = Instance.new("UICorner")
    fbCorner.CornerRadius = UDim.new(1, 0)
    fbCorner.Parent = fillBar

    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(initRatio, 0, 0.5, 0)
    handle.BackgroundColor3 = Theme.Crimson
    handle.Text = ""
    handle.BorderSizePixel = 0
    handle.ZIndex = 5
    handle.Parent = trackBg

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = handle

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
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    trackBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            applySlide(inp.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and sliding then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then applySlide(inp.Position) end
    end)
end

local function addButton(label, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Theme.CardBg
    btn.Text = label
    btn.TextColor3 = Theme.TextPrimary
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = ControlsHolder

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Theme.Border
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.CardHover}, 0.12)
        tw(bStroke, {Color = Theme.BorderBright}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.CardBg}, 0.12)
        tw(bStroke, {Color = Theme.Border}, 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.CardActive}, 0.06)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.CardHover}, 0.06)
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then task.spawn(cb) end
    end)
    return btn
end

local LogHeaderFrame = Instance.new("Frame")
LogHeaderFrame.Name = "LogHeaderFrame"
LogHeaderFrame.Size = UDim2.new(1, -20, 0, 24)
LogHeaderFrame.Position = UDim2.new(0, 10, 0, 295)
LogHeaderFrame.BackgroundTransparency = 1
LogHeaderFrame.Parent = MainFrame

local logTitle = Instance.new("TextLabel")
logTitle.Size = UDim2.new(0, 150, 1, 0)
logTitle.Position = UDim2.new(0, 2, 0, 0)
logTitle.BackgroundTransparency = 1
logTitle.Text = "LIVE DEBUG LOG"
logTitle.TextColor3 = Theme.AccentDim
logTitle.Font = Enum.Font.GothamBold
logTitle.TextSize = 9
logTitle.TextXAlignment = Enum.TextXAlignment.Left
logTitle.Parent = LogHeaderFrame

local copyLogBtn = Instance.new("TextButton")
copyLogBtn.Size = UDim2.new(0, 140, 1, 0)
copyLogBtn.Position = UDim2.new(1, -142, 0, 0)
copyLogBtn.BackgroundColor3 = Theme.CardBg
copyLogBtn.Text = "COPY ALL LOGS"
copyLogBtn.TextColor3 = Theme.Green
copyLogBtn.Font = Enum.Font.GothamBold
copyLogBtn.TextSize = 9
copyLogBtn.BorderSizePixel = 0
copyLogBtn.Parent = LogHeaderFrame

local clCorner = Instance.new("UICorner")
clCorner.CornerRadius = UDim.new(0, 4)
clCorner.Parent = copyLogBtn

local clStroke = Instance.new("UIStroke")
clStroke.Color = Theme.Border
clStroke.Thickness = 1
clStroke.Parent = copyLogBtn

copyLogBtn.MouseEnter:Connect(function()
    tw(copyLogBtn, {BackgroundColor3 = Theme.CardHover}, 0.12)
    tw(clStroke, {Color = Theme.BorderBright}, 0.12)
end)
copyLogBtn.MouseLeave:Connect(function()
    tw(copyLogBtn, {BackgroundColor3 = Theme.CardBg}, 0.12)
    tw(clStroke, {Color = Theme.Border}, 0.12)
end)

copyLogBtn.MouseButton1Click:Connect(function()
    local fullText = table.concat(logEntries, "\n")
    local ok = copyToClipboard(fullText)
    if ok then
        copyLogBtn.Text = "LOGS COPIED!"
        notify("Clipboard", "All logs copied! Paste in chat.", 2.5, Theme.Green)
        task.delay(2, function()
            copyLogBtn.Text = "COPY ALL LOGS"
        end)
    else
        notify("Clipboard", "Clipboard function blocked by executor.", 3, Theme.Crimson)
    end
end)

local LogContainer = Instance.new("Frame")
LogContainer.Name = "LogContainer"
LogContainer.Size = UDim2.new(1, -20, 0, 150)
LogContainer.Position = UDim2.new(0, 10, 0, 322)
LogContainer.BackgroundColor3 = Theme.LogBg
LogContainer.BorderSizePixel = 0
LogContainer.ClipsDescendants = true
LogContainer.Parent = MainFrame

local lcCorner = Instance.new("UICorner")
lcCorner.CornerRadius = UDim.new(0, 4)
lcCorner.Parent = LogContainer

local lcStroke = Instance.new("UIStroke")
lcStroke.Color = Theme.Border
lcStroke.Thickness = 1
lcStroke.Parent = LogContainer

logScrollFrame = Instance.new("ScrollingFrame")
logScrollFrame.Name = "LogScroll"
logScrollFrame.Size = UDim2.new(1, -10, 1, -10)
logScrollFrame.Position = UDim2.new(0, 5, 0, 5)
logScrollFrame.BackgroundTransparency = 1
logScrollFrame.BorderSizePixel = 0
logScrollFrame.ScrollBarThickness = 2
logScrollFrame.ScrollBarImageColor3 = Theme.BorderBright
logScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScrollFrame.Parent = LogContainer

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logScrollFrame

local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "FooterFrame"
FooterFrame.Size = UDim2.new(1, -20, 0, 18)
FooterFrame.Position = UDim2.new(0, 10, 1, -22)
FooterFrame.BackgroundTransparency = 1
FooterFrame.Parent = MainFrame

local footerLbl = Instance.new("TextLabel")
footerLbl.Size = UDim2.new(1, 0, 1, 0)
footerLbl.BackgroundTransparency = 1
footerLbl.Text = "Credits: eikovo * scriptblox | Press C to Force Glue"
footerLbl.TextColor3 = Theme.TextSecondary
footerLbl.Font = Enum.Font.Gotham
footerLbl.TextSize = 9
footerLbl.TextXAlignment = Enum.TextXAlignment.Center
footerLbl.Parent = FooterFrame

addLog("INIT", "Spider Crawler v5 Bulletproof Engine Initialized", Theme.Green)

do
    local crawlEnabled = true
    local crawlSpeed = 26
    local crawlMode = "Spider"
    local crawlConn = nil
    local touchConn = nil

    local isGlued = false
    local gluedNormal = Vector3.new(0, 1, 0)
    local gluedSurfacePart = nil
    local gluedHitPoint = Vector3.zero

    local spiderAnimEnabled = true
    local proceduralConn = nil

    local activeBv = nil
    local activeBg = nil

    local keysDown = {W = false, A = false, S = false, D = false, Space = false}

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.W then keysDown.W = true end
        if inp.KeyCode == Enum.KeyCode.A then keysDown.A = true end
        if inp.KeyCode == Enum.KeyCode.S then keysDown.S = true end
        if inp.KeyCode == Enum.KeyCode.D then keysDown.D = true end
        if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = true end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.W then keysDown.W = false end
        if inp.KeyCode == Enum.KeyCode.A then keysDown.A = false end
        if inp.KeyCode == Enum.KeyCode.S then keysDown.S = false end
        if inp.KeyCode == Enum.KeyCode.D then keysDown.D = false end
        if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = false end
    end)

    local function stopSpiderMorph()
        if proceduralConn then
            proceduralConn:Disconnect()
            proceduralConn = nil
        end
    end

    local function startSpiderMorph()
        stopSpiderMorph()
        local char = getChar()
        local hum = getHum()
        if not char or not hum then return end

        local rigTypeName = hum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
        addLog("RIG", "Active Rig: " .. rigTypeName .. " | Procedural Spider Scuttle Engaged", Theme.Accent)

        local stepTime = 0
        proceduralConn = RunService.RenderStepped:Connect(function(dt)
            if not spiderAnimEnabled then return end
            local root = getRoot()
            local currentHum = getHum()
            local currentChar = getChar()
            if not root or not currentHum or not currentChar then return end

            local isMoving = (keysDown.W or keysDown.A or keysDown.S or keysDown.D) or currentHum.MoveDirection.Magnitude > 0.1
            if isMoving then
                stepTime = stepTime + dt * 16
            end

            local waist = currentChar:FindFirstChild("Waist", true)
            local leftHip = currentChar:FindFirstChild("LeftHip", true) or currentChar:FindFirstChild("Left Hip", true)
            local rightHip = currentChar:FindFirstChild("RightHip", true) or currentChar:FindFirstChild("Right Hip", true)
            local leftShoulder = currentChar:FindFirstChild("LeftShoulder", true) or currentChar:FindFirstChild("Left Shoulder", true)
            local rightShoulder = currentChar:FindFirstChild("RightShoulder", true) or currentChar:FindFirstChild("Right Shoulder", true)
            local leftKnee = currentChar:FindFirstChild("LeftKnee", true)
            local rightKnee = currentChar:FindFirstChild("RightKnee", true)
            local leftElbow = currentChar:FindFirstChild("LeftElbow", true)
            local rightElbow = currentChar:FindFirstChild("RightElbow", true)
            local rootJoint = root:FindFirstChild("RootJoint")

            local legCycle = isMoving and math.sin(stepTime) * 0.7 or 0
            local armCycle = isMoving and math.sin(stepTime + math.pi) * 0.7 or 0

            if waist and waist:IsA("Motor6D") then
                local forwardTilt = isGlued and -35 or -20
                waist.Transform = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(forwardTilt), math.sin(stepTime * 0.5) * 0.08, 0)
            end

            if rootJoint and rootJoint:IsA("Motor6D") and not waist then
                rootJoint.Transform = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(-25), 0, 0)
            end

            if leftHip and leftHip:IsA("Motor6D") then
                leftHip.Transform = CFrame.Angles(math.rad(50 + legCycle * 30), math.rad(-35), math.rad(25))
            end
            if rightHip and rightHip:IsA("Motor6D") then
                rightHip.Transform = CFrame.Angles(math.rad(50 - legCycle * 30), math.rad(35), math.rad(-25))
            end

            if leftShoulder and leftShoulder:IsA("Motor6D") then
                leftShoulder.Transform = CFrame.Angles(math.rad(55 + armCycle * 30), math.rad(-25), math.rad(30))
            end
            if rightShoulder and rightShoulder:IsA("Motor6D") then
                rightShoulder.Transform = CFrame.Angles(math.rad(55 - armCycle * 30), math.rad(25), math.rad(-30))
            end

            if leftKnee and leftKnee:IsA("Motor6D") then
                leftKnee.Transform = CFrame.Angles(math.rad(-40 - legCycle * 15), 0, 0)
            end
            if rightKnee and rightKnee:IsA("Motor6D") then
                rightKnee.Transform = CFrame.Angles(math.rad(-40 + legCycle * 15), 0, 0)
            end

            if leftElbow and leftElbow:IsA("Motor6D") then
                leftElbow.Transform = CFrame.Angles(math.rad(-40 - armCycle * 15), 0, 0)
            end
            if rightElbow and rightElbow:IsA("Motor6D") then
                rightElbow.Transform = CFrame.Angles(math.rad(-40 + armCycle * 15), 0, 0)
            end
        end)
    end

    local function releaseGlue()
        isGlued = false
        gluedSurfacePart = nil
        if activeBv then activeBv:Destroy() activeBv = nil end
        if activeBg then activeBg:Destroy() activeBg = nil end
        local hum = getHum()
        if hum then hum.PlatformStand = false end
    end

    local function engageWallGlue(hitPart, hitNormal, hitPoint)
        if isGlued then return end
        local root = getRoot()
        local hum = getHum()
        if not root or not hum then return end

        isGlued = true
        gluedNormal = hitNormal.Unit
        gluedSurfacePart = hitPart
        gluedHitPoint = hitPoint or (root.Position - hitNormal * 2)

        hum.PlatformStand = true

        if activeBv then activeBv:Destroy() end
        activeBv = Instance.new("BodyVelocity")
        activeBv.Name = "SpiderBodyVelocity"
        activeBv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
        activeBv.P = 15000
        activeBv.Velocity = Vector3.zero
        activeBv.Parent = root

        if activeBg then activeBg:Destroy() end
        activeBg = Instance.new("BodyGyro")
        activeBg.Name = "SpiderBodyGyro"
        activeBg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
        activeBg.P = 25000
        activeBg.D = 400

        local N = gluedNormal
        local wallUp = Vector3.new(0, 1, 0) - (Vector3.new(0, 1, 0):Dot(N) * N)
        if wallUp.Magnitude > 0.05 then
            wallUp = wallUp.Unit
        else
            wallUp = Vector3.new(0, 0, -1) - (Vector3.new(0, 0, -1):Dot(N) * N)
            wallUp = wallUp.Magnitude > 0.05 and wallUp.Unit or Vector3.new(1, 0, 0)
        end

        if crawlMode == "Spider" then
            activeBg.CFrame = CFrame.lookAt(root.Position, root.Position - N, wallUp)
        else
            activeBg.CFrame = CFrame.lookAt(root.Position, root.Position + wallUp, N)
        end
        activeBg.Parent = root

        addLog("GLUE", string.format("GLUED to %s | Normal: (%.1f, %.1f, %.1f)", hitPart.Name, N.X, N.Y, N.Z), Theme.Green)
        notify("Spider Crawl", "GLUED TO WALL! WASD to climb, Space to leap off.", 2.5, Theme.Green)
    end

    local function castRay(origin, dir, char)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = RaycastFilterType.Exclude
        params.IgnoreWater = true
        return workspace:Raycast(origin, dir, params)
    end

    local function findSurfaceRay(root, char)
        local rootPos = root.Position
        local hum = getHum()
        local moveDir = hum and hum.MoveDirection or Vector3.zero

        if moveDir.Magnitude > 0.1 then
            local fHit = castRay(rootPos, moveDir.Unit * 4.5, char)
            if fHit and fHit.Instance and fHit.Instance.CanCollide and math.abs(fHit.Normal.Y) < 0.75 then
                return fHit.Instance, fHit.Normal, fHit.Position
            end
        end

        local angles = {0, 45, 90, 135, 180, 225, 270, 315}
        for _, deg in ipairs(angles) do
            local rad = math.rad(deg)
            local dir = Vector3.new(math.cos(rad), 0, math.sin(rad)) * 4.5
            local hit = castRay(rootPos, dir, char)
            if hit and hit.Instance and hit.Instance.CanCollide and math.abs(hit.Normal.Y) < 0.75 then
                return hit.Instance, hit.Normal, hit.Position
            end
        end

        local hitUp = castRay(rootPos, Vector3.new(0, 4.5, 0), char)
        if hitUp and hitUp.Instance and hitUp.Instance.CanCollide and hitUp.Normal.Y < -0.6 then
            return hitUp.Instance, hitUp.Normal, hitUp.Position
        end

        return nil, nil, nil
    end

    local function manualForceGlue()
        local root = getRoot()
        local char = getChar()
        if not root or not char then return end

        local hitPart, hitNormal, hitPos = findSurfaceRay(root, char)
        if hitPart then
            engageWallGlue(hitPart, hitNormal, hitPos)
        else
            local look = Camera.CFrame.LookVector
            local fHit = castRay(root.Position, look * 16, char)
            if fHit and fHit.Instance and fHit.Instance.CanCollide then
                root.CFrame = CFrame.new(fHit.Position + fHit.Normal * 2)
                engageWallGlue(fHit.Instance, fHit.Normal, fHit.Position)
                addLog("FORCE", "Snapping to targeted surface: " .. fHit.Instance.Name, Theme.Green)
            else
                notify("Force Glue", "No wall in front of you. Get closer.", 2, Theme.Crimson)
                addLog("FORCE", "No wall within 16 studs", Theme.Crimson)
            end
        end
    end

    addButton("FORCE GLUE TO WALL NOW [ Press C ]", function()
        manualForceGlue()
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == Enum.KeyCode.C then
            manualForceGlue()
        end
    end)

    local function hookTouched(root)
        if touchConn then touchConn:Disconnect() touchConn = nil end
        touchConn = root.Touched:Connect(function(otherPart)
            if not crawlEnabled or isGlued then return end
            local char = getChar()
            if not otherPart or not otherPart.CanCollide or (char and otherPart:IsDescendantOf(char)) then return end

            local rootPos = root.Position
            local diff = otherPart.Position - rootPos
            local isFloor = diff.Y < -1.8 and math.abs(diff.X) < 1.5 and math.abs(diff.Z) < 1.5
            if isFloor then return end

            local rayDir = (otherPart.Position - rootPos)
            if rayDir.Magnitude > 0.01 then
                local test = castRay(rootPos, rayDir.Unit * 5, char)
                if test and test.Instance and math.abs(test.Normal.Y) < 0.75 then
                    engageWallGlue(test.Instance, test.Normal, test.Position)
                    return
                end
            end

            local hitPart, hitNormal, hitPos = findSurfaceRay(root, char)
            if hitPart then
                engageWallGlue(hitPart, hitNormal, hitPos)
            end
        end)
    end

    local function setupCharacterOnSpawn(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 6)
            local root = char:WaitForChild("HumanoidRootPart", 6)
            if not hum or not root then
                addLog("SPAWN", "Timed out waiting for Humanoid/RootPart", Theme.Crimson)
                return
            end

            releaseGlue()
            hookTouched(root)
            addLog("SPAWN", "Player spawned. Ready for surface contact.", Theme.Green)

            if spiderAnimEnabled then
                task.wait(0.3)
                startSpiderMorph()
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(setupCharacterOnSpawn)
    if LocalPlayer.Character then
        setupCharacterOnSpawn(LocalPlayer.Character)
    end

    local lastStatusTime = 0

    local function updateWallGlue(dt)
        if not crawlEnabled then return end
        local root = getRoot()
        local hum = getHum()
        local char = getChar()
        if not root or not hum or not char then return end

        if keysDown.Space and isGlued then
            local n = gluedNormal
            releaseGlue()
            root.AssemblyLinearVelocity = n * 55 + Vector3.new(0, 32, 0)
            addLog("GLUE", "Space pressed: leaped off wall", Theme.Accent)
            task.wait(0.3)
            return
        end

        if not isGlued then
            local hitPart, hitNormal, hitPos = findSurfaceRay(root, char)
            if hitPart then
                engageWallGlue(hitPart, hitNormal, hitPos)
            end
        end

        if isGlued and activeBv and activeBv.Parent and activeBg and activeBg.Parent then
            hum.PlatformStand = true

            local testRay = castRay(root.Position + gluedNormal * 1, -gluedNormal * 6, char)
            if testRay and testRay.Instance and testRay.Instance.CanCollide then
                gluedNormal = testRay.Normal
                gluedSurfacePart = testRay.Instance
                gluedHitPoint = testRay.Position
            else
                local altPart, altNormal, altPos = findSurfaceRay(root, char)
                if altPart then
                    gluedNormal = altNormal
                    gluedSurfacePart = altPart
                    gluedHitPoint = altPos
                else
                    releaseGlue()
                    addLog("GLUE", "Detached from surface (end of wall)", Theme.Crimson)
                    return
                end
            end

            local N = gluedNormal
            local wallUp = Vector3.new(0, 1, 0) - (Vector3.new(0, 1, 0):Dot(N) * N)
            local wallRight = Vector3.zero

            if wallUp.Magnitude > 0.05 then
                wallUp = wallUp.Unit
                wallRight = wallUp:Cross(N).Unit
            else
                local camLook = Camera.CFrame.LookVector
                wallUp = camLook - (camLook:Dot(N) * N)
                if wallUp.Magnitude > 0.05 then
                    wallUp = wallUp.Unit
                else
                    wallUp = Vector3.new(0, 0, -1) - (Vector3.new(0, 0, -1):Dot(N) * N)
                    wallUp = wallUp.Magnitude > 0.05 and wallUp.Unit or Vector3.new(1, 0, 0)
                end
                wallRight = wallUp:Cross(N).Unit
            end

            local moveDir = Vector3.zero
            if keysDown.W then moveDir = moveDir + wallUp end
            if keysDown.S then moveDir = moveDir - wallUp end
            if keysDown.D then moveDir = moveDir + wallRight end
            if keysDown.A then moveDir = moveDir - wallRight end

            local targetDist = (crawlMode == "Spider") and 1.6 or 2.2
            local currentDist = (root.Position - gluedHitPoint):Dot(N)
            local distCorrection = math.clamp(targetDist - currentDist, -4, 4) * 8

            local targetVelocity = N * distCorrection
            if moveDir.Magnitude > 0.1 then
                targetVelocity = targetVelocity + moveDir.Unit * crawlSpeed
            end

            activeBv.Velocity = targetVelocity

            local facing = moveDir.Magnitude > 0.1 and moveDir.Unit or wallUp
            if crawlMode == "Spider" then
                activeBg.CFrame = CFrame.lookAt(root.Position, root.Position - N, facing)
            else
                activeBg.CFrame = CFrame.lookAt(root.Position, root.Position + facing, N)
            end

            if os.clock() - lastStatusTime > 4 then
                lastStatusTime = os.clock()
                addLog("STATUS", string.format("Glued: %s | Normal Y: %.2f", gluedSurfacePart and gluedSurfacePart.Name or "Surface", N.Y), Theme.AccentDim)
            end
        end
    end

    addToggle("Enable Wall Crawl", true, function(v)
        crawlEnabled = v
        if crawlConn then crawlConn:Disconnect() crawlConn = nil end
        if v then
            crawlConn = RunService.Heartbeat:Connect(updateWallGlue)
            startSpiderMorph()
            addLog("TOGGLE", "Spider Wall Crawl ENABLED", Theme.Green)
            notify("Spider Crawl", "Active! Touch wall or press C to glue.", 2.5, Theme.Green)
        else
            releaseGlue()
            stopSpiderMorph()
            addLog("TOGGLE", "Spider Wall Crawl DISABLED", Theme.TextSecondary)
            notify("Spider Crawl", "Disabled.", 1.5, Theme.TextSecondary)
        end
    end)

    crawlConn = RunService.Heartbeat:Connect(updateWallGlue)

    addToggle("Mode: Spider Belly Crawl / Magnetic Feet", true, function(v)
        crawlMode = v and "Spider" or "Magnetic"
        addLog("MODE", "Crawl Mode switched to: " .. crawlMode, Theme.Accent)
    end)

    addSlider("Crawl Speed", 16, 75, 26, function(val)
        crawlSpeed = val
    end)

    addToggle("Procedural Spider Scuttle Morph", true, function(v)
        spiderAnimEnabled = v
        if v then
            startSpiderMorph()
        else
            stopSpiderMorph()
        end
    end)
end

do
    local discordCard = Instance.new("Frame")
    discordCard.Size = UDim2.new(1, 0, 0, 48)
    discordCard.BackgroundColor3 = Theme.CardBg
    discordCard.BorderSizePixel = 0
    discordCard.Parent = ControlsHolder

    local dcCorner = Instance.new("UICorner")
    dcCorner.CornerRadius = UDim.new(0, 4)
    dcCorner.Parent = discordCard

    local dcStroke = Instance.new("UIStroke")
    dcStroke.Color = Theme.Border
    dcStroke.Thickness = 1
    dcStroke.Parent = discordCard

    local copyDiscordBtn = Instance.new("TextButton")
    copyDiscordBtn.Size = UDim2.new(1, -12, 0, 22)
    copyDiscordBtn.Position = UDim2.new(0, 6, 0, 4)
    copyDiscordBtn.BackgroundColor3 = Theme.Purple
    copyDiscordBtn.Text = "COPY DISCORD INVITE LINK"
    copyDiscordBtn.TextColor3 = Theme.Accent
    copyDiscordBtn.Font = Enum.Font.GothamBold
    copyDiscordBtn.TextSize = 10
    copyDiscordBtn.BorderSizePixel = 0
    copyDiscordBtn.Parent = discordCard

    local cdbCorner = Instance.new("UICorner")
    cdbCorner.CornerRadius = UDim.new(0, 3)
    cdbCorner.Parent = copyDiscordBtn

    local discordBox = Instance.new("TextBox")
    discordBox.Size = UDim2.new(1, -12, 0, 16)
    discordBox.Position = UDim2.new(0, 6, 0, 28)
    discordBox.BackgroundColor3 = Theme.Header
    discordBox.BorderSizePixel = 0
    discordBox.Text = "https://discord.gg/P7fuzYj5xK"
    discordBox.TextColor3 = Theme.AccentDim
    discordBox.Font = Enum.Font.Gotham
    discordBox.TextSize = 9
    discordBox.ClearTextOnFocus = false
    discordBox.TextEditable = false
    discordBox.Parent = discordCard

    local dxbCorner = Instance.new("UICorner")
    dxbCorner.CornerRadius = UDim.new(0, 3)
    dxbCorner.Parent = discordBox

    copyDiscordBtn.MouseButton1Click:Connect(function()
        local ok = copyToClipboard("https://discord.gg/P7fuzYj5xK")
        discordBox:CaptureFocus()
        if ok then
            copyDiscordBtn.Text = "COPIED TO CLIPBOARD!"
            addLog("CLIPBOARD", "Copied discord.gg/P7fuzYj5xK to clipboard", Theme.Purple)
            notify("Discord", "Copied to clipboard!", 2.5, Theme.Purple)
            task.delay(2.5, function()
                copyDiscordBtn.Text = "COPY DISCORD INVITE LINK"
            end)
        else
            notify("Discord", "Select & Ctrl+C to copy box below!", 3, Theme.Purple)
        end
    end)
end
