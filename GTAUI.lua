local GTAUI = {}
GTAUI.__index = GTAUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGuiService = game:GetService("CoreGui")

GTAUI.ActiveMenu = nil

local Sounds = {}
local SoundConfig = {
	Nav = "rbxassetid://8970347647",
	Select = "rbxassetid://111223777734727",
	Error = "rbxassetid://91660275693179"
}

for name, id in pairs(SoundConfig) do
	local snd = Instance.new("Sound")
	snd.Name = "GTAUI_" .. name
	snd.SoundId = id
	snd.Volume = 0.5
	snd.Parent = SoundService
	Sounds[name] = snd
end

function GTAUI.PlaySound(name)
	if Sounds[name] then Sounds[name]:Play() end
end

local function create(className, properties)
	local inst = Instance.new(className)
	for k, v in pairs(properties) do inst[k] = v end
	return inst
end

function GTAUI.new(config)
	local self = setmetatable({}, GTAUI)
	self.Title = config.Title or "MENU"
	self.Subtitle = config.Subtitle or "OPTIONS"
	self.Signature = config.Signature or "BY DEVELOPER"
	self.Theme = {
		Highlight = config.HighlightColor or Color3.fromRGB(250, 200, 0),
		HeaderBg = config.HeaderColor or Color3.fromRGB(20, 20, 20),
		MainBg = config.BackgroundColor or Color3.fromRGB(0, 0, 0),
		ButtonBg = config.ButtonColor or Color3.fromRGB(30, 30, 30),
		ButtonHover = config.ButtonHoverColor or Color3.fromRGB(255, 255, 255),
		Text = config.TextColor or Color3.fromRGB(255, 255, 255),
		TextHover = config.TextHoverColor or Color3.fromRGB(0, 0, 0)
	}
	self.Buttons = {}
	self.SelectedIndex = 1
	self.PreviousMenu = config.PreviousMenu
	self.IsOpen = false
	self.TargetPosition = UDim2.new(0.02, 0, 0.05, 0)
	self.HiddenPosition = UDim2.new(-0.3, 0, 0.05, 0)
	--local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = CoreGuiService:FindFirstChild("GTA_UI_Master") or create("ScreenGui", {Name = "GTA_UI_Master", ResetOnSpawn = false, IgnoreGuiInset = true, Parent = CoreGuiService})
	self.MainFrame = create("Frame", {
		Name = self.Title, Size = UDim2.new(0.25, 0, 0.65, 0), Position = self.HiddenPosition,
		BackgroundTransparency = 1, Visible = false, Parent = screenGui
	})
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.MainFrame})
	create("UIAspectRatioConstraint", {AspectRatio = 0.65, Parent = self.MainFrame})
	local header = create("Frame", {Size = UDim2.new(1, 0, 0.14, 0), BackgroundColor3 = self.Theme.HeaderBg, BorderSizePixel = 0, LayoutOrder = 1, Parent = self.MainFrame})
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = header})
	local headerText = create("TextLabel", {Size = UDim2.new(1, 0, 0.60, 0), BackgroundTransparency = 1, Text = self.Title, Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = self.Theme.Highlight, Parent = header})
	create("UIPadding", {PaddingLeft = UDim.new(0.1, 0), PaddingRight = UDim.new(0.1, 0), PaddingTop = UDim.new(0.1, 0), Parent = headerText})
	local sigText = create("TextLabel", {Size = UDim2.new(1, 0, 0.35, 0), BackgroundTransparency = 1, Text = self.Signature, Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = Color3.fromRGB(150, 150, 150), Parent = header})
	create("UIPadding", {PaddingBottom = UDim.new(0.2, 0), Parent = sigText})
	create("UITextSizeConstraint", {MaxTextSize = 11, Parent = sigText})
	local subBar = create("Frame", {Size = UDim2.new(1, 0, 0.06, 0), BackgroundColor3 = self.Theme.MainBg, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = 2, Parent = self.MainFrame})
	local catText = create("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0), BackgroundTransparency = 1, Text = self.Subtitle, Font = Enum.Font.GothamBold, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true, Parent = subBar})
	create("UIPadding", {PaddingTop = UDim.new(0.2,0), PaddingBottom = UDim.new(0.2,0), Parent = catText})
	create("UITextSizeConstraint", {MaxTextSize = 14, Parent = catText})
	self.CounterText = create("TextLabel", {Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.55, 0, 0, 0), BackgroundTransparency = 1, Text = "0 / 0", Font = Enum.Font.GothamBold, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Right, TextScaled = true, Parent = subBar})
	create("UIPadding", {PaddingTop = UDim.new(0.2,0), PaddingBottom = UDim.new(0.2,0), Parent = self.CounterText})
	create("UITextSizeConstraint", {MaxTextSize = 14, Parent = self.CounterText})
	self.ListFrame = create("ScrollingFrame", {Size = UDim2.new(1, 0, 0.65, 0), BackgroundColor3 = self.Theme.MainBg, BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = self.Theme.Text, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = self.MainFrame})
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.ListFrame})
	local actionFrame = create("Frame", {Size = UDim2.new(1, 0, 0.08, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0, LayoutOrder = 4, Parent = self.MainFrame})
	local btnActionText = self.PreviousMenu and "RETOUR" or "QUITTER"
	local btnAction = create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(90, 20, 20), BorderSizePixel = 0, Text = btnActionText, Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(200, 200, 200), TextScaled = true, Parent = actionFrame})
	create("UIPadding", {PaddingTop = UDim.new(0.25,0), PaddingBottom = UDim.new(0.25,0), Parent = btnAction})
	create("UITextSizeConstraint", {MaxTextSize = 12, Parent = btnAction})
	btnAction.MouseButton1Click:Connect(function()
		GTAUI.PlaySound("Nav")
		self:Close()
		if self.PreviousMenu then self.PreviousMenu:Open() end
	end)
	local footer = create("Frame", {Size = UDim2.new(1, 0, 0.07, 0), BackgroundColor3 = self.Theme.MainBg, BackgroundTransparency = 0.1, BorderSizePixel = 0, LayoutOrder = 5, Parent = self.MainFrame})
	local footerText = create("TextLabel", {Size = UDim2.new(0.9, 0, 0.6, 0), Position = UDim2.new(0.05, 0, 0.2, 0), BackgroundTransparency = 1, Text = "CLIQUE ou ENTRÉE pour sélectionner. FLÈCHES pour naviguer.", Font = Enum.Font.Gotham, TextScaled = true, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = Enum.TextXAlignment.Left, Parent = footer})
	create("UITextSizeConstraint", {MaxTextSize = 11, Parent = footerText})
	return self
