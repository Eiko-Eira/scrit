local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
                local old = c:FindFirstChild("ServerScannerUI")
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
end

local Theme = {
    Background    = Color3.fromRGB(0, 0, 0),
    Header        = Color3.fromRGB(8, 8, 10),
    Sidebar       = Color3.fromRGB(4, 4, 6),
    TabActive     = Color3.fromRGB(255, 255, 255),
    TabActiveText = Color3.fromRGB(0, 0, 0),
    TabInactive   = Color3.fromRGB(8, 8, 10),
    TabInactiveText = Color3.fromRGB(130, 130, 140),
    Accent        = Color3.fromRGB(255, 255, 255),
    AccentDim     = Color3.fromRGB(180, 180, 190),
    ElementBg     = Color3.fromRGB(10, 10, 14),
    ElementHover  = Color3.fromRGB(20, 20, 26),
    ElementActive = Color3.fromRGB(32, 32, 40),
    TextPrimary   = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Border        = Color3.fromRGB(36, 36, 44),
    BorderBright  = Color3.fromRGB(255, 255, 255),
    Green         = Color3.fromRGB(80, 240, 130),
    Red           = Color3.fromRGB(240, 80, 80),
    Cyan          = Color3.fromRGB(80, 200, 255),
    Yellow        = Color3.fromRGB(240, 190, 60),
    Blurple       = Color3.fromRGB(88, 101, 242)
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local function copyText(str)
    local sc = setclipboard or toclipboard or (syn and syn.set_clipboard)
    if sc then
        pcall(function() sc(tostring(str)) end)
        return true
    end
    return false
end

local Database = {
    KnownRemotes = {
        "cves", "sync_packet", "lalol_event", "lalol", "serverside", "backdoor",
        "ss_exec", "ssexec", "runcode", "execute", "loadstring", "payload",
        "cmd_remote", "admin_remote", "hd_event", "exoliner", "saturn", "sensation",
        "nexus_remote", "quik_remote", "topkek", "cve_payload", "sync_event",
        "net_debug", "packet_dispatch", "run_server", "req_event", "asset_load",
        "inject_module", "remote_bridge", "engine_bridge", "dbg_eval"
    },
    TrojanScriptNames = {
        "vaccine", "antivirus", "clean", "antibackdoor", "antilag", "fixlag",
        "cleanlag", "fastload", "welds", "jointfix", "snap", "weldscript",
        "qperplayer", "camerascript", "animatefix", "lightingfix", "lagremover",
        "smoothshift", "soundloader", "anticheat", "security", "patcher"
    },
    SuspiciousAssetNames = {
        "adminpad", "fegunkit", "hdadmin_loader", "chassis_loader", "free_vip",
        "super_admin", "model_loader", "tree_spawner", "morph_loader", "car_spawner"
    }
}

local ScanState = {
    Logs = {},
    MaxLogs = 120,
    AssetResults = {},
    FilteredAssets = {},
    RemoteResults = {},
    DbMatches = {},
    FilteredDb = {},
    IsScanning = false,
    RefreshLogs = nil
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerScannerUI"
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

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "NotifHolder"
NotifHolder.Size = UDim2.new(0, 270, 1, -60)
NotifHolder.Position = UDim2.new(1, -280, 0, 30)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 200
NotifHolder.Parent = ScreenGui
do
    local nl = Instance.new("UIListLayout")
    nl.SortOrder = Enum.SortOrder.LayoutOrder
    nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nl.Padding = UDim.new(0, 6)
    nl.Parent = NotifHolder
end

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
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
    local cs = Instance.new("UIStroke")
    cs.Color = Theme.Border
    cs.Thickness = 1
    cs.Parent = card
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 2, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = card
    local nT = Instance.new("TextLabel")
    nT.Size = UDim2.new(1, -18, 0, 18)
    nT.Position = UDim2.new(0, 12, 0, 6)
    nT.BackgroundTransparency = 1
    nT.Text = string.upper(title)
    nT.TextColor3 = color
    nT.Font = Enum.Font.Gotham
    nT.TextSize = 11
    nT.TextXAlignment = Enum.TextXAlignment.Left
    nT.Parent = card
    local nD = Instance.new("TextLabel")
    nD.Size = UDim2.new(1, -18, 0, 18)
    nD.Position = UDim2.new(0, 12, 0, 26)
    nD.BackgroundTransparency = 1
    nD.Text = desc
    nD.TextColor3 = Theme.TextSecondary
    nD.Font = Enum.Font.Gotham
    nD.TextSize = 11
    nD.TextXAlignment = Enum.TextXAlignment.Left
    nD.Parent = card
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
MainFrame.Size = UDim2.new(0, 640, 0, 460)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
do
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Border
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = MainFrame
end

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "ServerScannerFloatToggle"
FloatToggle.Size = UDim2.new(0, 44, 0, 44)
FloatToggle.Position = UDim2.new(0, 16, 0.5, 30)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.Text = "SS"
FloatToggle.TextColor3 = Theme.Accent
FloatToggle.Font = Enum.Font.Gotham
FloatToggle.TextSize = 11
FloatToggle.BorderSizePixel = 0
FloatToggle.AutoButtonColor = false
FloatToggle.ZIndex = 150
FloatToggle.Parent = ScreenGui

local setVisible
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
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 12
TopBar.Parent = MainFrame

do
    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = Theme.Border
    tbStroke.Thickness = 1
    tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tbStroke.Parent = TopBar
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0, 180, 1, 0)
    tl.Position = UDim2.new(0, 14, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "S E R V E R  S C A N N E R"
    tl.TextColor3 = Theme.TextPrimary
    tl.Font = Enum.Font.Gotham
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = TopBar
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 240, 1, 0)
    st.Position = UDim2.new(0, 194, 0, 0)
    st.BackgroundTransparency = 1
    st.Text = "DATABASE & ASSET PROBE"
    st.TextColor3 = Theme.TextSecondary
    st.Font = Enum.Font.Gotham
    st.TextSize = 10
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = TopBar
    local sd = Instance.new("Frame")
    sd.Size = UDim2.new(0, 6, 0, 6)
    sd.Position = UDim2.new(1, -52, 0.5, -3)
    sd.BackgroundColor3 = Theme.Green
    sd.BorderSizePixel = 0
    sd.Parent = TopBar
    Instance.new("UICorner", sd).CornerRadius = UDim.new(1, 0)
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 26, 0, 26)
    cb.Position = UDim2.new(1, -34, 0.5, -13)
    cb.BackgroundColor3 = Theme.ElementBg
    cb.Text = "x"
    cb.TextColor3 = Theme.TextSecondary
    cb.Font = Enum.Font.Gotham
    cb.TextSize = 11
    cb.BorderSizePixel = 0
    cb.Parent = TopBar
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
    cb.MouseEnter:Connect(function()
        tw(cb, {BackgroundColor3 = Theme.Red, TextColor3 = Theme.Accent}, 0.12)
    end)
    cb.MouseLeave:Connect(function()
        tw(cb, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12)
    end)
    cb.MouseButton1Click:Connect(function()
        setVisible(false)
    end)
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
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
TopBar.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = inp
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if inp == dragInput and isDragging then
        local d = inp.Position - mousePos
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local halfW = 320
        local halfH = 230
        local minX = -0.5 * vp.X + halfW + 10
        local maxX = 0.5 * vp.X - halfW - 10
        local minY = -0.5 * vp.Y + halfH + 10
        local maxY = 0.5 * vp.Y - halfH - 10
        local targetX = math.clamp(framePos.X.Offset + d.X, minX, maxX)
        local targetY = math.clamp(framePos.Y.Offset + d.Y, minY, maxY)
        MainFrame.Position = UDim2.new(framePos.X.Scale, targetX, framePos.Y.Scale, targetY)
    end
