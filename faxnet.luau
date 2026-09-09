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
        if ok and h then return h end
    end
    local cg = nil
    pcall(function() cg = game:GetService("CoreGui") end)
    if cg then
        local canUse = pcall(function()
            local t = Instance.new("ScreenGui")
            t.Parent = cg
            t:Destroy()
        end)
        if canUse then return cg end
    end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
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
                local old = c:FindFirstChild("FaxNetUI")
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
    Yellow        = Color3.fromRGB(240, 190, 60)
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

local FaxState = {
    Logs = {},
    MaxLogs = 120,
    NilResults = {},
    ModuleResults = {},
    FilteredModules = {},
    RemoteResults = {},
    HijackedConns = {},
    MutedCount = 0,
    RefreshLogs = nil
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FaxNetUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
do
    local ok = pcall(function() ScreenGui.Parent = guiParent end)
    if not ok or not ScreenGui.Parent then
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
            if pg then ScreenGui.Parent = pg end
        end)
    end
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
    nT.Font = Enum.Font.GothamBold
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
MainFrame.Size = UDim2.new(0, 660, 0, 480)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
do
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Border
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = MainFrame
end

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local setVisible
do
    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = Theme.Border
    tbStroke.Thickness = 1
    tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tbStroke.Parent = TopBar
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0, 130, 1, 0)
    tl.Position = UDim2.new(0, 14, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "F A X N E T"
    tl.TextColor3 = Theme.TextPrimary
    tl.Font = Enum.Font.GothamBlack
    tl.TextSize = 13
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = TopBar
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 240, 1, 0)
    st.Position = UDim2.new(0, 120, 0, 0)
    st.BackgroundTransparency = 1
    st.Text = "v 2 . 0  *  RSHIFT TOGGLE"
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
    cb.Font = Enum.Font.GothamBold
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
        local newX = framePos.X.Offset + d.X
        local newY = framePos.Y.Offset + d.Y
        local vpSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local minX = -(MainFrame.AbsoluteSize.X - 80)
        local maxX = vpSize.X - 80
        local minY = 0
        local maxY = vpSize.Y - 42
        newX = math.clamp(newX, minX, maxX)
        newY = math.clamp(newY, minY, maxY)
        MainFrame.Position = UDim2.new(framePos.X.Scale, newX, framePos.Y.Scale, newY)
    end
end)

