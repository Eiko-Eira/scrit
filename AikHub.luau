local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local existingUI = PlayerGui:FindFirstChild("NIXHubUI")
if existingUI then
    existingUI:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(10, 10, 12),
    Header = Color3.fromRGB(16, 16, 18),
    Sidebar = Color3.fromRGB(12, 12, 14),
    TabActive = Color3.fromRGB(240, 240, 240),
    TabActiveText = Color3.fromRGB(10, 10, 12),
    TabInactive = Color3.fromRGB(18, 18, 20),
    TabInactiveText = Color3.fromRGB(160, 160, 160),
    Accent = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(20, 20, 24),
    ElementHover = Color3.fromRGB(30, 30, 36),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(40, 40, 48),
}

local function tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local anim = TweenService:Create(instance, tweenInfo, properties)
    anim:Play()
    return anim
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NIXHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.Size = UDim2.new(0, 260, 1, -40)
notifContainer.Position = UDim2.new(1, -270, 0, 20)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 100
notifContainer.Parent = ScreenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)
notifLayout.Parent = notifContainer

local function Notify(titleText, descText, duration)
    duration = duration or 3

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 50)
    notif.BackgroundColor3 = Theme.Header
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.Parent = notifContainer

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 4)
    nCorner.Parent = notif

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Theme.Border
    nStroke.Thickness = 1
    nStroke.Transparency = 1
    nStroke.Parent = notif

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -16, 0, 18)
    nTitle.Position = UDim2.new(0, 10, 0, 6)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = string.upper(titleText)
    nTitle.TextColor3 = Theme.Accent
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 11
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.TextTransparency = 1
    nTitle.Parent = notif

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -16, 0, 18)
    nDesc.Position = UDim2.new(0, 10, 0, 24)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = descText
    nDesc.TextColor3 = Theme.TextSecondary
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 11
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.TextTransparency = 1
    nDesc.Parent = notif

    tween(notif, {BackgroundTransparency = 0}, 0.2)
    tween(nStroke, {Transparency = 0}, 0.2)
    tween(nTitle, {TextTransparency = 0}, 0.2)
    tween(nDesc, {TextTransparency = 0}, 0.2)

    task.delay(duration, function()
        if notif and notif.Parent then
            local fadeOut = tween(notif, {BackgroundTransparency = 1}, 0.2)
            tween(nStroke, {Transparency = 1}, 0.2)
            tween(nTitle, {TextTransparency = 1}, 0.2)
            tween(nDesc, {TextTransparency = 1}, 0.2)
            fadeOut.Completed:Connect(function()
                notif:Destroy()
            end)
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 430)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -215)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Border
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "N I X  H U B"
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 240, 1, 0)
subtitleLabel.Position = UDim2.new(0, 110, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "[ RSHIFT TO TOGGLE ]"
subtitleLabel.TextColor3 = Theme.TextSecondary
subtitleLabel.Font = Enum.Font.Code
subtitleLabel.TextSize = 11
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.BackgroundColor3 = Theme.ElementBackground
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
closeBtn.Parent = TopBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

local isDragging = false
local dragInput, mousePos, framePos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

local isVisible = true
local function setVisible(vis)
    isVisible = vis
    MainFrame.Visible = vis
end

closeBtn.MouseButton1Click:Connect(function()
    setVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not isVisible)
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 3)
tabListLayout.Parent = Sidebar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingLeft = UDim.new(0, 6)
tabPadding.PaddingRight = UDim.new(0, 6)
tabPadding.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -130, 1, -40)
ContentArea.Position = UDim2.new(0, 130, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {}

local function createTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 28)
    tabButton.BackgroundColor3 = Theme.TabInactive
    tabButton.Text = string.upper(tabName)
    tabButton.TextColor3 = Theme.TabInactiveText
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 10
    tabButton.BorderSizePixel = 0
    tabButton.Parent = Sidebar

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 4)
    tCorner.Parent = tabButton

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
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
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local tabObj = {
        Button = tabButton,
        Page = page,
        Name = tabName,
    }

    local function selectTab()
        for _, t in ipairs(Tabs) do
            t.Page.Visible = false
            tween(t.Button, {
                BackgroundColor3 = Theme.TabInactive,
                TextColor3 = Theme.TabInactiveText
            }, 0.15)
        end
        page.Visible = true
        tween(tabButton, {
            BackgroundColor3 = Theme.TabActive,
            TextColor3 = Theme.TabActiveText
        }, 0.15)
    end

    tabButton.MouseButton1Click:Connect(selectTab)
    if #Tabs == 0 then
        selectTab()
    end

    table.insert(Tabs, tabObj)

    function tabObj:AddSection(text)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, 0, 0, 20)
        sec.BackgroundTransparency = 1
        sec.Text = string.upper(text)
        sec.TextColor3 = Theme.Accent
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 10
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = page
        return sec
    end

    function tabObj:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Theme.ElementBackground
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Theme.Border
        bStroke.Thickness = 1
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            tween(bStroke, {Color = Theme.Accent}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
            tween(bStroke, {Color = Theme.Border}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback) end
        end)
        return btn
    end

    function tabObj:AddToggle(text, defaultState, callback)
        local state = defaultState or false

        local container = Instance.new("TextButton")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundColor3 = Theme.ElementBackground
        container.Text = ""
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = container

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Theme.Border
        cStroke.Thickness = 1
        cStroke.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local swBg = Instance.new("Frame")
        swBg.Size = UDim2.new(0, 30, 0, 14)
        swBg.Position = UDim2.new(1, -38, 0.5, -7)
        swBg.BackgroundColor3 = state and Theme.Accent or Theme.Header
        swBg.BorderSizePixel = 0
        swBg.Parent = container

        local swCorner = Instance.new("UICorner")
        swCorner.CornerRadius = UDim.new(1, 0)
        swCorner.Parent = swBg

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        knob.BackgroundColor3 = state and Color3.fromRGB(10, 10, 12) or Theme.TextSecondary
        knob.BorderSizePixel = 0
        knob.Parent = swBg

        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob

        local function update(newState)
            state = newState
            tween(swBg, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.15)
            tween(knob, {
                Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                BackgroundColor3 = state and Color3.fromRGB(10, 10, 12) or Theme.TextSecondary
            }, 0.15)
            if callback then task.spawn(callback, state) end
        end

        container.MouseButton1Click:Connect(function()
            update(not state)
        end)
    end

    function tabObj:AddSlider(text, minVal, maxVal, defaultVal, callback)
        local val = defaultVal or minVal
        minVal = minVal or 0
        maxVal = maxVal or 100

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 44)
        container.BackgroundColor3 = Theme.ElementBackground
        container.BorderSizePixel = 0
        container.Parent = page

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = container

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Theme.Border
        cStroke.Thickness = 1
        cStroke.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 0, 16)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextPrimary
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 50, 0, 16)
        valLbl.Position = UDim2.new(1, -58, 0, 4)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val)
        valLbl.TextColor3 = Theme.Accent
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = container

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(1, -20, 0, 4)
        track.Position = UDim2.new(0, 10, 0, 26)
        track.BackgroundColor3 = Theme.Header
        track.BorderSizePixel = 0
        track.Text = ""
        track.Parent = container

        local trkCorner = Instance.new("UICorner")
        trkCorner.CornerRadius = UDim.new(1, 0)
        trkCorner.Parent = track

        local fill = Instance.new("Frame")
        local ratio = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(1, 0)
        fCorner.Parent = fill

        local isSliding = false

        local function updateSlide(input)
            local trackX = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            local relX = math.clamp(input.Position.X - trackX, 0, trackWidth)
            local r = relX / trackWidth
            val = math.floor(minVal + (maxVal - minVal) * r)
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(r, 0, 1, 0)
            if callback then task.spawn(callback, val) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                updateSlide(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlide(input)
            end
        end)
    end

    return tabObj