end)

local isVisible = true
local isOpening = false

setVisible = function(v)
    if isOpening then return end
    isVisible = v
    if v then
        isOpening = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 600, 0, 430)
        MainFrame.BackgroundTransparency = 0.7
        tw(MainFrame, {Size = UDim2.new(0, 640, 0, 460), BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.25, function() isOpening = false end)
    else
        isOpening = true
        tw(MainFrame, {Size = UDim2.new(0, 600, 0, 430), BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
            MainFrame.Visible = false
            isOpening = false
        end)
    end
end

FloatToggle.MouseButton1Click:Connect(function()
    setVisible(not isVisible)
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.Border
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.ZIndex = 11
Sidebar.Parent = MainFrame
do
    local ss = Instance.new("UIStroke")
    ss.Color = Theme.Border
    ss.Thickness = 1
    ss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ss.Parent = Sidebar
    local sl = Instance.new("UIListLayout")
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    sl.Padding = UDim.new(0, 2)
    sl.Parent = Sidebar
    local sp = Instance.new("UIPadding")
    sp.PaddingTop = UDim.new(0, 8)
    sp.PaddingLeft = UDim.new(0, 7)
    sp.PaddingRight = UDim.new(0, 7)
    sp.Parent = Sidebar
end

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -140, 1, -42)
ContentArea.Position = UDim2.new(0, 140, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11
ContentArea.Parent = MainFrame

local AllTabs = {}
local activeTab = nil

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.TabInactive
    btn.Text = string.upper(name)
    btn.TextColor3 = Theme.TabInactiveText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    local tPad = Instance.new("UIPadding")
    tPad.PaddingLeft = UDim.new(0, 10)
    tPad.Parent = btn
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 0, 14)
    line.Position = UDim2.new(0, -2, 0.5, -7)
    line.BackgroundColor3 = Theme.Accent
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 1
    line.Parent = btn
    Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentArea
    local tabObj = {Button = btn, Page = page, Name = name, Line = line}
    local function sel()
        if activeTab and activeTab ~= tabObj then
            activeTab.Page.Visible = false
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.14)
            tw(activeTab.Line, {BackgroundTransparency = 1}, 0.14)
        end
        activeTab = tabObj
        page.Visible = true
        tw(btn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabActiveText}, 0.14)
        tw(line, {BackgroundTransparency = 0}, 0.14)
    end
    btn.MouseButton1Click:Connect(sel)
    if #AllTabs == 0 then task.defer(sel) end
    table.insert(AllTabs, tabObj)
    return tabObj
end

local function appendLog(tag, msg, color)
    local ts = os.date("%X")
    table.insert(ScanState.Logs, {Time = ts, Tag = tag, Message = tostring(msg), Color = color or Theme.TextPrimary})
    if #ScanState.Logs > ScanState.MaxLogs then
        table.remove(ScanState.Logs, 1)
    end
    if ScanState.RefreshLogs then
        task.spawn(ScanState.RefreshLogs)
    end
