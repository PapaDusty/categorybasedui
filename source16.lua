--[[
    VapeV4 Style UI Library (FIXED)
    - Menu now shows up properly
    - Categories auto-expand by default
    - Removed GUICategory
    - Added Settings tab at the end
]]

local mainapi = {
    Categories = {},
    GUIColor = {
        Hue = 0.46,
        Sat = 0.96,
        Value = 0.52
    },
    HeldKeybinds = {},
    Keybind = {'RightShift'},
    Loaded = false,
    Libraries = {},
    Modules = {},
    Profile = 'default',
    RainbowSpeed = {Value = 1},
    RainbowUpdateSpeed = {Value = 60},
    RainbowTable = {},
    Scale = {Value = 1},
    ThreadFix = setthreadidentity and true or false,
    ToggleNotifications = {},
    Version = '1.0',
    Windows = {}
}

local cloneref = cloneref or function(obj)
    return obj
end
local tweenService = cloneref(game:GetService('TweenService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local guiService = cloneref(game:GetService('GuiService'))
local runService = cloneref(game:GetService('RunService'))
local httpService = cloneref(game:GetService('HttpService'))

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
local notifications
local clickgui
local scaledgui
local toolblur
local tooltip
local scale
local gui

local color = {}
local tween = {
    tweens = {},
    tweenstwo = {}
}
local uipallet = {
    Main = Color3.fromRGB(26, 25, 26),
    Text = Color3.fromRGB(200, 200, 200),
    Font = Font.fromEnum(Enum.Font.Arial),
    FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.SemiBold),
    Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
}

local getcustomasset = function(path)
    return path
end

local function getTableSize(tab)
    local ind = 0
    for _ in tab do ind += 1 end
    return ind
end

local function loopClean(tab)
    for i, v in tab do
        if type(v) == 'table' then
            loopClean(v)
        end
        tab[i] = nil
    end
end

local function getfontsize(text, size, font)
    fontsize.Text = text
    fontsize.Size = size
    if typeof(font) == 'Font' then
        fontsize.Font = font
    end
    return textService:GetTextBoundsAsync(fontsize)
end

local clamp = function(x, a, b) return math.max(a, math.min(b, x)) end

local function addBlur(parent, notif)
    local blur = Instance.new('ImageLabel')
    blur.Name = 'Blur'
    blur.Size = UDim2.new(1, 89, 1, 52)
    blur.Position = UDim2.fromOffset(-48, -31)
    blur.BackgroundTransparency = 1
    blur.Image = 'rbxassetid://14898786664'
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(52, 31, 261, 502)
    blur.Parent = parent
    return blur
end

local function addCorner(parent, radius)
    local corner = Instance.new('UICorner')
    corner.CornerRadius = radius or UDim.new(0, 5)
    corner.Parent = parent
    return corner
end

local function addCloseButton(parent, offset)
    local close = Instance.new('ImageButton')
    close.Name = 'Close'
    close.Size = UDim2.fromOffset(24, 24)
    close.Position = UDim2.new(1, -35, 0, offset or 9)
    close.BackgroundColor3 = Color3.new(1, 1, 1)
    close.BackgroundTransparency = 1
    close.AutoButtonColor = false
    close.Image = 'rbxassetid://14368309446'
    close.ImageColor3 = color.Light(uipallet.Text, 0.2)
    close.ImageTransparency = 0.5
    close.Parent = parent
    addCorner(close, UDim.new(1, 0))

    close.MouseEnter:Connect(function()
        close.ImageTransparency = 0.3
        tween:Tween(close, uipallet.Tween, {
            BackgroundTransparency = 0.6
        })
    end)
    close.MouseLeave:Connect(function()
        close.ImageTransparency = 0.5
        tween:Tween(close, uipallet.Tween, {
            BackgroundTransparency = 1
        })
    end)

    return close
end

local function addMaid(object)
    object.Connections = {}
    function object:Clean(callback)
        if typeof(callback) == 'Instance' then
            table.insert(self.Connections, {
                Disconnect = function()
                    callback:ClearAllChildren()
                    callback:Destroy()
                end
            })
        elseif type(callback) == 'function' then
            table.insert(self.Connections, {
                Disconnect = callback
            })
        else
            table.insert(self.Connections, callback)
        end
    end
end

local function addTooltip(gui, text)
    if not text then return end

    local function tooltipMoved(x, y)
        local right = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
        tooltip.Position = UDim2.fromOffset(
            (right and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
            ((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
        )
        tooltip.Visible = toolblur.Visible
    end

    gui.MouseEnter:Connect(function(x, y)
        local tooltipSize = getfontsize(text, tooltip.TextSize, uipallet.Font)
        tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10)
        tooltip.Text = text
        tooltipMoved(x, y)
    end)
    gui.MouseMoved:Connect(tooltipMoved)
    gui.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

local function checkKeybinds(compare, target, key)
    if type(target) == 'table' then
        if table.find(target, key) then
            for i, v in target do
                if not table.find(compare, v) then
                    return false
                end
            end
            return true
        end
    end
    return false
end

local function randomString()
    local array = {}
    for i = 1, math.random(10, 100) do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

local function removeTags(str)
    str = str:gsub('<br%s*/>', '\n')
    return str:gsub('<[^<>]->', '')
end

do
    function color.Dark(col, num)
        local h, s, v = col:ToHSV()
        return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
    end

    function color.Light(col, num)
        local h, s, v = col:ToHSV()
        return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
    end

    function mainapi:Color(h)
        local s = 0.75 + (0.15 * math.min(h / 0.03, 1))
        if h > 0.57 then
            s = 0.9 - (0.4 * math.min((h - 0.57) / 0.09, 1))
        end
        if h > 0.66 then
            s = 0.5 + (0.4 * math.min((h - 0.66) / 0.16, 1))
        end
        if h > 0.87 then
            s = 0.9 - (0.15 * math.min((h - 0.87) / 0.13, 1))
        end
        return h, s, 1
    end

    function mainapi:TextColor(h, s, v)
        if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
            return Color3.new(0.19, 0.19, 0.19)
        end
        return Color3.new(1, 1, 1)
    end
end

do
    function tween:Tween(obj, tweeninfo, goal, tab)
        tab = tab or self.tweens
        if tab[obj] then
            tab[obj]:Cancel()
            tab[obj] = nil
        end

        if obj.Parent and obj.Visible then
            tab[obj] = tweenService:Create(obj, tweeninfo, goal)
            tab[obj].Completed:Once(function()
                if tab then
                    tab[obj] = nil
                    tab = nil
                end
            end)
            tab[obj]:Play()
        else
            for i, v in goal do
                obj[i] = v
            end
        end
    end

    function tween:Cancel(obj)
        if self.tweens[obj] then
            self.tweens[obj]:Cancel()
            self.tweens[obj] = nil
        end
    end
end

mainapi.Libraries = {
    color = color,
    getcustomasset = getcustomasset,
    getfontsize = getfontsize,
    tween = tween,
    uipallet = uipallet,
}

-- Components table (abbreviated for space - include all your component functions here)
local components = {}
-- ... (all your component functions here - Button, ColorSlider, Dropdown, etc.)
-- I'm omitting them for brevity since they're the same as your original

mainapi.Components = setmetatable(components, {
    __newindex = function(self, ind, func)
        for _, v in mainapi.Modules do
            rawset(v, 'Create'..ind, function(_, settings)
                return func(settings, v.Children, v)
            end)
        end

        if mainapi.Legit then
            for _, v in mainapi.Legit.Modules do
                rawset(v, 'Create'..ind, function(_, settings)
                    return func(settings, v.Children, v)
                end)
            end
        end

        rawset(self, ind, func)
    end
})

task.spawn(function()
    repeat
        local hue = tick() * (0.2 * mainapi.RainbowSpeed.Value) % 1
        for _, v in mainapi.RainbowTable do
            v:SetValue(hue)
        end
        task.wait(1 / mainapi.RainbowUpdateSpeed.Value)
    until mainapi.Loaded == nil
end)

function mainapi:BlurCheck()
    if self.ThreadFix then
        setthreadidentity(8)
        runService:SetRobloxGuiFocused((clickgui.Visible or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and self.Blur.Enabled)
    end
end

addMaid(mainapi)

-- FIXED CreateGUI - No GUICategory, directly creates categories
function mainapi:CreateGUI()
    local categoryapi = {
        Type = 'MainWindow',
        Buttons = {},
        Options = {}
    }

    -- DIRECT WINDOW - No GUICategory wrapper
    local window = Instance.new('TextButton')
    window.Name = 'MainWindow'
    window.Size = UDim2.fromOffset(220, 400)
    window.Position = UDim2.fromOffset(100, 60)
    window.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
    window.AutoButtonColor = false
    window.Text = ''
    window.Parent = clickgui
    addBlur(window)
    addCorner(window)
    
    local function makeDraggable(gui, window)
        gui.InputBegan:Connect(function(inputObj)
            if window and not window.Visible then return end
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
            then
                local dragPosition = Vector2.new(
                    gui.AbsolutePosition.X - inputObj.Position.X,
                    gui.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
                ) / scale.Scale

                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        local position = input.Position
                        if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            dragPosition = (dragPosition // 3) * 3
                            position = (position // 3) * 3
                        end
                        gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
                    end
                end)

                local ended
                ended = inputObj.Changed:Connect(function()
                    if inputObj.UserInputState == Enum.UserInputState.End then
                        if changed then
                            changed:Disconnect()
                        end
                        if ended then
                            ended:Disconnect()
                        end
                    end
                end)
            end
        end)
    end
    makeDraggable(window)
    
    local logo = Instance.new('ImageLabel')
    logo.Name = 'VapeLogo'
    logo.Size = UDim2.fromOffset(62, 18)
    logo.Position = UDim2.fromOffset(11, 10)
    logo.BackgroundTransparency = 1
    logo.Image = 'rbxassetid://14657521312'
    logo.ImageColor3 = select(3, uipallet.Main:ToHSV()) > 0.5 and uipallet.Text or Color3.new(1, 1, 1)
    logo.Parent = window
    local logov4 = Instance.new('ImageLabel')
    logov4.Name = 'V4Logo'
    logov4.Size = UDim2.fromOffset(28, 16)
    logov4.Position = UDim2.new(1, 1, 0, 1)
    logov4.BackgroundTransparency = 1
    logov4.Image = 'rbxassetid://14368322199'
    logov4.Parent = logo
    local children = Instance.new('ScrollingFrame')
    children.Name = 'Children'
    children.Size = UDim2.new(1, 0, 1, -33)
    children.Position = UDim2.fromOffset(0, 37)
    children.BackgroundTransparency = 1
    children.BorderSizePixel = 0
    children.ScrollBarThickness = 2
    children.ScrollBarImageTransparency = 0.75
    children.CanvasSize = UDim2.new()
    children.Parent = window
    local windowlist = Instance.new('UIListLayout')
    windowlist.SortOrder = Enum.SortOrder.LayoutOrder
    windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    windowlist.Parent = children
    
    categoryapi.Object = window
    categoryapi.Children = children
    categoryapi.WindowList = windowlist

    function categoryapi:CreateButton(categorysettings)
        local optionapi = {
            Enabled = false,
            Index = getTableSize(categoryapi.Buttons)
        }

        local button = Instance.new('TextButton')
        button.Name = categorysettings.Name
        button.Size = UDim2.fromOffset(220, 40)
        button.BackgroundColor3 = uipallet.Main
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = (categorysettings.Icon and '                                 ' or '             ')..categorysettings.Name
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextColor3 = color.Dark(uipallet.Text, 0.16)
        button.TextSize = 14
        button.FontFace = uipallet.Font
        button.Parent = children
        local icon
        if categorysettings.Icon then
            icon = Instance.new('ImageLabel')
            icon.Name = 'Icon'
            icon.Size = categorysettings.Size
            icon.Position = UDim2.fromOffset(13, 13)
            icon.BackgroundTransparency = 1
            icon.Image = categorysettings.Icon
            icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
            icon.Parent = button
        end
        local arrow = Instance.new('ImageLabel')
        arrow.Name = 'Arrow'
        arrow.Size = UDim2.fromOffset(4, 8)
        arrow.Position = UDim2.new(1, -20, 0, 16)
        arrow.BackgroundTransparency = 1
        arrow.Image = 'rbxassetid://14368316544'
        arrow.ImageColor3 = color.Light(uipallet.Main, 0.37)
        arrow.Parent = button
        optionapi.Name = categorysettings.Name
        optionapi.Icon = icon
        optionapi.Object = button
        optionapi.Window = categorysettings.Window

        function optionapi:Toggle()
            self.Enabled = not self.Enabled
            tween:Tween(arrow, uipallet.Tween, {
                Position = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
            })
            button.TextColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or uipallet.Text
            if icon then
                icon.ImageColor3 = button.TextColor3
            end
            button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
            categorysettings.Window.Visible = self.Enabled
        end

        button.MouseEnter:Connect(function()
            if not optionapi.Enabled then
                button.TextColor3 = uipallet.Text
                button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
            end
        end)
        button.MouseLeave:Connect(function()
            if not optionapi.Enabled then
                button.TextColor3 = color.Dark(uipallet.Text, 0.16)
                button.BackgroundColor3 = uipallet.Main
            end
        end)
        button.MouseButton1Click:Connect(function()
            optionapi:Toggle()
        end)

        categoryapi.Buttons[categorysettings.Name] = optionapi

        return optionapi
    end

    function categoryapi:CreateDivider(text)
        local divider = Instance.new('Frame')
        divider.Name = 'Divider'
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        divider.BorderSizePixel = 0
        divider.Parent = children
        if text then
            local label = Instance.new('TextLabel')
            label.Name = 'DividerLabel'
            label.Size = UDim2.fromOffset(218, 27)
            label.BackgroundTransparency = 1
            label.Text = '          '..text:upper()
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = color.Dark(uipallet.Text, 0.43)
            label.TextSize = 9
            label.FontFace = uipallet.Font
            label.Parent = children
            divider.Position = UDim2.fromOffset(0, 26)
            divider.Parent = label
        end
    end

    function categoryapi:CreateSettingsPane(categorysettings)
        local optionapi = {}

        local button = Instance.new('TextButton')
        button.Name = categorysettings.Name
        button.Size = UDim2.fromOffset(220, 40)
        button.BackgroundColor3 = uipallet.Main
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = '          '..categorysettings.Name
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextColor3 = color.Dark(uipallet.Text, 0.16)
        button.TextSize = 14
        button.FontFace = uipallet.Font
        button.Parent = children
        local arrow = Instance.new('ImageLabel')
        arrow.Name = 'Arrow'
        arrow.Size = UDim2.fromOffset(4, 8)
        arrow.Position = UDim2.new(1, -20, 0, 16)
        arrow.BackgroundTransparency = 1
        arrow.Image = 'rbxassetid://14368316544'
        arrow.ImageColor3 = color.Light(uipallet.Main, 0.37)
        arrow.Parent = button
        
        local settingspane = Instance.new('TextButton')
        settingspane.Size = UDim2.fromScale(1, 1)
        settingspane.BackgroundColor3 = uipallet.Main
        settingspane.AutoButtonColor = false
        settingspane.Visible = false
        settingspane.Text = ''
        settingspane.Parent = window
        local title = Instance.new('TextLabel')
        title.Name = 'Title'
        title.Size = UDim2.new(1, -36, 0, 20)
        title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 11)
        title.BackgroundTransparency = 1
        title.Text = categorysettings.Name
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = uipallet.Text
        title.TextSize = 13
        title.FontFace = uipallet.Font
        title.Parent = settingspane
        local close = addCloseButton(settingspane)
        local back = Instance.new('ImageButton')
        back.Name = 'Back'
        back.Size = UDim2.fromOffset(16, 16)
        back.Position = UDim2.fromOffset(11, 13)
        back.BackgroundTransparency = 1
        back.Image = 'rbxassetid://14368303894'
        back.ImageColor3 = color.Light(uipallet.Main, 0.37)
        back.Parent = settingspane
        addCorner(settingspane)
        local settingschildren = Instance.new('Frame')
        settingschildren.Name = 'Children'
        settingschildren.Size = UDim2.new(1, 0, 1, -57)
        settingschildren.Position = UDim2.fromOffset(0, 41)
        settingschildren.BackgroundColor3 = uipallet.Main
        settingschildren.BorderSizePixel = 0
        settingschildren.Parent = settingspane
        local settingswindowlist = Instance.new('UIListLayout')
        settingswindowlist.SortOrder = Enum.SortOrder.LayoutOrder
        settingswindowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        settingswindowlist.Parent = settingschildren

        for i, v in components do
            optionapi['Create'..i] = function(_, settings)
                return v(settings, settingschildren, categoryapi)
            end
        end

        back.MouseEnter:Connect(function()
            back.ImageColor3 = uipallet.Text
        end)
        back.MouseLeave:Connect(function()
            back.ImageColor3 = color.Light(uipallet.Main, 0.37)
        end)
        back.MouseButton1Click:Connect(function()
            settingspane.Visible = false
        end)
        button.MouseEnter:Connect(function()
            button.TextColor3 = uipallet.Text
            button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        end)
        button.MouseLeave:Connect(function()
            button.TextColor3 = color.Dark(uipallet.Text, 0.16)
            button.BackgroundColor3 = uipallet.Main
        end)
        button.MouseButton1Click:Connect(function()
            settingspane.Visible = true
        end)
        close.MouseButton1Click:Connect(function()
            settingspane.Visible = false
        end)
        
        settingswindowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            if mainapi.ThreadFix then
                setthreadidentity(8)
            end
            settingspane.Size = UDim2.fromOffset(220, 45 + settingswindowlist.AbsoluteContentSize.Y / scale.Scale)
        end)

        return optionapi
    end

    function categoryapi:CreateBind()
        -- Similar to your original but simplified
        local optionapi = {Bind = {'RightShift'}}

        local button = Instance.new('TextButton')
        button.Size = UDim2.fromOffset(220, 40)
        button.BackgroundColor3 = uipallet.Main
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = '          Rebind GUI'
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextColor3 = color.Dark(uipallet.Text, 0.16)
        button.TextSize = 14
        button.FontFace = uipallet.Font
        button.Parent = children
        addTooltip(button, 'Change the bind of the GUI')
        
        local bind = Instance.new('TextButton')
        bind.Name = 'Bind'
        bind.Size = UDim2.fromOffset(20, 21)
        bind.Position = UDim2.new(1, -10, 0, 9)
        bind.AnchorPoint = Vector2.new(1, 0)
        bind.BackgroundColor3 = Color3.new(1, 1, 1)
        bind.BackgroundTransparency = 0.92
        bind.BorderSizePixel = 0
        bind.AutoButtonColor = false
        bind.Text = ''
        bind.Parent = button
        addTooltip(bind, 'Click to bind')
        addCorner(bind, UDim.new(0, 4))
        
        local icon = Instance.new('ImageLabel')
        icon.Name = 'Icon'
        icon.Size = UDim2.fromOffset(12, 12)
        icon.Position = UDim2.new(0.5, -6, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = 'rbxassetid://14368304734'
        icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
        icon.Parent = bind
        
        local label = Instance.new('TextLabel')
        label.Name = 'Text'
        label.Size = UDim2.fromScale(1, 1)
        label.Position = UDim2.fromOffset(0, 1)
        label.BackgroundTransparency = 1
        label.Visible = false
        label.Text = ''
        label.TextColor3 = color.Dark(uipallet.Text, 0.43)
        label.TextSize = 12
        label.FontFace = uipallet.Font
        label.Parent = bind

        function optionapi:SetBind(tab)
            mainapi.Keybind = #tab <= 0 and mainapi.Keybind or table.clone(tab)
            self.Bind = mainapi.Keybind

            bind.Visible = true
            label.Visible = true
            icon.Visible = false
            label.Text = table.concat(mainapi.Keybind, ' + '):upper()
            bind.Size = UDim2.fromOffset(math.max(getfontsize(label.Text, label.TextSize, label.Font).X + 10, 20), 21)
        end

        bind.MouseEnter:Connect(function()
            label.Visible = false
            icon.Visible = not label.Visible
            icon.Image = 'rbxassetid://14368315443'
            icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
        end)
        bind.MouseLeave:Connect(function()
            label.Visible = true
            icon.Visible = not label.Visible
            icon.Image = 'rbxassetid://14368304734'
            icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
        end)
        bind.MouseButton1Click:Connect(function()
            mainapi.Binding = optionapi
        end)

        if not categoryapi.Options then
            categoryapi.Options = {}
        end
        categoryapi.Options.Bind = optionapi

        return optionapi
    end

    function categoryapi:CreateGUISlider(optionsettings)
        -- Your original GUISlider code here
        local optionapi = {
            Type = 'GUISlider',
            Notch = 4,
            Hue = 0.46,
            Sat = 0.96,
            Value = 0.52,
            Rainbow = false,
            CustomColor = false
        }
        
        local slidercolors = {
            Color3.fromRGB(250, 50, 56),
            Color3.fromRGB(242, 99, 33),
            Color3.fromRGB(252, 179, 22),
            Color3.fromRGB(5, 133, 104),
            Color3.fromRGB(47, 122, 229),
            Color3.fromRGB(126, 84, 217),
            Color3.fromRGB(232, 96, 152)
        }
        local slidercolorpos = {
            4,
            33,
            62,
            90,
            119,
            148,
            177
        }

        local slider = Instance.new('TextButton')
        slider.Name = optionsettings.Name..'Slider'
        slider.Size = UDim2.fromOffset(220, 50)
        slider.BackgroundTransparency = 1
        slider.AutoButtonColor = false
        slider.Text = ''
        slider.Parent = children
        local title = Instance.new('TextLabel')
        title.Name = 'Title'
        title.Size = UDim2.fromOffset(60, 30)
        title.Position = UDim2.fromOffset(10, 2)
        title.BackgroundTransparency = 1
        title.Text = optionsettings.Name
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = color.Dark(uipallet.Text, 0.16)
        title.TextSize = 11
        title.FontFace = uipallet.Font
        title.Parent = slider
        local holder = Instance.new('Frame')
        holder.Name = 'Slider'
        holder.Size = UDim2.fromOffset(200, 2)
        holder.Position = UDim2.fromOffset(10, 37)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.Parent = slider
        local colornum = 0
        for i, color in slidercolors do
            local colorframe = Instance.new('Frame')
            colorframe.Size = UDim2.fromOffset(27 + (((i + 1) % 2) == 0 and 1 or 0), 2)
            colorframe.Position = UDim2.fromOffset(colornum, 0)
            colorframe.BackgroundColor3 = color
            colorframe.BorderSizePixel = 0
            colorframe.Parent = holder
            colornum += (colorframe.Size.X.Offset + 1)
        end
        local preview = Instance.new('ImageButton')
        preview.Name = 'Preview'
        preview.Size = UDim2.fromOffset(12, 12)
        preview.Position = UDim2.new(1, -22, 0, 10)
        preview.BackgroundTransparency = 1
        preview.Image = 'rbxassetid://14368311578'
        preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, 1, 1)
        preview.Parent = slider
        local knob = Instance.new('ImageLabel')
        knob.Name = 'Knob'
        knob.Size = UDim2.fromOffset(26, 12)
        knob.Position = UDim2.fromOffset(slidercolorpos[4] - 3, -5)
        knob.BackgroundTransparency = 1
        knob.Image = 'rbxassetid://14368320020'
        knob.ImageColor3 = slidercolors[4]
        knob.Parent = holder
        
        optionsettings.Function = optionsettings.Function or function() end

        function optionapi:SetValue(h, s, v, n)
            if n then
                if self.Rainbow then
                    self:Toggle()
                end
                self.CustomColor = false
                h, s, v = slidercolors[n]:ToHSV()
            else
                self.CustomColor = true
            end

            self.Hue = h or self.Hue
            self.Sat = s or self.Sat
            self.Value = v or self.Value
            self.Notch = n
            preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)

            if self.Rainbow or self.CustomColor then
                knob.Image = 'rbxassetid://14368321228'
                knob.ImageColor3 = Color3.new(1, 1, 1)
                tween:Tween(knob, uipallet.Tween, {
                    Position = UDim2.fromOffset(slidercolorpos[4] - 3, -5)
                })
            else
                knob.Image = 'rbxassetid://14368320020'
                knob.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
                tween:Tween(knob, uipallet.Tween, {
                    Position = UDim2.fromOffset(slidercolorpos[n or 4] - 3, -5)
                })
            end
            optionsettings.Function(self.Hue, self.Sat, self.Value)
        end

        function optionapi:Toggle()
            self.Rainbow = not self.Rainbow
            if self.Rainbow then
                table.insert(mainapi.RainbowTable, self)
            else
                local ind = table.find(mainapi.RainbowTable, self)
                if ind then
                    table.remove(mainapi.RainbowTable, ind)
                end
                self:SetValue(nil, nil, nil, 4)
            end
        end

        slider.InputBegan:Connect(function(inputObj)
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
            then
                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        optionapi:SetValue(nil, nil, nil, math.clamp(math.round((input.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7))
                    end
                end)

                local ended
                ended = inputObj.Changed:Connect(function()
                    if inputObj.UserInputState == Enum.UserInputState.End then
                        if changed then
                            changed:Disconnect()
                        end
                        if ended then
                            ended:Disconnect()
                        end
                    end
                end)
                optionapi:SetValue(nil, nil, nil, math.clamp(math.round((inputObj.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7))
            end
        end)

        optionapi.Object = slider
        categoryapi.Options[optionsettings.Name] = optionapi

        return optionapi
    end

    windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
        window.Size = UDim2.fromOffset(220, math.min(42 + windowlist.AbsoluteContentSize.Y / scale.Scale, 600))
        for _, v in categoryapi.Buttons do
            if v.Icon then
                v.Object.Text = string.rep(' ', 36 * scale.Scale)..v.Name
            end
        end
    end)

    mainapi.Categories.Main = categoryapi

    return categoryapi
end

function mainapi:CreateCategory(categorysettings)
    local categoryapi = {
        Type = 'Category',
        Expanded = true -- AUTO-EXPANDED
    }

    local window = Instance.new('TextButton')
    window.Name = categorysettings.Name..'Category'
    window.Size = UDim2.fromOffset(220, 41)
    window.Position = UDim2.fromOffset(236, 60)
    window.BackgroundColor3 = uipallet.Main
    window.AutoButtonColor = false
    window.Visible = false
    window.Text = ''
    window.Parent = clickgui
    addBlur(window)
    addCorner(window)
    
    local function makeDraggable(gui, window)
        gui.InputBegan:Connect(function(inputObj)
            if window and not window.Visible then return end
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
            then
                local dragPosition = Vector2.new(
                    gui.AbsolutePosition.X - inputObj.Position.X,
                    gui.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
                ) / scale.Scale

                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        local position = input.Position
                        if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            dragPosition = (dragPosition // 3) * 3
                            position = (position // 3) * 3
                        end
                        gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
                    end
                end)

                local ended
                ended = inputObj.Changed:Connect(function()
                    if inputObj.UserInputState == Enum.UserInputState.End then
                        if changed then
                            changed:Disconnect()
                        end
                        if ended then
                            ended:Disconnect()
                        end
                    end
                end)
            end
        end)
    end
    makeDraggable(window)
    
    local icon = Instance.new('ImageLabel')
    icon.Name = 'Icon'
    icon.Size = categorysettings.Size
    icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 20 and 14 or 13))
    icon.BackgroundTransparency = 1
    icon.Image = categorysettings.Icon
    icon.ImageColor3 = uipallet.Text
    icon.Parent = window
    local title = Instance.new('TextLabel')
    title.Name = 'Title'
    title.Size = UDim2.new(1, -(categorysettings.Size.X.Offset > 18 and 40 or 33), 0, 41)
    title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
    title.BackgroundTransparency = 1
    title.Text = categorysettings.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = uipallet.Text
    title.TextSize = 13
    title.FontFace = uipallet.Font
    title.Parent = window
    local arrowbutton = Instance.new('TextButton')
    arrowbutton.Name = 'Arrow'
    arrowbutton.Size = UDim2.fromOffset(40, 40)
    arrowbutton.Position = UDim2.new(1, -40, 0, 0)
    arrowbutton.BackgroundTransparency = 1
    arrowbutton.Text = ''
    arrowbutton.Parent = window
    local arrow = Instance.new('ImageLabel')
    arrow.Name = 'Arrow'
    arrow.Size = UDim2.fromOffset(9, 4)
    arrow.Position = UDim2.fromOffset(20, 18)
    arrow.BackgroundTransparency = 1
    arrow.Image = 'rbxassetid://14368317595'
    arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
    arrow.Rotation = 0 -- OPEN by default
    arrow.Parent = arrowbutton
    local children = Instance.new('ScrollingFrame')
    children.Name = 'Children'
    children.Size = UDim2.new(1, 0, 1, -41)
    children.Position = UDim2.fromOffset(0, 37)
    children.BackgroundTransparency = 1
    children.BorderSizePixel = 0
    children.Visible = true -- AUTO-VISIBLE
    children.ScrollBarThickness = 2
    children.ScrollBarImageTransparency = 0.75
    children.CanvasSize = UDim2.new()
    children.Parent = window
    local divider = Instance.new('Frame')
    divider.Name = 'Divider'
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.fromOffset(0, 37)
    divider.BackgroundColor3 = Color3.new(1, 1, 1)
    divider.BackgroundTransparency = 0.928
    divider.BorderSizePixel = 0
    divider.Visible = false
    divider.Parent = window
    local windowlist = Instance.new('UIListLayout')
    windowlist.SortOrder = Enum.SortOrder.LayoutOrder
    windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    windowlist.Parent = children

    function categoryapi:CreateModule(modulesettings)
        mainapi:Remove(modulesettings.Name)
        local moduleapi = {
            Enabled = false,
            Options = {},
            Bind = {},
            Index = getTableSize(mainapi.Modules),
            ExtraText = modulesettings.ExtraText,
            Name = modulesettings.Name,
            Category = categorysettings.Name
        }

        local hovered = false
        local modulebutton = Instance.new('TextButton')
        modulebutton.Name = modulesettings.Name
        modulebutton.Size = UDim2.fromOffset(220, 40)
        modulebutton.BackgroundColor3 = uipallet.Main
        modulebutton.BorderSizePixel = 0
        modulebutton.AutoButtonColor = false
        modulebutton.Text = '            '..modulesettings.Name
        modulebutton.TextXAlignment = Enum.TextXAlignment.Left
        modulebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
        modulebutton.TextSize = 14
        modulebutton.FontFace = uipallet.Font
        modulebutton.Parent = children
        local gradient = Instance.new('UIGradient')
        gradient.Rotation = 90
        gradient.Enabled = false
        gradient.Parent = modulebutton
        local modulechildren = Instance.new('Frame')
        local bind = Instance.new('TextButton')
        addTooltip(modulebutton, modulesettings.Tooltip)
        addTooltip(bind, 'Click to bind')
        bind.Name = 'Bind'
        bind.Size = UDim2.fromOffset(20, 21)
        bind.Position = UDim2.new(1, -36, 0, 9)
        bind.AnchorPoint = Vector2.new(1, 0)
        bind.BackgroundColor3 = Color3.new(1, 1, 1)
        bind.BackgroundTransparency = 0.92
        bind.BorderSizePixel = 0
        bind.AutoButtonColor = false
        bind.Visible = false
        bind.Text = ''
        addCorner(bind, UDim.new(0, 4))
        local bindicon = Instance.new('ImageLabel')
        bindicon.Name = 'Icon'
        bindicon.Size = UDim2.fromOffset(12, 12)
        bindicon.Position = UDim2.new(0.5, -6, 0, 5)
        bindicon.BackgroundTransparency = 1
        bindicon.Image = 'rbxassetid://14368304734'
        bindicon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
        bindicon.Parent = bind
        local bindtext = Instance.new('TextLabel')
        bindtext.Size = UDim2.fromScale(1, 1)
        bindtext.Position = UDim2.fromOffset(0, 1)
        bindtext.BackgroundTransparency = 1
        bindtext.Visible = false
        bindtext.Text = ''
        bindtext.TextColor3 = color.Dark(uipallet.Text, 0.43)
        bindtext.TextSize = 12
        bindtext.FontFace = uipallet.Font
        bindtext.Parent = bind
        local bindcover = Instance.new('ImageLabel')
        bindcover.Name = 'Cover'
        bindcover.Size = UDim2.fromOffset(154, 40)
        bindcover.BackgroundTransparency = 1
        bindcover.Visible = false
        bindcover.Image = 'rbxassetid://14368305655'
        bindcover.ScaleType = Enum.ScaleType.Slice
        bindcover.SliceCenter = Rect.new(0, 0, 141, 40)
        bindcover.Parent = modulebutton
        local bindcovertext = Instance.new('TextLabel')
        bindcovertext.Name = 'Text'
        bindcovertext.Size = UDim2.new(1, -10, 1, -3)
        bindcovertext.BackgroundTransparency = 1
        bindcovertext.Text = 'PRESS A KEY TO BIND'
        bindcovertext.TextColor3 = uipallet.Text
        bindcovertext.TextSize = 11
        bindcovertext.FontFace = uipallet.Font
        bindcovertext.Parent = bindcover
        bind.Parent = modulebutton
        local dotsbutton = Instance.new('TextButton')
        dotsbutton.Name = 'Dots'
        dotsbutton.Size = UDim2.fromOffset(25, 40)
        dotsbutton.Position = UDim2.new(1, -25, 0, 0)
        dotsbutton.BackgroundTransparency = 1
        dotsbutton.Text = ''
        dotsbutton.Parent = modulebutton
        local dots = Instance.new('ImageLabel')
        dots.Name = 'Dots'
        dots.Size = UDim2.fromOffset(3, 16)
        dots.Position = UDim2.fromOffset(4, 12)
        dots.BackgroundTransparency = 1
        dots.Image = 'rbxassetid://14368314459'
        dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
        dots.Parent = dotsbutton
        modulechildren.Name = modulesettings.Name..'Children'
        modulechildren.Size = UDim2.new(1, 0, 0, 0)
        modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
        modulechildren.BorderSizePixel = 0
        modulechildren.Visible = false
        modulechildren.Parent = children
        moduleapi.Children = modulechildren
        local windowlist = Instance.new('UIListLayout')
        windowlist.SortOrder = Enum.SortOrder.LayoutOrder
        windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        windowlist.Parent = modulechildren
        local divider = Instance.new('Frame')
        divider.Name = 'Divider'
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.Position = UDim2.new(0, 0, 1, -1)
        divider.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19)
        divider.BackgroundTransparency = 0.52
        divider.BorderSizePixel = 0
        divider.Visible = false
        divider.Parent = modulebutton
        modulesettings.Function = modulesettings.Function or function() end
        addMaid(moduleapi)

        function moduleapi:SetBind(tab, mouse)
            self.Bind = table.clone(tab)
            if mouse then
                bindcovertext.Text = #tab <= 0 and 'BIND REMOVED' or 'BOUND TO'
                bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
                task.delay(1, function()
                    bindcover.Visible = false
                end)
            end

            if #tab <= 0 then
                bindtext.Visible = false
                bindicon.Visible = true
                bind.Size = UDim2.fromOffset(20, 21)
            else
                bind.Visible = true
                bindtext.Visible = true
                bindicon.Visible = false
                bindtext.Text = table.concat(tab, ' + '):upper()
                bind.Size = UDim2.fromOffset(math.max(getfontsize(bindtext.Text, bindtext.TextSize, bindtext.Font).X + 10, 20), 21)
            end
        end

        function moduleapi:Toggle(multiple)
            if mainapi.ThreadFix then
                setthreadidentity(8)
            end
            self.Enabled = not self.Enabled
            divider.Visible = self.Enabled
            gradient.Enabled = self.Enabled
            modulebutton.TextColor3 = (hovered or modulechildren.Visible) and uipallet.Text or color.Dark(uipallet.Text, 0.16)
            modulebutton.BackgroundColor3 = (hovered or modulechildren.Visible) and color.Light(uipallet.Main, 0.02) or uipallet.Main
            dots.ImageColor3 = self.Enabled and Color3.fromRGB(50, 50, 50) or color.Light(uipallet.Main, 0.37)
            bindicon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
            bindtext.TextColor3 = color.Dark(uipallet.Text, 0.43)
            if not self.Enabled then
                for _, v in self.Connections do
                    v:Disconnect()
                end
                table.clear(self.Connections)
            end
            if not multiple then
                mainapi:UpdateTextGUI()
            end
            task.spawn(modulesettings.Function, self.Enabled)
        end

        for i, v in components do
            moduleapi['Create'..i] = function(_, optionsettings)
                return v(optionsettings, modulechildren, moduleapi)
            end
        end

        bind.MouseEnter:Connect(function()
            bindtext.Visible = false
            bindicon.Visible = not bindtext.Visible
            bindicon.Image = 'rbxassetid://14368315443'
            if not moduleapi.Enabled then bindicon.ImageColor3 = color.Dark(uipallet.Text, 0.16) end
        end)
        bind.MouseLeave:Connect(function()
            bindtext.Visible = #moduleapi.Bind > 0
            bindicon.Visible = not bindtext.Visible
            bindicon.Image = 'rbxassetid://14368304734'
            if not moduleapi.Enabled then
                bindicon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
            end
        end)
        bind.MouseButton1Click:Connect(function()
            bindcovertext.Text = 'PRESS A KEY TO BIND'
            bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
            bindcover.Visible = true
            mainapi.Binding = moduleapi
        end)
        dotsbutton.MouseEnter:Connect(function()
            if not moduleapi.Enabled then
                dots.ImageColor3 = uipallet.Text
            end
        end)
        dotsbutton.MouseLeave:Connect(function()
            if not moduleapi.Enabled then
                dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
            end
        end)
        dotsbutton.MouseButton1Click:Connect(function()
            modulechildren.Visible = not modulechildren.Visible
        end)
        modulebutton.MouseEnter:Connect(function()
            hovered = true
            if not moduleapi.Enabled and not modulechildren.Visible then
                modulebutton.TextColor3 = uipallet.Text
                modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
            end
            bind.Visible = #moduleapi.Bind > 0 or hovered or modulechildren.Visible
        end)
        modulebutton.MouseLeave:Connect(function()
            hovered = false
            if not moduleapi.Enabled and not modulechildren.Visible then
                modulebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
                modulebutton.BackgroundColor3 = uipallet.Main
            end
            bind.Visible = #moduleapi.Bind > 0 or hovered or modulechildren.Visible
        end)
        modulebutton.MouseButton1Click:Connect(function()
            moduleapi:Toggle()
        end)
        modulebutton.MouseButton2Click:Connect(function()
            modulechildren.Visible = not modulechildren.Visible
        end)

        windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            if mainapi.ThreadFix then
                setthreadidentity(8)
            end
            modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
        end)

        moduleapi.Object = modulebutton
        mainapi.Modules[modulesettings.Name] = moduleapi

        local sorting = {}
        for _, v in mainapi.Modules do
            sorting[v.Category] = sorting[v.Category] or {}
            table.insert(sorting[v.Category], v.Name)
        end

        for _, sort in sorting do
            table.sort(sort)
            for i, v in sort do
                mainapi.Modules[v].Index = i
                mainapi.Modules[v].Object.LayoutOrder = i
                mainapi.Modules[v].Children.LayoutOrder = i
            end
        end

        return moduleapi
    end

    function categoryapi:Expand()
        self.Expanded = not self.Expanded
        children.Visible = self.Expanded
        arrow.Rotation = self.Expanded and 0 or 180
        window.Size = UDim2.fromOffset(220, self.Expanded and math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601) or 41)
        divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
    end

    arrowbutton.MouseButton1Click:Connect(function()
        categoryapi:Expand()
    end)
    arrowbutton.MouseEnter:Connect(function()
        arrow.ImageColor3 = Color3.fromRGB(220, 220, 220)
    end)
    arrowbutton.MouseLeave:Connect(function()
        arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
    end)
    children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
    end)
    windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
        if categoryapi.Expanded then
            window.Size = UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
        end
    end)

    categoryapi.Button = mainapi.Categories.Main:CreateButton({
        Name = categorysettings.Name,
        Icon = categorysettings.Icon,
        Size = categorysettings.Size,
        Window = window
    })

    categoryapi.Object = window
    mainapi.Categories[categorysettings.Name] = categoryapi

    return categoryapi
