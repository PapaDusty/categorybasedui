--[[
    VapeV4 Style UI Library
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

-- GUI Creation
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
clickgui.Visible = true -- Make visible by default
clickgui.Parent = scaledgui

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

scale = Instance.new('UIScale')
scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

-- Store categories with their positions
local categoryPositions = {}

function mainapi:SortCategories()
    local categories = {}
    for name, cat in pairs(mainapi.Categories) do
        if cat.Type == 'Category' and cat.Object then
            table.insert(categories, {name = name, obj = cat})
        end
    end
    
    -- Sort by name
    table.sort(categories, function(a, b)
        return a.name < b.name
    end)
    
    -- Position them
    local xOffset = 6
    local yOffset = 60
    for i, cat in ipairs(categories) do
        cat.obj.Object.Position = UDim2.fromOffset(xOffset, yOffset)
        xOffset = xOffset + 230
        -- Reset position if going off screen (every 8 categories)
        if xOffset > 1840 then
            xOffset = 6
            yOffset = yOffset + 420
        end
    end
end

-- Create the components table first
local components = {}

-- TargetsButton component
components.TargetsButton = function(optionsettings, children, api)
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
end

-- Targets component
components.Targets = function(optionsettings, children, api)
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
end

-- TextList component
components.TextList = function(optionsettings, children, api)
    local optionapi = {
        Type = 'TextList',
        List = optionsettings.Default or {},
        ListEnabled = optionsettings.Default or {},
        Objects = {},
        Window = {Visible = false},
        Index = getTableSize(api.Options)
    }
    optionsettings.Color = optionsettings.Color or Color3.fromRGB(5, 134, 105)
    
    local textlist = Instance.new('TextButton')
    textlist.Name = optionsettings.Name..'TextList'
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
    local buttonicon = Instance.new('ImageLabel')
    buttonicon.Name = 'Icon'
    buttonicon.Size = UDim2.fromOffset(14, 12)
    buttonicon.Position = UDim2.fromOffset(10, 14)
    buttonicon.BackgroundTransparency = 1
    buttonicon.Image = optionsettings.Icon or 'rbxassetid://14368302000'
    buttonicon.Parent = button
    local buttontitle = Instance.new('TextLabel')
    buttontitle.Name = 'Title'
    buttontitle.Size = UDim2.new(1, -35, 0, 15)
    buttontitle.Position = UDim2.fromOffset(35, 6)
    buttontitle.BackgroundTransparency = 1
    buttontitle.Text = optionsettings.Name
    buttontitle.TextXAlignment = Enum.TextXAlignment.Left
    buttontitle.TextColor3 = color.Dark(uipallet.Text, 0.16)
    buttontitle.TextSize = 15
    buttontitle.TextTruncate = Enum.TextTruncate.AtEnd
    buttontitle.FontFace = uipallet.Font
    buttontitle.Parent = button
    local amount = buttontitle:Clone()
    amount.Name = 'Amount'
    amount.Size = UDim2.new(1, -13, 0, 15)
    amount.Position = UDim2.fromOffset(0, 6)
    amount.Text = '0'
    amount.TextXAlignment = Enum.TextXAlignment.Right
    amount.Parent = button
    local items = buttontitle:Clone()
    items.Name = 'Items'
    items.Position = UDim2.fromOffset(35, 21)
    items.Text = 'None'
    items.TextColor3 = color.Dark(uipallet.Text, 0.43)
    items.TextSize = 11
    items.Parent = button
    addCorner(button, UDim.new(0, 4))
    local window = Instance.new('TextButton')
    window.Name = optionsettings.Name..'TextWindow'
    window.Size = UDim2.fromOffset(220, 85)
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
    icon.Size = optionsettings.TabSize or UDim2.fromOffset(19, 16)
    icon.Position = UDim2.fromOffset(10, 13)
    icon.BackgroundTransparency = 1
    icon.Image = optionsettings.Tab or 'rbxassetid://14368302875'
    icon.Parent = window
    local title = Instance.new('TextLabel')
    title.Name = 'Title'
    title.Size = UDim2.new(1, -36, 0, 20)
    title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 11)
    title.BackgroundTransparency = 1
    title.Text = optionsettings.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = uipallet.Text
    title.TextSize = 13
    title.FontFace = uipallet.Font
    title.Parent = window
    local close = addCloseButton(window)
    local addbkg = Instance.new('Frame')
    addbkg.Name = 'Add'
    addbkg.Size = UDim2.fromOffset(200, 31)
    addbkg.Position = UDim2.fromOffset(10, 45)
    addbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
    addbkg.Parent = window
    addCorner(addbkg)
    local addbox = addbkg:Clone()
    addbox.Size = UDim2.new(1, -2, 1, -2)
    addbox.Position = UDim2.fromOffset(1, 1)
    addbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
    addbox.Parent = addbkg
    local addvalue = Instance.new('TextBox')
    addvalue.Size = UDim2.new(1, -35, 1, 0)
    addvalue.Position = UDim2.fromOffset(10, 0)
    addvalue.BackgroundTransparency = 1
    addvalue.Text = ''
    addvalue.PlaceholderText = optionsettings.Placeholder or 'Add entry...'
    addvalue.TextXAlignment = Enum.TextXAlignment.Left
    addvalue.TextColor3 = Color3.new(1, 1, 1)
    addvalue.TextSize = 15
    addvalue.FontFace = uipallet.Font
    addvalue.ClearTextOnFocus = false
    addvalue.Parent = addbkg
    local addbutton = Instance.new('ImageButton')
    addbutton.Name = 'AddButton'
    addbutton.Size = UDim2.fromOffset(16, 16)
    addbutton.Position = UDim2.new(1, -26, 0, 8)
    addbutton.BackgroundTransparency = 1
    addbutton.Image = 'rbxassetid://14368300605'
    addbutton.ImageColor3 = optionsettings.Color
    addbutton.ImageTransparency = 0.3
    addbutton.Parent = addbkg
    optionsettings.Function = optionsettings.Function or function() end
    
    function optionapi:Save(tab)
        tab[optionsettings.Name] = {
            List = self.List,
            ListEnabled = self.ListEnabled
        }
    end
    
    function optionapi:Load(tab)
        self.List = tab.List or {}
        self.ListEnabled = tab.ListEnabled or {}
        self:ChangeValue()
    end
    
    function optionapi:Color(hue, sat, val, rainbowcheck)
        if window.Visible then
            bkg.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
        end
    end
    
    function optionapi:ChangeValue(val)
        if val then
            local ind = table.find(self.List, val)
            if ind then
                table.remove(self.List, ind)
                ind = table.find(self.ListEnabled, val)
                if ind then
                    table.remove(self.ListEnabled, ind)
                end
            else
                table.insert(self.List, val)
                table.insert(self.ListEnabled, val)
            end
        end
    
        optionsettings.Function(self.List)
        for _, v in self.Objects do
            v:Destroy()
        end
        table.clear(self.Objects)
        window.Size = UDim2.fromOffset(220, 85 + (#self.List * 35))
        amount.Text = #self.List
    
        local enabledtext = 'None'
        for i, v in self.ListEnabled do
            if i == 1 then enabledtext = '' end
            enabledtext = enabledtext..(i == 1 and v or ', '..v)
        end
        items.Text = enabledtext
    
        for i, v in self.List do
            local enabled = table.find(self.ListEnabled, v)
            local object = Instance.new('TextButton')
            object.Name = v
            object.Size = UDim2.fromOffset(200, 32)
            object.Position = UDim2.fromOffset(10, 47 + (i * 35))
            object.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
            object.AutoButtonColor = false
            object.Text = ''
            object.Parent = window
            addCorner(object)
            local objectbkg = Instance.new('Frame')
            objectbkg.Name = 'BKG'
            objectbkg.Size = UDim2.new(1, -2, 1, -2)
            objectbkg.Position = UDim2.fromOffset(1, 1)
            objectbkg.BackgroundColor3 = uipallet.Main
            objectbkg.Visible = false
            objectbkg.Parent = object
            addCorner(objectbkg)
            local objectdot = Instance.new('Frame')
            objectdot.Name = 'Dot'
            objectdot.Size = UDim2.fromOffset(10, 11)
            objectdot.Position = UDim2.fromOffset(10, 12)
            objectdot.BackgroundColor3 = enabled and optionsettings.Color or color.Light(uipallet.Main, 0.37)
            objectdot.Parent = object
            addCorner(objectdot, UDim.new(1, 0))
            local objectdotin = objectdot:Clone()
            objectdotin.Size = UDim2.fromOffset(8, 9)
            objectdotin.Position = UDim2.fromOffset(1, 1)
            objectdotin.BackgroundColor3 = enabled and optionsettings.Color or color.Light(uipallet.Main, 0.02)
            objectdotin.Parent = objectdot
            local objecttitle = Instance.new('TextLabel')
            objecttitle.Name = 'Title'
            objecttitle.Size = UDim2.new(1, -30, 1, 0)
            objecttitle.Position = UDim2.fromOffset(30, 0)
            objecttitle.BackgroundTransparency = 1
            objecttitle.Text = v
            objecttitle.TextXAlignment = Enum.TextXAlignment.Left
            objecttitle.TextColor3 = color.Dark(uipallet.Text, 0.16)
            objecttitle.TextSize = 15
            objecttitle.FontFace = uipallet.Font
            objecttitle.Parent = object
            local close = Instance.new('ImageButton')
            close.Name = 'Close'
            close.Size = UDim2.fromOffset(16, 16)
            close.Position = UDim2.new(1, -26, 0, 8)
            close.BackgroundColor3 = Color3.new(1, 1, 1)
            close.BackgroundTransparency = 1
            close.AutoButtonColor = false
            close.Image = 'rbxassetid://14368310467'
            close.ImageColor3 = color.Light(uipallet.Text, 0.2)
            close.ImageTransparency = 0.5
            close.Parent = object
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
            close.MouseButton1Click:Connect(function()
                self:ChangeValue(v)
            end)
            object.MouseEnter:Connect(function()
                objectbkg.Visible = true
            end)
            object.MouseLeave:Connect(function()
                objectbkg.Visible = false
            end)
            object.MouseButton1Click:Connect(function()
                local ind = table.find(self.ListEnabled, v)
                if ind then
                    table.remove(self.ListEnabled, ind)
                    objectdot.BackgroundColor3 = color.Light(uipallet.Main, 0.37)
                    objectdotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
                else
                    table.insert(self.ListEnabled, v)
                    objectdot.BackgroundColor3 = optionsettings.Color
                    objectdotin.BackgroundColor3 = optionsettings.Color
                end
    
                local enabledtext = 'None'
                for i, v in self.ListEnabled do
                    if i == 1 then enabledtext = '' end
                    enabledtext = enabledtext..(i == 1 and v or ', '..v)
                end
    
                items.Text = enabledtext
                optionsettings.Function()
            end)
    
            table.insert(self.Objects, object)
        end
    end
    
    addbutton.MouseEnter:Connect(function()
        addbutton.ImageTransparency = 0
    end)
    addbutton.MouseLeave:Connect(function()
        addbutton.ImageTransparency = 0.3
    end)
    addbutton.MouseButton1Click:Connect(function()
        if not table.find(optionapi.List, addvalue.Text) then
            optionapi:ChangeValue(addvalue.Text)
            addvalue.Text = ''
        end
    end)
    addvalue.FocusLost:Connect(function(enter)
        if enter and not table.find(optionapi.List, addvalue.Text) then
            optionapi:ChangeValue(addvalue.Text)
            addvalue.Text = ''
        end
    end)
    addvalue.MouseEnter:Connect(function()
        tween:Tween(addbkg, uipallet.Tween, {
            BackgroundColor3 = color.Light(uipallet.Main, 0.14)
        })
    end)
    addvalue.MouseLeave:Connect(function()
        tween:Tween(addbkg, uipallet.Tween, {
            BackgroundColor3 = color.Light(uipallet.Main, 0.02)
        })
    end)
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
        local actualPosition = (textlist.AbsolutePosition - (api.Legit and mainapi.Legit.Window.AbsolutePosition or -guiService:GetGuiInset())) / scale.Scale
        window.Position = UDim2.fromOffset(actualPosition.X + 220, actualPosition.Y)
    end)
    
    if optionsettings.Default then
        optionapi:ChangeValue()
    end
    optionapi.Object = textlist
    api.Options[optionsettings.Name] = optionapi
    
    return optionapi
end

-- Button component
components.Button = function(optionsettings, children, api)
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
end

-- ColorSlider component (simplified for brevity - add full version from previous code)
components.ColorSlider = function(optionsettings, children, api)
    local optionapi = {
        Type = 'ColorSlider',
        Hue = optionsettings.DefaultHue or 0.44,
        Sat = optionsettings.DefaultSat or 1,
        Value = optionsettings.DefaultValue or 1,
        Opacity = optionsettings.DefaultOpacity or 1,
        Rainbow = false,
        Index = 0
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
    
    local preview = Instance.new('ImageButton')
    preview.Name = 'Preview'
    preview.Size = UDim2.fromOffset(12, 12)
    preview.Position = UDim2.new(1, -22, 0, 10)
    preview.BackgroundTransparency = 1
    preview.Image = 'rbxassetid://14368311578'
    preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
    preview.ImageTransparency = 1 - optionapi.Opacity
    preview.Parent = slider
    
    function optionapi:SetValue(h, s, v, o)
        self.Hue = h or self.Hue
        self.Sat = s or self.Sat
        self.Value = v or self.Value
        self.Opacity = o or self.Opacity
        preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
        preview.ImageTransparency = 1 - self.Opacity
        optionsettings.Function(self.Hue, self.Sat, self.Value, self.Opacity)
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
        end
    end
    
    optionapi.Object = slider
    api.Options[optionsettings.Name] = optionapi
    
    return optionapi
end

-- Dropdown component
components.Dropdown = function(optionsettings, children, api)
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
    title.TextSize = 13
    title.TextTruncate = Enum.TextTruncate.AtEnd
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
end

-- Slider component
components.Slider = function(optionsettings, children, api)
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
    
    optionsettings.Decimal = optionsettings.Decimal or 1
    
    function optionapi:SetValue(value, pos, final)
        self.Value = value
        tween:Tween(fill, uipallet.Tween, {
            Size = UDim2.fromScale(math.clamp(pos or math.clamp(value / optionsettings.Max, 0, 1), 0.04, 0.96), 1)
        })
        valuebutton.Text = self.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(self.Value) or optionsettings.Suffix) or '')
        optionsettings.Function(value, final)
    end
    
    slider.InputBegan:Connect(function(inputObj)
        if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
            and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale) then
            local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
            optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
            
            local changed = inputService.InputChanged:Connect(function(input)
                if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                    local newPosition = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
                    optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
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
    
    optionapi.Object = slider
    api.Options[optionsettings.Name] = optionapi
    
    return optionapi
end

-- Toggle component
components.Toggle = function(optionsettings, children, api)
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
    
    function optionapi:Toggle()
        self.Enabled = not self.Enabled
        tween:Tween(knobholder, uipallet.Tween, {
            BackgroundColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or (hovered and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
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
end

-- TwoSlider component
components.TwoSlider = function(optionsettings, children, api)
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
    
    local random = Random.new()
    
    function optionapi:GetRandomValue()
        return random:NextNumber(optionapi.ValueMin, optionapi.ValueMax)
    end
    
    function optionapi:SetValue(max, value)
        self[max and 'ValueMax' or 'ValueMin'] = value
        optionsettings.Function()
    end
    
    optionapi.Object = slider
    api.Options[optionsettings.Name] = optionapi
    
    return optionapi
end

-- Divider component
components.Divider = function(children, text)
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

-- Set up metatable for components
mainapi.Components = setmetatable(components, {
    __newindex = function(self, ind, func)
        for _, v in mainapi.Modules do
            rawset(v, 'Create'..ind, function(_, settings)
                return func(settings, v.Children, v)
            end)
        end
        rawset(self, ind, func)
    end
})

-- Category creation function
function mainapi:CreateCategory(categorysettings)
    local categoryapi = {
        Type = 'Category',
        Expanded = true, -- Start expanded
        Modules = {}
    }

    local window = Instance.new('TextButton')
    window.Name = categorysettings.Name..'Category'
    window.Size = UDim2.fromOffset(220, 41)
    window.BackgroundColor3 = uipallet.Main
    window.AutoButtonColor = false
    window.Visible = true -- Make visible
    window.Text = ''
    window.Parent = clickgui
    addBlur(window)
    addCorner(window)
    
    -- Make draggable
    window.InputBegan:Connect(function(inputObj)
        if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
            and (inputObj.Position.Y - window.AbsolutePosition.Y < 40) then
            local dragPosition = Vector2.new(
                window.AbsolutePosition.X - inputObj.Position.X,
                window.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
            ) / scale.Scale

            local changed = inputService.InputChanged:Connect(function(input)
                if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                    window.Position = UDim2.fromOffset((input.Position.X / scale.Scale) + dragPosition.X, (input.Position.Y / scale.Scale) + dragPosition.Y)
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
    arrow.Rotation = 0 -- Pointing up when expanded
    arrow.Parent = arrowbutton
    
    local children = Instance.new('ScrollingFrame')
    children.Name = 'Children'
    children.Size = UDim2.new(1, 0, 1, -41)
    children.Position = UDim2.fromOffset(0, 37)
    children.BackgroundTransparency = 1
    children.BorderSizePixel = 0
    children.Visible = true -- Start visible
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
    divider.Visible = true
    divider.Parent = window
    
    local windowlist = Instance.new('UIListLayout')
    windowlist.SortOrder = Enum.SortOrder.LayoutOrder
    windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    windowlist.Parent = children

    function categoryapi:CreateModule(modulesettings)
        local moduleapi = {
            Enabled = false,
            Options = {},
            Bind = {},
            Index = getTableSize(mainapi.Modules),
            ExtraText = modulesettings.ExtraText,
            Name = modulesettings.Name,
            Category = categorysettings.Name
        }

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
        addTooltip(modulebutton, modulesettings.Tooltip)
        
        local modulechildren = Instance.new('Frame')
        modulechildren.Name = modulesettings.Name..'Children'
        modulechildren.Size = UDim2.new(1, 0, 0, 0)
        modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
        modulechildren.BorderSizePixel = 0
        modulechildren.Visible = false
        modulechildren.Parent = children
        moduleapi.Children = modulechildren
        
        local childlist = Instance.new('UIListLayout')
        childlist.SortOrder = Enum.SortOrder.LayoutOrder
        childlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        childlist.Parent = modulechildren
        
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
        
        modulesettings.Function = modulesettings.Function or function() end
        addMaid(moduleapi)
        
        function moduleapi:Toggle()
            moduleapi.Enabled = not moduleapi.Enabled
            modulebutton.TextColor3 = moduleapi.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Dark(uipallet.Text, 0.16)
            modulebutton.BackgroundColor3 = moduleapi.Enabled and color.Light(uipallet.Main, 0.02) or uipallet.Main
            if not moduleapi.Enabled then
                for _, v in moduleapi.Connections do
                    v:Disconnect()
                end
                table.clear(moduleapi.Connections)
            end
            task.spawn(modulesettings.Function, moduleapi.Enabled)
        end
        
        for i, v in components do
            moduleapi['Create'..i] = function(_, optionsettings)
                return v(optionsettings, modulechildren, moduleapi)
            end
        end
        
        dotsbutton.MouseButton1Click:Connect(function()
            modulechildren.Visible = not modulechildren.Visible
        end)
        modulebutton.MouseButton1Click:Connect(function()
            moduleapi:Toggle()
        end)
        modulebutton.MouseButton2Click:Connect(function()
            modulechildren.Visible = not modulechildren.Visible
        end)
        
        moduleapi.Object = modulebutton
        mainapi.Modules[modulesettings.Name] = moduleapi
        
        childlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            modulechildren.Size = UDim2.new(1, 0, 0, childlist.AbsoluteContentSize.Y / scale.Scale)
        end)
        
        return moduleapi
    end
    
    function categoryapi:Expand()
        children.Visible = not children.Visible
        arrow.Rotation = children.Visible and 0 or 180
        window.Size = UDim2.fromOffset(220, children.Visible and math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601) or 41)
        divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
    end
    
    arrowbutton.MouseButton1Click:Connect(function()
        categoryapi:Expand()
    end)
    
    windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
        if children.Visible then
            window.Size = UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
        end
    end)
    
    categoryapi.Object = window
    mainapi.Categories[categorysettings.Name] = categoryapi
    
    return categoryapi
end

-- Add settings category
function mainapi:AddSettingsCategory()
    local settingsCat = self:CreateCategory({
        Name = "Settings",
        Icon = "rbxassetid://14368318994",
        Size = UDim2.fromOffset(14, 14)
    })
    return settingsCat
end

-- Load function
function mainapi:Load()
    self.Keybind = {'RightShift'}
    self.Loaded = true
    
    -- Sort categories after creation
    self:SortCategories()
    
    -- Setup keybind for GUI
    inputService.InputBegan:Connect(function(inputObj)
        if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
            table.insert(self.HeldKeybinds, inputObj.KeyCode.Name)
            if checkKeybinds(self.HeldKeybinds, self.Keybind, inputObj.KeyCode.Name) then
                clickgui.Visible = not clickgui.Visible
                tooltip.Visible = false
            end
        end
    end)
    
    inputService.InputEnded:Connect(function(inputObj)
        local ind = table.find(self.HeldKeybinds, inputObj.KeyCode.Name)
        if ind then
            table.remove(self.HeldKeybinds, ind)
        end
    end)
end

-- Clean up function
function mainapi:Clean(callback)
    if not self.Connections then
        self.Connections = {}
    end
    table.insert(self.Connections, callback)
end

-- Update text GUI (placeholder)
function mainapi:UpdateTextGUI() end

-- Update main GUI colors
function mainapi:UpdateGUI(hue, sat, val, default)
    if not self.Loaded then return end
    
    for _, cat in pairs(self.Categories) do
        if cat.Object then
            for _, module in pairs(mainapi.Modules) do
                if module.Enabled and module.Object then
                    module.Object.TextColor3 = Color3.fromHSV(hue, sat, val)
                end
            end
        end
    end
end

-- Initialize
mainapi:Load()

return mainapi