end

local function makeButton(parent, text, color, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 28)
    btn.BackgroundColor3 = color or Theme.ElementBg
    btn.Text = text
    btn.TextColor3 = (color == Theme.Accent and Theme.TabActiveText) or Theme.TextPrimary
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bst = Instance.new("UIStroke")
    bst.Color = Theme.Border
    bst.Thickness = 1
    bst.Parent = btn
    btn.MouseButton1Click:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.Cyan, TextColor3 = Theme.TabActiveText}, 0.08).Completed:Connect(function()
            tw(btn, {BackgroundColor3 = color or Theme.ElementBg, TextColor3 = (color == Theme.Accent and Theme.TabActiveText) or Theme.TextPrimary}, 0.12)
        end)
        if cb then task.spawn(cb) end
    end)
    return btn
end

local function makeScrollPanel(parent, yOff)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -(yOff or 44))
    scroll.Position = UDim2.new(0, 0, 0, yOff or 44)
    scroll.BackgroundColor3 = Theme.ElementBg
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Theme.BorderBright
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
    local scSt = Instance.new("UIStroke")
    scSt.Color = Theme.Border
    scSt.Thickness = 1
    scSt.Parent = scroll
    local scLay = Instance.new("UIListLayout")
    scLay.SortOrder = Enum.SortOrder.LayoutOrder
    scLay.Padding = UDim.new(0, 3)
    scLay.Parent = scroll
    local scPad = Instance.new("UIPadding")
    scPad.PaddingTop = UDim.new(0, 6)
    scPad.PaddingLeft = UDim.new(0, 6)
    scPad.PaddingRight = UDim.new(0, 6)
    scPad.Parent = scroll
    return scroll
end

