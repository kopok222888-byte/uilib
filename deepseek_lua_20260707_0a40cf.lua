-- Enhanced UI Library v2.0
-- Улучшения: дизайн, ResetOnSpawn, кнопки свернуть/закрыть, фикс ползунков, анимация кликов

local Library = {}
Library.Windows = {}
Library.Notifications = {}

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Цветовая схема
local Colors = {
    Background = Color3.fromRGB(18, 18, 18),
    Element = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Toggled = Color3.fromRGB(0, 230, 100),
    Disabled = Color3.fromRGB(120, 120, 120),
    ButtonHover = Color3.fromRGB(45, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Тени и скругления
local function applyShadow(frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993" -- стандартная тень
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.Parent = frame
    shadow.ZIndex = 0
end

local function makeCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

-- Функция создания уведомления (остаётся прежней)
function Library:CreateNotification(text, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 250, 0, 50)
    notification.Position = UDim2.new(1, -260, 0, 20 + (#Library.Notifications * 60))
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BorderSizePixel = 0
    notification.Parent = LocalPlayer.PlayerGui
    makeCorner(notification, 6)
    applyShadow(notification)

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

-- Создание окна
function Library:CreateWindow(title)
    local Window = {}
    Window.Title = title
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false

    -- Используем PlayerGui, но с ResetOnSpawn = false, чтобы GUI не исчезал при смерти
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title
    ScreenGui.ResetOnSpawn = false   -- КРИТИЧЕСКИ ВАЖНО
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Основная рамка
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    makeCorner(MainFrame, 8)
    applyShadow(MainFrame)

    -- Заголовок с кнопками управления
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

    -- Кнопка сворачивания
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
        -- Показать маленький значок для восстановления
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

    -- Кнопка закрытия
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

    -- Контейнер для вкладок
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 130, 1, -32)
    TabContainer.Position = UDim2.new(0, 0, 0, 32)
    TabContainer.BackgroundColor3 = Colors.Element
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    makeCorner(TabContainer, 8)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -130, 1, -32)
    ContentFrame.Position = UDim2.new(0, 130, 0, 32)
    ContentFrame.BackgroundColor3 = Colors.Background
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    -- Переключение видимости по Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Создание вкладки
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
            -- Подсвечиваем активную вкладку
            TabButton.BackgroundColor3 = Colors.Accent
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    btn.BackgroundColor3 = Colors.Element
                end
            end
        end)

        -- Элементы интерфейса

        -- Кнопка с анимацией клика
        function Tab:AddButton(text, callback)
            local elem = {Type = "Button", Text = text, Callback = callback}
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
            makeCorner(Frame, 4)

            -- Анимация нажатия
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

        -- Тоггл
        function Tab:AddToggle(text, default, callback)
            local elem = {Type = "Toggle", Text = text, Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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

        -- Ползунок (исправлен)
        function Tab:AddSlider(text, min, max, default, callback)
            local elem = {Type = "Slider", Text = text, Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 60)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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
            SliderBar.Parent = Frame

            local Fill = Instance.new("Frame")
            local percent = (default - min) / (max - min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Fill.BackgroundColor3 = Colors.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = SliderBar

            local Thumb = Instance.new("TextButton")
            Thumb.Size = UDim2.new(0, 12, 0, 12)
            Thumb.Position = UDim2.new(percent, -6, 0.5, -6)
            Thumb.BackgroundColor3 = Colors.Text
            Thumb.Text = ""
            Thumb.BorderSizePixel = 0
            Thumb.AutoButtonColor = false
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
            -- Более стабильное обновление позиции
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local barStart = SliderBar.AbsolutePosition.X
                    local barWidth = SliderBar.AbsoluteSize.X
                    local relativeX = math.clamp(mousePos.X - barStart, 0, barWidth)
                    local newPercent = relativeX / barWidth
                    local val = min + (max - min) * newPercent
                    val = math.floor(val * 100 + 0.5) / 100 -- округление до 2 знаков
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

        -- Дропдаун
        function Tab:AddDropdown(text, options, callback)
            local elem = {Type = "Dropdown", Value = options[1]}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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

        -- Бинд клавиши
        function Tab:AddKeybind(text, defaultKey, callback)
            local elem = {Type = "Keybind", Text = text, Value = defaultKey}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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

            -- Фактический бинд
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == elem.Value and not gameProcessed then
                    callback()
                end
            end)

            elem.Frame = Frame
            table.insert(Tab.Elements, elem)
            return elem
        end

        -- Текстовое поле
        function Tab:AddTextbox(text, default, callback)
            local elem = {Type = "Textbox", Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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

        -- Цветовой пикер
        function Tab:AddColorpicker(text, default, callback)
            local elem = {Type = "Colorpicker", Value = default}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -16, 0, 30)
            Frame.Position = UDim2.new(0, 8, 0, 8 + (#Tab.Elements * 36))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
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

            ColorDisplay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pickerFrame = Instance.new("Frame")
                    pickerFrame.Size = UDim2.new(0, 200, 0, 200)
                    pickerFrame.Position = UDim2.new(0, ColorDisplay.AbsolutePosition.X - 100, 0, ColorDisplay.AbsolutePosition.Y + 30)
                    pickerFrame.BackgroundColor3 = Colors.Background
                    pickerFrame.BorderSizePixel = 0
                    pickerFrame.Parent = ScreenGui
                    makeCorner(pickerFrame, 8)

                    local function closePicker()
                        pickerFrame:Destroy()
                    end

                    local rSlider = Tab:AddSlider("R", 0, 255, default.R * 255, function(val)
                        elem.Value = Color3.fromRGB(val, elem.Value.G * 255, elem.Value.B * 255)
                        ColorDisplay.BackgroundColor3 = elem.Value
                        if callback then callback(elem.Value) end
                    end)
                    rSlider.Frame.Parent = pickerFrame
                    rSlider.Frame.Size = UDim2.new(1, -20, 0, 40)
                    rSlider.Frame.Position = UDim2.new(0, 10, 0, 10)

                    local gSlider = Tab:AddSlider("G", 0, 255, default.G * 255, function(val)
                        elem.Value = Color3.fromRGB(elem.Value.R * 255, val, elem.Value.B * 255)
                        ColorDisplay.BackgroundColor3 = elem.Value
                        if callback then callback(elem.Value) end
                    end)
                    gSlider.Frame.Parent = pickerFrame
                    gSlider.Frame.Size = UDim2.new(1, -20, 0, 40)
                    gSlider.Frame.Position = UDim2.new(0, 10, 0, 60)

                    local bSlider = Tab:AddSlider("B", 0, 255, default.B * 255, function(val)
                        elem.Value = Color3.fromRGB(elem.Value.R * 255, elem.Value.G * 255, val)
                        ColorDisplay.BackgroundColor3 = elem.Value
                        if callback then callback(elem.Value) end
                    end)
                    bSlider.Frame.Parent = pickerFrame
                    bSlider.Frame.Size = UDim2.new(1, -20, 0, 40)
                    bSlider.Frame.Position = UDim2.new(0, 10, 0, 110)

                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Size = UDim2.new(1, -20, 0, 30)
                    closeBtn.Position = UDim2.new(0, 10, 0, 160)
                    closeBtn.BackgroundColor3 = Colors.Accent
                    closeBtn.TextColor3 = Colors.Text
                    closeBtn.Text = "Закрыть"
                    closeBtn.Font = Enum.Font.Gotham
                    closeBtn.TextSize = 14
                    closeBtn.Parent = pickerFrame
                    closeBtn.MouseButton1Click:Connect(closePicker)
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
