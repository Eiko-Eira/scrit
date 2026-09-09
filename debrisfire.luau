local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

do
    local old = PlayerGui:FindFirstChild("AikDebrisUI")
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikDebrisUI"
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
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -170)
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
titleLabel.Size = UDim2.new(0, 170, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEBRIS ORBIT & LAUNCHER"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 130, 1, 0)
subtitleLabel.Position = UDim2.new(0, 185, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "by eikovo * scriptblox"
subtitleLabel.TextColor3 = Theme.Crimson
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 9
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
        MainFrame.Size = UDim2.new(0, 360, 0, 0)
        MainFrame.BackgroundTransparency = 1
        tw(MainFrame, {Size = UDim2.new(0, 360, 0, 340), BackgroundTransparency = 0}, 0.2)
    else
        tw(MainFrame, {Size = UDim2.new(0, 360, 0, 0), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
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

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 44)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = Content

local function addToggle(label, default, cb)
    local state = default or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Theme.CardBg
    row.Text = ""
    row.BorderSizePixel = 0
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
    lbl.TextSize = 11
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
    minV = minV or 100
    maxV = maxV or 1000

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundColor3 = Theme.CardBg
    container.BorderSizePixel = 0
    container.Parent = Content

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1
    cStroke.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.TextPrimary
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 18)
    valLbl.Position = UDim2.new(1, -58, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.TextColor3 = Theme.AccentDim
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -20, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 0, 28)
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
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.CardBg
    btn.Text = label
    btn.TextColor3 = Theme.TextPrimary
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
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

do
    local orbitEnabled = false
    local orbitRadius = 12
    local launchSpeed = 450
    local orbitConn = nil
    local activeParts = {}
    local orbitAngle = 0

    local function getUnanchoredParts()
        local parts = {}
        local root = getRoot()
        local char = getChar()
        if not root or not char then return parts end

        local rootPos = root.Position
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and obj:IsDescendantOf(p.Character) then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    local d = (obj.Position - rootPos).Magnitude
                    if d < 120 then
                        table.insert(parts, obj)
                    end
                end
            end
        end
        return parts
    end

    local function updateOrbit(dt)
        if not orbitEnabled then return end
        local root = getRoot()
        if not root then return end

        orbitAngle = orbitAngle + dt * 3.5
        activeParts = getUnanchoredParts()

        local count = #activeParts
        if count == 0 then return end

        local rootPos = root.Position
        for idx, part in ipairs(activeParts) do
            local angle = orbitAngle + (idx / count) * math.pi * 2
            local heightOffset = math.sin(orbitAngle * 1.8 + idx) * 2.5
            local offset = Vector3.new(math.cos(angle) * orbitRadius, heightOffset + 1.5, math.sin(angle) * orbitRadius)
            local targetPos = rootPos + offset

            local diff = targetPos - part.Position
            part.AssemblyLinearVelocity = diff * 22
            part.CanCollide = false
        end
    end

    local function launchAllDebris()
        local root = getRoot()
        if not root or #activeParts == 0 then
            notify("Launcher", "No unanchored parts orbiting to fire!", 2, Theme.Red)
            return
        end

        local mp = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
        local targetDir = ray.Direction.Unit

        local fired = #activeParts
        for _, part in ipairs(activeParts) do
            part.CanCollide = true
            part.AssemblyLinearVelocity = targetDir * launchSpeed + Vector3.new(0, 12, 0)
        end
        activeParts = {}
        notify("FIRED", string.format("Fired %d debris parts at supersonic speed!", fired), 2, Theme.Green)
    end

    addToggle("Enable Debris Orbit (Gather Map Parts)", false, function(v)
        orbitEnabled = v
        if orbitConn then orbitConn:Disconnect() orbitConn = nil end
        if v then
            orbitConn = RunService.Heartbeat:Connect(updateOrbit)
            notify("Debris Orbit", "Orbit ACTIVE. Pulling all unanchored map parts!", 2.5, Theme.Green)
        else
            for _, p in ipairs(activeParts) do
                p.CanCollide = true
            end
            activeParts = {}
            notify("Debris Orbit", "Orbit disabled. Released all parts.", 1.5, Theme.TextSecondary)
        end
    end)

    addSlider("Orbit Radius (Studs)", 6, 30, 12, function(val)
        orbitRadius = val
    end)

    addSlider("Launch Speed", 200, 900, 450, function(val)
        launchSpeed = val
    end)

    addButton("Fire Debris at Cursor [ Middle Click ]", function()
        launchAllDebris()
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.UserInputType == Enum.UserInputType.MouseButton3 then
            launchAllDebris()
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

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 20)
footer.BackgroundTransparency = 1
footer.Text = "Credits: eikovo * scriptblox | Middle-Click to Fire"
footer.TextColor3 = Theme.TextSecondary
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = Content
