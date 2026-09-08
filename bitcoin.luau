local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
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

local debugLogs = {}
local maxLogs = 250
local autoScroll = true
local remoteSpyEnabled = true
local logServiceEnabled = true
local refreshDebugUI = nil
local filterQuery = ""

local grabbedPackets = {}
local maxGrabbed = 40
local refreshGrabbedUI = nil
local harvestedRemotes = {}

local activeTamper = false
local tamperMultiplyNumbers = false
local tamperMultiplier = 10
local tamperForceBooleans = false
local tamperTargetOverride = false
local tamperTargetName = ""
local tamperTargetArgs = ""

local selectedRemoteInstance = nil
local selectedRemoteName = "None"
local selectedRemoteMethod = "FireServer"
local updateSelectedUI = nil

local function serializeVal(val, depth)
    depth = depth or 0
    if depth > 2 then return tostring(val) end
    local t = typeof(val)
    if t == "string" then
        return '"' .. val .. '"'
    elseif t == "number" or t == "boolean" or t == "nil" then
        return tostring(val)
    elseif t == "Instance" then
        return val.Name .. " (" .. val.ClassName .. ")"
    elseif t == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(val) do
            count = count + 1
            if count > 5 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, tostring(k) .. "=" .. serializeVal(v, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(val)
end

local function parseArgs(str)
    if not str or str == "" then return {} end
    local result = {}
    local pieces = string.split(str, ",")
    for _, raw in ipairs(pieces) do
        local p = string.match(raw, "^%s*(.-)%s*$")
        if p and p ~= "" then
            local n = tonumber(p)
            if n then
                table.insert(result, n)
            elseif p == "true" then
                table.insert(result, true)
            elseif p == "false" then
                table.insert(result, false)
            elseif p == "nil" then
                table.insert(result, nil)
            elseif p == "LocalPlayer" or p == "me" or p == "player" then
                table.insert(result, LocalPlayer)
            else
                local unquoted = string.match(p, '^["\'](.*)["\']$')
                table.insert(result, unquoted or p)
            end
        end
    end
    return result
end

local function argsToDisplayStr(args)
    if not args or #args == 0 then return "" end
    local parts = {}
    for _, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then
            table.insert(parts, '"' .. v .. '"')
        elseif t == "Instance" then
            table.insert(parts, v.Name)
        else
            table.insert(parts, tostring(v))
        end
    end
    return table.concat(parts, ", ")
end

local function addDebugLog(category, text, color)
    local timestamp = os.date("%H:%M:%S")
    local entry = {
        time = timestamp,
        category = category,
        text = text,
        color = color or Color3.fromRGB(240, 240, 245),
        raw = string.format("[%s] [%s] %s", timestamp, category, text)
    }
    table.insert(debugLogs, entry)
    if #debugLogs > maxLogs then
        table.remove(debugLogs, 1)
    end
    if refreshDebugUI then
        refreshDebugUI(entry)
    end
end

local rawMeta = getrawmetatable and getrawmetatable(game)
if rawMeta and setreadonly then
    setreadonly(rawMeta, false)
    local oldNamecall = rawMeta.__namecall
    rawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
            if blockedRemotes[self.Name] then
                addDebugLog("BLOCKED", "Dropped trap remote: " .. self.Name, Color3.fromRGB(230, 75, 75))
                return nil
            end
            local args = {...}
            if remoteSpyEnabled and self.Name ~= "GameAnalyticsError" and self.Name ~= "GameAnalyticsRemoteConfigs" then
                local strArgs = #args > 0 and serializeVal(args) or "none"
                addDebugLog("SPY", string.format("%s:%s(%s)", self.Name, method, strArgs), Color3.fromRGB(100, 200, 255))
            end

            table.insert(grabbedPackets, 1, {
                remote = self,
                name = self.Name,
                className = self.ClassName,
                method = method,
                args = args,
                time = os.date("%H:%M:%S")
            })
            if #grabbedPackets > maxGrabbed then
                table.remove(grabbedPackets)
            end
            if refreshGrabbedUI then
                task.spawn(refreshGrabbedUI)
            end

            if activeTamper then
                local modified = false
                local newArgs = {}
                for idx, v in ipairs(args) do
                    newArgs[idx] = v
                end
                if tamperTargetOverride and tamperTargetName ~= "" and self.Name == tamperTargetName and tamperTargetArgs ~= "" then
                    newArgs = parseArgs(tamperTargetArgs)
                    modified = true
                else
                    if tamperMultiplyNumbers then
                        for idx, v in ipairs(newArgs) do
                            if typeof(v) == "number" then
                                newArgs[idx] = v * tamperMultiplier
                                modified = true
                            end
                        end
                    end
                    if tamperForceBooleans then
                        for idx, v in ipairs(newArgs) do
                            if typeof(v) == "boolean" and not v then
                                newArgs[idx] = true
                                modified = true
                            end
                        end
                    end
                end
                if modified then
                    addDebugLog("RAK-TAMPER", string.format("Tampered %s:%s args -> %s", self.Name, method, serializeVal(newArgs)), Color3.fromRGB(80, 220, 120))
                    return oldNamecall(self, unpack(newArgs))
                end
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
    if not r then
        addDebugLog("ERROR", string.format("RemoteEvent NOT FOUND: %s.%s", parentPath, name), Color3.fromRGB(230, 75, 75))
        return false
    end
    if not r:IsA("RemoteEvent") then
        addDebugLog("ERROR", string.format("Object %s.%s is %s (not RemoteEvent)", parentPath, name, r.ClassName), Color3.fromRGB(230, 75, 75))
        return false
    end
    local args = {...}
    local strArgs = #args > 0 and serializeVal(args) or "none"
    local ok, err = pcall(function(...)
        r:FireServer(...)
    end, ...)
    if ok then
        addDebugLog("FIRE", string.format("%s:FireServer(%s)", name, strArgs), Color3.fromRGB(80, 220, 120))
        return true
    else
        addDebugLog("ERROR", string.format("%s:FireServer failed: %s", name, tostring(err)), Color3.fromRGB(230, 75, 75))
        return false
    end
end

local function safeInvoke(parentPath, name, ...)
    local r = getRemote(parentPath, name)
    if not r then
        addDebugLog("ERROR", string.format("RemoteFunction NOT FOUND: %s.%s", parentPath, name), Color3.fromRGB(230, 75, 75))
        return nil
    end
    if not r:IsA("RemoteFunction") then
        addDebugLog("ERROR", string.format("Object %s.%s is %s (not RemoteFunction)", parentPath, name, r.ClassName), Color3.fromRGB(230, 75, 75))
        return nil
    end
    local args = {...}
    local strArgs = #args > 0 and serializeVal(args) or "none"
    local res = nil
    local ok, err = pcall(function(...)
        res = r:InvokeServer(...)
    end, ...)
    if ok then
        addDebugLog("INVOKE", string.format("%s:InvokeServer(%s) -> %s", name, strArgs, serializeVal(res)), Color3.fromRGB(80, 220, 120))
        return res
    else
        addDebugLog("ERROR", string.format("%s:InvokeServer failed: %s", name, tostring(err)), Color3.fromRGB(230, 75, 75))
        return nil
    end
end

LogService.MessageOut:Connect(function(msg, msgType)
    if not logServiceEnabled then return end
    local typeName = msgType and msgType.Name or "Print"
    local col = Color3.fromRGB(160, 165, 175)
    if typeName == "MessageError" or typeName == "Error" then
        col = Color3.fromRGB(230, 75, 75)
    elseif typeName == "MessageWarning" or typeName == "Warning" then
        col = Color3.fromRGB(247, 180, 50)
    elseif typeName == "MessageInfo" or typeName == "Info" then
        col = Color3.fromRGB(247, 147, 26)
    end
    addDebugLog("ROBLOX", string.format("[%s] %s", typeName, msg), col)
end)

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

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -20, 0, 18)
    nTitle.Position = UDim2.new(0, 14, 0, 7)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = string.upper(title)
    nTitle.TextColor3 = color
    nTitle.Font = Enum.Font.Gotham
    nTitle.TextSize = 11
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.Parent = card

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -20, 0, 18)
    nDesc.Position = UDim2.new(0, 14, 0, 25)
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

