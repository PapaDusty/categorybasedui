--[[
    UI Library by YourName
    GitHub: [PLACEHOLDER] -- Replace [PLACEHOLDER] with your raw GitHub link
--]]

local UI = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Global state
local activeColorFrame = {}
local allTextObjects = {}
local currentColorMode = "Default"
local currentFont = "GothamMedium"
local accentColor = Color3.fromRGB(150, 0, 255) -- default purple
local heartbeatConnection

-- Helper to round corners
local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

-- Register text object for font updates
local function registerText(obj)
    table.insert(allTextObjects, obj)
end

local function updateFonts()
    for _, obj in ipairs(allTextObjects) do
        obj.FontFace = Font.new(currentFont)
    end
end

-- Color animation
local function startColorAnimation()
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if currentColorMode == "Breathing" then
            local factor = (math.sin(tick() * 2) + 1) / 2
            accentColor = Color3.fromRGB(100, 0, 180):Lerp(Color3.fromRGB(200, 0, 255), factor)
        elseif currentColorMode == "Rainbow" then
            local hue = (tick() * 0.3) % 1
            accentColor = Color3.fromHSV(hue, 1, 1)
        else -- Default
            accentColor = Color3.fromRGB(150, 0, 255)
        end
        for _, frame in pairs(activeColorFrame) do
            frame.BackgroundColor3 = accentColor
        end
    end)
end

local function stopColorAnimation()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

-- UI Element builders
local function createToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerText(label)

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(0.7, 0, 0.5, -10)
    toggleButton.BackgroundColor3 = default and accentColor or Color3.fromRGB(80, 80, 80)
    toggleButton.Text = ""
    applyCorner(toggleButton, 10)
    toggleButton.Parent = frame

    local state = default
    local function updateVisual()
        toggleButton.BackgroundColor3 = state and accentColor or Color3.fromRGB(80, 80, 80)
        if callback then
            callback(state)
        end
    end
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
    end)
    if default then
        frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            if state then
                toggleButton.BackgroundColor3 = frame.BackgroundColor3
            end
        end)
    end
    return {
        GetValue = function() return state end,
        SetValue = function(val)
            state = val
            updateVisual()
        end
    }
end

local function createSlider(parent, name, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerText(label)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default) .. (suffix or "")
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    registerText(valueLabel)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0.65, -10, 0, 6)
    sliderBar.Position = UDim2.new(0.32, 0, 0, 7)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    applyCorner(sliderBar, 3)
    sliderBar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    applyCorner(fill, 3)
    fill.Parent = sliderBar

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    applyCorner(knob, 7)
    knob.Parent = sliderBar

    local value = default
    local function setValue(newVal)
        newVal = math.clamp(newVal, min, max)
        value = newVal
        local scale = (newVal - min) / (max - min)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        knob.Position = UDim2.new(scale, -7, 0.5, -7)
        valueLabel.Text = tostring(math.floor(newVal * 100) / 100) .. (suffix or "")
        if callback then callback(newVal) end
    end

    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local barPos = sliderBar.AbsolutePosition
            local barSize = sliderBar.AbsoluteSize
            local scale = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
            setValue(min + scale * (max - min))
        end
    end)

    return {
        GetValue = function() return value end,
        SetValue = setValue
    }
end