end

function GTAUI:SetSelection(index)
	if #self.Buttons == 0 then return end
	if self.Buttons[self.SelectedIndex] then
		local oldBtn = self.Buttons[self.SelectedIndex].Instance
		oldBtn.BackgroundColor3 = self.Theme.ButtonBg
		oldBtn.TextColor3 = self.Theme.Text
		oldBtn.BackgroundTransparency = 0.5
	end
	if index > #self.Buttons then index = 1 end
	if index < 1 then index = #self.Buttons end
	self.SelectedIndex = index
	local newBtn = self.Buttons[self.SelectedIndex].Instance
	newBtn.BackgroundColor3 = self.Theme.ButtonHover
	newBtn.TextColor3 = self.Theme.TextHover
	newBtn.BackgroundTransparency = 0
	self.CounterText.Text = tostring(self.SelectedIndex) .. " / " .. tostring(#self.Buttons)
end

function GTAUI:AddButton(text, callback)
	local btn = create("TextButton", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = self.Theme.ButtonBg, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "  " .. text, Font = Enum.Font.GothamSemibold, TextColor3 = self.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.ListFrame})
	local index = #self.Buttons + 1
	local btnData = {Instance = btn, Action = callback}
	table.insert(self.Buttons, btnData)
	btn.MouseEnter:Connect(function()
		if self.SelectedIndex ~= index then GTAUI.PlaySound("Nav"); self:SetSelection(index) end
	end)
	btn.MouseButton1Click:Connect(btnData.Action)
	if index == 1 then self:SetSelection(1) else self.CounterText.Text = tostring(self.SelectedIndex) .. " / " .. tostring(#self.Buttons) end
	return btn
end

function GTAUI:AddToggle(text, defaultState, callback)
	local btn = create("TextButton", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = self.Theme.ButtonBg, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "  " .. text, Font = Enum.Font.GothamSemibold, TextColor3 = self.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.ListFrame})
	local statusColor = defaultState and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(200, 50, 50)
	local statusLabel = create("TextLabel", {Size = UDim2.new(0.2, 0, 1, 0), Position = UDim2.new(0.75, 0, 0, 0), BackgroundTransparency = 1, Text = defaultState and "[ ON ]" or "[ OFF ]", Font = Enum.Font.GothamBold, TextColor3 = statusColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = btn})
	local index = #self.Buttons + 1
	local btnData = {}
	btnData.Instance = btn
	btnData.State = defaultState
	btnData.Action = function()
		GTAUI.PlaySound("Select")
		btnData.State = not btnData.State
		statusLabel.Text = btnData.State and "[ ON ]" or "[ OFF ]"
		statusLabel.TextColor3 = btnData.State and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(200, 50, 50)
		callback(btnData.State)
	end
	table.insert(self.Buttons, btnData)
	btn.MouseEnter:Connect(function()
		if self.SelectedIndex ~= index then GTAUI.PlaySound("Nav"); self:SetSelection(index) end
	end)
	btn.MouseButton1Click:Connect(btnData.Action)
	if index == 1 then self:SetSelection(1) else self.CounterText.Text = tostring(self.SelectedIndex) .. " / " .. tostring(#self.Buttons) end
	return btn
end

function GTAUI:AddSubMenu(text, subMenuConfig)
	subMenuConfig.PreviousMenu = self
	local subMenu = GTAUI.new(subMenuConfig)
	self:AddButton(text .. " >", function()
		GTAUI.PlaySound("Select")
		self:Close()
		subMenu:Open()
	end)
	return subMenu
end

function GTAUI:Open()
	if self.IsOpen then return end
	self.IsOpen = true; self.MainFrame.Visible = true; GTAUI.ActiveMenu = self
	TweenService:Create(self.MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = self.TargetPosition}):Play()