end

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Name = "CrosshairOverlay"
CrosshairFrame.Size = UDim2.new(0, 12, 0, 12)
CrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.Parent = ScreenGui

local chDot = Instance.new("Frame")
chDot.Size = UDim2.new(0, 4, 0, 4)
chDot.AnchorPoint = Vector2.new(0.5, 0.5)
chDot.Position = UDim2.new(0.5, 0, 0.5, 0)
chDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
chDot.BorderSizePixel = 0
chDot.Parent = CrosshairFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = chDot

local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircleOverlay"
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 300, 0, 300)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1
fovStroke.Transparency = 0.6
fovStroke.Parent = FovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = FovCircle

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 140, 0, 20)
FpsLabel.Position = UDim2.new(0, 10, 0, 10)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS: 60"
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.Font = Enum.Font.Code
FpsLabel.TextSize = 11
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.Visible = false
FpsLabel.Parent = ScreenGui

local HoverHud = Instance.new("TextLabel")
HoverHud.Name = "HoverInspector"
HoverHud.Size = UDim2.new(0, 240, 0, 24)
HoverHud.Position = UDim2.new(0.5, -120, 1, -40)
HoverHud.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
HoverHud.TextColor3 = Color3.fromRGB(255, 255, 255)
HoverHud.Font = Enum.Font.Code
HoverHud.TextSize = 10
HoverHud.BorderSizePixel = 0
HoverHud.Visible = false
HoverHud.Parent = ScreenGui

