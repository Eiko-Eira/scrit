local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local Camera = workspace.CurrentCamera

local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local coreGui = game:GetService("CoreGui")
    local ok = pcall(function() return coreGui.Name end)
    if ok then
        local canParent = pcall(function()
            local t = Instance.new("Folder")
            t.Parent = coreGui
            t:Destroy()
        end)
        if canParent then return coreGui end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local targetGuiParent = getGuiParent()

do
    local old = targetGuiParent:FindFirstChild("AikDebrisUI")
    if old then old:Destroy() end
    local oldP = LocalPlayer:FindFirstChild("PlayerGui")
    if oldP then
        local old2 = oldP:FindFirstChild("AikDebrisUI")
        if old2 then old2:Destroy() end
    end
end

local Theme = {
    Background    = Color3.fromRGB(10, 10, 12),
    Header        = Color3.fromRGB(16, 16, 20),
    CardBg        = Color3.fromRGB(20, 20, 26),
    CardHover     = Color3.fromRGB(28, 28, 36),
    CardActive    = Color3.fromRGB(38, 38, 48),
    TextPrimary   = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Accent        = Color3.fromRGB(255, 255, 255),
    AccentDim     = Color3.fromRGB(180, 180, 180),
    Border        = Color3.fromRGB(38, 38, 48),
    BorderBright  = Color3.fromRGB(75, 75, 90),
    Crimson       = Color3.fromRGB(235, 50, 65),
    Green         = Color3.fromRGB(80, 220, 120),
    Purple        = Color3.fromRGB(160, 90, 240),
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

local function copyToClipboard(text)
    local copied = false
    if setclipboard then
        local ok = pcall(setclipboard, text)
        if ok then copied = true end
    end
    if not copied and toclipboard then
        local ok = pcall(toclipboard, text)
        if ok then copied = true end
    end
    if not copied and set_clipboard then
        local ok = pcall(set_clipboard, text)
        if ok then copied = true end
    end
    if not copied and syn and syn.write_clipboard then
        local ok = pcall(syn.write_clipboard, text)
        if ok then copied = true end
    end
    if not copied and Clipboard and Clipboard.set then
        local ok = pcall(Clipboard.set, text)
        if ok then copied = true end
    end
    return copied
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikDebrisUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = targetGuiParent

local ToastHolder = Instance.new("Frame")
ToastHolder.Name = "ToastHolder"
ToastHolder.Size = UDim2.new(0, 260, 0, 70)
ToastHolder.Position = UDim2.new(1, -274, 0, 16)
ToastHolder.BackgroundTransparency = 1
ToastHolder.ZIndex = 500
ToastHolder.Parent = ScreenGui

local function notify(title, desc, duration, col)
    duration = duration or 2.5
    col = col or Theme.Crimson

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Theme.Header
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = 500
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
    bar.ZIndex = 501
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
    tLbl.ZIndex = 502
    tLbl.Active = false
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(1, -20, 0, 16)
    dLbl.Position = UDim2.new(0, 12, 0, 20)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = Theme.TextSecondary
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 9
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.ZIndex = 502
    dLbl.Active = false
    dLbl.Parent = card

    card.Position = UDim2.new(1, 20, 0, 0)
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.2).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MiniToggleChip = Instance.new("TextButton")
MiniToggleChip.Name = "MiniToggleChip"
MiniToggleChip.Size = UDim2.new(0, 110, 0, 28)
MiniToggleChip.Position = UDim2.new(0, 16, 0.5, -14)
MiniToggleChip.BackgroundColor3 = Theme.Header
MiniToggleChip.BorderSizePixel = 0
MiniToggleChip.Text = "DEBRIS ORBIT"
MiniToggleChip.TextColor3 = Theme.TextPrimary
MiniToggleChip.Font = Enum.Font.GothamBold
MiniToggleChip.TextSize = 10
MiniToggleChip.ZIndex = 200
MiniToggleChip.Active = true
MiniToggleChip.AutoButtonColor = false
MiniToggleChip.Parent = ScreenGui

local mtcCorner = Instance.new("UICorner")
mtcCorner.CornerRadius = UDim.new(0, 6)
mtcCorner.Parent = MiniToggleChip