end

-- Add Settings Category function
function mainapi:AddSettingsCategory()
    local settingsCategory = self:CreateCategory({
        Name = "Settings",
        Icon = "rbxassetid://14368303894", -- Settings icon
        Size = UDim2.fromOffset(14, 14)
    })
    
    local settingsModule = settingsCategory:CreateModule({
        Name = "UI Settings",
        Function = function() end
    })
    
    -- GUI Settings
    settingsModule:CreateDivider("GUI")
    
    local blur = settingsModule:CreateToggle({
        Name = "Blur background",
        Function = function()
            self:BlurCheck()
        end,
        Default = true,
        Tooltip = "Blur the background of the GUI"
    })
    
    local autoScale = settingsModule:CreateToggle({
        Name = "Auto rescale",
        Default = true,
        Function = function(callback)
            if callback then
                scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
            end
        end,
        Tooltip = "Automatically rescales the gui using the screens resolution"
    })
    
    local manualScale = settingsModule:CreateSlider({
        Name = "Scale",
        Min = 0.1,
        Max = 2,
        Decimal = 10,
        Function = function(val, final)
            if final and not autoScale.Enabled then
                scale.Scale = val
            end
        end,
        Default = 1,
        Darker = true,
        Visible = false
    })
    
    autoScale:GetPropertyChangedSignal('Enabled'):Connect(function()
        manualScale.Object.Visible = not autoScale.Enabled
        if autoScale.Enabled then
            scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
        else
            scale.Scale = manualScale.Value
        end
    end)
    
    settingsModule:CreateDivider("Colors")
    
    local rainbowMode = settingsModule:CreateDropdown({
        Name = "Rainbow Mode",
        List = {'Normal', 'Gradient', 'Retro'},
        Tooltip = "Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color"
    })
    
    local rainbowSpeed = settingsModule:CreateSlider({
        Name = "Rainbow speed",
        Min = 0.1,
        Max = 10,
        Decimal = 10,
        Default = 1,
        Tooltip = "Adjusts the speed of rainbow values"
    })
    
    local rainbowUpdate = settingsModule:CreateSlider({
        Name = "Rainbow update rate",
        Min = 1,
        Max = 144,
        Default = 60,
        Tooltip = "Adjusts the update rate of rainbow values",
        Suffix = 'hz'
    })
    
    local guiTheme = settingsModule:CreateGUISlider({
        Name = "GUI Theme",
        Function = function(h, s, v)
            self:UpdateGUI(h, s, v, true)
        end
    })
    
    settingsModule:CreateDivider("Keybinds")
    
    local rebind = settingsModule:CreateBind()
    
    return settingsCategory
