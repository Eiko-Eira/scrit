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
if not LocalPlayer then return end

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

local Terrain = workspace:FindFirstChildOfClass("Terrain") or workspace.Terrain

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
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
end

local guiParent = getGuiParent()
if not guiParent then
    local w = os.clock()
    while not guiParent and (os.clock() - w) < 8 do
        guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        task.wait(0.2)
    end
end
if not guiParent then return end

do
    local function cleanOld(c)
        if c and typeof(c) == "Instance" then
            pcall(function()
                local old = c:FindFirstChild("NIXShadersUI")
                if old then old:Destroy() end
            end)
        end
    end
    cleanOld(guiParent)
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg and pg ~= guiParent then cleanOld(pg) end
    pcall(function()
        local coreG = game:GetService("CoreGui")
        if coreG and coreG ~= guiParent then cleanOld(coreG) end
    end)
    local oldRainFolder = workspace:FindFirstChild("NIXRainFX")
    if oldRainFolder then oldRainFolder:Destroy() end
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

local function copyText(str)
    local sc = setclipboard or toclipboard or (syn and syn.set_clipboard)
    if sc then
        sc(str)
        return true
    end
    return false
end

local RaycastExcludeType = (function()
    local ok, val = pcall(function() return Enum.RaycastFilterType.Exclude end)
    if ok and val then return val end
    local ok2, val2 = pcall(function() return Enum.RaycastFilterType.Blacklist end)
    if ok2 and val2 then return val2 end
    return 0
end)()

local ShadersState = {
    OriginalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        ShadowSoftness = Lighting.ShadowSoftness,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        GeographicLatitude = Lighting.GeographicLatitude
    },
    OriginalCamera = {
        CameraType = Camera.CameraType,
        FieldOfView = Camera.FieldOfView
    },
    DeveloperEffects = {},
    DevPresetsStripped = false,
    OriginalMaterials = {},
    OriginalCastShadows = {},
    FXAAGodraysEnabled = true,
    FXAABlurSize = 2,
    ReflectionsEnabled = false,
    ReflectionIntensity = 0.45,
    RainEnabled = false,
    RainIntensity = 1,
    AutoFocusEnabled = false,
    VignetteEnabled = false,
    DeepShadowsEnabled = false,
    ForceCastShadowEnabled = false,
    ActivePreset = "Default",
    CinematicEnabled = false,
    CinematicSpeed = 35,
    FreezePoseEnabled = true,
    HoldRMBToSteer = true,
    FrozenTracks = {},
    FrozenParts = {},
    PreviousCameraType = Enum.CameraType.Custom,
    PreviousCameraSubject = nil,
    SetCinematicToggleUI = nil,
    Connections = {}
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXShadersUI"
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
        ScreenGui.Parent = pg
    end)
end

local DevCache = Instance.new("Folder")
DevCache.Name = "NIXDevCache"
DevCache.Parent = ScreenGui

local function stripDeveloperEffects()
    if not ShadersState.DevPresetsStripped then
        ShadersState.DevPresetsStripped = true
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                if not string.find(obj.Name, "^NIX") then
                    if not ShadersState.DeveloperEffects[obj] then
                        local hasEnabled = pcall(function() return obj.Enabled end)
                        ShadersState.DeveloperEffects[obj] = {
                            Parent = obj.Parent,
                            Enabled = hasEnabled and obj.Enabled or nil
                        }
                    end
                    pcall(function()
                        if obj:IsA("Sky") or obj:IsA("Atmosphere") then
                            obj.Parent = DevCache
                        elseif obj:IsA("PostEffect") then
                            obj.Enabled = false
                        end
                    end)
                end
            end
        end
    end
end

local function restoreDeveloperEffects()
    if ShadersState.DevPresetsStripped then
        ShadersState.DevPresetsStripped = false
        for obj, data in pairs(ShadersState.DeveloperEffects) do
            if obj then
                pcall(function()
                    if data.Parent and data.Parent.Parent then
                        obj.Parent = data.Parent
                    else
                        obj.Parent = Lighting
                    end
                    if data.Enabled ~= nil then
                        obj.Enabled = data.Enabled
                    end
                end)
            end
        end
        ShadersState.DeveloperEffects = {}
        local o = ShadersState.OriginalLighting
        Lighting.Ambient = o.Ambient
        Lighting.OutdoorAmbient = o.OutdoorAmbient
        Lighting.Brightness = o.Brightness
        Lighting.ClockTime = o.ClockTime
        Lighting.FogColor = o.FogColor
        Lighting.FogEnd = o.FogEnd
        Lighting.FogStart = o.FogStart
        Lighting.GlobalShadows = o.GlobalShadows
        Lighting.ShadowSoftness = o.ShadowSoftness
        Lighting.ExposureCompensation = o.ExposureCompensation
        Lighting.EnvironmentDiffuseScale = o.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = o.EnvironmentSpecularScale
        Lighting.GeographicLatitude = o.GeographicLatitude
    end
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

local function Notify(title, desc, duration, color, onClick)
    duration = duration or 3
    color = color or Theme.Accent
    notifCount = notifCount + 1

    local card = Instance.new("TextButton")
    card.Name = "Notif_" .. notifCount
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Theme.Header
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
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

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        if card and card.Parent then
            tw(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0)}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end

    if onClick then
        card.MouseButton1Click:Connect(function()
            task.spawn(onClick)
            dismiss()
        end)
    end

    task.delay(duration, dismiss)
end

local MainShadow = Instance.new("Frame")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(0, 646, 0, 486)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.65
MainShadow.BorderSizePixel = 0
MainShadow.Active = false
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

    local GlassDarkener = Instance.new("Frame")
    GlassDarkener.Name = "GlassDarkener"
    GlassDarkener.Size = UDim2.new(1, 0, 1, 0)
    GlassDarkener.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    GlassDarkener.BackgroundTransparency = 0.35
    GlassDarkener.BorderSizePixel = 0
    GlassDarkener.Active = false
    GlassDarkener.ZIndex = 2
    GlassDarkener.Parent = MainFrame
