-- ui.lua
-- VapeV4-inspired category-window UI library
-- Place this file on GitHub and replace [PLACEHOLDER] with its raw URL.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UI = {}
UI.__index = UI
UI.Windows = {}
UI.ActiveColorMode = "Default" -- "Default", "Breathing", "Rainbow"
UI.CurrentAccent = Color3.fromRGB(150, 0, 255) -- default purple
UI.Font = "GothamMedium" -- default
UI.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

-- Helper to get all available Roblox fonts
local function getAvailableFonts()
	local fonts = {}
	for _, enumItem in ipairs(Enum.Font:GetEnumItems()) do
		-- Skip Unknown and any font that can't be used
		if enumItem == Enum.Font.Unknown then continue end
		local ok, font = pcall(Font.fromEnum, enumItem)
		if ok and font then
			table.insert(fonts, {
				Name = enumItem.Name,
				Font = font,
				Enum = enumItem
			})
		end
	end
	-- Add a few common custom font IDs (Gotham, etc.)
	local custom = {
		{Name = "GothamMedium", Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)},
		{Name = "GothamBold", Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)},
		{Name = "SourceSansBold", Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)},
	}
	for _, c in ipairs(custom) do
		table.insert(fonts, c)
	end
	return fonts
end

local function applyRoundedCorners(gui, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = gui
	return corner
end

local function makeDraggable(gui, target)
	local dragging = false
	local dragStart, startPos
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Update all active modules' backgrounds when color mode changes
local activeModules = {}

local function updateAccentColor()
	if UI.ActiveColorMode == "Breathing" then
		local factor = (math.sin(tick() * 2) + 1) / 2
		UI.CurrentAccent = Color3.fromRGB(100, 0, 180):Lerp(Color3.fromRGB(200, 0, 255), factor)
	elseif UI.ActiveColorMode == "Rainbow" then
		local hue = (tick() * 0.3) % 1
		UI.CurrentAccent = Color3.fromHSV(hue, 1, 1)
	else -- Default
		UI.CurrentAccent = Color3.fromRGB(150, 0, 255)
	end
	for _, moduleFrame in pairs(activeModules) do
		moduleFrame.BackgroundColor3 = UI.CurrentAccent
	end
end

-- Connect heartbeat for dynamic colors
RunService.Heartbeat:Connect(updateAccentColor)

-- ===== UI Elements =====
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
	label.FontFace = UI.FontFace
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 40, 0, 20)
	toggleButton.Position = UDim2.new(0.7, 0, 0.5, -10)
	toggleButton.BackgroundColor3 = default and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
	toggleButton.Text = ""
	applyRoundedCorners(toggleButton, 10)
	toggleButton.Parent = frame

	local state = default
	local function updateVisual()
		toggleButton.BackgroundColor3 = state and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
		if callback then callback(state) end
	end
	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		updateVisual()
	end)
	-- Update color when accent changes
	local conn = RunService.Heartbeat:Connect(function()
		if state then
			toggleButton.BackgroundColor3 = UI.CurrentAccent
		end
	end)
	-- Clean up
	frame.AncestryChanged:Connect(function()
		if not frame.Parent then
			conn:Disconnect()
		end
	end)
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
	label.FontFace = UI.FontFace
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
	valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default) .. (suffix or "")
	valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	valueLabel.FontFace = UI.FontFace
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(0.65, -10, 0, 6)
	sliderBar.Position = UDim2.new(0.32, 0, 0, 7)
	sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	applyRoundedCorners(sliderBar, 3)
	sliderBar.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = UI.CurrentAccent
	applyRoundedCorners(fill, 3)
	fill.Parent = sliderBar

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	applyRoundedCorners(knob, 7)
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
	label.FontFace = UI.FontFace
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.65, -5, 0, 24)
	button.Position = UDim2.new(0.35, 0, 0.5, -12)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.FontFace = UI.FontFace
	button.Text = default or options[1] or ""
	applyRoundedCorners(button, 4)
	button.Parent = frame

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.65, -5, 0, 0)
	listFrame.Position = UDim2.new(0.35, 0, 1, 2)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	listFrame.ClipsDescendants = true
	listFrame.Visible = false
	listFrame.ZIndex = 5
	applyRoundedCorners(listFrame, 4)
	listFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = listFrame

	local optionButtons = {}
	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 24)
		optBtn.BackgroundColor3 = (opt == default) and UI.CurrentAccent or Color3.fromRGB(40, 40, 40)
		optBtn.Text = opt
		optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		optBtn.FontFace = UI.FontFace
		optBtn.Parent = listFrame
		optBtn.MouseButton1Click:Connect(function()
			for _, b in ipairs(optionButtons) do
				b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			end
			optBtn.BackgroundColor3 = UI.CurrentAccent
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
				optionButtons[idx].BackgroundColor3 = UI.CurrentAccent
			end
			listFrame.Visible = false
		end
	}
