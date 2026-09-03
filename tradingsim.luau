local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startT = os.clock()
    while not LocalPlayer and (os.clock() - startT) < 5 do
        LocalPlayer = Players.LocalPlayer
        task.wait(0.1)
    end
end
if not LocalPlayer then return end

local function copyToClipboard(txt)
    local ok = false
    if setclipboard then
        ok = pcall(function() setclipboard(txt) end)
    elseif toclipboard then
        ok = pcall(function() toclipboard(txt) end)
    elseif syn and syn.write_clipboard then
        ok = pcall(function() syn.write_clipboard(txt) end)
    end
    return ok
end

local function notifyUser(title, msg, duration)
    pcall(function()
        local core = nil
        pcall(function() core = game:GetService("CoreGui") end)
        local parent = (gethui and gethui()) or core or LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not parent then return end

        local sg = Instance.new("ScreenGui")
        sg.Name = "NIXScannerNotif"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.IgnoreGuiInset = true
        sg.Parent = parent

        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 320, 0, 60)
        card.Position = UDim2.new(0.5, -160, 0, 30)
        card.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        card.BorderSizePixel = 0
        card.Parent = sg

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 8)
        cCorner.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(60, 220, 120)
        cStroke.Thickness = 1.5
        cStroke.Parent = card

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -20, 0, 20)
        tLbl.Position = UDim2.new(0, 10, 0, 8)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = string.upper(title)
        tLbl.TextColor3 = Color3.fromRGB(60, 220, 120)
        tLbl.Font = Enum.Font.GothamBold
        tLbl.TextSize = 12
        tLbl.TextXAlignment = Enum.TextXAlignment.Center
        tLbl.Parent = card

        local dLbl = Instance.new("TextLabel")
        dLbl.Size = UDim2.new(1, -20, 0, 24)
        dLbl.Position = UDim2.new(0, 10, 0, 28)
        dLbl.BackgroundTransparency = 1
        dLbl.Text = msg
        dLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
        dLbl.Font = Enum.Font.Gotham
        dLbl.TextSize = 11
        dLbl.TextXAlignment = Enum.TextXAlignment.Center
        dLbl.Parent = card

        task.delay(duration or 4, function()
            if sg and sg.Parent then
                sg:Destroy()
            end
        end)
    end)
end

local dossier = {}
local function logLine(str)
    table.insert(dossier, str or "")
end

do
    logLine("================================================================================")
    logLine("               N I X   A U D I T O R  ::  O N E - A N D - D O N E")
    logLine("================================================================================")
    logLine("TIMESTAMP       : " .. os.date("!%Y-%m-%dT%H:%M:%SZ"))
    logLine("PLACE ID        : " .. tostring(game.PlaceId))
    logLine("GAME ID         : " .. tostring(game.GameId))
    logLine("JOB ID          : " .. tostring(game.JobId))
    logLine("PLACE VERSION   : " .. tostring(game.PlaceVersion))
    logLine("PLAYER NAME     : " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")")
    logLine("USER ID         : " .. tostring(LocalPlayer.UserId))
    logLine("ACCOUNT AGE     : " .. tostring(LocalPlayer.AccountAge) .. " days")
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        logLine(string.format("HUMANOID STATS  : Health=%s/%s | WalkSpeed=%s | JumpPower=%s", tostring(hum.Health), tostring(hum.MaxHealth), tostring(hum.WalkSpeed), tostring(hum.JumpPower)))
    end
    logLine("")
end

do
    logLine("==")
    logLine(" [1] EXECUTOR CAPABILITIES & SECURITY ENVIRONMENT")
    logLine("==")
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
        {"gethui", type(gethui) == "function"},
        {"request / http_request", type(request) == "function" or type(http_request) == "function" or (syn and type(syn.request) == "function")}
    }
    local capStr = {}
    for _, item in ipairs(envChecks) do
        table.insert(capStr, string.format("  [%s] %s", item[2] and "YES" or " NO", item[1]))
    end
    logLine(table.concat(capStr, "\n"))
    logLine("")
end

local remoteEventsFound = {}
local remoteFunctionsFound = {}
local bindableEventsFound = {}
local bindableFunctionsFound = {}

