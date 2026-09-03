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
    local coreGui = nil
    pcall(function() coreGui = game:GetService("CoreGui") end)
    if coreGui then
        local canUseCore = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = coreGui
            test:Destroy()
        end)
        if canUseCore then return coreGui end
    end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
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
    Background = Color3.fromRGB(8, 8, 10),
    Header = Color3.fromRGB(14, 14, 18),
    Accent = Color3.fromRGB(60, 220, 130),
    AccentDim = Color3.fromRGB(120, 120, 130),
    ElementBg = Color3.fromRGB(16, 16, 22),
    ElementHover = Color3.fromRGB(24, 24, 32),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Border = Color3.fromRGB(36, 36, 46),
    BorderBright = Color3.fromRGB(60, 220, 130),
    BarBg = Color3.fromRGB(20, 20, 26),
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
ScreenGui.DisplayOrder = 9999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = true
pcall(function() ScreenGui.Parent = guiParent end)
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 480)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local tbGlow = Instance.new("Frame")
tbGlow.Size = UDim2.new(1, 0, 0, 2)
tbGlow.BackgroundColor3 = Theme.Accent
tbGlow.BorderSizePixel = 0
tbGlow.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 360, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X   F O R E N S I C   S C A N N E R"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
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
Body.Size = UDim2.new(1, -24, 1, -56)
Body.Position = UDim2.new(0, 12, 0, 48)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 60)
StatusCard.BackgroundColor3 = Theme.Header
StatusCard.BorderSizePixel = 0
StatusCard.Parent = Body
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 6)
local scStroke = Instance.new("UIStroke", StatusCard)
scStroke.Color = Theme.Border
scStroke.Thickness = 1

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 8)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "INITIALIZING FORENSIC SCAN..."
statusLabel.TextColor3 = Theme.Accent
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = StatusCard

local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, -20, 0, 8)
progressTrack.Position = UDim2.new(0, 10, 0, 36)
progressTrack.BackgroundColor3 = Theme.BarBg
progressTrack.BorderSizePixel = 0
progressTrack.Parent = StatusCard
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Theme.Accent
progressFill.BorderSizePixel = 0
progressFill.Parent = progressTrack
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local pctLabel = Instance.new("TextLabel")
pctLabel.Size = UDim2.new(0, 60, 0, 20)
pctLabel.Position = UDim2.new(1, -70, 0, 8)
pctLabel.BackgroundTransparency = 1
pctLabel.Text = "0%"
pctLabel.TextColor3 = Theme.TextSecondary
pctLabel.Font = Enum.Font.Code
pctLabel.TextSize = 11
pctLabel.TextXAlignment = Enum.TextXAlignment.Right
pctLabel.Parent = StatusCard

local LogCard = Instance.new("Frame")
LogCard.Size = UDim2.new(1, 0, 1, -122)
LogCard.Position = UDim2.new(0, 0, 0, 68)
LogCard.BackgroundColor3 = Theme.Header
LogCard.BorderSizePixel = 0
LogCard.Parent = Body
Instance.new("UICorner", LogCard).CornerRadius = UDim.new(0, 6)
local lcStroke = Instance.new("UIStroke", LogCard)
lcStroke.Color = Theme.Border
lcStroke.Thickness = 1

local logTextBox = Instance.new("TextBox")
logTextBox.Size = UDim2.new(1, -16, 1, -16)
logTextBox.Position = UDim2.new(0, 8, 0, 8)
logTextBox.BackgroundTransparency = 1
logTextBox.Text = "Preparing audit stream..."
logTextBox.TextColor3 = Theme.TextPrimary
logTextBox.Font = Enum.Font.Code
logTextBox.TextSize = 10
logTextBox.ClearTextOnFocus = false
logTextBox.TextEditable = false
logTextBox.MultiLine = true
logTextBox.TextXAlignment = Enum.TextXAlignment.Left
logTextBox.TextYAlignment = Enum.TextYAlignment.Top
logTextBox.Parent = LogCard

local ActionsCard = Instance.new("Frame")
ActionsCard.Size = UDim2.new(1, 0, 0, 44)
ActionsCard.Position = UDim2.new(0, 0, 1, -44)
ActionsCard.BackgroundTransparency = 1
ActionsCard.Parent = Body

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.6, -6, 1, 0)
copyBtn.Position = UDim2.new(0, 0, 0, 0)
copyBtn.BackgroundColor3 = Theme.Accent
copyBtn.Text = "COPY COMPLETE AUDIT TO CLIPBOARD"
copyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.BorderSizePixel = 0
copyBtn.Parent = ActionsCard
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

