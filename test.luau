local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- roblox methoden cachen
local _pcall = pcall
local _v3 = Vector3.new
local _v3z = Vector3.zero
local _cf = CFrame.new
local _ang = CFrame.Angles
local _rad = math.rad
local _sin = math.sin
local _cos = math.cos
local _clamp = math.clamp
local _rnd = math.random
local _inst = Instance.new


-- wtf waarom is localplayer soms nil
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startT = os.clock()
    while not LocalPlayer and (os.clock() - startT) < 5 do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.1)
    end
end

if not LocalPlayer then
    warn("[Hub] LocalPlayer not found. Must be run as a LocalScript.")
    return
end

-- gui container vinden
local function pakGui()
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
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then return pg end
    local coreGui = nil
    pcall(function() coreGui = game:GetService("CoreGui") end)
    if coreGui then
        local canUseCore = pcall(function()
            local test = Instance.new("ScreenGui")
            test.Parent = coreGui
            test:Destroy()
        end)
        if canUseCore then return coreGui end
    end
    return nil
end

local guiParent = pakGui()
if not guiParent then
    local startP = os.clock()
    while not guiParent and (os.clock() - startP) < 10 do
        guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        task.wait(0.2)
    end
end

if not guiParent then
    warn("[Hub] Could not find a valid GUI parent container.")
    return
end

local Camera = workspace.CurrentCamera
if not Camera then
    local startC = os.clock()
    while not Camera and (os.clock() - startC) < 5 do
        Camera = workspace.CurrentCamera
        task.wait(0.1)
    end
end
if not Camera then
    Camera = workspace:FindFirstChildOfClass("Camera") or workspace:WaitForChild("Camera", 5)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        Camera = workspace.CurrentCamera
    end
end)

do
    if getgenv and getgenv()._HUB_CLEANUP then
        pcall(getgenv()._HUB_CLEANUP)
    end
    -- oude meuk opruimen
local function ruimOudOp(c)
        if c and typeof(c) == "Instance" then
            pcall(function()
                local old = c:FindFirstChild("HubUI")
                if old then old:Destroy() end
            end)
        end
    end
    ruimOudOp(guiParent)
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg and pg ~= guiParent then ruimOudOp(pg) end
    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg and cg ~= guiParent then ruimOudOp(cg) end
    end)
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                for _, n in ipairs({"CharHighlight", "CharTag", "CharHealth", "CharDist", "CamLight"}) do
                    local found = p.Character:FindFirstChild(n, true)
                    if found then found:Destroy() end
                end
            end
        end
    end)
end

-- kleurtjes tabel
local Theme = {
    Background    = Color3.fromRGB(22, 22, 26),
    Header        = Color3.fromRGB(16, 16, 19),
    Sidebar       = Color3.fromRGB(18, 18, 21),
    TabActive     = Color3.fromRGB(38, 38, 46),
    TabActiveText = Color3.fromRGB(240, 240, 245),
    TabInactive   = Color3.fromRGB(18, 18, 21),
    TabInactiveText = Color3.fromRGB(130, 130, 140),
    Accent        = Color3.fromRGB(220, 220, 225),
    AccentDim     = Color3.fromRGB(140, 140, 150),
    ElementBg     = Color3.fromRGB(26, 26, 32),
    ElementHover  = Color3.fromRGB(36, 36, 44),
    ElementActive = Color3.fromRGB(46, 46, 56),
    TextPrimary   = Color3.fromRGB(225, 225, 230),
    TextSecondary = Color3.fromRGB(130, 130, 140),
    Border        = Color3.fromRGB(44, 44, 54),
    BorderBright  = Color3.fromRGB(70, 70, 85),
    Green         = Color3.fromRGB(75, 180, 100),
    Red           = Color3.fromRGB(190, 60, 60),
}

-- tween helper
local function glij(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubUI"
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

-- zwevende tooltip stubs
local function toonTip(tekst) end
local function verbergTip() end

-- melding stub (side popups removed)
local function melding(title, desc, duration, color, onClick) end

-- Venus Library Loader & Initialization
local VenusLib
do
    if Drawing and not Drawing.Fonts then
        Drawing.Fonts = { UI = 0, System = 1, Plex = 2, Monospace = 3 }
    end

    if getgenv and getgenv().VenusLib and typeof(getgenv().VenusLib) == "table" and getgenv().VenusLib.Load then
        VenusLib = getgenv().VenusLib
    end

    if not VenusLib and isfile and readfile then
        local tryPaths = {
            "Venus Lib Source.lua",
            "scripts/Venus Lib Source.lua",
            "scripts\\Venus Lib Source.lua",
            "SirHurt V5/workspace/Venus Lib Source.lua",
            "VenusLib.lua"
        }
        for _, path in ipairs(tryPaths) do
            if isfile(path) then
                local ok, res = pcall(function()
                    return loadstring(readfile(path))()
                end)
                if ok and typeof(res) == "table" and res.Load then
                    VenusLib = res
                    break
                end
            end
        end
    end

    if not VenusLib and loadfile then
        for _, path in ipairs({"Venus Lib Source.lua", "scripts/Venus Lib Source.lua"}) do
            local ok, fn = pcall(loadfile, path)
            if ok and typeof(fn) == "function" then
                local ok2, res = pcall(fn)
                if ok2 and typeof(res) == "table" and res.Load then
                    VenusLib = res
                    break
                end
            end
        end
    end
end

if not VenusLib then
    warn("[AikHub] Venus Lib not found! Ensure 'Venus Lib Source.lua' is present in your workspace or scripts folder.")
    return
end

local Window = VenusLib:Load{
    name = "AikHub",
    sizex = 740,
    sizey = 660,
    theme = "Default",
    folder = "AikHub",
    extension = "cfg"
}

pcall(function()
    VenusLib:Watermark("AikHub | discord.gg/P7fuzYj5xK")
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local FloatToggle = Instance.new("TextButton")
FloatToggle.Name = "ToggleBadge"
FloatToggle.Size = UDim2.new(0, 42, 0, 22)
FloatToggle.Position = UDim2.new(0, 8, 0.5, -11)
FloatToggle.BackgroundColor3 = Theme.Header
FloatToggle.BorderSizePixel = 1
FloatToggle.BorderColor3 = Theme.Border
FloatToggle.Text = "[HUB]"
FloatToggle.TextColor3 = Theme.TextPrimary
FloatToggle.Font = Enum.Font.Gotham
FloatToggle.TextSize = 9
FloatToggle.AutoButtonColor = false
FloatToggle.ZIndex = 150
FloatToggle.Parent = ScreenGui

do
    local ftDragging, ftStart, ftPos = false, nil, nil
    FloatToggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            ftDragging = true
            ftStart = inp.Position
            ftPos = FloatToggle.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then ftDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if ftDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ftStart
            FloatToggle.Position = UDim2.new(ftPos.X.Scale, ftPos.X.Offset + d.X, ftPos.Y.Scale, ftPos.Y.Offset + d.Y)
        end
    end)
    FloatToggle.MouseEnter:Connect(function() FloatToggle.BackgroundColor3 = Theme.ElementHover end)
    FloatToggle.MouseLeave:Connect(function() FloatToggle.BackgroundColor3 = Theme.Header end)
end

local isVisible = true
local function toggleUI()
    if VenusLib and VenusLib.Close then
        VenusLib:Close()
    end
end

FloatToggle.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then
        toggleUI()
    end
end)

local TabMap = {
    ["Combat"] = "Combat",
    ["Physics"] = "Physics",
    ["Teleport"] = "Teleport",
    ["Visuals"] = "Visuals",
    ["Players"] = "Players",
    ["Misc"] = "World",
    ["God & World"] = "World",
    ["Tools"] = "Tools",
    ["Intel"] = "Tools",
    ["Scripts"] = "Tools",
    ["Anims"] = "Tools",
    ["System"] = "Settings",
    ["Settings"] = "Settings",
    ["Credits"] = "Credits",
    ["Favorites"] = "Settings"
}

local CreatedVenusTabs = {}
local function getOrCreateVenusTab(vTabName)
    if not CreatedVenusTabs[vTabName] then
        CreatedVenusTabs[vTabName] = Window:Tab(vTabName)
    end
    return CreatedVenusTabs[vTabName]
end

local TabOrder = {"Combat", "Physics", "Teleport", "Visuals", "Players", "World", "Tools", "Settings", "Credits"}
for _, tName in ipairs(TabOrder) do
    getOrCreateVenusTab(tName)
end

local AllTabs = {}

local function maakTab(name)
    local targetVTabName = TabMap[name] or name
    local vTab = getOrCreateVenusTab(targetVTabName)

    local dummyPage = Instance.new("Frame")
    dummyPage.Name = name .. "Page"
    dummyPage.Size = UDim2.new(0, 0, 0, 0)
    dummyPage.Visible = false
    dummyPage.BackgroundTransparency = 1
    dummyPage.Parent = ScreenGui

    local tabObj = {
        Name = name,
        TargetTabName = targetVTabName,
        VTab = vTab,
        Page = dummyPage,
        CurrentSection = nil,
        CurrentSide = "left",
        LeftCount = 0,
        RightCount = 0
    }

    function tabObj:AddSection(label)
        local side = "left"
        if tabObj.LeftCount > tabObj.RightCount then
            side = "right"
        end
        local sectionTitle = label
        if name ~= targetVTabName and not string.find(string.lower(label), string.lower(name)) then
            sectionTitle = name .. ": " .. label
        end
        local sec = vTab:Section{
            name = sectionTitle,
            side = side
        }
        tabObj.CurrentSection = sec
        tabObj.CurrentSide = side
        return sec
    end

    function tabObj:AddButton(label, cb)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        if tabObj.CurrentSide == "left" then
            tabObj.LeftCount = tabObj.LeftCount + 1
        else
            tabObj.RightCount = tabObj.RightCount + 1
        end
        return tabObj.CurrentSection:Button{
            name = label,
            callback = function()
                if cb then task.spawn(cb) end
            end
        }
    end

    function tabObj:AddToggle(label, default, cb)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        if tabObj.CurrentSide == "left" then
            tabObj.LeftCount = tabObj.LeftCount + 1
        else
            tabObj.RightCount = tabObj.RightCount + 1
        end
        local state = default or false
        local vToggle = tabObj.CurrentSection:Toggle{
            name = label,
            default = state,
            callback = function(val)
                if cb then task.spawn(cb, val) end
            end
        }
        local function setToggle(val)
            if vToggle and vToggle.Toggle then
                vToggle:Toggle(val)
            end
        end
        return setToggle
    end

    function tabObj:AddSlider(label, minV, maxV, defaultV, cb)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        if tabObj.CurrentSide == "left" then
            tabObj.LeftCount = tabObj.LeftCount + 1.4
        else
            tabObj.RightCount = tabObj.RightCount + 1.4
        end
        local val = defaultV or minV
        minV = minV or 0
        maxV = maxV or 100
        return tabObj.CurrentSection:Slider{
            name = label,
            min = minV,
            max = maxV,
            default = val,
            float = 1,
            callback = function(v)
                if cb then task.spawn(cb, v) end
            end
        }
    end

    function tabObj:AddBox(label, default, placeholder, cb)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        if tabObj.CurrentSide == "left" then
            tabObj.LeftCount = tabObj.LeftCount + 1
        else
            tabObj.RightCount = tabObj.RightCount + 1
        end
        return tabObj.CurrentSection:Box{
            name = label,
            default = default or "",
            placeholder = placeholder or "",
            callback = function(str)
                if cb then task.spawn(cb, str) end
            end
        }
    end

    function tabObj:AddLabel(text)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        return tabObj.CurrentSection:Label(text)
    end

    function tabObj:AddDropdown(label, list, default, cb)
        if not tabObj.CurrentSection then
            tabObj:AddSection("Main")
        end
        if tabObj.CurrentSide == "left" then
            tabObj.LeftCount = tabObj.LeftCount + 1.2
        else
            tabObj.RightCount = tabObj.RightCount + 1.2
        end
        return tabObj.CurrentSection:Dropdown{
            name = label,
            content = list or {},
            default = default,
            callback = function(str)
                if cb then task.spawn(cb, str) end
            end
        }
    end

    table.insert(AllTabs, tabObj)
    return tabObj
end

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.new(0, 20, 0, 20)
CrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.Parent = ScreenGui

for _, cfg in ipairs({
    {UDim2.new(0.5, 0, 0, -5), UDim2.new(0, 1, 0, 4)},
    {UDim2.new(0.5, 0, 1, 1), UDim2.new(0, 1, 0, 4)},
    {UDim2.new(0, -5, 0.5, 0), UDim2.new(0, 4, 0, 1)},
    {UDim2.new(1, 1, 0.5, 0), UDim2.new(0, 4, 0, 1)},
}) do
    local line = Instance.new("Frame")
    line.Position = cfg[1]
    line.Size = cfg[2]
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Parent = CrosshairFrame
end

local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 300, 0, 300)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui

local fcStroke = Instance.new("UIStroke")
fcStroke.Color = Color3.fromRGB(255, 255, 255)
fcStroke.Thickness = 1
fcStroke.Transparency = 0.55
fcStroke.Parent = FovCircle

local fcCorner = Instance.new("UICorner")
fcCorner.CornerRadius = UDim.new(1, 0)
fcCorner.Parent = FovCircle

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 130, 0, 36)
FpsLabel.Position = UDim2.new(0, 10, 0, 10)
FpsLabel.BackgroundColor3 = Theme.Header
FpsLabel.BackgroundTransparency = 0.3
FpsLabel.TextColor3 = Theme.TextPrimary
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 10
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.BorderSizePixel = 1
FpsLabel.BorderColor3 = Theme.Border
FpsLabel.Visible = false
FpsLabel.Parent = ScreenGui

local fpsPad = Instance.new("UIPadding")
fpsPad.PaddingLeft = UDim.new(0, 6)
fpsPad.Parent = FpsLabel

local fpsConn = nil
function setFPSHud(enabled)
    FpsLabel.Visible = enabled
    fpsConn = veiligOntkoppelen(fpsConn)
    if enabled then
        local last = os.clock()
        local frames = 0
        fpsConn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = os.clock()
            if now - last >= 0.5 then
                local fps = math.floor(frames / (now - last))
                frames = 0
                last = now
                local root = pakBasis()
                local spd = root and math.floor(root.AssemblyLinearVelocity.Magnitude) or 0
                FpsLabel.Text = string.format("FPS: %d\nSPD: %d studs/s", fps, spd)
            end
        end)
    end
end

local HoverHud = Instance.new("TextLabel")
HoverHud.Size = UDim2.new(0, 260, 0, 22)
HoverHud.AnchorPoint = Vector2.new(0.5, 1)
HoverHud.Position = UDim2.new(0.5, 0, 1, -16)
HoverHud.BackgroundColor3 = Theme.Header
HoverHud.BackgroundTransparency = 0.25
HoverHud.TextColor3 = Theme.TextPrimary
HoverHud.Font = Enum.Font.Gotham
HoverHud.TextSize = 10
HoverHud.BorderSizePixel = 1
HoverHud.BorderColor3 = Theme.Border
HoverHud.Visible = false
HoverHud.Parent = ScreenGui

local savedWaypoints = {}

local function veiligOntkoppelen(c)
    if c then c:Disconnect() end
    return nil
end

-- karakter helpers
local function pakKarakter() return LocalPlayer.Character end
local function pakBasis()
    local c = pakKarakter()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function pakMens()
    local c = pakKarakter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- muis positie raycasten en tp
local function teleporteerMuis()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    local char = pakKarakter()
    if char then
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
    end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if result then
        local root = pakBasis()
        if root then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3.5, 0))
            melding("Teleport", "Moved to cursor position", 1.5, Theme.AccentDim)
        end
    end
end

local cyclePlayerIndex = 1

local function getOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    return list
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = pakBasis()
    if targetRoot and myRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
        melding("Teleport", "Teleported to " .. targetPlayer.Name, 1.8, Theme.Green)
    end
end

local function teleporteerDichtste()
    local myRoot = pakBasis()
    if not myRoot then return end
    local nearest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d = (myRoot.Position - tr.Position).Magnitude
                if d < shortest then
                    shortest = d
                    nearest = p
                end
            end
        end
    end
    if nearest then
        teleportToPlayer(nearest)
    else
        melding("Teleport", "No other players found", 1.8, Theme.Red)
    end
end

local function teleporteerWillekeurig()
    local others = getOtherPlayers()
    if #others > 0 then
        local p = others[math.random(1, #others)]
        teleportToPlayer(p)
    else
        melding("Teleport", "No other players found", 1.8, Theme.Red)
    end
end

local function volgendeSpelerTeleport()
    local others = getOtherPlayers()
    if #others == 0 then
        melding("Teleport", "No other players found", 1.8, Theme.Red)
        return
    end
    if cyclePlayerIndex > #others then cyclePlayerIndex = 1 end
    local target = others[cyclePlayerIndex]
    cyclePlayerIndex = cyclePlayerIndex + 1
    if target then teleportToPlayer(target) end
end


local keysDown = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

UserInputService.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = true
    end
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift or inp.KeyCode == Enum.KeyCode.RightControl or inp.KeyCode == Enum.KeyCode.Insert then
        zetZichtbaar(not isVisible)
    end
    if inp.KeyCode == Enum.KeyCode.W then keysDown.W = true end
    if inp.KeyCode == Enum.KeyCode.A then keysDown.A = true end
    if inp.KeyCode == Enum.KeyCode.S then keysDown.S = true end
    if inp.KeyCode == Enum.KeyCode.D then keysDown.D = true end
    if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = true end
    if inp.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = true end
    if inp.KeyCode == Enum.KeyCode.T then teleporteerMuis() end
end)

UserInputService.WindowFocusReleased:Connect(function()
    rmbHeld = false
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = false
    end
    if inp.KeyCode == Enum.KeyCode.W then keysDown.W = false end
    if inp.KeyCode == Enum.KeyCode.A then keysDown.A = false end
    if inp.KeyCode == Enum.KeyCode.S then keysDown.S = false end
    if inp.KeyCode == Enum.KeyCode.D then keysDown.D = false end
    if inp.KeyCode == Enum.KeyCode.Space then keysDown.Space = false end
    if inp.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = false end
end)

local function forAllCharacters(onCharAdded, onCharRemoved)
    local connections = {}
    local trackedNpcs = {}

    local function setupPlayer(player)
        if player == LocalPlayer then return end
        local pConns = {}

        local function onAdded(char)
            task.spawn(function()
                char:WaitForChild("HumanoidRootPart", 5)
                onCharAdded(player, char)
            end)
        end

        local function onRemoving(char)
            onCharRemoved(player, char)
        end

        pConns.added = player.CharacterAdded:Connect(onAdded)
        pConns.removing = player.CharacterRemoving:Connect(onRemoving)
        if player.Character then onAdded(player.Character) end
        connections[player] = pConns
    end

    local function cleanupPlayer(player)
        local pConns = connections[player]
        if pConns then
            if pConns.added then pConns.added:Disconnect() end
            if pConns.removing then pConns.removing:Disconnect() end
            connections[player] = nil
        end
        if player.Character then onCharRemoved(player, player.Character) end
    end

    for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
    local addedConn = Players.PlayerAdded:Connect(setupPlayer)
    local removingConn = Players.PlayerRemoving:Connect(cleanupPlayer)

    local myChar = pakKarakter()
    local function checkAndTrackModel(model)
        if not model:IsA("Model") or model == myChar or Players:GetPlayerFromCharacter(model) then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hv = model:FindFirstChild("Health") or model:FindFirstChild("HP") or model:GetAttribute("Health")
        if (hum and hum.Health > 0) or (hv and (typeof(hv) == "number" and hv > 0 or (typeof(hv) == "Instance" and hv:IsA("ValueBase") and hv.Value > 0))) then
            if not trackedNpcs[model] then
                trackedNpcs[model] = true
                task.spawn(function()
                    onCharAdded(nil, model)
                end)
                local ancConn
                ancConn = model.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        if ancConn then ancConn:Disconnect() end
                        trackedNpcs[model] = nil
                        onCharRemoved(nil, model)
                    end
                end)
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            checkAndTrackModel(obj)
        end
    end

    local descendantConn = workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") then
            task.delay(0.2, function() checkAndTrackModel(desc) end)
        elseif desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") then
            task.delay(0.2, function() checkAndTrackModel(desc.Parent) end)
        end
    end)

    return function()
        addedConn:Disconnect()
        removingConn:Disconnect()
        if descendantConn then descendantConn:Disconnect() end
        for player in pairs(connections) do cleanupPlayer(player) end
        for model in pairs(trackedNpcs) do
            onCharRemoved(nil, model)
        end
        connections = {}
        trackedNpcs = {}
    end
end

local fireRecoil, setRecoil, spawnBulletTracer, setAimAssist, setAutoShot
local aimSnap, wallCheck, teamCheck, aimRange, glideSpeed, autoShotDelay, recoilIntensity, aimLeadEnabled, aimLeadFactor, aimNoiseEnabled, aimNoiseIntensity, aimPriority, aimBone
local setHitboxExpander, setNoclip, setAirWalk, setGhostMode
ghostModeEnabled = false
hitboxDisplaceEnabled = false
inspectorConn = nil
local hitboxSize, updateHitboxSizes, flightSpeed, cameraShakeIntensity
local setFlashlight, updateFlashlight, setEntityRadar, setClearVision
local setTouchShield, setAntiFall, setDeathShield, setGodmode, setSpeedBoost
local setInstantPrompts, setInfZoom, setHitboxDisplace, setUnlockFirstPerson
local setAutoClearAttributes, clearRestrictions, toggleAllScripts
local customWalkSpeed, flashlightBrightness, flashlightRange, hitboxDisplaceDist
local setHighlights, setFullbright, setNightVision, setDayCycle, setCameraShake
local setHeadbob, setSpeedlines, setNameTags, setHealthBars, setDistanceTags
local setFlight, setInfJump, setFPSHud, applyAnimPack

local flashlightLight = nil
local flashlightEnabled = false
flashlightBrightness = 2.5
flashlightRange = 60

function updateFlashlight()
    if flashlightLight and flashlightLight.Parent then
        flashlightLight.Brightness = flashlightBrightness
        flashlightLight.Range = flashlightRange
    end
end

function zetZaklamp(enabled)
    flashlightEnabled = enabled
    if flashlightLight then flashlightLight:Destroy(); flashlightLight = nil end
    if not enabled then return end
    local char = pakKarakter()
    local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if head then
        local old = head:FindFirstChild("CamLight")
        if old then old:Destroy() end
        flashlightLight = Instance.new("SpotLight")
        flashlightLight.Name = "CamLight"
        flashlightLight.Angle = 65
        flashlightLight.Brightness = flashlightBrightness
        flashlightLight.Range = flashlightRange
        flashlightLight.Face = Enum.NormalId.Front
        flashlightLight.Shadows = true
        flashlightLight.Parent = head
    end
end

do
local recoilEnabled = false
recoilIntensity = 5
local recoilConn = nil
local targetRecoil = Vector3.zero
local currentRecoil = Vector3.zero

function schietTerugslag()
    if not recoilEnabled then return end
    targetRecoil = Vector3.new(
        recoilIntensity * (0.5 + math.random() * 0.5),
        (math.random() - 0.5) * recoilIntensity * 0.4,
        0
    )
end

function zetTerugslag(enabled)
    recoilEnabled = enabled
    recoilConn = veiligOntkoppelen(recoilConn)
    if enabled then
        recoilConn = RunService.RenderStepped:Connect(function(dt)
            currentRecoil = currentRecoil:Lerp(targetRecoil, math.min(dt * 18, 1))
            targetRecoil = targetRecoil:Lerp(Vector3.zero, math.min(dt * 10, 1))
            if currentRecoil.Magnitude > 0.001 then
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(currentRecoil.X), math.rad(currentRecoil.Y), 0)
            end
        end)
    end
end

function maakKogelSpoor()
    local mp = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
    local params = RaycastParams.new()
    local char = pakKarakter()
    if char then
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
    end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    local origin = ray.Origin
    local endPos = result and result.Position or (ray.Origin + ray.Direction * 500)

    local function makeAnchor(pos)
        local p = Instance.new("Part")
        p.Size = Vector3.one * 0.01
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = false
        p.Position = pos
        p.Parent = workspace
        local a = Instance.new("Attachment", p)
        return p, a
    end

    local p1, a1 = makeAnchor(origin)
    local p2, a2 = makeAnchor(endPos)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a1
    beam.Attachment1 = a2
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    beam.Width0 = 0.12
    beam.Width1 = 0.04
    beam.FaceCamera = true
    beam.LightEmission = 0.8
    beam.LightInfluence = 0.2
    beam.Parent = p1

    if result then
        local impact = Instance.new("Part")
        impact.Size = Vector3.one * 0.3
        impact.Transparency = 1
        impact.Anchored = true
        impact.CanCollide = false
        impact.CFrame = CFrame.new(result.Position, result.Position + result.Normal)
        impact.Parent = workspace

        local ring = Instance.new("ParticleEmitter")
        ring.Rate = 0
        ring.SpreadAngle = Vector2.new(60, 60)
        ring.Speed = NumberRange.new(2, 5)
        ring.Lifetime = NumberRange.new(0.05, 0.15)
        ring.Size = NumberSequence.new(0.15, 0)
        ring.Color = ColorSequence.new(Color3.fromRGB(255, 240, 200))
        ring.LightEmission = 1
        ring.Parent = impact
        ring:Emit(8)
        task.delay(0.2, function() impact:Destroy() end)
    end

    glij(beam, {Width0 = 0, Width1 = 0}, 0.18).Completed:Connect(function()
        p1:Destroy()
        p2:Destroy()
    end)
end

end

do
local aimEnabled = false
aimRange = 300
aimSnap = false
glideSpeed = 0.12
wallCheck = false
teamCheck = false
local aimConn = nil
local rmbHeld = false
local lockedTarget = nil

local autoShotEnabled = false
autoShotDelay = 0.14
local autoShotConn = nil
local lastAutoShot = 0
local wasOnTarget = false
local function isRmbHeld()
    if rmbHeld then return true end
    local ok, down = pcall(function()
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end)
    return ok and down or false
end

local function getTargetPart(character)
    if not character then return nil end
    local head = character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    local ut = character:FindFirstChild("UpperTorso")
    if ut and ut:IsA("BasePart") then return ut end
    local t = character:FindFirstChild("Torso")
    if t and t:IsA("BasePart") then return t end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    local hb = character:FindFirstChild("Hitbox") or character:FindFirstChild("HitBox")
    if hb and hb:IsA("BasePart") then return hb end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") and child.Transparency < 0.95 then
            return child
        end
    end
    return head or ut or t or hrp
end

