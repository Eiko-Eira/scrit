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

local logEntries = {}
local maxLogEntries = 120
local logScrollFrame = nil
local logLayout = nil

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
MainFrame.Size = UDim2.new(0, 420, 0, 450)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -225)
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
titleLabel.Text = "SPIDER CRAWLER"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 160, 1, 0)
subtitleLabel.Position = UDim2.new(0, 160, 0, 0)
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
        tw(MainFrame, {Size = UDim2.new(0, 420, 0, 450), BackgroundTransparency = 0}, 0.2)
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
ControlsHolder.Size = UDim2.new(1, -20, 0, 185)
ControlsHolder.Position = UDim2.new(0, 10, 0, 46)
ControlsHolder.BackgroundTransparency = 1
ControlsHolder.Parent = MainFrame

local cLayout = Instance.new("UIListLayout")
cLayout.SortOrder = Enum.SortOrder.LayoutOrder
cLayout.Padding = UDim.new(0, 5)
cLayout.Parent = ControlsHolder

local function addToggle(label, default, cb)
    local state = default or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 30)
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
    container.Size = UDim2.new(1, 0, 0, 42)
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
    lbl.Position = UDim2.new(0, 10, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.TextPrimary
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 16)
    valLbl.Position = UDim2.new(1, -58, 0, 3)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.TextColor3 = Theme.AccentDim
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -20, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 0, 24)
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

local function addButton(label, cb, customParent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Theme.CardBg
    btn.Text = label
    btn.TextColor3 = Theme.TextPrimary
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = customParent or ControlsHolder

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
LogHeaderFrame.Position = UDim2.new(0, 10, 0, 235)
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
    if setclipboard then
        setclipboard(fullText)
        notify("Clipboard", "All logs copied! Paste in chat or notes.", 2.5, Theme.Green)
    else
        notify("Clipboard", "setclipboard not supported by executor.", 3, Theme.Crimson)
    end
end)

local LogContainer = Instance.new("Frame")
LogContainer.Name = "LogContainer"
LogContainer.Size = UDim2.new(1, -20, 0, 160)
LogContainer.Position = UDim2.new(0, 10, 0, 262)
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

logLayout = Instance.new("UIListLayout")
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
footerLbl.Text = "Credits: eikovo * scriptblox | discord.gg/P7fuzYj5xK"
footerLbl.TextColor3 = Theme.TextSecondary
footerLbl.Font = Enum.Font.Gotham
footerLbl.TextSize = 9
footerLbl.TextXAlignment = Enum.TextXAlignment.Center
footerLbl.Parent = FooterFrame

addLog("INIT", "Spider Crawler v2 initialized with Live Log System", Theme.Green)

