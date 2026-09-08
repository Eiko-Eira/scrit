local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startWait = os.clock()
    while not LocalPlayer and (os.clock() - startWait) < 5 do
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
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    return pg
end

local guiParent = getGuiParent()
do
    pcall(function()
        if guiParent:FindFirstChild("NIXMetaHookUI") then
            guiParent.NIXMetaHookUI:Destroy()
        end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("NIXMetaHookUI") then
            pg.NIXMetaHookUI:Destroy()
        end
    end)
end

local Theme = {
    Background = Color3.fromRGB(10, 10, 14),
    Header = Color3.fromRGB(14, 14, 20),
    Sidebar = Color3.fromRGB(12, 12, 16),
    TabActive = Color3.fromRGB(240, 240, 245),
    TabActiveText = Color3.fromRGB(10, 10, 14),
    TabInactive = Color3.fromRGB(18, 18, 24),
    TabInactiveText = Color3.fromRGB(130, 130, 145),
    Accent = Color3.fromRGB(0, 230, 160),
    AccentDim = Color3.fromRGB(0, 170, 120),
    Cyan = Color3.fromRGB(0, 195, 255),
    ElementBg = Color3.fromRGB(16, 16, 22),
    ElementHover = Color3.fromRGB(24, 24, 34),
    ElementActive = Color3.fromRGB(32, 32, 44),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(125, 125, 138),
    Border = Color3.fromRGB(34, 34, 46),
    BorderBright = Color3.fromRGB(55, 55, 75),
    Green = Color3.fromRGB(70, 220, 120),
    Red = Color3.fromRGB(230, 70, 80),
    Yellow = Color3.fromRGB(240, 190, 60)
}

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, props)
    anim:Play()
    return anim
end

local globalEnv = (getgenv and getgenv()) or _G

local EngineState = {
    HookActive = true,
    HoneypotShield = true,
    ArgumentTamper = false,
    TamperMultiplier = 2,
    RemoteSpyEnabled = true,
    HookEngineInstalled = false,
    HookEngineType = "None",
    CurrentMethod = "FireServer",
    ActiveHookCallback = nil,
    OriginalFireServer = nil,
    OriginalInvokeServer = nil,
    InterceptedCount = 0,
    DroppedCount = 0,
    TamperedCount = 0,
    Logs = {},
    MaxLogs = 120,
    InterceptedPackets = {},
    MaxPackets = 50,
    ScanResults = {},
    ScanScore = 0,
    ScanTotal = 0,
    TestResults = {},
    TestsRunning = false,
    AutoScrollSpy = true,
    AutoScrollLogs = true
}

local blockedHoneypots = {
    BanMe = true,
    BlacklistPlayer = true,
    KickMe = true,
    ManuBan = true,
    Manuunban = true,
    FullDatWipe = true,
    UnlockWipeButton = true,
    DetectionCheck = true,
    ReportExploit = true,
    SecurityAlert = true
}

local function addConsoleLog(tag, msg, color)
    color = color or Theme.TextPrimary
    local timestamp = os.date("%X")
    local entry = {
        Time = timestamp,
        Tag = tag,
        Message = tostring(msg),
        Color = color
    }
    table.insert(EngineState.Logs, entry)
    if #EngineState.Logs > EngineState.MaxLogs then
        table.remove(EngineState.Logs, 1)
    end
    print(string.format("[%s] [%s] %s", timestamp, tag, tostring(msg)))
    if EngineState.RefreshLogsUI then
        task.spawn(EngineState.RefreshLogsUI)
    end
end