local MainShadow = Instance.new("Frame")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(0, 656, 0, 486)
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
MainFrame.Size = UDim2.new(0, 640, 0, 470)
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
subtitleLabel.Size = UDim2.new(0, 240, 1, 0)
subtitleLabel.Position = UDim2.new(0, 200, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "ID: 943733974 | RAKNET HOOK"
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
        tw(MainFrame, {Size = UDim2.new(0, 640, 0, 470), BackgroundTransparency = 0.12}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(MainShadow, {Size = UDim2.new(0, 656, 0, 486), BackgroundTransparency = 0.65}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tw(MainShadow, {Size = UDim2.new(0, 600, 0, 430), BackgroundTransparency = 1}, 0.18)
        tw(MainFrame, {Size = UDim2.new(0, 600, 0, 430), BackgroundTransparency = 1}, 0.18).Completed:Connect(function()
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

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 136, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 12
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
tabPad.PaddingTop = UDim.new(0, 7)
tabPad.PaddingLeft = UDim.new(0, 6)
tabPad.PaddingRight = UDim.new(0, 6)
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
    tabBtn.Size = UDim2.new(1, 0, 0, 26)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.Text = string.upper(name)
    tabBtn.TextColor3 = Theme.TabInactiveText
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 9
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local tPad = Instance.new("UIPadding")
    tPad.PaddingLeft = UDim.new(0, 8)
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
        row.BackgroundTransparency = 0.2
        row.Text = ""
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.ClipsDescendants = true
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 5)
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

        row.MouseEnter:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            tw(rStroke, {Color = Theme.BorderBright}, 0.12)
        end)
        row.MouseLeave:Connect(function()
            tw(row, {BackgroundColor3 = Theme.ElementBg}, 0.12)
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

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 5)
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
local RakTab      = createTab("RakNet Tamper")
local DevTab      = createTab("Dev & Packet")
local DebugTab    = createTab("Debug Log")
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
                task.wait(0.3)
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
                task.wait(0.35)
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
                task.wait(0.4)
            end
        end)
        Notify("Currency", "Auto XP leveling loop running", 1.5, Theme.Green)
    end
end)

CurrencyTab:AddSection("Diagnostics & Remote Probing")
CurrencyTab:AddButton("Probe Currency Remotes with Test Arguments", function()
    addDebugLog("PROBE", "Starting Currency Remotes Probe...", Theme.Accent)
    safeInvoke("Events", "AddSCash")
    safeInvoke("Events", "AddSCash", 100)
    safeInvoke("Events", "AddSCash", 1000000)
    safeInvoke("Events", "AddSCash", LocalPlayer)
    safeFire("Events", "GivePremiumCoins")
    safeFire("Events", "GivePremiumCoins", 100)
    safeFire("Events", "GivePremiumCoins", LocalPlayer)
    safeInvoke("Events", "AddXp")
    safeInvoke("Events", "AddXp", 500)
    safeInvoke("Events", "AddXp", LocalPlayer)
    Notify("Probe", "Currency remotes probed! Check Debug Log tab", 2.5, Theme.Green)
end)

CurrencyTab:AddSection("Milestones & Rewards")
CurrencyTab:AddButton("Claim 200M Milestone Gift", function()
    local ok = safeFire("Events", "Open200MGift")
    Notify("Milestone", ok and "Dispatched 200M Gift claim" or "Gift remote not found", 2, ok and Theme.Green or Theme.Red)
end)

