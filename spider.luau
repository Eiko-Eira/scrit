local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

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
    local old = targetGuiParent:FindFirstChild("AikFakeVerifiedUI")
    if old then old:Destroy() end
    local oldP = LocalPlayer:FindFirstChild("PlayerGui")
    if oldP then
        local old2 = oldP:FindFirstChild("AikFakeVerifiedUI")
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
    Gold          = Color3.fromRGB(240, 190, 60),
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
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

local function sendChatMessage(msg)
    local sent = false
    if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannels = TextChatService:FindFirstChild("TextChannels")
        local general = textChannels and textChannels:FindFirstChild("RBXGeneral")
        if general then
            local ok = pcall(function()
                general:SendAsync(msg)
            end)
            if ok then sent = true end
        end
    end

    if not sent then
        local sayReq = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if sayReq then
            local ok = pcall(function()
                sayReq:FireServer(msg, "All")
            end)
            if ok then sent = true end
        end
    end

    return sent
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AikFakeVerifiedUI"
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
    tLbl.ZIndex = 501
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
    dLbl.ZIndex = 501
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

local MiniToggleChip = Instance.new("TextButton")
MiniToggleChip.Name = "MiniToggleChip"
MiniToggleChip.Size = UDim2.new(0, 95, 0, 26)
MiniToggleChip.Position = UDim2.new(0, 16, 0, 16)
MiniToggleChip.BackgroundColor3 = Theme.Header
MiniToggleChip.Text = "VERIFIED UI"
MiniToggleChip.TextColor3 = Theme.Gold
MiniToggleChip.Font = Enum.Font.GothamBold
MiniToggleChip.TextSize = 10
MiniToggleChip.BorderSizePixel = 0
MiniToggleChip.ZIndex = 600
MiniToggleChip.Active = true
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
MainFrame.Size = UDim2.new(0, 420, 0, 430)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -215)
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
titleLabel.Size = UDim2.new(0, 220, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FAKE VERIFIED & CHAT SUITE"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12
titleLabel.Active = false
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 130, 1, 0)
subtitleLabel.Position = UDim2.new(0, 225, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "by eikovo * scriptblox"
subtitleLabel.TextColor3 = Theme.Gold
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

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 44)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = MainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 5)
contentLayout.Parent = Content

local TipCard = Instance.new("Frame")
TipCard.Size = UDim2.new(1, 0, 0, 36)
TipCard.BackgroundColor3 = Theme.CardBg
TipCard.BorderSizePixel = 0
TipCard.ZIndex = 12
TipCard.Parent = Content

local tcCorner = Instance.new("UICorner")
tcCorner.CornerRadius = UDim.new(0, 4)
tcCorner.Parent = TipCard

local tcStroke = Instance.new("UIStroke")
tcStroke.Color = Theme.Border
tcStroke.Thickness = 1
tcStroke.Parent = TipCard

local tipLbl = Instance.new("TextLabel")
tipLbl.Size = UDim2.new(1, -12, 1, 0)
tipLbl.Position = UDim2.new(0, 6, 0, 0)
tipLbl.BackgroundTransparency = 1
tipLbl.Text = "Tip: In pause menu (ESC), change Experience Language to Tieng Viet for the Verified badge trick."
tipLbl.TextColor3 = Theme.Gold
tipLbl.Font = Enum.Font.Gotham
tipLbl.TextSize = 9
tipLbl.TextWrapped = true
tipLbl.TextXAlignment = Enum.TextXAlignment.Left
tipLbl.ZIndex = 13
tipLbl.Active = false
tipLbl.Parent = TipCard

local activePrefix = "  "
local activePrefixName = "Verified (Spaces)"

local PrefixCard = Instance.new("Frame")
PrefixCard.Size = UDim2.new(1, 0, 0, 30)
PrefixCard.BackgroundColor3 = Theme.CardBg
PrefixCard.BorderSizePixel = 0
PrefixCard.ZIndex = 12
PrefixCard.Parent = Content

local pcCorner = Instance.new("UICorner")
pcCorner.CornerRadius = UDim.new(0, 4)
pcCorner.Parent = PrefixCard

local pcStroke = Instance.new("UIStroke")
pcStroke.Color = Theme.Border
pcStroke.Thickness = 1
pcStroke.Parent = PrefixCard

local pcLayout = Instance.new("UIListLayout")
pcLayout.FillDirection = Enum.FillDirection.Horizontal
pcLayout.SortOrder = Enum.SortOrder.LayoutOrder
pcLayout.Padding = UDim.new(0, 4)
pcLayout.Parent = PrefixCard