local rescanBtn = Instance.new("TextButton")
rescanBtn.Size = UDim2.new(0.4, -6, 1, 0)
rescanBtn.Position = UDim2.new(0.6, 6, 0, 0)
rescanBtn.BackgroundColor3 = Theme.ElementBg
rescanBtn.Text = "RE-RUN SCAN"
rescanBtn.TextColor3 = Theme.TextPrimary
rescanBtn.Font = Enum.Font.GothamBold
rescanBtn.TextSize = 11
rescanBtn.BorderSizePixel = 0
rescanBtn.Parent = ActionsCard
Instance.new("UICorner", rescanBtn).CornerRadius = UDim.new(0, 6)
local rbStroke = Instance.new("UIStroke", rescanBtn)
rbStroke.Color = Theme.Border
rbStroke.Thickness = 1

local dossierLines = {}
local function setProgress(pct, msg)
    pct = math.clamp(pct, 0, 1)
    tw(progressFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.15)
    pctLabel.Text = tostring(math.round(pct * 100)) .. "%"
    if msg then statusLabel.Text = string.upper(msg) end
end

local function addLog(line)
    table.insert(dossierLines, line)
    if #dossierLines % 5 == 0 or #dossierLines < 20 then
        logTextBox.Text = table.concat(dossierLines, "\n")
    end
end

