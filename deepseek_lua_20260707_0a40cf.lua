-- UI Library v4.0 (Stable)
local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Цвета
local C = {
    Bg = Color3.fromRGB(20,20,20),
    Elem = Color3.fromRGB(30,30,30),
    Accent = Color3.fromRGB(0,160,255),
    Text = Color3.fromRGB(240,240,240),
    Green = Color3.fromRGB(0,230,100),
    Gray = Color3.fromRGB(120,120,120),
    Hover = Color3.fromRGB(45,45,45)
}

-- Скругление
local function Corner(f,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = f
end

-- Уведомление
function Library:Notify(text, dur)
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0,250,0,50)
    n.Position = UDim2.new(1,-260,0,20 + (#Library.Notifs or 0)*60)
    n.BackgroundColor3 = C.Elem
    n.BorderSizePixel = 0
    n.Parent = LocalPlayer.PlayerGui
    Corner(n,6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,5,0,0)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.Text
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = n
    if not Library.Notifs then Library.Notifs = {} end
    table.insert(Library.Notifs, n)
    local ti = TweenInfo.new(0.3)
    TweenService:Create(n, ti, {BackgroundTransparency = 0.1}):Play()
    wait(dur)
    TweenService:Create(n, ti, {BackgroundTransparency = 1}):Play()
    wait(0.5)
    n:Destroy()
    for i,v in ipairs(Library.Notifs) do if v == n then table.remove(Library.Notifs,i) break end end
end

-- Окно
function Library:CreateWindow(title)
    local win = {}
    win.Tabs = {}
    win.CurTab = nil
    local gui = Instance.new("ScreenGui")
    gui.Name = title
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Parent = LocalPlayer.PlayerGui
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,600,0,400)
    main.Position = UDim2.new(0.5,-300,0.5,-200)
    main.BackgroundColor3 = C.Bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    Corner(main,8)
    -- Заголовок
    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1,0,0,32)
    tb.BackgroundColor3 = C.Elem
    tb.BorderSizePixel = 0
    tb.Parent = main
    Corner(tb,8)
    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1,-80,1,0)
    tt.Position = UDim2.new(0,40,0,0)
    tt.BackgroundTransparency = 1
    tt.TextColor3 = C.Text
    tt.Text = title
    tt.Font = Enum.Font.GothamBold
    tt.TextSize = 14
    tt.Parent = tb
    -- Кнопка закрыть
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,20,0,20)
    close.Position = UDim2.new(1,-24,0.5,-10)
    close.BackgroundColor3 = Color3.fromRGB(255,50,50)
    close.Text = "✕"
    close.TextColor3 = C.Text
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.BorderSizePixel = 0
    close.AutoButtonColor = false
    Corner(close,4)
    close.Parent = tb
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    -- Контейнер вкладок
    local tc = Instance.new("Frame")
    tc.Size = UDim2.new(0,120,1,-32)
    tc.Position = UDim2.new(0,0,0,32)
    tc.BackgroundColor3 = C.Elem
    tc.BorderSizePixel = 0
    tc.Parent = main
    Corner(tc,8)
    local tlist = Instance.new("UIListLayout")
    tlist.SortOrder = Enum.SortOrder.LayoutOrder
    tlist.Parent = tc
    -- Контент
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(1,-120,1,-32)
    cont.Position = UDim2.new(0,120,0,32)
    cont.BackgroundColor3 = C.Bg
    cont.BorderSizePixel = 0
    cont.Parent = main
    -- Открытие/закрытие Insert
    UserInputService.InputBegan:Connect(function(inp, processed)
        if inp.KeyCode == Enum.KeyCode.Insert and not processed then
            main.Visible = not main.Visible
        end
    end)

    function win:CreateTab(name)
        local tab = { Name = name, Elements = {}, Visible = false }
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,28)
        btn.BackgroundColor3 = C.Elem
        btn.TextColor3 = C.Text
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = tc
        Corner(btn,4)
        btn.MouseButton1Click:Connect(function()
            if win.CurTab then
                win.CurTab.Visible = false
                for _,e in ipairs(win.CurTab.Elements) do e.Frame.Visible = false end
            end
            tab.Visible = true
            win.CurTab = tab
            for _,e in ipairs(tab.Elements) do e.Frame.Visible = true end
            btn.BackgroundColor3 = C.Accent
            for _,b in ipairs(tc:GetChildren()) do
                if b:IsA("TextButton") and b ~= btn then b.BackgroundColor3 = C.Elem end
            end
        end)
        -- Функции добавления элементов
        local function addElement(typ, args)
            local elem = { Type = typ, Frame = nil }
            table.insert(tab.Elements, elem)
            return elem
        end
        local yPos = 8
        function tab:AddButton(text, callback)
            local elem = addElement("Button")
            local frame = Instance.new("TextButton")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.TextColor3 = C.Text
            frame.Text = text
            frame.Font = Enum.Font.Gotham
            frame.TextSize = 14
            frame.BorderSizePixel = 0
            frame.AutoButtonColor = false
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            frame.MouseButton1Click:Connect(callback)
            elem.Frame = frame
            return elem
        end
        function tab:AddToggle(text, default, callback)
            local elem = addElement("Toggle")
            elem.Value = default
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0,130,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local tb = Instance.new("TextButton")
            tb.Size = UDim2.new(0,40,0,20)
            tb.Position = UDim2.new(1,-48,0.5,-10)
            tb.BackgroundColor3 = default and C.Green or C.Gray
            tb.Text = ""
            tb.BorderSizePixel = 0
            tb.AutoButtonColor = false
            tb.Parent = frame
            Corner(tb,10)
            local ind = Instance.new("Frame")
            ind.Size = UDim2.new(0,16,0,16)
            ind.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
            ind.BackgroundColor3 = C.Text
            ind.BorderSizePixel = 0
            Corner(ind,8)
            ind.Parent = tb
            local on = default
            tb.MouseButton1Click:Connect(function()
                on = not on
                elem.Value = on
                tb.BackgroundColor3 = on and C.Green or C.Gray
                ind:TweenPosition(on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), "Out","Quad",0.2,true)
                if callback then callback(on) end
            end)
            elem.Frame = frame
            return elem
        end
        function tab:AddSlider(text, min, max, default, callback)
            local elem = addElement("Slider")
            elem.Value = default
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,60)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36+24  -- 60px
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-16,0,20)
            lbl.Position = UDim2.new(0,8,0,5)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text..": "..tostring(default)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1,-20,0,4)
            bar.Position = UDim2.new(0,10,0,35)
            bar.BackgroundColor3 = C.Gray
            bar.BorderSizePixel = 0
            bar.Parent = frame
            local fill = Instance.new("Frame")
            local pct = (default-min)/(max-min)
            fill.Size = UDim2.new(pct,0,1,0)
            fill.BackgroundColor3 = C.Accent
            fill.BorderSizePixel = 0
            fill.Parent = bar
            local thumb = Instance.new("TextButton")
            thumb.Size = UDim2.new(0,12,0,12)
            thumb.Position = UDim2.new(pct,-6,0.5,-6)
            thumb.BackgroundColor3 = C.Text
            thumb.Text = ""
            thumb.BorderSizePixel = 0
            thumb.AutoButtonColor = false
            Corner(thumb,6)
            thumb.Parent = bar
            local drag = false
            thumb.MouseButton1Down:Connect(function() drag = true end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
            end)
            RunService.RenderStepped:Connect(function()
                if drag then
                    local mouse = UserInputService:GetMouseLocation()
                    local barAbs = bar.AbsolutePosition
                    local barSize = bar.AbsoluteSize
                    local relX = math.clamp(mouse.X - barAbs.X, 0, barSize.X)
                    local newPct = relX/barSize.X
                    local val = min + (max-min)*newPct
                    val = math.floor(val*100+0.5)/100
                    fill.Size = UDim2.new(newPct,0,1,0)
                    thumb.Position = UDim2.new(newPct,-6,0.5,-6)
                    lbl.Text = text..": "..tostring(val)
                    elem.Value = val
                    if callback then callback(val) end
                end
            end)
            elem.Frame = frame
            return elem
        end
        function tab:AddDropdown(text, options, callback)
            local elem = addElement("Dropdown")
            elem.Value = options[1]
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0,90,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(0,180,1,-4)
            dropBtn.Position = UDim2.new(1,-188,0,2)
            dropBtn.BackgroundColor3 = C.Elem
            dropBtn.TextColor3 = C.Text
            dropBtn.Text = options[1]
            dropBtn.Font = Enum.Font.Gotham
            dropBtn.TextSize = 14
            dropBtn.BorderSizePixel = 0
            dropBtn.AutoButtonColor = false
            dropBtn.Parent = frame
            Corner(dropBtn,4)
            local dropList = Instance.new("Frame")
            dropList.Size = UDim2.new(0,180,0,0)
            dropList.Position = UDim2.new(1,-188,0,30)
            dropList.BackgroundColor3 = C.Bg
            dropList.BorderSizePixel = 0
            dropList.Visible = false
            dropList.ClipsDescendants = true
            dropList.ZIndex = 15
            dropList.Parent = frame
            Corner(dropList,4)
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = dropList
            local open = false
            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                dropList.Visible = open
                if open then
                    dropList:TweenSize(UDim2.new(0,180,0,#options*25), "Out","Quad",0.2,true)
                else
                    dropList:TweenSize(UDim2.new(0,180,0,0), "Out","Quad",0.2,true)
                end
            end)
            for _,opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1,0,0,25)
                ob.BackgroundColor3 = C.Elem
                ob.TextColor3 = C.Text
                ob.Text = opt
                ob.Font = Enum.Font.Gotham
                ob.TextSize = 14
                ob.BorderSizePixel = 0
                ob.AutoButtonColor = false
                ob.ZIndex = 15
                ob.Parent = dropList
                ob.MouseButton1Click:Connect(function()
                    elem.Value = opt
                    dropBtn.Text = opt
                    open = false
                    dropList:TweenSize(UDim2.new(0,180,0,0), "Out","Quad",0.2,true)
                    wait(0.2)
                    dropList.Visible = false
                    if callback then callback(opt) end
                end)
            end
            elem.Frame = frame
            return elem
        end
        function tab:AddKeybind(text, defaultKey, callback)
            local elem = addElement("Keybind")
            elem.Value = defaultKey
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0,110,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(0,90,1,-4)
            bindBtn.Position = UDim2.new(1,-98,0,2)
            bindBtn.BackgroundColor3 = C.Elem
            bindBtn.TextColor3 = C.Text
            bindBtn.Text = "["..defaultKey.Name.."]"
            bindBtn.Font = Enum.Font.Gotham
            bindBtn.TextSize = 14
            bindBtn.BorderSizePixel = 0
            bindBtn.AutoButtonColor = false
            bindBtn.Parent = frame
            Corner(bindBtn,4)
            local listen = false
            bindBtn.MouseButton1Click:Connect(function()
                listen = true
                bindBtn.Text = "[...]"
                local conn
                conn = UserInputService.InputBegan:Connect(function(inp, proc)
                    if listen and inp.KeyCode ~= Enum.KeyCode.Unknown then
                        listen = false
                        conn:Disconnect()
                        elem.Value = inp.KeyCode
                        bindBtn.Text = "["..inp.KeyCode.Name.."]"
                    end
                end)
            end)
            UserInputService.InputBegan:Connect(function(inp, proc)
                if inp.KeyCode == elem.Value and not proc then callback() end
            end)
            elem.Frame = frame
            return elem
        end
        function tab:AddTextbox(text, default, callback)
            local elem = addElement("Textbox")
            elem.Value = default
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0,110,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local txt = Instance.new("TextBox")
            txt.Size = UDim2.new(0,130,1,-4)
            txt.Position = UDim2.new(1,-138,0,2)
            txt.BackgroundColor3 = C.Bg
            txt.TextColor3 = C.Text
            txt.Text = default
            txt.Font = Enum.Font.Gotham
            txt.TextSize = 14
            txt.PlaceholderText = "..."
            txt.BorderSizePixel = 0
            Corner(txt,4)
            txt.Parent = frame
            txt.FocusLost:Connect(function(enter)
                elem.Value = txt.Text
                if callback then callback(txt.Text) end
            end)
            elem.Frame = frame
            return elem
        end
        function tab:AddColorpicker(text, default, callback)
            local elem = addElement("Colorpicker")
            elem.Value = default
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-16,0,30)
            frame.Position = UDim2.new(0,8,0, yPos)
            yPos = yPos + 36
            frame.BackgroundColor3 = C.Elem
            frame.BorderSizePixel = 0
            frame.Parent = cont
            frame.Visible = tab.Visible
            Corner(frame,4)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0,110,1,0)
            lbl.Position = UDim2.new(0,8,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = C.Text
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local disp = Instance.new("Frame")
            disp.Size = UDim2.new(0,40,0,20)
            disp.Position = UDim2.new(1,-48,0.5,-10)
            disp.BackgroundColor3 = default
            disp.BorderSizePixel = 0
            Corner(disp,4)
            disp.Parent = frame
            local pickerOpen = nil
            local function closePicker()
                if pickerOpen then pickerOpen:Destroy(); pickerOpen = nil end
            end
            disp.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    closePicker()
                    pickerOpen = Instance.new("Frame")
                    pickerOpen.Size = UDim2.new(0,200,0,200)
                    pickerOpen.Position = UDim2.new(0, disp.AbsolutePosition.X-80, 0, disp.AbsolutePosition.Y+30)
                    pickerOpen.BackgroundColor3 = C.Bg
                    pickerOpen.BorderSizePixel = 0
                    pickerOpen.Parent = gui
                    Corner(pickerOpen,8)
                    local ttl = Instance.new("TextLabel")
                    ttl.Size = UDim2.new(1,-10,0,20)
                    ttl.Position = UDim2.new(0,5,0,5)
                    ttl.BackgroundTransparency = 1
                    ttl.TextColor3 = C.Text
                    ttl.Text = "Выбор цвета"
                    ttl.Font = Enum.Font.GothamBold
                    ttl.TextSize = 14
                    ttl.Parent = pickerOpen
                    local prev = Instance.new("Frame")
                    prev.Size = UDim2.new(0,180,0,30)
                    prev.Position = UDim2.new(0.5,-90,0,30)
                    prev.BackgroundColor3 = elem.Value
                    prev.BorderSizePixel = 0
                    Corner(prev,6)
                    prev.Parent = pickerOpen
                    local function makeCS(ch, y, minv, maxv, startv)
                        local sf = Instance.new("Frame")
                        sf.Size = UDim2.new(0,180,0,25)
                        sf.Position = UDim2.new(0,10,0,y)
                        sf.BackgroundColor3 = C.Elem
                        sf.BorderSizePixel = 0
                        sf.Parent = pickerOpen
                        Corner(sf,4)
                        local bg = Instance.new("Frame")
                        bg.Size = UDim2.new(1,-10,0,6)
                        bg.Position = UDim2.new(0,5,0.5,-3)
                        bg.BackgroundColor3 = C.Gray
                        bg.BorderSizePixel = 0
                        bg.Parent = sf
                        local fl = Instance.new("Frame")
                        local pp = (startv-minv)/(maxv-minv)
                        fl.Size = UDim2.new(pp,0,1,0)
                        fl.BackgroundColor3 = C.Accent
                        fl.BorderSizePixel = 0
                        fl.Parent = bg
                        local th = Instance.new("TextButton")
                        th.Size = UDim2.new(0,12,0,12)
                        th.Position = UDim2.new(pp,-6,0.5,-6)
                        th.BackgroundColor3 = C.Text
                        th.Text = ""
                        th.BorderSizePixel = 0
                        th.AutoButtonColor = false
                        Corner(th,6)
                        th.Parent = bg
                        local drag = false
                        th.MouseButton1Down:Connect(function() drag = true end)
                        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
                        RunService.RenderStepped:Connect(function()
                            if drag then
                                local mp = UserInputService:GetMouseLocation()
                                local bs = bg.AbsolutePosition.X
                                local bw = bg.AbsoluteSize.X
                                local rx = math.clamp(mp.X - bs, 0, bw)
                                local p = rx/bw
                                local val = minv + (maxv-minv)*p
                                val = math.floor(val+0.5)
                                fl.Size = UDim2.new(p,0,1,0)
                                th.Position = UDim2.new(p,-6,0.5,-6)
                                if ch == "R" then elem.Value = Color3.fromRGB(val, elem.Value.G*255, elem.Value.B*255)
                                elseif ch == "G" then elem.Value = Color3.fromRGB(elem.Value.R*255, val, elem.Value.B*255)
                                elseif ch == "B" then elem.Value = Color3.fromRGB(elem.Value.R*255, elem.Value.G*255, val)
                                end
                                disp.BackgroundColor3 = elem.Value
                                prev.BackgroundColor3 = elem.Value
                                if callback then callback(elem.Value) end
                            end
                        end)
                    end
                    makeCS("R",65,0,255,default.R*255)
                    makeCS("G",100,0,255,default.G*255)
                    makeCS("B",135,0,255,default.B*255)
                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Size = UDim2.new(0,60,0,24)
                    closeBtn.Position = UDim2.new(0.5,-30,0,170)
                    closeBtn.BackgroundColor3 = C.Accent
                    closeBtn.TextColor3 = C.Text
                    closeBtn.Text = "Готово"
                    closeBtn.Font = Enum.Font.Gotham
                    closeBtn.TextSize = 14
                    closeBtn.BorderSizePixel = 0
                    Corner(closeBtn,4)
                    closeBtn.Parent = pickerOpen
                    closeBtn.MouseButton1Click:Connect(closePicker)
                end
            end)
            elem.Frame = frame
            return elem
        end
        table.insert(win.Tabs, tab)
        return tab
    end
    return win
end

return Library