-- muur check raycast
local function heeftZichtlijn(origin, targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    local filter = {}
    local char = pakKarakter()
    if char then table.insert(filter, char) end
    if Camera then table.insert(filter, Camera) end
    if workspace.CurrentCamera then table.insert(filter, workspace.CurrentCamera) end
    table.insert(filter, targetPart.Parent)
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    params.RespectCanCollide = true
    return workspace:Raycast(origin, dir, params) == nil
end

local targetNpcs = true
function setTargetNpcs(enabled) targetNpcs = enabled; melding("Aim Assist", enabled and "Target NPCs ON" or "Target NPCs OFF", 1.5) end

-- doelwit zoeken in fov
local function vindDichtsteVijand()
    local nearest = nil
    local shortest = aimRange
    local cam = Camera or workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local myChar = pakKarakter()

    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team) then
                table.insert(candidates, p.Character)
            end
        end
    end

    if targetNpcs or #candidates == 0 then
        local function scanEntity(child)
            if not child:IsA("Model") or child == myChar or Players:GetPlayerFromCharacter(child) then return end
            local hum = child:FindFirstChildOfClass("Humanoid")
            local hv = child:FindFirstChild("Health") or child:FindFirstChild("HP") or child:GetAttribute("Health") or child:GetAttribute("HP")
            local hasHp = (hum and hum.Health > 0) or false
            if not hasHp and hv then
                local val = typeof(hv) == "number" and hv or (typeof(hv) == "Instance" and hv:IsA("ValueBase") and tonumber(hv.Value))
                if val and val > 0 then hasHp = true end
            end
            if not hasHp then
                local cName = string.lower(child.Name)
                if string.find(cName, "npc") or string.find(cName, "enem") or string.find(cName, "zomb") or string.find(cName, "bot") or string.find(cName, "monster") or string.find(cName, "dummy") then
                    hasHp = true
                end
            end
            if hasHp and (child:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Torso") or child:FindFirstChild("UpperTorso")) then
                table.insert(candidates, child)
            end
        end

        for _, child in ipairs(workspace:GetChildren()) do
            scanEntity(child)
            if child:IsA("Folder") then
                local fName = string.lower(child.Name)
                if string.find(fName, "npc") or string.find(fName, "enem") or string.find(fName, "zomb") or string.find(fName, "mob") or string.find(fName, "monster") or string.find(fName, "character") then
                    for _, sub in ipairs(child:GetChildren()) do
                        scanEntity(sub)
                    end
                end
            end
        end
    end

    for _, char in ipairs(candidates) do
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hv = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:GetAttribute("Health") or char:GetAttribute("HP")
        local isAlive = (hum and hum.Health > 0) or false
        if not isAlive and hv then
            local val = typeof(hv) == "number" and hv or (typeof(hv) == "Instance" and hv:IsA("ValueBase") and tonumber(hv.Value))
            if val and val > 0 then isAlive = true end
        end
        if not isAlive and (hum == nil and hv == nil) then
            isAlive = true
        end

        if isAlive then
            local part = getTargetPart(char)
            if part then
                local canTarget = not wallCheck or wallbangEnabled or heeftZichtlijn(camPos, part)
                if canTarget then
                    local sp, vis = cam:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d <= aimRange then
                            local score = d
                            if aimPriority == "Distance" then
                                score = (camPos - part.Position).Magnitude
                            elseif aimPriority == "LowestHP" and hum then
                                score = hum.Health
                            end

                            if score < shortest then
                                shortest = score
                                nearest = part
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

    local lastSeenTargetTime = 0
    local targetStickinessGrace = 0.35
    local stickyLock = true

    function setStickyLock(enabled)
        stickyLock = enabled
        melding("Aim Assist", enabled and "Sticky Lock ON (Holds Target)" or "Sticky Lock OFF", 1.5)
    end

    local function isTargetValid(part)
        if not part or not part.Parent then return false end
        local hum = part.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        local camPos = Camera.CFrame.Position
        local dist = (camPos - part.Position).Magnitude
        if dist > 450 then return false end

        if wallCheck then
            if heeftZichtlijn(camPos, part) then
                lastSeenTargetTime = os.clock()
            else
                if (os.clock() - lastSeenTargetTime) > targetStickinessGrace then
                    return false
                end
            end
        else
            lastSeenTargetTime = os.clock()
        end

        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen and (os.clock() - lastSeenTargetTime) > targetStickinessGrace then
            return false
        end

        if not stickyLock then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if d > (aimRange * 1.5) then return false end
        end

        return true
    end

    function setAimLead(enabled) aimLeadEnabled = enabled end
    function setAimLeadFactor(val) aimLeadFactor = val end

    function zetDoelHulp(enabled)
    aimEnabled = enabled
    pcall(function()
        RunService:UnbindFromRenderStep("CamAimAssist")
    end)
    aimConn = veiligOntkoppelen(aimConn)
    lockedTarget = nil
    if fcStroke then fcStroke.Color = Theme.Accent end

    if enabled then
        RunService:BindToRenderStep("CamAimAssist", Enum.RenderPriority.Camera.Value + 1, function()
            if not isRmbHeld() then
                if lockedTarget then
                    lockedTarget = nil
                    if fcStroke then fcStroke.Color = Theme.Accent end
                end
                return
            end

            if not isTargetValid(lockedTarget) then
                lockedTarget = vindDichtsteVijand()
            end

            if not lockedTarget then
                if fcStroke then fcStroke.Color = Theme.Accent end
                return
            end

            if fcStroke then fcStroke.Color = Theme.Green end

            local tp = lockedTarget.Position
            local camPos = Camera.CFrame.Position
            if aimLeadEnabled then
                local vel = lockedTarget.AssemblyLinearVelocity or Vector3.zero
                local dist = (lockedTarget.Position - camPos).Magnitude
                local leadTime = math.clamp(dist / 600, 0.02, 0.35) * (aimLeadFactor / 0.12)
                tp = tp + (vel * leadTime)
            end
            if aimNoiseEnabled then
                local t = os.clock() * 7.5
                local jx = (math.noise(t, 12.34) or 0) * (aimNoiseIntensity or 1) * 0.45
                local jy = (math.noise(t, 56.78) or 0) * (aimNoiseIntensity or 1) * 0.45
                tp = tp + Vector3.new(jx, jy, 0)
            end
            if (tp - camPos).Magnitude < 0.1 then return end
            local targetRot = CFrame.lookAt(camPos, tp)

            if aimSnap then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position) * targetRot.Rotation
            else
                local factor = 1 - (1 - math.clamp(glideSpeed, 0.04, 0.6)) ^ 3
                Camera.CFrame = CFrame.new(Camera.CFrame.Position) * Camera.CFrame.Rotation:Lerp(targetRot.Rotation, factor)
            end
        end)
    end
end

local function getEnemyFromPart(part)
    if not part then return nil end
    local cur = part
    while cur and cur ~= workspace do
        if cur:IsA("Model") then
            local p = Players:GetPlayerFromCharacter(cur)
            if p and p ~= LocalPlayer then
                if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then return nil end
                local hum = cur:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then return cur end
            end
            local hum = cur:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and cur ~= pakKarakter() then
                return cur
            end
        end
        cur = cur.Parent
    end
    return nil
end

end

do
local function castRayAt(screenPoint)
    local ray = Camera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
    local params = RaycastParams.new()
    local char = pakKarakter()
    local filter = {}
    if char then table.insert(filter, char) end
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if res and res.Instance then
        return getEnemyFromPart(res.Instance)
    end
    return nil
end

local function isCursorOnTarget()
    local mp = UserInputService:GetMouseLocation()
    local hit = castRayAt(mp)
    if hit then return hit end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    hit = castRayAt(center)
    if hit then return hit end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not teamCheck or not LocalPlayer.Team or p.Team ~= LocalPlayer.Team then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = getTargetPart(p.Character)
                    if part then
                        local sp, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis then
                            local sp2 = Vector2.new(sp.X, sp.Y)
                            local d1 = (sp2 - mp).Magnitude
                            local d2 = (sp2 - center).Magnitude
                            if (d1 < 26 or d2 < 26) and heeftZichtlijn(Camera.CFrame.Position, part) then
                                return p.Character
                            end
                        end
                    end
                end
            end
        end
    end

    if lockedTarget and isTargetValid(lockedTarget) then
        local sp, vis = Camera:WorldToViewportPoint(lockedTarget.Position)
        if vis then
            local sp2 = Vector2.new(sp.X, sp.Y)
            if (sp2 - mp).Magnitude < 32 or (sp2 - center).Magnitude < 32 then
                return lockedTarget.Parent
            end
        end
    end

    return nil
end

local function triggerFire()
    maakKogelSpoor()
    schietTerugslag()

    local char = pakKarakter()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end

    local mp = UserInputService:GetMouseLocation()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(mp.X, mp.Y, 0, true, game, 0)
        task.defer(function()
            pcall(function() vim:SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 0) end)
        end)
    end)
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton1(Vector2.zero)
    end)
end

function setAutoShot(enabled)
    autoShotEnabled = enabled
    autoShotConn = veiligOntkoppelen(autoShotConn)
    wasOnTarget = false
    if enabled then
        autoShotConn = RunService.RenderStepped:Connect(function()
            local target = isCursorOnTarget()
            if target then
                local now = os.clock()
                if autoShotDelay <= 0.005 or not wasOnTarget or (now - lastAutoShot >= autoShotDelay) then
                    lastAutoShot = now
                    wasOnTarget = true
                    triggerFire()
                end
            else
                wasOnTarget = false
            end
        end)
    end
end
end

do
local hitboxExpanderEnabled = false
hitboxSize = 12
local hitboxOriginals = {}
local hitboxCleanup = nil
local hitboxLoopConn = nil

local KEY_HIT_PARTS = {
    "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"
}

local function isLocalOrViewmodel(model)
    if not model then return true end
    local myChar = pakKarakter()
    if myChar and (model == myChar or model:IsDescendantOf(myChar)) then return true end
    if LocalPlayer.Character and (model == LocalPlayer.Character or model:IsDescendantOf(LocalPlayer.Character)) then return true end
    if model.Name == LocalPlayer.Name then return true end
    if Camera and (model == Camera or model:IsDescendantOf(Camera)) then return true end
    if workspace.CurrentCamera and (model == workspace.CurrentCamera or model:IsDescendantOf(workspace.CurrentCamera)) then return true end
    local mName = string.lower(model.Name)
    if mName:find("view") or mName:find("arm") or mName:find("fps") or mName:find("weapon") or mName:find("gun") then
        return true
    end
    return false
end

local function applyHitboxToPart(part)
    if not part or not part:IsA("BasePart") then return end
    if isLocalOrViewmodel(part.Parent) then return end
    if not hitboxOriginals[part] then
        hitboxOriginals[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            Material = part.Material,
            CanCollide = part.CanCollide,
            CanQuery = part.CanQuery,
            CanTouch = part.CanTouch,
            Massless = part.Massless,
            Color = part.Color
        }
    end
    part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    part.Transparency = 0.65
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(240, 60, 60)
    part.CanCollide = false
    part.CanQuery = true
    part.CanTouch = true
    part.Massless = true
end

local function applyHitbox(player, char)
    if not char or isLocalOrViewmodel(char) then return end
    if player and player == LocalPlayer then return end
    if teamCheck and LocalPlayer.Team and player and player.Team == LocalPlayer.Team then return end

    for _, partName in ipairs(KEY_HIT_PARTS) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            applyHitboxToPart(part)
        end
    end

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") then
            local cName = string.lower(child.Name)
            if cName:find("hitbox") or cName:find("hit") or cName:find("box") or cName:find("collider") then
                applyHitboxToPart(child)
            end
        end
    end
end

local function revertHitbox(player, char)
    if not char then return end
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("BasePart") and hitboxOriginals[child] then
            local orig = hitboxOriginals[child]
            pcall(function()
                child.Size = orig.Size
                child.Transparency = orig.Transparency
                child.Material = orig.Material
                child.CanCollide = orig.CanCollide
                child.CanQuery = orig.CanQuery
                child.CanTouch = orig.CanTouch
                child.Massless = orig.Massless
                child.Color = orig.Color
            end)
            hitboxOriginals[child] = nil
        end
    end
end

function updateHitboxSizes()
    if not hitboxExpanderEnabled then return end
    for part, _ in pairs(hitboxOriginals) do
        if part and part.Parent and part:IsA("BasePart") then
            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        end
    end
end

function setHitboxExpander(enabled)
    hitboxExpanderEnabled = enabled
    if hitboxCleanup then hitboxCleanup(); hitboxCleanup = nil end
    hitboxLoopConn = veiligOntkoppelen(hitboxLoopConn)

    if enabled then
        hitboxCleanup = forAllCharacters(applyHitbox, revertHitbox)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                applyHitbox(p, p.Character)
            end
        end

        local lastScan = 0
        hitboxLoopConn = RunService.Heartbeat:Connect(function()
            if not hitboxExpanderEnabled then return end
            local now = os.clock()
            if now - lastScan < 0.4 then return end
            lastScan = now

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    applyHitbox(p, p.Character)
                end
            end

            for _, folderName in ipairs({"Characters", "Players", "Entities", "Bots", "NPCs"}) do
                local f = workspace:FindFirstChild(folderName)
                if f and f:IsA("Folder") then
                    for _, c in ipairs(f:GetChildren()) do
                        if c:IsA("Model") and not isLocalOrViewmodel(c) and (c:FindFirstChildOfClass("Humanoid") or c:FindFirstChild("HumanoidRootPart")) then
                            applyHitbox(nil, c)
                        end
                    end
                end
            end
        end)
    else
        for part, orig in pairs(hitboxOriginals) do
            if part and part.Parent and part:IsA("BasePart") then
                pcall(function()
                    part.Size = orig.Size
                    part.Transparency = orig.Transparency
                    part.Material = orig.Material
                    part.CanCollide = orig.CanCollide
                    part.CanQuery = orig.CanQuery
                    part.CanTouch = orig.CanTouch
                    part.Massless = orig.Massless
                    part.Color = orig.Color
                end)
            end
        end
        hitboxOriginals = {}
    end
end

local noclipEnabled = false
local noclipConn = nil

function zetDoorMuren(enabled)
    noclipEnabled = enabled
    noclipConn = veiligOntkoppelen(noclipConn)
    if enabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = pakKarakter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local airWalkEnabled = false
local airWalkPart = nil
local airWalkConn = nil
local airWalkY = 0

function zetLuchtLopen(enabled)
    airWalkEnabled = enabled
    airWalkConn = veiligOntkoppelen(airWalkConn)
    if airWalkPart then airWalkPart:Destroy() airWalkPart = nil end

    if enabled then
        local root = pakBasis()
        airWalkY = root and (root.Position.Y - 3.2) or 0

        airWalkPart = Instance.new("Part")
        airWalkPart.Name = "AirFloor"
        airWalkPart.Size = Vector3.new(7, 1, 7)
        airWalkPart.Transparency = 0.65
        airWalkPart.Material = Enum.Material.Neon
        airWalkPart.Color = Color3.fromRGB(160, 220, 255)
        airWalkPart.Anchored = true
        airWalkPart.CanCollide = true
        airWalkPart.Parent = workspace

        local pCorner = Instance.new("CylinderMesh")
        pCorner.Scale = Vector3.new(1, 0.4, 1)
        pCorner.Parent = airWalkPart

        airWalkConn = RunService.Heartbeat:Connect(function(dt)
            local myRoot = pakBasis()
            if not myRoot or not airWalkPart then return end

            if keysDown.Space then
                airWalkY = airWalkY + dt * 18
            elseif keysDown.LeftShift then
                airWalkY = airWalkY - dt * 18
            end

            airWalkPart.Position = Vector3.new(myRoot.Position.X, airWalkY, myRoot.Position.Z)
        end)
    end
end

local ghostModeEnabled = false
local ghostOriginals = {}

function setGhostMode(enabled)
    ghostModeEnabled = enabled
    local char = pakKarakter()
    if not char then return end

    if enabled then
        for _, d in ipairs(char:GetDescendants()) do
            if (d:IsA("BasePart") or d:IsA("Decal")) and d.Name ~= "HumanoidRootPart" then
                if ghostOriginals[d] == nil then
                    ghostOriginals[d] = d.Transparency
                end
                d.Transparency = 0.72
            end
        end
    else
        for d, orig in pairs(ghostOriginals) do
            if d and d.Parent then
                d.Transparency = orig
            end
        end
        ghostOriginals = {}
    end
end

end



do
    local chatSpyEnabled = false
    local chatSpyConns = {}
    local recentChats = {}

    local chatLogFrame = Instance.new("Frame")
    chatLogFrame.Name = "ChatSpyFrame"
    chatLogFrame.Size = UDim2.new(0, 320, 0, 190)
    chatLogFrame.Position = UDim2.new(0, 16, 1, -210)
    chatLogFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
    chatLogFrame.BorderSizePixel = 0
    chatLogFrame.ZIndex = 120
    chatLogFrame.Visible = false
    chatLogFrame.Parent = ScreenGui

    chatLogFrame.BorderSizePixel = 1
    chatLogFrame.BorderColor3 = Theme.Border

    local clfTopBar = Instance.new("Frame")
    clfTopBar.Name = "TopBar"
    clfTopBar.Size = UDim2.new(1, 0, 0, 26)
    clfTopBar.BackgroundColor3 = Theme.Header
    clfTopBar.BorderSizePixel = 0
    clfTopBar.Parent = chatLogFrame

    clfTopBar.BorderSizePixel = 0

    local clTitle = Instance.new("TextLabel")
    clTitle.Size = UDim2.new(1, -70, 1, 0)
    clTitle.Position = UDim2.new(0, 8, 0, 0)
    clTitle.BackgroundTransparency = 1
    clTitle.Text = "CHAT SPY LOG (0)"
    clTitle.TextColor3 = Theme.Accent
    clTitle.Font = Enum.Font.Gotham
    clTitle.TextSize = 10
    clTitle.TextXAlignment = Enum.TextXAlignment.Left
    clTitle.Parent = clfTopBar

    local clClearBtn = Instance.new("TextButton")
    clClearBtn.Size = UDim2.new(0, 36, 0, 18)
    clClearBtn.Position = UDim2.new(1, -62, 0.5, -9)
    clClearBtn.BackgroundColor3 = Theme.ElementBg
    clClearBtn.Text = "Clear"
    clClearBtn.TextColor3 = Theme.TextSecondary
    clClearBtn.Font = Enum.Font.Gotham
    clClearBtn.TextSize = 9
    clClearBtn.BorderSizePixel = 0
    clClearBtn.Parent = clfTopBar

    clClearBtn.BorderSizePixel = 1
    clClearBtn.BorderColor3 = Theme.Border

    local clCloseBtn = Instance.new("TextButton")
    clCloseBtn.Size = UDim2.new(0, 20, 0, 18)
    clCloseBtn.Position = UDim2.new(1, -24, 0.5, -9)
    clCloseBtn.BackgroundColor3 = Theme.ElementBg
    clCloseBtn.Text = "x"
    clCloseBtn.TextColor3 = Theme.TextSecondary
    clCloseBtn.Font = Enum.Font.Gotham
    clCloseBtn.TextSize = 10
    clCloseBtn.BorderSizePixel = 0
    clCloseBtn.Parent = clfTopBar

    clCloseBtn.BorderSizePixel = 1
    clCloseBtn.BorderColor3 = Theme.Border

    clCloseBtn.MouseButton1Click:Connect(function() chatLogFrame.Visible = false end)

    local clScroll = Instance.new("ScrollingFrame")
    clScroll.Size = UDim2.new(1, -12, 1, -34)
    clScroll.Position = UDim2.new(0, 6, 0, 29)
    clScroll.BackgroundTransparency = 1
    clScroll.BorderSizePixel = 0
    clScroll.ScrollBarThickness = 2
    clScroll.ScrollBarImageColor3 = Theme.BorderBright
    clScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    clScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    clScroll.Parent = chatLogFrame

    local clLayout = Instance.new("UIListLayout")
    clLayout.SortOrder = Enum.SortOrder.LayoutOrder
    clLayout.Padding = UDim.new(0, 3)
    clLayout.Parent = clScroll

    local clDrag, clDragInp, clMousePos, clFramePos = false, nil, nil, nil
    clfTopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            clDrag = true
            clMousePos = inp.Position
            clFramePos = chatLogFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then clDrag = false end
    end)
    clfTopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then clDragInp = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == clDragInp and clDrag then
            local d = inp.Position - clMousePos
            chatLogFrame.Position = UDim2.new(clFramePos.X.Scale, clFramePos.X.Offset + d.X, clFramePos.Y.Scale, clFramePos.Y.Offset + d.Y)
        end
    end)

    local function addChatLogEntry(senderName, msg)
        local timeStr = os.date("%X")
        local entryText = string.format("[%s] [%s]: %s", timeStr, senderName, msg)
        table.insert(recentChats, entryText)

        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, 0, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.BackgroundTransparency = 1
        row.Text = entryText
        row.TextColor3 = Color3.fromRGB(230, 230, 240)
        row.Font = Enum.Font.Gotham
        row.TextSize = 10
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextWrapped = true
        row.LayoutOrder = #recentChats
        row.Parent = clScroll

        clTitle.Text = string.format("CHAT SPY LOG (%d)", #recentChats)
        clScroll.CanvasPosition = Vector2.new(0, 99999)
    end

    clClearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(clScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        recentChats = {}
        clTitle.Text = "CHAT SPY LOG (0)"
        melding("ChatSpy", "Chat logs cleared", 1.5)
    end)

    local function onPlayerChat(player, msg)
        if not chatSpyEnabled or player == LocalPlayer then return end
        addChatLogEntry(player.Name, msg)

        pcall(function()
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = string.format("[SPY] [%s]: %s", player.Name, msg),
                Color = Color3.fromRGB(255, 220, 90),
                Font = Enum.Font.Gotham,
                FontSize = Enum.FontSize.Size14
            })
        end)
    end

    local function hookPlayer(p)
        if p == LocalPlayer then return end
        local c = p.Chatted:Connect(function(msg) onPlayerChat(p, msg) end)
        chatSpyConns[p] = c
    end

    function zetChatSpion(enabled)
        chatSpyEnabled = enabled
        for _, c in pairs(chatSpyConns) do veiligOntkoppelen(c) end
        chatSpyConns = {}
        if enabled then
            chatLogFrame.Visible = true
            for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
            chatSpyConns.added = Players.PlayerAdded:Connect(hookPlayer)
            chatSpyConns.removed = Players.PlayerRemoving:Connect(function(p)
                if chatSpyConns[p] then veiligOntkoppelen(chatSpyConns[p]); chatSpyConns[p] = nil end
            end)

            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                chatSpyConns.tcs = TextChatService.MessageReceived:Connect(function(tcm)
                    local src = tcm.TextSource
                    local p = src and Players:GetPlayerByUserId(src.UserId)
                    if p and p ~= LocalPlayer and tcm.Text then
                        onPlayerChat(p, tcm.Text)
                    end
                end)
            end)
            melding("ChatSpy", "Chat Spy ON  *  Monitoring Server", 2, Theme.Green)
        else
            melding("ChatSpy", "Chat Spy OFF", 1.5)
        end
    end

    function setChatLogVisible(v)
        chatLogFrame.Visible = v
    end

    function dumpAlleChatLogs()
        if #recentChats == 0 then
            melding("ChatSpy", "No chat logs recorded yet", 1.8, Theme.Red)
            return
        end
        local fullText = table.concat(recentChats, "\n")
        print("\n=== CHAT SPY LOGS ===\n" .. fullText .. "\n=====================\n")
        if setclipboard then
            pcall(setclipboard, fullText)
            melding("ChatSpy", "Copied " .. #recentChats .. " logs to clipboard + console", 2, Theme.Green)
        else
            melding("ChatSpy", "Dumped " .. #recentChats .. " logs to console (F9)", 2, Theme.Green)
        end
    end

    function haalLaatsteChat()
        return recentChats[#recentChats] or "No messages intercepted yet"
    end
end



do
    local entityRadarEnabled = false
    local entityRadarConn = nil
    local entityBills = {}

    local itemRadarEnabled = false
    local itemRadarConn = nil
    local itemBills = {}

    local function clearEntityRadar()
        for _, b in pairs(entityBills) do if b and b.Parent then b:Destroy() end end
        entityBills = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if d.Name == "EntityHL" then d:Destroy() end
        end
    end

    local function clearItemRadar()
        for _, b in pairs(itemBills) do if b and b.Parent then b:Destroy() end end
        itemBills = {}
    end

    local threatKeywords = {
        "monster", "entity", "killer", "creature", "demon", "ghost",
        "screech", "rush", "ambush", "figure", "seek", "nextbot",
        "stalker", "beast", "hazard", "danger", "chaser", "eyes", "halt",
        "mimic", "shadow", "flesh", "anomaly", "npc"
    }

    local function isThreatName(name)
        local low = string.lower(name)
        for _, kw in ipairs(threatKeywords) do
            if string.find(low, kw) then return true end
        end
        return false
    end

    function zetEntiteitRadar(enabled)
        entityRadarEnabled = enabled
        entityRadarConn = veiligOntkoppelen(entityRadarConn)
        clearEntityRadar()
        if enabled then
            entityRadarConn = RunService.Heartbeat:Connect(function()
                local myRoot = pakBasis()
                if not myRoot then return end

                local playerChars = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then playerChars[p.Character] = true end
                end

                for _, d in ipairs(workspace:GetChildren()) do
                    if not playerChars[d] then
                        local rootPart = nil
                        local isThreat = false
                        local threatLabel = d.Name
                        local speed = 0

                        if d:IsA("Model") then
                            local hum = d:FindFirstChildOfClass("Humanoid")
                            local animCtrl = d:FindFirstChildOfClass("AnimationController")
                            local mainPart = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head") or d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")

                            if hum and hum.Health > 0 and mainPart then
                                isThreat = true
                                rootPart = mainPart
                                speed = math.floor(mainPart.AssemblyLinearVelocity.Magnitude)
                            elseif animCtrl and mainPart then
                                isThreat = true
                                rootPart = mainPart
                                speed = math.floor(mainPart.AssemblyLinearVelocity.Magnitude)
                            elseif mainPart then
                                local vel = mainPart.AssemblyLinearVelocity.Magnitude
                                if vel > 2.5 or isThreatName(d.Name) then
                                    isThreat = true
                                    rootPart = mainPart
                                    speed = math.floor(vel)
                                end
                            end
                        elseif d:IsA("BasePart") and not d.Anchored then
                            local vel = d.AssemblyLinearVelocity.Magnitude
                            if vel > 4 or isThreatName(d.Name) then
                                isThreat = true
                                rootPart = d
                                speed = math.floor(vel)
                            end
                        end

                        if isThreat and rootPart and rootPart.Parent then
                            local dist = math.round((myRoot.Position - rootPart.Position).Magnitude)
                            if dist <= 380 then
                                local bill = entityBills[d]
                                if not bill or not bill.Parent then
                                    bill = Instance.new("BillboardGui")
                                    bill.Name = "EntityBill"
                                    bill.Size = UDim2.new(0, 140, 0, 26)
                                    bill.StudsOffset = Vector3.new(0, 3.2, 0)
                                    bill.AlwaysOnTop = true
                                    bill.Adornee = rootPart
                                    bill.Parent = rootPart

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Name = "ELbl"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 0.35
                                    lbl.BackgroundColor3 = Color3.fromRGB(18, 6, 6)
                                    lbl.TextColor3 = Theme.Red
                                    lbl.Font = Enum.Font.Gotham
                                    lbl.TextSize = 10
                                    lbl.Parent = bill

                                    local elc = Instance.new("UICorner")
                                    elc.CornerRadius = UDim.new(0, 4)
                                    elc.Parent = lbl

                                    local els = Instance.new("UIStroke")
                                    els.Color = Theme.Red
                                    els.Thickness = 1
                                    els.Parent = lbl

                                    local hl = Instance.new("Highlight")
                                    hl.Name = "EntityHL"
                                    hl.FillTransparency = 0.72
                                    hl.OutlineTransparency = 0.15
                                    hl.FillColor = Theme.Red
                                    hl.OutlineColor = Theme.Red
                                    hl.Adornee = d
                                    hl.Parent = d
                                    entityBills[d] = bill
                                end
                                local lbl = bill:FindFirstChild("ELbl")
                                if lbl then
                                    if speed > 1 then
                                        lbl.Text = string.format("[!] %s (%dm | %d s/s)", threatLabel, dist, speed)
                                    else
                                        lbl.Text = string.format("[!] %s (%dm)", threatLabel, dist)
                                    end
                                end
                            end
                        else
                            if entityBills[d] then
                                if entityBills[d].Parent then entityBills[d]:Destroy() end
                                entityBills[d] = nil
                            end
                        end
                    end
                end
            end)
        end
    end

    local itemKeywords = {"key", "battery", "fuse", "note", "book", "card", "lever", "generator", "flashlight", "crowbar", "wrench", "hammer", "code"}

    local function isItemName(name)
        local low = string.lower(name)
        for _, kw in ipairs(itemKeywords) do
            if string.find(low, kw) then return true end
        end
        return false
    end

    function setItemRadar(enabled)
        itemRadarEnabled = enabled
        itemRadarConn = veiligOntkoppelen(itemRadarConn)
        clearItemRadar()
        if enabled then
            local cachedTargets = {}
            local lastScan = 0

            itemRadarConn = RunService.Heartbeat:Connect(function()
                local myRoot = pakBasis()
                if not myRoot then return end
                local now = os.clock()

                if now - lastScan > 1.8 then
                    lastScan = now
                    cachedTargets = {}
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d:IsA("Tool") or d:IsA("ProximityPrompt") or isItemName(d.Name) then
                            local tp = d:IsA("BasePart") and d or (d:FindFirstChildWhichIsA("BasePart") or (d.Parent and d.Parent:IsA("BasePart") and d.Parent))
                            if tp and not tp:IsDescendantOf(LocalPlayer.Character) then
                                table.insert(cachedTargets, {obj = d, part = tp, name = d.Name})
                            end
                        end
                    end
                end

                for _, item in ipairs(cachedTargets) do
                    if item.part and item.part.Parent then
                        local dist = math.round((myRoot.Position - item.part.Position).Magnitude)
                        if dist <= 260 then
                            local bill = itemBills[item.obj]
                            if not bill or not bill.Parent then
                                bill = Instance.new("BillboardGui")
                                bill.Name = "ItemBill"
                                bill.Size = UDim2.new(0, 130, 0, 22)
                                bill.StudsOffset = Vector3.new(0, 2, 0)
                                bill.AlwaysOnTop = true
                                bill.Adornee = item.part
                                bill.Parent = item.part

                                local lbl = Instance.new("TextLabel")
                                lbl.Name = "ILbl"
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 0.4
                                lbl.BackgroundColor3 = Color3.fromRGB(6, 16, 20)
                                lbl.TextColor3 = Color3.fromRGB(80, 220, 255)
                                lbl.Font = Enum.Font.Gotham
                                lbl.TextSize = 10
                                lbl.Parent = bill

                                local ilc = Instance.new("UICorner")
                                ilc.CornerRadius = UDim.new(0, 4)
                                ilc.Parent = lbl

                                itemBills[item.obj] = bill
                            end
                            local lbl = bill:FindFirstChild("ILbl")
                            if lbl then lbl.Text = string.format("[*] %s (%dm)", item.name, dist) end
                        end
                    end
                end
            end)
        end
    end
end

do
local clearVisionEnabled = false
local clearVisionConn = nil

function zetHelderZicht(enabled)
    clearVisionEnabled = enabled
    clearVisionConn = veiligOntkoppelen(clearVisionConn)

    if enabled then
        clearVisionConn = RunService.Heartbeat:Connect(function()
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("BlurEffect") and v.Enabled then
                    v.Enabled = false
                end
                if v:IsA("Atmosphere") and v.Density > 0.3 then
                    v.Density = 0.1
                end
            end
        end)
    end
end

end

do
local touchShieldEnabled = false
local touchShieldConn = nil

function zetAanraakSchild(enabled)
    touchShieldEnabled = enabled
    touchShieldConn = veiligOntkoppelen(touchShieldConn)

    local char = pakKarakter()
    if not enabled and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = true
            end
        end
    end

    if enabled then
        touchShieldConn = RunService.Stepped:Connect(function()
            local c = pakKarakter()
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanTouch then
                        part.CanTouch = false
                    end
                end
            end
        end)
    end
end

local antiFallEnabled = false
local antiFallConn = nil

function zetValBescherming(enabled)
    antiFallEnabled = enabled
    antiFallConn = veiligOntkoppelen(antiFallConn)

    if enabled then
        antiFallConn = RunService.Heartbeat:Connect(function()
            local root = pakBasis()
            if not root then return end

            if root.AssemblyLinearVelocity.Y < -55 then
                local ray = Ray.new(root.Position, Vector3.new(0, -15, 0))
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {pakKarakter()})
                if hit then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
                end
            end
        end)
    end
end

customWalkSpeed = 16
local speedBoostEnabled = false
local speedBoostConn = nil

function setSpeedBoost(enabled)
    speedBoostEnabled = enabled
    speedBoostConn = veiligOntkoppelen(speedBoostConn)
    if enabled then
        speedBoostConn = RunService.Heartbeat:Connect(function()
            local hum = pakMens()
            if hum and hum.WalkSpeed ~= customWalkSpeed then
                hum.WalkSpeed = customWalkSpeed
            end
        end)
    else
        local hum = pakMens()
        if hum then hum.WalkSpeed = 16 end
    end
end

local godmodeEnabled = false
local godmodeConn = nil
local godmodeHeartbeatConn = nil

function zetGodModus(enabled)
    godmodeEnabled = enabled
    godmodeConn = veiligOntkoppelen(godmodeConn)
    godmodeHeartbeatConn = veiligOntkoppelen(godmodeHeartbeatConn)
    zetDoodsSchild(enabled)
    zetAanraakSchild(enabled)
    zetValBescherming(enabled)

    local hum = pakMens()
    if hum then
        pcall(function()
            if enabled then
                hum.BreakJointsOnDeath = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            else
                hum.BreakJointsOnDeath = true
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end
        end)
    end

    if enabled then
        if hum then
            godmodeConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if godmodeEnabled and hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end

        godmodeHeartbeatConn = RunService.Heartbeat:Connect(function()
            if not godmodeEnabled then return end
            local curHum = pakMens()
            if curHum then
                if curHum.Health < curHum.MaxHealth then
                    curHum.Health = curHum.MaxHealth
                end
                curHum.BreakJointsOnDeath = false
                curHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                if curHum:GetState() == Enum.HumanoidStateType.Dead then
                    curHum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end)
        melding("Protection", "Enhanced God Mode ACTIVE (Auto-heal + Death/Touch Shield)", 2, Theme.Green)
    else
        melding("Protection", "God Mode OFF", 1.5)
    end
end

local deathShieldEnabled = false
local deathShieldConn = nil

function zetDoodsSchild(enabled)
    deathShieldEnabled = enabled
    deathShieldConn = veiligOntkoppelen(deathShieldConn)

    local hum = pakMens()
    if not enabled and hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end)
    end

    if enabled and hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end)
        deathShieldConn = hum.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Dead or newState == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end