local function serializeVal(v, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local tv = typeof(v)
    if tv == "string" then
        return string.format("%q", v)
    elseif tv == "number" or tv == "boolean" then
        return tostring(v)
    elseif tv == "nil" then
        return "nil"
    elseif tv == "Instance" then
        return string.format("Instance(%s)", v.Name)
    elseif tv == "Vector3" then
        return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
    elseif tv == "CFrame" then
        return string.format("CF(%.1f,%.1f,%.1f)", v.Position.X, v.Position.Y, v.Position.Z)
    elseif tv == "table" then
        local parts = {}
        local count = 0
        for k, sub in pairs(v) do
            count = count + 1
            if count > 4 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, string.format("%s=%s", tostring(k), serializeVal(sub, depth + 1)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end

local function serializeArgs(args)
    local list = {}
    for i, a in ipairs(args) do
        table.insert(list, string.format("[%d]=%s", i, serializeVal(a, 0)))
    end
    return table.concat(list, ", ")
end

local dummyRemoteEvent = Instance.new("RemoteEvent")
local dummyRemoteFunction = Instance.new("RemoteFunction")

local function setupMetahookEngine()
    if globalEnv.hookmetamethod and globalEnv.getnamecallmethod and (not globalEnv.__NIX_FORCE_POLYFILL) then
        EngineState.HookEngineType = "Native UNC"
        EngineState.HookEngineInstalled = true
        addConsoleLog("ENGINE", "Native hookmetamethod detected in executor environment", Theme.Green)
        return true
    end

    local hf = hookfunction or replaceclosure
    if not hf then
        EngineState.HookEngineType = "None (Missing hookfunction)"
        EngineState.HookEngineInstalled = false
        addConsoleLog("ENGINE", "Failed to build metahook: hookfunction is missing", Theme.Red)
        return false
    end

    local nc = newcclosure or function(f) return f end

    globalEnv.getnamecallmethod = function()
        return EngineState.CurrentMethod or "FireServer"
    end

    globalEnv.setnamecallmethod = function(m)
        EngineState.CurrentMethod = tostring(m)
    end

    globalEnv.hookmetamethod = function(target, method, callback)
        if method == "__namecall" then
            local prev = EngineState.ActiveHookCallback
            EngineState.ActiveHookCallback = callback
            return function(self, ...)
                if EngineState.CurrentMethod == "InvokeServer" and EngineState.OriginalInvokeServer then
                    return EngineState.OriginalInvokeServer(self, ...)
                elseif EngineState.OriginalFireServer then
                    return EngineState.OriginalFireServer(self, ...)
                end
            end
        end
        return nil
    end

    local fireOk, fireErr = pcall(function()
        EngineState.OriginalFireServer = hf(dummyRemoteEvent.FireServer, nc(function(self, ...)
            local args = {...}
            EngineState.InterceptedCount = EngineState.InterceptedCount + 1

            if EngineState.HoneypotShield and self and blockedHoneypots[self.Name] then
                EngineState.DroppedCount = EngineState.DroppedCount + 1
                addConsoleLog("SHIELD", "Blocked malicious honeypot: " .. self.Name, Theme.Red)
                return nil
            end

            if EngineState.ArgumentTamper then
                for i = 1, #args do
                    if typeof(args[i]) == "number" then
                        args[i] = args[i] * EngineState.TamperMultiplier
                    end
                end
                EngineState.TamperedCount = EngineState.TamperedCount + 1
            end

            if EngineState.RemoteSpyEnabled and self then
                local packet = {
                    Time = os.date("%X"),
                    Method = "FireServer",
                    Name = tostring(self.Name),
                    Remote = self,
                    Args = args,
                    Summary = serializeArgs(args),
                    Action = (EngineState.ArgumentTamper and "Tampered") or "Forwarded"
                }
                table.insert(EngineState.InterceptedPackets, packet)
                if #EngineState.InterceptedPackets > EngineState.MaxPackets then
                    table.remove(EngineState.InterceptedPackets, 1)
                end
                if EngineState.RefreshSpyUI then
                    task.spawn(EngineState.RefreshSpyUI)
                end
            end

            if EngineState.HookActive and EngineState.ActiveHookCallback then
                EngineState.CurrentMethod = "FireServer"
                local ret = EngineState.ActiveHookCallback(self, table.unpack(args))
                if ret ~= nil then return ret end
            end

            return EngineState.OriginalFireServer(self, table.unpack(args))
        end))
    end)

    local invokeOk, invokeErr = pcall(function()
        EngineState.OriginalInvokeServer = hf(dummyRemoteFunction.InvokeServer, nc(function(self, ...)
            local args = {...}
            EngineState.InterceptedCount = EngineState.InterceptedCount + 1

            if EngineState.HoneypotShield and self and blockedHoneypots[self.Name] then
                EngineState.DroppedCount = EngineState.DroppedCount + 1
                addConsoleLog("SHIELD", "Blocked honeypot invoke: " .. self.Name, Theme.Red)
                return nil
            end

            if EngineState.RemoteSpyEnabled and self then
                local packet = {
                    Time = os.date("%X"),
                    Method = "InvokeServer",
                    Name = tostring(self.Name),
                    Remote = self,
                    Args = args,
                    Summary = serializeArgs(args),
                    Action = "Forwarded"
                }
                table.insert(EngineState.InterceptedPackets, packet)
                if #EngineState.InterceptedPackets > EngineState.MaxPackets then
                    table.remove(EngineState.InterceptedPackets, 1)
                end
                if EngineState.RefreshSpyUI then
                    task.spawn(EngineState.RefreshSpyUI)
                end
            end

            if EngineState.HookActive and EngineState.ActiveHookCallback then
                EngineState.CurrentMethod = "InvokeServer"
                local ret = EngineState.ActiveHookCallback(self, table.unpack(args))
                if ret ~= nil then return ret end
            end

            return EngineState.OriginalInvokeServer(self, table.unpack(args))
        end))
    end)

    if fireOk and invokeOk then
        EngineState.HookEngineType = "Polyfilled (via hookfunction)"
        EngineState.HookEngineInstalled = true
        addConsoleLog("ENGINE", "Forced hookmetamethod polyfill installed successfully!", Theme.Green)
        return true
    else
        EngineState.HookEngineType = "Partial/Failed"
        EngineState.HookEngineInstalled = false
        addConsoleLog("ENGINE", "Engine hook error: " .. tostring(fireErr or invokeErr), Theme.Red)
        return false
    end
end

if not globalEnv.getrawmetatable then
    if debug and debug.getmetatable then
        globalEnv.getrawmetatable = debug.getmetatable
        addConsoleLog("POLYFILL", "Aliased getrawmetatable -> debug.getmetatable", Theme.Cyan)
    end
end

if not globalEnv.setreadonly then
    if make_writeable and make_readonly then
        globalEnv.setreadonly = function(t, val)
            if val then make_readonly(t) else make_writeable(t) end
        end
        addConsoleLog("POLYFILL", "Aliased setreadonly -> make_writeable/readonly", Theme.Cyan)
    end
end

local function runSystemCapabilityScan()
    local scanList = {
        {"hookmetamethod", function() return typeof(globalEnv.hookmetamethod) == "function" end, "Metamethod hooker"},
        {"getnamecallmethod", function() return typeof(globalEnv.getnamecallmethod) == "function" end, "Active namecall query"},
        {"setnamecallmethod", function() return typeof(globalEnv.setnamecallmethod) == "function" end, "Override namecall method"},
        {"getrawmetatable", function() return typeof(globalEnv.getrawmetatable) == "function" end, "Bypass locked metatables"},
        {"setreadonly", function() return typeof(globalEnv.setreadonly or setreadonly or make_writeable) == "function" end, "Toggle table writability"},
        {"isreadonly", function() return typeof(globalEnv.isreadonly or isreadonly) == "function" end, "Check table writability"},
        {"hookfunction", function() return typeof(globalEnv.hookfunction or hookfunction or replaceclosure) == "function" end, "C and Lua function detour"},
        {"newcclosure", function() return typeof(globalEnv.newcclosure or newcclosure) == "function" end, "Wrap Lua closure as C function"},
        {"iscclosure", function() return typeof(globalEnv.iscclosure or iscclosure) == "function" end, "Detect C closures"},
        {"islclosure", function() return typeof(globalEnv.islclosure or islclosure) == "function" end, "Detect Lua closures"},
        {"clonefunction", function() return typeof(globalEnv.clonefunction or clonefunction) == "function" end, "Clone closure instance"},
        {"getgenv", function() return typeof(getgenv) == "function" end, "Global executor environment"},
        {"getrenv", function() return typeof(getrenv) == "function" end, "Roblox game environment"},
        {"getreg", function() return typeof(getreg) == "function" end, "Luau registry table"},
        {"getgc", function() return typeof(getgc) == "function" end, "Garbage collector table scan"},
        {"checkcaller", function() return typeof(checkcaller) == "function" end, "Check if thread is executor"},
        {"identifyexecutor", function() return typeof(identifyexecutor or getexecutorname) == "function" end, "Query executor signature"},
        {"getinstances", function() return typeof(getinstances) == "function" end, "Query all game instances"},
        {"getnilinstances", function() return typeof(getnilinstances) == "function" end, "Query parentless instances"},
        {"getloadedmodules", function() return typeof(getloadedmodules) == "function" end, "Query loaded ModuleScripts"},
        {"fireclickdetector", function() return typeof(fireclickdetector) == "function" end, "Simulate click detector"},
        {"fireproximityprompt", function() return typeof(fireproximityprompt) == "function" end, "Simulate proximity prompt"},
        {"firetouchinterest", function() return typeof(firetouchinterest) == "function" end, "Simulate touch collision"},
        {"readfile", function() return typeof(readfile) == "function" end, "Filesystem read file"},
        {"writefile", function() return typeof(writefile) == "function" end, "Filesystem write file"},
        {"isfile", function() return typeof(isfile) == "function" end, "Filesystem check file"},
        {"isfolder", function() return typeof(isfolder) == "function" end, "Filesystem check folder"},
        {"makefolder", function() return typeof(makefolder) == "function" end, "Filesystem create folder"},
        {"request", function() return typeof(request or http_request or (syn and syn.request)) == "function" end, "HTTP custom request"},
        {"rconsoleprint", function() return typeof(rconsoleprint or printconsole) == "function" end, "Print to external console"},
        {"setclipboard", function() return typeof(setclipboard or toclipboard) == "function" end, "Write to system clipboard"}
    }

    local results = {}
    local passed = 0
    local total = #scanList

    for _, item in ipairs(scanList) do
        local name = item[1]
        local checkFn = item[2]
        local desc = item[3]
        local ok, res = pcall(checkFn)
        local status = "FAIL"
        if ok and res then
            status = "PASS"
            passed = passed + 1
        elseif name == "hookmetamethod" and EngineState.HookEngineInstalled then
            status = "POLYFILLED"
            passed = passed + 1
        elseif name == "getnamecallmethod" and globalEnv.getnamecallmethod then
            status = "POLYFILLED"
            passed = passed + 1
        end

        table.insert(results, {
            Name = name,
            Status = status,
            Description = desc
        })
    end

    EngineState.ScanResults = results
    EngineState.ScanScore = passed
    EngineState.ScanTotal = total

    local pct = math.floor((passed / total) * 100)
    addConsoleLog("SCANNER", string.format("System scan complete: %d/%d passed (%d%% UNC capability)", passed, total, pct), Theme.Green)
    if EngineState.RefreshScanUI then
        task.spawn(EngineState.RefreshScanUI)
    end
end

local function runFullTestSuite()
    if EngineState.TestsRunning then return end
    EngineState.TestsRunning = true
    EngineState.TestResults = {}
    addConsoleLog("TEST", "Starting full functional test suite...", Theme.Yellow)

    local function recordTest(name, passed, detail)
        table.insert(EngineState.TestResults, {
            Name = name,
            Passed = passed,
            Detail = detail
        })
        local tagColor = passed and Theme.Green or Theme.Red
        addConsoleLog("TEST", string.format("[%s] %s: %s", passed and "PASS" or "FAIL", name, detail), tagColor)
        if EngineState.RefreshTestsUI then
            task.spawn(EngineState.RefreshTestsUI)
        end
    end

    task.spawn(function()
        local t1Ok = (typeof(globalEnv.hookmetamethod) == "function")
        recordTest("Hookmetamethod Presence", t1Ok, t1Ok and "Function is callable globally" or "hookmetamethod is nil")
        task.wait(0.1)

        local t2Ok = false
        pcall(function()
            if globalEnv.getnamecallmethod then
                local m = globalEnv.getnamecallmethod()
                t2Ok = (typeof(m) == "string")
            end
        end)
        recordTest("Namecall Method Detection", t2Ok, t2Ok and "getnamecallmethod returned string" or "Failed to query namecall method")
        task.wait(0.1)

        local t3Ok = false
        local t3Detail = "Failed"
        pcall(function()
            local hf = hookfunction or replaceclosure
            if hf then
                local testFn = function(a, b) return a + b end
                local oldFn
                oldFn = hf(testFn, function(a, b) return (a + b) * 2 end)
                local res = testFn(3, 4)
                if res == 14 then
                    t3Ok = true
                    t3Detail = "Closure detour intercepted and altered math result"
                else
                    t3Detail = "Detour ran but returned: " .. tostring(res)
                end
            else
                t3Detail = "hookfunction not available"
            end
        end)
        recordTest("Hookfunction Closure Detour", t3Ok, t3Detail)
        task.wait(0.1)

        local t4Ok = false
        local t4Detail = "Failed"
        pcall(function()
            if newcclosure then
                local wrapped = newcclosure(function(v) return v * 3 end)
                if wrapped(5) == 15 then
                    t4Ok = true
                    t4Detail = "newcclosure wrapped closure executed correctly"
                end
            else
                t4Detail = "newcclosure is nil in environment"
            end
        end)
        recordTest("Newcclosure Wrapper Test", t4Ok, t4Detail)
        task.wait(0.1)

        local t5Ok = false
        local t5Detail = "Failed"
        local testRemote = Instance.new("RemoteEvent")
        testRemote.Name = "NIXTestRemote"
        local intercepted = false
        local originalHook = EngineState.ActiveHookCallback

        EngineState.ActiveHookCallback = function(self, ...)
            if self == testRemote then
                intercepted = true
                return true
            end
            if originalHook then return originalHook(self, ...) end
        end

        local fireTestOk = pcall(function()
            testRemote:FireServer("NIX_VERIFICATION_PAYLOAD", 12345)
        end)

        task.wait(0.15)
        if intercepted then
            t5Ok = true
            t5Detail = "Remote:FireServer successfully caught by hook engine"
        else
            t5Detail = "Remote:FireServer was not intercepted"
        end
        EngineState.ActiveHookCallback = originalHook
        testRemote:Destroy()
        recordTest("Simulated RemoteEvent Intercept", t5Ok, t5Detail)
        task.wait(0.1)

        local t6Ok = false
        local t6Detail = "Failed"
        local testFunc = Instance.new("RemoteFunction")
        testFunc.Name = "NIXTestFunction"
        local funcIntercepted = false

        EngineState.ActiveHookCallback = function(self, ...)
            if self == testFunc then
                funcIntercepted = true
                return {Spoofed = true, Code = 999}
            end
            if originalHook then return originalHook(self, ...) end
        end

        pcall(function()
            testFunc:InvokeServer("QUERY_DATA")
        end)

        task.wait(0.15)
        if funcIntercepted then
            t6Ok = true
            t6Detail = "Remote:InvokeServer caught and spoofed return payload"
        else
            t6Detail = "InvokeServer call bypassed hook"
        end
        EngineState.ActiveHookCallback = originalHook
        testFunc:Destroy()
        recordTest("Simulated InvokeServer Spoof", t6Ok, t6Detail)
        task.wait(0.1)

        local t7Ok = false
        local honeypotRemote = Instance.new("RemoteEvent")
        honeypotRemote.Name = "BanMe"
        local initialDropped = EngineState.DroppedCount

        pcall(function()
            honeypotRemote:FireServer("SHOULD_BE_BLOCKED")
        end)

        task.wait(0.15)
        if EngineState.DroppedCount > initialDropped then
            t7Ok = true
            recordTest("Honeypot Drop Defense", true, "Malicious remote BanMe blocked from dispatching")
        else
            recordTest("Honeypot Drop Defense", false, "Honeypot was not filtered")
        end
        honeypotRemote:Destroy()
        task.wait(0.1)

        local t8Ok = false
        local tamperRemote = Instance.new("RemoteEvent")
        tamperRemote.Name = "NIXTamperRemote"
        local oldTamperState = EngineState.ArgumentTamper
        local caughtNumber = 0

        EngineState.ArgumentTamper = true
        EngineState.TamperMultiplier = 10

        EngineState.ActiveHookCallback = function(self, numVal)
            if self == tamperRemote then
                caughtNumber = numVal
                return true
            end
            if originalHook then return originalHook(self, numVal) end
        end

        pcall(function()
            tamperRemote:FireServer(25)
        end)

        task.wait(0.15)
        if caughtNumber == 250 then
            t8Ok = true
            recordTest("Argument Tamper Multiplier", true, "Numeric argument 25 multiplied to 250")
        else
            recordTest("Argument Tamper Multiplier", false, "Value expected 250, received: " .. tostring(caughtNumber))
        end

        EngineState.ArgumentTamper = oldTamperState
        EngineState.ActiveHookCallback = originalHook
        tamperRemote:Destroy()

        EngineState.TestsRunning = false
        addConsoleLog("TEST", "Diagnostic suite completed!", Theme.Green)
    end)
end

setupMetahookEngine()
runSystemCapabilityScan()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXMetaHookUI"
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
MainFrame.Size = UDim2.new(0, 680, 0, 480)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
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
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 2)
topAccent.Position = UDim2.new(0, 0, 0, 0)
topAccent.BackgroundColor3 = Theme.Accent
topAccent.BorderSizePixel = 0
topAccent.Parent = TopBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 240, 1, 0)
titleLbl.Position = UDim2.new(0, 14, 0, 2)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "N I X  M E T A H O O K"
titleLbl.TextColor3 = Theme.TextPrimary
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = TopBar

