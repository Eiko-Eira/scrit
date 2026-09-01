--[[
    ========================================================================
    Modular Developer Hub UI Library (Luau / Roblox)
    ========================================================================
    A clean, modern, and extensible UI framework for creating developer
    panels, sandbox toolbars, and in-game debug consoles.
    
    Features:
    - Draggable Main Window
    - Tab Switching Navigation
    - Interactive Controls: Buttons, Toggles, Sliders, TextBoxes, Dropdowns
    - Live Log Console & Notification Toasts
    - Smooth Tween Animations & Clean Dark-Mode Aesthetics
    ========================================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local HubUI = {}
HubUI.__index = HubUI

-- Default Theme Palette
local Theme = {
    Background = Color3.fromRGB(24, 24, 28),
    Header = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(20, 20, 24),
    TabActive = Color3.fromRGB(40, 40, 48),
    TabInactive = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(0, 162, 255),
    ElementBackground = Color3.fromRGB(32, 32, 38),
    ElementHover = Color3.fromRGB(42, 42, 50),
    TextPrimary = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(45, 45, 55),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),
}

-- Utility: Safe Tween
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

-- Utility: Make Frame Draggable
local function makeDraggable(topbar, object)
    local dragging = false
    local dragInput, mousePos, framePos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            object.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Creates a new Hub Window Instance
function HubUI.CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Developer Tool Hub"
    local windowSubtitle = config.Subtitle or "Sandbox & Debug Suite"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    local player = Players.LocalPlayer
    local targetParent = player:WaitForChild("PlayerGui")

    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeveloperHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = targetParent

    -- Notification Container
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "NotificationContainer"
    notifContainer.Size = UDim2.new(0, 280, 1, -40)
    notifContainer.Position = UDim2.new(1, -290, 0, 20)
    notifContainer.BackgroundTransparency = 1
    notifContainer.ZIndex = 100
    notifContainer.Parent = screenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.Padding = UDim.new(0, 10)
    notifLayout.Parent = notifContainer

    -- Main Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 640, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -320, 0.5, -210)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Border
    mainStroke.Thickness = 1
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    -- Header / Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 48)
    topBar.BackgroundColor3 = Theme.Header
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 300, 0, 24)
    titleLabel.Position = UDim2.new(0, 16, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Size = UDim2.new(0, 300, 0, 16)
    subtitleLabel.Position = UDim2.new(0, 16, 0, 26)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = windowSubtitle
    subtitleLabel.TextColor3 = Theme.TextSecondary
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 11
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = topBar

    -- Close / Minimize Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 10)
    closeBtn.BackgroundColor3 = Theme.ElementBackground
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    makeDraggable(topBar, mainFrame)

    -- Sidebar Container (Tabs)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -48)
    sidebar.Position = UDim2.new(0, 0, 0, 48)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.Parent = sidebar

    local tabListPadding = Instance.new("UIPadding")
    tabListPadding.PaddingTop = UDim.new(0, 10)
    tabListPadding.PaddingLeft = UDim.new(0, 8)
    tabListPadding.PaddingRight = UDim.new(0, 8)
    tabListPadding.Parent = sidebar

    -- Main Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -160, 1, -48)
    contentArea.Position = UDim2.new(0, 160, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- Keybind Toggle Listener
    local isVisible = true
    local function setWindowVisible(visible)
        isVisible = visible
        mainFrame.Visible = visible
    end

    closeBtn.MouseButton1Click:Connect(function()
        setWindowVisible(false)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            setWindowVisible(not isVisible)
        end
    end)

    -- Window Object
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ContentArea = contentArea,
        Sidebar = sidebar,
        NotifContainer = notifContainer,
        Tabs = {},
        CurrentTab = nil,
    }

    -- Notification System
    function window:Notify(titleText, descText, duration)
        duration = duration or 3.5

        local notif = Instance.new("Frame")
        notif.Name = "Notification"
        notif.Size = UDim2.new(1, 0, 0, 60)
        notif.BackgroundColor3 = Theme.Header
        notif.BorderSizePixel = 0
        notif.BackgroundTransparency = 1
        notif.Parent = notifContainer

        local nCorner = Instance.new("UICorner")
        nCorner.CornerRadius = UDim.new(0, 6)
        nCorner.Parent = notif

        local nStroke = Instance.new("UIStroke")
        nStroke.Color = Theme.Border
        nStroke.Thickness = 1
        nStroke.Transparency = 1
        nStroke.Parent = notif

        local nTitle = Instance.new("TextLabel")
        nTitle.Size = UDim2.new(1, -16, 0, 20)
        nTitle.Position = UDim2.new(0, 10, 0, 8)
        nTitle.BackgroundTransparency = 1
        nTitle.Text = titleText
        nTitle.TextColor3 = Theme.Accent
        nTitle.Font = Enum.Font.GothamBold
        nTitle.TextSize = 13
        nTitle.TextXAlignment = Enum.TextXAlignment.Left
        nTitle.TextTransparency = 1
        nTitle.Parent = notif

        local nDesc = Instance.new("TextLabel")
        nDesc.Size = UDim2.new(1, -16, 0, 24)
        nDesc.Position = UDim2.new(0, 10, 0, 28)
        nDesc.BackgroundTransparency = 1
        nDesc.Text = descText
        nDesc.TextColor3 = Theme.TextSecondary
        nDesc.Font = Enum.Font.Gotham
        nDesc.TextSize = 11
        nDesc.TextXAlignment = Enum.TextXAlignment.Left
        nDesc.TextTransparency = 1
        nDesc.Parent = notif

        -- Fade In
        tween(notif, {BackgroundTransparency = 0}, 0.25)
        tween(nStroke, {Transparency = 0}, 0.25)
        tween(nTitle, {TextTransparency = 0}, 0.25)
        tween(nDesc, {TextTransparency = 0}, 0.25)

        task.delay(duration, function()
            if notif and notif.Parent then
                local fadeOut = tween(notif, {BackgroundTransparency = 1}, 0.25)
                tween(nStroke, {Transparency = 1}, 0.25)
                tween(nTitle, {TextTransparency = 1}, 0.25)
                tween(nDesc, {TextTransparency = 1}, 0.25)
                fadeOut.Completed:Connect(function()
                    notif:Destroy()
                end)
            end
        end)
    end

    -- Tab Creator
    function window:CreateTab(tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "TabButton"
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = Theme.TabInactive
        tabButton.Text = tabName
        tabButton.TextColor3 = Theme.TextSecondary
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.TextSize = 13
        tabButton.BorderSizePixel = 0
        tabButton.Parent = sidebar

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabButton

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Theme.Border
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = contentArea

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent

        local tab = {
            Button = tabButton,
            Page = tabContent,
            Name = tabName,
        }

        local function activateTab()
            for _, otherTab in ipairs(window.Tabs) do
                otherTab.Page.Visible = false
                tween(otherTab.Button, {
                    BackgroundColor3 = Theme.TabInactive,
                    TextColor3 = Theme.TextSecondary
                }, 0.15)
            end

            tab.Page.Visible = true
            tween(tab.Button, {
                BackgroundColor3 = Theme.TabActive,
                TextColor3 = Theme.Accent
            }, 0.15)
            window.CurrentTab = tab
        end

        tabButton.MouseButton1Click:Connect(activateTab)

        if #window.Tabs == 0 then
            activateTab()
        end

        table.insert(window.Tabs, tab)

        -- Element: Section Header
        function tab:AddSection(sectionTitle)
            local header = Instance.new("TextLabel")
            header.Name = "SectionHeader"
            header.Size = UDim2.new(1, 0, 0, 24)
            header.BackgroundTransparency = 1
            header.Text = sectionTitle
            header.TextColor3 = Theme.Accent
            header.Font = Enum.Font.GothamBold
            header.TextSize = 13
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = tabContent
            return header
        end

        -- Element: Action Button
        function tab:AddButton(btnText, callback)
            local button = Instance.new("TextButton")
            button.Name = "Button_" .. btnText
            button.Size = UDim2.new(1, 0, 0, 36)
            button.BackgroundColor3 = Theme.ElementBackground
            button.Text = btnText
            button.TextColor3 = Theme.TextPrimary
            button.Font = Enum.Font.Gotham
            button.TextSize = 13
            button.BorderSizePixel = 0
            button.Parent = tabContent

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 6)
            bCorner.Parent = button

            button.MouseEnter:Connect(function()
                tween(button, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            button.MouseLeave:Connect(function()
                tween(button, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
            end)

            button.MouseButton1Click:Connect(function()
                if callback then
                    task.spawn(callback)
                end
            end)

            return button
        end

        -- Element: Toggle Switch
        function tab:AddToggle(toggleText, defaultState, callback)
            local state = defaultState or false

            local container = Instance.new("TextButton")
            container.Name = "Toggle_" .. toggleText
            container.Size = UDim2.new(1, 0, 0, 36)
            container.BackgroundColor3 = Theme.ElementBackground
            container.Text = ""
            container.BorderSizePixel = 0
            container.Parent = tabContent

            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(0, 6)
            tCorner.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = toggleText
            label.TextColor3 = Theme.TextPrimary
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local switchBg = Instance.new("Frame")
            switchBg.Size = UDim2.new(0, 38, 0, 20)
            switchBg.Position = UDim2.new(1, -48, 0.5, -10)
            switchBg.BackgroundColor3 = state and Theme.Accent or Theme.Header
            switchBg.BorderSizePixel = 0
            switchBg.Parent = container

            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(1, 0)
            sCorner.Parent = switchBg

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = Theme.TextPrimary
            knob.BorderSizePixel = 0
            knob.Parent = switchBg

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = knob

            local function updateToggle(newState)
                state = newState
                tween(switchBg, {BackgroundColor3 = state and Theme.Accent or Theme.Header}, 0.2)
                tween(knob, {
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                }, 0.2)
                if callback then
                    task.spawn(callback, state)
                end
            end

            container.MouseButton1Click:Connect(function()
                updateToggle(not state)
            end)

            return {
                Set = updateToggle,
                GetValue = function() return state end
            }
        end

        -- Element: Numeric Slider
        function tab:AddSlider(sliderText, minVal, maxVal, defaultVal, callback)
            local currentVal = defaultVal or minVal
            minVal = minVal or 0
            maxVal = maxVal or 100

            local container = Instance.new("Frame")
            container.Name = "Slider_" .. sliderText
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = Theme.ElementBackground
            container.BorderSizePixel = 0
            container.Parent = tabContent

            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 6)
            sCorner.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -80, 0, 20)
            label.Position = UDim2.new(0, 12, 0, 6)
            label.BackgroundTransparency = 1
            label.Text = sliderText
            label.TextColor3 = Theme.TextPrimary
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 60, 0, 20)
            valueLabel.Position = UDim2.new(1, -72, 0, 6)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(currentVal)
            valueLabel.TextColor3 = Theme.Accent
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 13
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container

            local track = Instance.new("TextButton")
            track.Name = "Track"
            track.Size = UDim2.new(1, -24, 0, 8)
            track.Position = UDim2.new(0, 12, 0, 32)
            track.BackgroundColor3 = Theme.Header
            track.BorderSizePixel = 0
            track.Text = ""
            track.Parent = container

            local tCorner2 = Instance.new("UICorner")
            tCorner2.CornerRadius = UDim.new(1, 0)
            tCorner2.Parent = track

            local fill = Instance.new("Frame")
            local initRatio = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(initRatio, 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0
            fill.Parent = track

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = fill

            local isSliding = false

            local function updateSlide(input)
                local trackAbsPos = track.AbsolutePosition.X
                local trackAbsSize = track.AbsoluteSize.X
                local relX = math.clamp(input.Position.X - trackAbsPos, 0, trackAbsSize)
                local ratio = relX / trackAbsSize
                local calculatedVal = math.floor(minVal + (maxVal - minVal) * ratio)

                currentVal = calculatedVal
                valueLabel.Text = tostring(currentVal)
                fill.Size = UDim2.new(ratio, 0, 1, 0)

                if callback then
                    task.spawn(callback, currentVal)
                end
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

            return {
                GetValue = function() return currentVal end,
                SetValue = function(val)
                    currentVal = math.clamp(val, minVal, maxVal)
                    local ratio = (currentVal - minVal) / (maxVal - minVal)
                    valueLabel.Text = tostring(currentVal)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                    if callback then
                        task.spawn(callback, currentVal)
                    end
                end
            }
        end

        -- Element: Text Input
        function tab:AddTextBox(boxPlaceholder, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = Theme.ElementBackground
            container.BorderSizePixel = 0
            container.Parent = tabContent

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 6)
            cCorner.Parent = container

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -24, 1, 0)
            textBox.Position = UDim2.new(0, 12, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.PlaceholderText = boxPlaceholder or "Enter input..."
            textBox.PlaceholderColor3 = Theme.TextSecondary
            textBox.Text = ""
            textBox.TextColor3 = Theme.TextPrimary
            textBox.Font = Enum.Font.Gotham
            textBox.TextSize = 13
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.ClearTextOnFocus = false
            textBox.Parent = container

            textBox.FocusLost:Connect(function(enterPressed)
                if callback then
                    task.spawn(callback, textBox.Text, enterPressed)
                end
            end)

            return textBox
        end

        -- Element: Dropdown Selector
        function tab:AddDropdown(dropdownTitle, optionsList, defaultOption, callback)
            optionsList = optionsList or {}
            local selected = defaultOption or (optionsList[1] or "")
            local isExpanded = false

            local container = Instance.new("Frame")
            container.Name = "Dropdown_" .. dropdownTitle
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = Theme.ElementBackground
            container.BorderSizePixel = 0
            container.ClipsDescendants = true
            container.Parent = tabContent

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 6)
            dCorner.Parent = container

            local mainBtn = Instance.new("TextButton")
            mainBtn.Size = UDim2.new(1, 0, 0, 40)
            mainBtn.BackgroundTransparency = 1
            mainBtn.Text = ""
            mainBtn.Parent = container

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(0.5, -12, 1, 0)
            titleLbl.Position = UDim2.new(0, 12, 0, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = dropdownTitle
            titleLbl.TextColor3 = Theme.TextPrimary
            titleLbl.Font = Enum.Font.Gotham
            titleLbl.TextSize = 13
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = mainBtn

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Size = UDim2.new(0.5, -30, 1, 0)
            selectedLbl.Position = UDim2.new(0.5, 0, 0, 0)
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.Text = tostring(selected)
            selectedLbl.TextColor3 = Theme.Accent
            selectedLbl.Font = Enum.Font.GothamMedium
            selectedLbl.TextSize = 13
            selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
            selectedLbl.Parent = mainBtn

            local arrowLbl = Instance.new("TextLabel")
            arrowLbl.Size = UDim2.new(0, 20, 1, 0)
            arrowLbl.Position = UDim2.new(1, -26, 0, 0)
            arrowLbl.BackgroundTransparency = 1
            arrowLbl.Text = "v"
            arrowLbl.TextColor3 = Theme.TextSecondary
            arrowLbl.Font = Enum.Font.GothamBold
            arrowLbl.TextSize = 12
            arrowLbl.Parent = mainBtn

            local optionListFrame = Instance.new("Frame")
            optionListFrame.Size = UDim2.new(1, -16, 0, #optionsList * 28)
            optionListFrame.Position = UDim2.new(0, 8, 0, 42)
            optionListFrame.BackgroundTransparency = 1
            optionListFrame.Parent = container

            local optLayout = Instance.new("UIListLayout")
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Padding = UDim.new(0, 2)
            optLayout.Parent = optionListFrame

            local function toggleDropdown(open)
                isExpanded = open
                local targetHeight = isExpanded and (48 + (#optionsList * 30)) or 40
                tween(container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                arrowLbl.Text = isExpanded and "^" or "v"
            end

            mainBtn.MouseButton1Click:Connect(function()
                toggleDropdown(not isExpanded)
            end)

            for _, opt in ipairs(optionsList) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.BackgroundColor3 = Theme.Header
                optBtn.Text = tostring(opt)
                optBtn.TextColor3 = Theme.TextSecondary
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 12
                optBtn.BorderSizePixel = 0
                optBtn.Parent = optionListFrame

                local oCorner = Instance.new("UICorner")
                oCorner.CornerRadius = UDim.new(0, 4)
                oCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selectedLbl.Text = tostring(opt)
                    toggleDropdown(false)
                    if callback then
                        task.spawn(callback, opt)
                    end
                end)
            end

            return {
                GetSelected = function() return selected end
            }
        end

        return tab
    end

    -- Teardown
    function window:Destroy()
        if screenGui then
            screenGui:Destroy()
        end
    end

    return window
end

return HubUI