local promptEnabled = false
local promptConn = nil
local originalPrompts = {}

local function applyPrompt(p)
    if not p:IsA("ProximityPrompt") then return end
    if originalPrompts[p] == nil then
        originalPrompts[p] = {
            HoldDuration = p.HoldDuration,
            RequiresLineOfSight = p.RequiresLineOfSight,
            MaxActivationDistance = p.MaxActivationDistance
        }
    end
    p.HoldDuration = 0
    p.RequiresLineOfSight = false
    p.MaxActivationDistance = math.max(p.MaxActivationDistance, 25)
end

function zetDirecteInteractie(enabled)
    promptEnabled = enabled
    promptConn = veiligOntkoppelen(promptConn)

    if enabled then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then applyPrompt(d) end
        end
        promptConn = workspace.DescendantAdded:Connect(function(d)
            if promptEnabled and d:IsA("ProximityPrompt") then
                task.wait(0.1)
                applyPrompt(d)
            end
        end)
    else
        for p, orig in pairs(originalPrompts) do
            if p and p.Parent then
                p.HoldDuration = orig.HoldDuration
                p.RequiresLineOfSight = orig.RequiresLineOfSight
                p.MaxActivationDistance = orig.MaxActivationDistance
            end
        end
        originalPrompts = {}
    end
end

local infZoomEnabled = false
local origMaxZoom = 128
local origMinZoom = 0.5
local origCamMode = Enum.CameraMode.Classic

function zetOneindigInzoomen(enabled)
    infZoomEnabled = enabled
    if enabled then
        origMaxZoom = LocalPlayer.CameraMaxZoomDistance
        origMinZoom = LocalPlayer.CameraMinZoomDistance
        origCamMode = LocalPlayer.CameraMode
        LocalPlayer.CameraMaxZoomDistance = 100000
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    else
        LocalPlayer.CameraMaxZoomDistance = origMaxZoom
        LocalPlayer.CameraMinZoomDistance = origMinZoom
        LocalPlayer.CameraMode = origCamMode
    end
end

local unlockFirstPersonEnabled = false
local unlockFirstPersonConn = nil

function setUnlockFirstPerson(enabled)
    unlockFirstPersonEnabled = enabled
    unlockFirstPersonConn = veiligOntkoppelen(unlockFirstPersonConn)
    if enabled then
        unlockFirstPersonConn = RunService.RenderStepped:Connect(function()
            if LocalPlayer.CameraMaxZoomDistance < 1000 then
                LocalPlayer.CameraMaxZoomDistance = 100000
            end
            if LocalPlayer.CameraMinZoomDistance > 0.5 then
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
        end)
    end
end

end

do
local autoClearAttributesEnabled = false
local autoClearAttributesConn = nil

function clearRestrictions()
    local targets = {LocalPlayer, pakKarakter(), workspace, Camera}
    local count = 0
    for _, obj in ipairs(targets) do
        if obj then
            for name, _ in pairs(obj:GetAttributes()) do
                obj:SetAttribute(name, nil)
                count = count + 1
            end
        end
    end
    local hum = pakMens()
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
            if state ~= Enum.HumanoidStateType.None then
                hum:SetStateEnabled(state, true)
            end
        end
    end
    return count
end

function setAutoClearAttributes(enabled)
    autoClearAttributesEnabled = enabled
    autoClearAttributesConn = veiligOntkoppelen(autoClearAttributesConn)
    if enabled then
        autoClearAttributesConn = RunService.Heartbeat:Connect(function()
            clearRestrictions()
        end)
    end
end

function toggleAllScripts(state)
    local count = 0
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        for _, d in ipairs(ps:GetDescendants()) do
            if d:IsA("LocalScript") and d.Name ~= "Hub" and not d.Name:lower():find("camera") then
                d.Disabled = not state
                count = count + 1
            end
        end
    end
    return count
end

end

do
local hitboxDisplaceEnabled = false
hitboxDisplaceDist = 25
local origRootJointC0 = nil

local function getRootJoint()
    local root = pakBasis()
    if not root then return nil end
    local rj = root:FindFirstChild("RootJoint")
    if rj then return rj end
    local char = pakKarakter()
    local lt = char and char:FindFirstChild("LowerTorso")
    return lt and lt:FindFirstChild("Root")
end

function zetRaakvlakVerplaatsen(enabled)
    hitboxDisplaceEnabled = enabled
    local rj = getRootJoint()
    if not rj then return end

    if origRootJointC0 == nil then
        origRootJointC0 = rj.C0
    end

    if enabled then
        rj.C0 = origRootJointC0 * CFrame.new(0, 0, hitboxDisplaceDist)
    else
        if origRootJointC0 then
            rj.C0 = origRootJointC0
            origRootJointC0 = nil
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    origRootJointC0 = nil
    task.wait(0.6)
    if godmodeEnabled then zetGodModus(true) end
    if speedBoostEnabled then setSpeedBoost(true) end
    if ghostModeEnabled then setGhostMode(true) end
    if deathShieldEnabled then zetDoodsSchild(true) end
    if touchShieldEnabled then zetAanraakSchild(true) end
    if hitboxDisplaceEnabled then zetRaakvlakVerplaatsen(true) end
    if flightEnabled then zetVliegen(true) end
    if flashlightEnabled then zetZaklamp(true) end
end)

end

do
local highlightsEnabled = false
local hlCleanup = nil

local function applyHighlight(player, char)
    if not char then return end
    local old = char:FindFirstChild("CharHighlight")
    if old then old:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "CharHighlight"
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0.1
    hl.FillColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function removeHighlight(player, char)
    if char then
        local old = char:FindFirstChild("CharHighlight")
        if old then old:Destroy() end
    end
end

function zetHoogtepunten(enabled)
    highlightsEnabled = enabled
    if hlCleanup then hlCleanup(); hlCleanup = nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeHighlight(p, p.Character) end
    end

    if enabled then
        hlCleanup = forAllCharacters(applyHighlight, removeHighlight)
    end
end

local fullbrightConn = nil
function setFullbright(enabled)
    fullbrightConn = veiligOntkoppelen(fullbrightConn)
    if enabled then
        fullbrightConn = RunService.Heartbeat:Connect(function()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
        end)
    else
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end
end

local dayCycleConn = nil
function zetDagNachtCyclus(enabled)
    dayCycleConn = veiligOntkoppelen(dayCycleConn)
    if enabled then
        dayCycleConn = RunService.Heartbeat:Connect(function(dt)
            Lighting.ClockTime = (Lighting.ClockTime + dt * 0.8) % 24
        end)
    end
end

local nightVisionEffect = nil
local origAmbient, origOutdoorAmbient, origBrightness = nil, nil, nil

function zetNachtZicht(enabled)
    if not nightVisionEffect then
        nightVisionEffect = Instance.new("ColorCorrectionEffect")
        nightVisionEffect.Name = "NightVision"
        nightVisionEffect.Parent = Lighting
    end
    if enabled then
        origAmbient = Lighting.Ambient
        origOutdoorAmbient = Lighting.OutdoorAmbient
        origBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(20, 220, 80)
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 220, 80)
        Lighting.Brightness = 3.5
        nightVisionEffect.TintColor = Color3.fromRGB(130, 255, 140)
        nightVisionEffect.Brightness = 0.2
        nightVisionEffect.Contrast = 0.45
        nightVisionEffect.Saturation = -0.2
        nightVisionEffect.Enabled = true
    else
        if origAmbient then Lighting.Ambient = origAmbient end
        if origOutdoorAmbient then Lighting.OutdoorAmbient = origOutdoorAmbient end
        if origBrightness then Lighting.Brightness = origBrightness end
        nightVisionEffect.Enabled = false
    end
end

local cameraShakeEnabled = false
cameraShakeIntensity = 3
local cameraShakeConn = nil
local shakeTime = 0

function zetCameraSchudden(enabled)
    cameraShakeEnabled = enabled
    cameraShakeConn = veiligOntkoppelen(cameraShakeConn)
    if enabled then
        cameraShakeConn = RunService.RenderStepped:Connect(function(dt)
            shakeTime = shakeTime + dt * 8
            local i = cameraShakeIntensity * 0.0008
            Camera.CFrame = Camera.CFrame
                * CFrame.Angles(math.sin(shakeTime * 1.3) * i, math.sin(shakeTime * 0.9) * i * 0.7, 0)
        end)
    end
end

local headbobConn = nil
local bobTime = 0

function zetHoofdDeinzen(enabled)
    headbobConn = veiligOntkoppelen(headbobConn)
    if enabled then
        headbobConn = RunService.RenderStepped:Connect(function(dt)
            local hum = pakMens()
            if not hum then return end
            local moving = hum.MoveDirection.Magnitude > 0.1
            if moving then
                bobTime = bobTime + dt * (hum.WalkSpeed * 0.25)
                Camera.CFrame = Camera.CFrame * CFrame.new(
                    math.sin(bobTime * 2.2) * 0.055,
                    math.abs(math.sin(bobTime)) * 0.04,
                    0
                )
            else
                bobTime = 0
            end
        end)
    end
end

local slFrame = nil
local slConn = nil

function zetSnelheidsLijnen(enabled)
    if slFrame then slFrame:Destroy() slFrame = nil end
    slConn = veiligOntkoppelen(slConn)
    if not enabled then return end

    slFrame = Instance.new("Frame")
    slFrame.Size = UDim2.new(1, 0, 1, 0)
    slFrame.BackgroundTransparency = 1
    slFrame.ZIndex = 5
    slFrame.Parent = ScreenGui

    slConn = RunService.RenderStepped:Connect(function(dt)
        local root = pakBasis()
        if not root or not slFrame then return end
        local spd = root.AssemblyLinearVelocity.Magnitude
        local intensity = math.clamp((spd - 24) / 70, 0, 1)

        for _, line in ipairs(slFrame:GetChildren()) do
            local prog = (line:GetAttribute("p") or 0) + dt * (5 + spd * 0.06)
            if prog > 1 then
                line:Destroy()
            else
                line:SetAttribute("p", prog)
                local ease = 1 - (1 - prog) ^ 2
                line.BackgroundTransparency = 1 - intensity * (1 - ease)
                local ox = line:GetAttribute("ox") or 0.5
                local oy = line:GetAttribute("oy") or 0.5
                line.Position = UDim2.new(
                    0.5 + (ox - 0.5) * (1 + ease * 2.4), 0,
                    0.5 + (oy - 0.5) * (1 + ease * 2.4), 0
                )
            end
        end

        if intensity > 0.04 and math.random() < intensity * 0.5 then
            local ang = math.random() * math.pi * 2
            local r = 0.04 + math.random() * 0.06
            local ox = 0.5 + math.cos(ang) * r
            local oy = 0.5 + math.sin(ang) * r
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 1, 0, math.random(25, 80))
            line.Position = UDim2.new(ox, 0, oy, 0)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Rotation = math.deg(ang) + 90
            line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            line.BackgroundTransparency = 1
            line.BorderSizePixel = 0
            line.ZIndex = 5
            line:SetAttribute("p", 0)
            line:SetAttribute("ox", ox)
            line:SetAttribute("oy", oy)
            line.Parent = slFrame
        end
    end)
end

end

do
local ntCleanup = nil
local function applyNameTag(player, char)
    local head = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    if not head then return end
    for _, ch in ipairs(head:GetChildren()) do
        if ch.Name == "CharTag" then ch:Destroy() end
    end

    local bill = Instance.new("BillboardGui")
    bill.Name = "CharTag"
    bill.Size = UDim2.new(0, 130, 0, 30)
    bill.StudsOffset = Vector3.new(0, 2.6, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = head

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel = 0
    bg.Parent = bill

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player and player.Name or char.Name
    lbl.TextColor3 = player and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 200, 100)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Parent = bill
end

local function removeNameTag(player, char)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local old = head:FindFirstChild("CharTag")
            if old then old:Destroy() end
        end
    end
end

function zetNaamKaartjes(enabled)
    if ntCleanup then ntCleanup(); ntCleanup = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeNameTag(p, p.Character) end
    end
    if enabled then
        ntCleanup = forAllCharacters(applyNameTag, removeNameTag)
    end
end

local hbCleanup = nil
local function applyHealthBar(player, char)
    local head = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    if not head then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    for _, ch in ipairs(head:GetChildren()) do
        if ch.Name == "CharHealth" then ch:Destroy() end
    end

    local bill = Instance.new("BillboardGui")
    bill.Name = "CharHealth"
    bill.Size = UDim2.new(0, 90, 0, 9)
    bill.StudsOffset = Vector3.new(0, 1.8, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = head

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bg.BorderSizePixel = 0
    bg.Parent = bill

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Theme.Green
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local function updateBar(cur, max)
        if not fill or not fill.Parent then return end
        local ratio = math.clamp(cur / math.max(max, 1), 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(
            math.floor((1 - ratio) * 220),
            math.floor(ratio * 200 + 20),
            40
        )
    end

    if hum then
        updateBar(hum.Health, hum.MaxHealth)
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            updateBar(hum.Health, hum.MaxHealth)
        end)
    else
        local hv = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:GetAttribute("Health")
        if hv and typeof(hv) == "Instance" and hv:IsA("ValueBase") then
            local max = (char:FindFirstChild("MaxHealth") and char.MaxHealth.Value) or 100
            updateBar(hv.Value, max)
            hv.Changed:Connect(function(v) updateBar(v, max) end)
        elseif typeof(hv) == "number" then
            updateBar(hv, 100)
            char:GetAttributeChangedSignal("Health"):Connect(function()
                updateBar(char:GetAttribute("Health") or 100, 100)
            end)
        end
    end
end

local function removeHealthBar(player, char)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local old = head:FindFirstChild("CharHealth")
            if old then old:Destroy() end
        end
    end
end

function zetGezondheidsBalken(enabled)
    if hbCleanup then hbCleanup(); hbCleanup = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then removeHealthBar(p, p.Character) end
    end
    if enabled then
        hbCleanup = forAllCharacters(applyHealthBar, removeHealthBar)
    end
end

local distConn = nil
function zetAfstandsKaartjes(enabled)
    distConn = veiligOntkoppelen(distConn)
    local function clearDist()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("Head")
                if h then
                    local b = h:FindFirstChild("CharDist")
                    if b then b:Destroy() end
                end
            end
        end
    end
    if not enabled then clearDist(); return end

    distConn = RunService.Heartbeat:Connect(function()
        local myRoot = pakBasis()
        if not myRoot then return end
        local myChar = pakKarakter()

        local function attachDist(char)
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
            local head = char:FindFirstChild("Head") or root
            if root and head then
                local dist = math.round((myRoot.Position - root.Position).Magnitude)
                local bill = head:FindFirstChild("CharDist")
                if not bill then
                    bill = Instance.new("BillboardGui")
                    bill.Name = "CharDist"
                    bill.Size = UDim2.new(0, 70, 0, 16)
                    bill.StudsOffset = Vector3.new(0, 3.8, 0)
                    bill.AlwaysOnTop = true
                    bill.Adornee = head
                    bill.Parent = head

                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "DistLbl"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextSize = 10
                    lbl.TextStrokeTransparency = 0.4
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.Parent = bill
                end
                local lbl = bill:FindFirstChild("DistLbl")
                if lbl then lbl.Text = dist .. "m" end
            end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                attachDist(p.Character)
            end
        end

        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and child ~= myChar and not Players:GetPlayerFromCharacter(child) then
                local hum = child:FindFirstChildOfClass("Humanoid")
                local hv = child:FindFirstChild("Health") or child:FindFirstChild("HP") or child:GetAttribute("Health")
                if (hum and hum.Health > 0) or (hv and (typeof(hv) == "number" and hv > 0 or (typeof(hv) == "Instance" and hv:IsA("ValueBase") and hv.Value > 0))) then
                    attachDist(child)
                end
            end
        end
    end)
end

end


local discoveredScripts = {}
local discoveredRemotes = {}
local scanAccessibleScripts = nil
local scanRemotes = nil
local scanAndRefreshScripts = nil
local scanAndRefreshRemotes = nil
do
    local selectedIndex = 1
    local codeTextBox = nil
    local statusInfoLabel = nil

    scanAccessibleScripts = function()
        discoveredScripts = {}
        local seen = {}

        pcall(function()
            if getscripts then
                local slist = getscripts()
                if type(slist) == "table" then
                    for _, s in ipairs(slist) do
                        if typeof(s) == "Instance" and (s:IsA("LocalScript") or s:IsA("ModuleScript") or s:IsA("Script")) and not s.Name:find("Hub") then
                            if not seen[s] then
                                seen[s] = true
                                table.insert(discoveredScripts, s)
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if getloadedmodules then
                local mlist = getloadedmodules()
                if type(mlist) == "table" then
                    for _, m in ipairs(mlist) do
                        if typeof(m) == "Instance" and m:IsA("ModuleScript") and not m.Name:find("Hub") then
                            if not seen[m] then
                                seen[m] = true
                                table.insert(discoveredScripts, m)
                            end
                        end
                    end
                end
            end
        end)

        local searchRoots = {
            LocalPlayer:FindFirstChild("PlayerScripts"),
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("Backpack"),
            pakKarakter(),
            game:GetService("ReplicatedStorage"),
            game:GetService("ReplicatedFirst"),
            workspace,
            game:GetService("StarterGui"),
            game:GetService("StarterPack"),
            game:GetService("StarterPlayer")
        }

        for _, root in ipairs(searchRoots) do
            if root then
                pcall(function()
                    if (root:IsA("LocalScript") or root:IsA("ModuleScript") or root:IsA("Script")) and not root.Name:find("Hub") then
                        if not seen[root] then
                            seen[root] = true
                            table.insert(discoveredScripts, root)
                        end
                    end
                    for _, d in ipairs(root:GetDescendants()) do
                        pcall(function()
                            if (d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script")) and not d.Name:find("Hub") then
                                if not seen[d] then
                                    seen[d] = true
                                    table.insert(discoveredScripts, d)
                                end
                            end
                        end)
                    end
                end)
            end
        end

        return #discoveredScripts
    end

    scanAndRefreshScripts = function()
        local cnt = scanAccessibleScripts()
        selectedIndex = 1
        updateScriptViewerUI()
        melding("Scripts", "Found " .. cnt .. " accessible scripts", 2, Theme.Green)
    end

    function nextScriptViewer()
        if #discoveredScripts == 0 then scanAccessibleScripts() end
        if #discoveredScripts == 0 then return end
        selectedIndex = selectedIndex + 1
        if selectedIndex > #discoveredScripts then selectedIndex = 1 end
        updateScriptViewerUI()
    end

    function prevScriptViewer()
        if #discoveredScripts == 0 then scanAccessibleScripts() end
        if #discoveredScripts == 0 then return end
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then selectedIndex = #discoveredScripts end
        updateScriptViewerUI()
    end

    function toggleSelectedScript()
        if #discoveredScripts == 0 then return end
        local target = discoveredScripts[selectedIndex]
        if target and target:IsA("LocalScript") then
            target.Disabled = not target.Disabled
            updateScriptViewerUI()
            melding("Scripts", target.Name .. " is now " .. (target.Disabled and "DISABLED" or "ENABLED"), 1.8, target.Disabled and Theme.Red or Theme.Green)
        else
            melding("Scripts", "ModuleScripts cannot be disabled", 1.8, Theme.Red)
        end
    end

    function printSelectedScript()
        if #discoveredScripts == 0 then return end
        local target = discoveredScripts[selectedIndex]
        if target then
            local info = inspectScript(target)
            print("\n" .. info .. "\n")
            if setclipboard then
                pcall(setclipboard, info)
                melding("Scripts", "Copied to clipboard + printed to console", 2, Theme.Green)
            else
                melding("Scripts", "Dumped script info to console (F9)", 2, Theme.Green)
            end
        end
    end

    function bindScriptViewerElements(tb, lbl)
        codeTextBox = tb
        statusInfoLabel = lbl
    end
end



do
    local promptAuraEnabled = false
    local promptAuraConn = nil
    local promptAuraRadius = 30

    function zetInteractieAura(enabled)
        promptAuraEnabled = enabled
        promptAuraConn = veiligOntkoppelen(promptAuraConn)
        if enabled then
            promptAuraConn = RunService.Heartbeat:Connect(function()
                local myRoot = pakBasis()
                if not myRoot then return end
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pPart = prompt.Parent
                        local pos = pPart and (pPart:IsA("BasePart") and pPart.Position or (pPart:IsA("Model") and pPart:GetPivot().Position))
                        if pos and (myRoot.Position - pos).Magnitude <= promptAuraRadius then
                            prompt.HoldDuration = 0
                            prompt.RequiresLineOfSight = false
                            if fireproximityprompt then
                                pcall(fireproximityprompt, prompt)
                            else
                                pcall(function()
                                    prompt:InputHoldBegin()
                                    prompt:InputHoldEnd()
                                end)
                            end
                        end
                    end
                end
            end)
            melding("Auto-Prompt", "Auto-Prompt Aura ON (Radius 30)", 1.8, Theme.Green)
        else
            melding("Auto-Prompt", "Auto-Prompt Aura OFF", 1.5)
        end
    end
end

do
    local touchMagnetEnabled = false
    local touchMagnetConn = nil
    local lastMagnetScan = 0
    local cachedPickups = {}

    function zetAanraakMagneet(enabled)
        touchMagnetEnabled = enabled
        touchMagnetConn = veiligOntkoppelen(touchMagnetConn)
        if enabled then
            touchMagnetConn = RunService.Heartbeat:Connect(function()
                local myRoot = pakBasis()
                if not myRoot then return end
                local now = os.clock()
                if now - lastMagnetScan > 1.2 then
                    lastMagnetScan = now
                    cachedPickups = {}
                    for _, p in ipairs(workspace:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanTouch and not p:IsDescendantOf(LocalPlayer.Character) then
                            if p:FindFirstChildWhichIsA("TouchTransmitter") or string.find(string.lower(p.Name), "coin") or string.find(string.lower(p.Name), "gem") or string.find(string.lower(p.Name), "star") or string.find(string.lower(p.Name), "token") or string.find(string.lower(p.Name), "candy") or string.find(string.lower(p.Name), "drop") then
                                table.insert(cachedPickups, p)
                            end
                        end
                    end
                end
                for _, p in ipairs(cachedPickups) do
                    if p and p.Parent and p.CanTouch then
                        if (myRoot.Position - p.Position).Magnitude <= 35 then
                            if firetouchinterest then
                                pcall(firetouchinterest, myRoot, p, 0)
                                pcall(firetouchinterest, myRoot, p, 1)
                            else
                                pcall(function()
                                    p.CFrame = myRoot.CFrame
                                end)
                            end
                        end
                    end
                end
            end)
            melding("Magnet", "Coin & Pickup Magnet ON (Radius 35)", 1.8, Theme.Green)
        else
            melding("Magnet", "Coin & Pickup Magnet OFF", 1.5)
        end
    end
end

do
    local antiFlingEnabled = false
    local antiFlingConn = nil

    function zetAntiSlinger(enabled)
        antiFlingEnabled = enabled
        antiFlingConn = veiligOntkoppelen(antiFlingConn)
        if enabled then
            antiFlingConn = RunService.Stepped:Connect(function()
                local myRoot = pakBasis()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                if myRoot and (part.Position - myRoot.Position).Magnitude <= 10 then
                                    if part.AssemblyLinearVelocity.Magnitude > 60 or part.AssemblyAngularVelocity.Magnitude > 60 then
                                        part.AssemblyLinearVelocity = Vector3.zero
                                        part.AssemblyAngularVelocity = Vector3.zero
                                    end
                                end
                            end
                        end
                    end
                end
                if myRoot and myRoot.AssemblyAngularVelocity.Magnitude > 120 then
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end
            end)
            melding("Anti-Fling", "Anti-Fling Physics Shield ON", 1.8, Theme.Green)
        else
            melding("Anti-Fling", "Anti-Fling Physics Shield OFF", 1.5)
        end
    end
end

do
    local freecamEnabled = false
    local freecamConn = nil
    local freecamCamCF = nil
    local btoolsEnabled = false
    local btoolsConn = nil

    function zetVrijeCamera(enabled)
        freecamEnabled = enabled
        freecamConn = veiligOntkoppelen(freecamConn)
        if enabled then
            freecamCamCF = Camera.CFrame
            freecamConn = RunService.RenderStepped:Connect(function(dt)
                local move = Vector3.zero
                if keysDown.W then move = move + freecamCamCF.LookVector end
                if keysDown.S then move = move - freecamCamCF.LookVector end
                if keysDown.D then move = move + freecamCamCF.RightVector end
                if keysDown.A then move = move - freecamCamCF.RightVector end
                if keysDown.Space then move = move + Vector3.new(0, 1, 0) end
                if keysDown.LeftShift then move = move - Vector3.new(0, 1, 0) end
                local speed = 65
                freecamCamCF = freecamCamCF + (move.Magnitude > 0 and move.Unit * speed * dt or Vector3.zero)
                Camera.CFrame = freecamCamCF
            end)
            melding("Freecam", "Freecam ON  *  WASD to Fly", 2, Theme.Green)
        else
            local root = pakBasis()
            if root then Camera.CameraSubject = pakMens() end
            melding("Freecam", "Freecam OFF", 1.5)
        end
    end

    function zetBouwGereedschap(enabled)
        btoolsEnabled = enabled
        btoolsConn = veiligOntkoppelen(btoolsConn)
        if enabled then
            btoolsConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local isCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                    local isAlt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
                    if isCtrl or isAlt then
                        local mp = UserInputService:GetMouseLocation()
                        local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
                        local params = RaycastParams.new()
                        local char = pakKarakter()
                        if char then
                            params.FilterDescendantsInstances = {char}
                            params.FilterType = Enum.RaycastFilterType.Exclude
                        end
                        local res = workspace:Raycast(ray.Origin, ray.Direction * 3000, params)
                        if res and res.Instance then
                            if isCtrl then
                                local target = res.Instance
                                local name = target.Name
                                target:Destroy()
                                melding("BTools", "Deleted: " .. name, 1.5, Theme.Red)
                            elseif isAlt then
                                local root = pakBasis()
                                if root then
                                    root.CFrame = CFrame.new(res.Position + Vector3.new(0, 3.5, 0))
                                    melding("BTools", "Teleported to surface", 1.5, Theme.Green)
                                end
                            end
                        end
                    end
                end
            end)
            melding("BTools", "BTools ON: Ctrl+Click to Delete, Alt+Click to TP", 2.5, Theme.Green)
        else
            melding("BTools", "BTools OFF", 1.5)
        end
    end
end

do
    local antiRagdollEnabled = false
    local antiRagdollConn = nil
    local infStaminaEnabled = false
    local infStaminaConn = nil

    function zetAntiLappenpop(enabled)
        antiRagdollEnabled = enabled
        antiRagdollConn = veiligOntkoppelen(antiRagdollConn)
        local hum = pakMens()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not enabled)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not enabled)
            end)
        end
        if enabled then
            antiRagdollConn = RunService.Heartbeat:Connect(function()
                local h = pakMens()
                if h then
                    local state = h:GetState()
                    if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
                        h:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)
            melding("Anti-Ragdoll", "Anti-Ragdoll ON  *  Immune to Knockdown", 1.8, Theme.Green)
        else
            melding("Anti-Ragdoll", "Anti-Ragdoll OFF", 1.5)
        end
    end

    function zetOneindigUithoudingsvermogen(enabled)
        infStaminaEnabled = enabled
        infStaminaConn = veiligOntkoppelen(infStaminaConn)
        if enabled then
            infStaminaConn = RunService.Heartbeat:Connect(function()
                local char = pakKarakter()
                local targets = {LocalPlayer, char}
                for _, t in ipairs(targets) do
                    if t then
                        for _, attr in ipairs({"Stamina", "stamina", "Energy", "energy", "Sprint", "sprint", "Breath", "RunStamina"}) do
                            if t:GetAttribute(attr) ~= nil then
                                t:SetAttribute(attr, 100)
                            end
                        end
                        for _, d in ipairs(t:GetDescendants()) do
                            if d:IsA("NumberValue") or d:IsA("IntValue") then
                                local name = string.lower(d.Name)
                                if string.find(name, "stamina") or string.find(name, "energy") or string.find(name, "sprint") then
                                    d.Value = 100
                                end
                            end
                        end
                    end
                end
            end)
            melding("Stamina", "Infinite Stamina ON  *  Locked at 100%", 1.8, Theme.Green)
        else
            melding("Stamina", "Infinite Stamina OFF", 1.5)
        end
    end