end

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "NIXFloatToggle"
FloatToggle.Size = UDim2.new(0, 44, 0, 44)
FloatToggle.Position = UDim2.new(0, 16, 0.5, 30)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "SHDR"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.Gotham
FloatToggle.TextSize = 11
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
closeBtn.Font = Enum.Font.Gotham
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
    titleLabel.Text = "N I X  S H A D E R S"
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = TopBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 260, 1, 0)
    subtitleLabel.Position = UDim2.new(0, 180, 0, 0)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "RSHIFT  *  TOGGLE  *  T PHOTO MODE"
    subtitleLabel.TextColor3 = Theme.TextSecondary
    subtitleLabel.Font = Enum.Font.Gotham
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
end

local isDragging, dragInput, mousePos, framePos = false, nil, nil, nil
TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        mousePos = inp.Position
        framePos = MainFrame.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
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
        local vp = Camera.ViewportSize
        local minX = -framePos.X.Scale * vp.X + 10
        local maxX = (1 - framePos.X.Scale) * vp.X - 640
        local minY = -framePos.Y.Scale * vp.Y + 10
        local maxY = (1 - framePos.Y.Scale) * vp.Y - 480
        local targetX = math.clamp(framePos.X.Offset + d.X, minX, maxX)
        local targetY = math.clamp(framePos.Y.Offset + d.Y, minY, maxY)
        local newPos = UDim2.new(framePos.X.Scale, targetX, framePos.Y.Scale, targetY)
        MainFrame.Position = newPos
        MainShadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 3)
    end
end)
UserInputService.WindowFocusReleased:Connect(function()
    isDragging = false
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

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 136, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.06
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.Border
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
    pageLayout.Padding = UDim.new(0, 5)
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
            tw(btn, {BackgroundColor3 = Theme.ElementActive}, 0.08)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
        end)
        btn.MouseButton1Click:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 10, 0, 10)
            ripple.Position = UDim2.new(0.5, -5, 0.5, -5)
            ripple.BackgroundColor3 = Theme.Accent
            ripple.BackgroundTransparency = 0.6
            ripple.BorderSizePixel = 0
            ripple.Active = false
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
        valLbl.Font = Enum.Font.Gotham
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
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                tw(handle, {Size = UDim2.new(0, 18, 0, 18)}, 0.12, Enum.EasingStyle.Back)
            end
        end)
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                tw(handle, {Size = UDim2.new(0, 18, 0, 18)}, 0.12, Enum.EasingStyle.Back)
                applySlide(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and sliding then
                sliding = false
                tw(handle, {Size = UDim2.new(0, 14, 0, 14)}, 0.12)
                tw(valLbl, {TextColor3 = Theme.AccentDim}, 0.2)
                tw(cStroke, {Color = Theme.Border}, 0.12)
                tw(container, {BackgroundColor3 = Theme.ElementBg}, 0.12)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                applySlide(inp.Position)
            end
        end)
    end

    function tabObj:AddInput(placeholder, btnText, cb)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 46)
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

        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -94, 0, 30)
        tb.Position = UDim2.new(0, 8, 0.5, -15)
        tb.BackgroundColor3 = Theme.Header
        tb.BorderSizePixel = 0
        tb.Text = ""
        tb.PlaceholderText = placeholder or ""
        tb.PlaceholderColor3 = Theme.TextSecondary
        tb.TextColor3 = Theme.TextPrimary
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 10
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = false
        tb.Parent = container

        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
        local tPad = Instance.new("UIPadding", tb)
        tPad.PaddingLeft = UDim.new(0, 8)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 76, 0, 30)
        btn.Position = UDim2.new(1, -82, 0.5, -15)
        btn.BackgroundColor3 = Theme.TabActive
        btn.Text = btnText or "LOAD"
        btn.TextColor3 = Theme.TabActiveText
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = container

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            if cb then task.spawn(cb, tb.Text) end
        end)
        return tb
    end

    return tabObj
end

local CC = Instance.new("ColorCorrectionEffect")
CC.Name = "NIXColorCorrection"
CC.Parent = Lighting

local Bloom = Instance.new("BloomEffect")
Bloom.Name = "NIXBloom"
Bloom.Parent = Lighting

local SunRays = Instance.new("SunRaysEffect")
SunRays.Name = "NIXSunRays"
SunRays.Intensity = 0.25
SunRays.Spread = 0.8
SunRays.Enabled = true
SunRays.Parent = Lighting

local FXAABlur = Instance.new("BlurEffect")
FXAABlur.Name = "NIXFXAABlur"
FXAABlur.Size = 2
FXAABlur.Enabled = true
FXAABlur.Parent = Lighting

local DOF = Instance.new("DepthOfFieldEffect")
DOF.Name = "NIXDepthOfField"
DOF.FarIntensity = 0.35
DOF.FocusDistance = 50
DOF.InFocusRadius = 25
DOF.NearIntensity = 0.35
DOF.Enabled = false
DOF.Parent = Lighting

local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Name = "NIXAtmosphere"
Atmosphere.Parent = Lighting

local Clouds = Terrain:FindFirstChildOfClass("Clouds")
if not Clouds then
    Clouds = Instance.new("Clouds")
    Clouds.Name = "NIXClouds"
    Clouds.Cover = 0.5
    Clouds.Density = 0.7
    Clouds.Parent = Terrain
end

local Sky = Instance.new("Sky")
Sky.Name = "NIXSky"
Sky.CelestialBodiesShown = true

local RainFolder = Instance.new("Folder")
RainFolder.Name = "NIXRainFX"
RainFolder.Parent = workspace

local VignetteFrame = Instance.new("ImageLabel")
VignetteFrame.Name = "NIXVignette"
VignetteFrame.Size = UDim2.new(1, 0, 1, 0)
VignetteFrame.BackgroundTransparency = 1
VignetteFrame.Image = "rbxassetid://4576475446"
VignetteFrame.ImageColor3 = Color3.fromRGB(0, 0, 0)
VignetteFrame.ImageTransparency = 1
VignetteFrame.ZIndex = 1
VignetteFrame.Parent = ScreenGui

local cinematicConn = nil
local cinematicKeys = {
    W = false,
    A = false,
    S = false,
    D = false,
    E = false,
    Q = false,
    Space = false,
    LeftShift = false,
    LeftControl = false
}
local rmbHeld = false
local camYaw = 0
local camPitch = 0
local camPos = Vector3.zero
local targetCamPos = Vector3.zero
local toggleCinematicCamera = nil
local focusCameraOnCharacter = nil

