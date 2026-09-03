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
        if guiParent:FindFirstChild("NIXMinesUI") then
            guiParent.NIXMinesUI:Destroy()
        end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("NIXMinesUI") then
            pg.NIXMinesUI:Destroy()
        end
    end)
end

local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentDim = Color3.fromRGB(160, 160, 160),
    ElementBg = Color3.fromRGB(14, 14, 14),
    ElementHover = Color3.fromRGB(26, 26, 26),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(140, 140, 140),
    Border = Color3.fromRGB(45, 45, 45),
    BorderBright = Color3.fromRGB(255, 255, 255)
}

local function tw(obj, props, t)
    local info = TweenInfo.new(t or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXMinesUI"
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
MainFrame.Size = UDim2.new(0, 680, 0, 540)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -270)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Theme.Border
mfStroke.Thickness = 1

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local tbBottomLine = Instance.new("Frame")
tbBottomLine.Size = UDim2.new(1, 0, 0, 1)
tbBottomLine.Position = UDim2.new(0, 0, 1, -1)
tbBottomLine.BackgroundColor3 = Theme.Border
tbBottomLine.BorderSizePixel = 0
tbBottomLine.Parent = TopBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 420, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X   *   M I N E S   F O R E N S I C   M O N I T O R"
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

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0, 0, 0)}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}) end)
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

local ControlsRow = Instance.new("Frame")
ControlsRow.Size = UDim2.new(1, 0, 0, 76)
ControlsRow.BackgroundColor3 = Theme.Header
ControlsRow.BorderSizePixel = 0
ControlsRow.Parent = Body
Instance.new("UICorner", ControlsRow).CornerRadius = UDim.new(0, 6)
local crStroke = Instance.new("UIStroke", ControlsRow)
crStroke.Color = Theme.Border
crStroke.Thickness = 1

local function createBtn(parent, pos, size, text, isPrimary, cb)
    local btn = Instance.new("TextButton")
    btn.Position = pos
    btn.Size = size
    btn.BackgroundColor3 = isPrimary and Theme.Accent or Theme.ElementBg
    btn.Text = text
    btn.TextColor3 = isPrimary and Color3.fromRGB(0, 0, 0) or Theme.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local st = Instance.new("UIStroke", btn)
    st.Color = Theme.Border
    st.Thickness = 1

    btn.MouseEnter:Connect(function()
        tw(btn, {BackgroundColor3 = isPrimary and Color3.fromRGB(220, 220, 220) or Theme.ElementHover})
        tw(st, {Color = Theme.BorderBright})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, {BackgroundColor3 = isPrimary and Theme.Accent or Theme.ElementBg})
        tw(st, {Color = Theme.Border})
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then task.spawn(cb) end
    end)
    return btn
end

local debugLogs = {}
local maxDebugLogs = 80
local logTextBox = nil

local function addLog(msg)
    local line = string.format("[%s] %s", os.date("%X"), msg)
    table.insert(debugLogs, 1, line)
    if #debugLogs > maxDebugLogs then table.remove(debugLogs) end
    if logTextBox and logTextBox.Parent then
        logTextBox.Text = table.concat(debugLogs, "\n")
    end
    print("[NIX MINES] " .. line)
end