end

do
    local antiVoidEnabled = false
    local antiVoidConn = nil
    local lastGroundCF = nil

    function zetAntiLeegte(enabled)
        antiVoidEnabled = enabled
        antiVoidConn = veiligOntkoppelen(antiVoidConn)
        if enabled then
            local root = pakBasis()
            if root then lastGroundCF = root.CFrame end
            antiVoidConn = RunService.Heartbeat:Connect(function()
                local myRoot = pakBasis()
                local hum = pakMens()
                if not myRoot or not hum then return end

                if hum.FloorMaterial ~= Enum.Material.Air then
                    lastGroundCF = myRoot.CFrame
                end

                if myRoot.Position.Y < -40 or myRoot.AssemblyLinearVelocity.Y < -140 then
                    if lastGroundCF then
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        myRoot.CFrame = lastGroundCF + Vector3.new(0, 3.5, 0)
                        melding("Anti-Void", "Void Fall Saved  *  Returned to Platform", 1.5, Theme.Green)
                    end
                end
            end)
            melding("Anti-Void", "Anti-Void Fall Rebound ON", 1.8, Theme.Green)
        else
            melding("Anti-Void", "Anti-Void Fall Rebound OFF", 1.5)
        end
    end
end

do
    local spiderWalkEnabled = false
    local spiderWalkConn = nil

    function zetSpinnenLoop(enabled)
        spiderWalkEnabled = enabled
        spiderWalkConn = veiligOntkoppelen(spiderWalkConn)
        if enabled then
            spiderWalkConn = RunService.Heartbeat:Connect(function(dt)
                local root = pakBasis()
                local hum = pakMens()
                if not root or not hum then return end
                if hum.MoveDirection.Magnitude > 0.1 then
                    local ray = Ray.new(root.Position, hum.MoveDirection * 2.5)
                    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {pakKarakter()})
                    if hit and hit.CanCollide then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 35, root.AssemblyLinearVelocity.Z)
                    end
                end
            end)
            melding("Spider-Walk", "Spider Wall Climb ON  *  Walk into Walls to Climb", 2, Theme.Green)
        else
            melding("Spider-Walk", "Spider Wall Climb OFF", 1.5)
        end
    end
end

do
    local ghostDesyncEnabled = false
    local ghostDummy = nil
    local ghostAnchorPos = nil
    local ghostDesyncConn = nil

    function zetGeestDesync(enabled)
        ghostDesyncEnabled = enabled
        ghostDesyncConn = veiligOntkoppelen(ghostDesyncConn)
        local char = pakKarakter()
        local root = pakBasis()
        if not char or not root then return end

        if enabled then
            ghostAnchorPos = root.CFrame
            local clone = Instance.new("Model")
            clone.Name = "GhostDummy"
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    local cp = p:Clone()
                    cp.Anchored = true
                    cp.CanCollide = false
                    cp.Transparency = 0.5
                    cp.Material = Enum.Material.ForceField
                    cp.Color = Color3.fromRGB(180, 200, 255)
                    cp.Parent = clone
                end
            end
            clone.Parent = workspace
            ghostDummy = clone

            melding("Ghost Desync", "Ghost Desync ON  *  Body Frozen for Enemies", 2, Theme.Green)
        else
            if ghostDummy then ghostDummy:Destroy() ghostDummy = nil end
            melding("Ghost Desync", "Ghost Desync OFF", 1.5)
        end
    end
end



do
    local audioSonarEnabled = false
    local audioSonarConn = nil
    local maxSonarDist = 120

    local function getSoundCategory(sound)
        local name = string.lower(sound.Name)
        if string.find(name, "step") or string.find(name, "walk") or string.find(name, "run") then
            return "Footstep", Color3.fromRGB(80, 180, 255), "F"
        elseif string.find(name, "shot") or string.find(name, "fire") or string.find(name, "gun") or string.find(name, "shoot") or string.find(name, "blast") then
            return "Gunshot", Color3.fromRGB(255, 70, 70), "G"
        elseif string.find(name, "reload") or string.find(name, "equip") or string.find(name, "click") then
            return "Weapon", Color3.fromRGB(255, 200, 60), "W"
        elseif string.find(name, "jump") or string.find(name, "land") then
            return "Movement", Color3.fromRGB(160, 255, 120), "M"
        else
            return "Audio", Color3.fromRGB(220, 220, 240), "A"
        end
    end

    local function spawnSonarPulse(sound, part)
        local myRoot = pakBasis()
        if not myRoot or not part or not part.Parent then return end
        if part:IsDescendantOf(LocalPlayer.Character) then return end

        local dist = math.round((myRoot.Position - part.Position).Magnitude)
        if dist > maxSonarDist or dist < 2 then return end

        local category, color, icon = getSoundCategory(sound)

        local pulsePart = Instance.new("Part")
        pulsePart.Size = Vector3.new(0.5, 0.5, 0.5)
        pulsePart.Position = part.Position
        pulsePart.Anchored = true
        pulsePart.CanCollide = false
        pulsePart.Transparency = 1
        pulsePart.Parent = workspace

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 110, 0, 22)
        bill.StudsOffset = Vector3.new(0, 1.5, 0)
        bill.AlwaysOnTop = true
        bill.Adornee = pulsePart
        bill.Parent = pulsePart

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        lbl.BackgroundTransparency = 0.3
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.Text = string.format("%s %s (%dm)", icon, category, dist)
        lbl.Parent = bill

        local lc = Instance.new("UICorner")
        lc.CornerRadius = UDim.new(0, 4)
        lc.Parent = lbl

        local ls = Instance.new("UIStroke")
        ls.Color = color
        ls.Thickness = 1
        ls.Parent = lbl

        glij(bill, {StudsOffset = Vector3.new(0, 3.2, 0)}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        glij(lbl, {BackgroundTransparency = 1, TextTransparency = 1}, 1.2).Completed:Connect(function()
            pulsePart:Destroy()
        end)
    end

    function setAudioSonar(enabled)
        audioSonarEnabled = enabled
        audioSonarConn = veiligOntkoppelen(audioSonarConn)
        if enabled then
            local monitoredSounds = {}
            audioSonarConn = RunService.Heartbeat:Connect(function()
                for _, s in ipairs(workspace:GetDescendants()) do
                    if s:IsA("Sound") and s.IsPlaying and s.Volume > 0.1 then
                        local p = s.Parent
                        if p and p:IsA("BasePart") and not monitoredSounds[s] then
                            monitoredSounds[s] = true
                            spawnSonarPulse(s, p)
                            task.delay(0.6, function() monitoredSounds[s] = nil end)
                        end
                    end
                end
            end)
            melding("Audio Sonar", "3D Audio Sonar ON  *  Visualizing Sounds", 2, Theme.Green)
        else
            melding("Audio Sonar", "3D Audio Sonar OFF", 1.5)
        end
    end
end

do
    local selectedRemoteIndex = 1
    local remoteStatusLabel = nil
    local remoteSpamEnabled = false
    local remoteSpamConn = nil

    scanRemotes = function()
        discoveredRemotes = {}
        local roots = {game:GetService("ReplicatedStorage"), workspace, game:GetService("Players")}
        for _, r in ipairs(roots) do
            if r then
                for _, d in ipairs(r:GetDescendants()) do
                    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                        table.insert(discoveredRemotes, d)
                    end
                end
            end
        end
        return #discoveredRemotes
    end

    local function getRemotePath(rem)
        if not rem then return "None" end
        local parts = {}
        local cur = rem
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

    local function updateRemoteUI()
        if not remoteStatusLabel then return end
        if #discoveredRemotes == 0 then
            remoteStatusLabel.Text = "No remotes found. Click 'Scan Remotes'."
            return
        end
        if selectedRemoteIndex > #discoveredRemotes then selectedRemoteIndex = 1 end
        if selectedRemoteIndex < 1 then selectedRemoteIndex = #discoveredRemotes end
        local rem = discoveredRemotes[selectedRemoteIndex]
        if rem then
            local cmd = getExecutableCommand and getExecutableCommand(rem) or getRemotePath(rem)
            remoteStatusLabel.Text = string.format("(%d/%d) %s [%s]\nCMD: %s", selectedRemoteIndex, #discoveredRemotes, rem.Name, rem.ClassName, cmd)
        end
    end

    scanAndRefreshRemotes = function()
        local cnt = scanRemotes()
        selectedRemoteIndex = 1
        updateRemoteUI()
        task.spawn(function() task.wait(0.2); compileGameLogbook() end)
        task.spawn(function() task.wait(0.2); compileGameLogbook() end)
        melding("Remotes", "Discovered " .. cnt .. " Server Remotes", 2, Theme.Green)
    end

    function nextRemote()
        if #discoveredRemotes == 0 then scanRemotes() end
        if #discoveredRemotes == 0 then return end
        selectedRemoteIndex = selectedRemoteIndex + 1
        if selectedRemoteIndex > #discoveredRemotes then selectedRemoteIndex = 1 end
        updateRemoteUI()
    end

    function prevRemote()
        if #discoveredRemotes == 0 then scanRemotes() end
        if #discoveredRemotes == 0 then return end
        selectedRemoteIndex = selectedRemoteIndex - 1
        if selectedRemoteIndex < 1 then selectedRemoteIndex = #discoveredRemotes end
        updateRemoteUI()
    end

    function fireCurrentRemote(argType)
        if #discoveredRemotes == 0 then scanRemotes() end
        local rem = discoveredRemotes[selectedRemoteIndex]
        if not rem then return end

        pcall(function()
            if rem:IsA("RemoteEvent") then
                if argType == "None" then
                    rem:FireServer()
                elseif argType == "Player" then
                    rem:FireServer(LocalPlayer)
                elseif argType == "Number" then
                    rem:FireServer(100)
                elseif argType == "String" then
                    rem:FireServer("Claim")
                end
            elseif rem:IsA("RemoteFunction") then
                if argType == "None" then
                    rem:InvokeServer()
                elseif argType == "Player" then
                    rem:InvokeServer(LocalPlayer)
                end
            end
        end)
        melding("Remote Invoker", "Fired: " .. rem.Name .. " (" .. argType .. ")", 1.5, Theme.Green)
    end

    function setRemoteSpam(enabled)
        remoteSpamEnabled = enabled
        remoteSpamConn = veiligOntkoppelen(remoteSpamConn)
        if enabled then
            remoteSpamConn = RunService.Heartbeat:Connect(function()
                local rem = discoveredRemotes[selectedRemoteIndex]
                if rem and rem:IsA("RemoteEvent") then
                    pcall(function() rem:FireServer() end)
                end
            end)
            melding("Remote Spam", "Spam Loop ON  *  Firing 60x/sec", 1.8, Theme.Green)
        else
            melding("Remote Spam", "Spam Loop OFF", 1.5)
        end
    end

    function bindRemoteStatusLabel(lbl)
        remoteStatusLabel = lbl
    end
end

do
    local logbookFrame = Instance.new("Frame")
    logbookFrame.Name = "LogbookFrame"
    logbookFrame.Size = UDim2.new(0, 360, 0, 260)
    logbookFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
    logbookFrame.BackgroundColor3 = Theme.Background
    logbookFrame.BorderSizePixel = 0
    logbookFrame.ZIndex = 130
    logbookFrame.Visible = false
    logbookFrame.Parent = ScreenGui

    logbookFrame.BorderSizePixel = 1
    logbookFrame.BorderColor3 = Theme.Border

    local lbfTopBar = Instance.new("Frame")
    lbfTopBar.Size = UDim2.new(1, 0, 0, 30)
    lbfTopBar.BackgroundColor3 = Theme.Header
    lbfTopBar.BorderSizePixel = 0
    lbfTopBar.ZIndex = 131
    lbfTopBar.Parent = logbookFrame

    lbfTopBar.BorderSizePixel = 0

    local lbfTitle = Instance.new("TextLabel")
    lbfTitle.Size = UDim2.new(0, 190, 1, 0)
    lbfTitle.Position = UDim2.new(0, 10, 0, 0)
    lbfTitle.BackgroundTransparency = 1
    lbfTitle.Text = "LOGBOOK  *  GAME DOSSIER"
    lbfTitle.TextColor3 = Theme.Accent
    lbfTitle.Font = Enum.Font.Gotham
    lbfTitle.TextSize = 10
    lbfTitle.TextXAlignment = Enum.TextXAlignment.Left
    lbfTitle.ZIndex = 132
    lbfTitle.Parent = lbfTopBar

    local lbfCloseBtn = Instance.new("TextButton")
    lbfCloseBtn.Size = UDim2.new(0, 22, 0, 22)
    lbfCloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
    lbfCloseBtn.BackgroundColor3 = Theme.ElementBg
    lbfCloseBtn.Text = "x"
    lbfCloseBtn.TextColor3 = Theme.TextSecondary
    lbfCloseBtn.Font = Enum.Font.Gotham
    lbfCloseBtn.TextSize = 11
    lbfCloseBtn.BorderSizePixel = 0
    lbfCloseBtn.ZIndex = 132
    lbfCloseBtn.Parent = lbfTopBar

    local lbfCopyBtn = Instance.new("TextButton")
    lbfCopyBtn.Size = UDim2.new(0, 46, 0, 20)
    lbfCopyBtn.Position = UDim2.new(1, -76, 0.5, -10)
    lbfCopyBtn.BackgroundColor3 = Theme.ElementBg
    lbfCopyBtn.Text = "COPY"
    lbfCopyBtn.TextColor3 = Theme.TextPrimary
    lbfCopyBtn.Font = Enum.Font.Gotham
    lbfCopyBtn.TextSize = 9
    lbfCopyBtn.BorderSizePixel = 0
    lbfCopyBtn.ZIndex = 132
    lbfCopyBtn.Parent = lbfTopBar

    local lbfScroll = Instance.new("ScrollingFrame")
    lbfScroll.Size = UDim2.new(1, -12, 1, -40)
    lbfScroll.Position = UDim2.new(0, 6, 0, 34)
    lbfScroll.BackgroundTransparency = 1
    lbfScroll.BorderSizePixel = 0
    lbfScroll.ScrollBarThickness = 3
    lbfScroll.ScrollBarImageColor3 = Theme.BorderBright
    lbfScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    lbfScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lbfScroll.ZIndex = 131
    lbfScroll.Parent = logbookFrame

    local lbfLayout = Instance.new("UIListLayout")
    lbfLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lbfLayout.Padding = UDim.new(0, 3)
    lbfLayout.Parent = lbfScroll

    local lbfDragging, lbfDragInput, lbfMousePos, lbfFramePos = false, nil, nil, nil
    lbfTopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            lbfDragging = true
            lbfMousePos = inp.Position
            lbfFramePos = logbookFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then lbfDragging = false end
    end)
    lbfTopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then lbfDragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == lbfDragInput and lbfDragging then
            local d = inp.Position - lbfMousePos
            logbookFrame.Position = UDim2.new(lbfFramePos.X.Scale, lbfFramePos.X.Offset + d.X, lbfFramePos.Y.Scale, lbfFramePos.Y.Offset + d.Y)
        end
    end)

    lbfCloseBtn.MouseButton1Click:Connect(function() logbookFrame.Visible = false end)

    local cachedDossierText = ""

        local function getExecutableCommand(inst)
        if not inst then return "" end
        local parts = {}
        local cur = inst
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        local service = parts[1]
        local path = ""
        if service then
            path = string.format('game:GetService("%s")', service)
            for i = 2, #parts do
                local pName = parts[i]
                if string.match(pName, "^[a-zA-Z_][a-zA-Z0-9_]*$") then
                    path = path .. "." .. pName
                else
                    path = string.format('%s["%s"]', path, pName)
                end
            end
        else
            path = inst:GetFullName()
        end
        if inst:IsA("RemoteEvent") then
            return path .. ":FireServer()"
        elseif inst:IsA("RemoteFunction") then
            return path .. ":InvokeServer()"
        end
        return path
    end

    local function getFullInstancePath(inst)
        if not inst then return "" end
        local parts = {}
        local cur = inst
        while cur and cur ~= game do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

        local function addEntryCard(tag, title, detail, col)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = Theme.ElementBg
        card.BorderSizePixel = 0
        card.ZIndex = 132
        card.Parent = lbfScroll

        local cCorner = Instance.new("UICorner", card)
        cCorner.CornerRadius = UDim.new(0, 4)

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Size = UDim2.new(0, 48, 0, 14)
        tagLbl.Position = UDim2.new(0, 6, 0, 4)
        tagLbl.BackgroundColor3 = Theme.Header
        tagLbl.TextColor3 = col or Theme.Accent
        tagLbl.Font = Enum.Font.Gotham
        tagLbl.TextSize = 8
        tagLbl.Text = tag
        tagLbl.ZIndex = 133
        tagLbl.Parent = card

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -62, 0, 14)
        nameLbl.Position = UDim2.new(0, 58, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Theme.TextPrimary
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 9
        nameLbl.Text = title
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 133
        nameLbl.Parent = card

        local pathLbl = Instance.new("TextLabel")
        pathLbl.Size = UDim2.new(1, -12, 0, 12)
        pathLbl.Position = UDim2.new(0, 6, 0, 18)
        pathLbl.BackgroundTransparency = 1
        pathLbl.TextColor3 = Theme.TextSecondary
        pathLbl.Font = Enum.Font.Gotham
        pathLbl.TextSize = 8
        pathLbl.Text = detail
        pathLbl.TextXAlignment = Enum.TextXAlignment.Left
        pathLbl.ZIndex = 133
        pathLbl.Parent = card
    end

    function compileGameLogbook()
        lbfScroll:ClearAllChildren()
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 3)
        layout.Parent = lbfScroll

        local remotesCount = #discoveredRemotes
        local scriptsCount = #discoveredScripts
        local placeId = tostring(game.PlaceId)
        local jobId = string.sub(tostring(game.JobId), 1, 8)

        local lines = {}
        table.insert(lines, "=== GAME ARCHITECTURE LOGBOOK ===")
        table.insert(lines, "Place ID: " .. placeId)
        table.insert(lines, "Job ID: " .. jobId)
        table.insert(lines, "Remotes Discovered: " .. remotesCount)
        table.insert(lines, "Scripts Discovered: " .. scriptsCount)
        table.insert(lines, "")
        table.insert(lines, "=== SERVER REMOTES ===")

        addEntryCard("INFO", "Game Place ID: " .. placeId, "Remotes: " .. remotesCount .. " | Scripts: " .. scriptsCount, Theme.Green)

        for _, r in ipairs(discoveredRemotes) do
            local p = getFullInstancePath(r)
            local tag = r:IsA("RemoteEvent") and "EVENT" or "FUNC"
            local cmd = getExecutableCommand(r)
            addEntryCard(tag, r.Name, cmd, Theme.Accent)
            table.insert(lines, string.format("[%s] %s\n      CMD: %s", tag, r.Name, cmd))
        end

        table.insert(lines, "")
        table.insert(lines, "=== CLIENT SCRIPTS ===")
        for _, s in ipairs(discoveredScripts) do
            local p = getFullInstancePath(s)
            local tag = s:IsA("LocalScript") and "LOCAL" or "MODULE"
            addEntryCard(tag, s.Name, p, Theme.TextSecondary)
            table.insert(lines, string.format("[%s] %s -> %s", tag, s.Name, p))
        end

        cachedDossierText = table.concat(lines, "\n")
        logbookFrame.Visible = true
        melding("Logbook", "Dossier Compiled (" .. remotesCount .. " Remotes, " .. scriptsCount .. " Scripts)", 2.5, Theme.Accent)
    end

    function copyLogbookDossier()
        if cachedDossierText == "" then
            compileGameLogbook()
        end
        pcall(function()
            if setclipboard then
                setclipboard(cachedDossierText)
            end
        end)
        print(cachedDossierText)
        melding("Logbook", "Copied to Clipboard & Console", 2, Theme.Green)
    end

    lbfCopyBtn.MouseButton1Click:Connect(copyLogbookDossier)

    
    function fullScanAndCopyClipboard()
        local rCnt = scanRemotes and scanRemotes() or 0
        local sCnt = scanAccessibleScripts and scanAccessibleScripts() or 0

        compileGameLogbook()
        copyLogbookDossier()

        melding("Intel", string.format("COPIED! %d Remotes & %d Scripts on Clipboard", rCnt, sCnt), 3.5, Theme.Green)
        return rCnt, sCnt
    end

    function setLogbookVisible(v)
        logbookFrame.Visible = v
        if v and cachedDossierText == "" then
            compileGameLogbook()
        end
    end
end



do
    local bhopEnabled = false
    local bhopConn = nil
    local bhopStateConn = nil

    local function doBhopJump()
        local hum = pakMens()
        local root = pakBasis()
        if not hum or not root or hum.Health <= 0 then return end
        if hum.MoveDirection.Magnitude > 0.05 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local pwr = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight * 3.5)
            if pwr <= 0 then pwr = 50 end
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, pwr, root.AssemblyLinearVelocity.Z)
        end
    end

    function zetKonijnenSprong(enabled)
        bhopEnabled = enabled
        bhopConn = veiligOntkoppelen(bhopConn)
        bhopStateConn = veiligOntkoppelen(bhopStateConn)
        if enabled then
            bhopConn = RunService.Heartbeat:Connect(function()
                local hum = pakMens()
                if hum and hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0.05 then
                    doBhopJump()
                end
            end)
            local hum = pakMens()
            if hum then
                bhopStateConn = hum.StateChanged:Connect(function(_, newState)
                    if newState == Enum.HumanoidStateType.Landed then
                        doBhopJump()
                    end
                end)
            end
            melding("B-Hop", "Bunnyhop ON  *  Auto-Jumping", 1.8, Theme.Green)
        else
            melding("B-Hop", "Bunnyhop OFF", 1.5)
        end
    end
end

do
    local infJumpEnabled = false
    local infJumpConn = nil

    function zetOneindigSpringen(enabled)
        infJumpEnabled = enabled
        infJumpConn = veiligOntkoppelen(infJumpConn)
        if enabled then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = pakMens()
                local root = pakBasis()
                if hum and root and hum.Health > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    local pwr = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight * 3.5)
                    if pwr <= 0 then pwr = 50 end
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, pwr, root.AssemblyLinearVelocity.Z)
                end
            end)
            melding("Infinite Jump", "Infinite Jump ON  *  Jump Infinitely in Air", 1.8, Theme.Green)
        else
            melding("Infinite Jump", "Infinite Jump OFF", 1.5)
        end
    end
end

do
    local flightEnabled = false
    flightSpeed = 60
    local flightVel = nil
    local flightAtt = nil
    local flightConn = nil

    function zetVliegen(enabled)
        flightEnabled = enabled
        local root = pakBasis()
        local hum = pakMens()
        if flightVel then flightVel:Destroy(); flightVel = nil end
        if flightAtt then flightAtt:Destroy(); flightAtt = nil end
        flightConn = veiligOntkoppelen(flightConn)
        if hum and not enabled then hum.PlatformStand = false end
        if not enabled or not root or not hum then return end
        hum.PlatformStand = true
        flightAtt = Instance.new("Attachment")
        flightAtt.Parent = root
        flightVel = Instance.new("LinearVelocity")
        flightVel.Attachment0 = flightAtt
        flightVel.MaxForce = math.huge
        flightVel.VectorVelocity = Vector3.zero
        flightVel.RelativeTo = Enum.ActuatorRelativeTo.World
        flightVel.Parent = root
        flightConn = RunService.RenderStepped:Connect(function()
            if not flightEnabled or not flightVel then return end
            local look = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local dir = Vector3.zero
            if keysDown.W then dir = dir + look end
            if keysDown.S then dir = dir - look end
            if keysDown.D then dir = dir + right end
            if keysDown.A then dir = dir - right end
            if keysDown.Space then dir = dir + Vector3.new(0, 1, 0) end
            if keysDown.LeftShift then dir = dir - Vector3.new(0, 1, 0) end
            flightVel.VectorVelocity = dir.Magnitude > 0 and dir.Unit * flightSpeed or Vector3.zero
        end)
    end

    local autoWalkEnabled = false
    local autoWalkConn = nil

    function setAutoWalk(enabled)
        autoWalkEnabled = enabled
        autoWalkConn = veiligOntkoppelen(autoWalkConn)
        if enabled then
            autoWalkConn = RunService.RenderStepped:Connect(function()
                local hum = pakMens()
                if hum and hum.Health > 0 then
                    local x = (keysDown.D and 1 or 0) - (keysDown.A and 1 or 0)
                    local moveVec = Vector3.new(x, 0, -1)
                    if moveVec.Magnitude > 0 then
                        hum:Move(moveVec.Unit, true)
                    end
                end
            end)
            melding("Movement", "Hold W Toggle ON", 1.5, Theme.Green)
        else
            melding("Movement", "Hold W Toggle OFF", 1.5)
        end
    end

    local airStrafeEnabled = false
    local airStrafeConn = nil
    local airStrafeInputConn = nil
    local strafeBoost = 0
    local maxStrafeBoost = 35
    local lastStrafeKey = nil
    local lastSwitchTime = 0

    local function onStrafeKey(key)
        if key == Enum.KeyCode.A or key == Enum.KeyCode.D then
            local now = os.clock()
            if lastStrafeKey and lastStrafeKey ~= key then
                lastSwitchTime = now
            elseif not lastStrafeKey then
                lastSwitchTime = now
            end
            lastStrafeKey = key
        end
    end

    function setAirStrafe(enabled)
        airStrafeEnabled = enabled
        airStrafeConn = veiligOntkoppelen(airStrafeConn)
        airStrafeInputConn = veiligOntkoppelen(airStrafeInputConn)
        strafeBoost = 0
        lastStrafeKey = nil
        lastSwitchTime = 0
        if enabled then
            airStrafeInputConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and (inp.KeyCode == Enum.KeyCode.A or inp.KeyCode == Enum.KeyCode.D) then
                    onStrafeKey(inp.KeyCode)
                end
            end)
            airStrafeConn = RunService.Heartbeat:Connect(function(dt)
                local root = pakBasis()
                local hum = pakMens()
                if not root or not hum or hum.Health <= 0 then
                    strafeBoost = 0
                    return
                end

                local inAir = (hum.FloorMaterial == Enum.Material.Air)
                local isStrafing = inAir and (os.clock() - lastSwitchTime < 1.5) and (keysDown.A or keysDown.D)

                if inAir and isStrafing then
                    strafeBoost = math.clamp(strafeBoost + dt * 18, 0, maxStrafeBoost)
                    local vel = root.AssemblyLinearVelocity
                    local camCF = Camera.CFrame
                    local moveDir = Vector3.zero
                    if keysDown.A then moveDir = moveDir - camCF.RightVector end
                    if keysDown.D then moveDir = moveDir + camCF.RightVector end
                    if keysDown.W or autoWalkEnabled then moveDir = moveDir + camCF.LookVector end
                    if keysDown.S then moveDir = moveDir - camCF.LookVector end
                    moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

                    if moveDir.Magnitude > 0.05 then
                        moveDir = moveDir.Unit
                        local targetHVel = moveDir * (hum.WalkSpeed + strafeBoost)
                        local curHVel = Vector3.new(vel.X, 0, vel.Z)
                        local newHVel = curHVel:Lerp(targetHVel, math.clamp(dt * 7, 0.05, 0.45))

                        local newY = vel.Y
                        if newY < 0 then
                            newY = newY + math.abs(newY) * math.clamp(dt * 3.5, 0.02, 0.28) + dt * 15
                        else
                            newY = newY + dt * 6
                        end
                        root.AssemblyLinearVelocity = Vector3.new(newHVel.X, newY, newHVel.Z)
                    end
                else
                    if strafeBoost > 0 then
                        strafeBoost = math.max(0, strafeBoost - dt * 20)
                    end
                    if not inAir then
                        lastSwitchTime = 0
                        lastStrafeKey = nil
                    end
                end
            end)
            melding("Physics", "Air-Strafing ON", 1.8, Theme.Green)
        else
            melding("Physics", "Air-Strafing OFF", 1.5)
        end
    end

    function setAirStrafeBoost(val)
        maxStrafeBoost = val
    end
end

