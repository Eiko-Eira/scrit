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
    local coreGui = nil
    pcall(function() coreGui = game:GetService("CoreGui") end)
    if coreGui then return coreGui end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local guiParent = getGuiParent()
do
    pcall(function()
        if guiParent:FindFirstChild("FaxNetUI") then
            guiParent.FaxNetUI:Destroy()
        end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("FaxNetUI") then
            pg.FaxNetUI:Destroy()
        end
    end)
end

local Theme = {
    Background = Color3.fromRGB(12, 12, 16),
    Header = Color3.fromRGB(18, 18, 24),
    Sidebar = Color3.fromRGB(14, 14, 20),
    TabActive = Color3.fromRGB(245, 245, 250),
    TabActiveText = Color3.fromRGB(12, 12, 16),
    TabInactive = Color3.fromRGB(20, 20, 28),
    TabInactiveText = Color3.fromRGB(135, 135, 145),
    Accent = Color3.fromRGB(0, 230, 160),
    AccentDim = Color3.fromRGB(0, 170, 120),
    Cyan = Color3.fromRGB(0, 200, 255),
    ElementBg = Color3.fromRGB(20, 20, 28),
    ElementHover = Color3.fromRGB(28, 28, 38),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Border = Color3.fromRGB(38, 38, 50),
    BorderBright = Color3.fromRGB(60, 60, 80),
    Green = Color3.fromRGB(70, 220, 120),
    Red = Color3.fromRGB(235, 70, 80),
    Yellow = Color3.fromRGB(240, 190, 60)
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
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
    MaxLogs = 80,
    NilResults = {},
    ModuleResults = {},
    HijackedConns = {},
    MutedCount = 0
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FaxNetUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = guiParent end)
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 640, 0, 450)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -225)
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
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 2)
topAccent.BackgroundColor3 = Theme.Accent
topAccent.BorderSizePixel = 0
topAccent.Parent = TopBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 160, 1, 0)
titleLbl.Position = UDim2.new(0, 14, 0, 2)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "F A X N E T  v 1 . 0"
titleLbl.TextColor3 = Theme.TextPrimary
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = TopBar

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(0, 240, 1, 0)
subTitle.Position = UDim2.new(0, 160, 0, 2)
subTitle.BackgroundTransparency = 1
subTitle.Text = "HOOKLESS ENGINE & REVERSE TOOLKIT"
subTitle.TextColor3 = Theme.TextSecondary
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 10
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = Theme.ElementBg
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 4)
cbCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Theme.Red, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.12)
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12)
end)

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
        tw(MainFrame, {Size = UDim2.new(0, 640, 0, 450), BackgroundTransparency = 0}, 0.2)
    else
        tw(MainFrame, {Size = UDim2.new(0, 640, 0, 0), BackgroundTransparency = 1}, 0.16).Completed:Connect(function()
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

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Theme.Border
sbStroke.Thickness = 1
sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sbStroke.Parent = Sidebar

local sbList = Instance.new("UIListLayout")
sbList.SortOrder = Enum.SortOrder.LayoutOrder
sbList.Padding = UDim.new(0, 4)
sbList.Parent = Sidebar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingTop = UDim.new(0, 8)
sbPad.PaddingLeft = UDim.new(0, 8)
sbPad.PaddingRight = UDim.new(0, 8)
sbPad.Parent = Sidebar

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
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.TabInactive
    btn.Text = string.upper(name)
    btn.TextColor3 = Theme.TabInactiveText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = btn

    local bPad = Instance.new("UIPadding")
    bPad.PaddingLeft = UDim.new(0, 10)
    bPad.Parent = btn

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 0, 16)
    line.Position = UDim2.new(0, -4, 0.5, -8)
    line.BackgroundColor3 = Theme.Accent
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 1
    line.Parent = btn

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentArea

    local tabObj = {Button = btn, Page = page, Name = name, Line = line}

    local function select()
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

    btn.MouseButton1Click:Connect(select)
    if #AllTabs == 0 then task.defer(select) end
    table.insert(AllTabs, tabObj)
    return tabObj