do
    local TabDb = createTab("Database Hits")
    local TabAssets = createTab("Infected Assets")
    local TabRemotes = createTab("Server Remotes")
    local TabProbe = createTab("Payload Probe")
    local TabConsole = createTab("Console")
    local TabCredits = createTab("Credits")

    do
        local page = TabDb.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Database signature match scanner"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow

        local searchRow = Instance.new("Frame")
        searchRow.Size = UDim2.new(1, 0, 0, 30)
        searchRow.Position = UDim2.new(0, 0, 0, 36)
        searchRow.BackgroundTransparency = 1
        searchRow.Parent = page

        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 26)
        searchBox.BackgroundColor3 = Theme.ElementBg
        searchBox.PlaceholderText = "FILTER SIGNATURE MATCHES..."
        searchBox.PlaceholderColor3 = Theme.TextSecondary
        searchBox.Text = ""
        searchBox.TextColor3 = Theme.TextPrimary
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextSize = 10
        searchBox.BorderSizePixel = 0
        searchBox.ClearTextOnFocus = false
        searchBox.Parent = searchRow
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
        local sbSt = Instance.new("UIStroke")
        sbSt.Color = Theme.Border
        sbSt.Thickness = 1
        sbSt.Parent = searchBox
        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0, 8)
        sbPad.Parent = searchBox

        local scroll = makeScrollPanel(page, 74)

        local function refreshDbList()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, item in ipairs(ScanState.FilteredDb) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 68, 1, 0)
                badge.Position = UDim2.new(0, 6, 0, 0)
                badge.BackgroundTransparency = 1
                badge.Text = item.Threat
                badge.TextColor3 = item.ThreatColor
                badge.Font = Enum.Font.Gotham
                badge.TextSize = 9
                badge.TextXAlignment = Enum.TextXAlignment.Left
                badge.Parent = row

                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(1, -150, 1, 0)
                nLbl.Position = UDim2.new(0, 76, 0, 0)
                nLbl.BackgroundTransparency = 1
                nLbl.Text = item.Name .. " (" .. item.ClassName .. ") | " .. item.Reason
                nLbl.TextColor3 = Theme.TextPrimary
                nLbl.Font = Enum.Font.Gotham
                nLbl.TextSize = 9
                nLbl.TextXAlignment = Enum.TextXAlignment.Left
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = row

                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(0, 60, 0, 20)
                cpBtn.Position = UDim2.new(1, -66, 0.5, -10)
                cpBtn.BackgroundColor3 = Theme.ElementBg
                cpBtn.Text = "COPY PATH"
                cpBtn.TextColor3 = Theme.TextSecondary
                cpBtn.Font = Enum.Font.Gotham
                cpBtn.TextSize = 8
                cpBtn.BorderSizePixel = 0
                cpBtn.Parent = row
                Instance.new("UICorner", cpBtn).CornerRadius = UDim.new(0, 3)
                cpBtn.MouseButton1Click:Connect(function()
                    if copyText(item.Path) then
                        Notify("Copied", item.Name, 1.5, Theme.Cyan)
                    end
                end)
            end
        end

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            if q == "" then
                ScanState.FilteredDb = ScanState.DbMatches
            else
                ScanState.FilteredDb = {}
                for _, item in ipairs(ScanState.DbMatches) do
                    if item.Path:lower():find(q, 1, true) or item.Name:lower():find(q, 1, true) or item.Reason:lower():find(q, 1, true) then
                        table.insert(ScanState.FilteredDb, item)
                    end
                end
            end
            refreshDbList()
        end)

        local scanBtn = makeButton(topRow, "SCAN DATABASE", Theme.Accent, function()
            statusLbl.Text = "Scanning all instances against signature database..."
            appendLog("DATABASE", "Querying game tree against known backdoor database...", Theme.Cyan)

            local matches = {}
            local containers = {
                workspace,
                ReplicatedStorage,
                game:GetService("Lighting"),
                game:GetService("StarterGui"),
                game:GetService("StarterPack"),
                game:GetService("JointsService")
            }
            pcall(function() table.insert(containers, game:GetService("Chat")) end)
            pcall(function() table.insert(containers, game:GetService("ReplicatedFirst")) end)

            local function checkDb(obj)
                pcall(function()
                    local cn = obj.ClassName
                    local nm = obj.Name:lower()
                    local fullPath = obj:GetFullName()

                    if cn == "RemoteEvent" or cn == "RemoteFunction" then
                        for _, known in ipairs(Database.KnownRemotes) do
                            if nm == known or nm:find(known) then
                                table.insert(matches, {
                                    Name = obj.Name,
                                    ClassName = cn,
                                    Path = fullPath,
                                    Threat = "KNOWN SS",
                                    ThreatColor = Theme.Red,
                                    Reason = "Matches known backdoor remote: " .. known,
                                    Obj = obj
                                })
                                return
                            end
                        end
                    end

                    if cn == "Script" or cn == "ModuleScript" or cn == "LocalScript" then
                        for _, trojan in ipairs(Database.TrojanScriptNames) do
                            if nm == trojan or nm:find(trojan) then
                                table.insert(matches, {
                                    Name = obj.Name,
                                    ClassName = cn,
                                    Path = fullPath,
                                    Threat = "TROJAN",
                                    ThreatColor = Theme.Yellow,
                                    Reason = "Matches known trojan script alias: " .. trojan,
                                    Obj = obj
                                })
                                return
                            end
                        end
                    end

                    if cn == "Model" or cn == "Tool" or cn == "Folder" then
                        for _, sus in ipairs(Database.SuspiciousAssetNames) do
                            if nm == sus or nm:find(sus) then
                                table.insert(matches, {
                                    Name = obj.Name,
                                    ClassName = cn,
                                    Path = fullPath,
                                    Threat = "SUSPECT ASSET",
                                    ThreatColor = Theme.Cyan,
                                    Reason = "Matches infected asset model signature: " .. sus,
                                    Obj = obj
                                })
                                return
                            end
                        end
                    end
                end)
            end

            for _, cont in ipairs(containers) do
                pcall(function()
                    for _, d in ipairs(cont:GetDescendants()) do
                        checkDb(d)
                    end
                end)
            end

            if getnilinstances then
                pcall(function()
                    for _, inst in ipairs(getnilinstances()) do
                        checkDb(inst)
                    end
                end)
            end

            ScanState.DbMatches = matches
            ScanState.FilteredDb = matches
            statusLbl.Text = string.format("Database matched %d known signatures", #matches)
            appendLog("DATABASE", string.format("Database scan finished: %d exact matches found", #matches), Theme.Green)
            Notify("Database Scan", string.format("%d matches found", #matches), 2.5, Theme.Green)
            refreshDbList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)

        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            local list = ScanState.FilteredDb
            if #list == 0 then list = ScanState.DbMatches end
            if #list == 0 then
                Notify("Database", "No matches to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== SERVER SCANNER DATABASE MATCHES ==="}
            for i, item in ipairs(list) do
                table.insert(lines, string.format("[%d] [%s] %s (%s) -> %s", i, item.Threat, item.Name, item.Reason, item.Path))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d database matches copied", #list), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabAssets.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Scan game assets for hidden scripts"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow

        local searchRow = Instance.new("Frame")
        searchRow.Size = UDim2.new(1, 0, 0, 30)
        searchRow.Position = UDim2.new(0, 0, 0, 36)
        searchRow.BackgroundTransparency = 1
        searchRow.Parent = page

        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 26)
        searchBox.BackgroundColor3 = Theme.ElementBg
        searchBox.PlaceholderText = "FILTER ASSETS..."
        searchBox.PlaceholderColor3 = Theme.TextSecondary
        searchBox.Text = ""
        searchBox.TextColor3 = Theme.TextPrimary
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextSize = 10
        searchBox.BorderSizePixel = 0
        searchBox.ClearTextOnFocus = false
        searchBox.Parent = searchRow
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
        local sbSt = Instance.new("UIStroke")
        sbSt.Color = Theme.Border
        sbSt.Thickness = 1
        sbSt.Parent = searchBox
        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0, 8)
        sbPad.Parent = searchBox

        local scroll = makeScrollPanel(page, 74)

        local function refreshAssetList()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, item in ipairs(ScanState.FilteredAssets) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 60, 1, 0)
                badge.Position = UDim2.new(0, 6, 0, 0)
                badge.BackgroundTransparency = 1
                badge.Text = item.Tag or "SCRIPT"
                badge.TextColor3 = item.TagColor or Theme.Red
                badge.Font = Enum.Font.Gotham
                badge.TextSize = 9
                badge.TextXAlignment = Enum.TextXAlignment.Left
                badge.Parent = row

                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(1, -140, 1, 0)
                nLbl.Position = UDim2.new(0, 70, 0, 0)
                nLbl.BackgroundTransparency = 1
                nLbl.Text = item.Name .. " (" .. item.ClassName .. ") in " .. item.ParentName
                nLbl.TextColor3 = Theme.TextPrimary
                nLbl.Font = Enum.Font.Gotham
                nLbl.TextSize = 9
                nLbl.TextXAlignment = Enum.TextXAlignment.Left
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = row

                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(0, 60, 0, 20)
                cpBtn.Position = UDim2.new(1, -66, 0.5, -10)
                cpBtn.BackgroundColor3 = Theme.ElementBg
                cpBtn.Text = "COPY PATH"
                cpBtn.TextColor3 = Theme.TextSecondary
                cpBtn.Font = Enum.Font.Gotham
                cpBtn.TextSize = 8
                cpBtn.BorderSizePixel = 0
                cpBtn.Parent = row
                Instance.new("UICorner", cpBtn).CornerRadius = UDim.new(0, 3)
                cpBtn.MouseButton1Click:Connect(function()
                    if copyText(item.Path) then
                        Notify("Copied", item.Name, 1.5, Theme.Cyan)
                    end
                end)
            end
        end

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            if q == "" then
                ScanState.FilteredAssets = ScanState.AssetResults
            else
                ScanState.FilteredAssets = {}
                for _, item in ipairs(ScanState.AssetResults) do
                    if item.Path:lower():find(q, 1, true) or item.Name:lower():find(q, 1, true) then
                        table.insert(ScanState.FilteredAssets, item)
                    end
                end
            end
            refreshAssetList()
        end)

        local scanBtn = makeButton(topRow, "SCAN ASSETS", Theme.Accent, function()
            if ScanState.IsScanning then return end
            ScanState.IsScanning = true
            statusLbl.Text = "Scanning game tree and nil memory..."
            appendLog("SCAN", "Starting full asset and hidden script scan...", Theme.Cyan)

            local flagged = {}
            local containers = {
                workspace,
                ReplicatedStorage,
                game:GetService("Lighting"),
                game:GetService("StarterGui"),
                game:GetService("StarterPack"),
                game:GetService("JointsService")
            }
            pcall(function() table.insert(containers, game:GetService("Chat")) end)
            pcall(function() table.insert(containers, game:GetService("ReplicatedFirst")) end)

            local function checkInstance(obj)
                pcall(function()
                    local cn = obj.ClassName
                    local nm = obj.Name:lower()
                    local p = obj.Parent
                    local pName = p and p.Name or "Nil"
                    local fullPath = obj:GetFullName()

                    local isSuspicious = false
                    local tag = "ASSET"
                    local tagColor = Theme.Yellow

                    if cn == "Script" then
                        isSuspicious = true
                        tag = "SERVER"
                        tagColor = Theme.Red
                    elseif cn == "ModuleScript" then
                        if nm:find("require") or nm:find("backdoor") or nm:find("load") or nm:find("cve") or nm:find("inject") or nm:find("ss") or nm:find("payload") or nm:find("sync") or #nm > 28 then
                            isSuspicious = true
                            tag = "MODULE"
                            tagColor = Theme.Yellow
                        end
                    elseif cn == "Tool" or cn == "Model" or cn == "Folder" then
                        for _, sub in ipairs(obj:GetChildren()) do
                            if sub:IsA("LuaSourceContainer") or sub:IsA("RemoteEvent") or sub:IsA("RemoteFunction") then
                                local sn = sub.Name:lower()
                                if sn:find("backdoor") or sn:find("require") or sn:find("exec") or sn:find("server") or sn:find("payload") then
                                    isSuspicious = true
                                    tag = "INFECTED"
                                    tagColor = Theme.Red
                                    break
                                end
                            end
                        end
                    end

                    if isSuspicious then
                        table.insert(flagged, {
                            Name = obj.Name,
                            ClassName = cn,
                            ParentName = pName,
                            Path = fullPath,
                            Tag = tag,
                            TagColor = tagColor,
                            Obj = obj
                        })
                    end
                end)
            end

            for _, cont in ipairs(containers) do
                pcall(function()
                    for _, d in ipairs(cont:GetDescendants()) do
                        checkInstance(d)
                    end
                end)
            end

            if getnilinstances then
                pcall(function()
                    for _, inst in ipairs(getnilinstances()) do
                        checkInstance(inst)
                    end
                end)
            end

            ScanState.AssetResults = flagged
            ScanState.FilteredAssets = flagged
            ScanState.IsScanning = false
            statusLbl.Text = string.format("Found %d flagged assets/scripts", #flagged)
            appendLog("SCAN", string.format("Scan finished: %d flagged instances detected", #flagged), Theme.Green)
            Notify("Scan Complete", string.format("%d suspicious assets found", #flagged), 2.5, Theme.Green)
            refreshAssetList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)

        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            local list = ScanState.FilteredAssets
            if #list == 0 then list = ScanState.AssetResults end
            if #list == 0 then
                Notify("Asset Scanner", "No assets to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== SERVER SCANNER ASSET DUMP ==="}
            for i, item in ipairs(list) do
                table.insert(lines, string.format("[%d] [%s] %s -> %s", i, item.Tag, item.ClassName, item.Path))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d entries copied", #list), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabRemotes.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Scan remotes allowing server code execution"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow

        local scroll = makeScrollPanel(page, 44)

        local function refreshRemoteList()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, item in ipairs(ScanState.RemoteResults) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 40, 1, 0)
                badge.Position = UDim2.new(0, 6, 0, 0)
                badge.BackgroundTransparency = 1
                badge.Text = item.IsSuspicious and "SS" or "REMOTE"
                badge.TextColor3 = item.IsSuspicious and Theme.Red or Theme.Cyan
                badge.Font = Enum.Font.Gotham
                badge.TextSize = 9
                badge.TextXAlignment = Enum.TextXAlignment.Left
                badge.Parent = row

                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(1, -165, 1, 0)
                nLbl.Position = UDim2.new(0, 48, 0, 0)
                nLbl.BackgroundTransparency = 1
                nLbl.Text = item.Name .. " (" .. item.ClassName .. ")"
                nLbl.TextColor3 = Theme.TextPrimary
                nLbl.Font = Enum.Font.Gotham
                nLbl.TextSize = 9
                nLbl.TextXAlignment = Enum.TextXAlignment.Left
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = row

                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(0, 50, 0, 18)
                cpBtn.Position = UDim2.new(1, -114, 0.5, -9)
                cpBtn.BackgroundColor3 = Theme.ElementBg
                cpBtn.Text = "COPY"
                cpBtn.TextColor3 = Theme.TextSecondary
                cpBtn.Font = Enum.Font.Gotham
                cpBtn.TextSize = 8
                cpBtn.BorderSizePixel = 0
                cpBtn.Parent = row
                Instance.new("UICorner", cpBtn).CornerRadius = UDim.new(0, 3)
                cpBtn.MouseButton1Click:Connect(function()
                    if copyText(item.Path) then
                        Notify("Copied", item.Path, 1.5, Theme.Cyan)
                    end
                end)

                local testBtn = Instance.new("TextButton")
                testBtn.Size = UDim2.new(0, 52, 0, 18)
                testBtn.Position = UDim2.new(1, -58, 0.5, -9)
                testBtn.BackgroundColor3 = item.IsSuspicious and Theme.Red or Theme.ElementActive
                testBtn.Text = "PROBE"
                testBtn.TextColor3 = Theme.TextPrimary
                testBtn.Font = Enum.Font.Gotham
                testBtn.TextSize = 8
                testBtn.BorderSizePixel = 0
                testBtn.Parent = row
                Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 3)
                testBtn.MouseButton1Click:Connect(function()
                    appendLog("PROBE", "Probing " .. item.Name .. " for code execution...", Theme.Yellow)
                    local sent = false
                    pcall(function()
                        if item.ClassName == "RemoteEvent" then
                            item.Obj:FireServer("print('SS_EXEC_TEST')", "require")
                            sent = true
                        elseif item.ClassName == "RemoteFunction" then
                            task.spawn(function()
                                item.Obj:InvokeServer("print('SS_EXEC_TEST')", "require")
                            end)
                            sent = true
                        end
                    end)
                    if sent then
                        Notify("Probe Sent", item.Name .. " dispatched", 1.5, Theme.Green)
                    else
                        Notify("Probe Failed", "Remote blocked execution", 1.5, Theme.Red)
                    end
                end)
            end
        end

        local scanBtn = makeButton(topRow, "SCAN REMOTES", Theme.Accent, function()
            statusLbl.Text = "Scanning all game remotes..."
            local remotes = {}
            local containers = {workspace, ReplicatedStorage, game:GetService("Lighting"), game:GetService("JointsService")}
            pcall(function() table.insert(containers, Players) end)

            local function checkRemote(obj)
                pcall(function()
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local nm = obj.Name:lower()
                        local isSusp = false
                        local suspiciousWords = {
                            "backdoor", "require", "run", "exec", "loadstring", "cve", "payload",
                            "serverside", "ss", "cmd", "command", "admin", "hdadmin", "sync", "event",
                            "lalol", "inject", "developer", "lua"
                        }
                        for _, w in ipairs(suspiciousWords) do
                            if nm:find(w) then
                                isSusp = true
                                break
                            end
                        end
                        if #obj.Name > 30 or obj.Name:find("^[a-f0-9%-]+$") then
                            isSusp = true
                        end
                        table.insert(remotes, {
                            Name = obj.Name,
                            ClassName = obj.ClassName,
                            Path = obj:GetFullName(),
                            IsSuspicious = isSusp,
                            Obj = obj
                        })
                    end
                end)
            end

            for _, cont in ipairs(containers) do
                pcall(function()
                    for _, d in ipairs(cont:GetDescendants()) do
                        checkRemote(d)
                    end
                end)
            end

            if getnilinstances then
                pcall(function()
                    for _, inst in ipairs(getnilinstances()) do
                        checkRemote(inst)
                    end
                end)
            end

            table.sort(remotes, function(a, b)
                if a.IsSuspicious and not b.IsSuspicious then return true end
                return false
            end)

            ScanState.RemoteResults = remotes
            statusLbl.Text = string.format("Found %d remotes", #remotes)
            appendLog("REMOTE", string.format("Found %d remotes across the game", #remotes), Theme.Green)
            Notify("Remote Scan", string.format("%d remotes found", #remotes), 2.5, Theme.Green)
            refreshRemoteList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)

        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            if #ScanState.RemoteResults == 0 then
                Notify("Remotes", "No remotes to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== SERVER SCANNER REMOTE DUMP ==="}
            for i, item in ipairs(ScanState.RemoteResults) do
                table.insert(lines, string.format("[%d] [%s] %s", i, item.ClassName, item.Path))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d remotes copied", #ScanState.RemoteResults), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabProbe.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Batch probe candidate remotes for server execution"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow

        local midFrame = Instance.new("Frame")
        midFrame.Size = UDim2.new(1, 0, 1, -44)
        midFrame.Position = UDim2.new(0, 0, 0, 44)
        midFrame.BackgroundColor3 = Theme.ElementBg
        midFrame.BorderSizePixel = 0
        midFrame.Parent = page
        Instance.new("UICorner", midFrame).CornerRadius = UDim.new(0, 6)
        local mfSt = Instance.new("UIStroke")
        mfSt.Color = Theme.Border
        mfSt.Thickness = 1
        mfSt.Parent = midFrame

        local statBox = Instance.new("TextLabel")
        statBox.Size = UDim2.new(1, -24, 0, 50)
        statBox.Position = UDim2.new(0, 12, 0, 12)
        statBox.BackgroundColor3 = Theme.Background
        statBox.Text = "Probe Status: Ready"
        statBox.TextColor3 = Theme.Cyan
        statBox.Font = Enum.Font.Gotham
        statBox.TextSize = 12
        statBox.BorderSizePixel = 0
        statBox.Parent = midFrame
        Instance.new("UICorner", statBox).CornerRadius = UDim.new(0, 4)

        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1, -24, 0, 130)
        descBox.Position = UDim2.new(0, 12, 0, 70)
        descBox.BackgroundTransparency = 1
        descBox.Text = "HOW PAYLOAD PROBING WORKS:" .. string.char(10) .. string.char(10) .. "1. Scans all candidate RemoteEvents for backdoors and free model script entry points." .. string.char(10) .. "2. Tests payloads (loadstring, require, bytecode) non-destructively." .. string.char(10) .. "3. Detects if the server executes incoming code or creates assets." .. string.char(10) .. string.char(10) .. "Use RUN PROBE to iterate through all discovered remotes."
        descBox.TextColor3 = Theme.TextSecondary
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 9
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Parent = midFrame

        local runBtn = makeButton(topRow, "RUN PROBE", Theme.Accent, function()
            if #ScanState.RemoteResults == 0 then
                Notify("Probe", "No remotes scanned yet. Scan remotes first.", 2, Theme.Yellow)
                return
            end
            statBox.Text = "Probing " .. #ScanState.RemoteResults .. " remotes..."
            statBox.TextColor3 = Theme.Yellow
            appendLog("PROBE", "Starting batch probe across " .. #ScanState.RemoteResults .. " remotes...", Theme.Cyan)

            local dispatched = 0
            for _, item in ipairs(ScanState.RemoteResults) do
                pcall(function()
                    if item.ClassName == "RemoteEvent" then
                        item.Obj:FireServer("require", 1010101)
                        item.Obj:FireServer("loadstring", "print('PROBE')")
                        item.Obj:FireServer("print('PROBE')")
                        dispatched = dispatched + 1
                    end
                end)
            end

            statBox.Text = string.format("Probe complete: %d test payloads dispatched", dispatched)
            statBox.TextColor3 = Theme.Green
            appendLog("PROBE", string.format("Batch probe finished. Dispatched %d tests.", dispatched), Theme.Green)
            Notify("Probe Complete", string.format("%d payloads sent", dispatched), 2.5, Theme.Green)
        end)
        runBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabConsole.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Scanner execution log"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow

        local scroll = makeScrollPanel(page, 44)

        local function refreshLogs()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, log in ipairs(ScanState.Logs) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 22)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

                local tLbl = Instance.new("TextLabel")
                tLbl.Size = UDim2.new(0, 50, 1, 0)
                tLbl.Position = UDim2.new(0, 6, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Text = log.Time
                tLbl.TextColor3 = Theme.TextSecondary
                tLbl.Font = Enum.Font.Gotham
                tLbl.TextSize = 8
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.Parent = row

                local tagLbl = Instance.new("TextLabel")
                tagLbl.Size = UDim2.new(0, 65, 1, 0)
                tagLbl.Position = UDim2.new(0, 58, 0, 0)
                tagLbl.BackgroundTransparency = 1
                tagLbl.Text = "[" .. log.Tag .. "]"
                tagLbl.TextColor3 = Theme.Cyan
                tagLbl.Font = Enum.Font.Gotham
                tagLbl.TextSize = 8
                tagLbl.TextXAlignment = Enum.TextXAlignment.Left
                tagLbl.Parent = row

                local msgLbl = Instance.new("TextLabel")
                msgLbl.Size = UDim2.new(1, -130, 1, 0)
                msgLbl.Position = UDim2.new(0, 125, 0, 0)
                msgLbl.BackgroundTransparency = 1
                msgLbl.Text = log.Message
                msgLbl.TextColor3 = log.Color
                msgLbl.Font = Enum.Font.Gotham
                msgLbl.TextSize = 9
                msgLbl.TextXAlignment = Enum.TextXAlignment.Left
                msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
                msgLbl.Parent = row
            end
            scroll.CanvasPosition = Vector2.new(0, 999999)
        end
        ScanState.RefreshLogs = refreshLogs

        local clearBtn = makeButton(topRow, "CLEAR LOGS", Theme.ElementBg, function()
            ScanState.Logs = {}
            refreshLogs()
            Notify("Console", "Logs cleared", 1.5, Theme.TextSecondary)
        end)
        clearBtn.Position = UDim2.new(1, -270, 0.5, -14)

        local copyBtn = makeButton(topRow, "COPY ALL LOGS", Theme.Accent, function()
            if #ScanState.Logs == 0 then
                Notify("Console", "No logs to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== SERVER SCANNER LOGS ==="}
            for _, l in ipairs(ScanState.Logs) do
                table.insert(lines, string.format("[%s] [%s] %s", l.Time, l.Tag, l.Message))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d log entries copied", #ScanState.Logs), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
        refreshLogs()
    end

    do
        local page = TabCredits.Page
        local center = Instance.new("Frame")
        center.Size = UDim2.new(1, 0, 1, 0)
        center.BackgroundColor3 = Theme.ElementBg
        center.BorderSizePixel = 0
        center.Parent = page
        Instance.new("UICorner", center).CornerRadius = UDim.new(0, 6)
        local cSt = Instance.new("UIStroke")
        cSt.Color = Theme.Border
        cSt.Thickness = 1
        cSt.Parent = center

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, 0, 0, 40)
        titleLbl.Position = UDim2.new(0, 0, 0, 50)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "S E R V E R  S C A N N E R"
        titleLbl.TextColor3 = Theme.TextPrimary
        titleLbl.Font = Enum.Font.Gotham
        titleLbl.TextSize = 22
        titleLbl.Parent = center

        local verLbl = Instance.new("TextLabel")
        verLbl.Size = UDim2.new(1, 0, 0, 20)
        verLbl.Position = UDim2.new(0, 0, 0, 95)
        verLbl.BackgroundTransparency = 1
        verLbl.Text = "v 2 . 0"
        verLbl.TextColor3 = Theme.TextSecondary
        verLbl.Font = Enum.Font.Gotham
        verLbl.TextSize = 13
        verLbl.Parent = center

        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(0, 100, 0, 1)
        divider.Position = UDim2.new(0.5, -50, 0, 126)
        divider.BackgroundColor3 = Theme.Border
        divider.BorderSizePixel = 0
        divider.Parent = center

        local madeByLbl = Instance.new("TextLabel")
        madeByLbl.Size = UDim2.new(1, 0, 0, 18)
        madeByLbl.Position = UDim2.new(0, 0, 0, 140)
        madeByLbl.BackgroundTransparency = 1
        madeByLbl.Text = "Made by"
        madeByLbl.TextColor3 = Theme.TextSecondary
        madeByLbl.Font = Enum.Font.Gotham
        madeByLbl.TextSize = 10
        madeByLbl.Parent = center

        local authorLbl = Instance.new("TextLabel")
        authorLbl.Size = UDim2.new(1, 0, 0, 26)
        authorLbl.Position = UDim2.new(0, 0, 0, 160)
        authorLbl.BackgroundTransparency = 1
        authorLbl.Text = "Eikovo / Scriptslow"
        authorLbl.TextColor3 = Theme.Accent
        authorLbl.Font = Enum.Font.Gotham
        authorLbl.TextSize = 16
        authorLbl.Parent = center

        local discordBtn = Instance.new("TextButton")
        discordBtn.Size = UDim2.new(0, 220, 0, 34)
        discordBtn.Position = UDim2.new(0.5, -110, 0, 206)
        discordBtn.BackgroundColor3 = Theme.Blurple
        discordBtn.Text = "COPY DISCORD INVITE"
        discordBtn.TextColor3 = Theme.Accent
        discordBtn.Font = Enum.Font.Gotham
        discordBtn.TextSize = 11
        discordBtn.BorderSizePixel = 0
        discordBtn.Parent = center
        Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 5)

        local discordSub = Instance.new("TextLabel")
        discordSub.Size = UDim2.new(1, 0, 0, 18)
        discordSub.Position = UDim2.new(0, 0, 0, 246)
        discordSub.BackgroundTransparency = 1
        discordSub.Text = "discord.gg/P7fuzYj5xK"
        discordSub.TextColor3 = Theme.TextSecondary
        discordSub.Font = Enum.Font.Gotham
        discordSub.TextSize = 10
        discordSub.Parent = center

        discordBtn.MouseButton1Click:Connect(function()
            if copyText("https://discord.gg/P7fuzYj5xK") then
                Notify("Discord", "Copied invite link to clipboard!", 2.5, Theme.Cyan)
                discordBtn.Text = "COPIED TO CLIPBOARD!"
                task.delay(2, function()
                    if discordBtn and discordBtn.Parent then
                        discordBtn.Text = "COPY DISCORD INVITE"
                    end
                end)
            end
        end)

        local keybindLbl = Instance.new("TextLabel")
        keybindLbl.Size = UDim2.new(1, 0, 0, 18)
        keybindLbl.Position = UDim2.new(0, 0, 1, -34)
        keybindLbl.BackgroundTransparency = 1
        keybindLbl.Text = "RSHIFT TO TOGGLE"
        keybindLbl.TextColor3 = Theme.TextSecondary
        keybindLbl.Font = Enum.Font.Gotham
        keybindLbl.TextSize = 9
        keybindLbl.Parent = center
    end
end

appendLog("INIT", "ServerScanner v2.0 initialized with database engine", Theme.Accent)
Notify("Server Scanner", "v2.0 loaded with DB engine. Press RightShift to toggle.", 3, Theme.Green)
task.spawn(function()
    setVisible(true)
end)
