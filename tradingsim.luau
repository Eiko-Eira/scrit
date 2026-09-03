local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then return pg end
    local coreGui = nil
    pcall(function() coreGui = game:GetService("CoreGui") end)
    return coreGui or LocalPlayer:WaitForChild("PlayerGui", 10)
end

local guiParent = getGuiParent()
do
    pcall(function()
        if guiParent:FindFirstChild("NIXScannerUI") then
            guiParent.NIXScannerUI:Destroy()
        end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("NIXScannerUI") then
            pg.NIXScannerUI:Destroy()
        end
    end)
end

local Theme = {
    Background = Color3.fromRGB(10, 10, 14),
    Header = Color3.fromRGB(16, 16, 22),
    Accent = Color3.fromRGB(50, 255, 130),
    AccentDim = Color3.fromRGB(140, 140, 150),
    ElementBg = Color3.fromRGB(18, 18, 26),
    ElementHover = Color3.fromRGB(28, 28, 38),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(40, 40, 52),
    BorderBright = Color3.fromRGB(50, 255, 130),
    BarBg = Color3.fromRGB(24, 24, 32),
    Red = Color3.fromRGB(255, 60, 70)
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXScannerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = true
pcall(function() ScreenGui.Parent = guiParent end)
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1, 0, 0, 2)
topGlow.BackgroundColor3 = Theme.Accent
topGlow.BorderSizePixel = 0
topGlow.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 400, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X   *   G A M E   F O R E N S I C   S C A N N E R"
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
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Red, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.1) end)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -24, 1, -58)
Body.Position = UDim2.new(0, 12, 0, 48)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

local ControlCard = Instance.new("Frame")
ControlCard.Size = UDim2.new(1, 0, 0, 78)
ControlCard.BackgroundColor3 = Theme.Header
ControlCard.BorderSizePixel = 0
ControlCard.Parent = Body
Instance.new("UICorner", ControlCard).CornerRadius = UDim.new(0, 6)
local ccStroke = Instance.new("UIStroke", ControlCard)
ccStroke.Color = Theme.Border
ccStroke.Thickness = 1

local startScanBtn = Instance.new("TextButton")
startScanBtn.Size = UDim2.new(0.65, -6, 0, 34)
startScanBtn.Position = UDim2.new(0, 10, 0, 8)
startScanBtn.BackgroundColor3 = Theme.Accent
startScanBtn.Text = "START DEEP FORENSIC SCAN"
startScanBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
startScanBtn.Font = Enum.Font.GothamBold
startScanBtn.TextSize = 11
startScanBtn.BorderSizePixel = 0
startScanBtn.Parent = ControlCard
Instance.new("UICorner", startScanBtn).CornerRadius = UDim.new(0, 5)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.35, -14, 0, 34)
copyBtn.Position = UDim2.new(0.65, 4, 0, 8)
copyBtn.BackgroundColor3 = Theme.ElementBg
copyBtn.Text = "COPY TO CLIPBOARD"
copyBtn.TextColor3 = Theme.TextSecondary
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.BorderSizePixel = 0
copyBtn.Parent = ControlCard
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)
local cbStroke = Instance.new("UIStroke", copyBtn)
cbStroke.Color = Theme.Border
cbStroke.Thickness = 1

local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, -20, 0, 6)
progressTrack.Position = UDim2.new(0, 10, 0, 48)
progressTrack.BackgroundColor3 = Theme.BarBg
progressTrack.BorderSizePixel = 0
progressTrack.Parent = ControlCard
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Theme.Accent
progressFill.BorderSizePixel = 0
progressFill.Parent = progressTrack
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 10, 0, 58)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: IDLE (CLICK 'START DEEP FORENSIC SCAN')"
statusLabel.TextColor3 = Theme.AccentDim
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = ControlCard

local pctLabel = Instance.new("TextLabel")
pctLabel.Size = UDim2.new(0.2, -10, 0, 16)
pctLabel.Position = UDim2.new(0.8, 0, 0, 58)
pctLabel.BackgroundTransparency = 1
pctLabel.Text = "0%"
pctLabel.TextColor3 = Theme.TextSecondary
pctLabel.Font = Enum.Font.Code
pctLabel.TextSize = 10
pctLabel.TextXAlignment = Enum.TextXAlignment.Right
pctLabel.Parent = ControlCard

local ConsoleCard = Instance.new("Frame")
ConsoleCard.Size = UDim2.new(1, 0, 1, -88)
ConsoleCard.Position = UDim2.new(0, 0, 0, 88)
ConsoleCard.BackgroundColor3 = Theme.Header
ConsoleCard.BorderSizePixel = 0
ConsoleCard.Parent = Body
Instance.new("UICorner", ConsoleCard).CornerRadius = UDim.new(0, 6)
local conStroke = Instance.new("UIStroke", ConsoleCard)
conStroke.Color = Theme.Border
conStroke.Thickness = 1

