local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
do
    local old = guiParent:FindFirstChild("NIXTradingSimUI")
    if old then old:Destroy() end
    local oldPg = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("NIXTradingSimUI")
    if oldPg then oldPg:Destroy() end
end

local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(8, 8, 10),
    Sidebar = Color3.fromRGB(4, 4, 6),
    TabActive = Color3.fromRGB(255, 255, 255),
    TabActiveText = Color3.fromRGB(0, 0, 0),
    TabInactive = Color3.fromRGB(12, 12, 16),
    TabInactiveText = Color3.fromRGB(140, 140, 150),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentDim = Color3.fromRGB(170, 170, 180),
    ElementBg = Color3.fromRGB(12, 12, 16),
    ElementHover = Color3.fromRGB(22, 22, 28),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(35, 35, 42),
    BorderBright = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(50, 255, 130),
    Red = Color3.fromRGB(255, 50, 70)
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXTradingSimUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 15
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = guiParent

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
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Theme.Header
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = 201
    card.Parent = NotifHolder

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Theme.Border
    cardStroke.Thickness = 1

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = color
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 202
    accentBar.Parent = card

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -20, 0, 18)
    nTitle.Position = UDim2.new(0, 12, 0, 6)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = string.upper(title)
    nTitle.TextColor3 = color
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 11
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.ZIndex = 202
    nTitle.Parent = card

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -20, 0, 18)
    nDesc.Position = UDim2.new(0, 12, 0, 25)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = desc
    nDesc.TextColor3 = Theme.TextSecondary
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 11
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.ZIndex = 202
    nDesc.Parent = card

    card.Position = UDim2.new(1, 20, 0, 0)
    tw(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back)

    task.delay(duration, function()
        if card and card.Parent then
            tw(card, {Position = UDim2.new(1, 20, 0, 0)}, 0.18).Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 670, 0, 500)
MainFrame.Position = UDim2.new(0.5, -335, 0.5, -250)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1

local topNeonBar = Instance.new("Frame")
topNeonBar.Size = UDim2.new(1, 0, 0, 2)
topNeonBar.BackgroundColor3 = Theme.Accent
topNeonBar.BorderSizePixel = 0
topNeonBar.ZIndex = 10
topNeonBar.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 320, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X  *  A I  Q U A N T  &  S N I P E R"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = Theme.ElementBg
closeBtn.Text = "x"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

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
    MainFrame.Visible = v
end
closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and (inp.KeyCode == Enum.KeyCode.RightShift or inp.KeyCode == Enum.KeyCode.Insert) then
        setVisible(not isVisible)
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 136, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

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
ContentArea.Size = UDim2.new(1, -136, 1, -42)
ContentArea.Position = UDim2.new(0, 136, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local AllTabs = {}
local activeTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.Text = string.upper(name)
    tabBtn.TextColor3 = Theme.TabInactiveText
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)

    local tPad = Instance.new("UIPadding", tabBtn)
    tPad.PaddingLeft = UDim.new(0, 10)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.Border
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 5)
    pageLayout.Parent = page

    local tabObj = {Button = tabBtn, Page = page, Name = name}

    local function select()
        if activeTab and activeTab ~= tabObj then
            activeTab.Page.Visible = false
            tw(activeTab.Button, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabInactiveText}, 0.12)
        end
        activeTab = tabObj
        page.Visible = true
        tw(tabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabActiveText}, 0.12)
    end

    tabBtn.MouseButton1Click:Connect(select)
    if #AllTabs == 0 then task.defer(select) end
    table.insert(AllTabs, tabObj)

    function tabObj:AddSection(label)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundTransparency = 1
        row.Parent = page

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(label)
        lbl.TextColor3 = Theme.AccentDim
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
    end

    function tabObj:AddButton(label, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Theme.ElementBg
        btn.Text = label
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Theme.Border
        bStroke.Thickness = 1

        btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = Theme.ElementHover}, 0.1) tw(bStroke, {Color = Theme.BorderBright}, 0.1) end)
        btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = Theme.ElementBg}, 0.1) tw(bStroke, {Color = Theme.Border}, 0.1) end)
        btn.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
        return btn
    end

    function tabObj:AddToggle(label, default, cb)
        local state = default or false
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = Theme.ElementBg
        row.Text = ""
        row.BorderSizePixel = 0
        row.Parent = page
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        local rStroke = Instance.new("UIStroke", row)
        rStroke.Color = Theme.Border
        rStroke.Thickness = 1

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
        Instance.new("UICorner", swTrack).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
        knob.BorderSizePixel = 0
        knob.Parent = swTrack
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function setToggle(v)
            state = v
            tw(swTrack, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.12)
            tw(knob, {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = state and Theme.Background or Theme.TextSecondary}, 0.12)
            if cb then task.spawn(cb, state) end
        end

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
        container.BorderSizePixel = 0
        container.Parent = page
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
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
        valLbl.TextColor3 = Theme.AccentDim
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local trackBg = Instance.new("Frame")
        trackBg.Size = UDim2.new(1, -22, 0, 5)
        trackBg.Position = UDim2.new(0, 11, 0, 30)
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
        handle.ZIndex = 5
        handle.Parent = trackBg
        Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

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
            if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                applySlide(inp.Position)
            end
        end)
    end

    return tabObj
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local RSEAdmin = ReplicatedStorage:WaitForChild("RSEAdmin", 5)