UserInputService.InputEnded:Connect(function(inp)
    if ShadersState.CinematicEnabled then
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            rmbHeld = false
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end)
        end
        if inp.KeyCode == Enum.KeyCode.W then cinematicKeys.W = false end
        if inp.KeyCode == Enum.KeyCode.A then cinematicKeys.A = false end
        if inp.KeyCode == Enum.KeyCode.S then cinematicKeys.S = false end
        if inp.KeyCode == Enum.KeyCode.D then cinematicKeys.D = false end
        if inp.KeyCode == Enum.KeyCode.E then cinematicKeys.E = false end
        if inp.KeyCode == Enum.KeyCode.Q then cinematicKeys.Q = false end
        if inp.KeyCode == Enum.KeyCode.Space then cinematicKeys.Space = false end
        if inp.KeyCode == Enum.KeyCode.LeftShift then cinematicKeys.LeftShift = false end
        if inp.KeyCode == Enum.KeyCode.LeftControl then cinematicKeys.LeftControl = false end
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if ShadersState.CinematicEnabled and inp.UserInputType == Enum.UserInputType.MouseMovement then
        if rmbHeld or not ShadersState.HoldRMBToSteer then
            local delta = inp.Delta
            local sens = 0.0032
            camYaw = camYaw - delta.X * sens
            camPitch = math.clamp(camPitch - delta.Y * sens, -math.rad(88), math.rad(88))
        end
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
    if not gpe and inp.KeyCode == Enum.KeyCode.T then
        if toggleCinematicCamera then
            toggleCinematicCamera(not ShadersState.CinematicEnabled)
        end
    end
    if not gpe and inp.KeyCode == Enum.KeyCode.H and ShadersState.CinematicEnabled then
        setVisible(not isVisible)
    end
    if ShadersState.CinematicEnabled then
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            rmbHeld = true
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            end)
        end
        if not gpe then
            if inp.KeyCode == Enum.KeyCode.W then cinematicKeys.W = true end
            if inp.KeyCode == Enum.KeyCode.A then cinematicKeys.A = true end
            if inp.KeyCode == Enum.KeyCode.S then cinematicKeys.S = true end
            if inp.KeyCode == Enum.KeyCode.D then cinematicKeys.D = true end
            if inp.KeyCode == Enum.KeyCode.E then cinematicKeys.E = true end
            if inp.KeyCode == Enum.KeyCode.Q then cinematicKeys.Q = true end
            if inp.KeyCode == Enum.KeyCode.Space then cinematicKeys.Space = true end
            if inp.KeyCode == Enum.KeyCode.LeftShift then cinematicKeys.LeftShift = true end
            if inp.KeyCode == Enum.KeyCode.LeftControl then cinematicKeys.LeftControl = true end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if ShadersState.CinematicEnabled and toggleCinematicCamera then
        toggleCinematicCamera(false)
    end
end)

local function setLightingTechnology(tech)
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", tech)
        else
            Lighting.Technology = tech
        end
    end)
end

local function setFXAAGodrays(enabled)
    ShadersState.FXAAGodraysEnabled = enabled
    if enabled then
        SunRays.Enabled = true
        FXAABlur.Enabled = true
        FXAABlur.Size = ShadersState.FXAABlurSize
    else
        FXAABlur.Enabled = false
    end
end

local function setReflectanceLevel(v)
    ShadersState.ReflectionIntensity = v
    if ShadersState.ReflectionsEnabled then
        for part in pairs(ShadersState.OriginalMaterials) do
            if part and part.Parent then
                pcall(function() part.Reflectance = v end)
            end
        end
    end
end

local function applySkybox(textures)
    if not textures then
        if Sky then Sky.Parent = DevCache end
        return
    end
    Sky.SkyboxBk = textures.Bk or ""
    Sky.SkyboxDn = textures.Dn or ""
    Sky.SkyboxFt = textures.Ft or ""
    Sky.SkyboxLf = textures.Lf or ""
    Sky.SkyboxRt = textures.Rt or ""
    Sky.SkyboxUp = textures.Up or ""
    Sky.Parent = Lighting
    Notify("Skybox", "Skybox textures loaded", 2, Theme.Green)
end