local mtcStroke = Instance.new("UIStroke")
mtcStroke.Color = Theme.Border
mtcStroke.Thickness = 1
mtcStroke.Parent = MiniToggleChip

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 390, 0, 480)
MainFrame.Position = UDim2.new(0.5, -195, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
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

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11
TopBar.Parent = MainFrame

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Theme.Border
tbStroke.Thickness = 1
tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tbStroke.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 190, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEBRIS ORBIT & LAUNCHER"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12
titleLabel.Active = false
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 140, 1, 0)
subtitleLabel.Position = UDim2.new(0, 192, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "v4 * Instant Teleport"
subtitleLabel.TextColor3 = Theme.Crimson
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 9
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 12
subtitleLabel.Active = false
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
closeBtn.ZIndex = 12
closeBtn.Active = true
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 4)
cbCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Crimson, TextColor3 = Theme.Accent}, 0.12) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.CardBg, TextColor3 = Theme.TextSecondary}, 0.12) end)

local isDragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = inp.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if isDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

local isVisible = true
local function setVisible(v)
    isVisible = v
    if v then
        MainFrame.Visible = true
        tw(MainFrame, {BackgroundTransparency = 0}, 0.18)
    else
        tw(MainFrame, {BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
end

closeBtn.Activated:Connect(function() setVisible(false) end)
MiniToggleChip.Activated:Connect(function() setVisible(not isVisible) end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -48)
Content.Position = UDim2.new(0, 8, 0, 44)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.BorderBright
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 11
Content.Parent = MainFrame

local cPad = Instance.new("UIPadding")
cPad.PaddingRight = UDim.new(0, 6)
cPad.PaddingTop = UDim.new(0, 2)
cPad.PaddingBottom = UDim.new(0, 6)
cPad.Parent = Content

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 5)
contentLayout.Parent = Content

local function addToggle(label, default, cb)
    local state = default or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = Theme.CardBg
    row.Text = ""
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Active = true
    row.AutoButtonColor = false
    row.Parent = Content

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
    lbl.ZIndex = 13
    lbl.Active = false
    lbl.Parent = row

    local swTrack = Instance.new("Frame")
    swTrack.Size = UDim2.new(0, 30, 0, 16)
    swTrack.Position = UDim2.new(1, -40, 0.5, -8)
    swTrack.BackgroundColor3 = state and Theme.Crimson or Theme.Header
    swTrack.BorderSizePixel = 0
    swTrack.ZIndex = 13
    swTrack.Active = false
    swTrack.Parent = row

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = swTrack

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Active = false
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

    local lastClick = 0
    row.Activated:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.1 then return end
        lastClick = now
        setToggle(not state)
    end)

    return setToggle
end