end

function mainapi:Remove(obj)
    local tab = (self.Modules[obj] and self.Modules or self.Categories)
    if tab and tab[obj] then
        local newobj = tab[obj]
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end

        for _, v in {'Object', 'Children', 'Toggle', 'Button'} do
            local childobj = typeof(newobj[v]) == 'table' and newobj[v].Object or newobj[v]
            if typeof(childobj) == 'Instance' then
                childobj:Destroy()
                childobj:ClearAllChildren()
            end
        end

        loopClean(newobj)
        tab[obj] = nil
    end
end

function mainapi:CreateNotification(title, text, duration, type)
    if not self.Notifications.Enabled then return end
    task.delay(0, function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        local i = #notifications:GetChildren() + 1
        local notification = Instance.new('ImageLabel')
        notification.Name = 'Notification'
        notification.Size = UDim2.fromOffset(math.max(getfontsize(removeTags(text), 14, uipallet.Font).X + 80, 266), 75)
        notification.Position = UDim2.new(1, 0, 1, -(29 + (78 * i)))
        notification.ZIndex = 5
        notification.BackgroundTransparency = 1
        notification.Image = 'rbxassetid://16738721069'
        notification.ScaleType = Enum.ScaleType.Slice
        notification.SliceCenter = Rect.new(7, 7, 9, 9)
        notification.Parent = notifications
        addBlur(notification, true)
        local iconshadow = Instance.new('ImageLabel')
        iconshadow.Name = 'Icon'
        iconshadow.Size = UDim2.fromOffset(60, 60)
        iconshadow.Position = UDim2.fromOffset(-5, -8)
        iconshadow.ZIndex = 5
        iconshadow.BackgroundTransparency = 1
        iconshadow.Image = 'rbxassetid://'..(type == 'alert' and '14368301329' or type == 'warning' and '14368361552' or '14368324807')
        iconshadow.ImageColor3 = Color3.new()
        iconshadow.ImageTransparency = 0.5
        iconshadow.Parent = notification
        local icon = iconshadow:Clone()
        icon.Position = UDim2.fromOffset(-1, -1)
        icon.ImageColor3 = Color3.new(1, 1, 1)
        icon.ImageTransparency = 0
        icon.Parent = iconshadow
        local titlelabel = Instance.new('TextLabel')
        titlelabel.Name = 'Title'
        titlelabel.Size = UDim2.new(1, -56, 0, 20)
        titlelabel.Position = UDim2.fromOffset(46, 16)
        titlelabel.ZIndex = 5
        titlelabel.BackgroundTransparency = 1
        titlelabel.Text = "<stroke color='#FFFFFF' joins='round' thickness='0.3' transparency='0.5'>"..title..'</stroke>'
        titlelabel.TextXAlignment = Enum.TextXAlignment.Left
        titlelabel.TextYAlignment = Enum.TextYAlignment.Top
        titlelabel.TextColor3 = Color3.fromRGB(209, 209, 209)
        titlelabel.TextSize = 14
        titlelabel.RichText = true
        titlelabel.FontFace = uipallet.FontSemiBold
        titlelabel.Parent = notification
        local textshadow = titlelabel:Clone()
        textshadow.Name = 'Text'
        textshadow.Position = UDim2.fromOffset(47, 44)
        textshadow.Text = removeTags(text)
        textshadow.TextColor3 = Color3.new()
        textshadow.TextTransparency = 0.5
        textshadow.RichText = false
        textshadow.FontFace = uipallet.Font
        textshadow.Parent = notification
        local textlabel = textshadow:Clone()
        textlabel.Position = UDim2.fromOffset(-1, -1)
        textlabel.Text = text
        textlabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        textlabel.TextTransparency = 0
        textlabel.RichText = true
        textlabel.Parent = textshadow
        local progress = Instance.new('Frame')
        progress.Name = 'Progress'
        progress.Size = UDim2.new(1, -13, 0, 2)
        progress.Position = UDim2.new(0, 3, 1, -4)
        progress.ZIndex = 5
        progress.BackgroundColor3 =
            type == 'alert' and Color3.fromRGB(250, 50, 56)
            or type == 'warning' and Color3.fromRGB(236, 129, 43)
            or Color3.fromRGB(220, 220, 220)
        progress.BorderSizePixel = 0
        progress.Parent = notification
        if tween.Tween then
            tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                AnchorPoint = Vector2.new(1, 0)
            }, tween.tweenstwo)
            tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                Size = UDim2.fromOffset(0, 2)
            })
        end
        task.delay(duration, function()
            if tween.Tween then
                tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
                    AnchorPoint = Vector2.new(0, 0)
                }, tween.tweenstwo)
            end
            task.wait(0.2)
            notification:ClearAllChildren()
            notification:Destroy()
        end)
    end)