CurrencyTab:AddButton("Redeem Event Tickets", function()
    local ok = safeFire("Events", "TicketReedem")
    Notify("Rewards", ok and "Dispatched Ticket Redeem" or "Ticket remote not found", 2, ok and Theme.Green or Theme.Red)
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
                task.wait(0.25)
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
local unifiedExchange = false
local exchangeInterval = 0.5

ExchangeTab:AddSection("Synchronized Exchange & Collect (Recommended)")
ExchangeTab:AddSlider("Exchange Interval (sec)", 1, 5, 1, function(val)
    exchangeInterval = val * 0.5
end)

ExchangeTab:AddToggle("Unified Auto Exchange & Collect", false, function(v)
    unifiedExchange = v
    if v then
        task.spawn(function()
            while unifiedExchange do
                addDebugLog("SYNC-EXCH", "Cycle Step 1: Firing SimpleExchange...", Theme.Accent)
                safeFire("Events.Exchanger", "SimpleExchange")
                task.wait(exchangeInterval)
                if not unifiedExchange then break end
                addDebugLog("SYNC-EXCH", "Cycle Step 2: Firing SimpleCollect...", Theme.Accent)
                safeFire("Events.Exchanger", "SimpleCollect")
                task.wait(exchangeInterval)
            end
        end)
        Notify("Exchange", "Unified Exchange & Collect running smoothly", 2, Theme.Green)
    end
end)

ExchangeTab:AddSection("Independent Loops (Old)")
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

ExchangeTab:AddToggle("Auto Collect Exchange Cash (SimpleCollect)", false, function(v)
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

ExchangeTab:AddSection("Exchange Diagnostics & Probes")
ExchangeTab:AddButton("Probe All Exchange Remotes", function()
    addDebugLog("PROBE", "Starting Exchange Remotes Probe...", Theme.Accent)
    safeFire("Events.Exchanger", "SimpleExchange")
    safeFire("Events.Exchanger", "SimpleExchange", "All")
    safeFire("Events.Exchanger", "SimpleExchange", "Bitcoin")
    safeFire("Events.Exchanger", "SimpleCollect")
    safeFire("Events.Exchanger", "SimpleCollect", "All")
    safeFire("Events", "ExchangeBlocks")
    safeFire("Events", "ExchangeMoney")
    safeInvoke("Events.Exchanger", "Exchange")
    safeFire("Events.Exchanger", "ShowToCollect")
    Notify("Probe", "Exchange remotes probed! Check Debug Log tab", 2.5, Theme.Green)
end)

ExchangeTab:AddSection("Rate Modifiers & Boosters")
ExchangeTab:AddButton("Trigger Free Rate Refresh", function()
    safeFire("Events", "FreeCngRate")
    safeFire("Events", "ChangeRate")
    Notify("Rates", "Rate refresh remotes dispatched", 1.5, Theme.Accent)
end)

ExchangeTab:AddButton("Apply Exchange Coupon Boost", function()
    safeFire("Events.Exchanger", "UseCoupon")
    Notify("Booster", "Coupon remote dispatched", 1.5, Theme.Green)
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
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and customSpeed ~= 16 then
        hum.WalkSpeed = customSpeed
    end
end)

local noclipConn = nil
local noclipEnabled = false
MoveTab:AddToggle("Noclip (Walk Through Walls)", false, function(v)
    noclipEnabled = v
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
        Notify("Movement", "Noclip enabled", 1.5, Theme.Green)
    else
        Notify("Movement", "Noclip disabled", 1.5, Theme.Red)
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
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 52, root.AssemblyLinearVelocity.Z)
            end
        end)
        Notify("Movement", "Infinite jump enabled", 1.5, Theme.Green)
    end
end)

RakTab:AddSection("Active In-Flight Packet Tamperer")
RakTab:AddToggle("Enable Active Argument Tampering", false, function(v)
    activeTamper = v
    Notify("RakNet", v and "Active in-flight argument tampering ACTIVE" or "Argument tampering PAUSED", 2, v and Theme.Green or Theme.Red)
end)

RakTab:AddToggle("Multiply Outgoing Numbers (10x - 1000x)", false, function(v)
    tamperMultiplyNumbers = v
    Notify("RakNet", v and "Number Multiplier active on all outgoing remotes" or "Number Multiplier OFF", 2, v and Theme.Green or Theme.Red)
end)

RakTab:AddSlider("Number Multiplier Value", 2, 500, 10, function(val)
    tamperMultiplier = val
end)

RakTab:AddToggle("Force Outgoing Booleans to TRUE", false, function(v)
    tamperForceBooleans = v
    Notify("RakNet", v and "Forcing all booleans to true" or "Boolean spoofer OFF", 2, v and Theme.Green or Theme.Red)
end)

RakTab:AddSection("Targeted In-Flight Override")
RakTab:AddToggle("Override Target Remote Arguments", false, function(v)
    tamperTargetOverride = v
    Notify("RakNet", v and "Targeted argument override ACTIVE" or "Targeted override OFF", 2, v and Theme.Green or Theme.Red)
end)

local overrideTargetInput = Instance.new("TextBox")
overrideTargetInput.Size = UDim2.new(1, 0, 0, 28)
overrideTargetInput.BackgroundColor3 = Theme.Header
overrideTargetInput.PlaceholderText = "Target Remote Name (e.g. AddSCash, SimpleExchange)..."
overrideTargetInput.Text = ""
overrideTargetInput.TextColor3 = Theme.TextPrimary
overrideTargetInput.PlaceholderColor3 = Theme.TextSecondary
overrideTargetInput.Font = Enum.Font.Gotham
overrideTargetInput.TextSize = 10
overrideTargetInput.TextXAlignment = Enum.TextXAlignment.Left
overrideTargetInput.BorderSizePixel = 0
overrideTargetInput.ClearTextOnFocus = false
overrideTargetInput.Parent = RakTab.Page

local otiCorner = Instance.new("UICorner", overrideTargetInput)
otiCorner.CornerRadius = UDim.new(0, 4)
local otiPad = Instance.new("UIPadding", overrideTargetInput)
otiPad.PaddingLeft = UDim.new(0, 8)

overrideTargetInput:GetPropertyChangedSignal("Text"):Connect(function()
    tamperTargetName = string.gsub(overrideTargetInput.Text, "%s+", "")
end)