local function applyPreset(name)
    ShadersState.ActivePreset = name
    if name == "BSL" then
        stripDeveloperEffects()
        CC.Brightness = 0.0
        CC.Contrast = 0.15
        CC.Saturation = 0.22
        CC.TintColor = Color3.fromRGB(255, 252, 245)
        Bloom.Enabled = true
        Bloom.Intensity = 0.35
        Bloom.Size = 16
        Bloom.Threshold = 0.88
        SunRays.Enabled = true
        SunRays.Intensity = 0.18
        SunRays.Spread = 0.8
        setFXAAGodrays(true)
        Atmosphere.Density = 0.22
        Atmosphere.Offset = 0.25
        Atmosphere.Haze = 0.1
        Atmosphere.Color = Color3.fromRGB(195, 220, 250)
        Atmosphere.Decay = Color3.fromRGB(255, 210, 160)
        Atmosphere.Glare = 0.2
        Lighting.Brightness = 2.4
        Lighting.ExposureCompensation = 0.0
        Lighting.ShadowSoftness = 0.12
        Lighting.Ambient = Color3.fromRGB(75, 78, 88)
        Lighting.OutdoorAmbient = Color3.fromRGB(130, 135, 145)
        setLightingTechnology(Enum.Technology.Future)
        Notify("Shaders", "Applied BSL Shaders (Balanced Daylight)", 2.5, Theme.Green)
    elseif name == "SEUS" then
        stripDeveloperEffects()
        CC.Brightness = 0.02
        CC.Contrast = 0.3
        CC.Saturation = 0.18
        CC.TintColor = Color3.fromRGB(250, 250, 255)
        Bloom.Enabled = true
        Bloom.Intensity = 0.45
        Bloom.Size = 22
        Bloom.Threshold = 0.92
        SunRays.Enabled = true
        SunRays.Intensity = 0.22
        SunRays.Spread = 0.85
        setFXAAGodrays(true)
        Atmosphere.Density = 0.18
        Atmosphere.Offset = 0.2
        Atmosphere.Haze = 0.05
        Atmosphere.Color = Color3.fromRGB(180, 210, 255)
        Atmosphere.Decay = Color3.fromRGB(240, 195, 150)
        Atmosphere.Glare = 0.3
        Lighting.Brightness = 2.6
        Lighting.ExposureCompensation = 0.1
        Lighting.ShadowSoftness = 0.05
        Lighting.Ambient = Color3.fromRGB(65, 70, 82)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 125, 135)
        setLightingTechnology(Enum.Technology.Future)
        Notify("Shaders", "Applied SEUS Renewed (Raytraced High-Contrast)", 2.5, Theme.Green)
    elseif name == "Cyberpunk" then
        stripDeveloperEffects()
        CC.Brightness = -0.05
        CC.Contrast = 0.45
        CC.Saturation = 0.5
        CC.TintColor = Color3.fromRGB(230, 240, 255)
        Bloom.Enabled = true
        Bloom.Intensity = 0.9
        Bloom.Size = 28
        Bloom.Threshold = 0.75
        SunRays.Enabled = true
        SunRays.Intensity = 0.3
        SunRays.Spread = 0.9
        setFXAAGodrays(true)
        Atmosphere.Density = 0.35
        Atmosphere.Offset = 0.1
        Atmosphere.Haze = 0.2
        Atmosphere.Color = Color3.fromRGB(120, 160, 255)
        Atmosphere.Decay = Color3.fromRGB(255, 60, 120)
        Atmosphere.Glare = 0.4
        Lighting.Brightness = 1.6
        Lighting.ExposureCompensation = -0.15
        Lighting.ShadowSoftness = 0.2
        Lighting.Ambient = Color3.fromRGB(30, 35, 55)
        Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 100)
        setLightingTechnology(Enum.Technology.Future)
        Notify("Shaders", "Applied Cyberpunk RTX (Vibrant Neon)", 2.5, Theme.Green)
    elseif name == "GoldenHour" then
        stripDeveloperEffects()
        CC.Brightness = 0.04
        CC.Contrast = 0.2
        CC.Saturation = 0.35
        CC.TintColor = Color3.fromRGB(255, 235, 205)
        Bloom.Enabled = true
        Bloom.Intensity = 0.65
        Bloom.Size = 24
        Bloom.Threshold = 0.8
        SunRays.Enabled = true
        SunRays.Intensity = 0.4
        SunRays.Spread = 0.95
        setFXAAGodrays(true)
        Atmosphere.Density = 0.3
        Atmosphere.Offset = 0.4
        Atmosphere.Haze = 0.25
        Atmosphere.Color = Color3.fromRGB(255, 185, 110)
        Atmosphere.Decay = Color3.fromRGB(210, 95, 45)
        Atmosphere.Glare = 0.6
        Lighting.Brightness = 2.8
        Lighting.ExposureCompensation = 0.15
        Lighting.ClockTime = 17.6
        Lighting.ShadowSoftness = 0.25
        Lighting.Ambient = Color3.fromRGB(90, 75, 65)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 125, 95)
        setLightingTechnology(Enum.Technology.Future)
        Notify("Shaders", "Applied Golden Hour (Sunset Sunbeams)", 2.5, Theme.Green)
    elseif name == "RainyNoir" then
        stripDeveloperEffects()
        CC.Brightness = -0.06
        CC.Contrast = 0.25
        CC.Saturation = -0.35
        CC.TintColor = Color3.fromRGB(205, 215, 230)
        Bloom.Enabled = true
        Bloom.Intensity = 0.2
        Bloom.Size = 12
        Bloom.Threshold = 0.9
        SunRays.Enabled = false
        setFXAAGodrays(false)
        Atmosphere.Density = 0.45
        Atmosphere.Offset = 0.1
        Atmosphere.Haze = 0.35
        Atmosphere.Color = Color3.fromRGB(150, 165, 185)
        Atmosphere.Decay = Color3.fromRGB(120, 135, 150)
        Atmosphere.Glare = 0.05
        Lighting.Brightness = 1.4
        Lighting.ExposureCompensation = -0.2
        Lighting.ShadowSoftness = 0.5
        Lighting.Ambient = Color3.fromRGB(45, 50, 60)
        Lighting.OutdoorAmbient = Color3.fromRGB(75, 85, 95)
        setLightingTechnology(Enum.Technology.Future)
        Notify("Shaders", "Applied Rainy Noir (Desaturated Overcast)", 2.5, Theme.Green)
    elseif name == "Default" then
        restoreDeveloperEffects()
        CC.Brightness = 0
        CC.Contrast = 0
        CC.Saturation = 0
        CC.TintColor = Color3.fromRGB(255, 255, 255)
        Bloom.Enabled = false
        SunRays.Enabled = false
        FXAABlur.Enabled = false
        DOF.Enabled = false
        Atmosphere.Density = 0.3
        Atmosphere.Haze = 0
        Atmosphere.Color = Color3.fromRGB(199, 199, 199)
        Atmosphere.Decay = Color3.fromRGB(106, 112, 125)
        Atmosphere.Glare = 0
        local o = ShadersState.OriginalLighting
        Lighting.Ambient = o.Ambient
        Lighting.OutdoorAmbient = o.OutdoorAmbient
        Lighting.Brightness = o.Brightness
        Lighting.ClockTime = o.ClockTime
        Lighting.FogColor = o.FogColor
        Lighting.FogEnd = o.FogEnd
        Lighting.FogStart = o.FogStart
        Lighting.GlobalShadows = o.GlobalShadows
        Lighting.ShadowSoftness = o.ShadowSoftness
        Lighting.ExposureCompensation = o.ExposureCompensation
        applySkybox(nil)
        Notify("Shaders", "Reverted to Vanilla Game Settings", 2.5, Theme.Green)
    end
end

