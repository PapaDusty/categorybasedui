-- ui.lua
-- VapeV4-style category‑based UI with inline module settings

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.ActiveColorMode = "Default"
UI.CurrentAccent = Color3.fromRGB(150, 0, 255)
UI.Font = "GothamMedium"
UI.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

-- Helper: get all valid fonts
local function getAvailableFonts()
	local fonts = {}
	for _, enumItem in ipairs(Enum.Font:GetEnumItems()) do
		if enumItem == Enum.Font.Unknown then continue end
		local ok, font = pcall(Font.fromEnum, enumItem)
		if ok and font then
			table.insert(fonts, { Name = enumItem.Name, Font = font, Enum = enumItem })
		end
	end
	-- Add a few common custom IDs
	local custom = {
		{Name = "GothamMedium", Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)},
		{Name = "GothamBold", Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)},
		{Name = "SourceSansBold", Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)},
	}
	for _, c in ipairs(custom) do table.insert(fonts, c) end
	return fonts
end

local function roundCorners(gui, radius)
	local corner = Instance.new("UICorner", gui)
	corner.CornerRadius = UDim.new(0, radius)
	return corner
end

local function makeDraggable(gui, target)
	local dragging, dragStart, startPos
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

-- ============ ELEMENT BUILDERS ============
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

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 40, 0, 20)
	toggleBtn.Position = UDim2.new(0.7, 0, 0.5, -10)
	toggleBtn.BackgroundColor3 = default and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
	toggleBtn.Text = ""
	roundCorners(toggleBtn, 10)
	toggleBtn.Parent = frame

	local state = default
	local function updateVisual()
		toggleBtn.BackgroundColor3 = state and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
		if callback then callback(state) end
	end
	toggleBtn.MouseButton1Click:Connect(function()
		state = not state
		updateVisual()
	end)
	return {
		GetValue = function() return state end,
		SetValue = function(val) state = val updateVisual() end
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
	roundCorners(sliderBar, 3)
	sliderBar.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = UI.CurrentAccent
	roundCorners(fill, 3)
	fill.Parent = sliderBar

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	roundCorners(knob, 7)
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
	knob.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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

	return { GetValue = function() return value end, SetValue = setValue }
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
	roundCorners(button, 4)
	button.Parent = frame

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.65, -5, 0, 0)
	listFrame.Position = UDim2.new(0.35, 0, 1, 2)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	listFrame.ClipsDescendants = true
	listFrame.Visible = false
	listFrame.ZIndex = 5
	roundCorners(listFrame, 4)
	listFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout", listFrame)
	local optionBtns = {}
	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 24)
		optBtn.BackgroundColor3 = (opt == default) and UI.CurrentAccent or Color3.fromRGB(40, 40, 40)
		optBtn.Text = opt
		optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		optBtn.FontFace = UI.FontFace
		optBtn.Parent = listFrame
		optBtn.MouseButton1Click:Connect(function()
			for _, b in ipairs(optionBtns) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
			optBtn.BackgroundColor3 = UI.CurrentAccent
			button.Text = opt
			listFrame.Visible = false
			if callback then callback(opt) end
		end)
		table.insert(optionBtns, optBtn)
	end
	listFrame.Size = UDim2.new(0.65, -5, 0, #options * 24)

	button.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
	return {
		GetValue = function() return button.Text end,
		SetValue = function(val)
			for _, b in ipairs(optionBtns) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
			if table.find(options, val) then
				button.Text = val
				local idx = table.find(options, val)
				optionBtns[idx].BackgroundColor3 = UI.CurrentAccent
			end
			listFrame.Visible = false
		end
	}
end

local function createMultiDropdown(parent, name, options, defaults, callback)
	-- basic implementation; similar to dropdown with checkboxes
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
	roundCorners(button, 4)
	button.Parent = frame

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.65, -5, 0, 0)
	listFrame.Position = UDim2.new(0.35, 0, 1, 2)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	listFrame.ClipsDescendants = true
	listFrame.Visible = false
	listFrame.ZIndex = 5
	roundCorners(listFrame, 4)
	listFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout", listFrame)
	local selections = {}
	for _, v in ipairs(defaults or {}) do selections[v] = true end
	local function updateVisual()
		local txt = {}
		for _, opt in ipairs(options) do if selections[opt] then table.insert(txt, opt) end end
		button.Text = #txt > 0 and table.concat(txt, ", ") or "None"
	end
	updateVisual()

	for _, opt in ipairs(options) do
		local optFrame = Instance.new("Frame")
		optFrame.Size = UDim2.new(1, 0, 0, 24)
		optFrame.BackgroundTransparency = 1
		optFrame.Parent = listFrame

		local check = Instance.new("Frame")
		check.Size = UDim2.new(0, 14, 0, 14)
		check.Position = UDim2.new(0, 4, 0.5, -7)
		check.BackgroundColor3 = selections[opt] and UI.CurrentAccent or Color3.fromRGB(60, 60, 60)
		roundCorners(check, 3)
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
	end
	listFrame.Size = UDim2.new(0.65, -5, 0, #options * 24)

	button.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
	return {
		GetValue = function() local t = {} for k,v in pairs(selections) do if v then table.insert(t, k) end end return t end,
		SetValue = function(tbl) selections = {} for _,v in ipairs(tbl) do selections[v] = true end updateVisual() end
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
	roundCorners(preview, 4)
	preview.Parent = frame

	local chooseBtn = Instance.new("TextButton")
	chooseBtn.Size = UDim2.new(0, 60, 0, 20)
	chooseBtn.Position = UDim2.new(0.35, 35, 0.5, -10)
	chooseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	chooseBtn.Text = "Pick"
	chooseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	chooseBtn.FontFace = UI.FontFace
	roundCorners(chooseBtn, 4)
	chooseBtn.Parent = frame

	-- mini color picker popup (simplified)
	local pickerGui = Instance.new("ScreenGui")
	pickerGui.Parent = CoreGui
	pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 200, 0, 200)
	pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	pickerFrame.Visible = false
	roundCorners(pickerFrame, 6)
	pickerFrame.Parent = pickerGui

	local pickerBox = Instance.new("Frame")
	pickerBox.Size = UDim2.new(0, 150, 0, 150)
	pickerBox.Position = UDim2.new(0, 10, 0, 10)
	pickerBox.BackgroundColor3 = default or Color3.fromRGB(255,0,0)
	pickerBox.Parent = pickerFrame

	local whiteOverlay = Instance.new("Frame")
	whiteOverlay.Size = UDim2.new(1, 0, 1, 0)
	whiteOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	whiteOverlay.Parent = pickerBox
	local whiteGradient = Instance.new("UIGradient", whiteOverlay)
	whiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

	local blackOverlay = Instance.new("Frame")
	blackOverlay.Size = UDim2.new(1, 0, 1, 0)
	blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackOverlay.Parent = pickerBox
	local blackGradient = Instance.new("UIGradient", blackOverlay)
	blackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

	local hueBar = Instance.new("Frame")
	hueBar.Size = UDim2.new(0, 20, 0, 150)
	hueBar.Position = UDim2.new(0, 170, 0, 10)
	hueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	hueBar.Parent = pickerFrame
	local hueGradient = Instance.new("UIGradient", hueBar)
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

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0, 180, 0, 24)
	confirmBtn.Position = UDim2.new(0, 10, 0, 168)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	confirmBtn.Text = "Confirm"
	confirmBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	confirmBtn.FontFace = UI.FontFace
	roundCorners(confirmBtn, 4)
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

	chooseBtn.MouseButton1Click:Connect(function() pickerFrame.Visible = true end)
	confirmBtn.MouseButton1Click:Connect(function()
		pickerFrame.Visible = false
		if callback then callback(currentColor) end
	end)

	return { GetValue = function() return currentColor end, SetValue = function(col) currentColor = col currentHue,currentSat,currentVal = col:ToHSV() updatePicker() end }