local hoverCorner = Instance.new("UICorner")
hoverCorner.CornerRadius = UDim.new(0, 4)
hoverCorner.Parent = HoverHud

local hoverStroke = Instance.new("UIStroke")
hoverStroke.Color = Theme.Border
hoverStroke.Thickness = 1
hoverStroke.Parent = HoverHud

local fpsConnection = nil
local inspectorConnection = nil

local savedWaypoints = {}

local function teleportToRaycast()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = RaycastFilterType.Exclude
    end

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if result then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
            Notify("Teleport", "Teleported to cursor position", 2)
        end
    end
end

local recoilEnabled = false
local recoilIntensity = 5
local recoilConnection = nil
local targetRecoil = Vector3.zero
local currentRecoil = Vector3.zero

local function setRecoil(enabled)
    recoilEnabled = enabled
    if recoilConnection then
        recoilConnection:Disconnect()
        recoilConnection = nil
    end

    if enabled then
        recoilConnection = RunService.RenderStepped:Connect(function(dt)
            currentRecoil = currentRecoil:Lerp(targetRecoil, dt * 12)
            targetRecoil = targetRecoil:Lerp(Vector3.zero, dt * 8)
            Camera.CFrame = Camera.CFrame * CFrame.Angles(
                math.rad(currentRecoil.X),
                math.rad(currentRecoil.Y),
                0
            )
        end)
    end
end

local aimAssistEnabled = false
local aimAssistRange = 300
local wallCheckEnabled = false
local teamCheckEnabled = false
local aimSnapEnabled = false
local aimAssistConnection = nil
local rmbHeld = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbHeld = false
    end
end)

local function isTargetVisible(originPos, targetPart)
    local direction = targetPart.Position - originPos
    local params = RaycastParams.new()
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
        params.FilterType = RaycastFilterType.Exclude
    end
    local result = workspace:Raycast(originPos, direction, params)
    return result == nil
end

local function getNearestTarget()
    local nearest = nil
    local shortestDist = aimAssistRange

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if teamCheckEnabled and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
                continue
            end

            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if wallCheckEnabled and not isTargetVisible(Camera.CFrame.Position, root) then
                    continue
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = root
                    end
                end
            end
        end
    end
    return nearest
end

local function setAimAssist(enabled)
    aimAssistEnabled = enabled
    if aimAssistConnection then
        aimAssistConnection:Disconnect()
        aimAssistConnection = nil
    end

    if enabled then
        aimAssistConnection = RunService.RenderStepped:Connect(function()
            if not rmbHeld then return end
            local target = getNearestTarget()
            if not target then return end
            local targetPos = target.Position + Vector3.new(0, 0.5, 0)
            if aimSnapEnabled then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.18)
            end
        end)
    end
end

local cameraShakeEnabled = false
local cameraShakeIntensity = 3
local cameraShakeConnection = nil

local function setCameraShake(enabled)
    cameraShakeEnabled = enabled
    if cameraShakeConnection then
        cameraShakeConnection:Disconnect()
        cameraShakeConnection = nil
    end
    if enabled then
        cameraShakeConnection = RunService.RenderStepped:Connect(function()
            local intensity = cameraShakeIntensity * 0.001
            local offsetX = (math.random() - 0.5) * intensity
            local offsetY = (math.random() - 0.5) * intensity
            Camera.CFrame = Camera.CFrame * CFrame.Angles(offsetX, offsetY, 0)
        end)
    end
end

local headbobEnabled = false
local headbobConnection = nil
local headbobTime = 0