do
    local customAnimTrack = nil
    local customAnimSpeed = 1
    local customAnimLooped = true

    function playCustomAnimation(inputStr)
        local animId = string.match(tostring(inputStr), "%d+")
        if not animId then
            melding("Animation", "Invalid Link or ID. Paste a valid Roblox ID.", 2, Theme.Red)
            return
        end

        local char = pakKarakter()
        local hum = pakMens()
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not char or not animator then
            melding("Animation", "Character or Animator not found", 2, Theme.Red)
            return
        end

        if customAnimTrack then
            customAnimTrack:Stop()
            customAnimTrack:Destroy()
            customAnimTrack = nil
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId

        local ok, track = pcall(function()
            return animator:LoadAnimation(anim)
        end)

        if ok and track then
            customAnimTrack = track
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = customAnimLooped
            track:Play()
            track:AdjustSpeed(customAnimSpeed)
            melding("Animation", "Playing Anim ID: " .. animId, 2, Theme.Green)
        else
            melding("Animation", "Failed to load animation ID: " .. animId, 2, Theme.Red)
        end
    end

    function stopCustomAnimation()
        if customAnimTrack then
            customAnimTrack:Stop()
            customAnimTrack:Destroy()
            customAnimTrack = nil
            melding("Animation", "Custom Animation Stopped", 1.5)
        end
    end

    function setCustomAnimSpeed(val)
        customAnimSpeed = val
        if customAnimTrack and customAnimTrack.IsPlaying then
            customAnimTrack:AdjustSpeed(val)
        end
    end

    function setCustomAnimLooped(val)
        customAnimLooped = val
        if customAnimTrack then
            customAnimTrack.Looped = val
        end
    end

    local catalogAnimPacks = {
        ["Ninja"] = {idle = "656117400", walk = "656121766", run = "656118341", jump = "656117878", fall = "656115606"},
        ["Zombie"] = {idle = "616158929", walk = "616168032", run = "616163682", jump = "616161997", fall = "616157476"},
        ["Mage"] = {idle = "707742142", walk = "707897766", run = "707861613", jump = "707853694", fall = "707829716"},
        ["Vampire"] = {idle = "1083445855", walk = "1083473930", run = "1083462077", jump = "1083455352", fall = "1083443587"},
        ["Superhero"] = {idle = "616111295", walk = "616122287", run = "616117076", jump = "616115533", fall = "616108001"},
        ["Toy"] = {idle = "782841498", walk = "782845627", run = "782847020", jump = "782843869", fall = "782842708"},
        ["Levitation"] = {idle = "616006778", walk = "616013216", run = "616006778", jump = "616008919", fall = "616005863"},
        ["Jotaro Jojo"] = {idle = "7264878502", walk = "7264879854", run = "7264879854", jump = "656117878", fall = "656115606"},
        ["Crawling Horror"] = {idle = "10921259837", walk = "10921262864", run = "10921262864", jump = "616161997", fall = "616157476"}
    }

    function applyAnimPack(pName)
        local char = pakKarakter()
        local animate = char and char:FindFirstChild("Animate")
        local hum = pakMens()
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        local pack = catalogAnimPacks[pName]
        if not char or not hum or not pack then
            melding("Anims", "Cannot apply pack: Character or Pack not found", 2, Theme.Red)
            return
        end
        if animate then
            for trackType, id in pairs(pack) do
                local folder = animate:FindFirstChild(trackType)
                if folder then
                    for _, child in ipairs(folder:GetChildren()) do
                        if child:IsA("Animation") then
                            child.AnimationId = "rbxassetid://" .. id
                        end
                    end
                end
            end
        end
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0.1)
            end
        end
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        melding("Anims", pName .. " Pack Applied", 2, Theme.Green)
    end
end

do
    local tracersEnabled = false
    local tracersConn = nil
    local tracerLines = {}
    local tracerFolder = Instance.new("Folder")
    tracerFolder.Name = "Tracers"
    tracerFolder.Parent = ScreenGui

    local function clearTracers()
        for _, line in pairs(tracerLines) do
            if line and line.Parent then line:Destroy() end
        end
        tracerLines = {}
    end

    local function drawTracerLine(id, p1, p2, color)
        local line = tracerLines[id]
        if not line or not line.Parent then
            line = Instance.new("Frame")
            line.Name = "Tracer_" .. tostring(id)
            line.BorderSizePixel = 0
            line.ZIndex = 50
            line.Parent = tracerFolder
            tracerLines[id] = line
        end

        local dx = p2.X - p1.X
        local dy = p2.Y - p1.Y
        local dist = math.sqrt(dx * dx + dy * dy)
        local angle = math.deg(math.atan2(dy, dx))

        line.Size = UDim2.new(0, dist, 0, 1.5)
        line.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Rotation = angle
        line.BackgroundColor3 = color or Theme.Accent
        line.BackgroundTransparency = 0.25
        line.Visible = true
    end

    function setTracers(enabled)
        tracersEnabled = enabled
        tracersConn = veiligOntkoppelen(tracersConn)
        clearTracers()
        if enabled then
            tracersConn = RunService.RenderStepped:Connect(function()
                local vp = Camera.ViewportSize
                local origin = Vector2.new(vp.X / 2, vp.Y)
                local seen = {}

                local myChar = pakKarakter()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head") or p.Character.PrimaryPart
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                seen[p.UserId] = true
                                local color = (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team) and Theme.Green or Theme.Accent
                                drawTracerLine(p.UserId, origin, Vector2.new(sp.X, sp.Y), color)
                            end
                        end
                    end
                end

                for _, child in ipairs(workspace:GetChildren()) do
                    if child:IsA("Model") and child ~= myChar and not Players:GetPlayerFromCharacter(child) then
                        local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head") or child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        local hum = child:FindFirstChildOfClass("Humanoid")
                        local hv = child:FindFirstChild("Health") or child:FindFirstChild("HP") or child:GetAttribute("Health")
                        local hasHp = (hum and hum.Health > 0) or (hv and (typeof(hv) == "number" and hv > 0 or (typeof(hv) == "Instance" and hv:IsA("ValueBase") and hv.Value > 0)))
                        if root and hasHp then
                            local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                local id = "NPC_" .. tostring(child:GetFullName())
                                seen[id] = true
                                drawTracerLine(id, origin, Vector2.new(sp.X, sp.Y), Color3.fromRGB(255, 180, 80))
                            end
                        end
                    end
                end

                for id, line in pairs(tracerLines) do
                    if not seen[id] then
                        line.Visible = false
                    end
                end
            end)
            melding("Tracers", "ESP Tracers ON", 1.5, Theme.Accent)
        else
            melding("Tracers", "ESP Tracers OFF", 1.5)
        end
    end

    function setAimNoise(enabled) aimNoiseEnabled = enabled end
    function setAimNoiseIntensity(val) aimNoiseIntensity = val end
end



do
    local keybinds = {
        ToggleUI = Enum.KeyCode.RightShift,
        Fly = Enum.KeyCode.F,
        CursorTP = Enum.KeyCode.T,
        AirWalk = Enum.KeyCode.X
    }
    local listeningKey = nil

    function startRebind(actionName, btn)
        listeningKey = actionName
        btn.Text = "Press any key..."
        local conn = nil
        conn = UserInputService.InputBegan:Connect(function(inp, gpe)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                keybinds[actionName] = inp.KeyCode
                btn.Text = string.format("%s: [%s]", actionName, inp.KeyCode.Name)
                veiligOntkoppelen(conn)
                listeningKey = nil
                melding("Keybind", actionName .. " set to " .. inp.KeyCode.Name, 1.5, Theme.Accent)
            end
        end)
    end

    function getKeybind(actionName)
        return keybinds[actionName]
    end
end

do
    local themeElements = {}

    function registerThemeAccent(obj, prop)
        table.insert(themeElements, {Object = obj, Property = prop})
    end

    function setAccentColor(col, name)
        Theme.Accent = col
        Theme.BorderBright = col
        for _, item in ipairs(themeElements) do
            if item.Object and item.Object.Parent then
                pcall(function() item.Object[item.Property] = col end)
            end
        end
        if topNeonBar then topNeonBar.BackgroundColor3 = col end
        melding("Theme", "Accent set to " .. (name or "Custom"), 1.5, col)
    end
end

do
    local cornerEspEnabled = false
    local cornerEspConn = nil
    local espBoxes = {}
    local espFolder = Instance.new("Folder")
    espFolder.Name = "CornerESP"
    espFolder.Parent = ScreenGui

    local function clearCornerEsp()
        for _, box in pairs(espBoxes) do
            if box.Container and box.Container.Parent then box.Container:Destroy() end
        end
        espBoxes = {}
    end

    local function createBoxGui(id)
        local c = Instance.new("Frame")
        c.Name = "Box_" .. tostring(id)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ZIndex = 40
        c.Parent = espFolder

        local lines = {}
        for i = 1, 8 do
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Theme.Accent
            f.ZIndex = 41
            f.Parent = c
            lines[i] = f
        end

        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(0, 3, 1, 0)
        hpBg.Position = UDim2.new(0, -6, 0, 0)
        hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        hpBg.BorderSizePixel = 0
        hpBg.ZIndex = 41
        hpBg.Parent = c

        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.Position = UDim2.new(0, 0, 1, 0)
        hpFill.AnchorPoint = Vector2.new(0, 1)
        hpFill.BackgroundColor3 = Theme.Green
        hpFill.BorderSizePixel = 0
        hpFill.ZIndex = 42
        hpFill.Parent = hpBg

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, 0, 0, 14)
        distLbl.Position = UDim2.new(0, 0, 1, 3)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3 = Theme.TextPrimary
        distLbl.Font = Enum.Font.Gotham
        distLbl.TextSize = 9
        distLbl.ZIndex = 42
        distLbl.Parent = c

        local boxData = {Container = c, Lines = lines, HpFill = hpFill, DistLabel = distLbl}
        espBoxes[id] = boxData
        return boxData
    end

    local function updateCornerLines(lines, w, h, col)
        local t = 1.5
        local s = math.clamp(w * 0.28, 4, 14)

        lines[1].Size = UDim2.new(0, s, 0, t)
        lines[1].Position = UDim2.new(0, 0, 0, 0)
        lines[2].Size = UDim2.new(0, t, 0, s)
        lines[2].Position = UDim2.new(0, 0, 0, 0)

        lines[3].Size = UDim2.new(0, s, 0, t)
        lines[3].Position = UDim2.new(1, -s, 0, 0)
        lines[4].Size = UDim2.new(0, t, 0, s)
        lines[4].Position = UDim2.new(1, -t, 0, 0)

        lines[5].Size = UDim2.new(0, s, 0, t)
        lines[5].Position = UDim2.new(0, 0, 1, -t)
        lines[6].Size = UDim2.new(0, t, 0, s)
        lines[6].Position = UDim2.new(0, 0, 1, -s)

        lines[7].Size = UDim2.new(0, s, 0, t)
        lines[7].Position = UDim2.new(1, -s, 1, -t)
        lines[8].Size = UDim2.new(0, t, 0, s)
        lines[8].Position = UDim2.new(1, -t, 1, -s)

        for i = 1, 8 do lines[i].BackgroundColor3 = col end
    end

    function setCornerEsp(enabled)
        cornerEspEnabled = enabled
        cornerEspConn = veiligOntkoppelen(cornerEspConn)
        clearCornerEsp()
        if enabled then
            cornerEspConn = RunService.RenderStepped:Connect(function()
                local seen = {}
                local myRoot = pakBasis()

                local myChar = pakKarakter()
                local function processCornerEntity(char, id, name, isPlayer, teamMatch)
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local curHp, maxHp = nil, nil
                    if hum and hum.Health > 0 then
                        curHp = hum.Health
                        maxHp = hum.MaxHealth
                    else
                        local hv = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:GetAttribute("Health")
                        if hv and typeof(hv) == "Instance" and hv:IsA("ValueBase") and hv.Value > 0 then
                            curHp = hv.Value
                            maxHp = (char:FindFirstChild("MaxHealth") and char.MaxHealth.Value) or 100
                        elseif typeof(hv) == "number" and hv > 0 then
                            curHp = hv
                            maxHp = char:GetAttribute("MaxHealth") or 100
                        end
                    end

                    if root and curHp then
                        local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            seen[id] = true
                            local topPoint = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
                            local btmPoint = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
                            local h = math.abs(btmPoint.Y - topPoint.Y)
                            local w = h * 0.65

                            local box = espBoxes[id] or createBoxGui(id)
                            box.Container.Visible = true
                            box.Container.Size = UDim2.new(0, w, 0, h)
                            box.Container.Position = UDim2.new(0, sp.X - w / 2, 0, topPoint.Y)

                            local col = isPlayer and (teamMatch and Theme.Green or Theme.Accent) or Color3.fromRGB(255, 180, 80)
                            updateCornerLines(box.Lines, w, h, col)

                            local hpRatio = math.clamp(curHp / math.max(maxHp, 1), 0, 1)
                            box.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
                            box.HpFill.BackgroundColor3 = Color3.fromRGB(math.floor((1 - hpRatio) * 240), math.floor(hpRatio * 220 + 20), 40)

                            if myRoot then
                                local dist = math.round((myRoot.Position - root.Position).Magnitude)
                                box.DistLabel.Text = string.format("%s [%dm]", name, dist)
                            end
                        end
                    end
                end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local teamMatch = (teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team)
                        processCornerEntity(p.Character, tostring(p.UserId), p.Name, true, teamMatch)
                    end
                end

                for _, child in ipairs(workspace:GetChildren()) do
                    if child:IsA("Model") and child ~= myChar and not Players:GetPlayerFromCharacter(child) then
                        local id = "NPC_" .. tostring(child:GetFullName())
                        processCornerEntity(child, id, child.Name, false, false)
                    end
                end

                for id, box in pairs(espBoxes) do
                    if not seen[id] then box.Container.Visible = false end
                end
            end)
            melding("ESP", "2D Corner Box ESP ON", 1.5, Theme.Accent)
        else
            melding("ESP", "Corner Box ESP OFF", 1.5)
        end
    end
end


-- alles uitzetten en resetten
local function herstelAlles()
    setAirStrafe(false)
    setAutoWalk(false)
    setStickyLock(true)
    setTargetNpcs(false)
    setCornerEsp(false)
    setTracers(false)
    stopCustomAnimation()
    zetKonijnenSprong(false)
    setAudioSonar(false)
    setRemoteSpam(false)
    zetInteractieAura(false)
    zetAanraakMagneet(false)
    zetAntiSlinger(false)
    zetVrijeCamera(false)
    zetBouwGereedschap(false)
    zetAntiLappenpop(false)
    zetOneindigUithoudingsvermogen(false)
    zetAntiLeegte(false)
    zetSpinnenLoop(false)
    zetGeestDesync(false)
    zetDoelHulp(false)
    setAutoShot(false)
    setHitboxExpander(false)
    zetGodModus(false)
    setSpeedBoost(false)
    zetDoorMuren(false)
    zetLuchtLopen(false)
    setGhostMode(false)
    zetZaklamp(false)
    zetEntiteitRadar(false)
    setItemRadar(false)
    zetChatSpion(false)
    zetHelderZicht(false)
    zetAanraakSchild(false)
    zetValBescherming(false)
    zetDoodsSchild(false)
    zetDirecteInteractie(false)
    zetOneindigInzoomen(false)
    zetRaakvlakVerplaatsen(false)
    setUnlockFirstPerson(false)
    setAutoClearAttributes(false)
    zetHoogtepunten(false)
    setFullbright(false)
    zetVliegen(false)
    zetOneindigSpringen(false)
    zetNachtZicht(false)
    zetDagNachtCyclus(false)
    zetCameraSchudden(false)
    zetHoofdDeinzen(false)
    zetSnelheidsLijnen(false)
    zetNaamKaartjes(false)
    zetGezondheidsBalken(false)
    zetAfstandsKaartjes(false)
    zetTerugslag(false)
    setFPSHud(false)
    setOverheadFlex(false)
    workspace.Gravity = 196
    Camera.FieldOfView = 70
    CrosshairFrame.Visible = false
    FovCircle.Visible = false
    if fcStroke then fcStroke.Color = Theme.Accent end
    melding("System", "All features reset to defaults", 2.5, Theme.Red)
end

-- combat tab vullen

do
    local noRecoilEnabled = false
    local noRecoilConn = nil
    local wallbangEnabled = false
    local silentAimEnabled = false
    local speedSpoofEnabled = false
    local antiKickEnabled = false
    local stealthModeEnabled = false

    local oldUnifiedNamecall = nil
    local oldUnifiedIndex = nil

    local function checkHookCapability()
        local ok1 = pcall(function() return typeof(hookfunction) == "function" end)
        local ok2 = pcall(function() return typeof(hookmetamethod) == "function" end)
        return (ok1 and hookfunction) or (ok2 and hookmetamethod)
    end

    local function neutralizeAdonis()
        if not getgc then return false end
        local count = 0
        pcall(function()
            for _, tbl in ipairs(getgc(true)) do
                if typeof(tbl) == "table" then
                    local hasDetector = rawget(tbl, "namecallInstance")
                    if hasDetector and typeof(hasDetector) == "table" then
                        pcall(function()
                            if setreadonly then setreadonly(tbl, false) end
                            if make_writeable then make_writeable(tbl) end
                            for k, det in pairs(tbl) do
                                if typeof(det) == "table" and typeof(det[2]) == "function" then
                                    pcall(function()
                                        if setreadonly then setreadonly(det, false) end
                                        if make_writeable then make_writeable(det) end
                                        det[2] = function() return false end
                                        count = count + 1
                                    end)
                                end
                            end
                        end)
                    end
                end
            end
        end)
        return count > 0
    end

    local function isCharacterOrDamageable(hitPart)
        if not hitPart or not hitPart.Parent then return false, nil end
        local myChar = pakKarakter()
        if myChar and hitPart:IsDescendantOf(myChar) then return false, nil end

        -- Fast player character check
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and hitPart:IsDescendantOf(p.Character) then
                if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                    return false, nil
                end
                return true, p.Character
            end
        end

        local cur = hitPart
        local foundModel = nil
        for _ = 1, 6 do
            if not cur or cur == workspace or cur == game then break end
            if cur:IsA("Model") then
                local p = Players:GetPlayerFromCharacter(cur)
                if p and p ~= LocalPlayer then
                    if teamCheck and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                        return false, nil
                    end
                    return true, cur
                end
                local hum = cur:FindFirstChildOfClass("Humanoid")
                if hum and cur ~= myChar then
                    return true, cur
                end
                local hv = cur:FindFirstChild("Health") or cur:FindFirstChild("HP") or cur:GetAttribute("Health") or cur:GetAttribute("HP")
                if hv then return true, cur end

                local cName = string.lower(cur.Name)
                if string.find(cName, "npc") or string.find(cName, "enem") or string.find(cName, "zomb")
                    or string.find(cName, "bot") or string.find(cName, "monster") or string.find(cName, "dummy")
                    or string.find(cName, "ragdoll") or string.find(cName, "creature") or string.find(cName, "player")
                    or string.find(cName, "char") or string.find(cName, "alive") then
                    return true, cur
                end
                foundModel = cur
            end
            cur = cur.Parent
        end

        local pName = hitPart.Name
        local lowerName = string.lower(pName)
        if pName == "Head" or pName == "Torso" or pName == "UpperTorso" or pName == "LowerTorso"
            or pName == "HumanoidRootPart" or pName == "LeftArm" or pName == "RightArm"
            or pName == "LeftLeg" or pName == "RightLeg" or string.find(lowerName, "arm")
            or string.find(lowerName, "leg") or string.find(lowerName, "hand") or string.find(lowerName, "foot")
            or string.find(lowerName, "hitbox") or string.find(lowerName, "body") or string.find(lowerName, "chest")
            or string.find(lowerName, "root") or string.find(lowerName, "collider") or string.find(lowerName, "limb") then
            return true, foundModel or hitPart.Parent
        end

        -- In Roblox FPS games, characters and hitboxes are almost always unanchored!
        if hitPart:IsA("BasePart") and hitPart.Anchored == false and not hitPart:IsDescendantOf(workspace.CurrentCamera) then
            if not hitPart.Name:lower():find("debris") and not hitPart.Name:lower():find("casing") then
                return true, foundModel or hitPart.Parent
            end
        end

        return false, nil
    end

    local function isWall(hitPart)
        if not hitPart or not hitPart:IsA("BasePart") then return false end
        if isCharacterOrDamageable(hitPart) then return false end
        if hitPart.Anchored == true then return true end
        local m = hitPart:FindFirstAncestorOfClass("Model")
        if not m or (not m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m)) then
            local nl = hitPart.Name:lower()
            if nl:find("wall") or nl:find("floor") or nl:find("door") or nl:find("glass") or nl:find("map") or nl:find("ground") or nl:find("building") or nl:find("terrain") then
                return true
            end
        end
        return false
    end

    local function isWeaponRay(origin, direction)
        if not origin or not direction then return false end
        if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return false end
        local mag = direction.Magnitude

        -- FastCast simulation step rays are short (typically 5 to 30 studs).
        -- Weapon crosshair aim rays and hitscan shots are long (>= 75 studs).
        -- Leaving short rays untouched prevents FastCast projectiles from terminating on Frame 1!
        if mag < 75 then return false end

        if getcallingscript then
            local scr = getcallingscript()
            if scr then
                local sn = string.lower(scr.Name)
                if sn:find("camera") or sn:find("cam") or sn:find("popper") or sn:find("zoom")
                    or sn:find("transparency") or sn:find("playermodule") or sn:find("control")
                    or sn:find("mouselock") or sn:find("input") or sn:find("freecam") then
                    return false
                end
            end
        end

        local cam = Camera or workspace.CurrentCamera
        if not cam then return false end
        local camPos = cam.CFrame.Position
        local char = pakKarakter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local rootPos = root and root.Position

        local nearCam = (origin - camPos).Magnitude <= 30
        local nearChar = rootPos and (origin - rootPos).Magnitude <= 30
        if not nearCam and not nearChar then return false end

        local camLook = cam.CFrame.LookVector
        if direction.Unit:Dot(camLook) < 0.2 then
            return false
        end

        return true
    end

    local function setupUnifiedNamecall()
        neutralizeAdonis()
        if oldUnifiedNamecall or typeof(hookmetamethod) ~= "function" then return end
        pcall(function()
            oldUnifiedNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if checkcaller and checkcaller() then
                    return oldUnifiedNamecall(self, ...)
                end

                local method = getnamecallmethod and getnamecallmethod()
                if method == "____________" then return oldUnifiedNamecall(self, ...) end

                if stealthModeEnabled then
                    return oldUnifiedNamecall(self, ...)
                end

                if (method == "Raycast" or method == "raycast") and self == workspace then
                    local origin, direction, params = ...
                    if isWeaponRay(origin, direction) then
                        local target = (silentAimEnabled or wallbangEnabled) and vindDichtsteVijand() or nil
                        local dirMag = (direction and direction.Magnitude) or 2000
                        local finalDirection = direction

                        if target and silentAimEnabled then
                            local aimDir = (target.Position - origin).Unit
                            finalDirection = aimDir * math.max(dirMag, (target.Position - origin).Magnitude + 50)
                        end

                        -- Standard Silent Aim: pass the game's original RaycastParams completely untouched!
                        if not wallbangEnabled then
                            return oldUnifiedNamecall(self, origin, finalDirection, params)
                        end

                        -- Wallbang penetration mode
                        local excludedInstances = {}
                        local myChar = pakKarakter()
                        if myChar then table.insert(excludedInstances, myChar) end

                        if params and params.FilterDescendantsInstances then
                            for _, inst in ipairs(params.FilterDescendantsInstances) do
                                table.insert(excludedInstances, inst)
                            end
                        end

                        local penParams = RaycastParams.new()
                        penParams.FilterType = Enum.RaycastFilterType.Exclude
                        penParams.IgnoreWater = (params and params.IgnoreWater ~= nil) and params.IgnoreWater or true
                        if params and params.CollisionGroup then
                            pcall(function() penParams.CollisionGroup = params.CollisionGroup end)
                        end

                        local maxSteps = 5
                        local firstWallHit = nil

                        for step = 1, maxSteps do
                            penParams.FilterDescendantsInstances = excludedInstances
                            local res = oldUnifiedNamecall(self, origin, finalDirection, penParams)
                            if not res then break end

                            if not firstWallHit then firstWallHit = res end

                            if isCharacterOrDamageable(res.Instance) then
                                return res
                            end

                            if isWall(res.Instance) then
                                table.insert(excludedInstances, res.Instance)
                            else
                                return res
                            end
                        end

                        return firstWallHit
                    end
                end

                if (method == "FindPartOnRay" or method == "findPartOnRay"
                    or method == "FindPartOnRayWithIgnoreList" or method == "findPartOnRayWithIgnoreList"
                    or method == "FindPartOnRayWithWhitelist" or method == "findPartOnRayWithWhitelist")
                    and self == workspace then
                    local ray, ignoreList, terrainAsCubes, ignoreWater = ...
                    if ray and typeof(ray) == "Ray" and isWeaponRay(ray.Origin, ray.Direction) then
                        local target = (silentAimEnabled or wallbangEnabled) and vindDichtsteVijand() or nil
                        local finalRay = ray
                        if target and silentAimEnabled then
                            local aimDir = (target.Position - ray.Origin).Unit
                            finalRay = Ray.new(ray.Origin, aimDir * math.max(ray.Direction.Magnitude, (target.Position - ray.Origin).Magnitude + 50))
                        end

                        if not wallbangEnabled then
                            return oldUnifiedNamecall(self, finalRay, ignoreList, terrainAsCubes, ignoreWater)
                        end

                        local currentIgnore = {}
                        if typeof(ignoreList) == "table" then
                            for _, itm in ipairs(ignoreList) do table.insert(currentIgnore, itm) end
                        elseif typeof(ignoreList) == "Instance" then
                            table.insert(currentIgnore, ignoreList)
                        end
                        local myChar = pakKarakter()
                        if myChar then table.insert(currentIgnore, myChar) end

                        local firstPartHit, firstPos, firstNorm, firstMat = nil, nil, nil, nil
                        for step = 1, 5 do
                            local p, pos, n, m = oldUnifiedNamecall(self, finalRay, currentIgnore, terrainAsCubes, ignoreWater)
                            if not p then break end
                            if not firstPartHit then
                                firstPartHit, firstPos, firstNorm, firstMat = p, pos, n, m
                            end
                            if isCharacterOrDamageable(p) then
                                return p, pos, n, m
                            end
                            if isWall(p) then
                                table.insert(currentIgnore, p)
                            else
                                return p, pos, n, m
                            end
                        end
                        if firstPartHit then return firstPartHit, firstPos, firstNorm, firstMat end
                    end
                end

                if (method == "FireServer" or method == "fireServer") and silentAimEnabled and self:IsA("RemoteEvent") then
                    local target = vindDichtsteVijand()
                    if target then
                        local sName = string.lower(self.Name)
                        local isWeaponRemote = sName:find("shoot") or sName:find("fire") or sName:find("hit")
                            or sName:find("damage") or sName:find("bullet") or sName:find("gun") or sName:find("attack")
                            or sName:find("cast") or sName:find("weapon")

                        if isWeaponRemote then
                            local args = {...}
                            local modified = false
                            local cam = Camera or workspace.CurrentCamera
                            local camPos = cam and cam.CFrame.Position
                            local myChar = pakKarakter()
                            local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
                            local rootPos = root and root.Position

                            -- Preserve muzzle origin so bullet spawns cleanly at the gun barrel
                            local muzzleOrigin = nil
                            for i, arg in ipairs(args) do
                                if typeof(arg) == "Vector3" then
                                    local nearCam = camPos and (arg - camPos).Magnitude <= 15
                                    local nearRoot = rootPos and (arg - rootPos).Magnitude <= 15
                                    if (nearCam or nearRoot) and not muzzleOrigin then
                                        -- Found the weapon muzzle origin: NEVER OVERWRITE IT!
                                        muzzleOrigin = arg
                                    elseif muzzleOrigin then
                                        -- Vector that follows the origin is the aim direction or hit target
                                        if arg.Magnitude <= 2 then
                                            -- Direction vector: recalculate towards target
                                            args[i] = (target.Position - muzzleOrigin).Unit
                                            modified = true
                                        else
                                            -- World position target
                                            args[i] = target.Position
                                            modified = true
                                        end
                                    end
                                elseif typeof(arg) == "Instance" and (arg:IsA("BasePart") or arg:IsA("Model")) then
                                    if not (myChar and arg:IsDescendantOf(myChar)) then
                                        args[i] = target
                                        modified = true
                                    end
                                elseif typeof(arg) == "table" then
                                    pcall(function()
                                        if rawget(arg, "Instance") or rawget(arg, "Part") then
                                            if arg.Instance then arg.Instance = target end
                                            if arg.Part then arg.Part = target end
                                            modified = true
                                        end
                                        if rawget(arg, "Hit") or rawget(arg, "Position") then
                                            if arg.Hit then arg.Hit = target.Position end
                                            if arg.Position then arg.Position = target.Position end
                                            modified = true
                                        end
                                    end)
                                end
                            end

                            if modified then
                                return oldUnifiedNamecall(self, unpack(args))
                            end
                        end
                    end
                end

                if (method == "Kick" or method == "kick") and self == LocalPlayer and antiKickEnabled then
                    local args = {...}
                    local reason = tostring(args[1] or "Blocked")
                    melding("Anti-Kick", "Blocked kick attempt: " .. reason, 4, Theme.Red)
                    return nil
                end

                return oldUnifiedNamecall(self, ...)
            end))
        end)
    end

    local function setupUnifiedIndex()
        if oldUnifiedIndex or typeof(hookmetamethod) ~= "function" then return end
        pcall(function()
            oldUnifiedIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if checkcaller and checkcaller() then
                    return oldUnifiedIndex(self, key)
                end
                if stealthModeEnabled then
                    return oldUnifiedIndex(self, key)
                end
                if speedSpoofEnabled and typeof(self) == "Instance" and self:IsA("Humanoid") then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                    if key == "JumpHeight" then return 7.2 end
                end
                return oldUnifiedIndex(self, key)
            end))
        end)
    end

    function setStealthMode(enabled)
        stealthModeEnabled = enabled
        melding("Stealth", enabled and "Pure Client Stealth Mode ACTIVE (0 Metatable Hooks)" or "Standard Mode ACTIVE", 2, enabled and Theme.Green or Theme.AccentDim)
    end

    function setSilentAim(enabled)
        silentAimEnabled = enabled
        if not enabled then
            melding("Combat", "Silent Aim OFF", 1.5)
            return
        end

        if not stealthModeEnabled and checkHookCapability() then
            setupUnifiedNamecall()
            if oldUnifiedNamecall then
                melding("Combat", "Stealth Silent Aim ACTIVE", 2, Theme.Green)
                return
            end
        end

        -- Silent aim must never manipulate or lock the player camera
        melding("Combat", "Silent Aim ACTIVE (Raycast Engine)", 2, Theme.Green)
    end

    function setSpeedSpoof(enabled)
        speedSpoofEnabled = enabled
        if not enabled then
            melding("Physics", "Speed Spoof OFF", 1.5)
            return
        end

        if not stealthModeEnabled and checkHookCapability() then
            setupUnifiedIndex()
            if oldUnifiedIndex then
                melding("Physics", "Stealth Speed Spoof ACTIVE (Anticheats see 16/50)", 2, Theme.Green)
                return
            end
        end

        melding("Physics", "Speed Spoof requires Metamethod hook support", 3, Theme.Yellow)
    end

    function setAntiKick(enabled)
        antiKickEnabled = enabled
        if not enabled then
            melding("System", "Anti-Kick OFF", 1.5)
            return
        end

        if not stealthModeEnabled and checkHookCapability() then
            setupUnifiedNamecall()
            pcall(function()
                if typeof(hookfunction) == "function" and LocalPlayer and LocalPlayer.Kick then
                    hookfunction(LocalPlayer.Kick, newcclosure(function(self, ...)
                        if checkcaller and checkcaller() then return end
                        if antiKickEnabled and self == LocalPlayer then
                            local args = {...}
                            local reason = tostring(args[1] or "Blocked")
                            melding("Anti-Kick", "Blocked kick attempt: " .. reason, 4, Theme.Red)
                            return nil
                        end
                    end))
                end
            end)
            melding("System", "Stealth Anti-Kick ACTIVE", 2, Theme.Green)
            return
        end

        melding("System", "Anti-Kick Passive Guard Active", 2, Theme.AccentDim)
    end

    function setNoRecoil(enabled)
        noRecoilEnabled = enabled
        noRecoilConn = veiligOntkoppelen(noRecoilConn)
        if not enabled then
            melding("Combat", "No Recoil OFF", 1.5)
            return
        end

        melding("Combat", "No-Recoil ACTIVE", 2, Theme.Green)
    end

    function setWallbang(enabled)
        wallbangEnabled = enabled
        if not enabled then
            wallCheck = true
            melding("Combat", "Wallbang OFF", 1.5)
            return
        end

        if not stealthModeEnabled and checkHookCapability() then
            setupUnifiedNamecall()
            if oldUnifiedNamecall then
                wallCheck = false
                melding("Combat", "Stealth Wallbang ACTIVE", 2, Theme.Green)
                return
            end
        end

        -- Client fallback: bypass LOS wall check
        wallCheck = false
        melding("Combat", "Client Wallbang (LOS Bypass) ACTIVE", 2, Theme.Green)
    end