local pcPad = Instance.new("UIPadding")
pcPad.PaddingLeft = UDim.new(0, 4)
pcPad.PaddingRight = UDim.new(0, 4)
pcPad.PaddingTop = UDim.new(0, 3)
pcPad.PaddingBottom = UDim.new(0, 3)
pcPad.Parent = PrefixCard

local function createPresetButton(title, prefixVal, isDefault)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, -3, 1, 0)
    btn.BackgroundColor3 = isDefault and Theme.Gold or Theme.Header
    btn.Text = title
    btn.TextColor3 = isDefault and Theme.Background or Theme.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.ZIndex = 13
    btn.Active = true
    btn.AutoButtonColor = false
    btn.Parent = PrefixCard

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 3)
    bCorner.Parent = btn

    btn.Activated:Connect(function()
        activePrefix = prefixVal
        activePrefixName = title
        notify("Preset Selected", "Active Prefix: " .. title, 1.5, Theme.Gold)
        for _, child in ipairs(PrefixCard:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = (child == btn) and Theme.Gold or Theme.Header
                child.TextColor3 = (child == btn) and Theme.Background or Theme.TextPrimary
            end
        end
    end)
    return btn
end

createPresetButton("VERIFIED", "  ", true)
createPresetButton("[SYSTEM]", "[System]: ", false)
createPresetButton("[ADMIN]", "[SERVER]: ", false)
createPresetButton("RAW", "", false)

local InputCard = Instance.new("Frame")
InputCard.Size = UDim2.new(1, 0, 0, 105)
InputCard.BackgroundColor3 = Theme.CardBg
InputCard.BorderSizePixel = 0
InputCard.ZIndex = 12
InputCard.Parent = Content

local icCorner = Instance.new("UICorner")
icCorner.CornerRadius = UDim.new(0, 4)
icCorner.Parent = InputCard

local icStroke = Instance.new("UIStroke")
icStroke.Color = Theme.Border
icStroke.Thickness = 1
icStroke.Parent = InputCard

local msgBox = Instance.new("TextBox")
msgBox.Size = UDim2.new(1, -12, 1, -12)
msgBox.Position = UDim2.new(0, 6, 0, 6)
msgBox.BackgroundTransparency = 1
msgBox.Text = "Hello everyone!"
msgBox.TextColor3 = Theme.TextPrimary
msgBox.Font = Enum.Font.Gotham
msgBox.TextSize = 11
msgBox.ClearTextOnFocus = false
msgBox.TextWrapped = true
msgBox.TextXAlignment = Enum.TextXAlignment.Left
msgBox.TextYAlignment = Enum.TextYAlignment.Top
msgBox.ZIndex = 13
msgBox.Parent = InputCard

local ActionRow1 = Instance.new("Frame")
ActionRow1.Size = UDim2.new(1, 0, 0, 30)
ActionRow1.BackgroundTransparency = 1
ActionRow1.ZIndex = 12
ActionRow1.Parent = Content

local ar1Layout = Instance.new("UIListLayout")
ar1Layout.FillDirection = Enum.FillDirection.Horizontal
ar1Layout.SortOrder = Enum.SortOrder.LayoutOrder
ar1Layout.Padding = UDim.new(0, 6)
ar1Layout.Parent = ActionRow1

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0.48, -3, 1, 0)
sendBtn.BackgroundColor3 = Theme.Green
sendBtn.Text = "SEND TO CHAT"
sendBtn.TextColor3 = Theme.Background
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 10
sendBtn.BorderSizePixel = 0
sendBtn.ZIndex = 13
sendBtn.Active = true
sendBtn.AutoButtonColor = false
sendBtn.Parent = ActionRow1

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 4)
sbCorner.Parent = sendBtn

local copyMsgBtn = Instance.new("TextButton")
copyMsgBtn.Size = UDim2.new(0.32, -3, 1, 0)
copyMsgBtn.BackgroundColor3 = Theme.CardBg
copyMsgBtn.Text = "COPY TEXT"
copyMsgBtn.TextColor3 = Theme.TextPrimary
copyMsgBtn.Font = Enum.Font.Gotham
copyMsgBtn.TextSize = 10
copyMsgBtn.BorderSizePixel = 0
copyMsgBtn.ZIndex = 13
copyMsgBtn.Active = true
copyMsgBtn.AutoButtonColor = false
copyMsgBtn.Parent = ActionRow1

local cb1Corner = Instance.new("UICorner")
cb1Corner.CornerRadius = UDim.new(0, 4)
cb1Corner.Parent = copyMsgBtn