do
    logLine("==")
    logLine(" [2] NETWORK ARCHITECTURE :: REMOTES & DISPATCHERS")
    logLine("==")
    local searchContainers = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        workspace,
        LocalPlayer:FindFirstChild("PlayerGui"),
        LocalPlayer:FindFirstChild("PlayerScripts")
    }

    local seenInst = {}
    for _, root in ipairs(searchContainers) do
        if root then
            pcall(function()
                for _, inst in ipairs(root:GetDescendants()) do
                    if not seenInst[inst] then
                        seenInst[inst] = true
                        if inst:IsA("RemoteEvent") then
                            table.insert(remoteEventsFound, inst)
                        elseif inst:IsA("RemoteFunction") then
                            table.insert(remoteFunctionsFound, inst)
                        elseif inst:IsA("BindableEvent") then
                            table.insert(bindableEventsFound, inst)
                        elseif inst:IsA("BindableFunction") then
                            table.insert(bindableFunctionsFound, inst)
                        end
                    end
                end
            end)
        end
    end

    logLine(string.format("SUMMARY: %d RemoteEvents, %d RemoteFunctions, %d BindableEvents, %d BindableFunctions", #remoteEventsFound, #remoteFunctionsFound, #bindableEventsFound, #bindableFunctionsFound))
    logLine("")
    logLine("== RemoteFunctions (Request/Response) ==")
    if #remoteFunctionsFound == 0 then
        logLine("  (None found)")
    else
        for idx, rf in ipairs(remoteFunctionsFound) do
            logLine(string.format("  [%d] %s -> %s", idx, rf.Name, rf:GetFullName()))
        end
    end
    logLine("")
    logLine("== RemoteEvents (Streaming/Firing) ==")
    if #remoteEventsFound == 0 then
        logLine("  (None found)")
    else
        for idx, re in ipairs(remoteEventsFound) do
            logLine(string.format("  [%d] %s -> %s", idx, re.Name, re:GetFullName()))
        end
    end
    logLine("")
end

local sharedModulesFound = {}

do
    logLine("==")
    logLine(" [3] SHARED & REPLICATED MODULESCRIPTS (ANALYSIS & EXPORTS)")
    logLine("==")
    local seenM = {}
    local moduleRoots = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst")
    }

    for _, root in ipairs(moduleRoots) do
        if root then
            pcall(function()
                for _, m in ipairs(root:GetDescendants()) do
                    if m:IsA("ModuleScript") and not seenM[m] then
                        seenM[m] = true
                        table.insert(sharedModulesFound, m)
                    end
                end
            end)
        end
    end

    logLine(string.format("Discovered %d Shared / Replicated ModuleScripts:", #sharedModulesFound))
    for idx, mod in ipairs(sharedModulesFound) do
        local reqOk, res = pcall(require, mod)
        if not reqOk then
            logLine(string.format("  [%d] %s [%s] -> REQUIRE FAILED: %s", idx, mod.Name, mod:GetFullName(), tostring(res)))
        else
            if type(res) == "table" then
                local keys = {}
                local fnCount = 0
                for k, v in pairs(res) do
                    if type(v) == "function" then fnCount = fnCount + 1 end
                    table.insert(keys, string.format("%s(%s)", tostring(k), type(v)))
                    if #keys >= 10 then break end
                end
                logLine(string.format("  [%d] %s [%s] -> Table (%d funcs) | Keys: %s", idx, mod.Name, mod:GetFullName(), fnCount, table.concat(keys, ", ")))
            else
                logLine(string.format("  [%d] %s [%s] -> Returns (%s): %s", idx, mod.Name, mod:GetFullName(), type(res), tostring(res)))
            end
        end
    end
    logLine("")
end

do
    logLine("==")
    logLine(" [4] PLAYER SCRIPTS & LOCAL CONTROLLERS AUDIT")
    logLine("==")
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    local localScripts = {}
    local clientModules = {}

    if ps then
        pcall(function()
            for _, d in ipairs(ps:GetDescendants()) do
                if d:IsA("LocalScript") then
                    table.insert(localScripts, d)
                elseif d:IsA("ModuleScript") then
                    table.insert(clientModules, d)
                end
            end
        end)
    end

    logLine(string.format("PlayerScripts: %d LocalScripts, %d ModuleScripts", #localScripts, #clientModules))
    logLine("")
    logLine("== LocalScripts ==")
    for idx, ls in ipairs(localScripts) do
        logLine(string.format("  [%d] %s -> %s", idx, ls.Name, ls:GetFullName()))
    end
    logLine("")
    logLine("== Client ModuleScripts ==")
    for idx, cm in ipairs(clientModules) do
        local ok, res = pcall(require, cm)
        if ok and type(res) == "table" then
            local keys = {}
            for k, v in pairs(res) do
                table.insert(keys, string.format("%s(%s)", tostring(k), type(v)))
                if #keys >= 6 then break end
            end
            logLine(string.format("  [%d] %s [%s] -> %s", idx, cm.Name, cm:GetFullName(), table.concat(keys, ", ")))
        else
            logLine(string.format("  [%d] %s [%s]", idx, cm.Name, cm:GetFullName()))
        end
    end
    logLine("")
end

do
    logLine("==")
    logLine(" [5] PLAYER GUI AUDIT :: SCREENGUIS, BUTTONS & TEXT INPUTS")
    logLine("==")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local guis = {}
    local buttons = {}
    local textBoxes = {}

    if pg then
        pcall(function()
            for _, child in ipairs(pg:GetChildren()) do
                if child:IsA("ScreenGui") or child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                    table.insert(guis, child)
                end
            end
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextButton") or d:IsA("ImageButton") then
                    table.insert(buttons, d)
                elseif d:IsA("TextBox") then
                    table.insert(textBoxes, d)
                end
            end
        end)
    end

    logLine(string.format("Discovered %d Top-Level GUIs, %d Interactive Buttons, %d TextBoxes", #guis, #buttons, #textBoxes))
    logLine("")
    logLine("== Top-Level GUIs ==")
    for idx, g in ipairs(guis) do
        logLine(string.format("  [%d] [%s] %s (Enabled: %s, DisplayOrder: %d)", idx, g.ClassName, g.Name, tostring(g.Enabled), g.DisplayOrder))
    end
    logLine("")
    logLine("== Action Buttons (Samples & High-Value Targets) ==")
    local shownButtons = 0
    for idx, b in ipairs(buttons) do
        local txt = b:IsA("TextButton") and b.Text or ""
        local cleanTxt = txt:gsub("\n", " "):gsub("\r", ""):match("^%s*(.-)%s*$") or ""
        if cleanTxt ~= "" or b.Name:lower():find("btn") or b.Name:lower():find("button") or idx <= 35 then
            shownButtons = shownButtons + 1
            logLine(string.format("  [%d] Button '%s' (Text: %q) -> %s", shownButtons, b.Name, cleanTxt, b:GetFullName()))
        end
        if shownButtons >= 60 then
            logLine(string.format("  ... (+%d more buttons in GUI)", #buttons - shownButtons))
            break
        end
    end
    logLine("")
    logLine("== Text Inputs (TextBoxes) ==")
    for idx, tb in ipairs(textBoxes) do
        if idx <= 25 then
            logLine(string.format("  [%d] TextBox '%s' (Placeholder: %q) -> %s", idx, tb.Name, tb.PlaceholderText or "", tb:GetFullName()))
        end
    end
    logLine("")
end

do
    logLine("==")
    logLine(" [6] WORKSPACE INTERACTIVE TRIGGERS & PROXIMITY PROMPTS")
    logLine("==")
    local prompts = {}
    local clickDetectors = {}
    local toolsInWorld = {}
    local spawns = {}

    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                table.insert(prompts, d)
            elseif d:IsA("ClickDetector") then
                table.insert(clickDetectors, d)
            elseif d:IsA("Tool") then
                table.insert(toolsInWorld, d)
            elseif d:IsA("SpawnLocation") then
                table.insert(spawns, d)
            end
        end
    end)

    logLine(string.format("Summary: %d ProximityPrompts, %d ClickDetectors, %d Tools in Workspace, %d Spawns", #prompts, #clickDetectors, #toolsInWorld, #spawns))
    logLine("")
    if #prompts > 0 then
        logLine("== ProximityPrompts ==")
        for idx, p in ipairs(prompts) do
            if idx <= 20 then
                logLine(string.format("  [%d] Action: %q | ObjectText: %q -> %s", idx, p.ActionText or "", p.ObjectText or "", p:GetFullName()))
            end
        end
        logLine("")
    end
    if #clickDetectors > 0 then
        logLine("== ClickDetectors ==")
        for idx, cd in ipairs(clickDetectors) do
            if idx <= 20 then
                logLine(string.format("  [%d] MaxDistance: %s -> %s", idx, tostring(cd.MaxActivationDistance), cd:GetFullName()))
            end
        end
        logLine("")
    end
end

do
    logLine("==")
    logLine(" [7] BACKPACK & EQUIPPED TOOLS")
    logLine("==")
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local myTools = {}
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(myTools, t) end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then table.insert(myTools, t) end
        end
    end

    if #myTools == 0 then
        logLine("  No tools equipped or in backpack.")
    else
        for idx, t in ipairs(myTools) do
            local scripts = {}
            for _, s in ipairs(t:GetDescendants()) do
                if s:IsA("LocalScript") or s:IsA("ModuleScript") or s:IsA("Script") then
                    table.insert(scripts, string.format("%s(%s)", s.Name, s.ClassName))
                end
            end
            logLine(string.format("  [%d] Tool: %s (Scripts: %s)", idx, t.Name, #scripts > 0 and table.concat(scripts, ", ") or "None"))
        end
    end
    logLine("")
end

logLine("================================================================================")
logLine("                       E N D   O F   A U D I T")
logLine("================================================================================")

local fullReport = table.concat(dossier, "\n")
print(fullReport)
local copied = copyToClipboard(fullReport)

local totalRemotes = #remoteEventsFound + #remoteFunctionsFound
if copied then
    notifyUser("NIX SCANNER COMPLETE", string.format("Audit copied to clipboard!\n(%d Remotes | %d Modules | %d chars)", totalRemotes, #sharedModulesFound, #fullReport), 4)
    print(string.format("[NIX SCANNER] SUCCESS! %d characters copied to clipboard.", #fullReport))
else
    notifyUser("NIX SCANNER PRINTED", "Report printed to F9 Console! (Clipboard unavailable)", 4)
    print("[NIX SCANNER] Printed to console. Use F9 Developer Console to view.")
end