end

local CombatTab = maakTab("Combat")
CombatTab:AddSection("Target Lock  [ Hold RMB ]")
CombatTab:AddToggle("Stealth Mode (Zero-Hook)", false, function(v) setStealthMode(v) end)
CombatTab:AddToggle("Aimlock", false, function(v) zetDoelHulp(v); melding("Combat", v and "Hold RMB to lock nearest target" or "Target Lock OFF", 2) end)
CombatTab:AddToggle("Silent Aim", false, function(v) setSilentAim(v) end)
CombatTab:AddToggle("Fast Snap Glide", false, function(v) aimSnap = v; melding("Combat", v and "Snap Glide ON" or "Smooth Lock ON", 1.5) end)
CombatTab:AddToggle("Target NPCs & Monsters", false, function(v) setTargetNpcs(v) end)
CombatTab:AddToggle("Sticky Target Lock", true, function(v) setStickyLock(v) end)


CombatTab:AddToggle("Predictive Lead Aim", false, function(v) aimLeadEnabled = v; melding("Combat", v and "Lead Prediction ON" or "Lead Prediction OFF", 1.5) end)
CombatTab:AddSlider("Lead Prediction (ms)", 0, 300, 120, function(v) aimLeadFactor = v / 1000 end)
CombatTab:AddToggle("Humanized Aim", false, function(v) setAimNoise(v) end)
CombatTab:AddSlider("Aim Noise Intensity", 1, 20, 10, function(v) setAimNoiseIntensity(v / 10) end)
CombatTab:AddSlider("Glide Speed (%)", 2, 40, 12, function(v) glideSpeed = v / 100 end)
CombatTab:AddToggle("Wall Check", true, function(v) wallCheck = v end)
CombatTab:AddToggle("Wallbang", false, function(v) setWallbang(v) end)
CombatTab:AddToggle("Team Check", false, function(v) teamCheck = v end)
CombatTab:AddToggle("Draw FOV Circle", false, function(v) FovCircle.Visible = v end)
CombatTab:AddSlider("FOV Radius (px)", 40, 700, 300, function(v) aimRange = v; FovCircle.Size = UDim2.new(0, v*2, 0, v*2) end)

CombatTab:AddSection("Auto Fire")
CombatTab:AddToggle("Triggerbot", false, function(v) setAutoShot(v); melding("Combat", v and "Auto Shot ON" or "Auto Shot OFF", 1.5) end)
CombatTab:AddSlider("Shot Delay (ms)", 60, 350, 140, function(v) autoShotDelay = v / 1000 end)

CombatTab:AddSection("Hitbox Manipulation")
CombatTab:AddToggle("Hitbox", false, function(v) setHitboxExpander(v); melding("Combat", v and "Hitboxes Expanded" or "Hitboxes Normal", 1.5) end)
CombatTab:AddSlider("Hitbox Size (studs)", 4, 30, 10, function(v) hitboxSize = v; updateHitboxSizes() end)

CombatTab:AddSection("Camera & Feedback")
CombatTab:AddToggle("No Recoil", false, function(v) setNoRecoil(v) end)
CombatTab:AddToggle("Recoil", false, function(v) zetTerugslag(v) end)
CombatTab:AddButton("Trigger Recoil Kick", function() schietTerugslag() end)
CombatTab:AddSlider("Recoil Intensity", 1, 20, 5, function(v) recoilIntensity = v end)
CombatTab:AddToggle("Camera Shake", false, function(v) zetCameraSchudden(v) end)
CombatTab:AddSlider("Shake Intensity", 1, 12, 3, function(v) cameraShakeIntensity = v end)
CombatTab:AddButton("Fire Test Bullet Tracer", function() maakKogelSpoor() end)
CombatTab:AddToggle("Crosshair", false, function(v) CrosshairFrame.Visible = v end)
CombatTab:AddSlider("Camera FOV", 40, 120, 70, function(v) Camera.FieldOfView = v end)

-- teleport tab
local TeleportTab = maakTab("Teleport")
TeleportTab:AddSection("Movement")
TeleportTab:AddButton("Teleport to Cursor [T]", function() teleporteerMuis() end)
TeleportTab:AddSection("Player Teleport")
TeleportTab:AddButton("Teleport to Nearest Player", function() teleporteerDichtste() end)
TeleportTab:AddButton("Teleport to Random Player", function() teleporteerWillekeurig() end)
TeleportTab:AddButton("Cycle Next Player", function() volgendeSpelerTeleport() end)

TeleportTab:AddSection("Waypoints [3 Slots]")
for _, slot in ipairs({"A", "B", "C"}) do
    TeleportTab:AddButton("Save Waypoint " .. slot, function()
        local root = pakBasis()
        if root then
            savedWaypoints[slot] = root.CFrame
            melding("Waypoint", "Slot " .. slot .. " saved", 1.5, Theme.Green)
        end
    end)
    TeleportTab:AddButton("Go to Waypoint " .. slot, function()
        local root = pakBasis()
        if root and savedWaypoints[slot] then
            root.CFrame = savedWaypoints[slot]
            melding("Waypoint", "Teleported to " .. slot, 1.5)
        else
            melding("Waypoint", "Slot " .. slot .. " not saved yet", 1.5, Theme.Red)
        end
    end)
end

-- esp en visuals
local VisualsTab = maakTab("Visuals")
VisualsTab:AddSection("World Rendering")
VisualsTab:AddToggle("Player ESP", false, function(v) zetHoogtepunten(v); melding("Visuals", v and "Highlights ON" or "Highlights OFF", 1.5) end)
VisualsTab:AddToggle("Player ESP Tracers", false, function(v) setTracers(v) end)
VisualsTab:AddToggle("2D Corner Box ESP", false, function(v) setCornerEsp(v) end)
VisualsTab:AddToggle("Fullbright", false, function(v) setFullbright(v); melding("Visuals", v and "Fullbright ON" or "Fullbright OFF", 1.5) end)
VisualsTab:AddToggle("Night Vision", false, function(v) zetNachtZicht(v) end)
VisualsTab:AddToggle("Auto Day/Night Cycle", false, function(v) zetDagNachtCyclus(v) end)
VisualsTab:AddSlider("Time of Day", 0, 24, 14, function(v) Lighting.ClockTime = v end)
VisualsTab:AddSlider("Fog End Distance", 100, 6000, 2000, function(v) Lighting.FogEnd = v; Lighting.FogStart = v * 0.3 end)

VisualsTab:AddSection("Character Effects")
VisualsTab:AddToggle("Ghost Mode", false, function(v) setGhostMode(v); melding("Visuals", v and "Ghost Mode ON" or "Ghost Mode OFF", 1.5) end)
VisualsTab:AddToggle("Head Bob", false, function(v) zetHoofdDeinzen(v) end)
VisualsTab:AddToggle("Speed Lines", false, function(v) zetSnelheidsLijnen(v) end)

local PlayersTab = maakTab("Players")
PlayersTab:AddSection("Chat Intelligence")
PlayersTab:AddToggle("Chat Spy", false, function(v) zetChatSpion(v) end)
PlayersTab:AddToggle("Show Chat Spy Window", false, function(v) setChatLogVisible(v) end)
PlayersTab:AddButton("Copy All Logs to Clipboard", function() dumpAlleChatLogs() end)
PlayersTab:AddButton("View Last Spied Chat", function() melding("ChatSpy", haalLaatsteChat(), 4, Color3.fromRGB(255, 220, 90)) end)
PlayersTab:AddSection("Player Indicators")
PlayersTab:AddToggle("Name Tags", false, function(v) zetNaamKaartjes(v); melding("Players", v and "Name Tags ON" or "Name Tags OFF", 1.5) end)
PlayersTab:AddToggle("Health Bars", false, function(v) zetGezondheidsBalken(v); melding("Players", v and "Health Bars ON" or "Health Bars OFF", 1.5) end)
PlayersTab:AddToggle("Distance Indicators", false, function(v) zetAfstandsKaartjes(v) end)

local AnimsTab = maakTab("Anims")
AnimsTab:AddSection("Custom Animation Link & Asset Loader")
local animCustomText = ""
AnimsTab:AddBox("Animation Asset ID", "", "Paste Catalog URL or Asset ID...", function(str)
    animCustomText = str
end)

AnimsTab:AddButton("Load & Play Animation", function()
    if animCustomText ~= "" then
        playCustomAnimation(animCustomText)
    else
        melding("Animation", "Please enter a URL or Asset ID first", 1.8, Theme.Red)
    end
end)
AnimsTab:AddButton("Stop Animation", function() stopCustomAnimation() end)
AnimsTab:AddSlider("Playback Speed (x100)", 10, 300, 100, function(v) setCustomAnimSpeed(v / 100) end)
AnimsTab:AddToggle("Loop Animation", true, function(v) setCustomAnimLooped(v) end)

AnimsTab:AddSection("Avatar Rig Control")
AnimsTab:AddToggle("Force R15 Rig", false, function(v) setForceR15(v) end)
AnimsTab:AddSection("UGC Animation Packs")
AnimsTab:AddButton("Jotaro Jojo Pack", function() applyAnimPack("Jotaro Jojo") end)
AnimsTab:AddButton("Crawling Horror Pack", function() applyAnimPack("Crawling Horror") end)
AnimsTab:AddSection("Universal Catalog Packs")
for _, pName in ipairs({"Ninja", "Mage", "Vampire", "Superhero", "Zombie", "Toy", "Levitation"}) do
    AnimsTab:AddButton(pName .. " Pack", function() applyAnimPack(pName) end)
end
AnimsTab:AddSection("Controls")
AnimsTab:AddButton("Stop Animations", function() stopAllAnimations(); melding("Animations", "Animations stopped", 1.5) end)

-- natuurkunde hacks
local PhysicsTab = maakTab("Physics")

PhysicsTab:AddSection("Locomotion & Speed")
PhysicsTab:AddToggle("Speed Boost", false, function(v)
    setSpeedBoost(v)
    melding("Physics", v and ("Speed locked to " .. customWalkSpeed) or "Speed default", 1.5)
end)
PhysicsTab:AddSlider("Walk Speed", 16, 350, 16, function(v)
    customWalkSpeed = v
    local hum = pakMens()
    if hum then hum.WalkSpeed = v end
end)
PhysicsTab:AddSlider("Jump Power", 20, 350, 50, function(v)
    local hum = pakMens()
    if hum then
        if hum.UseJumpPower then hum.JumpPower = v else hum.JumpHeight = v / 7.2 end
    end
end)
PhysicsTab:AddSlider("Workspace Gravity", 0, 400, 196, function(v)
    workspace.Gravity = v
end)
PhysicsTab:AddToggle("Infinite Jump", false, function(v)
    zetOneindigSpringen(v)
    melding("Physics", v and "Infinite Jump ON" or "Infinite Jump OFF", 1.5)
end)
PhysicsTab:AddToggle("Noclip", false, function(v)
    zetDoorMuren(v)
    melding("Physics", v and "Noclip ON" or "Noclip OFF", 1.5)
end)
PhysicsTab:AddToggle("Bunnyhop", false, function(v)
    zetKonijnenSprong(v)
end)
PhysicsTab:AddToggle("Air Walk", false, function(v)
    zetLuchtLopen(v)
    melding("Physics", v and "Air Walk ON" or "Air Walk OFF", 1.5)
end)
PhysicsTab:AddButton("Respawn Character", function()
    local hum = pakMens()
    if hum then hum.Health = 0 end
end)

PhysicsTab:AddSection("Flight & Aerial Control")
PhysicsTab:AddToggle("Creative Flight", false, function(v)
    zetVliegen(v)
    melding("Physics", v and "Flight ON" or "Flight OFF", 1.5)
end)
PhysicsTab:AddSlider("Flight Speed", 10, 350, 60, function(v)
    flightSpeed = v
end)
PhysicsTab:AddToggle("Anti-Detection Speed Spoof", false, function(v)
    setSpeedSpoof(v)
end)
PhysicsTab:AddToggle("Air-Strafing", false, function(v)
    setAirStrafe(v)
end)
PhysicsTab:AddSlider("Air-Strafe Max Boost", 10, 80, 35, function(v)
    setAirStrafeBoost(v)
end)
PhysicsTab:AddToggle("Auto-Walk", false, function(v)
    setAutoWalk(v)
end)

-- overige zooi
local MiscTab = maakTab("Misc")
MiscTab:AddSection("Survival & Immunity")
MiscTab:AddToggle("Godmode", false, function(v)
    zetGodModus(v)
    melding("Misc", v and "Godmode ON" or "Godmode OFF", 2, v and Theme.Green or Theme.Red)
end)
MiscTab:AddToggle("Killbrick Shield", false, function(v) zetAanraakSchild(v); melding("Misc", v and "Touch Shield ON" or "Touch Shield OFF", 1.5) end)
MiscTab:AddToggle("Prevent Death State", false, function(v) zetDoodsSchild(v); melding("Misc", v and "Death State Disabled" or "Death State Default", 1.5) end)
MiscTab:AddToggle("Anti-Fall Damage", false, function(v) zetValBescherming(v); melding("Misc", v and "Anti-Fall ON" or "Anti-Fall OFF", 1.5) end)

MiscTab:AddSection("Horror Utilities")
MiscTab:AddToggle("Camera Flashlight", false, function(v) zetZaklamp(v); melding("Misc", v and "Flashlight ON" or "Flashlight OFF", 1.5) end)
MiscTab:AddSlider("Light Brightness", 1, 10, 3, function(v) flashlightBrightness = v; updateFlashlight() end)
MiscTab:AddSlider("Light Range (studs)", 20, 180, 70, function(v) flashlightRange = v; updateFlashlight() end)
MiscTab:AddToggle("Entity Radar", false, function(v) zetEntiteitRadar(v); melding("Misc", v and "Monster Radar ON" or "Monster Radar OFF", 1.5) end)
MiscTab:AddToggle("Clear Vision", false, function(v) zetHelderZicht(v); melding("Misc", v and "Clear Vision ON" or "Clear Vision OFF", 1.5) end)

MiscTab:AddSection("World & Interactions")
MiscTab:AddToggle("Instant Prompts", false, function(v) zetDirecteInteractie(v); melding("Misc", v and "Instant Prompts ON" or "Instant Prompts OFF", 1.5) end)
MiscTab:AddToggle("Infinite Zoom", false, function(v) zetOneindigInzoomen(v); melding("Misc", v and "Infinite Zoom ON" or "Infinite Zoom OFF", 1.5) end)
MiscTab:AddToggle("Hitbox Displace", false, function(v) zetRaakvlakVerplaatsen(v); melding("Misc", v and "Hitbox Displaced" or "Hitbox Reset", 1.5) end)
MiscTab:AddSlider("Displace Distance", 5, 80, 25, function(v) hitboxDisplaceDist = v; if hitboxDisplaceEnabled then zetRaakvlakVerplaatsen(true) end end)

MiscTab:AddSection("Camera & Attribute Bypasses")
MiscTab:AddToggle("Force First Person", false, function(v)
    setUnlockFirstPerson(v)
    melding("Misc", v and "Forced First Person Unlocked" or "Camera Lock Default", 1.5)
end)
MiscTab:AddToggle("Auto-Clear Attributes", false, function(v)
    setAutoClearAttributes(v)
    melding("Misc", v and "Auto-Clear Attributes ON" or "Auto-Clear OFF", 1.5)
end)
MiscTab:AddButton("Wipe Attributes", function()
    local cnt = clearRestrictions()
    melding("Misc", "Wiped " .. cnt .. " attributes", 1.5, Theme.Green)
end)

local ToolsTab = maakTab("Tools")
ToolsTab:AddSection("PlayerScripts Controller")
ToolsTab:AddButton("Disable LocalScripts", function()
    local c = toggleAllScripts(false)
    melding("Tools", "Disabled " .. c .. " game scripts", 2, Theme.Red)
end)
ToolsTab:AddButton("Enable LocalScripts", function()
    local c = toggleAllScripts(true)
    melding("Tools", "Enabled " .. c .. " game scripts", 2, Theme.Green)
end)

ToolsTab:AddSection("Inspector")
ToolsTab:AddToggle("Hover Instance Inspector", false, function(v)
    HoverHud.Visible = v
    inspectorConn = veiligOntkoppelen(inspectorConn)
    if v then
        inspectorConn = RunService.RenderStepped:Connect(function()
            local mp = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mp.X, mp.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result and result.Instance then
                HoverHud.Text = string.format("  [%s]  %s", result.Instance.ClassName, result.Instance.Name)
            else
                HoverHud.Text = "  Hover over any instance..."
            end
        end)
    end
end)

ToolsTab:AddSection("Cleanup")
ToolsTab:AddButton("Clear Tagged Objects", function()
    local removed = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d.Name and (d.Name:find("Hub") or d.Name == "AirFloor" or d.Name == "CamLightAnchor") and (d:IsA("BasePart") or d:IsA("Beam") or d:IsA("Highlight")) then
            d:Destroy(); removed = removed + 1
        end
    end
    melding("Tools", "Removed " .. removed .. " tagged objects", 2)
end)


local IntelTab = maakTab("Intel")
IntelTab:AddSection("Game Architecture Intelligence")
IntelTab:AddButton("Run Vulnerability Probe", function()
        local rse = game:GetService("ReplicatedStorage"):FindFirstChild("RSEAdmin")
        if not rse then
            melding("Admin Probe", "RSEAdmin folder not found in this game", 2, Theme.Red)
            return
        end
        local req = rse:FindFirstChild("Request")
        local evt = rse:FindFirstChild("Event")
        local payloads = {"Admin", "GetAdmin", "GiveAdmin", "Cash", "Money", "Coins", "Speed", "BTools", "God", {"Admin"}}
        local vulns = 0
        local lines = {"=== RSEADMIN PROBE RESULTS ==="}
        for _, p in ipairs(payloads) do
            local pStr = type(p) == "table" and ("table: " .. tostring(p[1])) or tostring(p)
            if req and req:IsA("RemoteFunction") then
                local ok, res = pcall(function() return req:InvokeServer(p) end)
                if ok and res ~= nil and res ~= false then
                    vulns = vulns + 1
                    table.insert(lines, "[VULN] Request(" .. pStr .. ") -> " .. tostring(res))
                else
                    table.insert(lines, "[Blocked] Request(" .. pStr .. ")")
                end
            end
            if evt and evt:IsA("RemoteEvent") then pcall(function() evt:FireServer(p) end) end
            task.wait(0.06)
        end
        local resStr = table.concat(lines, "\n")
        print(resStr)
        if setclipboard then pcall(function() setclipboard(resStr) end) end
        melding("Admin Probe", string.format("Probe Done! %d vulnerabilities. Copied to clipboard.", vulns), 3.5, vulns > 0 and Theme.Green or Theme.Red)
    end)
IntelTab:AddButton("Full Scan & Copy", function() fullScanAndCopyClipboard() end)
IntelTab:AddButton("Open Logbook Window", function() setLogbookVisible(true) end)
IntelTab:AddButton("Re-Copy Dossier to Clipboard", function() copyLogbookDossier() end)

IntelTab:AddSection("Individual Scanners")
IntelTab:AddButton("Scan Remotes Only", function() scanAndRefreshRemotes() end)
IntelTab:AddButton("Scan Scripts Only", function() scanAndRefreshScripts() end)

local SystemTab = maakTab("System")
SystemTab:AddSection("Security & Anti-Kick")
SystemTab:AddToggle("Stealth Mode (Zero-Hook)", false, function(v) setStealthMode(v) end)
SystemTab:AddToggle("Anti-Kick", false, function(v) setAntiKick(v) end)
SystemTab:AddSection("Diagnostics")
SystemTab:AddToggle("FPS + Speed HUD", false, function(v) setFPSHud(v) end)
SystemTab:AddSection("Controls")
SystemTab:AddButton("Hide Menu  [ RShift ]", function() zetZichtbaar(false) end)
SystemTab:AddButton("Reset All Features", function() herstelAlles() end)

do
    local SettingsTab = maakTab("Settings")

    SettingsTab:AddSection("Automation & QoL")
    local antiAfkConn = nil
    SettingsTab:AddToggle("Anti-AFK", false, function(enabled)
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
        if enabled then
            local vu = nil
            pcall(function() vu = game:GetService("VirtualUser") end)
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                if vu then
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.zero)
                    end)
                end
            end)
            melding("Anti-AFK", "Enabled - 20min kick protection active", 3, Theme.Green)
        else
            melding("Anti-AFK", "Disabled", 2, Theme.Red)
        end
    end)

    SettingsTab:AddButton("Rejoin Same Server", function()
        local ts = game:GetService("TeleportService")
        pcall(function() ts:Teleport(game.PlaceId, LocalPlayer) end)
    end)
    SettingsTab:AddButton("Copy Server JobId", function()
        if setclipboard then pcall(function() setclipboard(game.JobId) end) end
        melding("JobId", "Server JobId copied to clipboard", 2.5, Theme.Accent)
    end)
end

task.defer(function()
    print("[Hub] Loaded successfully!")
    melding("Hub", "Loaded  *  RShift / Float Icon to toggle", 4, Theme.Green)
end)



local ScriptsTab = maakTab("Scripts")
ScriptsTab:AddSection("Script Discovery")
ScriptsTab:AddButton("Scan All Accessible Scripts", function() scanAndRefreshScripts() end)

ScriptsTab:AddSection("Active Script Selection")

local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 32)
statusCard.BackgroundColor3 = Theme.ElementBg
statusCard.BorderSizePixel = 0
statusCard.Parent = ScriptsTab.Page

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 5)
scCorner.Parent = statusCard

local scStroke = Instance.new("UIStroke")
scStroke.Color = Theme.BorderBright
scStroke.Thickness = 1
scStroke.Parent = statusCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 1, 0)
statusLabel.Position = UDim2.new(0, 8, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "No scripts loaded. Click 'Scan All Accessible Scripts'."
statusLabel.TextColor3 = Theme.Accent
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusCard

ScriptsTab:AddButton("Next Script  >", function() nextScriptViewer() end)
ScriptsTab:AddButton("<  Previous Script", function() prevScriptViewer() end)
ScriptsTab:AddButton("Toggle Active Script", function() toggleSelectedScript() end)
ScriptsTab:AddButton("Dump Script Info", function() printSelectedScript() end)

ScriptsTab:AddSection("Source & Metadata Viewer")

local viewerFrame = Instance.new("Frame")
viewerFrame.Size = UDim2.new(1, 0, 0, 220)
viewerFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
viewerFrame.BorderSizePixel = 0
viewerFrame.Parent = ScriptsTab.Page

local vfCorner = Instance.new("UICorner")
vfCorner.CornerRadius = UDim.new(0, 5)
vfCorner.Parent = viewerFrame

local vfStroke = Instance.new("UIStroke")
vfStroke.Color = Theme.Border
vfStroke.Thickness = 1
vfStroke.Parent = viewerFrame

local scrollBox = Instance.new("ScrollingFrame")
scrollBox.Size = UDim2.new(1, -12, 1, -12)
scrollBox.Position = UDim2.new(0, 6, 0, 6)
scrollBox.BackgroundTransparency = 1
scrollBox.BorderSizePixel = 0
scrollBox.ScrollBarThickness = 3
scrollBox.ScrollBarImageColor3 = Theme.BorderBright
scrollBox.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollBox.AutomaticCanvasSize = Enum.AutomaticSize.XY
scrollBox.Parent = viewerFrame

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, 0, 1, 0)
codeBox.BackgroundTransparency = 1
codeBox.BorderSizePixel = 0
codeBox.Text = "Click 'Scan All Accessible Scripts' above to inspect game scripts..."
codeBox.TextColor3 = Color3.fromRGB(200, 205, 225)
codeBox.Font = Enum.Font.Gotham
codeBox.TextSize = 10
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.ClearTextOnFocus = false
codeBox.TextEditable = false
codeBox.MultiLine = true
codeBox.Parent = scrollBox

bindScriptViewerElements(codeBox, statusLabel)
statusCard.MouseEnter:Connect(function() toonTip(statusLabel.Text) end)
statusCard.MouseLeave:Connect(verbergTip)
codeBox.MouseEnter:Connect(function() toonTip("Script Source Viewer") end)
codeBox.MouseLeave:Connect(verbergTip)



local PowerTab = maakTab("God & World")
PowerTab:AddSection("World Interaction Exploits")
PowerTab:AddToggle("Auto-Prompt Aura", false, function(v) zetInteractieAura(v) end)
PowerTab:AddToggle("Coin & Pickup Magnet", false, function(v) zetAanraakMagneet(v) end)

PowerTab:AddSection("Invulnerability & Defense")
PowerTab:AddToggle("Anti-Fling Shield", false, function(v) zetAntiSlinger(v) end)
PowerTab:AddToggle("Anti-Ragdoll", false, function(v) zetAntiLappenpop(v) end)
PowerTab:AddToggle("Infinite Stamina", false, function(v) zetOneindigUithoudingsvermogen(v) end)
PowerTab:AddToggle("Anti-Void Rebound", false, function(v) zetAntiLeegte(v) end)
PowerTab:AddToggle("Ghost Desync", false, function(v) zetGeestDesync(v) end)

PowerTab:AddSection("Locomotion & BTools")
PowerTab:AddToggle("Spider Wall Climb", false, function(v) zetSpinnenLoop(v) end)
PowerTab:AddToggle("Freecam", false, function(v) zetVrijeCamera(v) end)
PowerTab:AddToggle("BTools", false, function(v) zetBouwGereedschap(v) end)



ScriptsTab:AddSection("Server Remote Explorer & Invoker")
ScriptsTab:AddButton("Scan All Server Remotes", function() scanAndRefreshRemotes() end)

local remCard = Instance.new("Frame")
remCard.Size = UDim2.new(1, 0, 0, 36)
remCard.BackgroundColor3 = Theme.ElementBg
remCard.BorderSizePixel = 0
remCard.Parent = ScriptsTab.Page

local rmcCorner = Instance.new("UICorner")
rmcCorner.CornerRadius = UDim.new(0, 5)
rmcCorner.Parent = remCard

local rmcStroke = Instance.new("UIStroke")
rmcStroke.Color = Theme.BorderBright
rmcStroke.Thickness = 1
rmcStroke.Parent = remCard

local remLabel = Instance.new("TextLabel")
remLabel.Size = UDim2.new(1, -16, 1, 0)
remLabel.Position = UDim2.new(0, 8, 0, 0)
remLabel.BackgroundTransparency = 1
remLabel.Text = "No remotes loaded. Click 'Scan All Server Remotes'."
remLabel.TextColor3 = Theme.Accent
remLabel.Font = Enum.Font.Gotham
remLabel.TextSize = 10
remLabel.TextXAlignment = Enum.TextXAlignment.Left
remLabel.Parent = remCard