local cb1Stroke = Instance.new("UIStroke")
cb1Stroke.Color = Theme.Border
cb1Stroke.Thickness = 1
cb1Stroke.Parent = copyMsgBtn

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.20, -3, 1, 0)
clearBtn.BackgroundColor3 = Theme.CardBg
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = Theme.TextSecondary
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 10
clearBtn.BorderSizePixel = 0
clearBtn.ZIndex = 13
clearBtn.Active = true
clearBtn.AutoButtonColor = false
clearBtn.Parent = ActionRow1

local clrCorner = Instance.new("UICorner")
clrCorner.CornerRadius = UDim.new(0, 4)
clrCorner.Parent = clearBtn

local clrStroke = Instance.new("UIStroke")
clrStroke.Color = Theme.Border
clrStroke.Thickness = 1
clrStroke.Parent = clearBtn

local lastSendClick = 0
sendBtn.Activated:Connect(function()
    local now = os.clock()
    if now - lastSendClick < 0.25 then return end
    lastSendClick = now

    local raw = msgBox.Text
    if #raw == 0 then
        notify("Chat", "Please enter a message first.", 2, Theme.Crimson)
        return
    end

    local finalPayload = activePrefix .. raw
    local ok = sendChatMessage(finalPayload)
    if ok then
        notify("Sent", string.format("Sent with %s prefix!", activePrefixName), 2, Theme.Green)
    else
        notify("Chat Error", "Could not dispatch chat remote in this game.", 2.5, Theme.Crimson)
    end
end)

copyMsgBtn.Activated:Connect(function()
    local finalPayload = activePrefix .. msgBox.Text
    local ok = copyToClipboard(finalPayload)
    if ok then
        copyMsgBtn.Text = "COPIED!"
        notify("Clipboard", "Message copied to clipboard!", 2, Theme.Purple)
        task.delay(1.8, function() copyMsgBtn.Text = "COPY TEXT" end)
    else
        notify("Clipboard", "Clipboard unavailable on executor.", 2, Theme.Crimson)
    end
end)

clearBtn.Activated:Connect(function()
    msgBox.Text = ""
    notify("Cleared", "Message box emptied.", 1.2, Theme.TextSecondary)
end)

local fakeAdminBtn = Instance.new("TextButton")
fakeAdminBtn.Size = UDim2.new(1, 0, 0, 30)
fakeAdminBtn.BackgroundColor3 = Theme.Header
fakeAdminBtn.Text = "LAUNCH FAKEADMIN SCRIPT (Universal-Script-FakeAdmin-33991)"
fakeAdminBtn.TextColor3 = Theme.Gold
fakeAdminBtn.Font = Enum.Font.GothamBold
fakeAdminBtn.TextSize = 9
fakeAdminBtn.BorderSizePixel = 0
fakeAdminBtn.ZIndex = 13
fakeAdminBtn.Active = true
fakeAdminBtn.AutoButtonColor = false
fakeAdminBtn.Parent = Content

local faCorner = Instance.new("UICorner")
faCorner.CornerRadius = UDim.new(0, 4)
faCorner.Parent = fakeAdminBtn

local faStroke = Instance.new("UIStroke")
faStroke.Color = Theme.Border
faStroke.Thickness = 1
faStroke.Parent = fakeAdminBtn

fakeAdminBtn.MouseEnter:Connect(function()
    tw(fakeAdminBtn, {BackgroundColor3 = Theme.CardHover}, 0.12)
    tw(faStroke, {Color = Theme.Gold}, 0.12)
end)
fakeAdminBtn.MouseLeave:Connect(function()
    tw(fakeAdminBtn, {BackgroundColor3 = Theme.Header}, 0.12)
    tw(faStroke, {Color = Theme.Border}, 0.12)
end)

local lastFaClick = 0
fakeAdminBtn.Activated:Connect(function()
    local now = os.clock()
    if now - lastFaClick < 0.5 then return end
    lastFaClick = now

    notify("FakeAdmin", "Downloading & executing FakeAdmin...", 2, Theme.Gold)
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FakeAdmin-33991"))()
        end)
        if ok then
            notify("FakeAdmin", "FakeAdmin successfully loaded!", 2.5, Theme.Green)
        else
            notify("FakeAdmin", "Failed to load FakeAdmin URL.", 2.5, Theme.Crimson)
        end
    end)
end)

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
footer.Text = "Credits: eikovo * scriptblox | Right Shift to Toggle"
footer.TextColor3 = Theme.TextSecondary
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 12
footer.Active = false
footer.Parent = Content
