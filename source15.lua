--[[
    VapeV4 Style UI Library - FIXED VERSION
    A complete recreation of Vape V4's UI components and styling
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

local components
components = {
    Button = function(optionsettings, children, api)
        local button = Instance.new('TextButton')
        button.Name = optionsettings.Name..'Button'
        button.Size = UDim2.new(1, 0, 0, 31)
        button.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Visible = optionsettings.Visible == nil or optionsettings.Visible
        button.Text = ''
        button.Parent = children
        addTooltip(button, optionsettings.Tooltip)
        local bkg = Instance.new('Frame')
        bkg.Size = UDim2.fromOffset(200, 27)
        bkg.Position = UDim2.fromOffset(10, 2)
        bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
        bkg.Parent = button
        addCorner(bkg)
        local label = Instance.new('TextLabel')
        label.Size = UDim2.new(1, -4, 1, -4)
        label.Position = UDim2.fromOffset(2, 2)
        label.BackgroundColor3 = uipallet.Main
        label.Text = optionsettings.Name
        label.TextColor3 = color.Dark(uipallet.Text, 0.16)
        label.TextSize = 14
        label.FontFace = uipallet.Font
        label.Parent = bkg
        addCorner(label, UDim.new(0, 4))
        optionsettings.Function = optionsettings.Function or function() end
        
        button.MouseEnter:Connect(function()
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
            })
        end)
        button.MouseLeave:Connect(function()
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.05)
            })
        end)
        button.MouseButton1Click:Connect(optionsettings.Function)
    end,
    ColorSlider = function(optionsettings, children, api)
        local optionapi = {
            Type = 'ColorSlider',
            Hue = optionsettings.DefaultHue or 0.44,
            Sat = optionsettings.DefaultSat or 1,
            Value = optionsettings.DefaultValue or 1,
            Opacity = optionsettings.DefaultOpacity or 1,
            Rainbow = false,
            Index = 0
        }
        
        local function createSlider(name, gradientColor)
            local slider = Instance.new('TextButton')
            slider.Name = optionsettings.Name..'Slider'..name
            slider.Size = UDim2.new(1, 0, 0, 50)
            slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
            slider.BorderSizePixel = 0
            slider.AutoButtonColor = false
            slider.Visible = false
            slider.Text = ''
            slider.Parent = children
            local title = Instance.new('TextLabel')
            title.Name = 'Title'
            title.Size = UDim2.fromOffset(60, 30)
            title.Position = UDim2.fromOffset(10, 2)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextColor3 = color.Dark(uipallet.Text, 0.16)
            title.TextSize = 11
            title.FontFace = uipallet.Font
            title.Parent = slider
            local bkg = Instance.new('Frame')
            bkg.Name = 'Slider'
            bkg.Size = UDim2.new(1, -20, 0, 2)
            bkg.Position = UDim2.fromOffset(10, 37)
            bkg.BackgroundColor3 = Color3.new(1, 1, 1)
            bkg.BorderSizePixel = 0
            bkg.Parent = slider
            local gradient = Instance.new('UIGradient')
            gradient.Color = gradientColor
            gradient.Parent = bkg
            local fill = bkg:Clone()
            fill.Name = 'Fill'
            fill.Size = UDim2.fromScale(math.clamp(name == 'Saturation' and optionapi.Sat or name == 'Vibrance' and optionapi.Value or optionapi.Opacity, 0.04, 0.96), 1)
            fill.Position = UDim2.new()
            fill.BackgroundTransparency = 1
            fill.Parent = bkg
            local knobholder = Instance.new('Frame')
            knobholder.Name = 'Knob'
            knobholder.Size = UDim2.fromOffset(24, 4)
            knobholder.Position = UDim2.fromScale(1, 0.5)
            knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
            knobholder.BackgroundColor3 = slider.BackgroundColor3
            knobholder.BorderSizePixel = 0
            knobholder.Parent = fill
            local knob = Instance.new('Frame')
            knob.Name = 'Knob'
            knob.Size = UDim2.fromOffset(14, 14)
            knob.Position = UDim2.fromScale(0.5, 0.5)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = uipallet.Text
            knob.Parent = knobholder
            addCorner(knob, UDim.new(1, 0))
        
            slider.InputBegan:Connect(function(inputObj)
                if
                    (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                    and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
                then
                    local changed = inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                            optionapi:SetValue(nil, name == 'Saturation' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil, name == 'Vibrance' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil, name == 'Opacity' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil)
                        end
                    end)
        
                    local ended
                    ended = inputObj.Changed:Connect(function()
                        if inputObj.UserInputState == Enum.UserInputState.End then
                            if changed then changed:Disconnect() end
                            if ended then ended:Disconnect() end
                        end
                    end)
                end
            end)
            slider.MouseEnter:Connect(function()
                tween:Tween(knob, uipallet.Tween, {
                    Size = UDim2.fromOffset(16, 16)
                })
            end)
            slider.MouseLeave:Connect(function()
                tween:Tween(knob, uipallet.Tween, {
                    Size = UDim2.fromOffset(14, 14)
                })
            end)
        
            return slider
        end
        
        local slider = Instance.new('TextButton')
        slider.Name = optionsettings.Name..'Slider'
        slider.Size = UDim2.new(1, 0, 0, 50)
        slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        slider.BorderSizePixel = 0
        slider.AutoButtonColor = false
        slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
        slider.Text = ''
        slider.Parent = children
        addTooltip(slider, optionsettings.Tooltip)
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
        local valuebox = Instance.new('TextBox')
        valuebox.Name = 'Box'
        valuebox.Size = UDim2.fromOffset(60, 15)
        valuebox.Position = UDim2.new(1, -69, 0, 9)
        valuebox.BackgroundTransparency = 1
        valuebox.Visible = false
        valuebox.Text = ''
        valuebox.TextXAlignment = Enum.TextXAlignment.Right
        valuebox.TextColor3 = color.Dark(uipallet.Text, 0.16)
        valuebox.TextSize = 11
        valuebox.FontFace = uipallet.Font
        valuebox.ClearTextOnFocus = true
        valuebox.Parent = slider
        local bkg = Instance.new('Frame')
        bkg.Name = 'Slider'
        bkg.Size = UDim2.new(1, -20, 0, 2)
        bkg.Position = UDim2.fromOffset(10, 39)
        bkg.BackgroundColor3 = Color3.new(1, 1, 1)
        bkg.BorderSizePixel = 0
        bkg.Parent = slider
        local rainbowTable = {}
        for i = 0, 1, 0.1 do
            table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
        end
        local gradient = Instance.new('UIGradient')
        gradient.Color = ColorSequence.new(rainbowTable)
        gradient.Parent = bkg
        local fill = bkg:Clone()
        fill.Name = 'Fill'
        fill.Size = UDim2.fromScale(math.clamp(optionapi.Hue, 0.04, 0.96), 1)
        fill.Position = UDim2.new()
        fill.BackgroundTransparency = 1
        fill.Parent = bkg
        local preview = Instance.new('ImageButton')
        preview.Name = 'Preview'
        preview.Size = UDim2.fromOffset(12, 12)
        preview.Position = UDim2.new(1, -22, 0, 10)
        preview.BackgroundTransparency = 1
        preview.Image = 'rbxassetid://14368311578'
        preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
        preview.ImageTransparency = 1 - optionapi.Opacity
        preview.Parent = slider
        local expandbutton = Instance.new('TextButton')
        expandbutton.Name = 'Expand'
        expandbutton.Size = UDim2.fromOffset(17, 13)
        expandbutton.Position = UDim2.new(0, textService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(1000, 1000)).X + 11, 0, 7)
        expandbutton.BackgroundTransparency = 1
        expandbutton.Text = ''
        expandbutton.Parent = slider
        local expand = Instance.new('ImageLabel')
        expand.Name = 'Expand'
        expand.Size = UDim2.fromOffset(9, 5)
        expand.Position = UDim2.fromOffset(4, 4)
        expand.BackgroundTransparency = 1
        expand.Image = 'rbxassetid://14368353032'
        expand.ImageColor3 = color.Dark(uipallet.Text, 0.43)
        expand.Parent = expandbutton
        local rainbow = Instance.new('TextButton')
        rainbow.Name = 'Rainbow'
        rainbow.Size = UDim2.fromOffset(12, 12)
        rainbow.Position = UDim2.new(1, -42, 0, 10)
        rainbow.BackgroundTransparency = 1
        rainbow.Text = ''
        rainbow.Parent = slider
        local rainbow1 = Instance.new('ImageLabel')
        rainbow1.Size = UDim2.fromOffset(12, 12)
        rainbow1.BackgroundTransparency = 1
        rainbow1.Image = 'rbxassetid://14368344374'
        rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
        rainbow1.Parent = rainbow
        local rainbow2 = rainbow1:Clone()
        rainbow2.Image = 'rbxassetid://14368345149'
        rainbow2.Parent = rainbow
        local rainbow3 = rainbow1:Clone()
        rainbow3.Image = 'rbxassetid://14368345840'
        rainbow3.Parent = rainbow
        local rainbow4 = rainbow1:Clone()
        rainbow4.Image = 'rbxassetid://14368346696'
        rainbow4.Parent = rainbow
        local knobholder = Instance.new('Frame')
        knobholder.Name = 'Knob'
        knobholder.Size = UDim2.fromOffset(24, 4)
        knobholder.Position = UDim2.fromScale(1, 0.5)
        knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
        knobholder.BackgroundColor3 = slider.BackgroundColor3
        knobholder.BorderSizePixel = 0
        knobholder.Parent = fill
        local knob = Instance.new('Frame')
        knob.Name = 'Knob'
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = UDim2.fromScale(0.5, 0.5)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = uipallet.Text
        knob.Parent = knobholder
        addCorner(knob, UDim.new(1, 0))
        optionsettings.Function = optionsettings.Function or function() end
        local satSlider = createSlider('Saturation', ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, optionapi.Value)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, 1, optionapi.Value))
        }))
        local vibSlider = createSlider('Vibrance', ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, 1))
        }))
        local opSlider = createSlider('Opacity', ColorSequence.new({
            ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value))
        }))
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {
                Hue = self.Hue,
                Sat = self.Sat,
                Value = self.Value,
                Opacity = self.Opacity,
                Rainbow = self.Rainbow
            }
        end
        
        function optionapi:Load(tab)
            if tab.Rainbow ~= self.Rainbow then
                self:Toggle()
            end
            if self.Hue ~= tab.Hue or self.Sat ~= tab.Sat or self.Value ~= tab.Value or self.Opacity ~= tab.Opacity then
                self:SetValue(tab.Hue, tab.Sat, tab.Value, tab.Opacity)
            end
        end
        
        function optionapi:SetValue(h, s, v, o)
            self.Hue = h or self.Hue
            self.Sat = s or self.Sat
            self.Value = v or self.Value
            self.Opacity = o or self.Opacity
            preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
            preview.ImageTransparency = 1 - self.Opacity
            satSlider.Slider.UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
            })
            vibSlider.Slider.UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
            })
            opSlider.Slider.UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))
            })
        
            if self.Rainbow then
                fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
            else
                tween:Tween(fill, uipallet.Tween, {
                    Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
                })
            end
        
            if s then
                tween:Tween(satSlider.Slider.Fill, uipallet.Tween, {
                    Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
                })
            end
            if v then
                tween:Tween(vibSlider.Slider.Fill, uipallet.Tween, {
                    Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
                })
            end
            if o then
                tween:Tween(opSlider.Slider.Fill, uipallet.Tween, {
                    Size = UDim2.fromScale(math.clamp(self.Opacity, 0.04, 0.96), 1)
                })
            end
        
            optionsettings.Function(self.Hue, self.Sat, self.Value, self.Opacity)
        end
        
        function optionapi:Toggle()
            self.Rainbow = not self.Rainbow
            if self.Rainbow then
                table.insert(mainapi.RainbowTable, self)
                rainbow1.ImageColor3 = Color3.fromRGB(5, 127, 100)
                task.delay(0.1, function()
                    if not self.Rainbow then return end
                    rainbow2.ImageColor3 = Color3.fromRGB(228, 125, 43)
                    task.delay(0.1, function()
                        if not self.Rainbow then return end
                        rainbow3.ImageColor3 = Color3.fromRGB(225, 46, 52)
                    end)
                end)
            else
                local ind = table.find(mainapi.RainbowTable, self)
                if ind then
                    table.remove(mainapi.RainbowTable, ind)
                end
                rainbow3.ImageColor3 = color.Light(uipallet.Main, 0.37)
                task.delay(0.1, function()
                    if self.Rainbow then return end
                    rainbow2.ImageColor3 = color.Light(uipallet.Main, 0.37)
                    task.delay(0.1, function()
                        if self.Rainbow then return end
                        rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
                    end)
                end)
            end
        end
        
        local doubleClick = tick()
        preview.MouseButton1Click:Connect(function()
            preview.Visible = false
            valuebox.Visible = true
            valuebox:CaptureFocus()
            local text = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
            valuebox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255)
        end)
        slider.InputBegan:Connect(function(inputObj)
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
            then
                if doubleClick > tick() then
                    optionapi:Toggle()
                end
                doubleClick = tick() + 0.3
                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        optionapi:SetValue(math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1))
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
        slider.MouseEnter:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(16, 16)
            })
        end)
        slider.MouseLeave:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(14, 14)
            })
        end)
        slider:GetPropertyChangedSignal('Visible'):Connect(function()
            satSlider.Visible = expand.Rotation == 180 and slider.Visible
            vibSlider.Visible = satSlider.Visible
            opSlider.Visible = satSlider.Visible
        end)
        expandbutton.MouseEnter:Connect(function()
            expand.ImageColor3 = color.Dark(uipallet.Text, 0.16)
        end)
        expandbutton.MouseLeave:Connect(function()
            expand.ImageColor3 = color.Dark(uipallet.Text, 0.43)
        end)
        expandbutton.MouseButton1Click:Connect(function()
            satSlider.Visible = not satSlider.Visible
            vibSlider.Visible = satSlider.Visible
            opSlider.Visible = satSlider.Visible
            expand.Rotation = satSlider.Visible and 180 or 0
        end)
        rainbow.MouseButton1Click:Connect(function()
            optionapi:Toggle()
        end)
        valuebox.FocusLost:Connect(function(enter)
            preview.Visible = true
            valuebox.Visible = false
            if enter then
                local commas = valuebox.Text:split(',')
                local suc, res = pcall(function()
                    return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text)
                end)
                if suc then
                    if optionapi.Rainbow then
                        optionapi:Toggle()
                    end
                    optionapi:SetValue(res:ToHSV())
                end
            end
        end)
        
        optionapi.Object = slider
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    Dropdown = function(optionsettings, children, api)
        local optionapi = {
            Type = 'Dropdown',
            Value = optionsettings.List[1] or 'None',
            Index = 0
        }
        
        local dropdown = Instance.new('TextButton')
        dropdown.Name = optionsettings.Name..'Dropdown'
        dropdown.Size = UDim2.new(1, 0, 0, 40)
        dropdown.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        dropdown.BorderSizePixel = 0
        dropdown.AutoButtonColor = false
        dropdown.Visible = optionsettings.Visible == nil or optionsettings.Visible
        dropdown.Text = ''
        dropdown.Parent = children
        addTooltip(dropdown, optionsettings.Tooltip or optionsettings.Name)
        local bkg = Instance.new('Frame')
        bkg.Name = 'BKG'
        bkg.Size = UDim2.new(1, -20, 1, -9)
        bkg.Position = UDim2.fromOffset(10, 4)
        bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
        bkg.Parent = dropdown
        addCorner(bkg, UDim.new(0, 6))
        local button = Instance.new('TextButton')
        button.Name = 'Dropdown'
        button.Size = UDim2.new(1, -2, 1, -2)
        button.Position = UDim2.fromOffset(1, 1)
        button.BackgroundColor3 = uipallet.Main
        button.AutoButtonColor = false
        button.Text = ''
        button.Parent = bkg
        local title = Instance.new('TextLabel')
        title.Name = 'Title'
        title.Size = UDim2.new(1, 0, 0, 29)
        title.BackgroundTransparency = 1
        title.Text = '         '..optionsettings.Name..' - '..optionapi.Value
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = color.Dark(uipallet.Text, 0.16)
        title.TextSize = 13        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.FontFace = uipallet.Font
        title.Parent = button
        addCorner(button, UDim.new(0, 6))
        local arrow = Instance.new('ImageLabel')
        arrow.Name = 'Arrow'
        arrow.Size = UDim2.fromOffset(4, 8)
        arrow.Position = UDim2.new(1, -17, 0, 11)
        arrow.BackgroundTransparency = 1
        arrow.Image = 'rbxassetid://14368316544'
        arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
        arrow.Rotation = 90
        arrow.Parent = button
        optionsettings.Function = optionsettings.Function or function() end
        local dropdownchildren
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {Value = self.Value}
        end
        
        function optionapi:Load(tab)
            if self.Value ~= tab.Value then
                self:SetValue(tab.Value)
            end
        end
        
        function optionapi:Change(list)
            optionsettings.List = list or {}
            if not table.find(optionsettings.List, self.Value) then
                self:SetValue(self.Value)
            end
        end
        
        function optionapi:SetValue(val, mouse)
            self.Value = table.find(optionsettings.List, val) and val or optionsettings.List[1] or 'None'
            title.Text = '         '..optionsettings.Name..' - '..self.Value
            if dropdownchildren then
                arrow.Rotation = 90
                dropdownchildren:Destroy()
                dropdownchildren = nil
                dropdown.Size = UDim2.new(1, 0, 0, 40)
            end
            optionsettings.Function(self.Value, mouse)
        end
        
        button.MouseButton1Click:Connect(function()
            if not dropdownchildren then
                arrow.Rotation = 270
                dropdown.Size = UDim2.new(1, 0, 0, 40 + (#optionsettings.List - 1) * 26)
                dropdownchildren = Instance.new('Frame')
                dropdownchildren.Name = 'Children'
                dropdownchildren.Size = UDim2.new(1, 0, 0, (#optionsettings.List - 1) * 26)
                dropdownchildren.Position = UDim2.fromOffset(0, 27)
                dropdownchildren.BackgroundTransparency = 1
                dropdownchildren.Parent = button
                local ind = 0
                for _, v in optionsettings.List do
                    if v == optionapi.Value then continue end
                    local dropdownoption = Instance.new('TextButton')
                    dropdownoption.Name = v..'Option'
                    dropdownoption.Size = UDim2.new(1, 0, 0, 26)
                    dropdownoption.Position = UDim2.fromOffset(0, ind * 26)
                    dropdownoption.BackgroundColor3 = uipallet.Main
                    dropdownoption.BorderSizePixel = 0
                    dropdownoption.AutoButtonColor = false
                    dropdownoption.Text = '         '..v
                    dropdownoption.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownoption.TextColor3 = color.Dark(uipallet.Text, 0.16)
                    dropdownoption.TextSize = 13
                    dropdownoption.TextTruncate = Enum.TextTruncate.AtEnd
                    dropdownoption.FontFace = uipallet.Font
                    dropdownoption.Parent = dropdownchildren
                    dropdownoption.MouseEnter:Connect(function()
                        tween:Tween(dropdownoption, uipallet.Tween, {
                            BackgroundColor3 = color.Light(uipallet.Main, 0.02)
                        })
                    end)
                    dropdownoption.MouseLeave:Connect(function()
                        tween:Tween(dropdownoption, uipallet.Tween, {
                            BackgroundColor3 = uipallet.Main
                        })
                    end)
                    dropdownoption.MouseButton1Click:Connect(function()
                        optionapi:SetValue(v, true)
                    end)
                    ind += 1
                end
            else
                optionapi:SetValue(optionapi.Value, true)
            end
        end)
        dropdown.MouseEnter:Connect(function()
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
            })
        end)
        dropdown.MouseLeave:Connect(function()
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.034)
            })
        end)
        
        optionapi.Object = dropdown
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    Font = function(optionsettings, children, api)
        local fonts = {
            optionsettings.Blacklist,
            'Custom'
        }
        for _, v in Enum.Font:GetEnumItems() do
            if not table.find(fonts, v.Name) then
                table.insert(fonts, v.Name)
            end
        end
        
        local optionapi = {Value = Font.fromEnum(Enum.Font[fonts[1]])}
        local fontdropdown
        local fontbox
        optionsettings.Function = optionsettings.Function or function() end
        
        fontdropdown = components.Dropdown({
            Name = optionsettings.Name,
            List = fonts,
            Function = function(val)
                fontbox.Object.Visible = val == 'Custom' and fontdropdown.Object.Visible
                if val ~= 'Custom' then
                    optionapi.Value = Font.fromEnum(Enum.Font[val])
                    optionsettings.Function(optionapi.Value)
                else
                    pcall(function()
                        optionapi.Value = Font.fromId(tonumber(fontbox.Value))
                    end)
                    optionsettings.Function(optionapi.Value)
                end
            end,
            Darker = optionsettings.Darker,
            Visible = optionsettings.Visible
        }, children, api)
        optionapi.Object = fontdropdown.Object
        fontbox = components.TextBox({
            Name = optionsettings.Name..' Asset',
            Placeholder = 'font (rbxasset)',
            Function = function()
                if fontdropdown.Value == 'Custom' then
                    pcall(function()
                        optionapi.Value = Font.fromId(tonumber(fontbox.Value))
                    end)
                    optionsettings.Function(optionapi.Value)
                end
            end,
            Visible = false,
            Darker = true
        }, children, api)
        
        fontdropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function()
            fontbox.Object.Visible = fontdropdown.Object.Visible and fontdropdown.Value == 'Custom'
        end)
        
        return optionapi
    end,
    Slider = function(optionsettings, children, api)
        local optionapi = {
            Type = 'Slider',
            Value = optionsettings.Default or optionsettings.Min,
            Max = optionsettings.Max,
            Index = getTableSize(api.Options)
        }
        
        local slider = Instance.new('TextButton')
        slider.Name = optionsettings.Name..'Slider'
        slider.Size = UDim2.new(1, 0, 0, 50)
        slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        slider.BorderSizePixel = 0
        slider.AutoButtonColor = false
        slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
        slider.Text = ''
        slider.Parent = children
        addTooltip(slider, optionsettings.Tooltip)
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
        local valuebutton = Instance.new('TextButton')
        valuebutton.Name = 'Value'
        valuebutton.Size = UDim2.fromOffset(60, 15)
        valuebutton.Position = UDim2.new(1, -69, 0, 9)
        valuebutton.BackgroundTransparency = 1
        valuebutton.Text = optionapi.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(optionapi.Value) or optionsettings.Suffix) or '')
        valuebutton.TextXAlignment = Enum.TextXAlignment.Right
        valuebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
        valuebutton.TextSize = 11
        valuebutton.FontFace = uipallet.Font
        valuebutton.Parent = slider
        local valuebox = Instance.new('TextBox')
        valuebox.Name = 'Box'
        valuebox.Size = valuebutton.Size
        valuebox.Position = valuebutton.Position
        valuebox.BackgroundTransparency = 1
        valuebox.Visible = false
        valuebox.Text = optionapi.Value
        valuebox.TextXAlignment = Enum.TextXAlignment.Right
        valuebox.TextColor3 = color.Dark(uipallet.Text, 0.16)
        valuebox.TextSize = 11
        valuebox.FontFace = uipallet.Font
        valuebox.ClearTextOnFocus = false
        valuebox.Parent = slider
        local bkg = Instance.new('Frame')
        bkg.Name = 'Slider'
        bkg.Size = UDim2.new(1, -20, 0, 2)
        bkg.Position = UDim2.fromOffset(10, 37)
        bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
        bkg.BorderSizePixel = 0
        bkg.Parent = slider
        local fill = bkg:Clone()
        fill.Name = 'Fill'
        fill.Size = UDim2.fromScale(math.clamp((optionapi.Value - optionsettings.Min) / optionsettings.Max, 0.04, 0.96), 1)
        fill.Position = UDim2.new()
        fill.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        fill.Parent = bkg
        local knobholder = Instance.new('Frame')
        knobholder.Name = 'Knob'
        knobholder.Size = UDim2.fromOffset(24, 4)
        knobholder.Position = UDim2.fromScale(1, 0.5)
        knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
        knobholder.BackgroundColor3 = slider.BackgroundColor3
        knobholder.BorderSizePixel = 0
        knobholder.Parent = fill
        local knob = Instance.new('Frame')
        knob.Name = 'Knob'
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = UDim2.fromScale(0.5, 0.5)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        knob.Parent = knobholder
        addCorner(knob, UDim.new(1, 0))
        optionsettings.Function = optionsettings.Function or function() end
        optionsettings.Decimal = optionsettings.Decimal or 1
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {
                Value = self.Value,
                Max = self.Max
            }
        end
        
        function optionapi:Load(tab)
            local newval = tab.Value == tab.Max and tab.Max ~= self.Max and self.Max or tab.Value
            if self.Value ~= newval then
                self:SetValue(newval, nil, true)
            end
        end
        
        function optionapi:Color(hue, sat, val, rainbowcheck)
            fill.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
            knob.BackgroundColor3 = fill.BackgroundColor3
        end
        
        function optionapi:SetValue(value, pos, final)
            if tonumber(value) == math.huge or value ~= value then return end
            local check = self.Value ~= value
            self.Value = value
            tween:Tween(fill, uipallet.Tween, {
                Size = UDim2.fromScale(math.clamp(pos or math.clamp(value / optionsettings.Max, 0, 1), 0.04, 0.96), 1)
            })
            valuebutton.Text = self.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(self.Value) or optionsettings.Suffix) or '')
            if check or final then
                optionsettings.Function(value, final)
            end
        end
        
        slider.InputBegan:Connect(function(inputObj)
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
            then
                local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
                optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
                local lastValue = optionapi.Value
                local lastPosition = newPosition
        
                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        local newPosition = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
                        optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
                        lastValue = optionapi.Value
                        lastPosition = newPosition
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
                        optionapi:SetValue(lastValue, lastPosition, true)
                    end
                end)
        
            end
        end)
        slider.MouseEnter:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(16, 16)
            })
        end)
        slider.MouseLeave:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(14, 14)
            })
        end)
        valuebutton.MouseButton1Click:Connect(function()
            valuebutton.Visible = false
            valuebox.Visible = true
            valuebox.Text = optionapi.Value
            valuebox:CaptureFocus()
        end)
        valuebox.FocusLost:Connect(function(enter)
            valuebutton.Visible = true
            valuebox.Visible = false
            if enter and tonumber(valuebox.Text) then
                optionapi:SetValue(tonumber(valuebox.Text), nil, true)
            end
        end)
        
        optionapi.Object = slider
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    TargetsButton = function(optionsettings, children, api)
    local optionapi = {Enabled = false}
    
    local targetbutton = Instance.new('TextButton')
    targetbutton.Size = UDim2.fromOffset(98, 31)
    targetbutton.Position = optionsettings.Position
    targetbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
    targetbutton.AutoButtonColor = false
    targetbutton.Visible = optionsettings.Visible == nil or optionsettings.Visible
    targetbutton.Text = ''
    targetbutton.Parent = children
    addCorner(targetbutton)
    addTooltip(targetbutton, optionsettings.Tooltip)
    local bkg = Instance.new('Frame')
    bkg.Size = UDim2.new(1, -2, 1, -2)
    bkg.Position = UDim2.fromOffset(1, 1)
    bkg.BackgroundColor3 = uipallet.Main
    bkg.Parent = targetbutton
    addCorner(bkg)
    local icon = Instance.new('ImageLabel')
    icon.Size = optionsettings.IconSize
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = optionsettings.Icon
    icon.ImageColor3 = color.Light(uipallet.Main, 0.37)
    icon.Parent = bkg
    optionsettings.Function = optionsettings.Function or function() end
    local tooltipicon
    
    function optionapi:Toggle()
        self.Enabled = not self.Enabled
        tween:Tween(bkg, uipallet.Tween, {
            BackgroundColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or uipallet.Main
        })
        tween:Tween(icon, uipallet.Tween, {
            ImageColor3 = self.Enabled and Color3.new(1, 1, 1) or color.Light(uipallet.Main, 0.37)
        })
        if tooltipicon then
            tooltipicon:Destroy()
        end
        if self.Enabled then
            tooltipicon = Instance.new('ImageLabel')
            tooltipicon.Size = optionsettings.ToolSize
            tooltipicon.BackgroundTransparency = 1
            tooltipicon.Image = optionsettings.ToolIcon
            tooltipicon.ImageColor3 = uipallet.Text
            tooltipicon.Parent = optionsettings.IconParent
        end
        optionsettings.Function(self.Enabled)
    end
    
    targetbutton.MouseEnter:Connect(function()
        if not optionapi.Enabled then
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value - 0.25)
            })
            tween:Tween(icon, uipallet.Tween, {
                ImageColor3 = Color3.new(1, 1, 1)
            })
        end
    end)
    targetbutton.MouseLeave:Connect(function()
        if not optionapi.Enabled then
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = uipallet.Main
            })
            tween:Tween(icon, uipallet.Tween, {
                ImageColor3 = color.Light(uipallet.Main, 0.37)
            })
        end
    end)
    targetbutton.MouseButton1Click:Connect(function()
        optionapi:Toggle()
    end)
    
    optionapi.Object = targetbutton
    
    return optionapi