local subTitleLbl = Instance.new("TextLabel")
subTitleLbl.Size = UDim2.new(0, 220, 1, 0)
subTitleLbl.Position = UDim2.new(0, 175, 0, 2)
subTitleLbl.BackgroundTransparency = 1
subTitleLbl.Text = "SYSTEM SCANNER & HOOK ENGINE"
subTitleLbl.TextColor3 = Theme.TextSecondary
subTitleLbl.Font = Enum.Font.Gotham
subTitleLbl.TextSize = 10
subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
subTitleLbl.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Theme.ElementBg
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 5)
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
        tw(MainFrame, {Size = UDim2.new(0, 680, 0, 480), BackgroundTransparency = 0}, 0.2, Enum.EasingStyle.Quad)
    else
        tw(MainFrame, {Size = UDim2.new(0, 680, 0, 0), BackgroundTransparency = 1}, 0.16).Completed:Connect(function()
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
Sidebar.Size = UDim2.new(0, 150, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
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
sbPad.PaddingTop = UDim.new(0, 10)
sbPad.PaddingLeft = UDim.new(0, 8)
sbPad.PaddingRight = UDim.new(0, 8)
sbPad.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -44)
ContentArea.Position = UDim2.new(0, 150, 0, 44)
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
    bPad.PaddingLeft = UDim.new(0, 12)
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

local EngineTab = createTab("Dashboard")
local ScannerTab = createTab("System Scan")
local TestTab = createTab("Test Suite")
local SpyTab = createTab("Remote Spy")
local ConsoleTab = createTab("Logs")

local function buildDashboard(tab)
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = Theme.BorderBright
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.Parent = tab.Page

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, 0, 0, 85)
    statusCard.BackgroundColor3 = Theme.ElementBg
    statusCard.BorderSizePixel = 0
    statusCard.Parent = container

    Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 6)
    local scStroke = Instance.new("UIStroke", statusCard)
    scStroke.Color = Theme.Border
    scStroke.Thickness = 1

    local scTitle = Instance.new("TextLabel")
    scTitle.Size = UDim2.new(1, -20, 0, 20)
    scTitle.Position = UDim2.new(0, 12, 0, 8)
    scTitle.BackgroundTransparency = 1
    scTitle.Text = "HOOK ENGINE STATUS"
    scTitle.TextColor3 = Theme.Accent
    scTitle.Font = Enum.Font.GothamBold
    scTitle.TextSize = 11
    scTitle.TextXAlignment = Enum.TextXAlignment.Left
    scTitle.Parent = statusCard

    local engineTypeLbl = Instance.new("TextLabel")
    engineTypeLbl.Size = UDim2.new(1, -20, 0, 18)
    engineTypeLbl.Position = UDim2.new(0, 12, 0, 32)
    engineTypeLbl.BackgroundTransparency = 1
    engineTypeLbl.Text = "Engine Mode: " .. tostring(EngineState.HookEngineType)
    engineTypeLbl.TextColor3 = Theme.TextPrimary
    engineTypeLbl.Font = Enum.Font.Gotham
    engineTypeLbl.TextSize = 11
    engineTypeLbl.TextXAlignment = Enum.TextXAlignment.Left
    engineTypeLbl.Parent = statusCard

    local execName = "Unknown"
    pcall(function()
        if identifyexecutor then execName = identifyexecutor() end
    end)
    local execLbl = Instance.new("TextLabel")
    execLbl.Size = UDim2.new(1, -20, 0, 18)
    execLbl.Position = UDim2.new(0, 12, 0, 54)
    execLbl.BackgroundTransparency = 1
    execLbl.Text = "Active Executor: " .. tostring(execName)
    execLbl.TextColor3 = Theme.TextSecondary
    execLbl.Font = Enum.Font.Gotham
    execLbl.TextSize = 10
    execLbl.TextXAlignment = Enum.TextXAlignment.Left
    execLbl.Parent = statusCard

    local statsRow = Instance.new("Frame")
    statsRow.Size = UDim2.new(1, 0, 0, 60)
    statsRow.BackgroundTransparency = 1
    statsRow.Parent = container

    local sLayout = Instance.new("UIGridLayout")
    sLayout.CellSize = UDim2.new(0.315, 0, 1, 0)
    sLayout.CellPadding = UDim2.new(0.027, 0, 0, 0)
    sLayout.Parent = statsRow

    local function createStatBox(label, initVal, color)
        local box = Instance.new("Frame")
        box.BackgroundColor3 = Theme.ElementBg
        box.BorderSizePixel = 0
        box.Parent = statsRow
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local bst = Instance.new("UIStroke", box)
        bst.Color = Theme.Border
        bst.Thickness = 1

        local blbl = Instance.new("TextLabel")
        blbl.Size = UDim2.new(1, -10, 0, 18)
        blbl.Position = UDim2.new(0, 8, 0, 6)
        blbl.BackgroundTransparency = 1
        blbl.Text = label
        blbl.TextColor3 = Theme.TextSecondary
        blbl.Font = Enum.Font.Gotham
        blbl.TextSize = 9
        blbl.TextXAlignment = Enum.TextXAlignment.Left
        blbl.Parent = box

        local vlbl = Instance.new("TextLabel")
        vlbl.Size = UDim2.new(1, -10, 0, 26)
        vlbl.Position = UDim2.new(0, 8, 0, 26)
        vlbl.BackgroundTransparency = 1
        vlbl.Text = tostring(initVal)
        vlbl.TextColor3 = color or Theme.TextPrimary
        vlbl.Font = Enum.Font.GothamBold
        vlbl.TextSize = 16
        vlbl.TextXAlignment = Enum.TextXAlignment.Left
        vlbl.Parent = box
        return vlbl
    end

    local interceptedValLbl = createStatBox("TOTAL INTERCEPTED", 0, Theme.Cyan)
    local droppedValLbl = createStatBox("HONEYPOTS DROPPED", 0, Theme.Red)
    local tamperedValLbl = createStatBox("ARGUMENTS TAMPERED", 0, Theme.Yellow)

    local function createToggleRow(label, defaultState, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Theme.ElementBg
        row.BorderSizePixel = 0
        row.Parent = container
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        local rst = Instance.new("UIStroke", row)
        rst.Color = Theme.Border
        rst.Thickness = 1

        local rTitle = Instance.new("TextLabel")
        rTitle.Size = UDim2.new(1, -70, 1, 0)
        rTitle.Position = UDim2.new(0, 12, 0, 0)
        rTitle.BackgroundTransparency = 1
        rTitle.Text = label
        rTitle.TextColor3 = Theme.TextPrimary
        rTitle.Font = Enum.Font.Gotham
        rTitle.TextSize = 11
        rTitle.TextXAlignment = Enum.TextXAlignment.Left
        rTitle.Parent = row

        local tBtn = Instance.new("TextButton")
        tBtn.Size = UDim2.new(0, 44, 0, 22)
        tBtn.Position = UDim2.new(1, -54, 0.5, -11)
        tBtn.BackgroundColor3 = defaultState and Theme.Accent or Theme.Header
        tBtn.Text = defaultState and "ON" or "OFF"
        tBtn.TextColor3 = defaultState and Theme.TabActiveText or Theme.TextSecondary
        tBtn.Font = Enum.Font.GothamBold
        tBtn.TextSize = 10
        tBtn.BorderSizePixel = 0
        tBtn.Parent = row
        Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

        local state = defaultState
        tBtn.MouseButton1Click:Connect(function()
            state = not state
            tBtn.Text = state and "ON" or "OFF"
            tw(tBtn, {
                BackgroundColor3 = state and Theme.Accent or Theme.Header,
                TextColor3 = state and Theme.TabActiveText or Theme.TextSecondary
            }, 0.12)
            if callback then callback(state) end
        end)
    end

    createToggleRow("Enable Metahook & Remote Detour", EngineState.HookActive, function(v)
        EngineState.HookActive = v
        addConsoleLog("ENGINE", "Hook engine " .. (v and "ENABLED" or "DISABLED"), v and Theme.Green or Theme.Red)
    end)

    createToggleRow("Honeypot Shield (Drop malicious ban events)", EngineState.HoneypotShield, function(v)
        EngineState.HoneypotShield = v
        addConsoleLog("SHIELD", "Honeypot shield " .. (v and "ENABLED" or "DISABLED"), v and Theme.Green or Theme.Red)
    end)

    createToggleRow("Argument Tamperer (Multiply outgoing numbers)", EngineState.ArgumentTamper, function(v)
        EngineState.ArgumentTamper = v
        addConsoleLog("TAMPER", "Number tamperer " .. (v and "ENABLED" or "DISABLED"), v and Theme.Green or Theme.Red)
    end)

    createToggleRow("Live Remote Spy Interception", EngineState.RemoteSpyEnabled, function(v)
        EngineState.RemoteSpyEnabled = v
        addConsoleLog("SPY", "Remote spy " .. (v and "ENABLED" or "DISABLED"), v and Theme.Green or Theme.Red)
    end)

    RunService.Heartbeat:Connect(function()
        interceptedValLbl.Text = tostring(EngineState.InterceptedCount)
        droppedValLbl.Text = tostring(EngineState.DroppedCount)
        tamperedValLbl.Text = tostring(EngineState.TamperedCount)
    end)
end

local function buildScannerTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local scoreLbl = Instance.new("TextLabel")
    scoreLbl.Size = UDim2.new(0.6, 0, 1, 0)
    scoreLbl.BackgroundTransparency = 1
    scoreLbl.Text = "UNC Score: Calculating..."
    scoreLbl.TextColor3 = Theme.Accent
    scoreLbl.Font = Enum.Font.GothamBold
    scoreLbl.TextSize = 12
    scoreLbl.TextXAlignment = Enum.TextXAlignment.Left
    scoreLbl.Parent = topRow

    local rescanBtn = Instance.new("TextButton")
    rescanBtn.Size = UDim2.new(0, 100, 0, 28)
    rescanBtn.Position = UDim2.new(1, -100, 0.5, -14)
    rescanBtn.BackgroundColor3 = Theme.ElementBg
    rescanBtn.Text = "RESCAN"
    rescanBtn.TextColor3 = Theme.TextPrimary
    rescanBtn.Font = Enum.Font.GothamBold
    rescanBtn.TextSize = 10
    rescanBtn.BorderSizePixel = 0
    rescanBtn.Parent = topRow
    Instance.new("UICorner", rescanBtn).CornerRadius = UDim.new(0, 4)
    local rbStroke = Instance.new("UIStroke", rescanBtn)
    rbStroke.Color = Theme.Border
    rbStroke.Thickness = 1

    rescanBtn.MouseButton1Click:Connect(function()
        tw(rescanBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.TabActiveText}, 0.1).Completed:Connect(function()
            tw(rescanBtn, {BackgroundColor3 = Theme.ElementBg, TextColor3 = Theme.TextPrimary}, 0.12)
        end)
        runSystemCapabilityScan()
    end)

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 1, -44)
    listFrame.Position = UDim2.new(0, 0, 0, 44)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 2
    listFrame.ScrollBarImageColor3 = Theme.BorderBright
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.Parent = tab.Page

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listFrame

    local function refreshScanUI()
        listFrame:ClearAllChildren()
        listLayout:Clone().Parent = listFrame

        local pct = math.floor((EngineState.ScanScore / math.max(EngineState.ScanTotal, 1)) * 100)
        scoreLbl.Text = string.format("UNC Compatibility: %d/%d (%d%%)", EngineState.ScanScore, EngineState.ScanTotal, pct)

        for _, item in ipairs(EngineState.ScanResults) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 32)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = listFrame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

            local fnNameLbl = Instance.new("TextLabel")
            fnNameLbl.Size = UDim2.new(0, 150, 1, 0)
            fnNameLbl.Position = UDim2.new(0, 10, 0, 0)
            fnNameLbl.BackgroundTransparency = 1
            fnNameLbl.Text = item.Name
            fnNameLbl.TextColor3 = Theme.TextPrimary
            fnNameLbl.Font = Enum.Font.GothamBold
            fnNameLbl.TextSize = 10
            fnNameLbl.TextXAlignment = Enum.TextXAlignment.Left
            fnNameLbl.Parent = card

            local descLbl = Instance.new("TextLabel")
            descLbl.Size = UDim2.new(1, -260, 1, 0)
            descLbl.Position = UDim2.new(0, 165, 0, 0)
            descLbl.BackgroundTransparency = 1
            descLbl.Text = item.Description
            descLbl.TextColor3 = Theme.TextSecondary
            descLbl.Font = Enum.Font.Gotham
            descLbl.TextSize = 9
            descLbl.TextXAlignment = Enum.TextXAlignment.Left
            descLbl.Parent = card

            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 75, 0, 20)
            badge.Position = UDim2.new(1, -85, 0.5, -10)
            badge.BorderSizePixel = 0
            badge.Font = Enum.Font.GothamBold
            badge.TextSize = 9
            badge.Parent = card
            Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)

            if item.Status == "PASS" then
                badge.BackgroundColor3 = Color3.fromRGB(20, 60, 35)
                badge.TextColor3 = Theme.Green
                badge.Text = "[ PASS ]"
            elseif item.Status == "POLYFILLED" then
                badge.BackgroundColor3 = Color3.fromRGB(15, 45, 65)
                badge.TextColor3 = Theme.Cyan
                badge.Text = "[ POLY ]"
            else
                badge.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
                badge.TextColor3 = Theme.Red
                badge.Text = "[ FAIL ]"
            end
        end
    end

    EngineState.RefreshScanUI = refreshScanUI
    refreshScanUI()
