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
MainFrame.Size = UDim2.new(0, 640, 0, 480)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
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
titleLabel.Size = UDim2.new(0, 220, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X  *  T R A D I N G  S I M"
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

local probeResults = {}

local function runAdminProbe()
    if not RSEAdmin then
        Notify("Admin Probe", "RSEAdmin folder not found!", 2, Theme.Red)
        return
    end

    local req = RSEAdmin:FindFirstChild("Request")
    local evt = RSEAdmin:FindFirstChild("Event")
    probeResults = {}
    Notify("Admin Probe", "Testing RSEAdmin payloads...", 2, Theme.Accent)

    local payloads = {
        "Admin", "GetAdmin", "GiveAdmin", "SetAdmin", "superadmin",
        "Cash", "Money", "Coins", "GiveMoney", "AddCash", "1000000000",
        "Speed", "BTools", "God", "Fly", "Infinite",
        {"Admin"}, {"GetAdmin"}, {"Give", "Cash", 1000000000}
    }

    local successCount = 0
    for _, p in ipairs(payloads) do
        local pStr = type(p) == "table" and ("table: " .. tostring(p[1])) or tostring(p)
        if req and req:IsA("RemoteFunction") then
            local ok, res = pcall(function() return req:InvokeServer(p) end)
            if ok and res ~= nil and res ~= false then
                successCount = successCount + 1
                table.insert(probeResults, string.format("[VULNERABLE] Request(%s) -> %s", pStr, tostring(res)))
            else
                table.insert(probeResults, string.format("[Blocked] Request(%s)", pStr))
            end
        end
        if evt and evt:IsA("RemoteEvent") then
            pcall(function() evt:FireServer(p) end)
        end
        task.wait(0.08)
    end

    local report = table.concat(probeResults, "\n")
    print("=== RSEADMIN PROBE RESULTS ===\n" .. report)
    if setclipboard then pcall(function() setclipboard(report) end) end
    Notify("Admin Probe", string.format("Probe Done! %d vulnerabilities. Copied to clipboard.", successCount), 3, successCount > 0 and Theme.Green or Theme.Red)
end

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

local AdminTab = createTab("Admin Probe")
AdminTab:AddSection("RSEAdmin Vulnerability Scanner")
AdminTab:AddButton("RUN DEEP RSEADMIN PROBE (TEST ALL PAYLOADS)", function() runAdminProbe() end)
AdminTab:AddButton("Test Give Cash (1,000,000,000)", function()
    if RSEAdmin then
        local req = RSEAdmin:FindFirstChild("Request")
        if req then pcall(function() req:InvokeServer("Cash", 1000000000) end) end
        local evt = RSEAdmin:FindFirstChild("Event")
        if evt then pcall(function() evt:FireServer("Cash", 1000000000) end) end
        Notify("Admin", "Fired Cash Payload", 1.5)
    end
end)
AdminTab:AddButton("Test GetAdmin Command", function()
    if RSEAdmin then
        local req = RSEAdmin:FindFirstChild("Request")
        if req then pcall(function() req:InvokeServer("GetAdmin") end) end
        Notify("Admin", "Fired GetAdmin Payload", 1.5)
    end
end)

local MarketTab = createTab("Market")
MarketTab:AddSection("Stocks & Crypto")
MarketTab:AddButton("Buy IPO Stock", function() safeInvoke("BuyIPO"); Notify("Market", "Invoked BuyIPO", 1.5) end)
MarketTab:AddButton("Trigger MemeCoin Action", function() safeInvoke("MemeCoinAction"); Notify("Market", "Invoked MemeCoinAction", 1.5) end)
MarketTab:AddButton("Trigger Estate Action (Real Estate)", function() safeInvoke("EstateAction"); Notify("Market", "Invoked EstateAction", 1.5) end)
MarketTab:AddButton("Trigger Vault Action", function() safeInvoke("VaultAction"); Notify("Market", "Invoked VaultAction", 1.5) end)

local SysTab = createTab("System")
SysTab:AddSection("Controls")
SysTab:AddButton("Hide Menu [ RightShift / Insert ]", function() setVisible(false) end)
SysTab:AddButton("Unload & Destroy Hub", function() ScreenGui:Destroy() end)

Notify("NIX", "Trading Sim Suite Loaded! Press RShift to Toggle.", 3.5, Theme.Green)