bindRemoteStatusLabel(remLabel)

ScriptsTab:AddButton("Next Remote  >", function() nextRemote() end)
ScriptsTab:AddButton("<  Previous Remote", function() prevRemote() end)
ScriptsTab:AddButton("Fire Remote (Empty)", function() fireCurrentRemote("None") end)
ScriptsTab:AddButton("Fire Remote (Player)", function() fireCurrentRemote("Player") end)
ScriptsTab:AddButton("Fire Remote (100)", function() fireCurrentRemote("Number") end)
ScriptsTab:AddButton("Fire Remote ('Claim')", function() fireCurrentRemote("String") end)
ScriptsTab:AddToggle("Auto-Spam Remote", false, function(v) setRemoteSpam(v) end)

do
    local CreditsTab = maakTab("Credits")
    CreditsTab:AddSection("Credits")
    CreditsTab:AddLabel("Developer: Eiko")
    CreditsTab:AddLabel("UI Library: Venus")
    CreditsTab:AddButton("Copy Discord Invite", function()
        local link = "https://discord.gg/P7fuzYj5xK"
        local copied = false
        local fn = setclipboard or toclipboard or set_clipboard or writeclipboard or setrbxclipboard or (syn and syn.set_clipboard) or (Clipboard and Clipboard.set)
        if fn then
            local ok = pcall(fn, link)
            if ok then copied = true end
        end
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            pcall(function()
                req({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        cmd = "INVITE_BROWSER",
                        args = { code = "P7fuzYj5xK" },
                        nonce = game:GetService("HttpService"):GenerateGUID(false)
                    })
                })
            end)
        end
    end)
    CreditsTab:AddLabel("Discord: discord.gg/P7fuzYj5xK")
end

do
    local favTab = maakTab("Favorites")
    favTab:AddSection("Starred Features")

    local favEmptyNote = Instance.new("TextLabel")
    favEmptyNote.Size = UDim2.new(1, 0, 0, 40)
    favEmptyNote.BackgroundTransparency = 1
    favEmptyNote.Text = "Right-click any button or toggle to add to Favorites."
    favEmptyNote.TextColor3 = Theme.TextSecondary
    favEmptyNote.Font = Enum.Font.Gotham
    favEmptyNote.TextSize = 10
    favEmptyNote.TextWrapped = true
    favEmptyNote.Parent = favTab.Page

    local KModal = {}
    KModal.Overlay = Instance.new("Frame")
    KModal.Overlay.Size = UDim2.new(1, 0, 1, 0)
    KModal.Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    KModal.Overlay.BackgroundTransparency = 0.5
    KModal.Overlay.BorderSizePixel = 0
    KModal.Overlay.ZIndex = 700
    KModal.Overlay.Visible = false
    KModal.Overlay.Parent = ScreenGui

    do
        local kmCard = Instance.new("Frame")
        kmCard.Size = UDim2.new(0, 320, 0, 150)
        kmCard.AnchorPoint = Vector2.new(0.5, 0.5)
        kmCard.Position = UDim2.new(0.5, 0, 0.5, 0)
        kmCard.BackgroundColor3 = Theme.Header
        kmCard.BorderSizePixel = 0
        kmCard.ZIndex = 701
        kmCard.Parent = KModal.Overlay

        local kmCorner = Instance.new("UICorner")
        kmCorner.CornerRadius = UDim.new(0, 6)
        kmCorner.Parent = kmCard

        local kmStroke = Instance.new("UIStroke")
        kmStroke.Color = Theme.Border
        kmStroke.Thickness = 1
        kmStroke.Parent = kmCard

        local kmTitle = Instance.new("TextLabel")
        kmTitle.Size = UDim2.new(1, -20, 0, 24)
        kmTitle.Position = UDim2.new(0, 10, 0, 12)
        kmTitle.BackgroundTransparency = 1
        kmTitle.Text = "KEYBIND CONFIGURATION"
        kmTitle.TextColor3 = Theme.Accent
        kmTitle.Font = Enum.Font.Gotham
        kmTitle.TextSize = 11
        kmTitle.TextXAlignment = Enum.TextXAlignment.Left
        kmTitle.ZIndex = 702
        kmTitle.Parent = kmCard

        local kmDesc = Instance.new("TextLabel")
        kmDesc.Size = UDim2.new(1, -20, 0, 40)
        kmDesc.Position = UDim2.new(0, 10, 0, 38)
        kmDesc.BackgroundTransparency = 1
        kmDesc.Text = "Press any key on your keyboard to bind\n[Backspace] to remove | [Escape] to cancel"
        kmDesc.TextColor3 = Theme.TextSecondary
        kmDesc.Font = Enum.Font.Gotham
        kmDesc.TextSize = 10
        kmDesc.TextXAlignment = Enum.TextXAlignment.Left
        kmDesc.ZIndex = 702
        kmDesc.Parent = kmCard

        KModal.TargetLbl = Instance.new("TextLabel")
        KModal.TargetLbl.Size = UDim2.new(1, -20, 0, 24)
        KModal.TargetLbl.Position = UDim2.new(0, 10, 0, 84)
        KModal.TargetLbl.BackgroundColor3 = Theme.ElementBg
        KModal.TargetLbl.TextColor3 = Theme.Green
        KModal.TargetLbl.Font = Enum.Font.Gotham
        KModal.TargetLbl.TextSize = 10
        KModal.TargetLbl.BorderSizePixel = 0
        KModal.TargetLbl.ZIndex = 702
        KModal.TargetLbl.Parent = kmCard

        local kmtCorner = Instance.new("UICorner")
        kmtCorner.CornerRadius = UDim.new(0, 4)
        kmtCorner.Parent = KModal.TargetLbl
    end

    local KeybindRegistry = {}
    local pendingKeybindTarget = nil
    local pendingKeybindName = ""

    local Ctx = {}
    Ctx.Menu = Instance.new("Frame")
    Ctx.Menu.Size = UDim2.new(0, 140, 0, 96)
    Ctx.Menu.BackgroundColor3 = Theme.Header
    Ctx.Menu.BorderSizePixel = 0
    Ctx.Menu.Visible = false
    Ctx.Menu.ZIndex = 650
    Ctx.Menu.Parent = ScreenGui

    do
        local cmCorner = Instance.new("UICorner")
        cmCorner.CornerRadius = UDim.new(0, 5)
        cmCorner.Parent = Ctx.Menu

        local cmStroke = Instance.new("UIStroke")
        cmStroke.Color = Theme.BorderBright
        cmStroke.Thickness = 1
        cmStroke.Parent = Ctx.Menu

        local cmLayout = Instance.new("UIListLayout")
        cmLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cmLayout.Padding = UDim.new(0, 2)
        cmLayout.Parent = Ctx.Menu

        local cmPad = Instance.new("UIPadding")
        cmPad.PaddingTop = UDim.new(0, 4)
        cmPad.PaddingBottom = UDim.new(0, 4)
        cmPad.PaddingLeft = UDim.new(0, 4)
        cmPad.PaddingRight = UDim.new(0, 4)
        cmPad.Parent = Ctx.Menu
    end

    local currentContextTarget = nil
    local currentContextName = ""

    local function makeContextBtn(text, order, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = Theme.ElementBg
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.LayoutOrder = order
        btn.ZIndex = 651
        btn.Parent = Ctx.Menu

        local bPad = Instance.new("UIPadding")
        bPad.PaddingLeft = UDim.new(0, 8)
        bPad.Parent = btn

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 3)
        bCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            glij(btn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.ElementHover}, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            glij(btn, {BackgroundTransparency = 1}, 0.1)
        end)
        btn.MouseButton1Click:Connect(function()
            Ctx.Menu.Visible = false
            if onClick then onClick() end
        end)
        return btn
    end

    makeContextBtn("Toggle Favorite", 1, function()
        if not currentContextTarget then return end
        favEmptyNote.Visible = false
        local target = currentContextTarget
        local name = currentContextName
        if target:IsA("TextButton") then
            local isToggle = target:FindFirstChild("Frame") and target:FindFirstChild("Frame"):FindFirstChild("Frame")
            if isToggle then
                favTab:AddToggle(name, false, function()
                    pcall(function()
                        local fires = getconnections and getconnections(target.MouseButton1Click)
                        if fires then
                            for _, c in ipairs(fires) do
                                if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                            end
                        elseif firesignal then
                            firesignal(target.MouseButton1Click)
                        end
                    end)
                end)
            else
                favTab:AddButton(name, function()
                    pcall(function()
                        local fires = getconnections and getconnections(target.MouseButton1Click)
                        if fires then
                            for _, c in ipairs(fires) do
                                if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                            end
                        elseif firesignal then
                            firesignal(target.MouseButton1Click)
                        end
                    end)
                end)
            end
        end
        melding("Favorites", "Added '" .. name .. "' to Favorites", 2, Theme.Green)
    end)

    makeContextBtn("Bind Key", 2, function()
        if not currentContextTarget then return end
        pendingKeybindTarget = currentContextTarget
        pendingKeybindName = currentContextName
        KModal.TargetLbl.Text = "Target: " .. currentContextName
        KModal.Overlay.Visible = true
    end)

    makeContextBtn("Copy Name", 3, function()
        if currentContextName ~= "" then
            if setclipboard then pcall(setclipboard, currentContextName)
            elseif toclipboard then pcall(toclipboard, currentContextName) end
            melding("Copied", currentContextName, 2)
        end
    end)

    makeContextBtn("Reset Control", 4, function()
        if currentContextTarget and currentContextTarget:IsA("TextButton") then
            melding("Reset", "Reset control state", 1.5)
        end
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if KModal.Overlay.Visible then
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local kc = inp.KeyCode
                if kc == Enum.KeyCode.Escape then
                    KModal.Overlay.Visible = false
                    pendingKeybindTarget = nil
                elseif kc == Enum.KeyCode.Backspace then
                    for k, v in pairs(KeybindRegistry) do
                        if v.target == pendingKeybindTarget then
                            KeybindRegistry[k] = nil
                        end
                    end
                    KModal.Overlay.Visible = false
                    melding("Keybind", "Keybind cleared for " .. pendingKeybindName, 2)
                    pendingKeybindTarget = nil
                else
                    KeybindRegistry[kc] = {
                        target = pendingKeybindTarget,
                        name = pendingKeybindName
                    }
                    KModal.Overlay.Visible = false
                    melding("Keybind", "Bound [" .. kc.Name .. "] to " .. pendingKeybindName, 2.5, Theme.Green)
                    pendingKeybindTarget = nil
                end
            end
            return
        end

        if not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
            local entry = KeybindRegistry[inp.KeyCode]
            if entry and entry.target and entry.target.Parent then
                pcall(function()
                    local fires = getconnections and getconnections(entry.target.MouseButton1Click)
                    if fires then
                        for _, c in ipairs(fires) do
                            if c.Fire then c:Fire() elseif c.Function then task.spawn(c.Function) end
                        end
                    elseif firesignal then
                        firesignal(entry.target.MouseButton1Click)
                    end
                end)
                melding("Keybind", "Activated " .. entry.name .. " [" .. inp.KeyCode.Name .. "]", 1.2)
            end
        end

        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if Ctx.Menu.Visible then
                local mPos = UserInputService:GetMouseLocation()
                local cPos = Ctx.Menu.AbsolutePosition
                local cSize = Ctx.Menu.AbsoluteSize
                if mPos.X < cPos.X or mPos.X > cPos.X + cSize.X or mPos.Y < cPos.Y or mPos.Y > cPos.Y + cSize.Y then
                    Ctx.Menu.Visible = false
                end
            end
        end
    end)

    local function hookContext(elem)
        if elem:IsA("TextButton") or (elem:IsA("Frame") and elem.Name ~= "Page") then
            elem.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                    currentContextTarget = elem
                    local lbl = elem:FindFirstChildOfClass("TextLabel")
                    currentContextName = lbl and lbl.Text or (elem:IsA("TextButton") and elem.Text or "Feature")
                    local mPos = UserInputService:GetMouseLocation()
                    Ctx.Menu.Position = UDim2.new(0, mPos.X + 4, 0, mPos.Y - 20)
                    Ctx.Menu.Visible = true
                end
            end)
        end
    end

    for _, tabObj in ipairs(AllTabs) do
        if tabObj ~= favTab and tabObj.Page then
            for _, child in ipairs(tabObj.Page:GetChildren()) do
                hookContext(child)
            end
            tabObj.Page.ChildAdded:Connect(function(child)
                task.wait()
                hookContext(child)
            end)
        end
    end
end

do
    local chatFadeEnabled = true
    UserInputService.TextBoxFocused:Connect(function(textBox)
        if not chatFadeEnabled then return end
        local p = textBox.Parent
        local isChat = false
        while p and p ~= game do
            if string.find(string.lower(p.Name), "chat") or p.Name == "ChatBar" or p.Name == "ChatChannelParentFrame" then
                isChat = true
                break
            end
            p = p.Parent
        end
        if isChat or string.find(string.lower(textBox.Name), "chat") then
            glij(MainFrame, {BackgroundTransparency = 0.92}, 0.2)
            -- shadow weg
        end
    end)

    UserInputService.TextBoxFocusReleased:Connect(function(textBox)
        if isVisible then
            glij(MainFrame, {BackgroundTransparency = 0.12}, 0.2)
            -- shadow weg
        end
    end)
end

do
    for _, tabObj in ipairs(AllTabs) do
        if tabObj and tabObj.Page then
            for _, elem in ipairs(tabObj.Page:GetChildren()) do
                if elem:IsA("Frame") and elem.Size == UDim2.new(1, 0, 0, 28) and elem.BackgroundTransparency == 1 then
                    local lbl = elem:FindFirstChildOfClass("TextLabel")
                    if lbl and lbl.Font == Enum.Font.Gotham and lbl.TextSize == 9 then
                        local masterBtn = Instance.new("TextButton")
                        masterBtn.Size = UDim2.new(0, 38, 0, 16)
                        masterBtn.Position = UDim2.new(1, -44, 0.5, -8)
                        masterBtn.BackgroundColor3 = Theme.ElementBg
                        masterBtn.Text = "ALL"
                        masterBtn.TextColor3 = Theme.TextSecondary
                        masterBtn.Font = Enum.Font.Gotham
                        masterBtn.TextSize = 9
                        masterBtn.BorderSizePixel = 0
                        masterBtn.Parent = elem

                        local mbCorner = Instance.new("UICorner")
                        mbCorner.CornerRadius = UDim.new(0, 3)
                        mbCorner.Parent = masterBtn

                        local mbStroke = Instance.new("UIStroke")
                        mbStroke.Color = Theme.Border
                        mbStroke.Thickness = 1
                        mbStroke.Parent = masterBtn

                        local isMasterOn = false
                        masterBtn.MouseButton1Click:Connect(function()
                            isMasterOn = not isMasterOn
                            glij(masterBtn, {
                                BackgroundColor3 = isMasterOn and Theme.Accent or Theme.ElementBg,
                                TextColor3 = isMasterOn and Theme.Background or Theme.TextSecondary
                            }, 0.14)
                            local allElems = tabObj.Page:GetChildren()
                            local inSection = false
                            for _, sib in ipairs(allElems) do
                                if sib == elem then
                                    inSection = true
                                elseif inSection then
                                    if sib:IsA("Frame") and sib.Size == UDim2.new(1, 0, 0, 28) and sib.BackgroundTransparency == 1 then
                                        break
                                    end
                                    if sib:IsA("TextButton") and sib:FindFirstChild("Frame") then
                                        local fires = getconnections and getconnections(sib.MouseButton1Click)
                                        if fires then
                                            for _, c in ipairs(fires) do c:Fire() end
                                        else
                                            pcall(function() if firesignal then firesignal(sib.MouseButton1Click) end end)
                                        end
                                    end
                                end
                            end
                            melding("Section Master", isMasterOn and "Batch toggled ON" or "Batch toggled OFF", 1.5)
                        end)

                        local accordBtn = Instance.new("TextButton")
                        accordBtn.Size = UDim2.new(0, 16, 0, 16)
                        accordBtn.Position = UDim2.new(1, -66, 0.5, -8)
                        accordBtn.BackgroundTransparency = 1
                        accordBtn.Text = "v"
                        accordBtn.TextColor3 = Theme.AccentDim
                        accordBtn.Font = Enum.Font.Gotham
                        accordBtn.TextSize = 9
                        accordBtn.Parent = elem

                        local isCollapsed = false
                        accordBtn.MouseButton1Click:Connect(function()
                            isCollapsed = not isCollapsed
                            glij(accordBtn, {Rotation = isCollapsed and -90 or 0}, 0.15)
                            local allElems = tabObj.Page:GetChildren()
                            local inSection = false
                            for _, sib in ipairs(allElems) do
                                if sib == elem then
                                    inSection = true
                                elseif inSection then
                                    if sib:IsA("Frame") and sib.Size == UDim2.new(1, 0, 0, 28) and sib.BackgroundTransparency == 1 then
                                        break
                                    end
                                    if not sib:IsA("UIListLayout") and not sib:IsA("UIPadding") then
                                        sib.Visible = not isCollapsed
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

do
    local activeStateSnapshot = {
        flight = false,
        infJump = false,
        highlights = false,
        nightVision = false,
        walkSpeed = 16,
        jumpPower = 50,
        lastTool = nil
    }

    local function updateSnapshot()
        activeStateSnapshot.flight = flightEnabled or false
        activeStateSnapshot.highlights = highlightsEnabled or false
        local c = LocalPlayer.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                activeStateSnapshot.walkSpeed = hum.WalkSpeed
                activeStateSnapshot.jumpPower = hum.JumpPower
            end
            local t = c:FindFirstChildOfClass("Tool")
            if t then activeStateSnapshot.lastTool = t.Name end
        end
    end

    LocalPlayer.CharacterRemoving:Connect(function()
        updateSnapshot()
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.8)
        local hum = newChar:WaitForChild("Humanoid", 5)
        local root = newChar:WaitForChild("HumanoidRootPart", 5)
        if not hum or not root then return end

        local restoredCount = 0
        if activeStateSnapshot.flight and setFlight then
            zetVliegen(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.infJump and setInfJump then
            zetOneindigSpringen(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.highlights and setHighlights then
            zetHoogtepunten(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.nightVision and setNightVision then
            zetNachtZicht(true)
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.walkSpeed and activeStateSnapshot.walkSpeed > 16 then
            hum.WalkSpeed = activeStateSnapshot.walkSpeed
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.jumpPower and activeStateSnapshot.jumpPower > 50 then
            hum.JumpPower = activeStateSnapshot.jumpPower
            restoredCount = restoredCount + 1
        end
        if activeStateSnapshot.lastTool then
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then
                local tool = bp:FindFirstChild(activeStateSnapshot.lastTool)
                if tool then
                    hum:EquipTool(tool)
                    restoredCount = restoredCount + 1
                end
            end
        end

        if restoredCount > 0 then
            melding("Loadout Restore", "Restored " .. restoredCount .. " active features automatically.", 2.5, Theme.Green)
        end
    end)
end

do
    local function executeSilentCommand(msg)
        if string.sub(msg, 1, 1) ~= ";" and string.sub(msg, 1, 1) ~= "/" then return false end
        local args = string.split(string.sub(msg, 2), " ")
        local cmd = string.lower(args[1] or "")

        if cmd == "fly" then
            local spd = tonumber(args[2]) or 60
            if setFlight then zetVliegen(true) end
            melding("Command", "Flight enabled (Speed " .. spd .. ")", 2)
            return true
        elseif cmd == "unfly" then
            if setFlight then zetVliegen(false) end
            melding("Command", "Flight disabled", 2)
            return true
        elseif cmd == "speed" then
            local spd = tonumber(args[2]) or 32
            local hum = getHum and pakMens()
            if hum then hum.WalkSpeed = spd end
            melding("Command", "WalkSpeed set to " .. spd, 2)
            return true
        elseif cmd == "jump" then
            local pwr = tonumber(args[2]) or 80
            local hum = getHum and pakMens()
            if hum then hum.JumpPower = pwr end
            melding("Command", "JumpPower set to " .. pwr, 2)
            return true
        elseif cmd == "esp" then
            if setHighlights then zetHoogtepunten(not highlightsEnabled) end
            melding("Command", "ESP toggled", 2)
            return true
        elseif cmd == "rejoin" then
            melding("Command", "Rejoining server...", 2)
            task.wait(0.2)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            return true
        elseif cmd == "hub" then
            zetZichtbaar(not isVisible)
            return true
        elseif cmd == "tp" and args[2] then
            local targetName = string.lower(args[2])
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (string.find(string.lower(p.Name), targetName, 1, true) or string.find(string.lower(p.DisplayName), targetName, 1, true)) then
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local myRoot = getRoot and pakBasis()
                        if myRoot then
                            myRoot.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            melding("Command", "Teleported to " .. p.DisplayName, 2)
                            return true
                        end
                    end
                end
            end
            melding("Command", "Player not found", 2, Theme.Red)
            return true
        elseif cmd == "hub" then
            melding("Hub", "Running v2.0.1 (Elite Architecture)", 3, Theme.Accent)
            return true
        end
        return false
    end

    LocalPlayer.Chatted:Connect(function(msg)
        executeSilentCommand(msg)
    end)

    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.SendingMessage:Connect(function(message)
                if string.sub(message.Text, 1, 1) == ";" then
                    local ok = executeSilentCommand(message.Text)
                    if ok and message.Cancel then message:Cancel() end
                end
            end)
        end
    end)
end

do
    local desyncActive = false
    local desyncMode = "Burst"
    local desyncBurstTimer = 0

    local desyncHud = Instance.new("TextLabel")
    desyncHud.Name = "DesyncHudIndicator"
    desyncHud.Size = UDim2.new(0, 150, 0, 20)
    desyncHud.Position = UDim2.new(0, 10, 0, 52)
    desyncHud.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    desyncHud.BackgroundTransparency = 0.3
    desyncHud.TextColor3 = Theme.Green
    desyncHud.Font = Enum.Font.Gotham
    desyncHud.TextSize = 10
    desyncHud.Text = "DESYNC: INACTIVE"
    desyncHud.BorderSizePixel = 0
    desyncHud.Visible = false
    desyncHud.ZIndex = 80
    desyncHud.Parent = ScreenGui

    local dhCorner = Instance.new("UICorner")
    dhCorner.CornerRadius = UDim.new(0, 4)
    dhCorner.Parent = desyncHud

    local dhStroke = Instance.new("UIStroke")
    dhStroke.Color = Theme.Border
    dhStroke.Thickness = 1
    dhStroke.Parent = desyncHud

    local function toggleDesync(v)
        desyncActive = v
        desyncHud.Visible = v
        local root = getRoot and pakBasis()
        if not desyncActive then
            if root then root.Anchored = false end
            melding("Desync", "Network Desync DISABLED", 1.5)
        else
            melding("Desync", "Network Desync ENABLED [F4]", 1.5, Theme.Green)
        end
    end

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == Enum.KeyCode.F4 then
            toggleDesync(not desyncActive)
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        if not desyncActive then return end
        local root = getRoot and pakBasis()
        if not root then return end
        desyncBurstTimer = desyncBurstTimer + dt
        if desyncBurstTimer < 1.1 then
            root.Anchored = true
            desyncHud.Text = string.format("DESYNC: CHOKING (%.1fs)", 1.1 - desyncBurstTimer)
            desyncHud.TextColor3 = Theme.Red
        elseif desyncBurstTimer < 1.4 then
            root.Anchored = false
            desyncHud.Text = "DESYNC: RE-SYNCING"
            desyncHud.TextColor3 = Theme.Green
        else
            desyncBurstTimer = 0
        end
    end)

    local scriptsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Scripts" then
            scriptsTab = t
            break
        end
    end

    if scriptsTab then
        scriptsTab:AddSection("Exploit Network Modules")
        scriptsTab:AddToggle("Desync Lag Switch [F4]", false, function(v)
            toggleDesync(v)
        end)
    end
end

local function initAutomator()

local function initGameDetector()
    local SupportedGames = {
        [2629642516] = {
            Name = "Bitcoin Miner",
            GameId = 943733974,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto Super Cash, Auto Premium Coins, Auto XP, Auto Exchange, Anti-Kick"
        },
        [943733974] = {
            Name = "Bitcoin Miner",
            GameId = 943733974,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto Super Cash, Auto Premium Coins, Auto XP, Auto Exchange, Anti-Kick"
        },
        [142823291] = {
            Name = "Murder Mystery 2",
            GameId = 33513277,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto-Farm Coins, Sheriff ESP, Murderer ESP, Silent Aim"
        },
        [2753915549] = {
            Name = "Blox Fruits (Sea 1)",
            GameId = 994732206,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto Farm Level, Auto Chest, Fruit Finder"
        },
        [4442272183] = {
            Name = "Blox Fruits (Sea 2)",
            GameId = 994732206,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto Farm Level, Auto Chest, Fruit Finder"
        },
        [7449423635] = {
            Name = "Blox Fruits (Sea 3)",
            GameId = 994732206,
            Loadstring = '-- configure script loadstring here',
            Description = "Auto Farm Level, Auto Chest, Fruit Finder"
        },
        [286090429] = {
            Name = "Arsenal",
            GameId = 111958650,
            Loadstring = '-- configure script loadstring here',
            Description = "Silent Aim, Hitbox Expander, Wallbang, Auto Shoot"
        },
        [6872265039] = {
            Name = "Bedwars",
            GameId = 2619619496,
            Loadstring = '-- configure script loadstring here',
            Description = "Combat Aura, Auto Sprint, Velocity Modifier"
        },
        [17625359962] = {
            Name = "Rivals",
            GameId = 6035872082,
            Loadstring = '-- configure script loadstring here',
            Description = "Silent Aim, Anti-Recoil, Rapid Fire, ESP"
        }
    }

    local curPlace = game.PlaceId
    local curGame = game.GameId
    local foundGame = SupportedGames[curPlace] or SupportedGames[curGame]

    if not foundGame then
        for _, g in pairs(SupportedGames) do
            if g.GameId and g.GameId == curGame then
                foundGame = g
                break
            end
        end
    end

    local gsmOverlay = Instance.new("Frame")
    gsmOverlay.Name = "GameScriptModalOverlay"
    gsmOverlay.Size = UDim2.new(1, 0, 1, 0)
    gsmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    gsmOverlay.BackgroundTransparency = 1
    gsmOverlay.BorderSizePixel = 0
    gsmOverlay.ZIndex = 260
    gsmOverlay.Visible = false
    gsmOverlay.Active = false
    gsmOverlay.Parent = MainFrame

    local gsmModal = Instance.new("Frame")
    gsmModal.Size = UDim2.new(0, 480, 0, 310)
    gsmModal.AnchorPoint = Vector2.new(0.5, 0.5)
    gsmModal.Position = UDim2.new(0.5, 0, 0.5, 0)
    gsmModal.BackgroundColor3 = Theme.Header
    gsmModal.BackgroundTransparency = 0.05
    gsmModal.BorderSizePixel = 0
    gsmModal.ZIndex = 261
    gsmModal.Parent = gsmOverlay

    gsmModal.BorderSizePixel = 1
    gsmModal.BorderColor3 = Theme.Border

    local gsmTopBar = Instance.new("Frame")
    gsmTopBar.Size = UDim2.new(1, 0, 0, 36)
    gsmTopBar.BackgroundColor3 = Theme.Sidebar
    gsmTopBar.BorderSizePixel = 0
    gsmTopBar.ZIndex = 262
    gsmTopBar.Parent = gsmModal

    gsmTopBar.BorderSizePixel = 0

    local gmTitle = Instance.new("TextLabel")
    gmTitle.Size = UDim2.new(1, -50, 1, 0)
    gmTitle.Position = UDim2.new(0, 12, 0, 0)
    gmTitle.BackgroundTransparency = 1
    gmTitle.Text = "SCRIPT ENGINE"
    gmTitle.TextColor3 = Theme.Accent
    gmTitle.Font = Enum.Font.Gotham
    gmTitle.TextSize = 12
    gmTitle.TextXAlignment = Enum.TextXAlignment.Left
    gmTitle.ZIndex = 263
    gmTitle.Parent = gsmTopBar

    local gmClose = Instance.new("TextButton")
    gmClose.Size = UDim2.new(0, 24, 0, 24)
    gmClose.Position = UDim2.new(1, -30, 0.5, -12)
    gmClose.BackgroundColor3 = Theme.ElementBg
    gmClose.Text = "x"
    gmClose.TextColor3 = Theme.TextSecondary
    gmClose.Font = Enum.Font.Gotham
    gmClose.TextSize = 11
    gmClose.BorderSizePixel = 0
    gmClose.AutoButtonColor = false
    gmClose.ZIndex = 263
    gmClose.Parent = gsmTopBar

    gmClose.BorderSizePixel = 1
    gmClose.BorderColor3 = Theme.Border

    local gmGameTitle = Instance.new("TextLabel")
    gmGameTitle.Size = UDim2.new(1, -24, 0, 20)
    gmGameTitle.Position = UDim2.new(0, 12, 0, 44)
    gmGameTitle.BackgroundTransparency = 1
    gmGameTitle.Text = "GAME: " .. (foundGame and foundGame.Name or "Universal")
    gmGameTitle.TextColor3 = Theme.Green
    gmGameTitle.Font = Enum.Font.Gotham
    gmGameTitle.TextSize = 11
    gmGameTitle.TextXAlignment = Enum.TextXAlignment.Left
    gmGameTitle.ZIndex = 262
    gmGameTitle.Parent = gsmModal

    local gmDesc = Instance.new("TextLabel")
    gmDesc.Size = UDim2.new(1, -24, 0, 16)
    gmDesc.Position = UDim2.new(0, 12, 0, 66)
    gmDesc.BackgroundTransparency = 1
    gmDesc.Text = "Features: " .. (foundGame and foundGame.Description or "Universal Hub Features")
    gmDesc.TextColor3 = Theme.TextSecondary
    gmDesc.Font = Enum.Font.Gotham
    gmDesc.TextSize = 10
    gmDesc.TextXAlignment = Enum.TextXAlignment.Left
    gmDesc.ZIndex = 262
    gmDesc.Parent = gsmModal

    local codeContainer = Instance.new("Frame")
    codeContainer.Size = UDim2.new(1, -24, 0, 110)
    codeContainer.Position = UDim2.new(0, 12, 0, 90)
    codeContainer.BackgroundColor3 = Theme.Background
    codeContainer.BorderSizePixel = 0
    codeContainer.ZIndex = 262
    codeContainer.Parent = gsmModal

    local ccCorner = Instance.new("UICorner")
    ccCorner.CornerRadius = UDim.new(0, 4)
    ccCorner.Parent = codeContainer

    local ccStroke = Instance.new("UIStroke")
    ccStroke.Color = Theme.Border
    ccStroke.Thickness = 1
    ccStroke.Parent = codeContainer

    local codeHeader = Instance.new("TextLabel")
    codeHeader.Size = UDim2.new(1, -12, 0, 20)
    codeHeader.Position = UDim2.new(0, 8, 0, 4)
    codeHeader.BackgroundTransparency = 1
    codeHeader.Text = "LOADSTRING (SELECT OR CLICK COPY)"
    codeHeader.TextColor3 = Theme.AccentDim
    codeHeader.Font = Enum.Font.Gotham
    codeHeader.TextSize = 9
    codeHeader.TextXAlignment = Enum.TextXAlignment.Left
    codeHeader.ZIndex = 263
    codeHeader.Parent = codeContainer

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -16, 0, 76)
    codeBox.Position = UDim2.new(0, 8, 0, 26)
    codeBox.BackgroundColor3 = Theme.ElementBg
    codeBox.BackgroundTransparency = 0.5
    codeBox.TextColor3 = Color3.fromRGB(200, 220, 255)
    codeBox.Font = Enum.Font.Gotham
    codeBox.TextSize = 10
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.TextEditable = false
    codeBox.TextWrapped = true
    codeBox.BorderSizePixel = 0
    codeBox.ZIndex = 263
    codeBox.Parent = codeContainer

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 4)
    cbCorner.Parent = codeBox

    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -24, 0, 32)
    btnRow.Position = UDim2.new(0, 12, 0, 212)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 262
    btnRow.Parent = gsmModal

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.48, -4, 1, 0)
    copyBtn.Position = UDim2.new(0, 0, 0, 0)
    copyBtn.BackgroundColor3 = Theme.ElementBg
    copyBtn.Text = "COPY LOADSTRING"
    copyBtn.TextColor3 = Theme.Accent
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.TextSize = 10
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 263
    copyBtn.Parent = btnRow

    local cpbCorner = Instance.new("UICorner")
    cpbCorner.CornerRadius = UDim.new(0, 4)
    cpbCorner.Parent = copyBtn

    local cpbStroke = Instance.new("UIStroke")
    cpbStroke.Color = Theme.Border
    cpbStroke.Thickness = 1
    cpbStroke.Parent = copyBtn

    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.48, -4, 1, 0)
    execBtn.Position = UDim2.new(0.52, 0, 0, 0)
    execBtn.BackgroundColor3 = Theme.ElementBg
    execBtn.Text = "EXECUTE SCRIPT"
    execBtn.TextColor3 = Theme.Green
    execBtn.Font = Enum.Font.Gotham
    execBtn.TextSize = 10
    execBtn.BorderSizePixel = 0
    execBtn.AutoButtonColor = false
    execBtn.ZIndex = 263
    execBtn.Parent = btnRow

    local exbCorner = Instance.new("UICorner")
    exbCorner.CornerRadius = UDim.new(0, 4)
    exbCorner.Parent = execBtn

    local exbStroke = Instance.new("UIStroke")
    exbStroke.Color = Theme.Border
    exbStroke.Thickness = 1
    exbStroke.Parent = execBtn

    local activeGame = nil

    local function openScriptModal(gameData)
        activeGame = gameData
        gmGameTitle.Text = "GAME: " .. gameData.Name .. " (PlaceId: " .. tostring(curPlace) .. ")"
        gmDesc.Text = "Features: " .. gameData.Description
        codeBox.Text = gameData.Loadstring
        gsmOverlay.Visible = true
        glij(gsmOverlay, {BackgroundTransparency = 0.4}, 0.2)
        glij(gsmModal, {BackgroundTransparency = 0.05, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    local function closeScriptModal()
        glij(gsmOverlay, {BackgroundTransparency = 1}, 0.18)
        glij(gsmModal, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -20)}, 0.18).Completed:Connect(function()
            gsmOverlay.Visible = false
        end)
    end

    gmClose.MouseButton1Click:Connect(closeScriptModal)

    copyBtn.MouseButton1Click:Connect(function()
        if activeGame and activeGame.Loadstring then
            if setclipboard then pcall(setclipboard, activeGame.Loadstring)
            elseif toclipboard then pcall(toclipboard, activeGame.Loadstring) end
            melding("COPIED", "Loadstring copied to clipboard!", 2.5, Theme.Green)
        end
    end)

    execBtn.MouseButton1Click:Connect(function()
        if activeGame and activeGame.Loadstring then
            melding("EXECUTING", "Launching " .. activeGame.Name .. " script...", 2.5, Theme.Accent)
            pcall(function()
                local fn = loadstring(activeGame.Loadstring)
                if fn then task.spawn(fn) end
            end)
            closeScriptModal()
        end
    end)

    local scriptsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Scripts" then
            scriptsTab = t
            break
        end
    end

    if scriptsTab then
        scriptsTab:AddSection("Game Script Engine")
        if foundGame then
            scriptsTab:AddButton("View " .. foundGame.Name .. " Loadstring", function()
                openScriptModal(foundGame)
            end)
            scriptsTab:AddButton("Run " .. foundGame.Name .. " Script Now", function()
                melding("EXECUTING", "Launching " .. foundGame.Name .. " script...", 2.5, Theme.Accent)
                pcall(function()
                    local fn = loadstring(foundGame.Loadstring)
                    if fn then task.spawn(fn) end
                end)
            end)
        else
            scriptsTab:AddButton("Copy Current PlaceId (" .. tostring(curPlace) .. ")", function()
                if setclipboard then pcall(setclipboard, tostring(curPlace))
                elseif toclipboard then pcall(toclipboard, tostring(curPlace)) end
                melding("COPIED", "PlaceId copied: " .. tostring(curPlace), 2, Theme.Green)
            end)
            scriptsTab:AddButton("Copy Current GameId (" .. tostring(curGame) .. ")", function()
                if setclipboard then pcall(setclipboard, tostring(curGame))
                elseif toclipboard then pcall(toclipboard, tostring(curGame)) end
                melding("COPIED", "GameId copied: " .. tostring(curGame), 2, Theme.Green)
            end)
        end
    end

    if foundGame then
        task.delay(1.5, function()
            melding("GAME DETECTED", foundGame.Name .. " script available! Click to view loadstring", 10, Theme.Green, function()
                if not isVisible then zetZichtbaar(true) end
                openScriptModal(foundGame)
            end)
        end)
    end