local isScanning = false
local function runAudit()
    if isScanning then return end
    isScanning = true
    dossierLines = {}
    logTextBox.Text = ""
    setProgress(0.05, "Scanning Session Metadata...")

    task.spawn(function()
        addLog("================================================================================")
        addLog("            N I X   F O R E N S I C   A U D I T O R   R E P O R T")
        addLog("================================================================================")
        addLog("TIMESTAMP       : " .. os.date("!%Y-%m-%dT%H:%M:%SZ"))
        addLog("PLACE ID        : " .. tostring(game.PlaceId))
        addLog("GAME ID         : " .. tostring(game.GameId))
        addLog("JOB ID          : " .. tostring(game.JobId))
        addLog("PLACE VERSION   : " .. tostring(game.PlaceVersion))
        addLog("PLAYER NAME     : " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")")
        addLog("USER ID         : " .. tostring(LocalPlayer.UserId))
        addLog("ACCOUNT AGE     : " .. tostring(LocalPlayer.AccountAge) .. " days")
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            addLog(string.format("HUMANOID STATS  : Health=%s/%s | WalkSpeed=%s | JumpPower=%s", tostring(hum.Health), tostring(hum.MaxHealth), tostring(hum.WalkSpeed), tostring(hum.JumpPower)))
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.15, "Probing Executor Environment...")

        addLog("[=== 1 ===] EXECUTOR CAPABILITIES & SECURITY HOOKS")
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
            addLog(string.format("  [%s] %s", it[2] and "YES" or " NO", it[1]))
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.30, "Sweeping Network Remotes...")

        addLog("[=== 2 ===] NETWORK REMOTES & DISPATCHERS")
        local remotesFound = {}
        local functionsFound = {}
        local seenRem = {}

        local scanContainers = {
            ReplicatedStorage,
            game:GetService("ReplicatedFirst"),
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("PlayerScripts")
        }

        for _, root in ipairs(scanContainers) do
            if root then
                pcall(function()
                    for _, inst in ipairs(root:GetDescendants()) do
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
                task.wait()
            end
        end

        addLog(string.format("Summary: %d RemoteFunctions, %d RemoteEvents", #functionsFound, #remotesFound))
        addLog("")
        addLog("=== RemoteFunctions ===")
        for idx, rf in ipairs(functionsFound) do
            addLog(string.format("  [%d] %s -> %s", idx, rf.Name, rf:GetFullName()))
        end
        addLog("")
        addLog("=== RemoteEvents ===")
        for idx, re in ipairs(remotesFound) do
            addLog(string.format("  [%d] %s -> %s", idx, re.Name, re:GetFullName()))
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.50, "Auditing Shared Modules...")

        addLog("[=== 3 ===] SHARED & REPLICATED MODULES")
        local sharedMods = {}
        pcall(function()
            for _, m in ipairs(ReplicatedStorage:GetDescendants()) do
                if m:IsA("ModuleScript") then
                    table.insert(sharedMods, m)
                end
            end
        end)

        addLog(string.format("Discovered %d Shared ModuleScripts:", #sharedMods))
        local stepMod = math.clamp(math.floor(#sharedMods / 20), 1, 20)
        for idx, mod in ipairs(sharedMods) do
            addLog(string.format("  [%d] %s -> %s", idx, mod.Name, mod:GetFullName()))
            if idx % stepMod == 0 then
                task.wait()
            end
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.70, "Scanning Client Scripts & Controllers...")

        addLog("[=== 4 ===] CLIENT SCRIPTS (PLAYERSCRIPTS)")
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local pScripts = {}
        if ps then
            pcall(function()
                for _, s in ipairs(ps:GetDescendants()) do
                    if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                        table.insert(pScripts, s)
                    end
                end
            end)
        end
        addLog(string.format("PlayerScripts Discovered: %d", #pScripts))
        for idx, s in ipairs(pScripts) do
            addLog(string.format("  [%d] [%s] %s -> %s", idx, s.ClassName, s.Name, s:GetFullName()))
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.85, "Inspecting GUI & Interactive Triggers...")

        addLog("[=== 5 ===] PLAYER GUI AUDIT (BUTTONS & INPUTS)")
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local buttons = {}
        local textInputs = {}
        if pg then
            pcall(function()
                for _, d in ipairs(pg:GetDescendants()) do
                    if d:IsA("TextButton") or d:IsA("ImageButton") then
                        table.insert(buttons, d)
                    elseif d:IsA("TextBox") then
                        table.insert(textInputs, d)
                    end
                end
            end)
        end
        addLog(string.format("Discovered %d Buttons, %d TextBoxes in PlayerGui", #buttons, #textInputs))
        local shownBtns = 0
        for idx, b in ipairs(buttons) do
            local txt = b:IsA("TextButton") and b.Text or ""
            local clean = txt:gsub("\n", " "):gsub("\r", ""):match("^%s*(.-)%s*$") or ""
            if clean ~= "" or idx <= 35 then
                shownBtns = shownBtns + 1
                addLog(string.format("  [%d] Button '%s' (Text: %q) -> %s", shownBtns, b.Name, clean, b:GetFullName()))
            end
            if shownBtns >= 50 then
                addLog(string.format("  ... (+%d more buttons in GUI)", #buttons - shownBtns))
                break
            end
        end
        addLog("")

        task.wait(0.05)
        setProgress(0.95, "Scanning World Triggers & Spawns...")

        addLog("[=== 6 ===] WORKSPACE INTERACTIVE TRIGGERS")
        local prompts = {}
        local clickDets = {}
        local toolsWorld = {}
        pcall(function()
            local wsItems = workspace:GetChildren()
            for _, folder in ipairs(wsItems) do
                if folder.Name ~= "Terrain" and folder.Name ~= "Camera" then
                    for _, d in ipairs(folder:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            table.insert(prompts, d)
                        elseif d:IsA("ClickDetector") then
                            table.insert(clickDets, d)
                        elseif d:IsA("Tool") then
                            table.insert(toolsWorld, d)
                        end
                    end
                end
            end
        end)
        addLog(string.format("Triggers: %d ProximityPrompts, %d ClickDetectors, %d World Tools", #prompts, #clickDets, #toolsWorld))
        for idx, p in ipairs(prompts) do
            if idx <= 15 then
                addLog(string.format("  [%d] Action: %q | Object: %q -> %s", idx, p.ActionText or "", p.ObjectText or "", p:GetFullName()))
            end
        end
        addLog("")

        addLog("================================================================================")
        addLog("                       E N D   O F   A U D I T")
        addLog("================================================================================")

        local fullTxt = table.concat(dossierLines, "\n")
        logTextBox.Text = fullTxt
        setProgress(1, "Scan Complete! Copying to Clipboard...")

        local copied = false
        if setclipboard then
            copied = pcall(setclipboard, fullTxt)
        elseif toclipboard then
            copied = pcall(toclipboard, fullTxt)
        end

        if copied then
            statusLabel.Text = string.format("COMPLETE! %d CHARACTERS COPIED TO CLIPBOARD.", #fullTxt)
            tw(copyBtn, {BackgroundColor3 = Color3.fromRGB(80, 255, 140)}, 0.2)
            copyBtn.Text = "COPIED TO CLIPBOARD! (CLICK TO RE-COPY)"
        else
            statusLabel.Text = "COMPLETE! REPORT READY (CLICK COPY BUTTON)."
        end
        isScanning = false
    end)
end

copyBtn.MouseButton1Click:Connect(function()
    local fullTxt = table.concat(dossierLines, "\n")
    if setclipboard then
        pcall(setclipboard, fullTxt)
        copyBtn.Text = "COPIED TO CLIPBOARD!"
    elseif toclipboard then
        pcall(toclipboard, fullTxt)
        copyBtn.Text = "COPIED TO CLIPBOARD!"
    else
        copyBtn.Text = "CLIPBOARD UNAVAILABLE (SEE LOG)"
    end
end)

rescanBtn.MouseButton1Click:Connect(function()
    runAudit()
end)

task.defer(runAudit)