end

function mainapi:CreateLegit()
    local legitapi = {Modules = {}}

    local window = Instance.new('Frame')
    window.Name = 'LegitGUI'
    window.Size = UDim2.fromOffset(700, 389)
    window.Position = UDim2.new(0.5, -350, 0.5, -194)
    window.BackgroundColor3 = uipallet.Main
    window.Visible = false
    window.Parent = scaledgui
    addBlur(window)
    addCorner(window)
    
    local function makeDraggable(gui, window)
        gui.InputBegan:Connect(function(inputObj)
            if window and not window.Visible then return end
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
            then
                local dragPosition = Vector2.new(
                    gui.AbsolutePosition.X - inputObj.Position.X,
                    gui.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
                ) / scale.Scale

                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        local position = input.Position
                        if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            dragPosition = (dragPosition // 3) * 3
                            position = (position // 3) * 3
                        end
                        gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
                    end
                end)

                local ended
                ended = inputObj.Changed:Connect(function()
                    if inputObj.UserInputState == Enum.UserInputState.End then
                        if changed then
                            changed:Disconnect()
                        end
                        if ended then
                            ended:Disconnect()
                        end
                    end
                end)
            end
        end)
    end
    makeDraggable(window)
    
    local modal = Instance.new('TextButton')
    modal.BackgroundTransparency = 1
    modal.Text = ''
    modal.Modal = true
    modal.Parent = window
    local icon = Instance.new('ImageLabel')
    icon.Name = 'Icon'
    icon.Size = UDim2.fromOffset(16, 16)
    icon.Position = UDim2.fromOffset(18, 13)
    icon.BackgroundTransparency = 1
    icon.Image = 'rbxassetid://14426740825'
    icon.ImageColor3 = uipallet.Text
    icon.Parent = window
    local close = addCloseButton(window)
    local children = Instance.new('ScrollingFrame')
    children.Name = 'Children'
    children.Size = UDim2.fromOffset(684, 340)
    children.Position = UDim2.fromOffset(14, 41)
    children.BackgroundTransparency = 1
    children.BorderSizePixel = 0
    children.ScrollBarThickness = 2
    children.ScrollBarImageTransparency = 0.75
    children.CanvasSize = UDim2.new()
    children.Parent = window
    local windowlist = Instance.new('UIGridLayout')
    windowlist.SortOrder = Enum.SortOrder.LayoutOrder
    windowlist.FillDirectionMaxCells = 4
    windowlist.CellSize = UDim2.fromOffset(163, 114)
    windowlist.CellPadding = UDim2.fromOffset(6, 5)
    windowlist.Parent = children
    legitapi.Window = window
    table.insert(mainapi.Windows, window)

    function legitapi:CreateModule(modulesettings)
        mainapi:Remove(modulesettings.Name)
        local moduleapi = {
            Enabled = false,
            Options = {},
            Name = modulesettings.Name,
            Legit = true
        }

        local module = Instance.new('TextButton')
        module.Name = modulesettings.Name
        module.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        module.Text = ''
        module.AutoButtonColor = false
        module.Parent = children
        addTooltip(module, modulesettings.Tooltip)
        addCorner(module)
        local title = Instance.new('TextLabel')
        title.Name = 'Title'
        title.Size = UDim2.new(1, -16, 0, 20)
        title.Position = UDim2.fromOffset(16, 81)
        title.BackgroundTransparency = 1
        title.Text = modulesettings.Name
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = color.Dark(uipallet.Text, 0.31)
        title.TextSize = 13
        title.FontFace = uipallet.Font
        title.Parent = module
        local knob = Instance.new('Frame')
        knob.Name = 'Knob'
        knob.Size = UDim2.fromOffset(22, 12)
        knob.Position = UDim2.new(1, -57, 0, 14)
        knob.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
        knob.Parent = module
        addCorner(knob, UDim.new(1, 0))
        local knobmain = knob:Clone()
        knobmain.Size = UDim2.fromOffset(8, 8)
        knobmain.Position = UDim2.fromOffset(2, 2)
        knobmain.BackgroundColor3 = uipallet.Main
        knobmain.Parent = knob
        local dotsbutton = Instance.new('TextButton')
        dotsbutton.Name = 'Dots'
        dotsbutton.Size = UDim2.fromOffset(14, 24)
        dotsbutton.Position = UDim2.new(1, -27, 0, 8)
        dotsbutton.BackgroundTransparency = 1
        dotsbutton.Text = ''
        dotsbutton.Parent = module
        local dots = Instance.new('ImageLabel')
        dots.Name = 'Dots'
        dots.Size = UDim2.fromOffset(2, 12)
        dots.Position = UDim2.fromOffset(6, 6)
        dots.BackgroundTransparency = 1
        dots.Image = 'rbxassetid://14368314459'
        dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
        dots.Parent = dotsbutton
        local shadow = Instance.new('TextButton')
        shadow.Name = 'Shadow'
        shadow.Size = UDim2.new(1, 0, 1, -5)
        shadow.BackgroundColor3 = Color3.new()
        shadow.BackgroundTransparency = 1
        shadow.AutoButtonColor = false
        shadow.ClipsDescendants = true
        shadow.Visible = false
        shadow.Text = ''
        shadow.Parent = window
        addCorner(shadow)
        local settingspane = Instance.new('TextButton')
        settingspane.Size = UDim2.new(0, 220, 1, 0)
        settingspane.Position = UDim2.fromScale(1, 0)
        settingspane.BackgroundColor3 = uipallet.Main
        settingspane.AutoButtonColor = false
        settingspane.Text = ''
        settingspane.Parent = shadow
        local settingstitle = Instance.new('TextLabel')
        settingstitle.Name = 'Title'
        settingstitle.Size = UDim2.new(1, -36, 0, 20)
        settingstitle.Position = UDim2.fromOffset(36, 12)
        settingstitle.BackgroundTransparency = 1
        settingstitle.Text = modulesettings.Name
        settingstitle.TextXAlignment = Enum.TextXAlignment.Left
        settingstitle.TextColor3 = color.Dark(uipallet.Text, 0.16)
        settingstitle.TextSize = 13
        settingstitle.FontFace = uipallet.Font
        settingstitle.Parent = settingspane
        local back = Instance.new('ImageButton')
        back.Name = 'Back'
        back.Size = UDim2.fromOffset(16, 16)
        back.Position = UDim2.fromOffset(11, 13)
        back.BackgroundTransparency = 1
        back.Image = 'rbxassetid://14368303894'
        back.ImageColor3 = color.Light(uipallet.Main, 0.37)
        back.Parent = settingspane
        addCorner(settingspane)
        local settingschildren = Instance.new('ScrollingFrame')
        settingschildren.Name = 'Children'
        settingschildren.Size = UDim2.new(1, 0, 1, -45)
        settingschildren.Position = UDim2.fromOffset(0, 41)
        settingschildren.BackgroundColor3 = uipallet.Main
        settingschildren.BorderSizePixel = 0
        settingschildren.ScrollBarThickness = 2
        settingschildren.ScrollBarImageTransparency = 0.75
        settingschildren.CanvasSize = UDim2.new()
        settingschildren.Parent = settingspane
        local settingswindowlist = Instance.new('UIListLayout')
        settingswindowlist.SortOrder = Enum.SortOrder.LayoutOrder
        settingswindowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        settingswindowlist.Parent = settingschildren
        modulesettings.Function = modulesettings.Function or function() end
        addMaid(moduleapi)

        function moduleapi:Toggle()
            moduleapi.Enabled = not moduleapi.Enabled
            title.TextColor3 = moduleapi.Enabled and color.Light(uipallet.Text, 0.2) or color.Dark(uipallet.Text, 0.31)
            module.BackgroundColor3 = moduleapi.Enabled and color.Light(uipallet.Main, 0.05) or module.BackgroundColor3
            tween:Tween(knob, uipallet.Tween, {
                BackgroundColor3 = moduleapi.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Light(uipallet.Main, 0.14)
            })
            tween:Tween(knobmain, uipallet.Tween, {
                Position = UDim2.fromOffset(moduleapi.Enabled and 12 or 2, 2)
            })
            if not moduleapi.Enabled then
                for _, v in moduleapi.Connections do
                    v:Disconnect()
                end
                table.clear(moduleapi.Connections)
            end
            task.spawn(modulesettings.Function, moduleapi.Enabled)
        end

        back.MouseEnter:Connect(function()
            back.ImageColor3 = uipallet.Text
        end)
        back.MouseLeave:Connect(function()
            back.ImageColor3 = color.Light(uipallet.Main, 0.37)
        end)
        back.MouseButton1Click:Connect(function()
            tween:Tween(shadow, uipallet.Tween, {
                BackgroundTransparency = 1
            })
            tween:Tween(settingspane, uipallet.Tween, {
                Position = UDim2.fromScale(1, 0)
            })
            task.wait(0.2)
            shadow.Visible = false
        end)
        dotsbutton.MouseButton1Click:Connect(function()
            shadow.Visible = true
            tween:Tween(shadow, uipallet.Tween, {
                BackgroundTransparency = 0.5
            })
            tween:Tween(settingspane, uipallet.Tween, {
                Position = UDim2.new(1, -220, 0, 0)
            })
        end)
        dotsbutton.MouseEnter:Connect(function()
            dots.ImageColor3 = uipallet.Text
        end)
        dotsbutton.MouseLeave:Connect(function()
            dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
        end)
        module.MouseEnter:Connect(function()
            if not moduleapi.Enabled then
                module.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
            end
        end)
        module.MouseLeave:Connect(function()
            if not moduleapi.Enabled then
                module.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
            end
        end)
        module.MouseButton1Click:Connect(function()
            moduleapi:Toggle()
        end)
        module.MouseButton2Click:Connect(function()
            shadow.Visible = true
            tween:Tween(shadow, uipallet.Tween, {
                BackgroundTransparency = 0.5
            })
            tween:Tween(settingspane, uipallet.Tween, {
                Position = UDim2.new(1, -220, 0, 0)
            })
        end)
        shadow.MouseButton1Click:Connect(function()
            tween:Tween(shadow, uipallet.Tween, {
                BackgroundTransparency = 1
            })
            tween:Tween(settingspane, uipallet.Tween, {
                Position = UDim2.fromScale(1, 0)
            })
            task.wait(0.2)
            shadow.Visible = false
        end)
        settingswindowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            if mainapi.ThreadFix then
                setthreadidentity(8)
            end
            settingschildren.CanvasSize = UDim2.fromOffset(0, settingswindowlist.AbsoluteContentSize.Y / scale.Scale)
        end)

        for i, v in components do
            moduleapi['Create'..i] = function(_, optionsettings)
                return v(optionsettings, settingschildren, moduleapi)
            end
        end

        moduleapi.Object = module
        legitapi.Modules[modulesettings.Name] = moduleapi

        local sorting = {}
        for _, v in legitapi.Modules do
            table.insert(sorting, v.Name)
        end
        table.sort(sorting)

        for i, v in sorting do
            legitapi.Modules[v].Object.LayoutOrder = i
        end

        return moduleapi
    end

    local function visibleCheck()
        for _, v in legitapi.Modules do
            if v.Children then
                local visible = clickgui.Visible
                for _, v2 in mainapi.Windows do
                    visible = visible or v2.Visible
                end
                v.Children.Visible = (not visible or window.Visible) and v.Enabled
            end
        end
    end

    close.MouseButton1Click:Connect(function()
        window.Visible = false
        clickgui.Visible = true
    end)
    mainapi:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(visibleCheck))
    window:GetPropertyChangedSignal('Visible'):Connect(function()
        mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        visibleCheck()
    end)
    windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
    end)

    mainapi.Legit = legitapi

    return legitapi