end

local function buildTestTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 36)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local runAllBtn = Instance.new("TextButton")
    runAllBtn.Size = UDim2.new(0, 150, 0, 28)
    runAllBtn.Position = UDim2.new(0, 0, 0.5, -14)
    runAllBtn.BackgroundColor3 = Theme.Accent
    runAllBtn.Text = "RUN TEST SUITE"
    runAllBtn.TextColor3 = Theme.TabActiveText
    runAllBtn.Font = Enum.Font.GothamBold
    runAllBtn.TextSize = 10
    runAllBtn.BorderSizePixel = 0
    runAllBtn.Parent = topRow
    Instance.new("UICorner", runAllBtn).CornerRadius = UDim.new(0, 4)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -165, 1, 0)
    statusLbl.Position = UDim2.new(0, 165, 0, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Click Run to verify all hooks & detours"
    statusLbl.TextColor3 = Theme.TextSecondary
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 10
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent = topRow

    runAllBtn.MouseButton1Click:Connect(function()
        if EngineState.TestsRunning then return end
        statusLbl.Text = "Executing tests in background..."
        runFullTestSuite()
    end)

    local testListFrame = Instance.new("ScrollingFrame")
    testListFrame.Size = UDim2.new(1, 0, 1, -44)
    testListFrame.Position = UDim2.new(0, 0, 0, 44)
    testListFrame.BackgroundTransparency = 1
    testListFrame.BorderSizePixel = 0
    testListFrame.ScrollBarThickness = 2
    testListFrame.ScrollBarImageColor3 = Theme.BorderBright
    testListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    testListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    testListFrame.Parent = tab.Page

    local tLayout = Instance.new("UIListLayout")
    tLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tLayout.Padding = UDim.new(0, 4)
    tLayout.Parent = testListFrame

    local function refreshTestsUI()
        testListFrame:ClearAllChildren()
        tLayout:Clone().Parent = testListFrame

        for _, item in ipairs(EngineState.TestResults) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = testListFrame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -95, 0, 18)
            nameLbl.Position = UDim2.new(0, 10, 0, 4)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = item.Name
            nameLbl.TextColor3 = Theme.TextPrimary
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 10
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = card

            local detailLbl = Instance.new("TextLabel")
            detailLbl.Size = UDim2.new(1, -95, 0, 16)
            detailLbl.Position = UDim2.new(0, 10, 0, 22)
            detailLbl.BackgroundTransparency = 1
            detailLbl.Text = item.Detail
            detailLbl.TextColor3 = Theme.TextSecondary
            detailLbl.Font = Enum.Font.Gotham
            detailLbl.TextSize = 9
            detailLbl.TextXAlignment = Enum.TextXAlignment.Left
            detailLbl.Parent = card

            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 70, 0, 22)
            badge.Position = UDim2.new(1, -80, 0.5, -11)
            badge.BorderSizePixel = 0
            badge.Font = Enum.Font.GothamBold
            badge.TextSize = 9
            badge.Parent = card
            Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)

            if item.Passed then
                badge.BackgroundColor3 = Color3.fromRGB(20, 60, 35)
                badge.TextColor3 = Theme.Green
                badge.Text = "[ PASS ]"
            else
                badge.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
                badge.TextColor3 = Theme.Red
                badge.Text = "[ FAIL ]"
            end
        end

        if not EngineState.TestsRunning and #EngineState.TestResults > 0 then
            statusLbl.Text = "Test suite finished: " .. tostring(#EngineState.TestResults) .. " tests executed"
        end
    end

    EngineState.RefreshTestsUI = refreshTestsUI
end

local function buildSpyTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 32)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 70, 0, 24)
    clearBtn.BackgroundColor3 = Theme.ElementBg
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Theme.TextSecondary
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 9
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = topRow
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

    local spyList = Instance.new("ScrollingFrame")
    spyList.Size = UDim2.new(1, 0, 1, -40)
    spyList.Position = UDim2.new(0, 0, 0, 40)
    spyList.BackgroundTransparency = 1
    spyList.BorderSizePixel = 0
    spyList.ScrollBarThickness = 2
    spyList.ScrollBarImageColor3 = Theme.BorderBright
    spyList.CanvasSize = UDim2.new(0, 0, 0, 0)
    spyList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    spyList.Parent = tab.Page

    local spLayout = Instance.new("UIListLayout")
    spLayout.SortOrder = Enum.SortOrder.LayoutOrder
    spLayout.Padding = UDim.new(0, 4)
    spLayout.Parent = spyList

    clearBtn.MouseButton1Click:Connect(function()
        EngineState.InterceptedPackets = {}
        spyList:ClearAllChildren()
        spLayout:Clone().Parent = spyList
    end)

    local function refreshSpyUI()
        spyList:ClearAllChildren()
        spLayout:Clone().Parent = spyList

        for _, pkt in ipairs(EngineState.InterceptedPackets) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 44)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = spyList
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

            local timeLbl = Instance.new("TextLabel")
            timeLbl.Size = UDim2.new(0, 50, 0, 16)
            timeLbl.Position = UDim2.new(0, 8, 0, 4)
            timeLbl.BackgroundTransparency = 1
            timeLbl.Text = pkt.Time
            timeLbl.TextColor3 = Theme.TextSecondary
            timeLbl.Font = Enum.Font.Gotham
            timeLbl.TextSize = 8
            timeLbl.TextXAlignment = Enum.TextXAlignment.Left
            timeLbl.Parent = card

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -150, 0, 16)
            nameLbl.Position = UDim2.new(0, 62, 0, 4)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = string.format("%s:%s", pkt.Name, pkt.Method)
            nameLbl.TextColor3 = Theme.Cyan
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 10
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = card

            local argsLbl = Instance.new("TextLabel")
            argsLbl.Size = UDim2.new(1, -16, 0, 18)
            argsLbl.Position = UDim2.new(0, 8, 0, 22)
            argsLbl.BackgroundTransparency = 1
            argsLbl.Text = pkt.Summary
            argsLbl.TextColor3 = Theme.TextPrimary
            argsLbl.Font = Enum.Font.Gotham
            argsLbl.TextSize = 9
            argsLbl.TextXAlignment = Enum.TextXAlignment.Left
            argsLbl.ClipsDescendants = true
            argsLbl.Parent = card

            local actLbl = Instance.new("TextLabel")
            actLbl.Size = UDim2.new(0, 75, 0, 16)
            actLbl.Position = UDim2.new(1, -80, 0, 4)
            actLbl.BackgroundTransparency = 1
            actLbl.Text = pkt.Action
            actLbl.TextColor3 = (pkt.Action == "Tampered" and Theme.Yellow) or Theme.Green
            actLbl.Font = Enum.Font.GothamBold
            actLbl.TextSize = 9
            actLbl.TextXAlignment = Enum.TextXAlignment.Right
            actLbl.Parent = card
        end

        if EngineState.AutoScrollSpy and #EngineState.InterceptedPackets > 0 then
            spyList.CanvasPosition = Vector2.new(0, 999999)
        end
    end

    EngineState.RefreshSpyUI = refreshSpyUI