local function addSlider(label, minV, maxV, defaultV, cb)
    local val = defaultV or minV
    minV = minV or 100
    maxV = maxV or 1000

    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = Theme.CardBg
    container.Text = ""
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Active = true
    container.AutoButtonColor = false
    container.Parent = Content

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
    lbl.ZIndex = 13
    lbl.Active = false
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 16)
    valLbl.Position = UDim2.new(1, -58, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.TextColor3 = Theme.Crimson
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 13
    valLbl.Active = false
    valLbl.Parent = container

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -20, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 0, 22)
    trackBg.BackgroundColor3 = Theme.Header
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = 13
    trackBg.Active = false
    trackBg.Parent = container

    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(1, 0)
    trCorner.Parent = trackBg

    local fillBar = Instance.new("Frame")
    local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
    fillBar.Size = UDim2.new(initRatio, 0, 1, 0)
    fillBar.BackgroundColor3 = Theme.Crimson
    fillBar.BorderSizePixel = 0
    fillBar.ZIndex = 14
    fillBar.Active = false
    fillBar.Parent = trackBg

    local fbCorner = Instance.new("UICorner")
    fbCorner.CornerRadius = UDim.new(1, 0)
    fbCorner.Parent = fillBar

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 13, 0, 13)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(initRatio, 0, 0.5, 0)
    handle.BackgroundColor3 = Theme.Crimson
    handle.BorderSizePixel = 0
    handle.ZIndex = 15
    handle.Active = false
    handle.Parent = trackBg

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = handle

    local sliding = false

    local function applySlide(inputX)
        local trackAbsPos = trackBg.AbsolutePosition.X
        local trackWidth = trackBg.AbsoluteSize.X
        local r = math.clamp((inputX - trackAbsPos) / trackWidth, 0, 1)
        val = math.round(minV + (maxV - minV) * r)
        valLbl.Text = tostring(val)
        fillBar.Size = UDim2.new(r, 0, 1, 0)
        handle.Position = UDim2.new(r, 0, 0.5, 0)
        if cb then task.spawn(cb, val) end
    end

    container.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            applySlide(inp.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            applySlide(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
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
    btn.ZIndex = 12
    btn.Active = true
    btn.AutoButtonColor = false
    btn.Parent = Content

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

    local lastClick = 0
    btn.Activated:Connect(function()
        local now = os.clock()
        if now - lastClick < 0.1 then return end
        lastClick = now
        tw(btn, {BackgroundColor3 = Theme.CardActive}, 0.05)
        task.delay(0.08, function()
            tw(btn, {BackgroundColor3 = Theme.CardHover}, 0.08)
        end)
        if cb then task.spawn(cb) end
    end)
    return btn
end

do
    local orbitEnabled = false
    local orbitRadius = 14
    local orbitHeight = 2.0
    local orbitSpeed = 4.0
    local scanRange = 300
    local maxParts = 60
    local launchSpeed = 600
    local autoReturnEnabled = true
    local returnDelay = 3

    local orbitConn = nil
    local scannerThread = nil
    local activeParts = {}
    local firedCooldown = {}
    local orbitAngle = 0

    local function boostSimulation()
        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", 1e5) end)
        pcall(function() sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 1e5) end)
        pcall(function() LocalPlayer.MaximumSimulationRadius = 1e5 end)
        pcall(function() LocalPlayer.SimulationRadius = 1e5 end)
        pcall(function() settings().Physics.AllowSleep = false end)
    end

    local function isPartFired(part)
        local expiry = firedCooldown[part]
        if expiry then
            if os.clock() < expiry then
                return true
            else
                firedCooldown[part] = nil
            end
        end
        return false
    end

    local function cleanFiredCooldown()
        local now = os.clock()
        for part, expiry in pairs(firedCooldown) do
            if now >= expiry or not part.Parent then
                firedCooldown[part] = nil
            end
        end
    end

    local function freePart(part)
        pcall(function()
            for _, joint in ipairs(part:GetJoints()) do
                if joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("ManualWeld") or joint:IsA("Snap") or joint:IsA("Motor6D") then
                    joint:Destroy()
                end
            end
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("WeldConstraint") or child:IsA("Weld") or child:IsA("ManualWeld") or child:IsA("Motor6D") then
                    child:Destroy()
                end
            end
        end)
    end

    local function scanDebrisParts()
        local parts = {}
        local root = getRoot()
        local char = getChar()
        if not root or not char then return parts end

        local rootPos = root.Position
        local playersList = Players:GetPlayers()

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                if not isPartFired(obj) then
                    local isCharacterPart = false
                    for _, p in ipairs(playersList) do
                        if p.Character and obj:IsDescendantOf(p.Character) then
                            isCharacterPart = true
                            break
                        end
                    end
                    if not isCharacterPart then
                        local dist = (obj.Position - rootPos).Magnitude
                        if dist <= scanRange then
                            freePart(obj)
                            table.insert(parts, obj)
                            if #parts >= maxParts then
                                break
                            end
                        end
                    end
                end
            end
        end
        return parts
    end

    local function teleportPartToSlot(part, idx, totalCount, rootPos)
        local angle = orbitAngle + (idx / totalCount) * math.pi * 2
        local wave = math.sin(orbitAngle * 2.0 + idx) * 2.0
        local offset = Vector3.new(math.cos(angle) * orbitRadius, orbitHeight + wave, math.sin(angle) * orbitRadius)
        local targetPos = rootPos + offset
        local spinCF = CFrame.Angles(orbitAngle * 1.5 + idx, orbitAngle * 2.2, 0)

        part.CanCollide = false
        part.CFrame = CFrame.new(targetPos) * spinCF

        local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
        part.AssemblyLinearVelocity = tangent * (orbitRadius * 6)
        part.AssemblyAngularVelocity = Vector3.new(0, 80, 0)
    end

    local function updateOrbit(dt)
        if not orbitEnabled then return end
        local root = getRoot()
        if not root then return end

        orbitAngle = orbitAngle + dt * orbitSpeed
        boostSimulation()
        cleanFiredCooldown()

        local validParts = {}
        for _, p in ipairs(activeParts) do
            if p and p.Parent and not p.Anchored and not isPartFired(p) then
                table.insert(validParts, p)
            end
        end
        activeParts = validParts

        local count = #activeParts
        if count == 0 then return end

        local rootPos = root.Position
        for idx, part in ipairs(activeParts) do
            teleportPartToSlot(part, idx, count, rootPos)
        end
    end

    local lastSingleFireTime = 0

    local function launchSingleDebris()
        local now = os.clock()
        if now - lastSingleFireTime < 0.08 then return end
        lastSingleFireTime = now

        local root = getRoot()
        if not root then return end

        local targetPart = nil
        while #activeParts > 0 and not targetPart do
            local candidate = table.remove(activeParts, 1)
            if candidate and candidate.Parent and not candidate.Anchored then
                targetPart = candidate
            end
        end

        if not targetPart then
            notify("Launcher", "No debris in orbit! Wait for nearby parts.", 2, Theme.Crimson)
            return
        end

        boostSimulation()

        local mp = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
        local targetDir = ray.Direction.Unit

        local expiryTime = autoReturnEnabled and (now + returnDelay) or (now + 3600)
        firedCooldown[targetPart] = expiryTime

        targetPart.CFrame = CFrame.new(root.Position + targetDir * 4 + Vector3.new(0, 1.5, 0))
        targetPart.CanCollide = true
        targetPart.AssemblyLinearVelocity = targetDir * launchSpeed + Vector3.new(0, 6, 0)
        targetPart.AssemblyAngularVelocity = Vector3.new(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))

        local remaining = #activeParts
        notify("FIRED", string.format("Fired 1 part at %d studs/s! (%d left in orbit)", launchSpeed, remaining), 1.5, Theme.Green)
    end

    local function launchAllDebris()
        local root = getRoot()
        if not root or #activeParts == 0 then
            notify("Launcher", "No debris orbiting! Enable orbit first.", 2, Theme.Crimson)
            return
        end

        boostSimulation()
        local mp = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
        local targetDir = ray.Direction.Unit

        local now = os.clock()
        local expiryTime = autoReturnEnabled and (now + returnDelay) or (now + 3600)

        local firedCount = 0
        for _, part in ipairs(activeParts) do
            if part and part.Parent and not part.Anchored then
                firedCooldown[part] = expiryTime
                part.CFrame = CFrame.new(root.Position + targetDir * 4 + Vector3.new(0, 1.5, 0))
                part.CanCollide = true
                part.AssemblyLinearVelocity = targetDir * launchSpeed + Vector3.new(math.random(-25, 25), math.random(-15, 25), math.random(-25, 25))
                part.AssemblyAngularVelocity = Vector3.new(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))
                firedCount = firedCount + 1
            end
        end

        activeParts = {}
        notify("SALVO FIRED", string.format("Fired %d debris parts at %d studs/s!", firedCount, launchSpeed), 2, Theme.Green)
    end

    addToggle("Enable Debris Orbit (Teleport to Orbit)", false, function(v)
        orbitEnabled = v
        if orbitConn then orbitConn:Disconnect() orbitConn = nil end
        if scannerThread then task.cancel(scannerThread) scannerThread = nil end

        if v then
            boostSimulation()
            activeParts = scanDebrisParts()
            orbitConn = RunService.Heartbeat:Connect(updateOrbit)

            local root = getRoot()
            if root and #activeParts > 0 then
                local rootPos = root.Position
                for idx, part in ipairs(activeParts) do
                    teleportPartToSlot(part, idx, #activeParts, rootPos)
                end
            end

            scannerThread = task.spawn(function()
                while orbitEnabled do
                    task.wait(1.0)
                    local freshParts = scanDebrisParts()
                    local currentSet = {}
                    for _, p in ipairs(activeParts) do currentSet[p] = true end
                    local r = getRoot()
                    for _, p in ipairs(freshParts) do
                        if #activeParts >= maxParts then break end
                        if not currentSet[p] then
                            table.insert(activeParts, p)
                            if r then
                                teleportPartToSlot(p, #activeParts, #activeParts, r.Position)
                            end
                        end
                    end
                end
            end)

            notify("Debris Orbit", string.format("Orbit Active! Teleported %d unanchored parts.", #activeParts), 2.5, Theme.Green)
        else
            for _, p in ipairs(activeParts) do
                if p and p.Parent then
                    p.CanCollide = true
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end
            end
            activeParts = {}
            firedCooldown = {}
            notify("Debris Orbit", "Orbit disabled. Released all parts.", 1.5, Theme.TextSecondary)
        end
    end)

    addSlider("Orbit Radius (Studs)", 6, 40, 14, function(val)
        orbitRadius = val
    end)

    addSlider("Orbit Height (Studs)", -2, 10, 2, function(val)
        orbitHeight = val
    end)

    addSlider("Orbit Speed", 1, 10, 4, function(val)
        orbitSpeed = val
    end)

    addSlider("Scan Radius (Studs)", 50, 800, 300, function(val)
        scanRange = val
    end)

    addSlider("Max Orbit Parts", 10, 150, 60, function(val)
        maxParts = val
    end)

    addSlider("Launch Speed", 200, 1500, 600, function(val)
        launchSpeed = val
    end)

    addToggle("Auto-Return Debris After Launch", true, function(v)
        autoReturnEnabled = v
    end)

    addSlider("Return Delay (Seconds)", 1, 8, 3, function(val)
        returnDelay = val
    end)

    addButton("FIRE 1 DEBRIS AT CURSOR [ Middle-Click ]", function()
        launchSingleDebris()
    end)

    addButton("FIRE ALL DEBRIS (SALVO)", function()
        launchAllDebris()
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.UserInputType == Enum.UserInputType.MouseButton3 then
            launchSingleDebris()
        end
    end)
end

do
    local discordCard = Instance.new("Frame")
    discordCard.Size = UDim2.new(1, 0, 0, 48)
    discordCard.BackgroundColor3 = Theme.CardBg
    discordCard.BorderSizePixel = 0
    discordCard.ZIndex = 12
    discordCard.Parent = Content

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
    copyDiscordBtn.ZIndex = 13
    copyDiscordBtn.Active = true
    copyDiscordBtn.AutoButtonColor = false
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
    discordBox.TextEditable = true
    discordBox.ZIndex = 13
    discordBox.Active = true
    discordBox.Parent = discordCard

    local dxbCorner = Instance.new("UICorner")
    dxbCorner.CornerRadius = UDim.new(0, 3)
    dxbCorner.Parent = discordBox

    discordBox:GetPropertyChangedSignal("Text"):Connect(function()
        if discordBox.Text ~= "https://discord.gg/P7fuzYj5xK" then
            discordBox.Text = "https://discord.gg/P7fuzYj5xK"
        end
    end)

    local lastCopy = 0
    copyDiscordBtn.Activated:Connect(function()
        local now = os.clock()
        if now - lastCopy < 0.2 then return end
        lastCopy = now

        local ok = copyToClipboard("https://discord.gg/P7fuzYj5xK")
        pcall(function() print("AikHub Discord: https://discord.gg/P7fuzYj5xK") end)
        discordBox:CaptureFocus()
        discordBox.SelectionStart = 1
        discordBox.CursorPosition = 29

        if ok then
            copyDiscordBtn.Text = "COPIED TO CLIPBOARD!"
            notify("Discord", "Copied to clipboard!", 2.5, Theme.Purple)
            task.delay(2.5, function()
                copyDiscordBtn.Text = "COPY DISCORD INVITE LINK"
            end)
        else
            notify("Discord", "Text selected! Press Ctrl+C", 3, Theme.Purple)
        end
    end)
end

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 16)
footer.BackgroundTransparency = 1
footer.Text = "Credits: eikovo * scriptblox | Middle-Click to Fire"
footer.TextColor3 = Theme.TextSecondary
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 12
footer.Active = false
footer.Parent = Content