end

function mainapi:Load(skipgui)
    if not skipgui then
        if self.GUIColor and self.GUIColor.SetValue then
            self.GUIColor:SetValue(nil, nil, nil, 4)
        end
    end
    
    self.Keybind = {'RightShift'}
    
    if self.ProfileLabel then
        self.ProfileLabel.Text = #self.Profile > 10 and self.Profile:sub(1, 10)..'...' or self.Profile
        self.ProfileLabel.Size = UDim2.fromOffset(getfontsize(self.ProfileLabel.Text, self.ProfileLabel.TextSize, self.ProfileLabel.Font).X + 16, 24)
    end

    if self.Downloader then
        self.Downloader:Destroy()
        self.Downloader = nil
    end
    self.Loaded = true
    
    if self.Categories and self.Categories.Main and self.Categories.Main.Options and self.Categories.Main.Options.Bind then
        self.Categories.Main.Options.Bind:SetBind(self.Keybind)
    end
    
    if inputService.TouchEnabled and #self.Keybind == 1 and self.Keybind[1] == 'RightShift' then
        local button = Instance.new('TextButton')
        button.Size = UDim2.fromOffset(32, 32)
        button.Position = UDim2.new(1, -90, 0, 4)
        button.BackgroundColor3 = Color3.new()
        button.BackgroundTransparency = 0.5
        button.Text = ''
        button.Parent = gui
        local image = Instance.new('ImageLabel')
        image.Size = UDim2.fromOffset(26, 26)
        image.Position = UDim2.fromOffset(3, 3)
        image.BackgroundTransparency = 1
        image.Image = 'rbxassetid://14373395239'
        image.Parent = button
        local buttoncorner = Instance.new('UICorner')
        buttoncorner.Parent = button
        self.VapeButton = button
        button.MouseButton1Click:Connect(function()
            if mainapi.ThreadFix then
                setthreadidentity(8)
            end
            for _, v in mainapi.Windows do
                v.Visible = false
            end
            clickgui.Visible = not clickgui.Visible
            tooltip.Visible = false
            mainapi:BlurCheck()
        end)
    end