local function setHeadbob(enabled)
    headbobEnabled = enabled
    if headbobConnection then
        headbobConnection:Disconnect()
        headbobConnection = nil
    end
    if enabled then
        headbobConnection = RunService.RenderStepped:Connect(function(dt)
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local speed = hum.WalkSpeed
            local moving = hum.MoveDirection.Magnitude > 0.1
            if moving then
                headbobTime = headbobTime + dt * (speed * 0.3)
                local bobX = math.sin(headbobTime * 2) * 0.04
                local bobY = math.abs(math.sin(headbobTime)) * 0.03
                Camera.CFrame = Camera.CFrame * CFrame.new(bobX, bobY, 0)
            end
        end)
    end
end

local speedlinesEnabled = false
local speedlinesFrame = nil
local speedlinesConnection = nil

local function setSpeedlines(enabled)
    speedlinesEnabled = enabled
    if speedlinesFrame then
        speedlinesFrame:Destroy()
        speedlinesFrame = nil
    end
    if speedlinesConnection then
        speedlinesConnection:Disconnect()
        speedlinesConnection = nil
    end

    if enabled then
        speedlinesFrame = Instance.new("Frame")
        speedlinesFrame.Size = UDim2.new(1, 0, 1, 0)
        speedlinesFrame.BackgroundTransparency = 1
        speedlinesFrame.Name = "SpeedlinesFrame"
        speedlinesFrame.Parent = ScreenGui

        speedlinesConnection = RunService.RenderStepped:Connect(function(dt)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not speedlinesFrame or not root then return end
            local speed = root.AssemblyLinearVelocity.Magnitude
            local intensity = math.clamp((speed - 20) / 80, 0, 1)
            for _, line in ipairs(speedlinesFrame:GetChildren()) do
                local prog = line:GetAttribute("prog") or 0
                prog = prog + dt * (4 + speed * 0.05)
                if prog > 1 then
                    line:Destroy()
                else
                    line:SetAttribute("prog", prog)
                    line.BackgroundTransparency = 1 - (intensity * (1 - prog))
                    local sx = line:GetAttribute("sx") or 0.5
                    local sy = line:GetAttribute("sy") or 0.5
                    local ex = 0.5 + (sx - 0.5) * (1 + prog * 2)
                    local ey = 0.5 + (sy - 0.5) * (1 + prog * 2)
                    line.Position = UDim2.new(ex, 0, ey, 0)
                end
            end
            if intensity > 0.05 and math.random() < intensity * 0.4 then
                local line = Instance.new("Frame")
                local angle = math.random() * math.pi * 2
                local sx = 0.5 + math.cos(angle) * 0.08
                local sy = 0.5 + math.sin(angle) * 0.08
                line.Size = UDim2.new(0, 1, 0, math.random(30, 90))
                line.Position = UDim2.new(sx, 0, sy, 0)
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Rotation = math.deg(angle) + 90
                line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                line.BackgroundTransparency = 1 - intensity
                line.BorderSizePixel = 0
                line:SetAttribute("prog", 0)
                line:SetAttribute("sx", sx)
                line:SetAttribute("sy", sy)
                line.Parent = speedlinesFrame
            end
        end)
    end
end

local nameTagsEnabled = false
local nameTagConnection = nil
local nameTagBills = {}

local function clearNameTags()
    for _, b in pairs(nameTagBills) do
        if b and b.Parent then b:Destroy() end
    end
    nameTagBills = {}
end

local function setNameTags(enabled)
    nameTagsEnabled = enabled
    if nameTagConnection then
        nameTagConnection:Disconnect()
        nameTagConnection = nil
    end
    clearNameTags()

    if enabled then
        local function attachTag(player)
            if player == LocalPlayer then return end
            task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local head = char:WaitForChild("Head", 5)
                if not head then return end

                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 120, 0, 28)
                bill.StudsOffset = Vector3.new(0, 2.4, 0)
                bill.AlwaysOnTop = true
                bill.Adornee = head
                bill.Parent = head

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = player.Name
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextStrokeTransparency = 0.4
                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lbl.Parent = bill

                nameTagBills[player.UserId] = bill
            end)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            attachTag(p)
        end

        nameTagConnection = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                attachTag(p)
            end)
        end)
    end
end

local healthBarEnabled = false
local healthBarConnection = nil
local healthBarBills = {}

local function clearHealthBars()
    for _, b in pairs(healthBarBills) do
        if b and b.Parent then b:Destroy() end
    end
    healthBarBills = {}