local function dumpVal(val, depth, seen)
    seen = seen or {}
    depth = depth or 0
    if depth > 3 then return "{...}" end
    if type(val) == "table" then
        if seen[val] then return "<circular>" end
        seen[val] = true
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, string.format("%s = %s", tostring(k), dumpVal(v, depth + 1, seen)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif type(val) == "string" then
        return string.format("%q", val)
    else
        return tostring(val)
    end
end

local remotesFolder = ReplicatedStorage:WaitForChild("MinesIncrementalRemotes", 5)

local function hookAllEvents()
    if not remotesFolder then
        addLog("[ERR] MinesIncrementalRemotes folder not found in ReplicatedStorage!")
        return
    end

    addLog("=== ATTACHING NETWORK HOOKS TO EVENTS ===")
    local evCount = 0

    local streamEvent = remotesFolder:FindFirstChild("RevealStream")
    if streamEvent and streamEvent:IsA("RemoteEvent") then
        streamEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("RevealStream RX: " .. dumpVal(args))
        end)
        evCount = evCount + 1
        addLog("Hooked RemoteEvent: RevealStream")
    end

    local resultEvent = remotesFolder:FindFirstChild("RevealResult")
    if resultEvent and resultEvent:IsA("RemoteEvent") then
        resultEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("RevealResult RX: " .. dumpVal(args))
        end)
        evCount = evCount + 1
        addLog("Hooked RemoteEvent: RevealResult")
    end

    local stateEvent = remotesFolder:FindFirstChild("StateChanged")
    if stateEvent and stateEvent:IsA("RemoteEvent") then
        stateEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("StateChanged RX: " .. dumpVal(args))
        end)
        evCount = evCount + 1
        addLog("Hooked RemoteEvent: StateChanged")
    end

    local prodEvent = remotesFolder:FindFirstChild("ProductGranted")
    if prodEvent and prodEvent:IsA("RemoteEvent") then
        prodEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            addLog("ProductGranted RX: " .. dumpVal(args))
        end)
        evCount = evCount + 1
        addLog("Hooked RemoteEvent: ProductGranted")
    end

    addLog(string.format("Active hooks established on %d RemoteEvents!", evCount))
end

local isActionHooked = false
local function hookActionRemote()
    if isActionHooked then
        addLog("Action.InvokeServer is already hooked!")
        return
    end
    if not hookfunction then
        addLog("[ERR] hookfunction not supported by executor!")
        return
    end
    local rem = remotesFolder and remotesFolder:FindFirstChild("Action")
    if not rem or not rem:IsA("RemoteFunction") then
        addLog("[ERR] Action RemoteFunction not found!")
        return
    end

    local oldInvoke = nil
    local hookOk, err = pcall(function()
        oldInvoke = hookfunction(rem.InvokeServer, function(self, ...)
            local args = {...}
            addLog("ACTION TX: " .. dumpVal(args))
            local ret = oldInvoke(self, ...)
            addLog("ACTION RX: " .. dumpVal(ret))
            return ret
        end)
    end)

    if hookOk then
        isActionHooked = true
        addLog("HOOK SUCCESS: Action.InvokeServer hooked! Any in-game click will log TX/RX.")
    else
        addLog("HOOK FAILED: " .. tostring(err))
    end
end