local function createDropdown(parent, name, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerText(label)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.65, -5, 0, 24)
    button.Position = UDim2.new(0.35, 0, 0.5, -12)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = default or (options[1] or "")
    applyCorner(button, 4)
    button.Parent = frame
    registerText(button)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.65, -5, 0, 0)
    listFrame.Position = UDim2.new(0.35, 0, 1, 2)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.ClipsDescendants = true
    listFrame.Visible = false
    listFrame.ZIndex = 5
    applyCorner(listFrame, 4)
    listFrame.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local optionButtons = {}
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundColor3 = (opt == default) and accentColor or Color3.fromRGB(40, 40, 40)
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        optBtn.Parent = listFrame
        registerText(optBtn)
        optBtn.MouseButton1Click:Connect(function()
            for _, b in ipairs(optionButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            optBtn.BackgroundColor3 = accentColor
            button.Text = opt
            listFrame.Visible = false
            if callback then callback(opt) end
        end)
        table.insert(optionButtons, optBtn)
    end

    listFrame.Size = UDim2.new(0.65, -5, 0, #options * 24)

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)

    return {
        GetValue = function() return button.Text end,
        SetValue = function(val)
            for _, b in ipairs(optionButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            if table.find(options, val) then
                button.Text = val
                local idx = table.find(options, val)
                optionButtons[idx].BackgroundColor3 = accentColor
            end
            listFrame.Visible = false
        end
    }
end

local function createMultiDropdown(parent, name, options, defaults, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerText(label)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.65, -5, 0, 24)
    button.Position = UDim2.new(0.35, 0, 0.5, -12)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = "Select..."
    applyCorner(button, 4)
    button.Parent = frame
    registerText(button)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.65, -5, 0, 0)
    listFrame.Position = UDim2.new(0.35, 0, 1, 2)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.ClipsDescendants = true
    listFrame.Visible = false
    listFrame.ZIndex = 5
    applyCorner(listFrame, 4)
    listFrame.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = listFrame

    local selections = {}
    for _, v in ipairs(defaults or {}) do
        selections[v] = true
    end
    local function updateVisual()
        local selectedTexts = {}
        for opt, sel in pairs(selections) do
            if sel then
                table.insert(selectedTexts, opt)
            end
        end
        button.Text = #selectedTexts > 0 and table.concat(selectedTexts, ", ") or "None"
    end
    updateVisual()

    local optionFrames = {}
    for i, opt in ipairs(options) do
        local optFrame = Instance.new("Frame")
        optFrame.Size = UDim2.new(1, 0, 0, 24)
        optFrame.BackgroundTransparency = 1
        optFrame.Parent = listFrame

        local check = Instance.new("Frame")
        check.Size = UDim2.new(0, 14, 0, 14)
        check.Position = UDim2.new(0, 4, 0.5, -7)
        check.BackgroundColor3 = selections[opt] and accentColor or Color3.fromRGB(60, 60, 60)
        applyCorner(check, 3)
        check.Parent = optFrame

        local optLabel = Instance.new("TextLabel")
        optLabel.Size = UDim2.new(1, -22, 1, 0)
        optLabel.Position = UDim2.new(0, 22, 0, 0)
        optLabel.BackgroundTransparency = 1
        optLabel.Text = opt
        optLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        optLabel.TextXAlignment = Enum.TextXAlignment.Left
        optLabel.Parent = optFrame
        registerText(optLabel)

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = optFrame
        clickBtn.MouseButton1Click:Connect(function()
            selections[opt] = not selections[opt]
            check.BackgroundColor3 = selections[opt] and accentColor or Color3.fromRGB(60, 60, 60)
            updateVisual()
            if callback then callback(selections) end
        end)
        table.insert(optionFrames, optFrame)
    end

    listFrame.Size = UDim2.new(0.65, -5, 0, #options * 24)

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)

    return {
        GetValue = function()
            local t = {}
            for k, v in pairs(selections) do
                if v then table.insert(t, k) end
            end
            return t
        end,
        SetValue = function(tbl)
            selections = {}
            for _, v in ipairs(tbl) do
                selections[v] = true
            end
            updateVisual()
        end
    }
end

local function createColorPicker(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerText(label)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 20)
    preview.Position = UDim2.new(0.35, 0, 0.5, -10)
    preview.BackgroundColor3 = default
    applyCorner(preview, 4)
    preview.Parent = frame

    local chooseBtn = Instance.new("TextButton")
    chooseBtn.Size = UDim2.new(0, 60, 0, 20)
    chooseBtn.Position = UDim2.new(0.35, 35, 0.5, -10)
    chooseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    chooseBtn.Text = "Pick"
    chooseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    applyCorner(chooseBtn, 4)
    chooseBtn.Parent = frame
    registerText(chooseBtn)

    local pickerGui = Instance.new("ScreenGui")
    pickerGui.Parent = game:GetService("CoreGui")
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 200, 0, 200)
    pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    pickerFrame.Visible = false
    applyCorner(pickerFrame, 6)
    pickerFrame.Parent = pickerGui

    -- sat/val box
    local pickerBox = Instance.new("Frame")
    pickerBox.Size = UDim2.new(0, 150, 0, 150)
    pickerBox.Position = UDim2.new(0, 10, 0, 10)
    pickerBox.BackgroundColor3 = default
    pickerBox.Parent = pickerFrame

    -- white overlay (horizontal transparency)
    local whiteOverlay = Instance.new("Frame")
    whiteOverlay.Size = UDim2.new(1, 0, 1, 0)
    whiteOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    whiteOverlay.Parent = pickerBox
    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Parent = whiteOverlay

    -- black overlay (vertical transparency)
    local blackOverlay = Instance.new("Frame")
    blackOverlay.Size = UDim2.new(1, 0, 1, 0)
    blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackOverlay.Parent = pickerBox
    local blackGradient = Instance.new("UIGradient")
    blackGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGradient.Rotation = 0
    blackGradient.Parent = blackOverlay

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 20, 0, 150)
    hueBar.Position = UDim2.new(0, 170, 0, 10)
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hueBar.Parent = pickerFrame
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Rotation = 90
    hueGradient.Parent = hueBar

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 180, 0, 24)
    confirmBtn.Position = UDim2.new(0, 10, 0, 168)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    confirmBtn.Text = "Confirm"
    confirmBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    applyCorner(confirmBtn, 4)
    confirmBtn.Parent = pickerFrame
    registerText(confirmBtn)

    local currentColor = default
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1

    local function updatePicker()
        pickerBox.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        preview.BackgroundColor3 = currentColor
    end

    local satValMouse = false
    pickerBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satValMouse = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satValMouse = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if satValMouse then
                local pos = UserInputService:GetMouseLocation()
                local boxPos = pickerBox.AbsolutePosition
                local boxSize = pickerBox.AbsoluteSize
                currentSat = math.clamp((pos.X - boxPos.X) / boxSize.X, 0, 1)
                currentVal = math.clamp(1 - (pos.Y - boxPos.Y) / boxSize.Y, 0, 1)
                currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
                updatePicker()
            end
        end
    end)

    local hueMouse = false
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueMouse = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueMouse = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and hueMouse then
            local pos = UserInputService:GetMouseLocation()
            local barPos = hueBar.AbsolutePosition
            local barSize = hueBar.AbsoluteSize
            currentHue = math.clamp((pos.Y - barPos.Y) / barSize.Y, 0, 1)
            currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
            updatePicker()
        end
    end)

    chooseBtn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = true
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = false
        if callback then callback(currentColor) end
    end)

    return {
        GetValue = function() return currentColor end,
        SetValue = function(col)
            currentColor = col
            currentHue, currentSat, currentVal = col:ToHSV()
            preview.BackgroundColor3 = col
            updatePicker()
        end
    }