local overrideArgsInput = Instance.new("TextBox")
overrideArgsInput.Size = UDim2.new(1, 0, 0, 28)
overrideArgsInput.BackgroundColor3 = Theme.Header
overrideArgsInput.PlaceholderText = "Replacement Arguments (e.g. 999999999 or true, All)..."
overrideArgsInput.Text = ""
overrideArgsInput.TextColor3 = Theme.TextPrimary
overrideArgsInput.PlaceholderColor3 = Theme.TextSecondary
overrideArgsInput.Font = Enum.Font.Gotham
overrideArgsInput.TextSize = 10
overrideArgsInput.TextXAlignment = Enum.TextXAlignment.Left
overrideArgsInput.BorderSizePixel = 0
overrideArgsInput.ClearTextOnFocus = false
overrideArgsInput.Parent = RakTab.Page

local oaiCorner = Instance.new("UICorner", overrideArgsInput)
oaiCorner.CornerRadius = UDim.new(0, 4)
local oaiPad = Instance.new("UIPadding", overrideArgsInput)
oaiPad.PaddingLeft = UDim.new(0, 8)

overrideArgsInput:GetPropertyChangedSignal("Text"):Connect(function()
    tamperTargetArgs = overrideArgsInput.Text
end)

RakTab:AddSection("Packet Tamper & Custom Dispatcher")

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, 0, 0, 20)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = "TARGET: NONE (Select a remote below)"
selectedLabel.TextColor3 = Theme.Accent
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextSize = 10
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = RakTab.Page

local function setTargetRemote(inst, name, method)
    selectedRemoteInstance = inst
    selectedRemoteName = name
    selectedRemoteMethod = method or (inst and (inst:IsA("RemoteFunction") and "InvokeServer" or "FireServer") or "FireServer")
    selectedLabel.Text = string.format("TARGET: %s (%s)", selectedRemoteName, selectedRemoteMethod)
    Notify("Target Set", "Active target: " .. selectedRemoteName, 1.5, Theme.Green)
end

updateSelectedUI = setTargetRemote

local payloadInput = Instance.new("TextBox")
payloadInput.Size = UDim2.new(1, 0, 0, 30)
payloadInput.BackgroundColor3 = Theme.Header
payloadInput.PlaceholderText = "Argument Payload (comma-separated: 1000000000 or true, All)..."
payloadInput.Text = ""
payloadInput.TextColor3 = Theme.TextPrimary
payloadInput.PlaceholderColor3 = Theme.TextSecondary
payloadInput.Font = Enum.Font.Gotham
payloadInput.TextSize = 10
payloadInput.TextXAlignment = Enum.TextXAlignment.Left
payloadInput.BorderSizePixel = 0
payloadInput.ClearTextOnFocus = false
payloadInput.Parent = RakTab.Page

local piCorner = Instance.new("UICorner", payloadInput)
piCorner.CornerRadius = UDim.new(0, 4)
local piPad = Instance.new("UIPadding", payloadInput)
piPad.PaddingLeft = UDim.new(0, 8)

local presetsRow = Instance.new("Frame")
presetsRow.Size = UDim2.new(1, 0, 0, 24)
presetsRow.BackgroundTransparency = 1
presetsRow.Parent = RakTab.Page

local function addPresetBtn(label, value, xRatio, widthRatio)
    local pBtn = Instance.new("TextButton")
    pBtn.Size = UDim2.new(widthRatio, -3, 1, 0)
    pBtn.Position = UDim2.new(xRatio, 0, 0, 0)
    pBtn.BackgroundColor3 = Theme.ElementBg
    pBtn.Text = label
    pBtn.TextColor3 = Theme.Accent
    pBtn.Font = Enum.Font.Gotham
    pBtn.TextSize = 9
    pBtn.BorderSizePixel = 0
    pBtn.AutoButtonColor = false
    pBtn.Parent = presetsRow

    local pbCorner = Instance.new("UICorner", pBtn)
    pbCorner.CornerRadius = UDim.new(0, 3)

    pBtn.MouseButton1Click:Connect(function()
        payloadInput.Text = value
    end)
end

addPresetBtn("999M", "999999999", 0, 0.2)
addPresetBtn("TRUE", "true", 0.2, 0.2)
addPresetBtn("PLAYER", "LocalPlayer", 0.4, 0.2)
addPresetBtn('"ALL"', '"All"', 0.6, 0.2)
addPresetBtn("CLEAR", "", 0.8, 0.2)

RakTab:AddButton("FIRE / INVOKE TARGET WITH MODIFIED ARGS", function()
    if not selectedRemoteInstance then
        Notify("Error", "No target remote selected! Choose below", 2, Theme.Red)
        return
    end
    local parsed = parseArgs(payloadInput.Text)
    local strArgs = serializeVal(parsed)
    if selectedRemoteInstance:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            selectedRemoteInstance:FireServer(unpack(parsed))
        end)
        if ok then
            addDebugLog("TAMPER-FIRE", string.format("Fired %s with args: %s", selectedRemoteName, strArgs), Theme.Green)
            Notify("Dispatched", "Fired " .. selectedRemoteName, 1.5, Theme.Green)
        else
            addDebugLog("ERROR", string.format("FireServer on %s failed: %s", selectedRemoteName, tostring(err)), Theme.Red)
        end
    elseif selectedRemoteInstance:IsA("RemoteFunction") then
        local res = nil
        local ok, err = pcall(function()
            res = selectedRemoteInstance:InvokeServer(unpack(parsed))
        end)
        if ok then
            addDebugLog("TAMPER-INVOKE", string.format("Invoked %s with args: %s -> %s", selectedRemoteName, strArgs, serializeVal(res)), Theme.Green)
            Notify("Invoked", "Invoked " .. selectedRemoteName .. " -> " .. serializeVal(res), 2, Theme.Green)
        else
            addDebugLog("ERROR", string.format("InvokeServer on %s failed: %s", selectedRemoteName, tostring(err)), Theme.Red)
        end
    end
end)