local skyPresets = {
    ClearDay = {
        Bk = "rbxassetid://159454299",
        Dn = "rbxassetid://159454296",
        Ft = "rbxassetid://159454293",
        Lf = "rbxassetid://159454286",
        Rt = "rbxassetid://159454300",
        Up = "rbxassetid://159454288"
    },
    Cumulus = {
        Bk = "rbxassetid://1310706484",
        Dn = "rbxassetid://1310707137",
        Ft = "rbxassetid://1310706917",
        Lf = "rbxassetid://1310707374",
        Rt = "rbxassetid://1310707579",
        Up = "rbxassetid://1310707765"
    },
    GoldenSunset = {
        Bk = "rbxassetid://444101785",
        Dn = "rbxassetid://444103629",
        Ft = "rbxassetid://444101854",
        Lf = "rbxassetid://444103565",
        Rt = "rbxassetid://444103823",
        Up = "rbxassetid://444103983"
    },
    MilkyWay = {
        Bk = "rbxassetid://144093950",
        Dn = "rbxassetid://144093946",
        Ft = "rbxassetid://144093953",
        Lf = "rbxassetid://144093948",
        Rt = "rbxassetid://144093955",
        Up = "rbxassetid://144093957"
    },
    AnimeSky = {
        Bk = "rbxassetid://291721590",
        Dn = "rbxassetid://291721665",
        Ft = "rbxassetid://291721737",
        Lf = "rbxassetid://291721815",
        Rt = "rbxassetid://291721886",
        Up = "rbxassetid://291721950"
    }
}

local function setSkybox(name, customAssetId)
    if name == "Custom" and customAssetId then
        applySkybox({
            Bk = customAssetId,
            Dn = customAssetId,
            Ft = customAssetId,
            Lf = customAssetId,
            Rt = customAssetId,
            Up = customAssetId
        })
    elseif name == "Default" then
        applySkybox(nil)
    elseif skyPresets[name] then
        applySkybox(skyPresets[name])
    end
end

local function setDeepShadows(enabled)
    ShadersState.DeepShadowsEnabled = enabled
    if enabled then
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(
            math.max(0, Lighting.OutdoorAmbient.R * 255 - 45),
            math.max(0, Lighting.OutdoorAmbient.G * 255 - 45),
            math.max(0, Lighting.OutdoorAmbient.B * 255 - 45)
        )
        Lighting.ShadowSoftness = 0.05
        Notify("Shadows", "Deep ambient contact shadows enabled", 2, Theme.Green)
    else
        local o = ShadersState.OriginalLighting
        Lighting.OutdoorAmbient = o.OutdoorAmbient
        Lighting.ShadowSoftness = o.ShadowSoftness
        Notify("Shadows", "Deep shadows restored", 2, Theme.Green)
    end
end

local function setForceCastShadow(enabled)
    ShadersState.ForceCastShadowEnabled = enabled
    if not enabled then
        for part, state in pairs(ShadersState.OriginalCastShadows) do
            if part and part.Parent then
                pcall(function() part.CastShadow = state end)
            end
        end
        ShadersState.OriginalCastShadows = {}
        Notify("Shadows", "Original CastShadow properties restored", 2, Theme.Green)
        return
    end

    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if ShadersState.OriginalCastShadows[obj] == nil then
                ShadersState.OriginalCastShadows[obj] = obj.CastShadow
            end
            if not obj.CastShadow then
                obj.CastShadow = true
                count = count + 1
            end
        end
    end
    Notify("Shadows", "Enabled CastShadow on " .. count .. " world parts", 2.5, Theme.Green)
end

local function setReflections(enabled)
    ShadersState.ReflectionsEnabled = enabled
    if not enabled then
        for part, props in pairs(ShadersState.OriginalMaterials) do
            if part and part.Parent then
                pcall(function()
                    part.Material = props.Material
                    part.Reflectance = props.Reflectance
                end)
            end
        end
        ShadersState.OriginalMaterials = {}
        Notify("Reflections", "PBR materials restored to original", 2, Theme.Green)
        return
    end

    local targetMaterials = {
        [Enum.Material.Metal] = true,
        [Enum.Material.CorrodedMetal] = true,
        [Enum.Material.DiamondPlate] = true,
        [Enum.Material.Foil] = true,
        [Enum.Material.Glass] = true,
        [Enum.Material.SmoothPlastic] = true,
        [Enum.Material.Plastic] = true,
        [Enum.Material.Marble] = true,
        [Enum.Material.Granite] = true
    }
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and targetMaterials[obj.Material] then
            if not ShadersState.OriginalMaterials[obj] then
                ShadersState.OriginalMaterials[obj] = {
                    Material = obj.Material,
                    Reflectance = obj.Reflectance
                }
                count = count + 1
            end
            pcall(function()
                if obj.Material ~= Enum.Material.Glass and obj.Material ~= Enum.Material.Metal then
                    obj.Material = Enum.Material.Glass
                end
                obj.Reflectance = ShadersState.ReflectionIntensity
            end)
        end
    end
    Notify("Reflections", "Enhanced PBR reflections on " .. count .. " parts", 2.5, Theme.Green)
end

local function setRainEffect(enabled)
    ShadersState.RainEnabled = enabled
    RainFolder:ClearAllChildren()
    if ShadersState.Connections.Rain then
        ShadersState.Connections.Rain:Disconnect()
        ShadersState.Connections.Rain = nil
    end
    if not enabled then
        Notify("Rain FX", "Rain system stopped", 2, Theme.Green)
        return
    end

    local emitterPart = Instance.new("Part")
    emitterPart.Name = "RainEmitterBox"
    emitterPart.Size = Vector3.new(60, 2, 60)
    emitterPart.Transparency = 1
    emitterPart.Anchored = true
    emitterPart.CanCollide = false
    emitterPart.CanTouch = false
    emitterPart.CanQuery = false
    emitterPart.Parent = RainFolder

    local pe = Instance.new("ParticleEmitter")
    pe.Name = "RainStreaks"
    pe.Rate = 450 * ShadersState.RainIntensity
    pe.Speed = NumberRange.new(85, 115)
    pe.Lifetime = NumberRange.new(0.6, 0.9)
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    pe.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    pe.Color = ColorSequence.new(Color3.fromRGB(200, 225, 255))
    pe.EmissionDirection = Enum.NormalId.Bottom
    pe.SpreadAngle = Vector2.new(2, 2)
    pe.Parent = emitterPart

    ShadersState.Connections.Rain = RunService.RenderStepped:Connect(function()
        if not ShadersState.RainEnabled or not Camera then return end
        emitterPart.Position = Camera.CFrame.Position + Vector3.new(0, 30, 0)
    end)
    Notify("Rain FX", "Volumetric rain and wet ground enabled", 2.5, Theme.Green)
end