end

-- Module class
local Module = {}
Module.__index = Module

function Module.new(parentFrame, name, callback)
    local self = setmetatable({}, Module)
    self.Parent = parentFrame
    self.Name = name
    self.ToggleCallback = callback
    self.Enabled = false
    self.Settings = {} -- saved setting objects
    self.SettingValues = {}

    self.Frame = Instance.new("Frame")
    self.Frame.Size = UDim2.new(1, -10, 0, 36)
    self.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    applyCorner(self.Frame, 6)
    self.Frame.Parent = parentFrame

    self.ToggleIndicator = Instance.new("Frame")
    self.ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
    self.ToggleIndicator.Position = UDim2.new(0, 6, 0.5, -9)
    self.ToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    applyCorner(self.ToggleIndicator, 9)
    self.ToggleIndicator.Parent = self.Frame

    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(0.7, -30, 1, 0)
    self.Label.Position = UDim2.new(0, 30, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    registerText(self.Label)

    -- Toggle button covering indicator
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 1, 0)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = self.Frame
    toggleBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Right click handler
    local rightClickBtn = Instance.new("TextButton")
    rightClickBtn.Size = UDim2.new(1, 0, 1, 0)
    rightClickBtn.BackgroundTransparency = 1
    rightClickBtn.Text = ""
    rightClickBtn.ZIndex = 2
    rightClickBtn.Parent = self.Frame
    rightClickBtn.MouseButton2Click:Connect(function()
        self:OpenSettings()
    end)

    return self