end

local function setHealthBars(enabled)
    healthBarEnabled = enabled
    if healthBarConnection then
        healthBarConnection:Disconnect()
        healthBarConnection = nil
    end
    clearHealthBars()

    if enabled then
        local function attachBar(player)
            if player == LocalPlayer then return end
            task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local head = char:WaitForChild("Head", 5)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not head or not hum then return end

                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 80, 0, 8)
                bill.StudsOffset = Vector3.new(0, 1.6, 0)
                bill.AlwaysOnTop = true
                bill.Adornee = head
                bill.Parent = head

                local bg = Instance.new("Frame")
                bg.Size = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                bg.BorderSizePixel = 0
                bg.Parent = bill

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                fill.BorderSizePixel = 0
                fill.Parent = bg

                hum:GetPropertyChangedSignal("Health"):Connect(function()
                    if fill and fill.Parent then
                        local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        fill.Size = UDim2.new(ratio, 0, 1, 0)
                        local r = 255 * (1 - ratio)
                        local g = 255 * ratio
                        fill.BackgroundColor3 = Color3.fromRGB(r, g, 0)
                    end
                end)

                healthBarBills[player.UserId] = bill
            end)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            attachBar(p)
        end

        healthBarConnection = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                attachBar(p)
            end)
        end)
    end
end

local distanceTagEnabled = false
local distanceConnection = nil

local function setDistanceTags(enabled)
    distanceTagEnabled = enabled
    if distanceConnection then
        distanceConnection:Disconnect()
        distanceConnection = nil
    end
    if enabled then
        distanceConnection = RunService.Heartbeat:Connect(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    if theirRoot and head then
                        local dist = math.floor((myRoot.Position - theirRoot.Position).Magnitude)
                        local bill = head:FindFirstChild("NIXDistBill")
                        if not bill then
                            bill = Instance.new("BillboardGui")
                            bill.Name = "NIXDistBill"
                            bill.Size = UDim2.new(0, 80, 0, 18)
                            bill.StudsOffset = Vector3.new(0, 3.6, 0)
                            bill.AlwaysOnTop = true
                            bill.Adornee = head
                            bill.Parent = head

                            local lbl = Instance.new("TextLabel")
                            lbl.Name = "DistLbl"
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                            lbl.Font = Enum.Font.Code
                            lbl.TextSize = 11
                            lbl.TextStrokeTransparency = 0.3
                            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            lbl.Parent = bill
                        end
                        local lbl = bill:FindFirstChild("DistLbl")
                        if lbl then lbl.Text = dist .. "m" end
                    end
                end
            end
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local bill = head:FindFirstChild("NIXDistBill")
                    if bill then bill:Destroy() end
                end
            end
        end
    end
end

local highlightsEnabled = false
local highlightsFolder = Instance.new("Folder")
highlightsFolder.Name = "NIXHighlights"
highlightsFolder.Parent = ScreenGui

local function updateHighlights()
    highlightsFolder:ClearAllChildren()
    if not highlightsEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = Instance.new("Highlight")
            hl.Name = player.Name .. "_HL"
            hl.Adornee = player.Character
            hl.FillTransparency = 0.65
            hl.OutlineTransparency = 0
            hl.FillColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = highlightsFolder
        end
    end
end

local highlightConnection = nil
local function setHighlights(enabled)
    highlightsEnabled = enabled
    if highlightConnection then
        highlightConnection:Disconnect()
        highlightConnection = nil
    end

    if enabled then
        updateHighlights()
        highlightConnection = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                updateHighlights()
            end)
        end)
    else
        highlightsFolder:ClearAllChildren()
    end
end

local flightEnabled = false
local flightSpeed = 50
local flightVelocity = nil
local flightAttachment = nil
local flightConnection = nil

local keysDown = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftShift = false
}