local consoleBox = Instance.new("TextBox")
consoleBox.Size = UDim2.new(1, -16, 1, -16)
consoleBox.Position = UDim2.new(0, 8, 0, 8)
consoleBox.BackgroundTransparency = 1
consoleBox.Text = "NIX Forensic Scanner Ready.\nClick 'START DEEP FORENSIC SCAN' above to analyze this game."
consoleBox.TextColor3 = Theme.TextPrimary
consoleBox.Font = Enum.Font.Code
consoleBox.TextSize = 10
consoleBox.ClearTextOnFocus = false
consoleBox.TextEditable = false
consoleBox.MultiLine = true
consoleBox.TextXAlignment = Enum.TextXAlignment.Left
consoleBox.TextYAlignment = Enum.TextYAlignment.Top
consoleBox.Parent = ConsoleCard

local isRunningScan = false
local cachedReport = ""

local function setProgress(pct, msg)
    pct = math.clamp(pct, 0, 1)
    tw(progressFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.12)
    pctLabel.Text = tostring(math.round(pct * 100)) .. "%"
    if msg then statusLabel.Text = string.upper(msg) end
end

local function executeForensicAudit()
    if isRunningScan then return end
    isRunningScan = true
    cachedReport = ""
    startScanBtn.Text = "SCANNING IN PROGRESS..."
    tw(startScanBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.15)
    consoleBox.Text = "Auditing game architecture... please wait."

    task.spawn(function()
        local lines = {}
        local function add(s) table.insert(lines, s or "") end

        setProgress(0.05, "1/6: Gathering Session Metadata...")
        task.wait(0.05)

        add("================================================================================")
        add("            N I X   F O R E N S I C   A U D I T O R   R E P O R T")
        add("================================================================================")
        add("TIMESTAMP       : " .. os.date("!%Y-%m-%dT%H:%M:%SZ"))
        add("PLACE ID        : " .. tostring(game.PlaceId))
        add("GAME ID         : " .. tostring(game.GameId))
        add("JOB ID          : " .. tostring(game.JobId))
        add("PLACE VERSION   : " .. tostring(game.PlaceVersion))
        add("PLAYER NAME     : " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")")
        add("USER ID         : " .. tostring(LocalPlayer.UserId))
        add("ACCOUNT AGE     : " .. tostring(LocalPlayer.AccountAge) .. " days")
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            add(string.format("HUMANOID STATS  : Health=%s/%s | WalkSpeed=%s | JumpPower=%s", tostring(hum.Health), tostring(hum.MaxHealth), tostring(hum.WalkSpeed), tostring(hum.JumpPower)))
        end
        add("")

        setProgress(0.18, "2/6: Probing Executor Capabilities...")
        task.wait(0.05)

        add("[=== 1 ===] EXECUTOR CAPABILITIES & SECURITY HOOKS")
        local envChecks = {
            {"getgenv", type(getgenv) == "function"},
            {"getrenv", type(getrenv) == "function"},
            {"getsenv", type(getsenv) == "function"},
            {"getreg", type(getreg) == "function"},
            {"getgc", type(getgc) == "function"},
            {"getinstances", type(getinstances) == "function"},
            {"getnilinstances", type(getnilinstances) == "function"},
            {"getscripts", type(getscripts) == "function"},
            {"getloadedmodules", type(getloadedmodules) == "function"},
            {"hookmetamethod", type(hookmetamethod) == "function"},
            {"hookfunction", type(hookfunction) == "function"},
            {"firesignal", type(firesignal) == "function"},
            {"fireclickdetector", type(fireclickdetector) == "function"},
            {"fireproximityprompt", type(fireproximityprompt) == "function"},
            {"setclipboard", type(setclipboard) == "function" or type(toclipboard) == "function"},
            {"getconnections", type(getconnections) == "function"},
            {"gethui", type(gethui) == "function"}
        }
        for _, it in ipairs(envChecks) do
            add(string.format("  [%s] %s", it[2] and "YES" or " NO", it[1]))
        end
        add("")

        setProgress(0.35, "3/6: Sweeping Network Remotes...")
        task.wait(0.05)

        add("[=== 2 ===] NETWORK REMOTES & DISPATCHERS")
        local remotesFound = {}
        local functionsFound = {}
        local seenRem = {}

        local scanRoots = {
            ReplicatedStorage,
            game:GetService("ReplicatedFirst"),
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("PlayerScripts")
        }

        for _, root in ipairs(scanRoots) do
            if root then
                pcall(function()
                    local count = 0
                    for _, inst in ipairs(root:GetDescendants()) do
                        count = count + 1
                        if count % 100 == 0 then task.wait() end
                        if not seenRem[inst] then
                            seenRem[inst] = true
                            if inst:IsA("RemoteFunction") then
                                table.insert(functionsFound, inst)
                            elseif inst:IsA("RemoteEvent") then
                                table.insert(remotesFound, inst)
                            end
                        end
                    end
                end)
                task.wait(0.02)
            end
        end

        add(string.format("Summary: %d RemoteFunctions, %d RemoteEvents", #functionsFound, #remotesFound))
        add("")
        add("=== RemoteFunctions ===")
        for idx, rf in ipairs(functionsFound) do
            add(string.format("  [%d] %s -> %s", idx, rf.Name, rf:GetFullName()))
        end
        add("")
        add("=== RemoteEvents ===")
        for idx, re in ipairs(remotesFound) do
            add(string.format("  [%d] %s -> %s", idx, re.Name, re:GetFullName()))
        end
        add("")

        setProgress(0.55, "4/6: Auditing Shared ModuleScripts...")
        task.wait(0.05)

        add("[=== 3 ===] SHARED & REPLICATED MODULES")
        local sharedMods = {}
        pcall(function()
            local count = 0
            for _, m in ipairs(ReplicatedStorage:GetDescendants()) do
                count = count + 1
                if count % 100 == 0 then task.wait() end
                if m:IsA("ModuleScript") then
                    table.insert(sharedMods, m)
                end
            end
        end)

        add(string.format("Discovered %d Shared ModuleScripts:", #sharedMods))
        for idx, mod in ipairs(sharedMods) do
            add(string.format("  [%d] %s -> %s", idx, mod.Name, mod:GetFullName()))
        end
        add("")

        setProgress(0.75, "5/6: Scanning Client PlayerScripts...")
        task.wait(0.05)

        add("[=== 4 ===] CLIENT SCRIPTS (PLAYERSCRIPTS)")
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local pScripts = {}
        if ps then
            pcall(function()
                local count = 0
                for _, s in ipairs(ps:GetDescendants()) do
                    count = count + 1
                    if count % 100 == 0 then task.wait() end
                    if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                        table.insert(pScripts, s)
                    end
                end
            end)
        end
        add(string.format("PlayerScripts Discovered: %d", #pScripts))
        for idx, s in ipairs(pScripts) do
            add(string.format("  [%d] [%s] %s -> %s", idx, s.ClassName, s.Name, s:GetFullName()))
        end
        add("")

        setProgress(0.90, "6/6: Auditing PlayerGui Buttons & Inputs...")
        task.wait(0.05)

        add("[=== 5 ===] PLAYER GUI AUDIT (BUTTONS & INPUTS)")
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local buttons = {}
        local textInputs = {}
        if pg then
            pcall(function()
                local count = 0
                for _, d in ipairs(pg:GetDescendants()) do
                    count = count + 1
                    if count % 100 == 0 then task.wait() end
                    if d:IsA("TextButton") or d:IsA("ImageButton") then
                        table.insert(buttons, d)
                    elseif d:IsA("TextBox") then
                        table.insert(textInputs, d)
                    end
                end
            end)
        end
        add(string.format("Discovered %d Buttons, %d TextBoxes in PlayerGui", #buttons, #textInputs))
        local shownBtns = 0
        for idx, b in ipairs(buttons) do
            local txt = b:IsA("TextButton") and b.Text or ""
            local clean = txt:gsub("\n", " "):gsub("\r", ""):match("^%s*(.-)%s*$") or ""
            if clean ~= "" or idx <= 35 then
                shownBtns = shownBtns + 1
                add(string.format("  [%d] Button '%s' (Text: %q) -> %s", shownBtns, b.Name, clean, b:GetFullName()))
            end
            if shownBtns >= 50 then
                add(string.format("  ... (+%d more buttons in GUI)", #buttons - shownBtns))
                break
            end
        end
        add("")

        add("================================================================================")
        add("                       E N D   O F   A U D I T")
        add("================================================================================")

        cachedReport = table.concat(lines, "\n")
        consoleBox.Text = cachedReport
        setProgress(1, "Scan Complete! Report Ready.")

        local copied = false
        if setclipboard then
            copied = pcall(setclipboard, cachedReport)
        elseif toclipboard then
            copied = pcall(toclipboard, cachedReport)
        end

        tw(startScanBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
        startScanBtn.Text = "RE-RUN FORENSIC SCAN"

        tw(copyBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
        if copied then
            copyBtn.Text = "COPIED TO CLIPBOARD!"
            statusLabel.Text = string.format("COMPLETE! %d CHARACTERS COPIED TO CLIPBOARD.", #cachedReport)
        else
            copyBtn.Text = "COPY TO CLIPBOARD"
            statusLabel.Text = "COMPLETE! CLICK 'COPY TO CLIPBOARD'."
        end
        isRunningScan = false
    end)
end

startScanBtn.MouseButton1Click:Connect(function()
    executeForensicAudit()
end)

copyBtn.MouseButton1Click:Connect(function()
    if cachedReport == "" then return end
    if setclipboard then
        pcall(setclipboard, cachedReport)
        copyBtn.Text = "COPIED!"
    elseif toclipboard then
        pcall(toclipboard, cachedReport)
        copyBtn.Text = "COPIED!"
    end
end)