do
    local crawlEnabled = true
    local crawlSpeed = 28
    local crawlConn = nil

    local isGlued = false
    local gluedNormal = Vector3.new(0, 1, 0)
    local gluedPosition = Vector3.zero
    local facingDirection = Vector3.new(0, 0, -1)
    local glueAttachPart = nil

    local spiderAnimEnabled = true
    local activeTracks = {}
    local proceduralConn = nil

    local spiderAssetIds = {
        walk  = "rbxassetid://138735759009918",
        idle  = "rbxassetid://118964620679772",
        run   = "rbxassetid://86134191283674",
        fall  = "rbxassetid://133605321342133",
        climb = "rbxassetid://100046056368355",
        jump  = "rbxassetid://81019769325329",
    }
    local fallbackSpiderAnim = "rbxassetid://1083218792"

    local function stopSpiderAnims()
        for _, trk in ipairs(activeTracks) do
            pcall(function() trk:Stop(0.1) end)
        end
        activeTracks = {}
        if proceduralConn then
            proceduralConn:Disconnect()
            proceduralConn = nil
        end
    end

    local function applySpiderAnims()
        stopSpiderAnims()
        local char = getChar()
        local hum = getHum()
        if not char or not hum then
            addLog("ANIM", "Character or Humanoid missing during anim apply", Theme.Crimson)
            return
        end

        local rigTypeName = hum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
        addLog("RIG", "Current Character RigType: " .. rigTypeName, Theme.Accent)

        local animate = char:FindFirstChild("Animate")
        if animate then
            local count = 0
            local function swapCategory(catName, animId)
                local cat = animate:FindFirstChild(catName)
                if cat then
                    for _, child in ipairs(cat:GetChildren()) do
                        if child:IsA("Animation") then
                            child.AnimationId = animId
                            count = count + 1
                        end
                    end
                end
            end
            swapCategory("walk", spiderAssetIds.walk)
            swapCategory("run", spiderAssetIds.run)
            swapCategory("idle", spiderAssetIds.idle)
            swapCategory("climb", spiderAssetIds.climb)
            swapCategory("jump", spiderAssetIds.jump)
            swapCategory("fall", spiderAssetIds.fall)
            addLog("ANIM", string.format("Swapped %d animations in Animate script to Spider pack", count), Theme.Green)
        else
            addLog("ANIM", "No Animate script found in character", Theme.TextSecondary)
        end

        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
            addLog("ANIM", "Created new Animator inside Humanoid", Theme.Accent)
        end

        local animObj = Instance.new("Animation")
        animObj.AnimationId = spiderAssetIds.walk

        local ok, track = pcall(function()
            return animator:LoadAnimation(animObj)
        end)

        if ok and track then
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            track:Play(0.15)
            table.insert(activeTracks, track)
            addLog("ANIM", "Loaded official Spider Walk animation (138735759009918)", Theme.Green)
        else
            addLog("ANIM", "Official Spider Walk failed, trying fallback crawl...", Theme.Crimson)
            animObj.AnimationId = fallbackSpiderAnim
            local fOk, fTrack = pcall(function()
                return animator:LoadAnimation(animObj)
            end)
            if fOk and fTrack then
                fTrack.Priority = Enum.AnimationPriority.Action4
                fTrack.Looped = true
                fTrack:Play(0.15)
                table.insert(activeTracks, fTrack)
                addLog("ANIM", "Loaded fallback spider crawl animation", Theme.Green)
            else
                addLog("ANIM", "Fallback animation also failed; engaging procedural morph only", Theme.Crimson)
            end
        end

        local stepTime = 0
        proceduralConn = RunService.Stepped:Connect(function(t, dt)
            if not spiderAnimEnabled then return end
            stepTime = stepTime + dt * 10
            local root = getRoot()
            if not root then return end

            local lowerTorso = char:FindFirstChild("LowerTorso")
            local torso = char:FindFirstChild("Torso")

            if lowerTorso then
                local waist = lowerTorso:FindFirstChild("Waist")
                if waist and waist:IsA("Motor6D") then
                    waist.Transform = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(-35), math.sin(stepTime) * 0.08, 0)
                end
                local leftUpperLeg = char:FindFirstChild("LeftUpperLeg")
                local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
                local leftHip = leftUpperLeg and leftUpperLeg:FindFirstChild("LeftHip")
                local rightHip = rightUpperLeg and rightUpperLeg:FindFirstChild("RightHip")
                if leftHip and leftHip:IsA("Motor6D") then
                    leftHip.Transform = CFrame.Angles(math.rad(50), math.rad(-40), math.sin(stepTime) * 0.45)
                end
                if rightHip and rightHip:IsA("Motor6D") then
                    rightHip.Transform = CFrame.Angles(math.rad(50), math.rad(40), -math.sin(stepTime) * 0.45)
                end
                local leftUpperArm = char:FindFirstChild("LeftUpperArm")
                local rightUpperArm = char:FindFirstChild("RightUpperArm")
                local leftShoulder = leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder")
                local rightShoulder = rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder")
                if leftShoulder and leftShoulder:IsA("Motor6D") then
                    leftShoulder.Transform = CFrame.Angles(math.rad(50), math.rad(-30), -math.sin(stepTime) * 0.45)
                end
                if rightShoulder and rightShoulder:IsA("Motor6D") then
                    rightShoulder.Transform = CFrame.Angles(math.rad(50), math.rad(30), math.sin(stepTime) * 0.45)
                end
            elseif torso then
                local rootJoint = root:FindFirstChild("RootJoint")
                if rootJoint and rootJoint:IsA("Motor6D") then
                    rootJoint.Transform = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(-35), 0, 0)
                end
                local leftHip = torso:FindFirstChild("Left Hip")
                local rightHip = torso:FindFirstChild("Right Hip")
                if leftHip and leftHip:IsA("Motor6D") then
                    leftHip.Transform = CFrame.Angles(math.rad(45), math.rad(-35), math.sin(stepTime) * 0.4)
                end
                if rightHip and rightHip:IsA("Motor6D") then
                    rightHip.Transform = CFrame.Angles(math.rad(45), math.rad(35), -math.sin(stepTime) * 0.4)
                end
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

            isGlued = false
            hum.PlatformStand = false
            addLog("SPAWN", "Player spawned. Ready for surface contact.", Theme.Green)

            if spiderAnimEnabled then
                task.wait(0.5)
                applySpiderAnims()
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(setupCharacterOnSpawn)
    if LocalPlayer.Character then
        setupCharacterOnSpawn(LocalPlayer.Character)
    end

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

    local function castRay(origin, dir, char)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = RaycastFilterType.Exclude
        return workspace:Raycast(origin, dir, params)
    end

    local function scanSurroundingWalls(rootPos, char)
        local rayDist = 6.0
        local angles = {0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330}
        for _, deg in ipairs(angles) do
            local rad = math.rad(deg)
            local dir = Vector3.new(math.cos(rad), 0, math.sin(rad)) * rayDist
            local hit = castRay(rootPos, dir, char)
            if hit and hit.Instance and hit.Instance.CanCollide and math.abs(hit.Normal.Y) < 0.85 then
                return hit
            end
        end
        local hitUp = castRay(rootPos, Vector3.new(0, rayDist, 0), char)
        if hitUp and hitUp.Instance and hitUp.Instance.CanCollide and hitUp.Normal.Y < -0.6 then
            return hitUp
        end
        return nil
    end

    local lastLogTime = 0

    local function updateWallGlue(dt)
        if not crawlEnabled then return end
        local root = getRoot()
        local hum = getHum()
        local char = getChar()
        if not root or not hum or not char then return end

        if keysDown.Space and isGlued then
            local n = gluedNormal
            isGlued = false
            hum.PlatformStand = false
            root.CFrame = root.CFrame + n * 3.5
            root.AssemblyLinearVelocity = n * 55 + Vector3.new(0, 25, 0)
            addLog("GLUE", "Space pressed: detached from wall", Theme.Accent)
            task.wait(0.3)
            return
        end

        if not isGlued then
            local rootPos = root.Position
            local moveDir = hum.MoveDirection
            local forwardHit = nil
            if moveDir.Magnitude > 0.1 then
                forwardHit = castRay(rootPos, moveDir.Unit * 5.2, char)
            end
            local hit = forwardHit or scanSurroundingWalls(rootPos, char)
            if hit and hit.Instance and hit.Instance.CanCollide then
                isGlued = true
                gluedNormal = hit.Normal
                gluedPosition = hit.Position
                glueAttachPart = hit.Instance
                facingDirection = (gluedNormal:Cross(Vector3.new(0, 1, 0))).Magnitude > 0.1 and Vector3.new(0, 1, 0) or Camera.CFrame.LookVector
                hum.PlatformStand = true
                addLog("GLUE", string.format("GLUED to %s | Normal: (%.1f, %.1f, %.1f)", hit.Instance.Name, hit.Normal.X, hit.Normal.Y, hit.Normal.Z), Theme.Green)
                notify("Spider Crawl", "GLUED to surface! WASD to climb, Space to jump off.", 2, Theme.Green)
            end
        end

        if isGlued then
            hum.PlatformStand = true

            local testRay = castRay(gluedPosition + gluedNormal * 3, -gluedNormal * 6, char)
            if testRay and testRay.Instance and testRay.Instance.CanCollide then
                gluedNormal = testRay.Normal
                gluedPosition = testRay.Position
                glueAttachPart = testRay.Instance
            else
                local cornerHit = scanSurroundingWalls(root.Position, char)
                if cornerHit then
                    gluedNormal = cornerHit.Normal
                    gluedPosition = cornerHit.Position
                    glueAttachPart = cornerHit.Instance
                else
                    isGlued = false
                    hum.PlatformStand = false
                    addLog("GLUE", "No adjacent wall found; unglued from surface", Theme.Crimson)
                    return
                end
            end

            local N = gluedNormal
            local wallUp = Vector3.new(0, 1, 0) - (Vector3.new(0, 1, 0):Dot(N) * N)
            local wallRight = Vector3.zero

            if wallUp.Magnitude > 0.1 then
                wallUp = wallUp.Unit
                wallRight = wallUp:Cross(N).Unit
            else
                local camLook = Camera.CFrame.LookVector
                wallUp = (camLook - camLook:Dot(N) * N).Unit
                wallRight = (Camera.CFrame.RightVector - Camera.CFrame.RightVector:Dot(N) * N).Unit
            end

            local moveInput = Vector3.zero
            if keysDown.W then moveInput = moveInput + wallUp end
            if keysDown.S then moveInput = moveInput - wallUp end
            if keysDown.D then moveInput = moveInput + wallRight end
            if keysDown.A then moveInput = moveInput - wallRight end

            if moveInput.Magnitude > 0.1 then
                local step = moveInput.Unit * (crawlSpeed * dt)
                gluedPosition = gluedPosition + step
                facingDirection = moveInput.Unit
            end

            local stickPos = gluedPosition + N * 2.2
            local lookTarget = stickPos + facingDirection
            root.CFrame = CFrame.lookAt(stickPos, lookTarget, N)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

            if os.clock() - lastLogTime > 3 then
                lastLogTime = os.clock()
                addLog("STATUS", string.format("Glued on %s | Normal Y: %.2f", glueAttachPart and glueAttachPart.Name or "Surface", N.Y), Theme.AccentDim)
            end
        end
    end

    addToggle("Enable Spider Wall Crawl", true, function(v)
        crawlEnabled = v
        if crawlConn then crawlConn:Disconnect() crawlConn = nil end
        if v then
            crawlConn = RunService.Heartbeat:Connect(updateWallGlue)
            applySpiderAnims()
            addLog("TOGGLE", "Spider Wall Crawl ENABLED", Theme.Green)
            notify("Spider Crawl", "Active! Walk into any wall or ceiling to glue.", 2.5, Theme.Green)
        else
            isGlued = false
            local hum = getHum()
            if hum then hum.PlatformStand = false end
            stopSpiderAnims()
            addLog("TOGGLE", "Spider Wall Crawl DISABLED", Theme.TextSecondary)
            notify("Spider Crawl", "Disabled.", 1.5, Theme.TextSecondary)
        end
    end)

    crawlConn = RunService.Heartbeat:Connect(updateWallGlue)

    addSlider("Crawl Speed", 16, 75, 28, function(val)
        crawlSpeed = val
    end)

    addToggle("Spider Animation Pack (Bundle 278347659293508)", true, function(v)
        spiderAnimEnabled = v
        if v then
            applySpiderAnims()
        else
            stopSpiderAnims()
        end
    end)
end

addButton("Discord (discord.gg/P7fuzYj5xK)", function()
    if setclipboard then
        setclipboard("https://discord.gg/P7fuzYj5xK")
        notify("Discord", "Copied discord.gg/P7fuzYj5xK!", 2, Theme.Purple)
    else
        notify("Discord", "discord.gg/P7fuzYj5xK", 3, Theme.Purple)
    end
end)