end

local function buildConsoleTab(tab)
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 32)
    topRow.BackgroundTransparency = 1
    topRow.Parent = tab.Page

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 70, 0, 24)
    clearBtn.BackgroundColor3 = Theme.ElementBg
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Theme.TextSecondary
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 9
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = topRow
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

    local logScroll = Instance.new("ScrollingFrame")
    logScroll.Size = UDim2.new(1, 0, 1, -40)
    logScroll.Position = UDim2.new(0, 0, 0, 40)
    logScroll.BackgroundTransparency = 1
    logScroll.BorderSizePixel = 0
    logScroll.ScrollBarThickness = 2
    logScroll.ScrollBarImageColor3 = Theme.BorderBright
    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logScroll.Parent = tab.Page

    local lgLayout = Instance.new("UIListLayout")
    lgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lgLayout.Padding = UDim.new(0, 3)
    lgLayout.Parent = logScroll

    clearBtn.MouseButton1Click:Connect(function()
        EngineState.Logs = {}
        logScroll:ClearAllChildren()
        lgLayout:Clone().Parent = logScroll
    end)

    local function refreshLogsUI()
        logScroll:ClearAllChildren()
        lgLayout:Clone().Parent = logScroll

        for _, log in ipairs(EngineState.Logs) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 24)
            card.BackgroundColor3 = Theme.ElementBg
            card.BorderSizePixel = 0
            card.Parent = logScroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 3)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0, 50, 1, 0)
            tLbl.Position = UDim2.new(0, 6, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = log.Time
            tLbl.TextColor3 = Theme.TextSecondary
            tLbl.Font = Enum.Font.Gotham
            tLbl.TextSize = 8
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local tagLbl = Instance.new("TextLabel")
            tagLbl.Size = UDim2.new(0, 70, 1, 0)
            tagLbl.Position = UDim2.new(0, 60, 0, 0)
            tagLbl.BackgroundTransparency = 1
            tagLbl.Text = "[" .. log.Tag .. "]"
            tagLbl.TextColor3 = Theme.Cyan
            tagLbl.Font = Enum.Font.GothamBold
            tagLbl.TextSize = 8
            tagLbl.TextXAlignment = Enum.TextXAlignment.Left
            tagLbl.Parent = card

            local msgLbl = Instance.new("TextLabel")
            msgLbl.Size = UDim2.new(1, -140, 1, 0)
            msgLbl.Position = UDim2.new(0, 135, 0, 0)
            msgLbl.BackgroundTransparency = 1
            msgLbl.Text = log.Message
            msgLbl.TextColor3 = log.Color
            msgLbl.Font = Enum.Font.Gotham
            msgLbl.TextSize = 9
            msgLbl.TextXAlignment = Enum.TextXAlignment.Left
            msgLbl.Parent = card
        end

        if EngineState.AutoScrollLogs and #EngineState.Logs > 0 then
            logScroll.CanvasPosition = Vector2.new(0, 999999)
        end
    end

    EngineState.RefreshLogsUI = refreshLogsUI
    refreshLogsUI()
end

buildDashboard(EngineTab)
buildScannerTab(ScannerTab)
buildTestTab(TestTab)
buildSpyTab(SpyTab)
buildConsoleTab(ConsoleTab)

addConsoleLog("INIT", "NIXMetaHook Suite initialized (Press RightShift to toggle UI)", Theme.Accent)