end

function mainapi:Save(newprofile)
    if not self.Loaded then return end
end

function mainapi:Uninject()
    mainapi:Save()
    mainapi.Loaded = nil
    for _, v in self.Modules do
        if v.Enabled then
            v:Toggle()
        end
    end
    for _, v in self.Legit.Modules do
        if v.Enabled then
            v:Toggle()
        end
    end
    for _, v in self.Connections do
        pcall(function()
            v:Disconnect()
        end)
    end
    if mainapi.ThreadFix then
        setthreadidentity(8)
        clickgui.Visible = false
        mainapi:BlurCheck()
    end
    mainapi.gui:ClearAllChildren()
    mainapi.gui:Destroy()
    table.clear(mainapi.Libraries)
    loopClean(mainapi)
end

function mainapi:UpdateGUI(hue, sat, val, default)
    if mainapi.Loaded == nil then return end
    if not default and mainapi.GUIColor.Rainbow then return end

    local rainbow = mainapi.GUIColor.Rainbow and mainapi.RainbowMode.Value ~= 'Retro'

    for i, v in mainapi.Categories do
        if i == 'Main' then
            v.Object.VapeLogo.V4Logo.ImageColor3 = Color3.fromHSV(hue, sat, val)
            for _, button in v.Buttons do
                if button.Enabled then
                    button.Object.TextColor3 = rainbow and Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
                    if button.Icon then
                        button.Icon.ImageColor3 = button.Object.TextColor3
                    end
                end
            end
        end

        if v.Options then
            for _, option in v.Options do
                if option.Color then
                    option:Color(hue, sat, val, rainbow)
                end
            end
        end
    end

    for _, button in mainapi.Modules do
        if button.Enabled then
            button.Object.BackgroundColor3 = rainbow and Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
            button.Object.TextColor3 = mainapi.GUIColor.Rainbow and Color3.new(0.19, 0.19, 0.19) or mainapi:TextColor(hue, sat, val)
            button.Object.UIGradient.Enabled = rainbow and mainapi.RainbowMode.Value == 'Gradient'
            if button.Object.UIGradient.Enabled then
                button.Object.BackgroundColor3 = Color3.new(1, 1, 1)
                button.Object.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1))),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(mainapi:Color((hue - ((button.Index + 1) * 0.025)) % 1)))
                })
            end
            button.Object.Bind.Icon.ImageColor3 = button.Object.TextColor3
            button.Object.Bind.TextLabel.TextColor3 = button.Object.TextColor3
            button.Object.Dots.Dots.ImageColor3 = button.Object.TextColor3
        end

        for _, option in button.Options do
            if option.Color then
                option:Color(hue, sat, val, rainbow)
            end
        end
    end

    if mainapi.Legit.Window.Visible then
        for _, v in mainapi.Legit.Modules do
            if v.Enabled then
                tween:Cancel(v.Object.Knob)
                v.Object.Knob.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
            end

            for _, option in v.Options do
                if option.Color then
                    option:Color(hue, sat, val, rainbow)
                end
            end
        end
    end