local isVisible = true
setVisible = function(v)
    isVisible = v
    if v then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 660, 0, 0)
        MainFrame.BackgroundTransparency = 1
        tw(MainFrame, {Size = UDim2.new(0, 660, 0, 480), BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Back)
    else
        tw(MainFrame, {Size = UDim2.new(0, 660, 0, 0), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
end

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
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
    btn.Font = Enum.Font.GothamMedium
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
    table.insert(FaxState.Logs, {Time = ts, Tag = tag, Message = tostring(msg), Color = color or Theme.TextPrimary})
    if #FaxState.Logs > FaxState.MaxLogs then
        table.remove(FaxState.Logs, 1)
    end
    if FaxState.RefreshLogs then
        task.spawn(FaxState.RefreshLogs)
    end
end

local function makeButton(parent, text, color, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 28)
    btn.BackgroundColor3 = color or Theme.ElementBg
    btn.Text = text
    btn.TextColor3 = (color == Theme.Accent and Theme.TabActiveText) or Theme.TextPrimary
    btn.Font = Enum.Font.GothamBold
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
    local TabNil = createTab("Nil Scanner")
    local TabModules = createTab("Module Hunter")
    local TabRemotes = createTab("Remote Spy")
    local TabSignals = createTab("Signal Hijack")
    local TabEnv = createTab("Environment")
    local TabConsole = createTab("Console")
    local TabCredits = createTab("Credits")

    do
        local page = TabNil.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Scan parentless nil instances in memory"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow
        local scroll = makeScrollPanel(page, 44)
        local function refreshNilList()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, item in ipairs(FaxState.NilResults) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 26)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)
                local classColor = Theme.TextPrimary
                local cn = item.ClassName
                if cn:find("RemoteEvent") then classColor = Theme.Cyan
                elseif cn:find("RemoteFunction") then classColor = Theme.Yellow
                elseif cn:find("Script") then classColor = Theme.Red
                elseif cn:find("Bindable") then classColor = Theme.Green
                end
                local cLbl = Instance.new("TextLabel")
                cLbl.Size = UDim2.new(0, 120, 1, 0)
                cLbl.Position = UDim2.new(0, 8, 0, 0)
                cLbl.BackgroundTransparency = 1
                cLbl.Text = cn
                cLbl.TextColor3 = classColor
                cLbl.Font = Enum.Font.GothamBold
                cLbl.TextSize = 9
                cLbl.TextXAlignment = Enum.TextXAlignment.Left
                cLbl.Parent = row
                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(1, -135, 1, 0)
                nLbl.Position = UDim2.new(0, 130, 0, 0)
                nLbl.BackgroundTransparency = 1
                nLbl.Text = item.Name
                nLbl.TextColor3 = Theme.TextPrimary
                nLbl.Font = Enum.Font.Gotham
                nLbl.TextSize = 9
                nLbl.TextXAlignment = Enum.TextXAlignment.Left
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = row
                local rowBtn = Instance.new("TextButton")
                rowBtn.Size = UDim2.new(1, 0, 1, 0)
                rowBtn.BackgroundTransparency = 1
                rowBtn.Text = ""
                rowBtn.Parent = row
                rowBtn.MouseButton1Click:Connect(function()
                    if copyText(cn .. " : " .. item.Name) then
                        Notify("Copied", cn .. " : " .. item.Name, 1.5, Theme.Cyan)
                    end
                end)
            end
        end
        local scanBtn = makeButton(topRow, "SCAN NIL INSTANCES", Theme.Accent, function()
            statusLbl.Text = "Scanning parentless memory..."
            if not getnilinstances then
                appendLog("NIL", "getnilinstances not supported", Theme.Red)
                statusLbl.Text = "getnilinstances unsupported"
                Notify("Error", "getnilinstances not available", 2, Theme.Red)
                return
            end
            local list = getnilinstances()
            local highVal = {}
            for _, inst in ipairs(list) do
                pcall(function()
                    local c = inst.ClassName
                    if c:find("Remote") or c:find("Bindable") or c:find("Script") or c:find("Tool") or c:find("Value") then
                        table.insert(highVal, {Name = inst.Name, ClassName = c, Obj = inst})
                    end
                end)
            end
            FaxState.NilResults = highVal
            statusLbl.Text = string.format("Found %d total, %d high-value", #list, #highVal)
            appendLog("NIL", string.format("Scanned %d nil objects, filtered %d", #list, #highVal), Theme.Green)
            Notify("Nil Scanner", string.format("%d high-value instances found", #highVal), 2.5, Theme.Green)
            refreshNilList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)
        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            if #FaxState.NilResults == 0 then
                Notify("Nil Scanner", "No results. Run scan first.", 2, Theme.Yellow)
                return
            end
            local lines = {"=== FAXNET NIL INSTANCES ==="}
            for i, item in ipairs(FaxState.NilResults) do
                table.insert(lines, string.format("[%d] [%s] %s", i, item.ClassName, item.Name))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d nil instances copied", #FaxState.NilResults), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabModules.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(0, 200, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Scan all loaded game modules"
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
        searchBox.PlaceholderText = "FILTER MODULES..."
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
        local function refreshModuleList()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for idx, item in ipairs(FaxState.FilteredModules) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 24)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)
                local pLbl = Instance.new("TextLabel")
                pLbl.Size = UDim2.new(1, -12, 1, 0)
                pLbl.Position = UDim2.new(0, 8, 0, 0)
                pLbl.BackgroundTransparency = 1
                pLbl.Text = item.Path
                pLbl.TextColor3 = Theme.TextPrimary
                pLbl.Font = Enum.Font.Gotham
                pLbl.TextSize = 9
                pLbl.TextXAlignment = Enum.TextXAlignment.Left
                pLbl.TextTruncate = Enum.TextTruncate.AtEnd
                pLbl.Parent = row
                local rowBtn = Instance.new("TextButton")
                rowBtn.Size = UDim2.new(1, 0, 1, 0)
                rowBtn.BackgroundTransparency = 1
                rowBtn.Text = ""
                rowBtn.Parent = row
                rowBtn.MouseButton1Click:Connect(function()
                    if copyText(item.Path) then
                        Notify("Copied", item.Name, 1.5, Theme.Cyan)
                    end
                end)
            end
        end
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = searchBox.Text:lower()
            if query == "" then
                FaxState.FilteredModules = FaxState.ModuleResults
            else
                FaxState.FilteredModules = {}
                for _, item in ipairs(FaxState.ModuleResults) do
                    if item.Path:lower():find(query, 1, true) then
                        table.insert(FaxState.FilteredModules, item)
                    end
                end
            end
            refreshModuleList()
        end)
        local scanBtn = makeButton(topRow, "SCAN MODULES", Theme.Accent, function()
            statusLbl.Text = "Scanning loaded modules..."
            if not getloadedmodules then
                appendLog("MODULE", "getloadedmodules not supported", Theme.Red)
                statusLbl.Text = "getloadedmodules unsupported"
                Notify("Error", "getloadedmodules not available", 2, Theme.Red)
                return
            end
            local list = getloadedmodules()
            local gameMods = {}
            for _, mod in ipairs(list) do
                pcall(function()
                    local path = mod:GetFullName()
                    if not path:find("CorePackages") and not path:find("CoreGui") then
                        table.insert(gameMods, {Name = mod.Name, Path = path, Obj = mod})
                    end
                end)
            end
            FaxState.ModuleResults = gameMods
            FaxState.FilteredModules = gameMods
            searchBox.Text = ""
            statusLbl.Text = string.format("Found %d game modules", #gameMods)
            appendLog("MODULE", string.format("Scanned %d modules, %d game-relevant", #list, #gameMods), Theme.Green)
            Notify("Module Hunter", string.format("%d game modules found", #gameMods), 2.5, Theme.Green)
            refreshModuleList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)
        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            local source = FaxState.FilteredModules
            if #source == 0 then source = FaxState.ModuleResults end
            if #source == 0 then
                Notify("Module Hunter", "No modules to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== FAXNET LOADED MODULES ==="}
            for i, item in ipairs(source) do
                table.insert(lines, string.format("[%d] %s", i, item.Path))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d modules copied", #source), 2, Theme.Cyan)
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
        statusLbl.Text = "Scan all RemoteEvents and RemoteFunctions"
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
            for idx, item in ipairs(FaxState.RemoteResults) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundColor3 = Theme.Background
                row.BorderSizePixel = 0
                row.LayoutOrder = idx
                row.Parent = scroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)
                local classColor = item.ClassName == "RemoteEvent" and Theme.Cyan or Theme.Yellow
                local cLbl = Instance.new("TextLabel")
                cLbl.Size = UDim2.new(0, 14, 1, 0)
                cLbl.Position = UDim2.new(0, 6, 0, 0)
                cLbl.BackgroundTransparency = 1
                cLbl.Text = item.ClassName == "RemoteEvent" and "E" or "F"
                cLbl.TextColor3 = classColor
                cLbl.Font = Enum.Font.GothamBold
                cLbl.TextSize = 10
                cLbl.Parent = row
                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(1, -170, 1, 0)
                nLbl.Position = UDim2.new(0, 24, 0, 0)
                nLbl.BackgroundTransparency = 1
                nLbl.Text = item.Name
                nLbl.TextColor3 = Theme.TextPrimary
                nLbl.Font = Enum.Font.Gotham
                nLbl.TextSize = 9
                nLbl.TextXAlignment = Enum.TextXAlignment.Left
                nLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nLbl.Parent = row
                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(0, 50, 0, 18)
                cpBtn.Position = UDim2.new(1, -120, 0.5, -9)
                cpBtn.BackgroundColor3 = Theme.ElementBg
                cpBtn.Text = "COPY"
                cpBtn.TextColor3 = Theme.TextSecondary
                cpBtn.Font = Enum.Font.GothamBold
                cpBtn.TextSize = 8
                cpBtn.BorderSizePixel = 0
                cpBtn.Parent = row
                Instance.new("UICorner", cpBtn).CornerRadius = UDim.new(0, 3)
                cpBtn.MouseButton1Click:Connect(function()
                    if copyText(item.Path) then
                        Notify("Copied", item.Path, 1.5, Theme.Cyan)
                    end
                end)
                if item.ClassName == "RemoteEvent" then
                    local fireBtn = Instance.new("TextButton")
                    fireBtn.Size = UDim2.new(0, 55, 0, 18)
                    fireBtn.Position = UDim2.new(1, -62, 0.5, -9)
                    fireBtn.BackgroundColor3 = Theme.Red
                    fireBtn.Text = "FIRE"
                    fireBtn.TextColor3 = Theme.TextPrimary
                    fireBtn.Font = Enum.Font.GothamBold
                    fireBtn.TextSize = 8
                    fireBtn.BorderSizePixel = 0
                    fireBtn.Parent = row
                    Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 3)
                    fireBtn.MouseButton1Click:Connect(function()
                        pcall(function() item.Obj:FireServer() end)
                        Notify("Fired", item.Name .. " (no args)", 1.5, Theme.Red)
                        appendLog("REMOTE", "Fired " .. item.Name, Theme.Red)
                    end)
                end
            end
        end
        local scanBtn = makeButton(topRow, "SCAN REMOTES", Theme.Accent, function()
            statusLbl.Text = "Scanning game remotes..."
            local results = {}
            local containers = {ReplicatedStorage, workspace}
            pcall(function() table.insert(containers, Players) end)
            for _, container in ipairs(containers) do
                pcall(function()
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            table.insert(results, {
                                Name = obj.Name,
                                ClassName = obj.ClassName,
                                Path = obj:GetFullName(),
                                Obj = obj
                            })
                        end
                    end
                end)
            end
            FaxState.RemoteResults = results
            statusLbl.Text = string.format("Found %d remotes across the game", #results)
            appendLog("REMOTE", string.format("Found %d remotes", #results), Theme.Green)
            Notify("Remote Spy", string.format("%d remotes discovered", #results), 2.5, Theme.Green)
            refreshRemoteList()
        end)
        scanBtn.Position = UDim2.new(1, -270, 0.5, -14)
        local copyBtn = makeButton(topRow, "COPY ALL", Theme.ElementBg, function()
            if #FaxState.RemoteResults == 0 then
                Notify("Remote Spy", "No remotes to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== FAXNET REMOTE SPY ==="}
            for i, item in ipairs(FaxState.RemoteResults) do
                table.insert(lines, string.format("[%d] [%s] %s", i, item.ClassName, item.Path))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d remotes copied", #FaxState.RemoteResults), 2, Theme.Cyan)
            end
        end)
        copyBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabSignals.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -280, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Hijack and mute game signal listeners"
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
        statBox.Text = "Status: Idle"
        statBox.TextColor3 = Theme.Cyan
        statBox.Font = Enum.Font.GothamBold
        statBox.TextSize = 12
        statBox.BorderSizePixel = 0
        statBox.Parent = midFrame
        Instance.new("UICorner", statBox).CornerRadius = UDim.new(0, 4)
        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1, -24, 0, 120)
        descBox.Position = UDim2.new(0, 12, 0, 70)
        descBox.BackgroundTransparency = 1
        descBox.Text = "CONNECTION HIJACKING:" .. string.char(10) .. string.char(10) .. "1. MUTE calls conn:Disable() on RemoteEvent listeners across" .. string.char(10) .. "   ReplicatedStorage, Workspace, and Players." .. string.char(10) .. "2. Client scripts stop receiving server packets directly." .. string.char(10) .. "3. FaxNet sits in the middle for full packet control." .. string.char(10) .. string.char(10) .. "RESTORE re-enables all previously disabled connections."
        descBox.TextColor3 = Theme.TextSecondary
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 9
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Parent = midFrame
        local muteBtn = makeButton(topRow, "MUTE LISTENERS", Theme.Red, function()
            if not getconnections then
                appendLog("SIGNAL", "getconnections not supported", Theme.Red)
                Notify("Error", "getconnections not available", 2, Theme.Red)
                return
            end
            local count = 0
            FaxState.HijackedConns = {}
            local containers = {ReplicatedStorage, workspace}
            pcall(function() table.insert(containers, Players) end)
            for _, container in ipairs(containers) do
                pcall(function()
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local conns = getconnections(obj.OnClientEvent)
                            for _, conn in ipairs(conns) do
                                if conn.Disable then
                                    conn:Disable()
                                    table.insert(FaxState.HijackedConns, conn)
                                    count = count + 1
                                end
                            end
                        end
                    end
                end)
            end
            FaxState.MutedCount = count
            statBox.Text = string.format("MUTED: %d listeners disabled", count)
            statBox.TextColor3 = Theme.Red
            appendLog("SIGNAL", string.format("Muted %d game listeners", count), Theme.Red)
            Notify("Signal Hijack", string.format("%d listeners muted", count), 2.5, Theme.Red)
        end)
        muteBtn.Position = UDim2.new(1, -270, 0.5, -14)
        local restoreBtn = makeButton(topRow, "RESTORE", Theme.Green, function()
            local count = 0
            for _, conn in ipairs(FaxState.HijackedConns) do
                if conn.Enable then
                    conn:Enable()
                    count = count + 1
                end
            end
            FaxState.HijackedConns = {}
            FaxState.MutedCount = 0
            statBox.Text = string.format("RESTORED: %d listeners re-enabled", count)
            statBox.TextColor3 = Theme.Green
            appendLog("SIGNAL", string.format("Restored %d listeners", count), Theme.Green)
            Notify("Signal Hijack", string.format("%d listeners restored", count), 2.5, Theme.Green)
        end)
        restoreBtn.Position = UDim2.new(1, -135, 0.5, -14)
    end

    do
        local page = TabEnv.Page
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 36)
        topRow.BackgroundTransparency = 1
        topRow.Parent = page
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -140, 1, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Executor environment capability report"
        statusLbl.TextColor3 = Theme.TextSecondary
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Parent = topRow
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, -44)
        scroll.Position = UDim2.new(0, 0, 0, 44)
        scroll.BackgroundColor3 = Theme.ElementBg
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = Theme.BorderBright
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = page
        Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
        local scSt = Instance.new("UIStroke")
        scSt.Color = Theme.Border
        scSt.Thickness = 1
        scSt.Parent = scroll
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.5, -6, 0, 28)
        grid.CellPadding = UDim2.new(0, 6, 0, 4)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = scroll
        local gridPad = Instance.new("UIPadding")
        gridPad.PaddingTop = UDim.new(0, 6)
        gridPad.PaddingLeft = UDim.new(0, 6)
        gridPad.PaddingRight = UDim.new(0, 6)
        gridPad.PaddingBottom = UDim.new(0, 6)
        gridPad.Parent = scroll
        local function populateEnv()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local checks = {}
            local function chk(name, val)
                table.insert(checks, {Name = name, Available = val ~= nil})
            end
            chk("getnilinstances", getnilinstances)
            chk("getloadedmodules", getloadedmodules)
            chk("getconnections", getconnections)
            chk("getgenv", getgenv)
            chk("getrenv", getrenv)
            chk("getrawmetatable", getrawmetatable)
            chk("hookmetamethod", hookmetamethod)
            chk("hookfunction", hookfunction)
            chk("newcclosure", newcclosure)
            chk("iscclosure", iscclosure)
            chk("islclosure", islclosure)
            chk("checkcaller", checkcaller)
            chk("getnamecallmethod", getnamecallmethod)
            chk("setreadonly", setreadonly)
            chk("isreadonly", isreadonly)
            chk("firetouchinterest", firetouchinterest)
            chk("fireclickdetector", fireclickdetector)
            chk("setclipboard", setclipboard)
            chk("getgc", getgc)
            chk("isexecutorclosure", isexecutorclosure)
            chk("gethui", gethui)
            chk("getinstances", getinstances)
            local dbgInfo = nil
            pcall(function() dbgInfo = debug.getinfo end)
            chk("debug.getinfo", dbgInfo)
            local dbgGetup = nil
            pcall(function() dbgGetup = debug.getupvalue end)
            chk("debug.getupvalue", dbgGetup)
            local dbgSetup = nil
            pcall(function() dbgSetup = debug.setupvalue end)
            chk("debug.setupvalue", dbgSetup)
            local avail = 0
            for idx, c in ipairs(checks) do
                if c.Available then avail = avail + 1 end
                local cell = Instance.new("Frame")
                cell.BackgroundColor3 = Theme.Background
                cell.BorderSizePixel = 0
                cell.LayoutOrder = idx
                cell.Parent = scroll
                Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 4)
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = c.Name
                nameLbl.TextColor3 = Theme.TextPrimary
                nameLbl.Font = Enum.Font.Gotham
                nameLbl.TextSize = 9
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = cell
                local stLbl = Instance.new("TextLabel")
                stLbl.Size = UDim2.new(0.4, -8, 1, 0)
                stLbl.Position = UDim2.new(0.6, 0, 0, 0)
                stLbl.BackgroundTransparency = 1
                stLbl.Text = c.Available and "AVAILABLE" or "MISSING"
                stLbl.TextColor3 = c.Available and Theme.Green or Theme.Red
                stLbl.Font = Enum.Font.GothamBold
                stLbl.TextSize = 9
                stLbl.TextXAlignment = Enum.TextXAlignment.Right
                stLbl.Parent = cell
            end
            statusLbl.Text = string.format("%d / %d functions available", avail, #checks)
            appendLog("ENV", string.format("Environment: %d/%d available", avail, #checks), Theme.Green)
        end
        local scanBtn = makeButton(topRow, "SCAN ENVIRONMENT", Theme.Accent, function()
            populateEnv()
            Notify("Environment", "Capability scan complete", 2, Theme.Green)
        end)
        scanBtn.Position = UDim2.new(1, -135, 0.5, -14)
        task.defer(populateEnv)
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
        statusLbl.Text = "FaxNet internal execution log"
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
            for idx, log in ipairs(FaxState.Logs) do
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
                tagLbl.Font = Enum.Font.GothamBold
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
        FaxState.RefreshLogs = refreshLogs
        local clearBtn = makeButton(topRow, "CLEAR LOGS", Theme.ElementBg, function()
            FaxState.Logs = {}
            refreshLogs()
            Notify("Console", "Logs cleared", 1.5, Theme.TextSecondary)
        end)
        clearBtn.Position = UDim2.new(1, -270, 0.5, -14)
        local copyBtn = makeButton(topRow, "COPY ALL LOGS", Theme.Accent, function()
            if #FaxState.Logs == 0 then
                Notify("Console", "No logs to copy", 2, Theme.Yellow)
                return
            end
            local lines = {"=== FAXNET CONSOLE LOGS ==="}
            for _, l in ipairs(FaxState.Logs) do
                table.insert(lines, string.format("[%s] [%s] %s", l.Time, l.Tag, l.Message))
            end
            if copyText(table.concat(lines, string.char(10))) then
                Notify("Copied", string.format("%d log entries copied", #FaxState.Logs), 2, Theme.Cyan)
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
        titleLbl.Position = UDim2.new(0, 0, 0, 60)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "F A X N E T"
        titleLbl.TextColor3 = Theme.TextPrimary
        titleLbl.Font = Enum.Font.GothamBlack
        titleLbl.TextSize = 28
        titleLbl.Parent = center
        local verLbl = Instance.new("TextLabel")
        verLbl.Size = UDim2.new(1, 0, 0, 20)
        verLbl.Position = UDim2.new(0, 0, 0, 100)
        verLbl.BackgroundTransparency = 1
        verLbl.Text = "v 2 . 0"
        verLbl.TextColor3 = Theme.TextSecondary
        verLbl.Font = Enum.Font.Gotham
        verLbl.TextSize = 14
        verLbl.Parent = center
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(0, 120, 0, 1)
        divider.Position = UDim2.new(0.5, -60, 0, 135)
        divider.BackgroundColor3 = Theme.Border
        divider.BorderSizePixel = 0
        divider.Parent = center
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 20)
        descLbl.Position = UDim2.new(0, 0, 0, 150)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = "Hookless Reverse Engineering Toolkit"
        descLbl.TextColor3 = Theme.TextSecondary
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 11
        descLbl.Parent = center
        local divider2 = Instance.new("Frame")
        divider2.Size = UDim2.new(0, 60, 0, 1)
        divider2.Position = UDim2.new(0.5, -30, 0, 185)
        divider2.BackgroundColor3 = Theme.Border
        divider2.BorderSizePixel = 0
        divider2.Parent = center
        local madeByLbl = Instance.new("TextLabel")
        madeByLbl.Size = UDim2.new(1, 0, 0, 18)
        madeByLbl.Position = UDim2.new(0, 0, 0, 200)
        madeByLbl.BackgroundTransparency = 1
        madeByLbl.Text = "Made by"
        madeByLbl.TextColor3 = Theme.TextSecondary
        madeByLbl.Font = Enum.Font.Gotham
        madeByLbl.TextSize = 10
        madeByLbl.Parent = center
        local authorLbl = Instance.new("TextLabel")
        authorLbl.Size = UDim2.new(1, 0, 0, 26)
        authorLbl.Position = UDim2.new(0, 0, 0, 220)
        authorLbl.BackgroundTransparency = 1
        authorLbl.Text = "Eikovo / Scriptslow"
        authorLbl.TextColor3 = Theme.Accent
        authorLbl.Font = Enum.Font.GothamBold
        authorLbl.TextSize = 16
        authorLbl.Parent = center
        local repoLbl = Instance.new("TextLabel")
        repoLbl.Size = UDim2.new(1, 0, 0, 18)
        repoLbl.Position = UDim2.new(0, 0, 0, 260)
        repoLbl.BackgroundTransparency = 1
        repoLbl.Text = "github.com/EikoAik/AikHub"
        repoLbl.TextColor3 = Theme.TextSecondary
        repoLbl.Font = Enum.Font.Gotham
        repoLbl.TextSize = 10
        repoLbl.Parent = center
        local keybindLbl = Instance.new("TextLabel")
        keybindLbl.Size = UDim2.new(1, 0, 0, 18)
        keybindLbl.Position = UDim2.new(0, 0, 1, -40)
        keybindLbl.BackgroundTransparency = 1
        keybindLbl.Text = "RSHIFT TO TOGGLE"
        keybindLbl.TextColor3 = Theme.TextSecondary
        keybindLbl.Font = Enum.Font.GothamBold
        keybindLbl.TextSize = 9
        keybindLbl.Parent = center
    end
end

appendLog("INIT", "FaxNet v2.0 initialized", Theme.Accent)
Notify("FaxNet", "Engine v2.0 loaded. Press RightShift to toggle.", 3, Theme.Green)