end

function Module:Toggle(state)
    if state == nil then state = not self.Enabled end
    self.Enabled = state
    self.ToggleIndicator.BackgroundColor3 = state and accentColor or Color3.fromRGB(80, 80, 80)
    if state then
        activeColorFrame[self.Frame] = true
        self.Frame.BackgroundColor3 = accentColor
    else
        activeColorFrame[self.Frame] = nil
        self.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end
    if self.ToggleCallback then
        self.ToggleCallback(state)
    end
end

function Module:AddSetting(settingTable)
    local setting
    local type = settingTable.Type
    local name = settingTable.Name
    if type == "Toggle" then
        setting = createToggle(self.SettingsFrame, name, settingTable.Default, settingTable.Callback)
    elseif type == "Slider" then
        setting = createSlider(self.SettingsFrame, name, settingTable.Min, settingTable.Max, settingTable.Default, settingTable.Suffix, settingTable.Callback)
    elseif type == "Dropdown" then
        setting = createDropdown(self.SettingsFrame, name, settingTable.Options, settingTable.Default, settingTable.Callback)
    elseif type == "MultiDropdown" then
        setting = createMultiDropdown(self.SettingsFrame, name, settingTable.Options, settingTable.Default, settingTable.Callback)
    elseif type == "ColorPicker" then
        setting = createColorPicker(self.SettingsFrame, name, settingTable.Default, settingTable.Callback)
    end
    self.SettingValues[name] = setting
    return setting
end

function Module:OpenSettings()
    if self.settingsPopup then
        self.settingsPopup:Destroy()
        self.settingsPopup = nil
    end

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 240, 0, 200)
    popup.Position = UDim2.new(0, self.Frame.AbsolutePosition.X - 240, 0, self.Frame.AbsolutePosition.Y)
    popup.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    popup.ZIndex = 10
    applyCorner(popup, 6)
    popup.Parent = self.Parent.Parent -- main window
    self.settingsPopup = popup

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyCorner(closeBtn, 4)
    closeBtn.Parent = popup
    closeBtn.MouseButton1Click:Connect(function()
        popup:Destroy()
        self.settingsPopup = nil
    end)

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -10, 1, -35)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 30)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.Parent = popup

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollingFrame

    self.SettingsFrame = scrollingFrame

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Repopulate settings (they are stored as entries but need to be rebuilt)
    -- For simplicity, we'll rebuild by calling AddSetting again by storing configs
    -- We'll implement a method to reload settings if needed. For now, just recreate from saved configs.
    -- We'll store raw configurations in module.
    self:LoadSettingsFromConfig()
end

function Module:LoadSettingsFromConfig()
    if not self.SettingConfigs then return end
    for _, cfg in ipairs(self.SettingConfigs) do
        self:AddSetting(cfg)
    end
end

-- We override AddSetting to also store config
local originalAddSetting = Module.AddSetting
function Module:AddSetting(cfg)
    if not self.SettingConfigs then self.SettingConfigs = {} end
    table.insert(self.SettingConfigs, cfg)
    return originalAddSetting(self, cfg)
end

-- Tab class
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Name = name
    self.Button = nil
    self.Modules = {}
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -20)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 10)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.ScrollBarThickness = 4
    self.ContentFrame.Visible = false
    self.ContentFrame.Parent = window.ContentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = self.ContentFrame

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)

    self.Button = Instance.new("TextButton")
    self.Button.Size = UDim2.new(1, -6, 0, 32)
    self.Button.Position = UDim2.new(0, 3, 0, 0) -- will be placed in layout
    self.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.Button.Text = name
    self.Button.TextXAlignment = Enum.TextXAlignment.Left
    self.Button.TextXAlignment = Enum.TextXAlignment.Center
    applyCorner(self.Button, 8)
    self.Button.Parent = window.TabsList
    registerText(self.Button)

    self.Button.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)

    return self
end

function Tab:CreateModule(name, callback)
    local mod = Module.new(self.ContentFrame, name, callback)
    table.insert(self.Modules, mod)
    return mod
end

-- Window class
local Window = {}
Window.__index = Window