local function safeInvoke(remoteName, ...)
    if not Remotes then return nil end
    local rem = Remotes:FindFirstChild(remoteName)
    if rem and rem:IsA("RemoteFunction") then
        local ok, res = pcall(function(...) return rem:InvokeServer(...) end, ...)
        return ok and res or nil
    end
    return nil
end

local function safeFire(remoteName, ...)
    if not Remotes then return end
    local rem = Remotes:FindFirstChild(remoteName)
    if rem and rem:IsA("RemoteEvent") then
        pcall(function(...) rem:FireServer(...) end, ...)
    end
end

local function dumpValue(val, depth, seen)
    seen = seen or {}
    depth = depth or 0
    if depth > 3 then return "{...}" end
    if type(val) == "table" then
        if seen[val] then return "<circular>" end
        seen[val] = true
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, string.format("%s = %s", tostring(k), dumpValue(v, depth + 1, seen)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif type(val) == "string" then
        return string.format("%q", val)
    else
        return tostring(val)
    end
end

local knownCompanies = {}
local heldStocks = {}
local interceptedLogs = {}
local maxInterceptLogs = 30
local hookActive = false
local pushConn = nil
local spyTextBox = nil
local latestRawPacket = nil

local autoMemeSniperEnabled = true
local memeSniperBuyAmount = 100

local function updateCompaniesFromData(compTable)
    if type(compTable) ~= "table" then return end
    for k, v in pairs(compTable) do
        if type(v) == "table" then
            local ticker = v.ticker or v.symbol or v.name or v.id or tostring(k)
            local price = v.price or v.sharePrice or v.currentPrice or v.val or (v.history and v.history[#v.history]) or 10
            knownCompanies[ticker] = {
                id = v.id or k,
                ticker = ticker,
                name = v.name or ticker,
                price = price,
                raw = v
            }
        elseif type(v) == "number" then
            knownCompanies[tostring(k)] = {
                id = k,
                ticker = tostring(k),
                name = tostring(k),
                price = v
            }
        end
    end
end

local function addInterceptLog(entry)
    table.insert(interceptedLogs, 1, string.format("[%s] %s", os.date("%X"), entry))
    if #interceptedLogs > maxInterceptLogs then
        table.remove(interceptedLogs)
    end
    if spyTextBox then spyTextBox.Text = table.concat(interceptedLogs, "\n") end
end

local function handleMemeSniper(data)
    if not autoMemeSniperEnabled or not data then return end
    local coinId = data.coinId or data.id or data.ticker
    local ticker = data.ticker or data.name or "MEME"
    local name = tostring(ticker)

    task.spawn(function()
        local r1 = safeInvoke("MemeCoinAction", coinId, "Buy", memeSniperBuyAmount)
        local r2 = safeInvoke("MemeCoinAction", {Action = "Buy", CoinId = coinId, Amount = memeSniperBuyAmount})
        local r3 = safeInvoke("MemeCoinAction", name, "Buy", memeSniperBuyAmount)
        local r4 = safeInvoke("Trade", name, "Buy", memeSniperBuyAmount)

        Notify("MEME SNIPER", string.format("SNIPED %s (ID: %s) Instant Buy Fired!", name, tostring(coinId)), 3, Theme.Green)

        task.delay(10, function()
            safeInvoke("MemeCoinAction", coinId, "Sell", memeSniperBuyAmount)
            safeInvoke("MemeCoinAction", name, "Sell", memeSniperBuyAmount)
            safeInvoke("Trade", name, "Sell", memeSniperBuyAmount)
            Notify("MEME EXIT", string.format("Auto-Sold Sniped Meme: %s (10s exit)", name), 2.5, Theme.Accent)
        end)
    end)
end

local function onPushReceived(...)
    local args = {...}
    for _, item in ipairs(args) do
        if type(item) == "table" then
            latestRawPacket = item
            local kind = item.kind
            local data = item.data
            if kind == "companyStocksUpdated" and data and data.companies then
                updateCompaniesFromData(data.companies)
            elseif kind == "memeCall" and data then
                local t = data.ticker or data.name or "MEME"
                Notify("MEME CALL", "New Meme: " .. tostring(t), 2.5, Theme.Green)
                handleMemeSniper(data)
            end
        end
    end
    addInterceptLog("PUSH RX: " .. dumpValue(args))
end

local function startPushStreamListener()
    if pushConn then pushConn:Disconnect() pushConn = nil end
    local pushRemote = Remotes and Remotes:FindFirstChild("Push")
    if pushRemote and pushRemote:IsA("RemoteEvent") then
        pushConn = pushRemote.OnClientEvent:Connect(onPushReceived)
        Notify("Hook", "Connected to Push RemoteEvent stream!", 2, Theme.Green)
    else
        Notify("Hook", "Remotes.Push not found", 2, Theme.Red)
    end
end

task.defer(startPushStreamListener)

local function activateNamecallSpyHook()
    if hookActive then return end
    if not hookmetamethod or not getnamecallmethod or not checkcaller then
        Notify("Hook", "Executor does not support hookmetamethod", 2.5, Theme.Red)
        return
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
            local objName = tostring(self.Name)
            local pName = self.Parent and tostring(self.Parent.Name) or "Root"
            local logMsg = string.format("%s.%s:%s(%s)", pName, objName, method, dumpValue(args))
            addInterceptLog(logMsg)
        end
        return oldNamecall(self, ...)
    end)
    hookActive = true
    Notify("Hook", "Namecall Spy Hook Active!", 2.5, Theme.Green)
end

local function unpackLatestPacket()
    local lines = {"=== DEEP PACKET UNPACKER REPORT ==="}
    if latestRawPacket and type(latestRawPacket) == "table" then
        table.insert(lines, "Packet Kind: " .. tostring(latestRawPacket.kind))
        if latestRawPacket.data and type(latestRawPacket.data) == "table" then
            for k, v in pairs(latestRawPacket.data) do
                table.insert(lines, "\n=== [FIELD: " .. tostring(k) .. "] ===")
                table.insert(lines, dumpValue(v, 0))
            end
        end
    else
        table.insert(lines, "No recent Push packet cached yet. Polling GetCompanyStocks...")
        local res = safeInvoke("GetCompanyStocks")
        if res then
            table.insert(lines, "\n=== [GetCompanyStocks Response] ===")
            table.insert(lines, dumpValue(res, 0))
        end
    end

    local report = table.concat(lines, "\n")
    print(report)
    if setclipboard then pcall(function() setclipboard(report) end) end
    Notify("Unpacker", "Packet details copied to clipboard & printed to console!", 3, Theme.Green)
end

local function dumpCoreModules()
    local modules = {
        {"PriceEngine", "ReplicatedStorage.Shared.PriceEngine"},
        {"RSEScript", "ReplicatedStorage.Shared.RSEScript"},
        {"Config", "ReplicatedStorage.Shared.Config"},
        {"AlgoStrategy", "ReplicatedStorage.Shared.AlgoStrategy"},
        {"MarketClock", "ReplicatedStorage.Shared.MarketClock"},
        {"State", "PlayerScripts.Client.State"},
        {"TradePanel", "PlayerScripts.Client.TradePanel"}
    }

    local report = {"=== CORE MODULES DUMP ==="}
    for _, item in ipairs(modules) do
        local name = item[1]
        local path = item[2]
        table.insert(report, "\n=== [" .. name .. "] (" .. path .. ") ===")

        local modInstance = nil
        if path:find("ReplicatedStorage.Shared") then
            modInstance = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild(name)
        elseif path:find("PlayerScripts.Client") then
            local client = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Client")
            modInstance = client and client:FindFirstChild(name)
        end

        if modInstance and modInstance:IsA("ModuleScript") then
            local decompiled = false
            if decompile then
                local ok, src = pcall(decompile, modInstance)
                if ok and src and #src > 10 then
                    decompiled = true
                    table.insert(report, "[DECOMPILED SOURCE]\n" .. src)
                    if writefile then pcall(function() writefile(name .. "_dump.luau", src) end) end
                end
            end

            if not decompiled then
                local ok, tbl = pcall(require, modInstance)
                if ok then
                    table.insert(report, "[MEMORY TABLE DUMP]\n" .. dumpValue(tbl))
                else
                    table.insert(report, "[REQUIRE FAILED] " .. tostring(tbl))
                end
            end
        else
            table.insert(report, "[NOT FOUND]")
        end
    end

    local outStr = table.concat(report, "\n")
    print(outStr)
    if setclipboard then pcall(function() setclipboard(outStr) end) end
    if writefile then pcall(function() writefile("TradingSim_CoreDump.txt", outStr) end) end
    Notify("Dumper", "Dump Complete! Copied to clipboard & saved to workspace files.", 3.5, Theme.Green)
end

local aiBotEnabled = false
local aiBotThread = nil
local maxHoldTime = 10
local takeProfitPct = 12
local stopLossPct = 5
local trailingStopPct = 2.5
local minSignalScore = 70
local maxConcurrentTrades = 3

local activeTrades = {}
local assetStats = {}
local sessionWins = 0
local sessionLosses = 0
local lastActionLog = "None"
local cooldowns = {}
local liveMetricsLabel = nil

local function updateMetricsUI()
    if not liveMetricsLabel then return end
    local activeNames = {}
    for name, t in pairs(activeTrades) do
        local d = math.round((os.clock() - t.entryTime) * 10) / 10
        table.insert(activeNames, string.format("%s (%ss)", name, tostring(d)))
    end
    local posStr = #activeNames > 0 and table.concat(activeNames, ", ") or "None"
    local totalTrades = sessionWins + sessionLosses
    local winrate = totalTrades > 0 and math.round((sessionWins / totalTrades) * 100) or 100

    local stockCount = 0
    for _ in pairs(knownCompanies) do stockCount = stockCount + 1 end

    liveMetricsLabel.Text = string.format("STOCKS TRACKED: %d | ACTIVE POSITIONS: %s\nWINS: %d | LOSSES: %d | WINRATE: %d%%\nLAST: %s", stockCount, posStr, sessionWins, sessionLosses, winrate, lastActionLog)
end

local function executeBuyOrder(name, id, price, score)
    local qty = 100
    safeInvoke("InvestCompanyStock", id, qty)
    safeInvoke("InvestCompanyStock", name, qty)
    safeInvoke("Trade", name, "Buy", qty)
    safeInvoke("Trade", {Stock = name, Action = "Buy", Amount = qty})
    safeInvoke("MemeCoinAction", name, "Buy", qty)

    activeTrades[name] = {
        id = id,
        entryPrice = price,
        entryTime = os.clock(),
        highestPrice = price,
        quantity = qty,
        score = score
    }

    lastActionLog = string.format("BUY %s @ $%s (Score: %d)", name, tostring(price), score)
    updateMetricsUI()
    Notify("AI Trader", string.format("BOUGHT %s @ $%s (Score: %d)", name, tostring(price), score), 2, Theme.Accent)
end

local function executeSellOrder(name, curPrice, reason)
    local trade = activeTrades[name]
    if not trade then return end

    local pnl = ((curPrice - trade.entryPrice) / trade.entryPrice) * 100
    local holdDuration = math.round((os.clock() - trade.entryTime) * 10) / 10
    local roundedPnl = math.round(pnl * 10) / 10
    local id = trade.id or name

    safeInvoke("SellCompanyStock", id, trade.quantity or 100)
    safeInvoke("SellCompanyStock", name, trade.quantity or 100)
    safeInvoke("Trade", name, "Sell", trade.quantity or 100)
    safeInvoke("Trade", {Stock = name, Action = "Sell", Amount = trade.quantity or 100})
    safeInvoke("MemeCoinAction", name, "Sell", trade.quantity or 100)

    activeTrades[name] = nil
    cooldowns[name] = os.clock() + 4

    if roundedPnl >= 0 then
        sessionWins = sessionWins + 1
        lastActionLog = string.format("SOLD %s +%s%% (%s, %ss)", name, tostring(roundedPnl), reason, tostring(holdDuration))
        Notify("PROFIT SECURED", string.format("Sold %s (+%s%%) in %ss [%s]", name, tostring(roundedPnl), tostring(holdDuration), reason), 2.5, Theme.Green)
    else
        sessionLosses = sessionLosses + 1
        lastActionLog = string.format("EXIT %s %s%% (%s, %ss)", name, tostring(roundedPnl), reason, tostring(holdDuration))
        Notify("STOP LOSS", string.format("Exited %s (%s%%) in %ss [%s]", name, tostring(roundedPnl), tostring(holdDuration), reason), 2.5, Theme.Red)
    end
    updateMetricsUI()
end

local function calculateAssetScore(name, curPrice, ticks)
    if #ticks < 4 then return 50 end
    local score = 50

    local p1 = ticks[#ticks - 3].price
    local p2 = ticks[#ticks - 2].price
    local p3 = ticks[#ticks - 1].price
    local p4 = curPrice

    local velRecent = (p4 - p3)
    local velPrev = (p3 - p2)
    local velOld = (p2 - p1)

    if velRecent > 0 and velRecent >= velPrev and velPrev >= velOld then
        score = score + 28
    elseif velRecent > 0 then
        score = score + 14
    elseif velRecent < 0 then
        score = score - 20
    end

    local gains = 0
    local losses = 0
    for i = 2, #ticks do
        local diff = ticks[i].price - ticks[i-1].price
        if diff > 0 then gains = gains + diff else losses = losses + math.abs(diff) end
    end

    local rsi = 50
    if (gains + losses) > 0 then rsi = (gains / (gains + losses)) * 100 end

    if rsi >= 25 and rsi <= 45 and velRecent > 0 then
        score = score + 20
    elseif rsi > 80 then
        score = score - 25
    end

    local stats = assetStats[name]
    if stats and stats.lowest and stats.highest and stats.highest > stats.lowest then
        local rangePos = (curPrice - stats.lowest) / (stats.highest - stats.lowest)
        if rangePos <= 0.25 and velRecent > 0 then
            score = score + 15
        elseif rangePos >= 0.90 then
            score = score - 15
        end
    end

    return math.clamp(math.round(score), 0, 100)
end

local function evaluateMarketCycle()
    local now = os.clock()
    local activeCount = 0
    for _ in pairs(activeTrades) do activeCount = activeCount + 1 end

    for name, trade in pairs(activeTrades) do
        if not heldStocks[name] then
            local curPrice = 0
            local comp = knownCompanies[name]
            if comp and comp.price then
                curPrice = comp.price
            end

            if curPrice > 0 then
                if curPrice > trade.highestPrice then
                    trade.highestPrice = curPrice
                end

                local holdDuration = now - trade.entryTime
                local pnlPct = ((curPrice - trade.entryPrice) / trade.entryPrice) * 100
                local pullbackFromPeak = ((trade.highestPrice - curPrice) / trade.highestPrice) * 100

                local shouldExit = false
                local exitReason = ""

                if holdDuration >= maxHoldTime then
                    shouldExit = true
                    exitReason = string.format("Time Limit (%ds)", maxHoldTime)
                elseif pnlPct >= takeProfitPct then
                    shouldExit = true
                    exitReason = string.format("Target (+%s%%)", tostring(takeProfitPct))
                elseif pnlPct <= -stopLossPct then
                    shouldExit = true
                    exitReason = string.format("Stop Loss (-%s%%)", tostring(stopLossPct))
                elseif trade.highestPrice > (trade.entryPrice * 1.035) and pullbackFromPeak >= trailingStopPct then
                    shouldExit = true
                    exitReason = string.format("Trailing Stop (-%s%% peak)", tostring(trailingStopPct))
                end

                if shouldExit then
                    executeSellOrder(name, curPrice, exitReason)
                end
            end
        end
    end

    for ticker, comp in pairs(knownCompanies) do
        local curPrice = comp.price or 0
        local name = ticker
        local id = comp.id or ticker

        if curPrice > 0 then
            if not assetStats[name] then
                assetStats[name] = {ticks = {}, lowest = curPrice, highest = curPrice}
            end

            local st = assetStats[name]
            table.insert(st.ticks, {time = now, price = curPrice})
            if #st.ticks > 25 then table.remove(st.ticks, 1) end
            if curPrice < st.lowest then st.lowest = curPrice end
            if curPrice > st.highest then st.highest = curPrice end

            local inCooldown = cooldowns[name] and (now < cooldowns[name])
            if not activeTrades[name] and not inCooldown and not heldStocks[name] and activeCount < maxConcurrentTrades then
                local score = calculateAssetScore(name, curPrice, st.ticks)
                if score >= minSignalScore then
                    activeCount = activeCount + 1
                    executeBuyOrder(name, id, curPrice, score)
                end
            end
        end
    end
    updateMetricsUI()
end

local function setAITradingBot(enabled)
    aiBotEnabled = enabled
    if enabled then
        aiBotThread = task.spawn(function()
            while aiBotEnabled do
                pcall(evaluateMarketCycle)
                task.wait(0.35)
            end
        end)
        Notify("AI Trader", "Smart Trading Bot ACTIVE (10s Auto-Exit & Momentum)", 3, Theme.Green)
    else
        if aiBotThread then task.cancel(aiBotThread) aiBotThread = nil end
        Notify("AI Trader", "Smart Trading Bot DEACTIVATED", 1.5)
    end
end

local function buyRandomStockAndKeep()
    local count = 0
    for _ in pairs(knownCompanies) do count = count + 1 end

    if count == 0 then
        local res = safeInvoke("GetCompanyStocks")
        if res then
            updateCompaniesFromData(res)
            for _ in pairs(knownCompanies) do count = count + 1 end
        end
    end

    if count == 0 then
        local snap = safeInvoke("SectorSnapshot")
        if snap and type(snap) == "table" and snap.companies then
            updateCompaniesFromData(snap.companies)
            for _ in pairs(knownCompanies) do count = count + 1 end
        end
    end

    local list = {}
    for _, comp in pairs(knownCompanies) do
        table.insert(list, comp)
    end

    if #list == 0 then
        Notify("Random Buy", "No stocks discovered yet! Push stream is receiving tickers...", 2.5, Theme.Red)
        return
    end

    local chosen = list[math.random(1, #list)]
    local id = chosen.id
    local ticker = chosen.ticker
    local price = chosen.price or 10
    local amount = 100

    task.spawn(function()
        local res1 = safeInvoke("InvestCompanyStock", id, amount)
        local res2 = safeInvoke("InvestCompanyStock", ticker, amount)
        local res3 = safeInvoke("Trade", ticker, "Buy", amount)
        local res4 = safeInvoke("Trade", {Stock = ticker, Action = "Buy", Amount = amount})
        local res5 = safeInvoke("BuyIPO", id)

        heldStocks[ticker] = true
        lastActionLog = string.format("BOUGHT & KEPT: %s ($%s)", ticker, tostring(price))
        updateMetricsUI()
        Notify("BOUGHT & KEPT", string.format("Bought random stock: %s ($%s) - HELD PERMANENTLY", ticker, tostring(price)), 3.5, Theme.Green)
        print(string.format("=== BOUGHT RANDOM STOCK [%s] ===", ticker))
        print("Invest(id) ->", tostring(res1))
        print("Invest(ticker) ->", tostring(res2))
        print("Trade ->", tostring(res3))
    end)
end

local function panicSellAll()
    local count = 0
    for name, trade in pairs(activeTrades) do
        if not heldStocks[name] then
            local comp = knownCompanies[name]
            local curPrice = comp and comp.price or 1
            executeSellOrder(name, curPrice, "Panic Liquidate")
            count = count + 1
        end
    end
    updateMetricsUI()
    Notify("AI Trader", "Liquidated " .. count .. " positions!", 2, Theme.Red)
end

local autoClaimEnabled = false
local autoClaimThread = nil

local function setAutoClaim(enabled)
    autoClaimEnabled = enabled
    if enabled then
        autoClaimThread = task.spawn(function()
            while autoClaimEnabled do
                safeInvoke("ClaimDaily")
                safeInvoke("ClaimReward")
                safeInvoke("ClaimCareer")
                safeInvoke("ClaimCloseReport")
                safeInvoke("AdReward")
                safeInvoke("FreeSkip")
                task.wait(2.5)
            end
        end)
        Notify("Auto-Farm", "Auto-Claim All Rewards ON", 2, Theme.Green)
    else
        if autoClaimThread then task.cancel(autoClaimThread) autoClaimThread = nil end
        Notify("Auto-Farm", "Auto-Claim All Rewards OFF", 1.5)
    end
end

local autoUpgradeEnabled = false
local autoUpgradeThread = nil

local function setAutoUpgrade(enabled)
    autoUpgradeEnabled = enabled
    if enabled then
        autoUpgradeThread = task.spawn(function()
            while autoUpgradeEnabled do
                safeInvoke("ClaimDesk")
                safeInvoke("BuyDeskUpgrade")
                safeInvoke("BuyUpgrade")
                task.wait(2)
            end
        end)
        Notify("Progression", "Auto-Upgrade Desks & Stats ON", 2, Theme.Green)
    else
        if autoUpgradeThread then task.cancel(autoUpgradeThread) autoUpgradeThread = nil end
        Notify("Progression", "Auto-Upgrade OFF", 1.5)
    end
end

local autoRebirthEnabled = false
local autoRebirthThread = nil

local function setAutoRebirth(enabled)
    autoRebirthEnabled = enabled
    if enabled then
        autoRebirthThread = task.spawn(function()
            while autoRebirthEnabled do
                safeInvoke("Rebirth")
                task.wait(3)
            end
        end)
        Notify("Progression", "Auto-Rebirth ON", 2, Theme.Green)
    else
        if autoRebirthThread then task.cancel(autoRebirthThread) autoRebirthThread = nil end
        Notify("Progression", "Auto-Rebirth OFF", 1.5)
    end
end

local TraderTab = createTab("AI Trader")
TraderTab:AddSection("Random Stock Execution")
TraderTab:AddButton("RANDOM BUY A STOCK & KEEP (HOLD FOREVER)", function() buyRandomStockAndKeep() end)

TraderTab:AddSection("Meme Coin Sniper")
TraderTab:AddToggle("Auto-Snipe Meme Coins (On memeCall)", true, function(v) autoMemeSniperEnabled = v end)
TraderTab:AddSlider("Meme Snipe Amount", 10, 1000, 100, function(v) memeSniperBuyAmount = v end)

TraderTab:AddSection("Autonomous Trading Engine")
TraderTab:AddToggle("AI Trading Bot (Auto Buy & Smart Exit)", false, function(v) setAITradingBot(v) end)
TraderTab:AddSlider("Auto-Sell Max Hold Time (Seconds)", 3, 60, 10, function(v) maxHoldTime = v end)
TraderTab:AddSlider("Take-Profit Target (%)", 5, 50, 12, function(v) takeProfitPct = v end)
TraderTab:AddSlider("Stop-Loss Cutoff (%)", 2, 20, 5, function(v) stopLossPct = v end)
TraderTab:AddSlider("Trailing Stop Reversal (%)", 1, 10, 3, function(v) trailingStopPct = v end)
TraderTab:AddSlider("Signal Confidence Threshold", 50, 95, 70, function(v) minSignalScore = v end)
TraderTab:AddSlider("Max Concurrent Positions", 1, 10, 3, function(v) maxConcurrentTrades = v end)

TraderTab:AddSection("Actions")
TraderTab:AddButton("EMERGENCY PANIC SELL ALL (LIQUIDATE)", function() panicSellAll() end)
TraderTab:AddButton("Reset Session Win/Loss Stats", function() sessionWins = 0; sessionLosses = 0; lastActionLog = "Reset"; updateMetricsUI(); Notify("AI Trader", "Stats Reset", 1.5) end)

local metricsCard = Instance.new("Frame")
metricsCard.Size = UDim2.new(1, 0, 0, 56)
metricsCard.BackgroundColor3 = Theme.Header
metricsCard.BorderSizePixel = 0
metricsCard.Parent = TraderTab.Page
Instance.new("UICorner", metricsCard).CornerRadius = UDim.new(0, 5)
local mcStroke = Instance.new("UIStroke", metricsCard)
mcStroke.Color = Theme.Border
mcStroke.Thickness = 1

liveMetricsLabel = Instance.new("TextLabel")
liveMetricsLabel.Size = UDim2.new(1, -16, 1, -10)
liveMetricsLabel.Position = UDim2.new(0, 8, 0, 5)
liveMetricsLabel.BackgroundTransparency = 1
liveMetricsLabel.Text = "STOCKS TRACKED: 0 | ACTIVE POSITIONS: None\nWINS: 0 | LOSSES: 0 | WINRATE: 100%\nLAST: Idle"
liveMetricsLabel.TextColor3 = Theme.Accent
liveMetricsLabel.Font = Enum.Font.Code
liveMetricsLabel.TextSize = 10
liveMetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
liveMetricsLabel.Parent = metricsCard

local HookTab = createTab("Hook & Spy")
HookTab:AddSection("Packet Inspection & Hooks")
HookTab:AddButton("UNPACK LATEST PUSH PACKET (DEEP INSPECTION)", function() unpackLatestPacket() end)
HookTab:AddButton("ACTIVATE NAMECALL SPY HOOK", function() activateNamecallSpyHook() end)
HookTab:AddButton("RECONNECT PUSH STREAM LISTENER", function() startPushStreamListener() end)
HookTab:AddButton("DUMP & DECOMPILE ALL CORE MODULES", function() dumpCoreModules() end)
HookTab:AddButton("Copy Intercepted Network Logs", function()
    local txt = table.concat(interceptedLogs, "\n")
    if setclipboard then pcall(function() setclipboard(txt) end) end
    Notify("Hook", "Copied " .. #interceptedLogs .. " packet logs to clipboard!", 2, Theme.Green)
end)
HookTab:AddButton("Clear Intercepted Logs", function() interceptedLogs = {}; updateSpyUI(); Notify("Hook", "Cleared logs", 1.5) end)

HookTab:AddSection("Live Intercepted Packets")
local spyCard = Instance.new("Frame")
spyCard.Size = UDim2.new(1, 0, 0, 140)
spyCard.BackgroundColor3 = Theme.Header
spyCard.BorderSizePixel = 0
spyCard.Parent = HookTab.Page
Instance.new("UICorner", spyCard).CornerRadius = UDim.new(0, 5)
local scStroke = Instance.new("UIStroke", spyCard)
scStroke.Color = Theme.Border
scStroke.Thickness = 1

spyTextBox = Instance.new("TextBox")
spyTextBox.Size = UDim2.new(1, -16, 1, -12)
spyTextBox.Position = UDim2.new(0, 8, 0, 6)
spyTextBox.BackgroundTransparency = 1
spyTextBox.Text = "Network interceptor logs will appear here..."
spyTextBox.TextColor3 = Theme.AccentDim
spyTextBox.Font = Enum.Font.Code
spyTextBox.TextSize = 9
spyTextBox.ClearTextOnFocus = false
spyTextBox.TextEditable = false
spyTextBox.MultiLine = true
spyTextBox.TextXAlignment = Enum.TextXAlignment.Left
spyTextBox.TextYAlignment = Enum.TextYAlignment.Top
spyTextBox.Parent = spyCard

local FarmTab = createTab("Auto-Farm")
FarmTab:AddSection("Instant Money & Reward Loops")
FarmTab:AddToggle("Auto-Claim All Rewards (Loop)", false, function(v) setAutoClaim(v) end)
FarmTab:AddButton("Recover From Bankruptcy (Free Bailout)", function() safeInvoke("RecoverBankruptcy"); Notify("Money", "Invoked RecoverBankruptcy", 1.5, Theme.Green) end)
FarmTab:AddButton("Claim Daily Reward Now", function() safeInvoke("ClaimDaily"); Notify("Money", "Claimed Daily", 1.5, Theme.Green) end)
FarmTab:AddButton("Claim Milestone Reward Now", function() safeInvoke("ClaimReward"); Notify("Money", "Claimed Reward", 1.5, Theme.Green) end)
FarmTab:AddButton("Claim Career Payout Now", function() safeInvoke("ClaimCareer"); Notify("Money", "Claimed Career", 1.5, Theme.Green) end)
FarmTab:AddButton("Claim Market Close Report Now", function() safeInvoke("ClaimCloseReport"); Notify("Money", "Claimed Close Report", 1.5, Theme.Green) end)
FarmTab:AddButton("Bypass Ad Reward (Free Money)", function() safeInvoke("AdReward"); Notify("Money", "Bypassed Ad Reward", 1.5, Theme.Green) end)
FarmTab:AddButton("Free Time Skip", function() safeInvoke("FreeSkip"); Notify("Money", "Invoked FreeSkip", 1.5, Theme.Green) end)

local ProgTab = createTab("Progression")
ProgTab:AddSection("Automation")
ProgTab:AddToggle("Auto-Claim & Upgrade Desks", false, function(v) setAutoUpgrade(v) end)
ProgTab:AddToggle("Auto-Rebirth", false, function(v) setAutoRebirth(v) end)
ProgTab:AddButton("Claim Office Desk Now", function() safeInvoke("ClaimDesk"); Notify("Desk", "Invoked ClaimDesk", 1.5) end)
ProgTab:AddButton("Buy Desk Upgrade Now", function() safeInvoke("BuyDeskUpgrade"); Notify("Desk", "Invoked BuyDeskUpgrade", 1.5) end)
ProgTab:AddButton("Buy Stat Upgrade Now", function() safeInvoke("BuyUpgrade"); Notify("Stats", "Invoked BuyUpgrade", 1.5) end)
ProgTab:AddButton("Trigger VIP Simulator Status", function() safeInvoke("VipSim"); Notify("VIP", "Invoked VipSim", 1.5, Theme.Green) end)
ProgTab:AddButton("Rebirth Now", function() safeInvoke("Rebirth"); Notify("Progression", "Invoked Rebirth", 1.5) end)

local AdminTab = createTab("Admin & RSE")
AdminTab:AddSection("Security & Admin Analyzer")
AdminTab:AddButton("RUN DEEP RSEADMIN PROBE (TEST ALL PAYLOADS)", function()
    if not RSEAdmin then Notify("Admin Probe", "RSEAdmin not found!", 2, Theme.Red) return end
    local req = RSEAdmin:FindFirstChild("Request")
    local payloads = {"Admin", "GetAdmin", "Cash", "Money", "Coins", "1000000000", "Speed", "BTools", "God"}
    local lines = {"=== RSEADMIN PROBE RESULTS ==="}
    for _, p in ipairs(payloads) do
        if req and req:IsA("RemoteFunction") then
            local ok, res = pcall(function() return req:InvokeServer(p) end)
            table.insert(lines, string.format("Request(%s) -> %s", tostring(p), tostring(res)))
        end
        task.wait(0.06)
    end
    local rep = table.concat(lines, "\n")
    print(rep)
    if setclipboard then pcall(function() setclipboard(rep) end) end
    Notify("Admin Probe", "Probe Complete! Logged to Console & Clipboard.", 3, Theme.Green)
end)
AdminTab:AddButton("FORCE UNHIDE HIDDEN ADMIN GUIS", function()
    local cnt = 0
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name:find("Admin") or gui.Name:find("RSE") or gui.Name:find("Debug") then
            pcall(function() gui.Enabled = true end)
            cnt = cnt + 1
        end
    end
    Notify("Admin", "Unhid " .. cnt .. " potential Admin GUIs", 2, Theme.Green)
end)

local MarketTab = createTab("Market")
MarketTab:AddSection("Manual Market Controls")
MarketTab:AddButton("Buy IPO Stock", function() safeInvoke("BuyIPO"); Notify("Market", "Invoked BuyIPO", 1.5) end)
MarketTab:AddButton("Trigger MemeCoin Action", function() safeInvoke("MemeCoinAction"); Notify("Market", "Invoked MemeCoinAction", 1.5) end)
MarketTab:AddButton("Trigger Estate Action (Real Estate)", function() safeInvoke("EstateAction"); Notify("Market", "Invoked EstateAction", 1.5) end)
MarketTab:AddButton("Trigger Vault Action", function() safeInvoke("VaultAction"); Notify("Market", "Invoked VaultAction", 1.5) end)

local SysTab = createTab("System")
SysTab:AddSection("Controls")
SysTab:AddButton("Hide Menu [ RightShift / Insert ]", function() setVisible(false) end)
SysTab:AddButton("Unload & Destroy Hub", function() ScreenGui:Destroy() end)

Notify("NIX", "AI Quant & Sniper Loaded! Press RShift to Toggle.", 3.5, Theme.Green)