end

local function createMultiDropdown(parent, name, options, defaults, callback)
	-- Similar to dropdown but with checkboxes; omitted for brevity but can be extended
	-- I'll implement a basic version using checkboxes
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 30)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.3, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.FontFace = UI.FontFace
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.65, -5, 0, 24)
	button.Position = UDim2.new(0.35, 0, 0.5, -12)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.FontFace = UI.FontFace
	button.Text = "Select..."
	applyRoundedCorners(button, 4)
	button.Parent = frame

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.65, -5, 0, 0)
	listFrame.Position = UDim2.new(0.35, 0, 1, 2)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	listFrame.ClipsDescendants = true
	listFrame.Visible = false
	listFrame.ZIndex = 5
	applyRoundedCorners(listFrame, 4)
	listFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = listFrame

	local selections = {}
	for _, v in ipairs(defaults or {}) do selections[v] = true end
	local function updateVisual()
		local txt = {}
		for _, opt in ipairs(options) do
			if selections[opt] then table.insert(txt, opt) end
		end
		button.Text = #txt > 0 and table.concat(txt, ", ") or "None"
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
		check.BackgroundColor3 = selections[opt] and UI.CurrentAccent or Color3.fromRGB(60, 60, 60)
		applyRoundedCorners(check, 3)
		check.Parent = optFrame

		local optLabel = Instance.new("TextLabel")
		optLabel.Size = UDim2.new(1, -22, 1, 0)
		optLabel.Position = UDim2.new(0, 22, 0, 0)
		optLabel.BackgroundTransparency = 1
		optLabel.Text = opt
		optLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		optLabel.FontFace = UI.FontFace
		optLabel.TextXAlignment = Enum.TextXAlignment.Left
		optLabel.Parent = optFrame

		local clickBtn = Instance.new("TextButton")
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.BackgroundTransparency = 1
		clickBtn.Text = ""
		clickBtn.Parent = optFrame
		clickBtn.MouseButton1Click:Connect(function()
			selections[opt] = not selections[opt]
			check.BackgroundColor3 = selections[opt] and UI.CurrentAccent or Color3.fromRGB(60, 60, 60)
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
			for _, v in ipairs(tbl) do selections[v] = true end
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
	label.FontFace = UI.FontFace
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 30, 0, 20)
	preview.Position = UDim2.new(0.35, 0, 0.5, -10)
	preview.BackgroundColor3 = default or Color3.fromRGB(255,255,255)
	applyRoundedCorners(preview, 4)
	preview.Parent = frame

	local chooseBtn = Instance.new("TextButton")
	chooseBtn.Size = UDim2.new(0, 60, 0, 20)
	chooseBtn.Position = UDim2.new(0.35, 35, 0.5, -10)
	chooseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	chooseBtn.Text = "Pick"
	chooseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	chooseBtn.FontFace = UI.FontFace
	applyRoundedCorners(chooseBtn, 4)
	chooseBtn.Parent = frame

	local pickerGui = Instance.new("ScreenGui")
	pickerGui.Parent = game:GetService("CoreGui")
	pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 200, 0, 200)
	pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	pickerFrame.Visible = false
	applyRoundedCorners(pickerFrame, 6)
	pickerFrame.Parent = pickerGui

	-- simple saturation/value box + hue bar
	local pickerBox = Instance.new("Frame")
	pickerBox.Size = UDim2.new(0, 150, 0, 150)
	pickerBox.Position = UDim2.new(0, 10, 0, 10)
	pickerBox.BackgroundColor3 = default or Color3.fromRGB(255,0,0)
	pickerBox.Parent = pickerFrame

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

	local blackOverlay = Instance.new("Frame")
	blackOverlay.Size = UDim2.new(1, 0, 1, 0)
	blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackOverlay.Parent = pickerBox
	local blackGradient = Instance.new("UIGradient")
	blackGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
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
	confirmBtn.FontFace = UI.FontFace
	applyRoundedCorners(confirmBtn, 4)
	confirmBtn.Parent = pickerFrame

	local currentColor = default or Color3.fromRGB(255,255,255)
	local currentHue, currentSat, currentVal = currentColor:ToHSV()

	local function updatePicker()
		pickerBox.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
		preview.BackgroundColor3 = currentColor
	end
	updatePicker()

	local satValMouse = false
	pickerBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then satValMouse = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then satValMouse = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and satValMouse then
			local pos = UserInputService:GetMouseLocation()
			local boxPos = pickerBox.AbsolutePosition
			local boxSize = pickerBox.AbsoluteSize
			currentSat = math.clamp((pos.X - boxPos.X) / boxSize.X, 0, 1)
			currentVal = math.clamp(1 - (pos.Y - boxPos.Y) / boxSize.Y, 0, 1)
			currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
			updatePicker()
		end
	end)

	local hueMouse = false
	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then hueMouse = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then hueMouse = false end
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
	self.SettingConfigs = {}

	self.Frame = Instance.new("Frame")
	self.Frame.Size = UDim2.new(1, -10, 0, 36)
	self.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	applyRoundedCorners(self.Frame, 6)
	self.Frame.Parent = parentFrame

	self.ToggleIndicator = Instance.new("Frame")
	self.ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
	self.ToggleIndicator.Position = UDim2.new(0, 6, 0.5, -9)
	self.ToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	applyRoundedCorners(self.ToggleIndicator, 9)
	self.ToggleIndicator.Parent = self.Frame

	self.Label = Instance.new("TextLabel")
	self.Label.Size = UDim2.new(0.7, -30, 1, 0)
	self.Label.Position = UDim2.new(0, 30, 0, 0)
	self.Label.BackgroundTransparency = 1
	self.Label.Text = name
	self.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.Label.FontFace = UI.FontFace
	self.Label.TextXAlignment = Enum.TextXAlignment.Left
	self.Label.Parent = self.Frame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 30, 1, 0)
	toggleBtn.Position = UDim2.new(0, 0, 0, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = ""
	toggleBtn.Parent = self.Frame
	toggleBtn.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	local rightClick = Instance.new("TextButton")
	rightClick.Size = UDim2.new(1, 0, 1, 0)
	rightClick.BackgroundTransparency = 1
	rightClick.Text = ""
	rightClick.ZIndex = 2
	rightClick.Parent = self.Frame
	rightClick.MouseButton2Click:Connect(function()
		self:OpenSettings()
	end)

	return self
end

function Module:Toggle(state)
	if state == nil then state = not self.Enabled end
	self.Enabled = state
	self.ToggleIndicator.BackgroundColor3 = state and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
	if state then
		activeModules[self.Frame] = true
		self.Frame.BackgroundColor3 = UI.CurrentAccent
	else
		activeModules[self.Frame] = nil
		self.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end
	if self.ToggleCallback then
		self.ToggleCallback(state)
	end
end

function Module:AddSetting(cfg)
	table.insert(self.SettingConfigs, cfg)
	if self.SettingsFrame then
		return self:_createSettingFromConfig(cfg)
	end
end

function Module:_createSettingFromConfig(cfg)
	local set
	local tp = cfg.Type
	if tp == "Toggle" then
		set = createToggle(self.SettingsFrame, cfg.Name, cfg.Default, cfg.Callback)
	elseif tp == "Slider" then
		set = createSlider(self.SettingsFrame, cfg.Name, cfg.Min, cfg.Max, cfg.Default, cfg.Suffix, cfg.Callback)
	elseif tp == "Dropdown" then
		set = createDropdown(self.SettingsFrame, cfg.Name, cfg.Options, cfg.Default, cfg.Callback)
	elseif tp == "MultiDropdown" then
		set = createMultiDropdown(self.SettingsFrame, cfg.Name, cfg.Options, cfg.Default, cfg.Callback)
	elseif tp == "ColorPicker" then
		set = createColorPicker(self.SettingsFrame, cfg.Name, cfg.Default, cfg.Callback)
	end
	return set
end

function Module:OpenSettings()
	if self.settingsPopup then
		self.settingsPopup:Destroy()
		self.settingsPopup = nil
		return
	end

	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0, 240, 0, 200)
	popup.Position = UDim2.new(0, self.Frame.AbsolutePosition.X - 250, 0, self.Frame.AbsolutePosition.Y)
	popup.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	popup.ZIndex = 10
	applyRoundedCorners(popup, 6)
	popup.Parent = self.Parent.Parent -- parent of the scrolling frame inside category window
	self.settingsPopup = popup

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -25, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.FontFace = UI.FontFace
	applyRoundedCorners(closeBtn, 4)
	closeBtn.Parent = popup
	closeBtn.MouseButton1Click:Connect(function()
		popup:Destroy()
		self.settingsPopup = nil
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -35)
	scroll.Position = UDim2.new(0, 5, 0, 30)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 4
	scroll.Parent = popup

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = scroll

	self.SettingsFrame = scroll

	-- Recreate all settings
	for _, cfg in ipairs(self.SettingConfigs) do
		self:_createSettingFromConfig(cfg)
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)
end