end,
Targets = function(optionsettings, children, api)
    local optionapi = {
        Type = 'Targets',
        Index = getTableSize(api.Options)
    }
    
    local textlist = Instance.new('TextButton')
    textlist.Name = 'Targets'
    textlist.Size = UDim2.new(1, 0, 0, 50)
    textlist.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
    textlist.BorderSizePixel = 0
    textlist.AutoButtonColor = false
    textlist.Visible = optionsettings.Visible == nil or optionsettings.Visible
    textlist.Text = ''
    textlist.Parent = children
    addTooltip(textlist, optionsettings.Tooltip)
    local bkg = Instance.new('Frame')
    bkg.Name = 'BKG'
    bkg.Size = UDim2.new(1, -20, 1, -9)
    bkg.Position = UDim2.fromOffset(10, 4)
    bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
    bkg.Parent = textlist
    addCorner(bkg, UDim.new(0, 4))
    local button = Instance.new('TextButton')
    button.Name = 'TextList'
    button.Size = UDim2.new(1, -2, 1, -2)
    button.Position = UDim2.fromOffset(1, 1)
    button.BackgroundColor3 = uipallet.Main
    button.AutoButtonColor = false
    button.Text = ''
    button.Parent = bkg
    local buttontitle = Instance.new('TextLabel')
    buttontitle.Name = 'Title'
    buttontitle.Size = UDim2.new(1, -5, 0, 15)
    buttontitle.Position = UDim2.fromOffset(5, 6)
    buttontitle.BackgroundTransparency = 1
    buttontitle.Text = 'Target:'
    buttontitle.TextXAlignment = Enum.TextXAlignment.Left
    buttontitle.TextColor3 = color.Dark(uipallet.Text, 0.16)
    buttontitle.TextSize = 15
    buttontitle.TextTruncate = Enum.TextTruncate.AtEnd
    buttontitle.FontFace = uipallet.Font
    buttontitle.Parent = button
    local items = buttontitle:Clone()
    items.Name = 'Items'
    items.Position = UDim2.fromOffset(5, 21)
    items.Text = 'Ignore none'
    items.TextColor3 = color.Dark(uipallet.Text, 0.16)
    items.TextSize = 11
    items.Parent = button
    addCorner(button, UDim.new(0, 4))
    local tool = Instance.new('Frame')
    tool.Size = UDim2.fromOffset(65, 12)
    tool.Position = UDim2.fromOffset(52, 8)
    tool.BackgroundTransparency = 1
    tool.Parent = button
    local toollist = Instance.new('UIListLayout')
    toollist.FillDirection = Enum.FillDirection.Horizontal
    toollist.Padding = UDim.new(0, 6)
    toollist.Parent = tool
    local window = Instance.new('TextButton')
    window.Name = 'TargetsTextWindow'
    window.Size = UDim2.fromOffset(220, 145)
    window.BackgroundColor3 = uipallet.Main
    window.BorderSizePixel = 0
    window.AutoButtonColor = false
    window.Visible = false
    window.Text = ''
    window.Parent = clickgui
    optionapi.Window = window
    addBlur(window)
    addCorner(window)
    local icon = Instance.new('ImageLabel')
    icon.Name = 'Icon'
    icon.Size = UDim2.fromOffset(18, 12)
    icon.Position = UDim2.fromOffset(10, 15)
    icon.BackgroundTransparency = 1
    icon.Image = 'rbxassetid://14497393895'
    icon.Parent = window
    local title = Instance.new('TextLabel')
    title.Name = 'Title'
    title.Size = UDim2.new(1, -36, 0, 20)
    title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 11)
    title.BackgroundTransparency = 1
    title.Text = 'Target settings'
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = uipallet.Text
    title.TextSize = 13
    title.FontFace = uipallet.Font
    title.Parent = window
    local close = addCloseButton(window)
    optionsettings.Function = optionsettings.Function or function() end
    
    function optionapi:Save(tab)
        tab.Targets = {
            Players = self.Players.Enabled,
            NPCs = self.NPCs.Enabled,
            Walls = self.Walls.Enabled
        }
    end
    
    function optionapi:Load(tab)
        if self.Players.Enabled ~= tab.Players then
            self.Players:Toggle()
        end
        if self.NPCs.Enabled ~= tab.NPCs then
            self.NPCs:Toggle()
        end
        if self.Walls.Enabled ~= tab.Walls then
            self.Walls:Toggle()
        end
    end
    
    function optionapi:Color(hue, sat, val, rainbowcheck)
        bkg.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
        if self.Players.Enabled then
            tween:Cancel(self.Players.Object.Frame)
            self.Players.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
        end
        if self.NPCs.Enabled then
            tween:Cancel(self.NPCs.Object.Frame)
            self.NPCs.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
        end
        if self.Walls.Enabled then
            tween:Cancel(self.Walls.Object.Knob)
            self.Walls.Object.Knob.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
        end
    end
    
    optionapi.Players = components.TargetsButton({
        Position = UDim2.fromOffset(11, 45),
        Icon = 'rbxassetid://14497396015',
        IconSize = UDim2.fromOffset(15, 16),
        IconParent = tool,
        ToolIcon = 'rbxassetid://14497397862',
        ToolSize = UDim2.fromOffset(11, 12),
        Tooltip = 'Players',
        Function = optionsettings.Function
    }, window, tool)
    optionapi.NPCs = components.TargetsButton({
        Position = UDim2.fromOffset(112, 45),
        Icon = 'rbxassetid://14497400332',
        IconSize = UDim2.fromOffset(12, 16),
        IconParent = tool,
        ToolIcon = 'rbxassetid://14497402744',
        ToolSize = UDim2.fromOffset(9, 12),
        Tooltip = 'NPCs',
        Function = optionsettings.Function
    }, window, tool)
    optionapi.Walls = components.Toggle({
        Name = 'Ignore behind walls',
        Function = function()
            local text = 'none'
            if optionapi.Walls.Enabled then
                text = 'behind walls'
            end
            items.Text = 'Ignore '..text
            optionsettings.Function()
        end
    }, window, {Options = {}})
    optionapi.Walls.Object.Position = UDim2.fromOffset(0, 81)
    
    if optionsettings.Players then
        optionapi.Players:Toggle()
    end
    if optionsettings.NPCs then
        optionapi.NPCs:Toggle()
    end
    if optionsettings.Walls then
        optionapi.Walls:Toggle()
    end
    
    close.MouseButton1Click:Connect(function()
        window.Visible = false
    end)
    button.MouseButton1Click:Connect(function()
        window.Visible = not window.Visible
        tween:Cancel(bkg)
        bkg.BackgroundColor3 = window.Visible and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Light(uipallet.Main, 0.37)
    end)
    textlist.MouseEnter:Connect(function()
        if not optionapi.Window.Visible then
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.37)
            })
        end
    end)
    textlist.MouseLeave:Connect(function()
        if not optionapi.Window.Visible then
            tween:Tween(bkg, uipallet.Tween, {
                BackgroundColor3 = color.Light(uipallet.Main, 0.034)
            })
        end
    end)
    textlist:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
        if mainapi.ThreadFix then
            setthreadidentity(8)
        end
        local actualPosition = (textlist.AbsolutePosition + Vector2.new(0, 60)) / scale.Scale
        window.Position = UDim2.fromOffset(actualPosition.X + 220, actualPosition.Y)
    end)
    
    optionapi.Object = textlist
    api.Options.Targets = optionapi
    
    return optionapi