end

local TabNil = createTab("Nil Scanner")
local TabModules = createTab("Module Hunter")
local TabSignals = createTab("Signal Hijack")
local TabConsole = createTab("Console Logs")

local function appendLog(tag, msg, color)
    local timestamp = os.date("%X")
    local entry = {
        Time = timestamp,
        Tag = tag,
        Message = tostring(msg),
        Color = color or Theme.TextPrimary
    }
    table.insert(FaxState.Logs, entry)
    if #FaxState.Logs > FaxState.MaxLogs then
        table.remove(FaxState.Logs, 1)
    end
    print(string.format("[%s] [%s] %s", timestamp, tag, tostring(msg)))
    if FaxState.RefreshLogs then
        task.spawn(FaxState.RefreshLogs)
    end
end

local function makeButton(parent, text, color, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 30)
    btn.BackgroundColor3 = color or Theme.ElementBg
    btn.Text = text
    btn.TextColor3 = (color == Theme.Accent and Theme.TabActiveText) or Theme.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = btn

    local st = Instance.new("UIStroke")
    st.Color = Theme.Border
    st.Thickness = 1
    st.Parent = btn

    btn.MouseButton1Click:Connect(function()
        tw(btn, {BackgroundColor3 = Theme.Cyan, TextColor3 = Theme.TabActiveText}, 0.08).Completed:Connect(function()
            tw(btn, {BackgroundColor3 = color or Theme.ElementBg, TextColor3 = (color == Theme.Accent and Theme.TabActiveText) or Theme.TextPrimary}, 0.12)
        end)
        if cb then task.spawn(cb) end
    end)
    return btn
end