local function inspectClientEnv()
    addLog("=== INSPECTING MINESINCREMENTALCLIENT (GETSENV) ===")
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    local clientScript = ps and ps:FindFirstChild("MinesIncrementalClient")
    if not clientScript then
        addLog("[ERR] MinesIncrementalClient script not found!")
        return
    end
    if not getsenv then
        addLog("[ERR] getsenv not supported by executor!")
        return
    end

    local ok, env = pcall(getsenv, clientScript)
    if not ok or type(env) ~= "table" then
        addLog("getsenv error: " .. tostring(env))
        return
    end

    local fnList = {}
    local varList = {}
    for k, v in pairs(env) do
        if type(v) == "function" then
            table.insert(fnList, tostring(k))
        else
            table.insert(varList, string.format("%s (%s = %s)", tostring(k), type(v), dumpVal(v, 1)))
        end
    end

    addLog("Client Functions (" .. #fnList .. "): " .. table.concat(fnList, ", "))
    for _, varInfo in ipairs(varList) do
        addLog("State Var: " .. varInfo)
    end
end

local function inspectBoardGrid()
    addLog("=== INSPECTING IN-GAME 5x5 BOARD TILES ===")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mineGui = pg and pg:FindFirstChild("MineCoreGui")
    local grid = mineGui and mineGui:FindFirstChild("GameShell", true)
    local board = grid and grid:FindFirstChild("Board", true)
    local tileGrid = board and board:FindFirstChild("Grid", true)

    if not tileGrid then
        addLog("[ERR] MineCoreGui.GameShell.Board.Grid not found in PlayerGui!")
        return
    end

    local tilesFound = 0
    for i = 1, 25 do
        local t = tileGrid:FindFirstChild("Tile" .. i)
        if t then
            tilesFound = tilesFound + 1
            local face = t:FindFirstChild("Face")
            local faceText = face and face:IsA("TextButton") and face.Text or "NoFace"
            addLog(string.format("Tile %d: FaceText=%q, Visible=%s", i, faceText, tostring(t.Visible)))
        end
    end
    addLog(string.format("Discovered %d/25 Tiles in Board Grid.", tilesFound))
end

local function inspectConfigModule()
    addLog("=== INSPECTING MINESINCREMENTALCONFIG ===")
    local cfg = ReplicatedStorage:FindFirstChild("MinesIncrementalConfig")
    if not cfg or not cfg:IsA("ModuleScript") then
        addLog("[ERR] ReplicatedStorage.MinesIncrementalConfig not found!")
        return
    end

    local ok, res = pcall(require, cfg)
    if not ok then
        addLog("Require error: " .. tostring(res))
        return
    end

    if type(res) == "table" then
        local keys = {}
        for k, v in pairs(res) do
            table.insert(keys, string.format("%s(%s)", tostring(k), type(v)))
        end
        addLog("Config keys: " .. table.concat(keys, ", "))
    else
        addLog("Config returns: " .. tostring(res))
    end
end

createBtn(ControlsRow, UDim2.new(0, 8, 0, 8), UDim2.new(0.32, -6, 0, 26), "HOOK ACTION REMOTE", true, function() hookActionRemote() end)
createBtn(ControlsRow, UDim2.new(0.33, 4, 0, 8), UDim2.new(0.33, -6, 0, 26), "INSPECT CLIENT (GETSENV)", false, function() inspectClientEnv() end)
createBtn(ControlsRow, UDim2.new(0.66, 6, 0, 8), UDim2.new(0.34, -14, 0, 26), "INSPECT 5x5 BOARD", false, function() inspectBoardGrid() end)

createBtn(ControlsRow, UDim2.new(0, 8, 0, 40), UDim2.new(0.32, -6, 0, 26), "RECONNECT EVENT HOOKS", false, function() hookAllEvents() end)
createBtn(ControlsRow, UDim2.new(0.33, 4, 0, 40), UDim2.new(0.33, -6, 0, 26), "COPY DEBUG LOG", false, function()
    local txt = table.concat(debugLogs, "\n")
    if setclipboard then pcall(setclipboard, txt) end
    addLog("Debug log copied to clipboard!")
end)
createBtn(ControlsRow, UDim2.new(0.66, 6, 0, 40), UDim2.new(0.34, -14, 0, 26), "CLEAR DEBUG LOG", false, function()
    debugLogs = {}
    if logTextBox then logTextBox.Text = "Debug log cleared." end
end)

local LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1, 0, 1, -86)
LogContainer.Position = UDim2.new(0, 0, 0, 86)
LogContainer.BackgroundColor3 = Theme.Header
LogContainer.BorderSizePixel = 0
LogContainer.Parent = Body
Instance.new("UICorner", LogContainer).CornerRadius = UDim.new(0, 6)
local lcStroke = Instance.new("UIStroke", LogContainer)
lcStroke.Color = Theme.Border
lcStroke.Thickness = 1

logTextBox = Instance.new("TextBox")
logTextBox.Size = UDim2.new(1, -16, 1, -16)
logTextBox.Position = UDim2.new(0, 8, 0, 8)
logTextBox.BackgroundTransparency = 1
logTextBox.Text = "NIX Mines Forensic Monitor ready.\nIncoming and outgoing network hooks are active..."
logTextBox.TextColor3 = Theme.TextPrimary
logTextBox.Font = Enum.Font.Code
logTextBox.TextSize = 10
logTextBox.ClearTextOnFocus = false
logTextBox.TextEditable = false
logTextBox.MultiLine = true
logTextBox.TextXAlignment = Enum.TextXAlignment.Left
logTextBox.TextYAlignment = Enum.TextYAlignment.Top
logTextBox.Parent = LogContainer

task.defer(function()
    hookAllEvents()
    hookActionRemote()
end)