-- Category Window
local Category = {}
Category.__index = Category

function Category.new(name, parentGui)
	local self = setmetatable({}, Category)
	self.Name = name
	self.Modules = {}
	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, 220, 0, 300)
	self.Window.Position = UDim2.new(0.5, -110, 0.5, -150)
	self.Window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	self.Window.Visible = false
	applyRoundedCorners(self.Window, 8)
	self.Window.Parent = parentGui

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	applyRoundedCorners(titleBar, 8)
	titleBar.Parent = self.Window

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = name
	title.TextColor3 = Color3.fromRGB(200, 200, 200)
	title.FontFace = UI.FontFace
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -25, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.FontFace = UI.FontFace
	applyRoundedCorners(closeBtn, 4)
	closeBtn.Parent = titleBar
	closeBtn.MouseButton1Click:Connect(function()
		self.Window.Visible = false
	end)

	-- Modules list
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -40)
	scroll.Position = UDim2.new(0, 5, 0, 35)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 4
	scroll.Parent = self.Window

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = scroll

	self.ModuleContainer = scroll

	makeDraggable(titleBar, self.Window)

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)

	return self
end

function Category:CreateModule(name, callback)
	local mod = Module.new(self.ModuleContainer, name, callback)
	table.insert(self.Modules, mod)
	return mod