end,
    TextBox = function(optionsettings, children, api)
        local optionapi = {
            Type = 'TextBox',
            Value = optionsettings.Default or '',
            Index = 0
        }
        
        local textbox = Instance.new('TextButton')
        textbox.Name = optionsettings.Name..'TextBox'
        textbox.Size = UDim2.new(1, 0, 0, 58)
        textbox.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        textbox.BorderSizePixel = 0
        textbox.AutoButtonColor = false
        textbox.Visible = optionsettings.Visible == nil or optionsettings.Visible
        textbox.Text = ''
        textbox.Parent = children
        addTooltip(textbox, optionsettings.Tooltip)
        local title = Instance.new('TextLabel')
        title.Size = UDim2.new(1, -10, 0, 20)
        title.Position = UDim2.fromOffset(10, 3)
        title.BackgroundTransparency = 1
        title.Text = optionsettings.Name
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = uipallet.Text
        title.TextSize = 12
        title.FontFace = uipallet.Font
        title.Parent = textbox
        local bkg = Instance.new('Frame')
        bkg.Name = 'BKG'
        bkg.Size = UDim2.new(1, -20, 0, 29)
        bkg.Position = UDim2.fromOffset(10, 23)
        bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        bkg.Parent = textbox
        addCorner(bkg, UDim.new(0, 4))
        local box = Instance.new('TextBox')
        box.Size = UDim2.new(1, -8, 1, 0)
        box.Position = UDim2.fromOffset(8, 0)
        box.BackgroundTransparency = 1
        box.Text = optionsettings.Default or ''
        box.PlaceholderText = optionsettings.Placeholder or 'Click to set'
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextColor3 = color.Dark(uipallet.Text, 0.16)
        box.PlaceholderColor3 = color.Dark(uipallet.Text, 0.31)
        box.TextSize = 12
        box.FontFace = uipallet.Font
        box.ClearTextOnFocus = false
        box.Parent = bkg
        optionsettings.Function = optionsettings.Function or function() end
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {Value = self.Value}
        end
        
        function optionapi:Load(tab)
            if self.Value ~= tab.Value then
                self:SetValue(tab.Value)
            end
        end
        
        function optionapi:SetValue(val, enter)
            self.Value = val
            box.Text = val
            optionsettings.Function(enter)
        end
        
        textbox.MouseButton1Click:Connect(function()
            box:CaptureFocus()
        end)
        box.FocusLost:Connect(function(enter)
            optionapi:SetValue(box.Text, enter)
        end)
        box:GetPropertyChangedSignal('Text'):Connect(function()
            optionapi:SetValue(box.Text)
        end)
        
        optionapi.Object = textbox
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    Toggle = function(optionsettings, children, api)
        local optionapi = {
            Type = 'Toggle',
            Enabled = false,
            Index = getTableSize(api.Options)
        }
        
        local hovered = false
        local toggle = Instance.new('TextButton')
        toggle.Name = optionsettings.Name..'Toggle'
        toggle.Size = UDim2.new(1, 0, 0, 30)
        toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        toggle.BorderSizePixel = 0
        toggle.AutoButtonColor = false
        toggle.Visible = optionsettings.Visible == nil or optionsettings.Visible
        toggle.Text = '          '..optionsettings.Name
        toggle.TextXAlignment = Enum.TextXAlignment.Left
        toggle.TextColor3 = color.Dark(uipallet.Text, 0.16)
        toggle.TextSize = 14
        toggle.FontFace = uipallet.Font
        toggle.Parent = children
        addTooltip(toggle, optionsettings.Tooltip)
        local knobholder = Instance.new('Frame')
        knobholder.Name = 'Knob'
        knobholder.Size = UDim2.fromOffset(22, 12)
        knobholder.Position = UDim2.new(1, -30, 0, 9)
        knobholder.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
        knobholder.Parent = toggle
        addCorner(knobholder, UDim.new(1, 0))
        local knob = knobholder:Clone()
        knob.Size = UDim2.fromOffset(8, 8)
        knob.Position = UDim2.fromOffset(2, 2)
        knob.BackgroundColor3 = uipallet.Main
        knob.Parent = knobholder
        optionsettings.Function = optionsettings.Function or function() end
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {Enabled = self.Enabled}
        end
        
        function optionapi:Load(tab)
            if self.Enabled ~= tab.Enabled then
                self:Toggle()
            end
        end
        
        function optionapi:Color(hue, sat, val, rainbowcheck)
            if self.Enabled then
                tween:Cancel(knobholder)
                knobholder.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
            end
        end
        
        function optionapi:Toggle()
            self.Enabled = not self.Enabled
            local rainbowcheck = mainapi.GUIColor.Rainbow and mainapi.RainbowMode.Value ~= 'Retro'
            tween:Tween(knobholder, uipallet.Tween, {
                BackgroundColor3 = self.Enabled and (rainbowcheck and Color3.fromHSV(mainapi:Color((mainapi.GUIColor.Hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)) or (hovered and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
            })
            tween:Tween(knob, uipallet.Tween, {
                Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
            })
            optionsettings.Function(self.Enabled)
        end
        
        toggle.MouseEnter:Connect(function()
            hovered = true
            if not optionapi.Enabled then
                tween:Tween(knobholder, uipallet.Tween, {
                    BackgroundColor3 = color.Light(uipallet.Main, 0.37)
                })
            end
        end)
        toggle.MouseLeave:Connect(function()
            hovered = false
            if not optionapi.Enabled then
                tween:Tween(knobholder, uipallet.Tween, {
                    BackgroundColor3 = color.Light(uipallet.Main, 0.14)
                })
            end
        end)
        toggle.MouseButton1Click:Connect(function()
            optionapi:Toggle()
        end)
        
        if optionsettings.Default then
            optionapi:Toggle()
        end
        optionapi.Object = toggle
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    TwoSlider = function(optionsettings, children, api)
        local optionapi = {
            Type = 'TwoSlider',
            ValueMin = optionsettings.DefaultMin or optionsettings.Min,
            ValueMax = optionsettings.DefaultMax or 10,
            Max = optionsettings.Max,
            Index = getTableSize(api.Options)
        }
        
        local slider = Instance.new('TextButton')
        slider.Name = optionsettings.Name..'Slider'
        slider.Size = UDim2.new(1, 0, 0, 50)
        slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
        slider.BorderSizePixel = 0
        slider.AutoButtonColor = false
        slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
        slider.Text = ''
        slider.Parent = children
        addTooltip(slider, optionsettings.Tooltip)
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
        local valuebutton = Instance.new('TextButton')
        valuebutton.Name = 'Value'
        valuebutton.Size = UDim2.fromOffset(60, 15)
        valuebutton.Position = UDim2.new(1, -69, 0, 9)
        valuebutton.BackgroundTransparency = 1
        valuebutton.Text = optionapi.ValueMax
        valuebutton.TextXAlignment = Enum.TextXAlignment.Right
        valuebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
        valuebutton.TextSize = 11
        valuebutton.FontFace = uipallet.Font
        valuebutton.Parent = slider
        local valuebutton2 = valuebutton:Clone()
        valuebutton2.Position = UDim2.new(1, -125, 0, 9)
        valuebutton2.Text = optionapi.ValueMin
        valuebutton2.Parent = slider
        local valuebox = Instance.new('TextBox')
        valuebox.Name = 'Box'
        valuebox.Size = valuebutton.Size
        valuebox.Position = valuebutton.Position
        valuebox.BackgroundTransparency = 1
        valuebox.Visible = false
        valuebox.Text = optionapi.ValueMin
        valuebox.TextXAlignment = Enum.TextXAlignment.Right
        valuebox.TextColor3 = color.Dark(uipallet.Text, 0.16)
        valuebox.TextSize = 11
        valuebox.FontFace = uipallet.Font
        valuebox.ClearTextOnFocus = false
        valuebox.Parent = slider
        local valuebox2 = valuebox:Clone()
        valuebox2.Position = valuebutton2.Position
        valuebox2.Parent = slider
        local bkg = Instance.new('Frame')
        bkg.Name = 'Slider'
        bkg.Size = UDim2.new(1, -20, 0, 2)
        bkg.Position = UDim2.fromOffset(10, 37)
        bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
        bkg.BorderSizePixel = 0
        bkg.Parent = slider
        local fill = bkg:Clone()
        fill.Name = 'Fill'
        fill.Position = UDim2.fromScale(math.clamp(optionapi.ValueMin / optionsettings.Max, 0.04, 0.96), 0)
        fill.Size = UDim2.fromScale(math.clamp(math.clamp(optionapi.ValueMax / optionsettings.Max, 0, 1), 0.04, 0.96) - fill.Position.X.Scale, 1)
        fill.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        fill.Parent = bkg
        local knobholder = Instance.new('Frame')
        knobholder.Name = 'Knob'
        knobholder.Size = UDim2.fromOffset(16, 4)
        knobholder.Position = UDim2.fromScale(0, 0.5)
        knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
        knobholder.BackgroundColor3 = slider.BackgroundColor3
        knobholder.BorderSizePixel = 0
        knobholder.Parent = fill
        local knob = Instance.new('ImageLabel')
        knob.Name = 'Knob'
        knob.Size = UDim2.fromOffset(9, 16)
        knob.Position = UDim2.fromScale(0.5, 0.5)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundTransparency = 1
        knob.Image = 'rbxassetid://14368347435'
        knob.ImageColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        knob.Parent = knobholder
        local knobholdermax = knobholder:Clone()
        knobholdermax.Name = 'KnobMax'
        knobholdermax.Position = UDim2.fromScale(1, 0.5)
        knobholdermax.Parent = fill
        knobholdermax.Knob.Rotation = 180
        local arrow = Instance.new('ImageLabel')
        arrow.Name = 'Arrow'
        arrow.Size = UDim2.fromOffset(12, 6)
        arrow.Position = UDim2.new(1, -56, 0, 10)
        arrow.BackgroundTransparency = 1
        arrow.Image = 'rbxassetid://14368348640'
        arrow.ImageColor3 = color.Light(uipallet.Main, 0.14)
        arrow.Parent = slider
        optionsettings.Function = optionsettings.Function or function() end
        optionsettings.Decimal = optionsettings.Decimal or 1
        local random = Random.new()
        
        function optionapi:Save(tab)
            tab[optionsettings.Name] = {ValueMin = self.ValueMin, ValueMax = self.ValueMax}
        end
        
        function optionapi:Load(tab)
            if self.ValueMin ~= tab.ValueMin then
                self:SetValue(false, tab.ValueMin)
            end
            if self.ValueMax ~= tab.ValueMax then
                self:SetValue(true, tab.ValueMax)
            end
        end
        
        function optionapi:Color(hue, sat, val, rainbowcheck)
            fill.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
            knob.ImageColor3 = fill.BackgroundColor3
            knobholdermax.Knob.ImageColor3 = fill.BackgroundColor3
        end
        
        function optionapi:GetRandomValue()
            return random:NextNumber(optionapi.ValueMin, optionapi.ValueMax)
        end
        
        function optionapi:SetValue(max, value)
            if tonumber(value) == math.huge or value ~= value then return end
            self[max and 'ValueMax' or 'ValueMin'] = value
            valuebutton.Text = self.ValueMax
            valuebutton2.Text = self.ValueMin
            local size = math.clamp(math.clamp(self.ValueMin / optionsettings.Max, 0, 1), 0.04, 0.96)
            tween:Tween(fill, TweenInfo.new(0.1), {
                Position = UDim2.fromScale(size, 0),
                Size = UDim2.fromScale(math.clamp(math.clamp(math.clamp(self.ValueMax / optionsettings.Max, 0.04, 0.96), 0.04, 0.96) - size, 0, 1), 1)
            })
        end
        
        knobholder.MouseEnter:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(11, 18)
            })
        end)
        knobholder.MouseLeave:Connect(function()
            tween:Tween(knob, uipallet.Tween, {
                Size = UDim2.fromOffset(9, 16)
            })
        end)
        knobholdermax.MouseEnter:Connect(function()
            tween:Tween(knobholdermax.Knob, uipallet.Tween, {
                Size = UDim2.fromOffset(11, 18)
            })
        end)
        knobholdermax.MouseLeave:Connect(function()
            tween:Tween(knobholdermax.Knob, uipallet.Tween, {
                Size = UDim2.fromOffset(9, 16)
            })
        end)
        slider.InputBegan:Connect(function(inputObj)
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
            then
                local maxCheck = (inputObj.Position.X - knobholdermax.AbsolutePosition.X) > -10
                local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
                optionapi:SetValue(maxCheck, math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
        
                local changed = inputService.InputChanged:Connect(function(input)
                    if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                        local newPosition = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
                        optionapi:SetValue(maxCheck, math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
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
        valuebutton.MouseButton1Click:Connect(function()
            valuebutton.Visible = false
            valuebox.Visible = true
            valuebox.Text = optionapi.ValueMax
            valuebox:CaptureFocus()
        end)
        valuebutton2.MouseButton1Click:Connect(function()
            valuebutton2.Visible = false
            valuebox2.Visible = true
            valuebox2.Text = optionapi.ValueMin
            valuebox2:CaptureFocus()
        end)
        valuebox.FocusLost:Connect(function(enter)
            valuebutton.Visible = true
            valuebox.Visible = false
            if enter and tonumber(valuebox.Text) then
                optionapi:SetValue(true, tonumber(valuebox.Text))
            end
        end)
        valuebox2.FocusLost:Connect(function(enter)
            valuebutton2.Visible = true
            valuebox2.Visible = false
            if enter and tonumber(valuebox2.Text) then
                optionapi:SetValue(false, tonumber(valuebox2.Text))
            end
        end)
        
        optionapi.Object = slider
        api.Options[optionsettings.Name] = optionapi
        
        return optionapi
    end,
    Divider = function(children, text)
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
}

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

-- FIXED: Create the main window directly without extra wrapper
function mainapi:InitializeUI()
    local categoryapi = {
        Type = 'MainWindow',
        Buttons = {},
        Options = {}
    }

    -- Create the main window directly
    local window = Instance.new('TextButton')
    window.Name = 'MainWindow'
    window.Size = UDim2.fromOffset(490, 400) -- Wider to accommodate categories side by side
    window.Position = UDim2.new(0.5, -245, 0.5, -200) -- Centered
    window.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
    window.AutoButtonColor = false
    window.Text = ''
    window.Parent = clickgui
    addBlur(window)
    addCorner(window)
    
    -- Make window draggable
    local function makeDraggable(gui, window)
        gui.InputBegan:Connect(function(inputObj)
            if window and not window.Visible then return end
            if
                (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
                and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40)
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
    
    -- Logo
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
    
    -- Tab bar (horizontal layout)
    local tabbar = Instance.new('Frame')
    tabbar.Name = 'TabBar'
    tabbar.Size = UDim2.new(1, 0, 0, 37)
    tabbar.Position = UDim2.fromOffset(0, 0)
    tabbar.BackgroundColor3 = uipallet.Main
    tabbar.BorderSizePixel = 0
    tabbar.Parent = window
    
    local tablayout = Instance.new('UIListLayout')
    tablayout.FillDirection = Enum.FillDirection.Horizontal
    tablayout.Padding = UDim.new(0, 0)
    tablayout.Parent = tabbar
    
    -- Content area
    local contentArea = Instance.new('Frame')
    contentArea.Name = 'ContentArea'
    contentArea.Size = UDim2.new(1, 0, 1, -37)
    contentArea.Position = UDim2.fromOffset(0, 37)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = window
    
    categoryapi.Object = window
    
    -- Store categories
    local categories = {}
    
    -- Function to create a category pane
    function categoryapi:CreateCategory(categoryData)
        local categoryObj = {
            Type = 'Category',
            Expanded = true, -- Always expanded
            Buttons = {},
            Modules = {},
            Options = {}
        }
        
        -- Create category button
        local button = Instance.new('TextButton')
        button.Name = categoryData.Name..'Button'
        button.Size = UDim2.fromOffset(120, 37)
        button.BackgroundColor3 = uipallet.Main
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = categoryData.Name
        button.TextColor3 = color.Dark(uipallet.Text, 0.16)
        button.TextSize = 14
        button.FontFace = uipallet.Font
        button.Parent = tabbar
        
        -- Create category panel
        local panel = Instance.new('ScrollingFrame')
        panel.Name = categoryData.Name..'Panel'
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel = 0
        panel.ScrollBarThickness = 2
        panel.ScrollBarImageTransparency = 0.75
        panel.CanvasSize = UDim2.new()
        panel.Visible = false
        panel.Parent = contentArea
        
        local panelLayout = Instance.new('UIListLayout')
        panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
        panelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        panelLayout.Padding = UDim.new(0, 5)
        panelLayout.Parent = panel
        
        -- Make panel content resizable
        panelLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            panel.CanvasSize = UDim2.fromOffset(0, panelLayout.AbsoluteContentSize.Y)
        end)
        
        categoryObj.Object = panel
        categoryObj.Button = button
        categories[categoryData.Name] = categoryObj
        
        -- Create module creation function
        function categoryObj:CreateModule(moduleSettings)
            -- Remove existing module if exists
            mainapi:Remove(moduleSettings.Name)
            
            local moduleapi = {
                Enabled = false,
                Options = {},
                Bind = {},
                Index = getTableSize(mainapi.Modules),
                ExtraText = moduleSettings.ExtraText,
                Name = moduleSettings.Name,
                Category = categoryData.Name
            }
            
            local hovered = false
            local modulebutton = Instance.new('TextButton')
            modulebutton.Name = moduleSettings.Name
            modulebutton.Size = UDim2.fromOffset(440, 40)
            modulebutton.BackgroundColor3 = uipallet.Main
            modulebutton.BorderSizePixel = 0
            modulebutton.AutoButtonColor = false
            modulebutton.Text = '            '..moduleSettings.Name
            modulebutton.TextXAlignment = Enum.TextXAlignment.Left
            modulebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
            modulebutton.TextSize = 14
            modulebutton.FontFace = uipallet.Font
            modulebutton.Parent = panel
            
            local gradient = Instance.new('UIGradient')
            gradient.Rotation = 90
            gradient.Enabled = false
            gradient.Parent = modulebutton
            
            local modulechildren = Instance.new('Frame')
            local bind = Instance.new('TextButton')
            addTooltip(modulebutton, moduleSettings.Tooltip)
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
            
            modulechildren.Name = moduleSettings.Name..'Children'
            modulechildren.Size = UDim2.new(1, 0, 0, 0)
            modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
            modulechildren.BorderSizePixel = 0
            modulechildren.Visible = false
            modulechildren.Parent = panel
            
            local childrenLayout = Instance.new('UIListLayout')
            childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder
            childrenLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            childrenLayout.Parent = modulechildren
            
            local divider = Instance.new('Frame')
            divider.Name = 'Divider'
            divider.Size = UDim2.new(1, 0, 0, 1)
            divider.Position = UDim2.new(0, 0, 1, -1)
            divider.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19)
            divider.BackgroundTransparency = 0.52
            divider.BorderSizePixel = 0
            divider.Visible = false
            divider.Parent = modulebutton
            
            moduleSettings.Function = moduleSettings.Function or function() end
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
                task.spawn(moduleSettings.Function, self.Enabled)
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
            
            childrenLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                if mainapi.ThreadFix then
                    setthreadidentity(8)
                end
                modulechildren.Size = UDim2.new(1, 0, 0, childrenLayout.AbsoluteContentSize.Y)
            end)
            
            moduleapi.Object = modulebutton
            mainapi.Modules[moduleSettings.Name] = moduleapi
            
            return moduleapi
        end
        
        return categoryObj
    end
    
    -- Add divider helper
    function categoryapi:CreateDivider(text)
        -- Find the currently visible panel
        for _, panel in pairs(categories) do
            if panel.Object.Visible then
                return components.Divider(panel.Object, text)
            end
        end
        -- Fallback to first panel
        local firstPanel = next(categories)
        if firstPanel then
            return components.Divider(categories[firstPanel].Object, text)
        end
    end
    
    -- Tab switching
    local activeCategory = nil
    for name, category in pairs(categories) do
        category.Button.MouseButton1Click:Connect(function()
            if activeCategory == category then return end
            if activeCategory then
                activeCategory.Object.Visible = false
                activeCategory.Button.TextColor3 = color.Dark(uipallet.Text, 0.16)
                activeCategory.Button.BackgroundColor3 = uipallet.Main
            end
            activeCategory = category
            category.Object.Visible = true
            category.Button.TextColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
            category.Button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        end)
    end
    
    -- Refresh panel sizes
    for _, panel in pairs(categories) do
        local layout = panel.Object:FindFirstChildWhichIsA('UIListLayout')
        if layout then
            layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                panel.Object.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
            end)
        end
    end
    
    -- Window resizing
    local mainLayout = contentArea:FindFirstChildWhichIsA('UIListLayout')
    if not mainLayout then
        -- No need, we handle individual panels
    end
    
    window.Size = UDim2.fromOffset(490, 500)
    
    -- Create default categories
    local combatCategory = categoryapi:CreateCategory({Name = 'Combat'})
    local movementCategory = categoryapi:CreateCategory({Name = 'Movement'})
    local visualCategory = categoryapi:CreateCategory({Name = 'Visual'})
    local worldCategory = categoryapi:CreateCategory({Name = 'World'})
    local settingsCategory = categoryapi:CreateCategory({Name = 'Settings'})
    
    -- Activate first category
    if categories['Combat'] then
        activeCategory = categories['Combat']
        activeCategory.Object.Visible = true
        activeCategory.Button.TextColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
        activeCategory.Button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
    end
    
    return categoryapi