local floodActive = false
local floodBatch = 5
RakTab:AddToggle("Flood Target with Modified Arguments (Blaster)", false, function(v)
    floodActive = v
    if v then
        if not selectedRemoteInstance then
            Notify("Error", "Select a target remote first", 2, Theme.Red)
            return
        end
        task.spawn(function()
            while floodActive do
                local parsed = parseArgs(payloadInput.Text)
                for i = 1, floodBatch do
                    task.spawn(function()
                        if selectedRemoteInstance:IsA("RemoteEvent") then
                            pcall(function() selectedRemoteInstance:FireServer(unpack(parsed)) end)
                        elseif selectedRemoteInstance:IsA("RemoteFunction") then
                            pcall(function() selectedRemoteInstance:InvokeServer(unpack(parsed)) end)
                        end
                    end)
                end
                task.wait(0.06)
            end
        end)
        Notify("RakNet", "Blasting target with modified arguments!", 2, Theme.Green)
    end
end)

RakTab:AddSlider("Flood Batch Size", 1, 30, 5, function(val)
    floodBatch = val
end)

RakTab:AddSection("Quick Target Selectors")
local quickRow1 = Instance.new("Frame")
quickRow1.Size = UDim2.new(1, 0, 0, 26)
quickRow1.BackgroundTransparency = 1
quickRow1.Parent = RakTab.Page

local function addQuickBtn(parent, label, remotePath, remoteName, xRatio, widthRatio)
    local qb = Instance.new("TextButton")
    qb.Size = UDim2.new(widthRatio, -3, 1, 0)
    qb.Position = UDim2.new(xRatio, 0, 0, 0)
    qb.BackgroundColor3 = Theme.ElementBg
    qb.Text = label
    qb.TextColor3 = Theme.TextPrimary
    qb.Font = Enum.Font.Gotham
    qb.TextSize = 9
    qb.BorderSizePixel = 0
    qb.AutoButtonColor = false
    qb.Parent = parent

    local qbCorner = Instance.new("UICorner", qb)
    qbCorner.CornerRadius = UDim.new(0, 4)

    qb.MouseButton1Click:Connect(function()
        local r = getRemote(remotePath, remoteName)
        if r then
            setTargetRemote(r, remoteName)
            if remoteName == "AddSCash" or remoteName == "GivePremiumCoins" then
                payloadInput.Text = "1000000000"
            elseif remoteName == "SimpleExchange" then
                payloadInput.Text = ""
            elseif remoteName == "AdminPlotEvnt" then
                payloadInput.Text = 'true, "All"'
            end
        else
            Notify("Missing", remoteName .. " remote not found in hierarchy", 2, Theme.Red)
        end
    end)
end

addQuickBtn(quickRow1, "AddSCash", "Events", "AddSCash", 0, 0.25)
addQuickBtn(quickRow1, "PremCoins", "Events", "GivePremiumCoins", 0.25, 0.25)
addQuickBtn(quickRow1, "AddXp", "Events", "AddXp", 0.5, 0.25)
addQuickBtn(quickRow1, "Exchange", "Events.Exchanger", "SimpleExchange", 0.75, 0.25)

local quickRow2 = Instance.new("Frame")
quickRow2.Size = UDim2.new(1, 0, 0, 26)
quickRow2.BackgroundTransparency = 1
quickRow2.Parent = RakTab.Page

addQuickBtn(quickRow2, "Collect", "Events.Exchanger", "SimpleCollect", 0, 0.25)
addQuickBtn(quickRow2, "AdminPlot", "Events", "AdminPlotEvnt", 0.25, 0.25)
addQuickBtn(quickRow2, "BuyQuasar", "Events", "BuyPremiumQuasar", 0.5, 0.25)
addQuickBtn(quickRow2, "OpenCase", "Events", "OpenCase", 0.75, 0.25)