local function setFlight(enabled)
    flightEnabled = enabled
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not enabled then
        if flightVelocity then flightVelocity:Destroy() flightVelocity = nil end
        if flightAttachment then flightAttachment:Destroy() flightAttachment = nil end
        if flightConnection then flightConnection:Disconnect() flightConnection = nil end
        if hum then hum.PlatformStand = false end
        return
    end

    if not root or not hum then return end

    hum.PlatformStand = true
    flightAttachment = Instance.new("Attachment")
    flightAttachment.Name = "NIXFlightAttachment"
    flightAttachment.Parent = root

    flightVelocity = Instance.new("LinearVelocity")
    flightVelocity.Name = "NIXFlightVelocity"
    flightVelocity.Attachment0 = flightAttachment
    flightVelocity.MaxForce = math.huge
    flightVelocity.VectorVelocity = Vector3.zero
    flightVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flightVelocity.Parent = root

    flightConnection = RunService.RenderStepped:Connect(function()
        if not flightEnabled or not root or not flightVelocity then return end

        local moveDir = Vector3.zero
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector

        if keysDown.W then moveDir = moveDir + look end
        if keysDown.S then moveDir = moveDir - look end
        if keysDown.D then moveDir = moveDir + right end
        if keysDown.A then moveDir = moveDir - right end
        if keysDown.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keysDown.LeftShift then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flightVelocity.VectorVelocity = moveDir.Unit * flightSpeed
        else
            flightVelocity.VectorVelocity = Vector3.zero
        end
    end)
end

local infJumpEnabled = false
local infJumpConnection = nil

local function setInfJump(enabled)
    infJumpEnabled = enabled
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end

    if enabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, hum.JumpPower or 50, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end

local function spawnBulletTracer()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = RaycastFilterType.Exclude
    end

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    local endPos = result and result.Position or (ray.Origin + ray.Direction * 300)

    local p1 = Instance.new("Part")
    p1.Size = Vector3.new(0.1, 0.1, 0.1)
    p1.Transparency = 1
    p1.Anchored = true
    p1.Position = ray.Origin
    p1.Parent = workspace

    local p2 = Instance.new("Part")
    p2.Size = Vector3.new(0.1, 0.1, 0.1)
    p2.Transparency = 1
    p2.Anchored = true
    p2.Position = endPos
    p2.Parent = workspace

    local a1 = Instance.new("Attachment", p1)
    local a2 = Instance.new("Attachment", p2)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a1
    beam.Attachment1 = a2
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    beam.Width0 = 0.15
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Parent = p1

    tween(beam, {Width0 = 0, Width1 = 0}, 0.25).Completed:Connect(function()
        p1:Destroy()
        p2:Destroy()
    end)
end

local dayCycleEnabled = false
local dayCycleConnection = nil

local function setDayCycle(enabled)
    dayCycleEnabled = enabled
    if dayCycleConnection then
        dayCycleConnection:Disconnect()
        dayCycleConnection = nil
    end

    if enabled then
        dayCycleConnection = RunService.Heartbeat:Connect(function(dt)
            Lighting.ClockTime = (Lighting.ClockTime + (dt * 0.5)) % 24
        end)
    end
end

local nightVisionEnabled = false
local origAmbient

local function setNightVision(enabled)
    nightVisionEnabled = enabled
    local colorCorr = Lighting:FindFirstChild("NIXNightVision")
    if not colorCorr then
        colorCorr = Instance.new("ColorCorrectionEffect")
        colorCorr.Name = "NIXNightVision"
        colorCorr.Parent = Lighting
    end

    if enabled then
        origAmbient = Lighting.Ambient
        Lighting.Ambient = Color3.fromRGB(0, 255, 100)
        colorCorr.TintColor = Color3.fromRGB(150, 255, 150)
        colorCorr.Brightness = 0.2
        colorCorr.Contrast = 0.4
        colorCorr.Enabled = true
    else
        if origAmbient then Lighting.Ambient = origAmbient end
        colorCorr.Enabled = false
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then keysDown.W = true end
    if input.KeyCode == Enum.KeyCode.A then keysDown.A = true end
    if input.KeyCode == Enum.KeyCode.S then keysDown.S = true end
    if input.KeyCode == Enum.KeyCode.D then keysDown.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keysDown.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = true end
    if input.KeyCode == Enum.KeyCode.T then teleportToRaycast() end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keysDown.W = false end
    if input.KeyCode == Enum.KeyCode.A then keysDown.A = false end
    if input.KeyCode == Enum.KeyCode.S then keysDown.S = false end
    if input.KeyCode == Enum.KeyCode.D then keysDown.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keysDown.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = false end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if flightEnabled then
        task.wait(0.5)
        setFlight(true)
    end
end)

local CombatTab = createTab("Combat")
CombatTab:AddSection("Target Tracking [ HOLD RMB ]")