function UI.CreateWindow(title)
    local self = setmetatable({}, Window)
    self.Title = title
    self.Tabs = {}
    self.SelectedTab = nil
    self.ColorMode = "Default"
    self.Font = "GothamMedium"

    -- Main container
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "VapeV4UILib"
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    applyCorner(self.MainFrame, 10)
    self.MainFrame.Parent = self.ScreenGui

    -- Left panel (tabs)
    self.TabPanel = Instance.new("Frame")
    self.TabPanel.Size = UDim2.new(0, 120, 1, -10)
    self.TabPanel.Position = UDim2.new(0, 5, 0, 5)
    self.TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    applyCorner(self.TabPanel, 8)
    self.TabPanel.Parent = self.MainFrame

    self.TabsList = Instance.new("ScrollingFrame")
    self.TabsList.Size = UDim2.new(1, -10, 1, -10)
    self.TabsList.Position = UDim2.new(0, 5, 0, 5)
    self.TabsList.BackgroundTransparency = 1
    self.TabsList.ScrollBarThickness = 2
    self.TabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabsList.Parent = self.TabPanel

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.Parent = self.TabsList

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabsList.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Content area (right)
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -135, 1, -10)
    self.ContentArea.Position = UDim2.new(0, 130, 0, 5)
    self.ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    applyCorner(self.ContentArea, 8)
    self.ContentArea.Parent = self.MainFrame

    -- Create Settings tab automatically
    local settingsTab = Tab.new(self, "Settings")
    settingsTab.Button.Text = "⚙ Settings"
    table.insert(self.Tabs, settingsTab)
    self:SelectTab(settingsTab)

    -- Add Color Mode dropdown in Settings tab
    local colorModeDropdown

    -- Create content frame for settings directly (not using modules)
    settingsTab.ContentFrame.Visible = true
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(1, 0, 0, 80)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Parent = settingsTab.ContentFrame

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.3, 0, 0, 20)
    colorLabel.Position = UDim2.new(0, 5, 0, 10)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Color Mode"
    colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = settingsFrame
    registerText(colorLabel)

    colorModeDropdown = createDropdown(settingsFrame, "Color Mode", {"Default", "Breathing", "Rainbow"}, "Default", function(val)
        currentColorMode = val
        self.ColorMode = val
        -- update all active module frames to new accent (or will be updated by animation)
        if val == "Default" then
            accentColor = Color3.fromRGB(150, 0, 255)
            stopColorAnimation()
            for frame, _ in pairs(activeColorFrame) do
                frame.BackgroundColor3 = accentColor
            end
        elseif val == "Breathing" then
            startColorAnimation()
        elseif val == "Rainbow" then
            startColorAnimation()
        end
    end)

    -- Font dropdown
    local fontLabel = Instance.new("TextLabel")
    fontLabel.Size = UDim2.new(0.3, 0, 0, 20)
    fontLabel.Position = UDim2.new(0, 5, 0, 45)
    fontLabel.BackgroundTransparency = 1
    fontLabel.Text = "Font"
    fontLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fontLabel.TextXAlignment = Enum.TextXAlignment.Left
    fontLabel.Parent = settingsFrame
    registerText(fontLabel)

    local fontDropdown = createDropdown(settingsFrame, "Font", {
        "Gotham", "GothamMedium", "GothamBold", "Arial", "ArialBold",
        "SourceSans", "SourceSansLight", "SourceSansBold", "Fantasy", "Legacy"
    }, "GothamMedium", function(val)
        currentFont = val
        self.Font = val
        updateFonts()
    end)

    -- Make the settings tab active initially
    self:SelectTab(settingsTab)

    -- Use default color mode
    accentColor = Color3.fromRGB(150, 0, 255)

    return self
end

function Window:SelectTab(tab)
    if self.SelectedTab then
        self.SelectedTab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        self.SelectedTab.ContentFrame.Visible = false
    end
    self.SelectedTab = tab
    tab.Button.BackgroundColor3 = accentColor
    tab.ContentFrame.Visible = true
end

function Window:CreateTab(name, icon)
    local tab = Tab.new(self, name, icon)
    table.insert(self.Tabs, tab)
    return tab
end

return UI