end

-- Create the UI structure
local mainWindow = mainapi:InitializeUI()

-- Add GUI settings to Settings tab
local settingsCategory = mainapi.Categories['Settings']
if settingsCategory then
    local guiSettingsModule = settingsCategory:CreateModule({Name = 'GUI Settings'})
    
    mainapi.Blur = guiSettingsModule:CreateToggle({
        Name = 'Blur background',
        Function = function()
            mainapi:BlurCheck()
        end,
        Default = true,
        Tooltip = 'Blur the background of the GUI'
    })
    
    local scaleslider = {Object = {}, Value = 1}
    mainapi.Scale = guiSettingsModule:CreateToggle({
        Name = 'Auto rescale',
        Default = true,
        Function = function(callback)
            scaleslider.Object.Visible = not callback
            if callback then
                scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
            else
                scale.Scale = scaleslider.Value
            end
        end,
        Tooltip = 'Automatically rescales the gui using the screens resolution'
    })
    
    scaleslider = guiSettingsModule:CreateSlider({
        Name = 'Scale',
        Min = 0.1,
        Max = 2,
        Decimal = 10,
        Function = function(val, final)
            if final and not mainapi.Scale.Enabled then
                scale.Scale = val
            end
        end,
        Default = 1,
        Darker = true,
        Visible = false
    })
    
    mainapi.RainbowMode = guiSettingsModule:CreateDropdown({
        Name = 'Rainbow Mode',
        List = {'Normal', 'Gradient', 'Retro'},
        Tooltip = 'Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color'
    })
    
    mainapi.RainbowSpeed = guiSettingsModule:CreateSlider({
        Name = 'Rainbow speed',
        Min = 0.1,
        Max = 10,
        Decimal = 10,
        Default = 1,
        Tooltip = 'Adjusts the speed of rainbow values'
    })
    
    mainapi.RainbowUpdateSpeed = guiSettingsModule:CreateSlider({
        Name = 'Rainbow update rate',
        Min = 1,
        Max = 144,
        Default = 60,
        Tooltip = 'Adjusts the update rate of rainbow values',
        Suffix = 'hz'
    })
    
    mainapi.GUIColor = guiSettingsModule:CreateColorSlider({
        Name = 'GUI Theme',
        DefaultHue = 0.46,
        DefaultSat = 0.96,
        DefaultValue = 0.52,
        Function = function(h, s, v)
            mainapi:UpdateGUI(h, s, v, true)
        end
    })
end

-- Create Legit GUI
mainapi:CreateLegit()

-- Keybind handling
local function checkGlobalKeybind()
    local keysPressed = {}
    for _, key in inputService:GetKeysPressed() do
        table.insert(keysPressed, key.Name)
    end
    if checkKeybinds(keysPressed, mainapi.Keybind) then
        for _, v in mainapi.Windows do
            v.Visible = false
        end
        clickgui.Visible = not clickgui.Visible
        tooltip.Visible = false
        mainapi:BlurCheck()
    end
end

inputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    task.wait()
    checkGlobalKeybind()
end)

gui.ResetOnSpawn = false

-- Make menu visible by default or bind
clickgui.Visible = true
mainapi:Load()

return mainapi