end

function mainapi:UpdateTextGUI()
    -- Override in your script if needed
end

-- Initialize the GUI
gui = Instance.new('ScreenGui')
gui.Name = randomString()
gui.DisplayOrder = 9999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.IgnoreGuiInset = true
gui.OnTopOfCoreBlur = true
if mainapi.ThreadFix then
    gui.Parent = cloneref(game:GetService('CoreGui'))
else
    gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
    gui.ResetOnSpawn = false
end
mainapi.gui = gui
scaledgui = Instance.new('Frame')
scaledgui.Name = 'ScaledGui'
scaledgui.Size = UDim2.fromScale(1, 1)
scaledgui.BackgroundTransparency = 1
scaledgui.Parent = gui
clickgui = Instance.new('Frame')
clickgui.Name = 'ClickGui'
clickgui.Size = UDim2.fromScale(1, 1)
clickgui.BackgroundTransparency = 1
clickgui.Visible = false
clickgui.Parent = scaledgui
local scarcitybanner = Instance.new('TextLabel')
scarcitybanner.Size = UDim2.fromScale(1, 0.02)
scarcitybanner.Position = UDim2.fromScale(0, 0.97)
scarcitybanner.BackgroundTransparency = 1
scarcitybanner.Text = 'VapeV5 🥶'
scarcitybanner.TextScaled = true
scarcitybanner.TextColor3 = Color3.new(1, 1, 1)
scarcitybanner.TextStrokeTransparency = 0.5
scarcitybanner.FontFace = uipallet.Font
scarcitybanner.Parent = clickgui
local modal = Instance.new('TextButton')
modal.BackgroundTransparency = 1
modal.Modal = true
modal.Text = ''
modal.Parent = clickgui
local cursor = Instance.new('ImageLabel')
cursor.Size = UDim2.fromOffset(64, 64)
cursor.BackgroundTransparency = 1
cursor.Visible = false
cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
cursor.Parent = gui
notifications = Instance.new('Folder')
notifications.Name = 'Notifications'
notifications.Parent = scaledgui
tooltip = Instance.new('TextLabel')
tooltip.Name = 'Tooltip'
tooltip.Position = UDim2.fromScale(-1, -1)
tooltip.ZIndex = 5
tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
tooltip.Visible = false
tooltip.Text = ''
tooltip.TextColor3 = color.Dark(uipallet.Text, 0.16)
tooltip.TextSize = 12
tooltip.FontFace = uipallet.Font
tooltip.Parent = scaledgui
toolblur = addBlur(tooltip)
addCorner(tooltip)
local toolstrokebkg = Instance.new('Frame')
toolstrokebkg.Size = UDim2.new(1, -2, 1, -2)
toolstrokebkg.Position = UDim2.fromOffset(1, 1)
toolstrokebkg.ZIndex = 6
toolstrokebkg.BackgroundTransparency = 1
toolstrokebkg.Parent = tooltip
local toolstroke = Instance.new('UIStroke')
toolstroke.Color = color.Light(uipallet.Main, 0.02)
toolstroke.Parent = toolstrokebkg
addCorner(toolstrokebkg, UDim.new(0, 4))
scale = Instance.new('UIScale')
scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