end

-- Main GUI
function UI:Create()
	local gui = Instance.new("ScreenGui")
	gui.Name = "VapeUI"
	gui.Parent = game:GetService("CoreGui")
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self.Categories = {}

	-- Category buttons panel
	local catPanel = Instance.new("Frame")
	catPanel.Size = UDim2.new(0, 150, 0, 40)
	catPanel.Position = UDim2.new(0.5, -75, 0, 10)
	catPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	applyRoundedCorners(catPanel, 8)
	catPanel.Parent = gui

	local catLayout = Instance.new("UIListLayout")
	catLayout.FillDirection = Enum.FillDirection.Horizontal
	catLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	catLayout.SortOrder = Enum.SortOrder.LayoutOrder
	catLayout.Padding = UDim.new(0, 4)
	catLayout.Parent = catPanel

	function self:AddCategory(name)
		local catBtn = Instance.new("TextButton")
		catBtn.Size = UDim2.new(0, 70, 1, 0)
		catBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		catBtn.Text = name
		catBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		catBtn.FontFace = UI.FontFace
		applyRoundedCorners(catBtn, 6)
		catBtn.Parent = catPanel

		local category = Category.new(name, gui)
		self.Categories[name] = category

		catBtn.MouseButton1Click:Connect(function()
			-- Toggle visibilty
			category.Window.Visible = not category.Window.Visible
			-- Close other categories if needed (optional)
			for n, cat in pairs(self.Categories) do
				if cat ~= category then
					cat.Window.Visible = false
				end
			end
		end)

		-- Make window drag properly
		makeDraggable(catBtn, category.Window) -- maybe better not to use button drag
		return category
	end

	-- Settings tab (always present)
	local settingsCat = Category.new("Settings", gui)
	self.SettingsCategory = settingsCat

	-- Add settings directly to the category
	local settingsScroll = settingsCat.ModuleContainer
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = settingsScroll

	-- Color Mode dropdown
	local colorModeDropdown = createDropdown(settingsScroll, "Color Mode", {"Default", "Breathing", "Rainbow"}, "Default", function(val)
		UI.ActiveColorMode = val
		-- Force update all active modules
		updateAccentColor()
	end)

	-- Font dropdown
	local fonts = getAvailableFonts()
	local fontNames = {}
	for _, f in ipairs(fonts) do table.insert(fontNames, f.Name) end
	local fontDropdown = createDropdown(settingsScroll, "Font", fontNames, "GothamMedium", function(val)
		UI.Font = val
		for _, f in ipairs(fonts) do
			if f.Name == val then
				UI.FontFace = f.Font
				break
			end
		end
		-- Update all text objects
		for _, desc in pairs(gui:GetDescendants()) do
			if desc:IsA("TextLabel") or desc:IsA("TextButton") then
				desc.FontFace = UI.FontFace
			end
		end
	end)

	settingsCat.Window.Visible = true -- show settings by default
	self.Categories["Settings"] = settingsCat
	settingsCat.Window.Position = UDim2.new(0.5, -110, 0.5, -150)

	-- Also add a settings button on the panel
	local settingsBtn = Instance.new("TextButton")
	settingsBtn.Size = UDim2.new(0, 70, 1, 0)
	settingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	settingsBtn.Text = "Settings"
	settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	settingsBtn.FontFace = UI.FontFace
	applyRoundedCorners(settingsBtn, 6)
	settingsBtn.Parent = catPanel
	settingsBtn.MouseButton1Click:Connect(function()
		settingsCat.Window.Visible = not settingsCat.Window.Visible
		for n, cat in pairs(self.Categories) do
			if cat ~= settingsCat then
				cat.Window.Visible = false
			end
		end
	end)

	-- Set initial accent
	updateAccentColor()
	return self
end

return UI