end

function GTAUI:Close()
	if not self.IsOpen then return end
	self.IsOpen = false; if GTAUI.ActiveMenu == self then GTAUI.ActiveMenu = nil end
	local tween = TweenService:Create(self.MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = self.HiddenPosition})
	tween:Play()
	tween.Completed:Connect(function() if not self.IsOpen then self.MainFrame.Visible = false end end)
end

function GTAUI:Toggle()
	if self.IsOpen then self:Close() else self:Open() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local active = GTAUI.ActiveMenu
	if not active or not active.IsOpen then return end
	if input.KeyCode == Enum.KeyCode.Up then
		active:SetSelection(active.SelectedIndex - 1); GTAUI.PlaySound("Nav")
	elseif input.KeyCode == Enum.KeyCode.Down then
		active:SetSelection(active.SelectedIndex + 1); GTAUI.PlaySound("Nav")
	elseif input.KeyCode == Enum.KeyCode.Return then
		local btnData = active.Buttons[active.SelectedIndex]
		if btnData and btnData.Action then btnData.Action() end
	elseif input.KeyCode == Enum.KeyCode.Backspace then
		GTAUI.PlaySound("Nav")
		active:Close()
		if active.PreviousMenu then active.PreviousMenu:Open() end
	end
end)

return GTAUI
