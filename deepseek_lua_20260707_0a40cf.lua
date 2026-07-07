-- UI_Library.lua
-- Базовая библиотека элементов интерфейса для читов в Roblox
-- Поддерживает окна, вкладки, кнопки, тогглы, слайдеры, дропдауны

local Library = {}
Library.Windows = {}
Library.CurrentWindow = nil
Library.UIEnabled = false

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Цветовая схема
local Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 180, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Toggled = Color3.fromRGB(0, 255, 100),
    Disabled = Color3.fromRGB(100, 100, 100)
}

-- Создание окна
function Library:CreateWindow(title)
    local Window = {}
    Window.Title = title
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Visible = true

    -- Графический контейнер окна (используем ScreenGui для наглядности)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Colors.Element
    TitleBar.TextColor3 = Colors.Text
    TitleBar.Text = title
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 14
    TitleBar.Parent = MainFrame

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Colors.Element
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -120, 1, -30)
    ContentFrame.Position = UDim2.new(0, 120, 0, 30)
    ContentFrame.BackgroundColor3 = Colors.Background
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabContainer

    Window.MainFrame = MainFrame
    Window.ScreenGui = ScreenGui
    Window.TabContainer = TabContainer
    Window.ContentFrame = ContentFrame

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.ContentFrame = ContentFrame
        Tab.Visible = false

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Colors.Element
        TabButton.TextColor3 = Colors.Text
        TabButton.Text = name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer
        TabButton.AutoButtonColor = false

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
            -- сброс цвета других вкладок
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    btn.BackgroundColor3 = Colors.Element
                end
            end
        end)

        function Tab:AddButton(text, callback)
            local ButtonElem = {Type = "Button", Text = text, Callback = callback}
            local Frame = Instance.new("TextButton")
            Frame.Size = UDim2.new(1, -10, 0, 30)
            Frame.Position = UDim2.new(0, 5, 0, 5 + (#Tab.Elements * 35))
            Frame.BackgroundColor3 = Colors.Element
            Frame.TextColor3 = Colors.Text
            Frame.Text = text
            Frame.Font = Enum.Font.Gotham
            Frame.TextSize = 14
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible
            Frame.AutoButtonColor = false
            Frame.MouseButton1Click:Connect(callback)
            ButtonElem.Frame = Frame
            table.insert(Tab.Elements, ButtonElem)
            return ButtonElem
        end

        function Tab:AddToggle(text, default, callback)
            local ToggleElem = {Type = "Toggle", Text = text, Value = default, Callback = callback}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 30)
            Frame.Position = UDim2.new(0, 5, 0, 5 + (#Tab.Elements * 35))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 150, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleButton.BackgroundColor3 = default and Colors.Toggled or Colors.Disabled
            ToggleButton.Text = ""
            ToggleButton.BorderSizePixel = 0
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = Frame

            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
            ToggleIndicator.Position = default and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9)
            ToggleIndicator.BackgroundColor3 = Colors.Text
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton

            local isOn = default
            ToggleButton.MouseButton1Click:Connect(function()
                isOn = not isOn
                ToggleButton.BackgroundColor3 = isOn and Colors.Toggled or Colors.Disabled
                ToggleIndicator:TweenPosition(
                    UDim2.new(isOn and 1 or 0, isOn and -19 or 1, 0.5, -9),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
                ToggleElem.Value = isOn
                if callback then callback(isOn) end
            end)

            ToggleElem.Frame = Frame
            table.insert(Tab.Elements, ToggleElem)
            return ToggleElem
        end

        function Tab:AddSlider(text, min, max, default, callback)
            local SliderElem = {Type = "Slider", Text = text, Min = min, Max = max, Value = default, Callback = callback}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 60)
            Frame.Position = UDim2.new(0, 5, 0, 5 + (#Tab.Elements * 35))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 5)
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

            local SliderFill = Instance.new("Frame")
            local percent = (default - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderFill.BackgroundColor3 = Colors.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar

            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(0, 12, 0, 12)
            SliderButton.Position = UDim2.new(percent, -6, 0.5, -6)
            SliderButton.BackgroundColor3 = Colors.Text
            SliderButton.Text = ""
            SliderButton.BorderSizePixel = 0
            SliderButton.AutoButtonColor = false
            SliderButton.Parent = SliderBar

            local dragging = false
            SliderButton.MouseButton1Down:Connect(function()
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
                    local barAbsPos = SliderBar.AbsolutePosition
                    local barSize = SliderBar.AbsoluteSize
                    local relativeX = math.clamp(mousePos.X - barAbsPos.X, 0, barSize.X)
                    local percent = relativeX / barSize.X
                    local value = min + (max - min) * percent
                    -- округление до двух знаков
                    value = math.floor(value * 100 + 0.5) / 100
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderButton.Position = UDim2.new(percent, -6, 0.5, -6)
                    Label.Text = text .. ": " .. tostring(value)
                    SliderElem.Value = value
                    if callback then callback(value) end
                end
            end)

            SliderElem.Frame = Frame
            table.insert(Tab.Elements, SliderElem)
            return SliderElem
        end

        function Tab:AddDropdown(text, options, callback)
            local DropdownElem = {Type = "Dropdown", Text = text, Options = options, Value = options[1], Callback = callback}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 30)
            Frame.Position = UDim2.new(0, 5, 0, 5 + (#Tab.Elements * 35))
            Frame.BackgroundColor3 = Colors.Element
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentFrame
            Frame.Visible = Tab.Visible

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 100, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.Text
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local DropButton = Instance.new("TextButton")
            DropButton.Size = UDim2.new(0, 200, 1, -4)
            DropButton.Position = UDim2.new(1, -210, 0, 2)
            DropButton.BackgroundColor3 = Colors.Element
            DropButton.TextColor3 = Colors.Text
            DropButton.Text = options[1]
            DropButton.Font = Enum.Font.Gotham
            DropButton.TextSize = 14
            DropButton.AutoButtonColor = false
            DropButton.Parent = Frame

            local DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(0, 200, 0, 0)
            DropList.Position = UDim2.new(1, -210, 0, 32)
            DropList.BackgroundColor3 = Colors.Background
            DropList.BorderSizePixel = 0
            DropList.Visible = false
            DropList.ClipsDescendants = true
            DropList.Parent = Frame

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
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.BackgroundColor3 = Colors.Element
                OptionButton.TextColor3 = Colors.Text
                OptionButton.Text = option
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 14
                OptionButton.AutoButtonColor = false
                OptionButton.Parent = DropList
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownElem.Value = option
                    DropButton.Text = option
                    open = false
                    DropList:TweenSize(UDim2.new(0, 200, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    wait(0.2)
                    DropList.Visible = false
                    if callback then callback(option) end
                end)
            end

            DropdownElem.Frame = Frame
            table.insert(Tab.Elements, DropdownElem)
            return DropdownElem
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    -- Если это первое окно, скрываем его по нажатию Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    table.insert(Library.Windows, Window)
    return Window
end

return Library