local function setupNilTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -280, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Click SCAN to inspect 1,700+ nil instances"
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
    scroll.Parent = tab.Page

    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
    local scStroke = Instance.new("UIStroke", scroll)
    scStroke.Color = Theme.Border
    scStroke.Thickness = 1

    local sLayout = Instance.new("UIListLayout")
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Padding = UDim.new(0, 3)
    sLayout.Parent = scroll

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 6)
    sPad.PaddingLeft = UDim.new(0, 6)
    sPad.PaddingRight = UDim.new(0, 6)
    sPad.Parent = scroll

    local function refreshNilList()
        scroll:ClearAllChildren()
        sLayout:Clone().Parent = scroll
        sPad:Clone().Parent = scroll

        for _, item in ipairs(FaxState.NilResults) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 24)
            row.BackgroundColor3 = Theme.Background
            row.BorderSizePixel = 0
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

            local classLbl = Instance.new("TextLabel")
            classLbl.Size = UDim2.new(0, 110, 1, 0)
            classLbl.Position = UDim2.new(0, 8, 0, 0)
            classLbl.BackgroundTransparency = 1
            classLbl.Text = item.ClassName
            classLbl.TextColor3 = Theme.Cyan
            classLbl.Font = Enum.Font.GothamBold
            classLbl.TextSize = 9
            classLbl.TextXAlignment = Enum.TextXAlignment.Left
            classLbl.Parent = row

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -125, 1, 0)
            nameLbl.Position = UDim2.new(0, 120, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = item.Name
            nameLbl.TextColor3 = Theme.TextPrimary
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextSize = 9
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row
        end
    end

    local scanBtn = makeButton(topRow, "SCAN NIL INSTANCES", Theme.Accent, function()
        statusLbl.Text = "Scanning parentless memory..."
        if not getnilinstances then
            appendLog("NIL", "getnilinstances is not supported on this executor", Theme.Red)
            statusLbl.Text = "getnilinstances unsupported!"
            return
        end
        local list = getnilinstances()
        local highValue = {}
        for _, inst in ipairs(list) do
            local c = inst.ClassName
            if c:find("Remote") or c:find("Bindable") or c:find("Script") or c:find("Tool") or c:find("Value") then
                table.insert(highValue, {Name = inst.Name, ClassName = c, Obj = inst})
            end
        end
        FaxState.NilResults = highValue
        statusLbl.Text = string.format("Found %d total, %d high-value instances", #list, #highValue)
        appendLog("NIL", string.format("Scanned %d nil objects. Filtered %d remotes/scripts/tools.", #list, #highValue), Theme.Green)
        refreshNilList()
    end)
    scanBtn.Position = UDim2.new(1, -270, 0.5, -15)

    local copyBtn = makeButton(topRow, "COPY NIL LIST", Theme.ElementBg, function()
        if #FaxState.NilResults == 0 then
            appendLog("NIL", "No nil instances to copy. Run scan first.", Theme.Yellow)
            return
        end
        local lines = {"=== FAXNET NIL INSTANCES SCAN ==="}
        for i, item in ipairs(FaxState.NilResults) do
            table.insert(lines, string.format("[%d] [%s] %s", i, item.ClassName, item.Name))
        end
        local fullText = table.concat(lines, string.char(10))
        local ok = copyText(fullText)
        if ok then
            appendLog("NIL", string.format("Copied %d nil instances to clipboard!", #FaxState.NilResults), Theme.Cyan)
        else
            appendLog("NIL", "Failed to copy to clipboard", Theme.Red)
        end
    end)
    copyBtn.Position = UDim2.new(1, -135, 0.5, -15)
end

local function setupModuleTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -280, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Filter 28,000+ cached modules for game scripts"
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
    scroll.Parent = tab.Page

    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
    local scStroke = Instance.new("UIStroke", scroll)
    scStroke.Color = Theme.Border
    scStroke.Thickness = 1

    local sLayout = Instance.new("UIListLayout")
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Padding = UDim.new(0, 3)
    sLayout.Parent = scroll

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 6)
    sPad.PaddingLeft = UDim.new(0, 6)
    sPad.PaddingRight = UDim.new(0, 6)
    sPad.Parent = scroll

    local function refreshModuleList()
        scroll:ClearAllChildren()
        sLayout:Clone().Parent = scroll
        sPad:Clone().Parent = scroll

        for _, item in ipairs(FaxState.ModuleResults) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 24)
            row.BackgroundColor3 = Theme.Background
            row.BorderSizePixel = 0
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

            local pathLbl = Instance.new("TextLabel")
            pathLbl.Size = UDim2.new(1, -12, 1, 0)
            pathLbl.Position = UDim2.new(0, 8, 0, 0)
            pathLbl.BackgroundTransparency = 1
            pathLbl.Text = item.Path
            pathLbl.TextColor3 = Theme.TextPrimary
            pathLbl.Font = Enum.Font.Gotham
            pathLbl.TextSize = 9
            pathLbl.TextXAlignment = Enum.TextXAlignment.Left
            pathLbl.Parent = row
        end
    end

    local scanBtn = makeButton(topRow, "HUNT GAME MODULES", Theme.Accent, function()
        statusLbl.Text = "Filtering loaded modules..."
        if not getloadedmodules then
            appendLog("MODULE", "getloadedmodules is not supported", Theme.Red)
            statusLbl.Text = "getloadedmodules unsupported!"
            return
        end
        local list = getloadedmodules()
        local gameMods = {}
        local keywords = {"Bitcoin", "Miner", "Shop", "Warp", "Exchange", "Core", "Building", "Reward", "Card", "Data"}
        for _, mod in ipairs(list) do
            local path = mod:GetFullName()
            if not path:find("CorePackages") and not path:find("CoreGui") then
                for _, kw in ipairs(keywords) do
                    if path:lower():find(kw:lower()) then
                        table.insert(gameMods, {Name = mod.Name, Path = path, Obj = mod})
                        break
                    end
                end
            end
        end
        FaxState.ModuleResults = gameMods
        statusLbl.Text = string.format("Filtered %d game-relevant modules", #gameMods)
        appendLog("MODULE", string.format("Scanned %d modules. Extracted %d relevant game modules.", #list, #gameMods), Theme.Green)
        refreshModuleList()
    end)
    scanBtn.Position = UDim2.new(1, -270, 0.5, -15)

    local copyBtn = makeButton(topRow, "COPY MODULE LIST", Theme.ElementBg, function()
        if #FaxState.ModuleResults == 0 then
            appendLog("MODULE", "No modules to copy. Run hunt first.", Theme.Yellow)
            return
        end
        local lines = {"=== FAXNET LOADED MODULES HUNT ==="}
        for i, item in ipairs(FaxState.ModuleResults) do
            table.insert(lines, string.format("[%d] %s", i, item.Path))
        end
        local fullText = table.concat(lines, string.char(10))
        local ok = copyText(fullText)
        if ok then
            appendLog("MODULE", string.format("Copied %d modules to clipboard!", #FaxState.ModuleResults), Theme.Cyan)
        else
            appendLog("MODULE", "Failed to copy to clipboard", Theme.Red)
        end
    end)
    copyBtn.Position = UDim2.new(1, -135, 0.5, -15)
end

local function setupSignalTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -280, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Hijack & mute game connections with getconnections"
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
    midFrame.Parent = tab.Page

    Instance.new("UICorner", midFrame).CornerRadius = UDim.new(0, 6)
    local mfSt = Instance.new("UIStroke", midFrame)
    mfSt.Color = Theme.Border
    mfSt.Thickness = 1

    local statBox = Instance.new("TextLabel")
    statBox.Size = UDim2.new(1, -24, 0, 50)
    statBox.Position = UDim2.new(0, 12, 0, 12)
    statBox.BackgroundColor3 = Theme.Background
    statBox.Text = "Connections Status: Idle"
    statBox.TextColor3 = Theme.Cyan
    statBox.Font = Enum.Font.GothamBold
    statBox.TextSize = 12
    statBox.BorderSizePixel = 0
    statBox.Parent = midFrame
    Instance.new("UICorner", statBox).CornerRadius = UDim.new(0, 4)

    local descBox = Instance.new("TextLabel")
    descBox.Size = UDim2.new(1, -24, 0, 90)
    descBox.Position = UDim2.new(0, 12, 0, 70)
    descBox.BackgroundTransparency = 1
    descBox.Text = "HOW CONNECTION HIJACKING WORKS:\n1. Mute Listeners calls conn:Disable() on the game's incoming RemoteEvent connections.\n2. The game's UI and client scripts stop receiving packets directly from the server.\n3. FaxNet sits in the middle and receives all packets first, allowing full control."
    descBox.TextColor3 = Theme.TextSecondary
    descBox.Font = Enum.Font.Gotham
    descBox.TextSize = 9
    descBox.TextXAlignment = Enum.TextXAlignment.Left
    descBox.TextYAlignment = Enum.TextYAlignment.Top
    descBox.Parent = midFrame

    local muteBtn = makeButton(topRow, "MUTE GAME LISTENERS", Theme.Red, function()
        if not getconnections then
            appendLog("SIGNAL", "getconnections is not supported", Theme.Red)
            return
        end
        local count = 0
        FaxState.HijackedConns = {}
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
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
        FaxState.MutedCount = count
        statBox.Text = string.format("Muted: %d Game Listeners Disabled", count)
        statBox.TextColor3 = Theme.Red
        appendLog("SIGNAL", string.format("MUTED %d game listeners! Client scripts are now silenced.", count), Theme.Red)
    end)
    muteBtn.Position = UDim2.new(1, -270, 0.5, -15)

    local unmuteBtn = makeButton(topRow, "RESTORE LISTENERS", Theme.Green, function()
        local count = 0
        for _, conn in ipairs(FaxState.HijackedConns) do
            if conn.Enable then
                conn:Enable()
                count = count + 1
            end
        end
        FaxState.MutedCount = 0
        statBox.Text = string.format("Restored: %d Game Listeners Re-enabled", count)
        statBox.TextColor3 = Theme.Green
        appendLog("SIGNAL", string.format("RESTORED %d game listeners to normal operation.", count), Theme.Green)
    end)
    unmuteBtn.Position = UDim2.new(1, -135, 0.5, -15)
end

local function setupConsoleTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -280, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "FaxNet internal execution log"
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
    scroll.Parent = tab.Page

    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
    local scStroke = Instance.new("UIStroke", scroll)
    scStroke.Color = Theme.Border
    scStroke.Thickness = 1

    local sLayout = Instance.new("UIListLayout")
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Padding = UDim.new(0, 2)
    sLayout.Parent = scroll

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 6)
    sPad.PaddingLeft = UDim.new(0, 6)
    sPad.PaddingRight = UDim.new(0, 6)
    sPad.Parent = scroll

    local function refreshLogs()
        scroll:ClearAllChildren()
        sLayout:Clone().Parent = scroll
        sPad:Clone().Parent = scroll

        for _, log in ipairs(FaxState.Logs) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 22)
            row.BackgroundColor3 = Theme.Background
            row.BorderSizePixel = 0
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

            local timeLbl = Instance.new("TextLabel")
            timeLbl.Size = UDim2.new(0, 50, 1, 0)
            timeLbl.Position = UDim2.new(0, 6, 0, 0)
            timeLbl.BackgroundTransparency = 1
            timeLbl.Text = log.Time
            timeLbl.TextColor3 = Theme.TextSecondary
            timeLbl.Font = Enum.Font.Gotham
            timeLbl.TextSize = 8
            timeLbl.TextXAlignment = Enum.TextXAlignment.Left
            timeLbl.Parent = row

            local tagLbl = Instance.new("TextLabel")
            tagLbl.Size = UDim2.new(0, 60, 1, 0)
            tagLbl.Position = UDim2.new(0, 58, 0, 0)
            tagLbl.BackgroundTransparency = 1
            tagLbl.Text = "[" .. log.Tag .. "]"
            tagLbl.TextColor3 = Theme.Cyan
            tagLbl.Font = Enum.Font.GothamBold
            tagLbl.TextSize = 8
            tagLbl.TextXAlignment = Enum.TextXAlignment.Left
            tagLbl.Parent = row

            local msgLbl = Instance.new("TextLabel")
            msgLbl.Size = UDim2.new(1, -125, 1, 0)
            msgLbl.Position = UDim2.new(0, 120, 0, 0)
            msgLbl.BackgroundTransparency = 1
            msgLbl.Text = log.Message
            msgLbl.TextColor3 = log.Color
            msgLbl.Font = Enum.Font.Gotham
            msgLbl.TextSize = 9
            msgLbl.TextXAlignment = Enum.TextXAlignment.Left
            msgLbl.Parent = row
        end
        scroll.CanvasPosition = Vector2.new(0, 999999)
    end

    FaxState.RefreshLogs = refreshLogs

    local clearBtn = makeButton(topRow, "CLEAR LOGS", Theme.ElementBg, function()
        FaxState.Logs = {}
        refreshLogs()
    end)
    clearBtn.Position = UDim2.new(1, -270, 0.5, -15)

    local copyBtn = makeButton(topRow, "COPY ALL LOGS", Theme.Accent, function()
        local lines = {"=== FAXNET CONSOLE LOGS ==="}
        for _, l in ipairs(FaxState.Logs) do
            table.insert(lines, string.format("[%s] [%s] %s", l.Time, l.Tag, l.Message))
        end
        local ok = copyText(table.concat(lines, string.char(10)))
        if ok then
            appendLog("SYSTEM", "Logs copied to clipboard!", Theme.Green)
        end
    end)
    copyBtn.Position = UDim2.new(1, -135, 0.5, -15)

    refreshLogs()
end

setupNilTab(TabNil)
setupModuleTab(TabModules)
setupSignalTab(TabSignals)
setupConsoleTab(TabConsole)

appendLog("INIT", "FaxNet Engine v1.0 initialized (Press RightShift to toggle UI)", Theme.Accent)