local function setAutoFocus(enabled)
    ShadersState.AutoFocusEnabled = enabled
    DOF.Enabled = enabled
    if ShadersState.Connections.DOF then
        ShadersState.Connections.DOF:Disconnect()
        ShadersState.Connections.DOF = nil
    end
    if not enabled then return end

    ShadersState.Connections.DOF = RunService.RenderStepped:Connect(function()
        if not ShadersState.AutoFocusEnabled or not Camera then return end
        local camPos = Camera.CFrame.Position
        local camLook = Camera.CFrame.LookVector
        local params = RaycastParams.new()
        pcall(function() params.FilterType = RaycastExcludeType end)
        local filterList = {RainFolder}
        local char = LocalPlayer.Character
        if char then table.insert(filterList, char) end
        params.FilterDescendantsInstances = filterList

        local hit = workspace:Raycast(camPos, camLook * 300, params)
        local targetDist = hit and hit.Distance or 50
        DOF.FocusDistance = math.clamp(DOF.FocusDistance + (targetDist - DOF.FocusDistance) * 0.15, 5, 250)
    end)
end

local function setFreezePose(freeze)
    if freeze then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = hum:FindFirstChildOfClass("Animator")
                local tracks = anim and anim:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
                for _, t in ipairs(tracks) do
                    pcall(function()
                        t:AdjustSpeed(0)
                        table.insert(ShadersState.FrozenTracks, t)
                    end)
                end
                hum.PlatformStand = true
                hum.AutoRotate = false
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.Anchored = true
                    table.insert(ShadersState.FrozenParts, part)
                end
            end
        end
    else
        for _, part in ipairs(ShadersState.FrozenParts) do
            if part and part.Parent then
                pcall(function() part.Anchored = false end)
            end
        end
        ShadersState.FrozenParts = {}
        for _, t in ipairs(ShadersState.FrozenTracks) do
            pcall(function() t:AdjustSpeed(1) end)
        end
        ShadersState.FrozenTracks = {}
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
        end
    end
end

focusCameraOnCharacter = function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return end
    local frontPos = root.Position + root.CFrame.LookVector * 7 + Vector3.new(0, 1.2, 0)
    targetCamPos = frontPos
    camPos = frontPos
    local dir = (root.Position + Vector3.new(0, 0.8, 0) - frontPos).Unit
    camYaw = math.atan2(-dir.X, -dir.Z)
    camPitch = math.asin(math.clamp(dir.Y, -0.9999, 0.9999))
    Camera.CFrame = CFrame.new(camPos) * CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)
end

toggleCinematicCamera = function(enabled)
    if enabled == ShadersState.CinematicEnabled then return end
    ShadersState.CinematicEnabled = enabled

    if enabled then
        if ShadersState.FreezePoseEnabled then
            setFreezePose(true)
        end

        ShadersState.PreviousCameraType = Camera.CameraType
        ShadersState.PreviousCameraSubject = Camera.CameraSubject
        Camera.CameraType = Enum.CameraType.Scriptable

        local curCF = Camera.CFrame
        camPos = curCF.Position
        targetCamPos = curCF.Position

        local look = curCF.LookVector
        camYaw = math.atan2(-look.X, -look.Z)
        camPitch = math.asin(math.clamp(look.Y, -0.9999, 0.9999))

        for k in pairs(cinematicKeys) do
            cinematicKeys[k] = false
        end
        rmbHeld = false

        if cinematicConn then
            cinematicConn:Disconnect()
        end

        cinematicConn = RunService.RenderStepped:Connect(function(rawDt)
            if not ShadersState.CinematicEnabled or not Camera then return end
            local dt = math.clamp(rawDt, 0.001, 0.05)
            local rot = CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)

            local moveDir = Vector3.zero
            if cinematicKeys.W then moveDir = moveDir + rot.LookVector end
            if cinematicKeys.S then moveDir = moveDir - rot.LookVector end
            if cinematicKeys.D then moveDir = moveDir + rot.RightVector end
            if cinematicKeys.A then moveDir = moveDir - rot.RightVector end
            if cinematicKeys.E or cinematicKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if cinematicKeys.Q or cinematicKeys.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end

            local boost = cinematicKeys.LeftShift and 2.5 or 1.0
            local spd = (ShadersState.CinematicSpeed or 35) * boost
            targetCamPos = targetCamPos + moveDir * (spd * dt)
            camPos = camPos:Lerp(targetCamPos, math.clamp(dt * 18, 0, 1))

            Camera.CFrame = CFrame.new(camPos) * rot
        end)

        Notify("Photo Mode", "Cinematic Freecam ON [T]. WASD fly, hold RMB steer.", 3.5, Theme.Green)
    else
        if cinematicConn then
            cinematicConn:Disconnect()
            cinematicConn = nil
        end
        for k in pairs(cinematicKeys) do
            cinematicKeys[k] = false
        end
        rmbHeld = false
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)

        setFreezePose(false)

        Camera.CameraType = ShadersState.PreviousCameraType or Enum.CameraType.Custom
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end

        Notify("Photo Mode", "Cinematic Freecam OFF. Pose & camera restored.", 2.5, Theme.Accent)
    end

    if ShadersState.SetCinematicToggleUI then
        ShadersState.SetCinematicToggleUI(enabled)
    end
end