mainapi:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
    if mainapi.Scale.Enabled then
        scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
    end
end))

mainapi:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
    scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
    for _, v in scaledgui:GetDescendants() do
        if v:IsA('GuiObject') and v.Visible then
            v.Visible = false
            v.Visible = true
        end
    end
end))

mainapi:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
    mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, true)
    if clickgui.Visible and inputService.MouseEnabled then
        repeat
            local visibleCheck = clickgui.Visible
            for _, v in mainapi.Windows do
                visibleCheck = visibleCheck or v.Visible
            end
            if not visibleCheck then break end

            cursor.Visible = not inputService.MouseIconEnabled
            if cursor.Visible then
                local mouseLocation = inputService:GetMouseLocation()
                cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32)
            end

            task.wait()
        until mainapi.Loaded == nil
        cursor.Visible = false
    end
end))

-- Create the main structure
mainapi:CreateGUI()
mainapi.Categories.Main:CreateDivider()

-- Create categories (they will auto-expand)
local Categories = {}

-- Combat category
Categories.Combat = mainapi:CreateCategory({
    Name = "Combat",
    Icon = "rbxassetid://14368312652",
    Size = UDim2.fromOffset(13, 14)
})

-- Movement category  
Categories.Movement = mainapi:CreateCategory({
    Name = "Movement",
    Icon = "rbxassetid://14368362492",
    Size = UDim2.fromOffset(14, 14)
})

-- Visuals category
Categories.Visuals = mainapi:CreateCategory({
    Name = "Visuals", 
    Icon = "rbxassetid://14368350193",
    Size = UDim2.fromOffset(15, 14)
})

-- Utility category
Categories.Utility = mainapi:CreateCategory({
    Name = "Utility",
    Icon = "rbxassetid://14368359107",
    Size = UDim2.fromOffset(15, 14)
})

-- Add Settings category at the end (always on the right)
local SettingsCategory = mainapi:AddSettingsCategory()

-- Auto-open the first category (Combat) by default
task.defer(function()
    if Categories.Combat and Categories.Combat.Button then
        Categories.Combat.Button:Toggle()
    end
end)

-- Position windows
task.wait(0.1)
local xOffset = 240
for i, category in pairs({Categories.Combat, Categories.Movement, Categories.Visuals, Categories.Utility, SettingsCategory}) do
    if category and category.Object then
        category.Object.Position = UDim2.fromOffset(xOffset, 60)
        xOffset = xOffset + 230
    end
end

mainapi:Load()

-- Make the GUI visible
clickgui.Visible = true

print("UI Loaded successfully! Press Right Shift to close and reopen.")

return mainapi
