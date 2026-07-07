-- ============================================================
-- UI Library v2.2 (встроенная)
-- ============================================================
local Library = {}
Library.Windows = {}
Library.Notifications = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Colors = {
    Background = Color3.fromRGB(18, 18, 18),
    Element = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Toggled = Color3.fromRGB(0, 230, 100),
    Disabled = Color3.fromRGB(120, 120, 120),
    ButtonHover = Color3.fromRGB(45, 45, 45)
}

local function makeCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

function Library:CreateNotification(text, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 250, 0, 50)
    notification.Position = UDim2.new(1, -260, 0, 20 + (#Library.Notifications * 60))
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BorderSizePixel = 0
    notification.Parent = LocalPlayer:WaitForChild("PlayerGui")
    makeCorner(notification, 6)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Colors.Text
    textLabel.Text = text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = notification

    table.insert(Library.Notifications, notification)

    local tween = TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0.1})
    tween:Play()
    tween.Completed:Connect(function()
        wait(duration)
        local fadeTween = TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            notification:Destroy()
            for i, v in ipairs(Library.Notifications) do
                if v == notification then
                    table.remove(Library.Notifications, i)
                    break
                end
            end
        end)
    end)
end

function Library:CreateWindow(title)
    local Window = {}
    Window.Title = title
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 1000
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 2
    MainFrame.Parent = ScreenGui
    makeCorner(MainFrame, 8)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Colors.Element
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    makeCorner(TitleBar, 8)

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 40, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Colors.Text
    TitleText.Text = title
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.Parent = TitleBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Position = UDim2.new(1, -54, 0.5, -10)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Colors.Text
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 14
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.AutoButtonColor = false
    makeCorner(MinimizeBtn, 4)
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        Window.Minimized = true
        local RestoreBtn = ScreenGui:FindFirstChild("RestoreBtn")
        if not RestoreBtn then
            RestoreBtn = Instance.new("TextButton")
            RestoreBtn.Name = "RestoreBtn"
            RestoreBtn.Size = UDim2.new(0, 30, 0, 30)
            RestoreBtn.Position = UDim2.new(0, 10, 0, 10)
            RestoreBtn.BackgroundColor3 = Colors.Accent
            RestoreBtn.Text = "⌂"
            RestoreBtn.TextColor3 = Colors.Text
            RestoreBtn.Font = Enum.Font.GothamBold
            RestoreBtn.TextSize = 18
            RestoreBtn.BorderSizePixel = 0
            makeCorner(RestoreBtn, 6)
            RestoreBtn.Parent = ScreenGui
            RestoreBtn.MouseButton1Click:Connect(function()
                MainFrame.Visible = true
                Window.Minimized = false
                RestoreBtn:Destroy()
            end)
        end
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -24, 0.5, -10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.Text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.BorderSizePixel = 0
    CloseBtn.AutoButtonColor = false
    makeCorner(CloseBtn, 4)
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 130, 1, -32)
    TabContainer.Position = UDim2.new(0, 0, 0, 32)
    TabContainer.BackgroundColor3 = Colors.Element
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    makeCorner(TabContainer, 8)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -130, 1, -32)
    ContentFrame.Position = UDim2.new(0, 130, 0, 32)
    ContentFrame.BackgroundColor3 = Colors.Background
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Блокируем закрытие по Escape (оставляем только Insert)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
            -- Ничего не делаем, не даём скрыться меню
        end
    end)

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.Visible = false

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Colors.Element
        TabButton.TextColor3 = Colors.Text
        TabButton.Text = name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.BorderSizePixel = 0
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        makeCorner(TabButton, 4)

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Visible = false
                for _, elem in ipairs(Window.CurrentTab.Elements) do
                    if elem.Frame then elem.Frame.Visible = false end
                end
            end
            Tab.Visible = true
            Window.CurrentTab = Tab
            for _, elem in ipairs(Tab.Elements) do
                if elem.Frame then elem.Frame.Visible = true end
            end
            TabButton.BackgroundColor3 = Colors.Accent
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    btn.BackgroundColor3 = Colors.Element
                end
            end
        end)

        function Tab:AddButton(text, callback)
            local elem = {Type = "Button", Text = text}
            local Frame = Instance.new("TextButton")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.TextColor3 = Colors.Text
            Frame.Text = text
            Frame.Font = Enum.Font.Gotham
            Frame.TextSize = 14
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.AutoButtonColor = false
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            Frame.MouseButton1Down:Connect(function()
                TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Colors.ButtonHover}):Play()
                TweenService:Create(Frame, TweenInfo.new(0.05), {Size = UDim2.new(1, -16, 0, 28)}):Play()
            end)
            Frame.MouseButton1Up:Connect(function()
                TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Element}):Play()
                TweenService:Create(Frame, TweenInfo.new(0.05), {Size = UDim2.new(1, -16, 0, 30)}):Play()
            end)
            Frame.MouseButton1Click:Connect(callback)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddToggle(text, default, callback)
            local elem = {Type = "Toggle", Text = text, Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 150, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
            ToggleButton.BackgroundColor3 = default and Colors.Toggled or Colors.Disabled
            ToggleButton.Text = ""
            ToggleButton.BorderSizePixel = 0
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = Frame
            makeCorner(ToggleButton, 10)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Indicator.BackgroundColor3 = Colors.Text
            Indicator.BorderSizePixel = 0
            makeCorner(Indicator, 8)
            Indicator.Parent = ToggleButton

            local isOn = default
            ToggleButton.MouseButton1Click:Connect(function()
                isOn = not isOn
                ToggleButton.BackgroundColor3 = isOn and Colors.Toggled or Colors.Disabled
                Indicator:TweenPosition(
                    UDim2.new(isOn and 1 or 0, isOn and -18 or 2, 0.5, -8),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
                elem.Value = isOn
                if callback then callback(isOn) end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddSlider(text, min, max, default, callback)
            local elem = {Type = "Slider", Text = text, Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 60)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -16, 0, 20)
            Label.Position = UDim2.new(0, 8, 0, 5)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text .. ": " .. tostring(default)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -20, 0, 4)
            SliderBar.Position = UDim2.new(0, 10, 0, 35)
            SliderBar.BackgroundColor3 = Colors.Disabled
            SliderBar.BorderSizePixel = 0
            SliderBar.ZIndex = 6
            SliderBar.Parent = Frame

            local Fill = Instance.new("Frame")
            local percent = (default - min) / (max - min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Fill.BackgroundColor3 = Colors.Accent
            Fill.BorderSizePixel = 0
            Fill.ZIndex = 6
            Fill.Parent = SliderBar

            local Thumb = Instance.new("TextButton")
            Thumb.Size = UDim2.new(0, 12, 0, 12)
            Thumb.Position = UDim2.new(percent, -6, 0.5, -6)
            Thumb.BackgroundColor3 = Colors.Text
            Thumb.Text = ""
            Thumb.BorderSizePixel = 0
            Thumb.AutoButtonColor = false
            Thumb.ZIndex = 10
            makeCorner(Thumb, 6)
            Thumb.Parent = SliderBar

            local dragging = false
            Thumb.MouseButton1Down:Connect(function()
                dragging = true
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local barStart = SliderBar.AbsolutePosition.X
                    local barWidth = SliderBar.AbsoluteSize.X
                    local relativeX = math.clamp(mousePos.X - barStart, 0, barWidth)
                    local newPercent = relativeX / barWidth
                    local val = min + (max - min) * newPercent
                    val = math.floor(val * 100 + 0.5) / 100
                    Fill.Size = UDim2.new(newPercent, 0, 1, 0)
                    Thumb.Position = UDim2.new(newPercent, -6, 0.5, -6)
                    Label.Text = text .. ": " .. tostring(val)
                    elem.Value = val
                    if callback then callback(val) end
                end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddDropdown(text, options, callback)
            local elem = {Type = "Dropdown", Value = options[1]}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 100, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local DropButton = Instance.new("TextButton")
            DropButton.Size = UDim2.new(0, 200, 1, -4)
            DropButton.Position = UDim2.new(1, -208, 0, 2)
            DropButton.BackgroundColor3 = Colors.Element
            DropButton.TextColor3 = Colors.Text
            DropButton.Text = options[1]
            DropButton.Font = Enum.Font.Gotham
            DropButton.TextSize = 14
            DropButton.AutoButtonColor = false
            DropButton.Parent = Frame
            makeCorner(DropButton, 4)

            local DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(0, 200, 0, 0)
            DropList.Position = UDim2.new(1, -208, 0, 32)
            DropList.BackgroundColor3 = Colors.Background
            DropList.BorderSizePixel = 0
            DropList.Visible = false
            DropList.ClipsDescendants = true
            DropList.ZIndex = 15
            DropList.Parent = Frame
            makeCorner(DropList, 4)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropList

            local open = false
            DropButton.MouseButton1Click:Connect(function()
                open = not open
                DropList.Visible = open
                if open then
                    DropList:TweenSize(UDim2.new(0, 200, 0, #options * 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                else
                    DropList:TweenSize(UDim2.new(0, 200, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end
            end)

            for _, option in ipairs(options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Size = UDim2.new(1, 0, 0, 25)
                OptionBtn.BackgroundColor3 = Colors.Element
                OptionBtn.TextColor3 = Colors.Text
                OptionBtn.Text = option
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.TextSize = 14
                OptionBtn.AutoButtonColor = false
                OptionBtn.ZIndex = 15
                OptionBtn.Parent = DropList
                OptionBtn.MouseButton1Click:Connect(function()
                    elem.Value = option
                    DropButton.Text = option
                    open = false
                    DropList:TweenSize(UDim2.new(0, 200, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    wait(0.2)
                    DropList.Visible = false
                    if callback then callback(option) end
                end)
            end

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddKeybind(text, defaultKey, callback)
            local elem = {Type = "Keybind", Text = text, Value = defaultKey}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 120, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 100, 1, -4)
            BindBtn.Position = UDim2.new(1, -108, 0, 2)
            BindBtn.BackgroundColor3 = Colors.Element
            BindBtn.TextColor3 = Colors.Text
            BindBtn.Text = "[" .. defaultKey.Name .. "]"
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 14
            BindBtn.AutoButtonColor = false
            BindBtn.Parent = Frame
            makeCorner(BindBtn, 4)

            local listening = false
            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "[...]"
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        conn:Disconnect()
                        elem.Value = input.KeyCode
                        BindBtn.Text = "[" .. input.KeyCode.Name .. "]"
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == elem.Value and not gameProcessed then
                    callback()
                end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddTextbox(text, default, callback)
            local elem = {Type = "Textbox", Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 120, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0, 150, 1, -4)
            TextBox.Position = UDim2.new(1, -158, 0, 2)
            TextBox.BackgroundColor3 = Colors.Background
            TextBox.TextColor3 = Colors.Text
            TextBox.Text = default
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 14
            TextBox.PlaceholderText = "Введите..."
            TextBox.BorderSizePixel = 0
            makeCorner(TextBox, 4)
            TextBox.Parent = Frame

            TextBox.FocusLost:Connect(function(enterPressed)
                elem.Value = TextBox.Text
                if callback then callback(TextBox.Text) end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        function Tab:AddColorpicker(text, default, callback)
            local elem = {Type = "Colorpicker", Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.ZIndex = 5
            makeCorner(Frame, 4)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 120, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ColorDisplay = Instance.new("Frame")
            ColorDisplay.Size = UDim2.new(0, 40, 0, 20)
            ColorDisplay.Position = UDim2.new(1, -48, 0.5, -10)
            ColorDisplay.BackgroundColor3 = default
            ColorDisplay.BorderSizePixel = 0
            makeCorner(ColorDisplay, 4)
            ColorDisplay.Parent = Frame

            local activePicker = nil

            local function closePicker()
                if activePicker then
                    activePicker:Destroy()
                    activePicker = nil
                end
            end

            ColorDisplay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    closePicker()

                    activePicker = Instance.new("Frame")
                    activePicker.Size = UDim2.new(0, 220, 0, 220)
                    activePicker.Position = UDim2.new(0, ColorDisplay.AbsolutePosition.X - 90, 0, ColorDisplay.AbsolutePosition.Y + 30)
                    activePicker.BackgroundColor3 = Colors.Background
                    activePicker.BorderSizePixel = 0
                    activePicker.ZIndex = 20
                    activePicker.Parent = ScreenGui
                    makeCorner(activePicker, 10)

                    local pickerTitle = Instance.new("TextLabel")
                    pickerTitle.Size = UDim2.new(1, -20, 0, 25)
                    pickerTitle.Position = UDim2.new(0, 10, 0, 5)
                    pickerTitle.BackgroundTransparency = 1
                    pickerTitle.TextColor3 = Colors.Text
                    pickerTitle.Text = "Выбор цвета"
                    pickerTitle.Font = Enum.Font.GothamBold
                    pickerTitle.TextSize = 14
                    pickerTitle.Parent = activePicker

                    local preview = Instance.new("Frame")
                    preview.Size = UDim2.new(0, 200, 0, 30)
                    preview.Position = UDim2.new(0.5, -100, 0, 35)
                    preview.BackgroundColor3 = elem.Value
                    preview.BorderSizePixel = 0
                    makeCorner(preview, 6)
                    preview.Parent = activePicker

                    local function makeColorSlider(channel, yPos, minVal, maxVal, startVal)
                        local sliderFrame = Instance.new("Frame")
                        sliderFrame.Size = UDim2.new(0, 200, 0, 25)
                        sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
                        sliderFrame.BackgroundColor3 = Colors.Element
                        sliderFrame.BorderSizePixel = 0
                        sliderFrame.Parent = activePicker
                        makeCorner(sliderFrame, 4)

                        local bg = Instance.new("Frame")
                        bg.Size = UDim2.new(1, -10, 0, 6)
                        bg.Position = UDim2.new(0, 5, 0.5, -3)
                        bg.BackgroundColor3 = Colors.Disabled
                        bg.BorderSizePixel = 0
                        bg.Parent = sliderFrame

                        local fill = Instance.new("Frame")
                        local percent = (startVal - minVal) / (maxVal - minVal)
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        fill.BackgroundColor3 = Colors.Accent
                        fill.BorderSizePixel = 0
                        fill.Parent = bg

                        local thumb = Instance.new("TextButton")
                        thumb.Size = UDim2.new(0, 12, 0, 12)
                        thumb.Position = UDim2.new(percent, -6, 0.5, -6)
                        thumb.BackgroundColor3 = Colors.Text
                        thumb.Text = ""
                        thumb.BorderSizePixel = 0
                        thumb.AutoButtonColor = false
                        thumb.ZIndex = 10
                        makeCorner(thumb, 6)
                        thumb.Parent = bg

                        local dragging = false
                        thumb.MouseButton1Down:Connect(function() dragging = true end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                        end)
                        RunService.RenderStepped:Connect(function()
                            if dragging then
                                local mousePos = UserInputService:GetMouseLocation()
                                local barStart = bg.AbsolutePosition.X
                                local barWidth = bg.AbsoluteSize.X
                                local relX = math.clamp(mousePos.X - barStart, 0, barWidth)
                                local pct = relX / barWidth
                                local val = minVal + (maxVal - minVal) * pct
                                val = math.floor(val + 0.5)
                                fill.Size = UDim2.new(pct, 0, 1, 0)
                                thumb.Position = UDim2.new(pct, -6, 0.5, -6)
                                if channel == "R" then
                                    elem.Value = Color3.fromRGB(val, elem.Value.G * 255, elem.Value.B * 255)
                                elseif channel == "G" then
                                    elem.Value = Color3.fromRGB(elem.Value.R * 255, val, elem.Value.B * 255)
                                elseif channel == "B" then
                                    elem.Value = Color3.fromRGB(elem.Value.R * 255, elem.Value.G * 255, val)
                                end
                                ColorDisplay.BackgroundColor3 = elem.Value
                                preview.BackgroundColor3 = elem.Value
                                if callback then callback(elem.Value) end
                            end
                        end)

                        return {bg = bg, fill = fill, thumb = thumb}
                    end

                    makeColorSlider("R", 75, 0, 255, default.R * 255)
                    makeColorSlider("G", 110, 0, 255, default.G * 255)
                    makeColorSlider("B", 145, 0, 255, default.B * 255)

                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Size = UDim2.new(0, 80, 0, 25)
                    closeBtn.Position = UDim2.new(0.5, -40, 0, 185)
                    closeBtn.BackgroundColor3 = Colors.Accent
                    closeBtn.TextColor3 = Colors.Text
                    closeBtn.Text = "Закрыть"
                    closeBtn.Font = Enum.Font.Gotham
                    closeBtn.TextSize = 14
                    closeBtn.BorderSizePixel = 0
                    makeCorner(closeBtn, 4)
                    closeBtn.Parent = activePicker
                    closeBtn.MouseButton1Click:Connect(closePicker)

                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = UserInputService:GetMouseLocation()
                            if activePicker and (pos.X < activePicker.AbsolutePosition.X or pos.X > activePicker.AbsolutePosition.X + activePicker.AbsoluteSize.X
                                or pos.Y < activePicker.AbsolutePosition.Y or pos.Y > activePicker.AbsolutePosition.Y + activePicker.AbsoluteSize.Y) then
                                closePicker()
                                connection:Disconnect()
                            end
                        end
                    end)

                    activePicker.Destroying:Connect(function()
                        if connection then connection:Disconnect() end
                    end)
                end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    table.insert(Library.Windows, Window)
    return Window
end

return Library
-- ============================================================
-- Конец встроенной библиотеки
-- ============================================================
