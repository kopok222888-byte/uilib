-- SimpleUI v1.0 – минимальная библиотека для создания окон, вкладок и элементов
local UI = {}
local activeWindows = {}

function UI:CreateWindow(title, accentColor)
    accentColor = accentColor or Color3.fromRGB(255,80,80)
    local scr = Instance.new("ScreenGui")
    scr.Name = title
    if syn and syn.protect_gui then pcall(syn.protect_gui, scr) end
    scr.Parent = game.CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,500,0,350)
    main.Position = UDim2.new(0.5,-250,0.5,-175)
    main.BorderSizePixel = 0
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.Parent = scr

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = accentColor
    titleBar.TextColor3 = Color3.new(1,1,1)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 16
    titleBar.Text = title
    titleBar.Parent = main

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0,120,1,-30)
    tabFrame.Position = UDim2.new(0,0,0,30)
    tabFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = main

    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = tabFrame

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-120,1,-30)
    content.Position = UDim2.new(0,120,0,30)
    content.BackgroundColor3 = Color3.fromRGB(30,30,30)
    content.BorderSizePixel = 0
    content.Parent = main

    local window = {
        gui = scr,
        main = main,
        tabs = {},
        selectedTab = nil
    }

    function window:AddTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Text = name
        btn.BorderSizePixel = 0
        btn.Parent = tabFrame

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,-10,1,-10)
        page.Position = UDim2.new(0,5,0,5)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Parent = content
        page.Visible = false

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,4)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = page

        local tab = { button = btn, page = page, elements = {} }

        function tab:Activate()
            if window.selectedTab then
                window.selectedTab.page.Visible = false
                window.selectedTab.button.BackgroundColor3 = Color3.fromRGB(40,40,40)
            end
            window.selectedTab = tab
            tab.page.Visible = true
            tab.button.BackgroundColor3 = accentColor
        end

        function tab:AddButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,30)
            b.BackgroundColor3 = Color3.fromRGB(50,50,50)
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.Text = text
            b.BorderSizePixel = 0
            b.Parent = page
            b.MouseButton1Click:Connect(callback)
            table.insert(tab.elements, b)
            page.CanvasSize = UDim2.new(0,0,0,#tab.elements * 34)
            return b
        end

        function tab:AddToggle(text, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,0,0,30)
            frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
            frame.BorderSizePixel = 0
            frame.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.Text = text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local togg = Instance.new("TextButton")
            togg.Size = UDim2.new(0,50,1,-4)
            togg.Position = UDim2.new(1,-55,0,2)
            togg.BackgroundColor3 = default and accentColor or Color3.fromRGB(80,80,80)
            togg.TextColor3 = Color3.new(1,1,1)
            togg.Font = Enum.Font.GothamBold
            togg.TextSize = 12
            togg.Text = default and "ON" or "OFF"
            togg.BorderSizePixel = 0
            togg.Parent = frame

            local state = default
            togg.MouseButton1Click:Connect(function()
                state = not state
                togg.BackgroundColor3 = state and accentColor or Color3.fromRGB(80,80,80)
                togg.Text = state and "ON" or "OFF"
                callback(state)
            end)
            table.insert(tab.elements, frame)
            page.CanvasSize = UDim2.new(0,0,0,#tab.elements * 34)
            return {
                Set = function(v)
                    state = v
                    togg.BackgroundColor3 = state and accentColor or Color3.fromRGB(80,80,80)
                    togg.Text = state and "ON" or "OFF"
                end
            }
        end

        btn.MouseButton1Click:Connect(function() tab:Activate() end)
        table.insert(window.tabs, tab)
        if #window.tabs == 1 then tab:Activate() end
        return tab
    end

    function window:Destroy()
        scr:Destroy()
    end

    table.insert(activeWindows, window)
    return window
end

return UI