end
initGameDetector()

    local scriptsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Scripts" then
            scriptsTab = t
            break
        end
    end

    if scriptsTab then
        scriptsTab:AddSection("Remote Event Trigger Automator")

        local automatorActive = false
        local selectedTrigger = ""
        local selectedActionType = "Remote"
        local selectedActionRemote = ""
        local selectedActionKey = "E"
        local automatorLatency = 0.5
        local triggerConnections = {}
        local activeRules = {}

        local autoContainer = Instance.new("Frame")
        autoContainer.Size = UDim2.new(1, 0, 0, 320)
        autoContainer.BackgroundColor3 = Theme.ElementBg
        autoContainer.BackgroundTransparency = 0.15
        autoContainer.BorderSizePixel = 0
        autoContainer.Parent = scriptsTab.Page

        local acCorner = Instance.new("UICorner")
        acCorner.CornerRadius = UDim.new(0, 6)
        acCorner.Parent = autoContainer

        local acStroke = Instance.new("UIStroke")
        acStroke.Color = Theme.Border
        acStroke.Thickness = 1
        acStroke.Parent = autoContainer

        local acTitle = Instance.new("TextLabel")
        acTitle.Size = UDim2.new(1, -20, 0, 24)
        acTitle.Position = UDim2.new(0, 10, 0, 8)
        acTitle.BackgroundTransparency = 1
        acTitle.Text = "EVENT MACRO & REACTION BUILDER"
        acTitle.TextColor3 = Theme.Accent
        acTitle.Font = Enum.Font.Gotham
        acTitle.TextSize = 10
        acTitle.TextXAlignment = Enum.TextXAlignment.Left
        acTitle.Parent = autoContainer

        local triggerInput = Instance.new("TextBox")
        triggerInput.Size = UDim2.new(1, -20, 0, 26)
        triggerInput.Position = UDim2.new(0, 10, 0, 36)
        triggerInput.BackgroundColor3 = Theme.Header
        triggerInput.Text = ""
        triggerInput.PlaceholderText = "Trigger Remote Name (e.g. DamageEvent, HitRemote)"
        triggerInput.TextColor3 = Theme.TextPrimary
        triggerInput.PlaceholderColor3 = Theme.TextSecondary
        triggerInput.Font = Enum.Font.Gotham
        triggerInput.TextSize = 10
        triggerInput.BorderSizePixel = 0
        triggerInput.TextXAlignment = Enum.TextXAlignment.Left
        triggerInput.Parent = autoContainer

        local tiCorner = Instance.new("UICorner")
        tiCorner.CornerRadius = UDim.new(0, 4)
        tiCorner.Parent = triggerInput

        local tiPad = Instance.new("UIPadding")
        tiPad.PaddingLeft = UDim.new(0, 8)
        tiPad.Parent = triggerInput

        local actionTypeBtn = Instance.new("TextButton")
        actionTypeBtn.Size = UDim2.new(0.48, 0, 0, 24)
        actionTypeBtn.Position = UDim2.new(0, 10, 0, 70)
        actionTypeBtn.BackgroundColor3 = Theme.Header
        actionTypeBtn.Text = "ACTION: REMOTE EVENT"
        actionTypeBtn.TextColor3 = Theme.Accent
        actionTypeBtn.Font = Enum.Font.Gotham
        actionTypeBtn.TextSize = 9
        actionTypeBtn.BorderSizePixel = 0
        actionTypeBtn.Parent = autoContainer

        local atbCorner = Instance.new("UICorner")
        atbCorner.CornerRadius = UDim.new(0, 4)
        atbCorner.Parent = actionTypeBtn

        local keySelectBtn = Instance.new("TextButton")
        keySelectBtn.Size = UDim2.new(0.48, -10, 0, 24)
        keySelectBtn.Position = UDim2.new(0.52, 0, 0, 70)
        keySelectBtn.BackgroundColor3 = Theme.Header
        keySelectBtn.Text = "KEY: [ E ]"
        keySelectBtn.TextColor3 = Theme.TextSecondary
        keySelectBtn.Font = Enum.Font.Gotham
        keySelectBtn.TextSize = 10
        keySelectBtn.BorderSizePixel = 0
        keySelectBtn.Parent = autoContainer

        local ksbCorner = Instance.new("UICorner")
        ksbCorner.CornerRadius = UDim.new(0, 4)
        ksbCorner.Parent = keySelectBtn

        local actionRemoteInput = Instance.new("TextBox")
        actionRemoteInput.Size = UDim2.new(1, -20, 0, 26)
        actionRemoteInput.Position = UDim2.new(0, 10, 0, 102)
        actionRemoteInput.BackgroundColor3 = Theme.Header
        actionRemoteInput.Text = ""
        actionRemoteInput.PlaceholderText = "Action Remote Name to Fire (e.g. BlockRemote, Parry)"
        actionRemoteInput.TextColor3 = Theme.TextPrimary
        actionRemoteInput.PlaceholderColor3 = Theme.TextSecondary
        actionRemoteInput.Font = Enum.Font.Gotham
        actionRemoteInput.TextSize = 10
        actionRemoteInput.BorderSizePixel = 0
        actionRemoteInput.TextXAlignment = Enum.TextXAlignment.Left
        actionRemoteInput.Parent = autoContainer

        local ariCorner = Instance.new("UICorner")
        ariCorner.CornerRadius = UDim.new(0, 4)
        ariCorner.Parent = actionRemoteInput

        local ariPad = Instance.new("UIPadding")
        ariPad.PaddingLeft = UDim.new(0, 8)
        ariPad.Parent = actionRemoteInput

        local latencyLabel = Instance.new("TextLabel")
        latencyLabel.Size = UDim2.new(1, -20, 0, 16)
        latencyLabel.Position = UDim2.new(0, 10, 0, 136)
        latencyLabel.BackgroundTransparency = 1
        latencyLabel.Text = "Reaction Latency: 500ms"
        latencyLabel.TextColor3 = Theme.TextSecondary
        latencyLabel.Font = Enum.Font.Gotham
        latencyLabel.TextSize = 10
        latencyLabel.TextXAlignment = Enum.TextXAlignment.Left
        latencyLabel.Parent = autoContainer

        local latencyTrack = Instance.new("Frame")
        latencyTrack.Size = UDim2.new(1, -20, 0, 6)
        latencyTrack.Position = UDim2.new(0, 10, 0, 156)
        latencyTrack.BackgroundColor3 = Theme.Header
        latencyTrack.BorderSizePixel = 0
        latencyTrack.Parent = autoContainer

        local ltCorner = Instance.new("UICorner")
        ltCorner.CornerRadius = UDim.new(1, 0)
        ltCorner.Parent = latencyTrack

        local latencyFill = Instance.new("Frame")
        latencyFill.Size = UDim2.new(0.25, 0, 1, 0)
        latencyFill.BackgroundColor3 = Theme.Accent
        latencyFill.BorderSizePixel = 0
        latencyFill.Parent = latencyTrack

        local lfCorner = Instance.new("UICorner")
        lfCorner.CornerRadius = UDim.new(1, 0)
        lfCorner.Parent = latencyFill

        local latencySliderBtn = Instance.new("TextButton")
        latencySliderBtn.Size = UDim2.new(1, 0, 1, 0)
        latencySliderBtn.BackgroundTransparency = 1
        latencySliderBtn.Text = ""
        latencySliderBtn.Parent = latencyTrack

        latencySliderBtn.MouseButton1Down:Connect(function()
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = latencyTrack.AbsolutePosition.X
                    local w = latencyTrack.AbsoluteSize.X
                    local r = math.clamp((inp.Position.X - x) / w, 0, 1)
                    automatorLatency = math.round(r * 2000) / 1000
                    latencyFill.Size = UDim2.new(r, 0, 1, 0)
                    latencyLabel.Text = string.format("Reaction Latency: %dms", math.round(automatorLatency * 1000))
                end
            end)
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if conn then conn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end)

        actionTypeBtn.MouseButton1Click:Connect(function()
            if selectedActionType == "Remote" then
                selectedActionType = "Key"
                actionTypeBtn.Text = "ACTION: KEYBOARD KEY"
                actionRemoteInput.Visible = false
                keySelectBtn.TextColor3 = Theme.Accent
            else
                selectedActionType = "Remote"
                actionTypeBtn.Text = "ACTION: REMOTE EVENT"
                actionRemoteInput.Visible = true
                keySelectBtn.TextColor3 = Theme.TextSecondary
            end
        end)

        local availableKeys = {"E", "Q", "F", "R", "C", "V", "X", "Z", "Space", "One", "Two", "Three"}
        local keyIdx = 1
        keySelectBtn.MouseButton1Click:Connect(function()
            keyIdx = (keyIdx % #availableKeys) + 1
            selectedActionKey = availableKeys[keyIdx]
            keySelectBtn.Text = "KEY: [ " .. selectedActionKey .. " ]"
        end)

        local addRuleBtn = Instance.new("TextButton")
        addRuleBtn.Size = UDim2.new(1, -20, 0, 28)
        addRuleBtn.Position = UDim2.new(0, 10, 0, 172)
        addRuleBtn.BackgroundColor3 = Theme.ElementActive
        addRuleBtn.Text = "CREATE AUTOMATION RULE"
        addRuleBtn.TextColor3 = Theme.Accent
        addRuleBtn.Font = Enum.Font.Gotham
        addRuleBtn.TextSize = 10
        addRuleBtn.BorderSizePixel = 0
        addRuleBtn.Parent = autoContainer

        local arbCorner = Instance.new("UICorner")
        arbCorner.CornerRadius = UDim.new(0, 4)
        arbCorner.Parent = addRuleBtn

        local rulesScroll = Instance.new("ScrollingFrame")
        rulesScroll.Size = UDim2.new(1, -20, 0, 100)
        rulesScroll.Position = UDim2.new(0, 10, 0, 208)
        rulesScroll.BackgroundColor3 = Theme.Header
        rulesScroll.BorderSizePixel = 0
        rulesScroll.ScrollBarThickness = 2
        rulesScroll.ScrollBarImageColor3 = Theme.BorderBright
        rulesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        rulesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        rulesScroll.Parent = autoContainer

        local rsCorner = Instance.new("UICorner")
        rsCorner.CornerRadius = UDim.new(0, 4)
        rsCorner.Parent = rulesScroll

        local rsLayout = Instance.new("UIListLayout")
        rsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rsLayout.Padding = UDim.new(0, 4)
        rsLayout.Parent = rulesScroll

        local rsPad = Instance.new("UIPadding")
        rsPad.PaddingTop = UDim.new(0, 4)
        rsPad.PaddingBottom = UDim.new(0, 4)
        rsPad.PaddingLeft = UDim.new(0, 4)
        rsPad.PaddingRight = UDim.new(0, 4)
        rsPad.Parent = rulesScroll

        local function registerRule(rule)
            table.insert(activeRules, rule)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 28)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = rulesScroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 4)
            cCorner.Parent = card

            local cardLbl = Instance.new("TextLabel")
            cardLbl.Size = UDim2.new(1, -54, 1, 0)
            cardLbl.Position = UDim2.new(0, 6, 0, 0)
            cardLbl.BackgroundTransparency = 1
            local actDesc = rule.actionType == "Remote" and rule.actionRemote or ("Key: " .. rule.actionKey)
            cardLbl.Text = rule.triggerRemote .. " -> " .. actDesc .. " (" .. math.round(rule.latency * 1000) .. "ms)"
            cardLbl.TextColor3 = Theme.TextPrimary
            cardLbl.Font = Enum.Font.Gotham
            cardLbl.TextSize = 9
            cardLbl.TextXAlignment = Enum.TextXAlignment.Left
            cardLbl.Parent = card

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 20, 0, 20)
            delBtn.Position = UDim2.new(1, -24, 0.5, -10)
            delBtn.BackgroundColor3 = Theme.Red
            delBtn.Text = "x"
            delBtn.TextColor3 = Theme.Accent
            delBtn.Font = Enum.Font.Gotham
            delBtn.TextSize = 10
            delBtn.BorderSizePixel = 0
            delBtn.Parent = card

            local dbCorner = Instance.new("UICorner")
            dbCorner.CornerRadius = UDim.new(0, 3)
            dbCorner.Parent = delBtn

            delBtn.MouseButton1Click:Connect(function()
                if rule.connection then rule.connection:Disconnect() end
                for i, r in ipairs(activeRules) do
                    if r == rule then
                        table.remove(activeRules, i)
                        break
                    end
                end
                card:Destroy()
                melding("Automator", "Rule removed", 1.5)
            end)

            pcall(function()
                for _, inst in ipairs(game:GetDescendants()) do
                    if inst:IsA("RemoteEvent") and inst.Name == rule.triggerRemote then
                        rule.connection = inst.OnClientEvent:Connect(function(...)
                            if not automatorActive then return end
                            local args = {...}
                            task.delay(rule.latency, function()
                                if rule.actionType == "Remote" then
                                    local targetRem = nil
                                    for _, d in ipairs(game:GetDescendants()) do
                                        if d:IsA("RemoteEvent") and d.Name == rule.actionRemote then
                                            targetRem = d
                                            break
                                        end
                                    end
                                    if targetRem then targetRem:FireServer() end
                                else
                                    pcall(function()
                                        local vim = game:GetService("VirtualInputManager")
                                        local kc = Enum.KeyCode[rule.actionKey] or Enum.KeyCode.E
                                        vim:SendKeyEvent(true, kc, false, game)
                                        task.wait(0.05)
                                        vim:SendKeyEvent(false, kc, false, game)
                                    end)
                                end
                            end)
                        end)
                        break
                    end
                end
            end)
        end

        addRuleBtn.MouseButton1Click:Connect(function()
            local trig = triggerInput.Text
            if trig == "" then
                melding("Automator", "Enter a trigger remote name first!", 2, Theme.Red)
                return
            end
            local rule = {
                triggerRemote = trig,
                actionType = selectedActionType,
                actionRemote = actionRemoteInput.Text,
                actionKey = selectedActionKey,
                latency = automatorLatency,
                connection = nil
            }
            registerRule(rule)
            triggerInput.Text = ""
            actionRemoteInput.Text = ""
            melding("Automator", "Rule active! Listening for " .. trig, 2.5, Theme.Green)
        end)

        scriptsTab:AddToggle("Automator Master Switch", false, function(v)
            automatorActive = v
            melding("Automator", v and "Automator rules ACTIVE" or "Automator rules PAUSED", 2, v and Theme.Green or Theme.Red)
        end)
    end
end
initAutomator()

do
    pcall(function()
        for _, tabObj in ipairs(AllTabs) do
            if tabObj and tabObj.Page then
                local page = tabObj.Page
                local velY = 0
                UserInputService.PointerAction:Connect(function(w, pan, pinch, gpe)
                    if page.Visible and not gpe and typeof(w) == "number" then
                        velY = velY + (w * 18)
                    end
                end)
                RunService.RenderStepped:Connect(function(dt)
                    if math.abs(velY) > 0.5 then
                        page.CanvasPosition = Vector2.new(0, math.clamp(page.CanvasPosition.Y - velY, 0, math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y)))
                        velY = velY * 0.88
                    else
                        velY = 0
                    end
                end)
            end
        end
    end)
end

do
    local clogOverlay = Instance.new("Frame")
    clogOverlay.Name = "ChangelogOverlayModal"
    clogOverlay.Size = UDim2.new(1, 0, 1, 0)
    clogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    clogOverlay.BackgroundTransparency = 1
    clogOverlay.BorderSizePixel = 0
    clogOverlay.ZIndex = 250
    clogOverlay.Visible = false
    clogOverlay.Active = false
    clogOverlay.Parent = MainFrame

    local clogModal = Instance.new("Frame")
    clogModal.Size = UDim2.new(0, 460, 0, 310)
    clogModal.AnchorPoint = Vector2.new(0.5, 0.5)
    clogModal.Position = UDim2.new(0.5, 0, 0.5, 20)
    clogModal.BackgroundColor3 = Theme.Header
    clogModal.BackgroundTransparency = 1
    clogModal.BorderSizePixel = 0
    clogModal.ZIndex = 301
    clogModal.Parent = clogOverlay

    local cmCorner = Instance.new("UICorner")
    cmCorner.CornerRadius = UDim.new(0, 6)
    cmCorner.Parent = clogModal

    local cmStroke = Instance.new("UIStroke")
    cmStroke.Color = Theme.Border
    cmStroke.Thickness = 1
    cmStroke.Transparency = 1
    cmStroke.Parent = clogModal

    local cmTitle = Instance.new("TextLabel")
    cmTitle.Size = UDim2.new(1, -40, 0, 36)
    cmTitle.Position = UDim2.new(0, 14, 0, 0)
    cmTitle.BackgroundTransparency = 1
    cmTitle.Text = "HUB v2.0.1 RELEASE NOTES"
    cmTitle.TextColor3 = Theme.Accent
    cmTitle.TextTransparency = 1
    cmTitle.Font = Enum.Font.Gotham
    cmTitle.TextSize = 12
    cmTitle.TextXAlignment = Enum.TextXAlignment.Left
    cmTitle.ZIndex = 302
    cmTitle.Parent = clogModal

    local closeClog = Instance.new("TextButton")
    closeClog.Size = UDim2.new(0, 24, 0, 24)
    closeClog.Position = UDim2.new(1, -32, 0, 6)
    closeClog.BackgroundColor3 = Theme.ElementBg
    closeClog.BackgroundTransparency = 1
    closeClog.Text = "x"
    closeClog.TextColor3 = Theme.TextSecondary
    closeClog.TextTransparency = 1
    closeClog.Font = Enum.Font.Gotham
    closeClog.TextSize = 11
    closeClog.BorderSizePixel = 0
    closeClog.ZIndex = 302
    closeClog.Parent = clogModal

    local ccCorner = Instance.new("UICorner")
    ccCorner.CornerRadius = UDim.new(0, 4)
    ccCorner.Parent = closeClog

    closeClog.MouseEnter:Connect(function()
        glij(closeClog, {BackgroundColor3 = Theme.Red, TextColor3 = Theme.Accent}, 0.12)
    end)
    closeClog.MouseLeave:Connect(function()
        glij(closeClog, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextSecondary}, 0.12)
    end)

    local clScroll = Instance.new("ScrollingFrame")
    clScroll.Size = UDim2.new(1, -24, 1, -50)
    clScroll.Position = UDim2.new(0, 12, 0, 40)
    clScroll.BackgroundTransparency = 1
    clScroll.BorderSizePixel = 0
    clScroll.ScrollBarThickness = 2
    clScroll.ScrollBarImageColor3 = Theme.BorderBright
    clScroll.ScrollBarImageTransparency = 1
    clScroll.CanvasSize = UDim2.new(0, 0, 0, 420)
    clScroll.ZIndex = 302
    clScroll.Parent = clogModal

    local clText = Instance.new("TextLabel")
    clText.Size = UDim2.new(1, -10, 1, 0)
    clText.BackgroundTransparency = 1
    clText.Text = "Welcome to Hub v2.0.1!\n\n[ UI & VISUAL ENGINE ]\n* Glassmorphism & Frosted Glass Blocks with neon glow borders\n* Mini-mode Collapsible Sidebar with clean ASCII labels\n* Tactile Window Resizer Grip with boundary clamping\n* Player Profile Card (Avatar Headshot, Username, Live Account Age)\n* Section Accordion Collapsers & Dynamic Hover Tooltips\n* Animated Typewriter Boot Splash Screen & Clean Typography\n\n[ QUALITY OF LIFE SUITE ]\n* Universal Real-Time Feature Search Bar with instant filtering\n* Interactive Right-Click Context Menu on all hub controls\n* Dedicated Favorites Tab with linked bidirectional control sync\n* Custom Keybind Rebinding Engine with keyboard capture modal\n* Auto-Fade on Roblox Chat Focus (smooth 90% opacity drop)\n* Inertia Momentum Scrolling across all hub tabs\n* Auto-Respawn Loadout Restore (Flight, Speed, ESP, Tools auto-applied)\n* Silent Chat Interceptor (;fly, ;noclip, ;speed, ;esp, ;tp, ;rejoin)\n* Section Master Switches ([ALL] batch toggles)\n* Multi-Profile Config Engine & JSON Clipboard Exporter/Importer\n\n[ SCRIPT & EXPLOIT ENGINE ]\n* Desync & Micro Lag Switch [F4] with HUD status monitor\n* Custom Remote Event Trigger Automator & Macro Builder\n* 0-Register Scope Isolation avoiding Luau 200 crash limit\n* Client-Side Only Strict LocalScript Security"
    clText.TextColor3 = Theme.TextPrimary
    clText.TextTransparency = 1
    clText.Font = Enum.Font.Gotham
    clText.TextSize = 10
    clText.TextXAlignment = Enum.TextXAlignment.Left
    clText.TextYAlignment = Enum.TextYAlignment.Top
    clText.TextWrapped = true
    clText.ZIndex = 302
    clText.Parent = clScroll

    local function openChangelog()
        clogOverlay.Visible = true
        glij(clogOverlay, {BackgroundTransparency = 0.4}, 0.25)
        glij(clogModal, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        glij(cmStroke, {Transparency = 0}, 0.25)
        glij(cmTitle, {TextTransparency = 0}, 0.25)
        glij(closeClog, {BackgroundTransparency = 0, TextTransparency = 0}, 0.25)
        glij(clText, {TextTransparency = 0}, 0.25)
        glij(clScroll, {ScrollBarImageTransparency = 0}, 0.25)
    end

    closeClog.MouseButton1Click:Connect(function()
        glij(clogOverlay, {BackgroundTransparency = 1}, 0.18)
        glij(clogModal, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -20)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        glij(cmStroke, {Transparency = 1}, 0.18)
        glij(cmTitle, {TextTransparency = 1}, 0.18)
        glij(closeClog, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
        glij(clText, {TextTransparency = 1}, 0.18)
        glij(clScroll, {ScrollBarImageTransparency = 1}, 0.18).Completed:Connect(function()
            clogOverlay.Visible = false
        end)
    end)

    local settingsTab = nil
    for _, t in ipairs(AllTabs) do
        if t.Name == "Settings" then
            settingsTab = t
            break
        end
    end
    if settingsTab then
        settingsTab:AddButton("View Patch Notes (Changelog)", function()
            openChangelog()
        end)
    end
end

do
    melding("AikHub", "Venus UI Loaded - Press RightShift or [HUB] to toggle", 3.5, Theme.Green)
end