RakTab:AddSection("Universal Remote Harvester (Scan All)")
RakTab:AddButton("GRAB ALL GAME REMOTES (Scan Game & Memory)", function()
    harvestedRemotes = {}
    local function scan(parent)
        if not parent then return end
        local ok, children = pcall(function() return parent:GetDescendants() end)
        if ok and children then
            for _, obj in ipairs(children) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
                    table.insert(harvestedRemotes, {
                        instance = obj,
                        name = obj.Name,
                        className = obj.ClassName,
                        path = obj:GetFullName()
                    })
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(workspace)
    scan(Players)
    if getnilinstances then
        local ok, nils = pcall(getnilinstances)
        if ok and nils then
            for _, obj in ipairs(nils) do
                if typeof(obj) == "Instance" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                    table.insert(harvestedRemotes, {
                        instance = obj,
                        name = obj.Name .. " (NIL)",
                        className = obj.ClassName,
                        path = "NIL." .. obj.Name
                    })
                end
            end
        end
    end
    addDebugLog("HARVEST", string.format("Grabbed %d game remotes from hierarchy & memory!", #harvestedRemotes), Theme.Green)
    Notify("Harvester", string.format("Grabbed %d remotes! View in Debug Log", #harvestedRemotes), 3, Theme.Green)
end)

RakTab:AddButton("Dump Grabbed Remotes to Debug Log", function()
    if #harvestedRemotes == 0 then
        Notify("Harvester", "Run 'GRAB ALL GAME REMOTES' first", 2, Theme.Red)
        return
    end
    addDebugLog("DUMP", string.format("*** DUMPING %d GRABBED REMOTES ***", #harvestedRemotes), Theme.Accent)
    for idx, r in ipairs(harvestedRemotes) do
        addDebugLog("REMOTE", string.format("#%d [%s] %s", idx, r.className, r.path), Theme.TextPrimary)
    end
    Notify("Dumped", "Dumped all remotes into Debug Log tab", 2, Theme.Green)
end)

RakTab:AddButton("Copy Grabbed Remotes List to Clipboard", function()
    if #harvestedRemotes == 0 then
        Notify("Harvester", "Run 'GRAB ALL GAME REMOTES' first", 2, Theme.Red)
        return
    end
    local lines = {}
    for idx, r in ipairs(harvestedRemotes) do
        table.insert(lines, string.format("#%d [%s] %s", idx, r.className, r.path))
    end
    local text = table.concat(lines, "\n")
    if setclipboard then
        pcall(setclipboard, text)
        Notify("Copied", string.format("Copied %d remotes to clipboard", #harvestedRemotes), 2, Theme.Green)
    end
end)

RakTab:AddSection("Grab & Boost Client Value Objects")
RakTab:AddButton("Grab & Set All Client Values to 999,999,999", function()
    local count = 0
    local function scanValues(parent)
        if not parent then return end
        local ok, descendants = pcall(function() return parent:GetDescendants() end)
        if ok and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    pcall(function()
                        obj.Value = 999999999
                        count = count + 1
                    end)
                elseif obj:IsA("BoolValue") then
                    pcall(function()
                        obj.Value = true
                        count = count + 1
                    end)
                end
            end
        end
    end
    scanValues(LocalPlayer)
    local char = LocalPlayer.Character
    if char then scanValues(char) end
    addDebugLog("VALUES", string.format("Modified %d client ValueObjects to max!", count), Theme.Green)
    Notify("Values", string.format("Boosted %d client values to max", count), 2, Theme.Green)
end)

RakTab:AddSection("Live Grabbed Packets Feed")
local grabbedHolder = Instance.new("Frame")
grabbedHolder.Size = UDim2.new(1, 0, 0, 180)
grabbedHolder.BackgroundColor3 = Theme.Header
grabbedHolder.BorderSizePixel = 0
grabbedHolder.Parent = RakTab.Page

local ghCorner = Instance.new("UICorner", grabbedHolder)
ghCorner.CornerRadius = UDim.new(0, 5)

local ghStroke = Instance.new("UIStroke", grabbedHolder)
ghStroke.Color = Theme.Border
ghStroke.Thickness = 1

local grabbedScroll = Instance.new("ScrollingFrame")
grabbedScroll.Size = UDim2.new(1, -8, 1, -8)
grabbedScroll.Position = UDim2.new(0, 4, 0, 4)
grabbedScroll.BackgroundTransparency = 1
grabbedScroll.BorderSizePixel = 0
grabbedScroll.ScrollBarThickness = 2
grabbedScroll.ScrollBarImageColor3 = Theme.BorderBright
grabbedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
grabbedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
grabbedScroll.Parent = grabbedHolder

local gsLayout = Instance.new("UIListLayout")
gsLayout.SortOrder = Enum.SortOrder.LayoutOrder
gsLayout.Padding = UDim.new(0, 4)
gsLayout.Parent = grabbedScroll

refreshGrabbedUI = function()
    grabbedScroll:ClearAllChildren()
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = grabbedScroll

    for idx, pkt in ipairs(grabbedPackets) do
        if idx > 15 then break end
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -6, 0, 28)
        card.BackgroundColor3 = Theme.ElementBg
        card.BorderSizePixel = 0
        card.Parent = grabbedScroll

        local cc = Instance.new("UICorner", card)
        cc.CornerRadius = UDim.new(0, 4)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(0.72, -4, 1, 0)
        tLbl.Position = UDim2.new(0, 6, 0, 0)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = string.format("[%s] %s (%s)", pkt.time, pkt.name, argsToDisplayStr(pkt.args))
        tLbl.TextColor3 = Theme.TextPrimary
        tLbl.Font = Enum.Font.Gotham
        tLbl.TextSize = 9
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.TextTruncate = Enum.TextTruncate.AtEnd
        tLbl.Parent = card

        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0.25, 0, 0, 20)
        loadBtn.Position = UDim2.new(0.73, 0, 0.5, -10)
        loadBtn.BackgroundColor3 = Theme.Accent
        loadBtn.Text = "LOAD"
        loadBtn.TextColor3 = Theme.Background
        loadBtn.Font = Enum.Font.Gotham
        loadBtn.TextSize = 9
        loadBtn.BorderSizePixel = 0
        loadBtn.AutoButtonColor = false
        loadBtn.Parent = card

        local lbc = Instance.new("UICorner", loadBtn)
        lbc.CornerRadius = UDim.new(0, 3)

        loadBtn.MouseButton1Click:Connect(function()
            setTargetRemote(pkt.remote, pkt.name, pkt.method)
            payloadInput.Text = argsToDisplayStr(pkt.args)
            Notify("Loaded", "Loaded " .. pkt.name .. " into tamper editor", 1.5, Theme.Accent)
        end)
    end
end

local burstCount = 10
local blasterCash = false
local blasterCoins = false
local blasterXp = false

DevTab:AddSection("RakNet High-Frequency Packet Blaster")
DevTab:AddSlider("Packets Per Burst", 5, 50, 10, function(val)
    burstCount = val
end)

DevTab:AddToggle("Super Cash Packet Blaster", false, function(v)
    blasterCash = v
    if v then
        task.spawn(function()
            while blasterCash do
                for i = 1, burstCount do
                    task.spawn(function()
                        safeInvoke("Events", "AddSCash")
                    end)
                end
                task.wait(0.06)
            end
        end)
        Notify("RakNet", "Super Cash packet blaster streaming", 2, Theme.Green)
    end
end)

DevTab:AddToggle("Premium Coins Packet Blaster", false, function(v)
    blasterCoins = v
    if v then
        task.spawn(function()
            while blasterCoins do
                for i = 1, burstCount do
                    task.spawn(function()
                        safeFire("Events", "GivePremiumCoins")
                    end)
                end
                task.wait(0.06)
            end
        end)
        Notify("RakNet", "Premium Coins packet blaster streaming", 2, Theme.Green)
    end
end)

DevTab:AddToggle("XP Leveler Packet Blaster", false, function(v)
    blasterXp = v
    if v then
        task.spawn(function()
            while blasterXp do
                for i = 1, burstCount do
                    task.spawn(function()
                        safeInvoke("Events", "AddXp")
                    end)
                end
                task.wait(0.08)
            end
        end)
        Notify("RakNet", "XP packet blaster streaming", 2, Theme.Green)
    end
end)

DevTab:AddSection("Admin & Developer Remotes")
DevTab:AddButton("Trigger Admin Plot Event (AdminPlotEvnt)", function()
    safeFire("Events", "AdminPlotEvnt")
    safeFire("Events", "AdminPlotEvnt", true)
    safeFire("Events", "AdminPlotEvnt", "All")
    Notify("Admin", "Fired AdminPlotEvnt with elevated parameters", 2, Theme.Accent)
end)

DevTab:AddButton("Trigger Admin UGC Claim (AdminUGC)", function()
    local ok = safeFire("Events", "AdminUGC")
    Notify("Admin", ok and "Dispatched AdminUGC remote" or "AdminUGC remote called", 2, Theme.Accent)
end)

DevTab:AddButton("Claim Premium Quasar Rig (BuyPremiumQuasar)", function()
    local ok = safeFire("Events", "BuyPremiumQuasar")
    safeFire("Events", "BuyPremiumQuasar", true)
    safeFire("Events", "BuyPremiumQuasar", 0)
    Notify("Quasar", ok and "Dispatched BuyPremiumQuasar" or "Quasar remote called", 2, Theme.Green)
end)

DevTab:AddButton("Claim Quasar Starter Pack (QuasarStarterPack)", function()
    local res = safeInvoke("Events", "QuasarStarterPack")
    Notify("Quasar", "Invoked QuasarStarterPack remote", 2, Theme.Green)
end)

DevTab:AddButton("Instant Skip Metal Smelt Cooldown", function()
    local ok = safeFire("Events", "SkipMetalCooldwn")
    Notify("Smelting", ok and "Skipped metal cooldown on server" or "Cooldown remote called", 2, Theme.Green)
end)

DevTab:AddButton("Bulk Delete Plot Obstacles", function()
    local ok = safeFire("Events", "BulkDeleteObjects")
    Notify("Plot", "Dispatched BulkDeleteObjects", 1.5)
end)

DevTab:AddSection("Gamepass & VIP Spoofing")
DevTab:AddButton("Spoof All Gamepasses (GamepassBought)", function()
    for id = 1, 60 do
        task.spawn(function()
            safeFire("Events", "GamepassBought", id)
        end)
    end
    Notify("Gamepasses", "Streamed purchase signals across gamepass IDs", 2.5, Theme.Green)
end)

DevTab:AddButton("Bypass VIP Check (HasVip)", function()
    local res = safeInvoke("Events", "HasVip")
    Notify("VIP", "Invoked HasVip status bypass", 2, Theme.Accent)
end)

DevTab:AddButton("Use Premium Teleport Warp (UsePremiumWarp)", function()
    local ok = safeFire("Events", "UsePremiumWarp")
    Notify("Teleport", ok and "Triggered Premium Warp" or "Premium Warp remote called", 2, Theme.Green)
end)

DevTab:AddButton("Probe Robux Card Bypass (CardToBuy)", function()
    safeInvoke("Events.RobuxBuy", "CardToBuy", "Quasar")
    safeInvoke("Events.RobuxBuy", "CardToBuy", "Solaris")
    safeInvoke("Events.RobuxBuy", "CardToBuy", "Quantum")
    Notify("RobuxBuy", "Probed CardToBuy with top-tier rigs", 2, Theme.Accent)
end)

DebugTab:AddSection("Live Logger Controls")

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 18)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "TOTAL LOGS: 0  *  LIVE SNIFFER ACTIVE"
statsLabel.TextColor3 = Theme.Green
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 10
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = DebugTab.Page

local logControlsRow = Instance.new("Frame")
logControlsRow.Size = UDim2.new(1, 0, 0, 30)
logControlsRow.BackgroundTransparency = 1
logControlsRow.Parent = DebugTab.Page

local copyLogsBtn = Instance.new("TextButton")
copyLogsBtn.Size = UDim2.new(0.48, -4, 1, 0)
copyLogsBtn.Position = UDim2.new(0, 0, 0, 0)
copyLogsBtn.BackgroundColor3 = Theme.ElementBg
copyLogsBtn.Text = "COPY ALL LOGS"
copyLogsBtn.TextColor3 = Theme.Accent
copyLogsBtn.Font = Enum.Font.Gotham
copyLogsBtn.TextSize = 10
copyLogsBtn.BorderSizePixel = 0
copyLogsBtn.AutoButtonColor = false
copyLogsBtn.Parent = logControlsRow

local clbCorner = Instance.new("UICorner", copyLogsBtn)
clbCorner.CornerRadius = UDim.new(0, 4)

local clbStroke = Instance.new("UIStroke", copyLogsBtn)
clbStroke.Color = Theme.Border
clbStroke.Thickness = 1

local clearLogsBtn = Instance.new("TextButton")
clearLogsBtn.Size = UDim2.new(0.48, -4, 1, 0)
clearLogsBtn.Position = UDim2.new(0.52, 0, 0, 0)
clearLogsBtn.BackgroundColor3 = Theme.ElementBg
clearLogsBtn.Text = "CLEAR LOGS"
clearLogsBtn.TextColor3 = Theme.Red
clearLogsBtn.Font = Enum.Font.Gotham
clearLogsBtn.TextSize = 10
clearLogsBtn.BorderSizePixel = 0
clearLogsBtn.AutoButtonColor = false
clearLogsBtn.Parent = logControlsRow

local clrCorner = Instance.new("UICorner", clearLogsBtn)
clrCorner.CornerRadius = UDim.new(0, 4)

local clrStroke = Instance.new("UIStroke", clearLogsBtn)
clrStroke.Color = Theme.Border
clrStroke.Thickness = 1

local filterInput = Instance.new("TextBox")
filterInput.Size = UDim2.new(1, 0, 0, 26)
filterInput.BackgroundColor3 = Theme.Header
filterInput.PlaceholderText = "Filter Logs (e.g. SPY, ERROR, SimpleExchange, AddSCash)..."
filterInput.Text = ""
filterInput.TextColor3 = Theme.TextPrimary
filterInput.PlaceholderColor3 = Theme.TextSecondary
filterInput.Font = Enum.Font.Gotham
filterInput.TextSize = 10
filterInput.TextXAlignment = Enum.TextXAlignment.Left
filterInput.BorderSizePixel = 0
filterInput.ClearTextOnFocus = false
filterInput.Parent = DebugTab.Page

local fiCorner = Instance.new("UICorner", filterInput)
fiCorner.CornerRadius = UDim.new(0, 4)

local fiPad = Instance.new("UIPadding", filterInput)
fiPad.PaddingLeft = UDim.new(0, 8)

DebugTab:AddToggle("Auto-Scroll to Bottom", true, function(v)
    autoScroll = v
end)

DebugTab:AddToggle("Remote Spy (Intercept Outgoing Remotes)", true, function(v)
    remoteSpyEnabled = v
    Notify("Spy", v and "Remote Spy ACTIVE" or "Remote Spy PAUSED", 1.5, v and Theme.Green or Theme.Red)
end)

DebugTab:AddToggle("Capture Roblox Prints & Warnings", true, function(v)
    logServiceEnabled = v
end)

DebugTab:AddSection("Terminal Stream")

local terminalFrame = Instance.new("Frame")
terminalFrame.Size = UDim2.new(1, 0, 0, 260)
terminalFrame.BackgroundColor3 = Theme.Header
terminalFrame.BackgroundTransparency = 0.15
terminalFrame.BorderSizePixel = 0
terminalFrame.ClipsDescendants = true
terminalFrame.Parent = DebugTab.Page

local tfCorner = Instance.new("UICorner", terminalFrame)
tfCorner.CornerRadius = UDim.new(0, 6)

local tfStroke = Instance.new("UIStroke", terminalFrame)
tfStroke.Color = Theme.Border
tfStroke.Thickness = 1

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -12, 1, -12)
logScroll.Position = UDim2.new(0, 6, 0, 6)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 3
logScroll.ScrollBarImageColor3 = Theme.BorderBright
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScroll.Parent = terminalFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logScroll

local logLabels = {}

local function rebuildLogs()
    for _, l in ipairs(logLabels) do
        if l and l.Parent then l:Destroy() end
    end
    logLabels = {}
    local shownCount = 0
    for idx, item in ipairs(debugLogs) do
        if filterQuery == "" or string.find(string.lower(item.raw), filterQuery, 1, true) then
            shownCount = shownCount + 1
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = item.raw
            lbl.TextColor3 = item.color
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 9
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = false
            lbl.ClipsDescendants = true
            lbl.LayoutOrder = idx
            lbl.Parent = logScroll
            table.insert(logLabels, lbl)
        end
    end
    statsLabel.Text = string.format("LOGS: %d / %d SHOWN  *  BUFFER: %d MAX", shownCount, #debugLogs, maxLogs)
    if autoScroll then
        task.defer(function()
            logScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end
end

refreshDebugUI = function(newItem)
    if not newItem then
        rebuildLogs()
        return
    end
    if filterQuery == "" or string.find(string.lower(newItem.raw), filterQuery, 1, true) then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = newItem.raw
        lbl.TextColor3 = newItem.color
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = false
        lbl.ClipsDescendants = true
        lbl.LayoutOrder = #debugLogs
        lbl.Parent = logScroll
        table.insert(logLabels, lbl)
        if #logLabels > maxLogs then
            local old = table.remove(logLabels, 1)
            if old and old.Parent then old:Destroy() end
        end
        statsLabel.Text = string.format("LOGS: %d SHOWN  *  BUFFER: %d", #logLabels, #debugLogs)
        if autoScroll then
            task.defer(function()
                logScroll.CanvasPosition = Vector2.new(0, 999999)
            end)
        end
    end
end

filterInput:GetPropertyChangedSignal("Text"):Connect(function()
    filterQuery = string.lower(filterInput.Text)
    rebuildLogs()
end)

copyLogsBtn.MouseButton1Click:Connect(function()
    local text = ""
    for _, item in ipairs(debugLogs) do
        text = text .. item.raw .. "\n"
    end
    if setclipboard then
        pcall(setclipboard, text)
        Notify("Debug", "Copied " .. #debugLogs .. " logs to clipboard", 2, Theme.Green)
    else
        Notify("Debug", "setclipboard is not supported", 2, Theme.Red)
    end
end)

clearLogsBtn.MouseButton1Click:Connect(function()
    debugLogs = {}
    for _, l in ipairs(logLabels) do
        if l and l.Parent then l:Destroy() end
    end
    logLabels = {}
    statsLabel.Text = "TOTAL LOGS: 0  *  BUFFER CLEARED"
    Notify("Debug", "Debug log buffer cleared", 1.5, Theme.Accent)
end)

SafetyTab:AddSection("Metamethod Shield Status")
SafetyTab:AddButton("Blocked: KickMe (Kick Remote)", function()
    Notify("Shield", "KickMe remote is safely blocked", 2.5, Theme.Green)
end)
SafetyTab:AddButton("Blocked: Blacklisted (Ban Remote)", function()
    Notify("Shield", "Blacklisted remote is safely blocked", 2.5, Theme.Green)
end)
SafetyTab:AddButton("Blocked: FullDatWipe (Data Wipe Remote)", function()
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

addDebugLog("INIT", "AikHub Bitcoin Miner Exploit Suite initialized successfully", Theme.Green)
addDebugLog("HOOK", "Metamethod __namecall hook active (Honeypots blocked)", Theme.Green)
addDebugLog("RAKNET", "RakNet Packet Grabber & Argument Tamperer ready", Theme.Accent)
addDebugLog("INFO", "LogService print/warn/error interception listening", Theme.Accent)

Notify("AIKHUB", "Bitcoin Miner script loaded! Press RShift to toggle", 4, Theme.Accent)