CombatTab:AddToggle("Target Lock Assist", false, function(enabled)
    setAimAssist(enabled)
    Notify("Combat", enabled and "Hold RMB to Lock On Nearest Target" or "Target Lock Disabled", 2.5)
end)

CombatTab:AddToggle("Hard Snap (Instant Lock)", false, function(enabled)
    aimSnapEnabled = enabled
    Notify("Combat", enabled and "Hard Snap Active" or "Smooth Lock Active", 2)
end)

CombatTab:AddToggle("Wall Check (Line of Sight)", false, function(enabled)
    wallCheckEnabled = enabled
    Notify("Combat", enabled and "Wall Check Filter Enabled" or "Wall Check Disabled", 2)
end)

CombatTab:AddToggle("Team Check (Ignore Teammates)", false, function(enabled)
    teamCheckEnabled = enabled
    Notify("Combat", enabled and "Team Filter Enabled" or "Team Filter Disabled", 2)
end)

CombatTab:AddToggle("Draw FOV Field Circle", false, function(enabled)
    FovCircle.Visible = enabled
end)

CombatTab:AddSlider("Tracking Field (px)", 50, 600, 300, function(val)
    aimAssistRange = val
    FovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

CombatTab:AddSection("Camera & Effects")

CombatTab:AddToggle("Procedural Recoil Sim", false, function(enabled)
    setRecoil(enabled)
    Notify("Combat", enabled and "Camera Recoil Active" or "Recoil Disabled", 2)
end)

CombatTab:AddSlider("Recoil Intensity", 1, 20, 5, function(val)
    recoilIntensity = val
end)

CombatTab:AddToggle("Camera Shake", false, function(enabled)
    setCameraShake(enabled)
    Notify("Combat", enabled and "Camera Shake Active" or "Camera Shake Disabled", 2)
end)

CombatTab:AddSlider("Shake Intensity", 1, 10, 3, function(val)
    cameraShakeIntensity = val
end)

CombatTab:AddButton("Spawn Test Bullet Tracer", function()
    spawnBulletTracer()
end)

CombatTab:AddToggle("Center Crosshair Dot", false, function(enabled)
    CrosshairFrame.Visible = enabled
end)

CombatTab:AddSlider("Camera FOV", 40, 120, 70, function(val)
    Camera.FieldOfView = val
end)

local TeleportTab = createTab("Teleport")
TeleportTab:AddSection("Locomotion & Waypoints")

TeleportTab:AddButton("Click-to-Teleport (Or Press T)", function()
    teleportToRaycast()
end)

TeleportTab:AddButton("Save Waypoint A", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        savedWaypoints["SlotA"] = root.CFrame
        Notify("Waypoint", "Saved Waypoint A", 2)
    end
end)

TeleportTab:AddButton("Teleport to Waypoint A", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and savedWaypoints["SlotA"] then
        root.CFrame = savedWaypoints["SlotA"]
        Notify("Waypoint", "Teleported to Waypoint A", 2)
    else
        Notify("Waypoint", "No Waypoint A saved", 2)
    end
end)

TeleportTab:AddButton("Save Waypoint B", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        savedWaypoints["SlotB"] = root.CFrame
        Notify("Waypoint", "Saved Waypoint B", 2)
    end
end)

TeleportTab:AddButton("Teleport to Waypoint B", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and savedWaypoints["SlotB"] then
        root.CFrame = savedWaypoints["SlotB"]
        Notify("Waypoint", "Teleported to Waypoint B", 2)
    else
        Notify("Waypoint", "No Waypoint B saved", 2)
    end
end)

local VisualsTab = createTab("Visuals")
VisualsTab:AddSection("World Outlines & Filters")

VisualsTab:AddToggle("Player Highlight Outlines", false, function(enabled)
    setHighlights(enabled)
    Notify("Visuals", enabled and "Highlight Outlines Active" or "Outlines Disabled", 2)
end)

VisualsTab:AddToggle("Night Vision Mode", false, function(enabled)
    setNightVision(enabled)
end)

VisualsTab:AddToggle("Smooth Day/Night Cycle", false, function(enabled)
    setDayCycle(enabled)
end)

VisualsTab:AddToggle("Fullbright Ambient", false, function(enabled)
    if enabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
    end
end)

VisualsTab:AddSlider("Time of Day", 0, 24, 14, function(val)
    Lighting.ClockTime = val
end)

VisualsTab:AddSlider("Fog Distance", 100, 5000, 1000, function(val)
    Lighting.FogEnd = val
end)

VisualsTab:AddSection("Camera Feel Effects")

VisualsTab:AddToggle("Head Bob (Walk Bob)", false, function(enabled)
    setHeadbob(enabled)
    Notify("Visuals", enabled and "Head Bobbing Active" or "Head Bob Disabled", 2)
end)

VisualsTab:AddToggle("Speed Lines (Motion Blur)", false, function(enabled)
    setSpeedlines(enabled)
    Notify("Visuals", enabled and "Speed Lines Active at high velocity" or "Speed Lines Disabled", 2)
end)

local PlayerInfoTab = createTab("Players")
PlayerInfoTab:AddSection("Player Indicators")

PlayerInfoTab:AddToggle("Name Tags (AlwaysOnTop)", false, function(enabled)
    setNameTags(enabled)
    Notify("Players", enabled and "Name Tags Active" or "Name Tags Disabled", 2)
end)

PlayerInfoTab:AddToggle("Enemy Health Bars", false, function(enabled)
    setHealthBars(enabled)
    Notify("Players", enabled and "Health Bars Active" or "Health Bars Disabled", 2)
end)

PlayerInfoTab:AddToggle("Distance Indicators", false, function(enabled)
    setDistanceTags(enabled)
    Notify("Players", enabled and "Distance Tags Active" or "Distance Tags Disabled", 2)
end)

local PhysicsTab = createTab("Physics")
PhysicsTab:AddSection("Flight & Locomotion")

PhysicsTab:AddToggle("Infinite Air Jump", false, function(enabled)
    setInfJump(enabled)
    Notify("Physics", enabled and "Infinite Air Jump Enabled" or "Air Jump Disabled", 2)
end)

PhysicsTab:AddToggle("Creative Flight", false, function(enabled)
    setFlight(enabled)
    Notify("Physics", enabled and "Flight Mode Enabled (WASD/Space/Shift)" or "Flight Mode Disabled", 2.5)
end)

PhysicsTab:AddSlider("Flight Speed", 20, 200, 50, function(val)
    flightSpeed = val
end)

PhysicsTab:AddSlider("WalkSpeed", 16, 150, 16, function(val)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

PhysicsTab:AddSlider("Jump Power", 50, 250, 50, function(val)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.UseJumpPower then
            hum.JumpPower = val
        else
            hum.JumpHeight = val / 7.2
        end
    end
end)

PhysicsTab:AddSlider("Workspace Gravity", 0, 300, 196, function(val)
    workspace.Gravity = val
end)

PhysicsTab:AddButton("Respawn Character", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

local ToolsTab = createTab("Tools")
ToolsTab:AddSection("Sandbox Utilities")

ToolsTab:AddToggle("Hover Instance Inspector", false, function(enabled)
    HoverHud.Visible = enabled
    if inspectorConnection then
        inspectorConnection:Disconnect()
        inspectorConnection = nil
    end

    if enabled then
        inspectorConnection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 500)

            if result and result.Instance then
                HoverHud.Text = string.format("[%s] %s", result.Instance.ClassName, result.Instance.Name)
            else
                HoverHud.Text = "Hover over world instance..."
            end
        end)
    end
end)

ToolsTab:AddButton("Clear Local Test Decals", function()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Decal") and part.Name == "NIXBulletImpact" then
            part:Destroy()
        end
    end
    Notify("Tools", "Cleared test decals", 2)
end)

local DiagTab = createTab("System")
DiagTab:AddSection("Diagnostics & Settings")

DiagTab:AddToggle("Show FPS HUD", false, function(enabled)
    FpsLabel.Visible = enabled
    if enabled then
        local lastTime = os.clock()
        local frameCount = 0
        fpsConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = os.clock()
            if now - lastTime >= 0.5 then
                local fps = math.floor(frameCount / (now - lastTime))
                FpsLabel.Text = string.format("FPS: %d", fps)
                frameCount = 0
                lastTime = now
            end
        end)
    else
        if fpsConnection then
            fpsConnection:Disconnect()
            fpsConnection = nil
        end
    end
end)

DiagTab:AddButton("Close Menu", function()
    setVisible(false)
end)

Notify("NIXHub Active", "Press Right Shift to toggle menu", 3.5)