end

-- Map type name to builder
local settingBuilders = {
	Toggle = createToggle,
	Slider = createSlider,
	Dropdown = createDropdown,
	MultiDropdown = createMultiDropdown,
	ColorPicker = createColorPicker,
}

-- ============ MAIN WINDOW ============
function UI:CreateWindow()
	local gui = Instance.new("ScreenGui")
	gui.Name = "VapeUILib"
	gui.Parent = CoreGui
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainWindow = { Gui = gui, Categories = {}, ModuleFrames = {} }

	-- Panel for category buttons
	local catPanel = Instance.new("Frame")
	catPanel.Size = UDim2.new(0, 300, 0, 40)
	catPanel.Position = UDim2.new(0.5, -150, 0, 10)
	catPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	roundCorners(catPanel, 8)
	catPanel.Parent = gui

	local catLayout = Instance.new("UIListLayout")
	catLayout.FillDirection = Enum.FillDirection.Horizontal
	catLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	catLayout.SortOrder = Enum.SortOrder.LayoutOrder
	catLayout.Padding = UDim.new(0, 4)
	catLayout.Parent = catPanel

	-- Settings button (always visible)
	local settingsBtn = Instance.new("TextButton")
	settingsBtn.Size = UDim2.new(0, 80, 1, 0)
	settingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	settingsBtn.Text = "Settings"
	settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	settingsBtn.FontFace = UI.FontFace
	roundCorners(settingsBtn, 6)
	settingsBtn.Parent = catPanel

	-- ========== Create Settings category window ==========
	local function createCategoryWindow(name, parentGui)
		local window = Instance.new("Frame")
		window.Size = UDim2.new(0, 220, 0, 400)
		window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		window.Visible = false
		roundCorners(window, 8)
		window.Parent = parentGui

		local titleBar = Instance.new("Frame")
		titleBar.Size = UDim2.new(1, 0, 0, 30)
		titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		roundCorners(titleBar, 8)
		titleBar.Parent = window

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
		roundCorners(closeBtn, 4)
		closeBtn.Parent = titleBar
		closeBtn.MouseButton1Click:Connect(function() window.Visible = false end)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -10, 1, -40)
		scroll.Position = UDim2.new(0, 5, 0, 35)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 4
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Parent = window

		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 5)
		listLayout.Parent = scroll

		makeDraggable(titleBar, window)

		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
		end)

		-- Category object
		local catObj = {
			Window = window,
			Scroll = scroll,
			Modules = {}
		}

		-- Add setting directly to the tab (for global settings)
		function catObj:AddSetting(cfg)
			return settingBuilders[cfg.Type](self.Scroll, cfg.Name, cfg.Default, cfg.Options, cfg.Min, cfg.Max, cfg.Suffix, cfg.Callback)
		end

		-- Create a module inside this category
		function catObj:CreateModule(name, callback)
			local moduleFrame = Instance.new("Frame")
			moduleFrame.Size = UDim2.new(1, -10, 0, 36)
			moduleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			roundCorners(moduleFrame, 6)
			moduleFrame.Parent = self.Scroll

			local toggleIndicator = Instance.new("Frame")
			toggleIndicator.Size = UDim2.new(0, 18, 0, 18)
			toggleIndicator.Position = UDim2.new(0, 6, 0.5, -9)
			toggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			roundCorners(toggleIndicator, 9)
			toggleIndicator.Parent = moduleFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.7, -30, 1, 0)
			label.Position = UDim2.new(0, 30, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = name
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.FontFace = UI.FontFace
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = moduleFrame

			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Size = UDim2.new(0, 30, 1, 0)
			toggleBtn.Position = UDim2.new(0, 0, 0, 0)
			toggleBtn.BackgroundTransparency = 1
			toggleBtn.Text = ""
			toggleBtn.Parent = moduleFrame

			-- Hidden settings frame (placed in the scroll, right after the module)
			local settingsFrame = Instance.new("Frame")
			settingsFrame.Size = UDim2.new(1, -10, 0, 0)
			settingsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			settingsFrame.Visible = false
			settingsFrame.ClipsDescendants = true
			roundCorners(settingsFrame, 4)
			settingsFrame.Parent = self.Scroll

			local settingsList = Instance.new("UIListLayout")
			settingsList.SortOrder = Enum.SortOrder.LayoutOrder
			settingsList.Padding = UDim.new(0, 3)
			settingsList.Parent = settingsFrame

			-- Right-click to toggle settings
			local rightClickBtn = Instance.new("TextButton")
			rightClickBtn.Size = UDim2.new(1, 0, 1, 0)
			rightClickBtn.BackgroundTransparency = 1
			rightClickBtn.Text = ""
			rightClickBtn.ZIndex = 2
			rightClickBtn.Parent = moduleFrame
			rightClickBtn.MouseButton2Click:Connect(function()
				settingsFrame.Visible = not settingsFrame.Visible
				self.Scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
			end)

			settingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if settingsFrame.Visible then
					settingsFrame.Size = UDim2.new(1, -10, 0, settingsList.AbsoluteContentSize.Y + 10)
				else
					settingsFrame.Size = UDim2.new(1, -10, 0, 0)
				end
				self.Scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
			end)

			local modObj = {
				Frame = moduleFrame,
				SettingsFrame = settingsFrame,
				Enabled = false,
				Toggle = function(state)
					if state == nil then state = not modObj.Enabled end
					modObj.Enabled = state
					toggleIndicator.BackgroundColor3 = state and UI.CurrentAccent or Color3.fromRGB(80, 80, 80)
					moduleFrame.BackgroundColor3 = state and UI.CurrentAccent or Color3.fromRGB(20, 20, 20)
					if callback then callback(state) end
				end
			}

			toggleBtn.MouseButton1Click:Connect(function() modObj.Toggle() end)

			function modObj:AddSetting(cfg)
				local builder = settingBuilders[cfg.Type]
				if builder then
					if cfg.Type == "Slider" then
						return builder(settingsFrame, cfg.Name, cfg.Min, cfg.Max, cfg.Default, cfg.Suffix, cfg.Callback)
					elseif cfg.Type == "Dropdown" then
						return builder(settingsFrame, cfg.Name, cfg.Options, cfg.Default, cfg.Callback)
					elseif cfg.Type == "MultiDropdown" then
						return builder(settingsFrame, cfg.Name, cfg.Options, cfg.Default, cfg.Callback)
					else
						return builder(settingsFrame, cfg.Name, cfg.Default, cfg.Callback)
					end
				end
			end

			table.insert(mainWindow.ModuleFrames, moduleFrame)
			table.insert(self.Modules, modObj)
			return modObj
		end

		return catObj
	end

	-- Create Settings category
	local settingsCat = createCategoryWindow("Settings", gui)
	settingsCat.Window.Visible = true
	settingsCat.Window.Position = UDim2.new(0.5, -110, 0.5, -200)
	mainWindow.Categories["Settings"] = settingsCat

	settingsBtn.MouseButton1Click:Connect(function()
		settingsCat.Window.Visible = not settingsCat.Window.Visible
	end)

	-- Populate Settings tab with Color Mode and Font
	settingsCat:AddSetting({
		Type = "Dropdown",
		Name = "Color Mode",
		Options = {"Default", "Breathing", "Rainbow"},
		Default = "Default",
		Callback = function(val)
			UI.ActiveColorMode = val
		end
	})
	local fonts = getAvailableFonts()
	local fontNames = {}
	for _, f in ipairs(fonts) do table.insert(fontNames, f.Name) end
	settingsCat:AddSetting({
		Type = "Dropdown",
		Name = "Font",
		Options = fontNames,
		Default = "GothamMedium",
		Callback = function(val)
			UI.Font = val
			for _, f in ipairs(fonts) do
				if f.Name == val then
					UI.FontFace = f.Font
					break
				end
			end
			for _, desc in pairs(gui:GetDescendants()) do
				if desc:IsA("TextLabel") or desc:IsA("TextButton") then
					desc.FontFace = UI.FontFace
				end
			end
		end
	})

	-- Start color animation
	RunService.Heartbeat:Connect(function()
		if UI.ActiveColorMode == "Breathing" then
			local factor = (math.sin(tick() * 2) + 1) / 2
			UI.CurrentAccent = Color3.fromRGB(100, 0, 180):Lerp(Color3.fromRGB(200, 0, 255), factor)
		elseif UI.ActiveColorMode == "Rainbow" then
			local hue = (tick() * 0.3) % 1
			UI.CurrentAccent = Color3.fromHSV(hue, 1, 1)
		else
			UI.CurrentAccent = Color3.fromRGB(150, 0, 255)
		end
		-- Update enabled module backgrounds
		for _, modFrame in ipairs(mainWindow.ModuleFrames) do
			-- Find module object? We need to track enabled state.
			-- We'll instead loop over all categories and their modules.
		end
	end)
	-- Proper enabled tracking: we'll iterate all categories' modules in the heartbeat.
	local function updateAllModules()
		for _, cat in pairs(mainWindow.Categories) do
			for _, mod in ipairs(cat.Modules) do
				if mod.Enabled then
					mod.Frame.BackgroundColor3 = UI.CurrentAccent
					mod.Frame.ToggleIndicator.BackgroundColor3 = UI.CurrentAccent
				end
			end
		end
	end
	RunService.Heartbeat:Connect(function()
		if UI.ActiveColorMode ~= "Default" then
			updateAllModules()
		end
	end)

	-- Method to add a new category
	function mainWindow:AddCategory(name)
		local cat = createCategoryWindow(name, gui)
		cat.Window.Position = UDim2.new(0.5, -110 + (#mainWindow.Categories * 30), 0.5, -200 + (#mainWindow.Categories * 30))
		mainWindow.Categories[name] = cat

		-- Create a button in the panel for this category
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 70, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.FontFace = UI.FontFace
		roundCorners(btn, 6)
		btn.Parent = catPanel
		btn.MouseButton1Click:Connect(function()
			cat.Window.Visible = not cat.Window.Visible
		end)
		return cat
	end

	return mainWindow
end

return UI