do
    local PacksTab = createTab("Packs")
    local SkyTab = createTab("Sky")
    local ShadowsTab = createTab("Shadows")
    local GodraysTab = createTab("Godrays")
    local ReflectionsTab = createTab("Reflect")
    local WeatherTab = createTab("Weather")
    local LensTab = createTab("PostFX")
    local PhotoTab = createTab("Photo")
    local CreditsTab = createTab("Credits")

    do
        PacksTab:AddSection("Minecraft Style Shader Packs")
        PacksTab:AddButton("BSL Shaders - Natural Daylight & Crisp Shadows", function()
            applyPreset("BSL")
        end)
        PacksTab:AddButton("SEUS Renewed - High Dynamic Range & Raytraced", function()
            applyPreset("SEUS")
        end)
        PacksTab:AddButton("Cyberpunk RTX - Vibrant Neon Specular & Deep Ambient", function()
            applyPreset("Cyberpunk")
        end)
        PacksTab:AddButton("Golden Hour - Warm Sunset & Amber Rim Lights", function()
            applyPreset("GoldenHour")
        end)
        PacksTab:AddButton("Rainy Noir - Atmospheric Overcast & Wet Surfaces", function()
            applyPreset("RainyNoir")
        end)
        PacksTab:AddButton("Reset Default - Vanilla Game Lighting", function()
            applyPreset("Default")
        end)

        PacksTab:AddSection("Developer Preset Stripper")
        PacksTab:AddToggle("Strip Developer Lighting Overrides", ShadersState.DevPresetsStripped, function(v)
            if v then
                stripDeveloperEffects()
                Notify("Dev Stripper", "Developer post-effects cached & disabled", 2, Theme.Green)
            else
                restoreDeveloperEffects()
                Notify("Dev Stripper", "Developer post-effects restored", 2, Theme.Green)
            end
        end)
        PacksTab:AddButton("Restore Developer PostEffects & Sky", function()
            restoreDeveloperEffects()
            Notify("Dev Stripper", "Clean restoration finished", 2, Theme.Green)
        end)
    end

    do
        SkyTab:AddSection("HD Atmospheric Skybox Presets")
        SkyTab:AddButton("Clear Azure Day - Crisp Blue Horizon", function()
            setSkybox("ClearDay")
        end)
        SkyTab:AddButton("Realistic Cumulus - Fluffy Cloud Formations", function()
            setSkybox("Cumulus")
        end)
        SkyTab:AddButton("Golden Sunset - Rich Amber Sunset Glow", function()
            setSkybox("GoldenSunset")
        end)
        SkyTab:AddButton("Milky Way Galaxy - Deep Cosmic Starlight", function()
            setSkybox("MilkyWay")
        end)
        SkyTab:AddButton("Stylized Anime - Dramatic Painted Horizon", function()
            setSkybox("AnimeSky")
        end)
        SkyTab:AddButton("Vanilla Default Skybox", function()
            setSkybox("Default")
        end)

        SkyTab:AddSection("Custom Skybox Loader")
        SkyTab:AddInput("Paste Asset ID (e.g. 159454299)", "LOAD SKY", function(txt)
            local raw = txt:gsub("%s+", "")
            local id = raw:match("%d+")
            if id then
                setSkybox("Custom", "rbxassetid://" .. id)
                Notify("Skybox", "Loaded custom asset: " .. id, 2.5, Theme.Green)
            else
                Notify("Skybox", "Invalid Asset ID entered", 2, Theme.Red)
            end
        end)

        SkyTab:AddSection("3D Volumetric Clouds")
        SkyTab:AddToggle("3D Procedural Clouds", Clouds.Enabled, function(v)
            Clouds.Enabled = v
            Notify("Clouds", v and "3D Clouds Enabled" or "3D Clouds Disabled", 2, Theme.Green)
        end)
        SkyTab:AddSlider("Cloud Cover %", 0, 100, math.round(Clouds.Cover * 100), function(v)
            Clouds.Cover = v / 100
        end)
        SkyTab:AddSlider("Cloud Density %", 0, 100, math.round(Clouds.Density * 100), function(v)
            Clouds.Density = v / 100
        end)
    end

    do
        ShadowsTab:AddSection("Lighting Technology Engine")
        ShadowsTab:AddButton("Future Lighting (Raytraced Shadows + Voxel)", function()
            setLightingTechnology(Enum.Technology.Future)
            Notify("Lighting", "Switched to Future Technology", 2, Theme.Green)
        end)
        ShadowsTab:AddButton("ShadowMap Lighting (Sharp Directional)", function()
            setLightingTechnology(Enum.Technology.ShadowMap)
            Notify("Lighting", "Switched to ShadowMap Technology", 2, Theme.Green)
        end)
        ShadowsTab:AddButton("Voxel Lighting (High FPS Compatibility)", function()
            setLightingTechnology(Enum.Technology.Voxel)
            Notify("Lighting", "Switched to Voxel Technology", 2, Theme.Green)
        end)

        ShadowsTab:AddSection("Shadow Quality & Parameters")
        ShadowsTab:AddToggle("Global Shadows", Lighting.GlobalShadows, function(v)
            Lighting.GlobalShadows = v
        end)
        ShadowsTab:AddToggle("Deep Ambient Contact Shadows", ShadersState.DeepShadowsEnabled, function(v)
            setDeepShadows(v)
        end)
        ShadowsTab:AddToggle("Force CastShadow on All Parts", ShadersState.ForceCastShadowEnabled, function(v)
            setForceCastShadow(v)
        end)
        ShadowsTab:AddSlider("Shadow Softness %", 0, 100, math.round(Lighting.ShadowSoftness * 100), function(v)
            Lighting.ShadowSoftness = v / 100
        end)
        ShadowsTab:AddSlider("Sun Latitude (Degrees)", 0, 90, math.round(Lighting.GeographicLatitude), function(v)
            Lighting.GeographicLatitude = v
        end)
    end

    do
        GodraysTab:AddSection("Volumetric Godrays Engine")
        GodraysTab:AddToggle("FXAA SunRays & Godrays", ShadersState.FXAAGodraysEnabled, function(v)
            setFXAAGodrays(v)
            Notify("Godrays", v and "FXAA Godrays Enabled" or "Godrays Disabled", 2, Theme.Green)
        end)
        GodraysTab:AddSlider("FXAA Diffusion Blur Radius", 1, 10, ShadersState.FXAABlurSize, function(v)
            ShadersState.FXAABlurSize = v
            if ShadersState.FXAAGodraysEnabled then
                FXAABlur.Size = v
            end
        end)
        GodraysTab:AddSlider("SunRay Intensity %", 0, 100, math.round(SunRays.Intensity * 100), function(v)
            SunRays.Intensity = v / 100
            SunRays.Enabled = true
        end)
        GodraysTab:AddSlider("SunRay Spread %", 0, 100, math.round(SunRays.Spread * 100), function(v)
            SunRays.Spread = v / 100
            SunRays.Enabled = true
        end)
    end

    do
        ReflectionsTab:AddSection("PBR Material Reflections")
        ReflectionsTab:AddToggle("Real-Time Material Reflections", ShadersState.ReflectionsEnabled, function(v)
            setReflections(v)
        end)
        ReflectionsTab:AddSlider("Reflectance Level %", 0, 100, math.round(ShadersState.ReflectionIntensity * 100), function(v)
            setReflectanceLevel(v / 100)
        end)

        ReflectionsTab:AddSection("Environment Specular & Diffuse")
        ReflectionsTab:AddSlider("Environment Diffuse Scale %", 0, 100, math.round((Lighting.EnvironmentDiffuseScale or 1) * 100), function(v)
            Lighting.EnvironmentDiffuseScale = v / 100
        end)
        ReflectionsTab:AddSlider("Environment Specular Scale %", 0, 100, math.round((Lighting.EnvironmentSpecularScale or 1) * 100), function(v)
            Lighting.EnvironmentSpecularScale = v / 100
        end)
    end

    do
        WeatherTab:AddSection("Dynamic Volumetric Weather")
        WeatherTab:AddToggle("Volumetric Rain Particles", ShadersState.RainEnabled, function(v)
            setRainEffect(v)
        end)
        WeatherTab:AddSlider("Rain Particle Density", 10, 300, math.round(ShadersState.RainIntensity * 100), function(v)
            ShadersState.RainIntensity = v / 100
            if ShadersState.RainEnabled then
                setRainEffect(true)
            end
        end)

        WeatherTab:AddSection("Atmospheric Fog & Time")
        WeatherTab:AddSlider("Time of Day (ClockTime)", 0, 24, math.round(Lighting.ClockTime), function(v)
            Lighting.ClockTime = v
        end)
        WeatherTab:AddSlider("Fog Distance (Studs)", 50, 2500, math.round(Lighting.FogEnd), function(v)
            Lighting.FogEnd = v
        end)
    end

    do
        LensTab:AddSection("Camera Lens & Optical FX")
        LensTab:AddToggle("Auto-Focus Depth of Field", ShadersState.AutoFocusEnabled, function(v)
            setAutoFocus(v)
            Notify("Lens", v and "Dynamic Auto-Focus Enabled" or "Auto-Focus Disabled", 2, Theme.Green)
        end)
        LensTab:AddToggle("Cinematic Lens Vignette", ShadersState.VignetteEnabled, function(v)
            ShadersState.VignetteEnabled = v
            tw(VignetteFrame, {ImageTransparency = v and 0.45 or 1}, 0.2)
        end)

        LensTab:AddSection("Color Grading & Exposure")
        LensTab:AddSlider("Exposure Compensation", -150, 150, math.round(Lighting.ExposureCompensation * 100), function(v)
            Lighting.ExposureCompensation = v / 100
        end)
        LensTab:AddSlider("Color Brightness", -50, 50, math.round(CC.Brightness * 100), function(v)
            CC.Brightness = v / 100
        end)
        LensTab:AddSlider("Color Contrast", -50, 100, math.round(CC.Contrast * 100), function(v)
            CC.Contrast = v / 100
        end)
        LensTab:AddSlider("Color Saturation", -100, 100, math.round(CC.Saturation * 100), function(v)
            CC.Saturation = v / 100
        end)

        LensTab:AddSection("Bloom Optics")
        LensTab:AddSlider("Bloom Intensity", 0, 200, math.round(Bloom.Intensity * 100), function(v)
            Bloom.Enabled = true
            Bloom.Intensity = v / 100
        end)
        LensTab:AddSlider("Bloom Blur Size", 1, 56, math.round(Bloom.Size), function(v)
            Bloom.Enabled = true
            Bloom.Size = v
        end)
        LensTab:AddSlider("Bloom Threshold", 0, 100, math.round(Bloom.Threshold * 100), function(v)
            Bloom.Enabled = true
            Bloom.Threshold = v / 100
        end)
    end

    do
        PhotoTab:AddSection("Cinematic Camera & Pose Lock")
        local photoToggle = PhotoTab:AddToggle("Cinematic Freecam [T]", ShadersState.CinematicEnabled, function(v)
            toggleCinematicCamera(v)
        end)
        ShadersState.SetCinematicToggleUI = photoToggle

        PhotoTab:AddToggle("Lock Animation Pose Keyframe", ShadersState.FreezePoseEnabled, function(v)
            ShadersState.FreezePoseEnabled = v
            if ShadersState.CinematicEnabled then
                setFreezePose(v)
            end
        end)
        PhotoTab:AddToggle("Hold RMB to Steer / Freelook", ShadersState.HoldRMBToSteer, function(v)
            ShadersState.HoldRMBToSteer = v
        end)

        PhotoTab:AddSection("Flight & Optical Zoom")
        PhotoTab:AddSlider("Flight Speed (Studs/s)", 5, 150, ShadersState.CinematicSpeed, function(v)
            ShadersState.CinematicSpeed = v
        end)
        PhotoTab:AddSlider("Camera Field of View (FOV)", 15, 120, math.round(Camera.FieldOfView), function(v)
            Camera.FieldOfView = v
        end)

        PhotoTab:AddSection("Screenshot Shortcuts & Framing")
        PhotoTab:AddButton("Frame Camera On Character (Front Portrait)", function()
            if not ShadersState.CinematicEnabled then
                toggleCinematicCamera(true)
            end
            focusCameraOnCharacter()
            Notify("Photo Mode", "Camera framed in front of character", 2, Theme.Green)
        end)
        PhotoTab:AddButton("Hide UI for Clean Screenshot [H]", function()
            setVisible(false)
            Notify("Photo Mode", "UI hidden. Press [H] or [RightShift] to restore.", 3, Theme.Accent)
        end)
        PhotoTab:AddButton("Freecam Controls: W/A/S/D fly, Q/E vertical, Shift boost", function() end)
    end

    do
        CreditsTab:AddSection("Community & Support")
        CreditsTab:AddButton("Eiko's Shaders v2.5 - Eikovo / Scriptslow", function() end)
        CreditsTab:AddButton("Copy Discord Invite Link", function()
            if copyText("https://discord.gg/P7fuzYj5xK") then
                Notify("Discord", "Copied invite link to clipboard!", 2.5, Theme.Green)
            end
        end)
        CreditsTab:AddButton("Discord Server: discord.gg/P7fuzYj5xK", function()
            copyText("https://discord.gg/P7fuzYj5xK")
        end)
        CreditsTab:AddButton("GitHub Repository: Eiko", function()
            if copyText("find it yourself <3") then
                Notify("GitHub", "text copied", 2.5, Theme.Accent)
            end
        end)
        CreditsTab:AddButton("Press [RightShift] to toggle menu, [T] for Photo Mode", function() end)
    end
end

Notify("NIX Shaders", "v2.5 loaded. Press RightShift to toggle, T for Photo Mode.", 3, Theme.Green)
task.spawn(function()
    setVisible(true)
end)
