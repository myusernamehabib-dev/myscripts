--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v18.0 [PART 1: CORE ENGINE & UI]
--==================================================================

shared.UltraAdmin = shared.UltraAdmin or {}

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
	Lighting = game:GetService("Lighting"),
	CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

pcall(function()
	if PlayerGui:FindFirstChild("UltraAdminPanelV18") then
		PlayerGui.UltraAdminPanelV18:Destroy()
	end
end)

shared.UltraAdmin.Config = {
	WalkSpeed = 50,
	JumpPower = 100,
	FlySpeed = 75,
	Gravity = 196.2,
	HipHeight = 0,
	NoclipEnabled = false,
	InfJumpEnabled = false,
	FlyEnabled = false,
	SpeedEnabled = false,
	JumpEnabled = false
}

shared.UltraAdmin.State = {
	Fly = false,
	Noclip = false,
	Speed = false,
	SuperJump = false,
	InfiniteJump = false,
	GodMode = false,
	Invisible = false
}

shared.UltraAdmin.Connections = {}
shared.UltraAdmin.Pages = {}
shared.UltraAdmin.SideButtons = {}
shared.UltraAdmin.Elements = {}

local Helpers = {}
shared.UltraAdmin.Helpers = Helpers

function Helpers.getChar(player)
	player = player or LocalPlayer
	if player then
		return player.Character
	end
	return nil
end

function Helpers.getHum(player)
	local char = Helpers.getChar(player)
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

function Helpers.getRoot(player)
	local char = Helpers.getChar(player)
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

function Helpers.tween(obj, props, timeVal)
	timeVal = timeVal or 0.2
	pcall(function()
		local info = TweenInfo.new(timeVal, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local anim = Services.TweenService:Create(obj, info, props)
		anim:Play()
	end)
end

function Helpers.disconnect(name)
	if shared.UltraAdmin.Connections[name] then
		pcall(function()
			shared.UltraAdmin.Connections[name]:Disconnect()
		end)
		shared.UltraAdmin.Connections[name] = nil
	end
end

function Helpers.safeExecute(func)
	local success, err = pcall(func)
	if not success then
		warn("[UltraAdmin Error]: " .. tostring(err))
	end
	return success
end

-- ИНТЕРФЕЙС И ГЕОМЕТРИЯ UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraAdminPanelV18"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

pcall(function()
	ScreenGui.Parent = Services.CoreGui
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = PlayerGui
end

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.Size = UDim2.new(0, 250, 1, 0)
NotificationHolder.Position = UDim2.new(1, -260, 0, 10)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 6)
NotifList.Parent = NotificationHolder

function Helpers.notify(title, msg, duration)
	duration = duration or 3
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 50)
	notif.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
	notif.BackgroundTransparency = 0.1
	notif.Parent = NotificationHolder

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 255, 140)
	stroke.Thickness = 1
	stroke.Parent = notif

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notif

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -10, 0, 20)
	tLbl.Position = UDim2.fromOffset(8, 4)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = Color3.fromRGB(0, 255, 140)
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 12
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = notif

	local mLbl = Instance.new("TextLabel")
	mLbl.Size = UDim2.new(1, -10, 0, 20)
	mLbl.Position = UDim2.fromOffset(8, 22)
	mLbl.BackgroundTransparency = 1
	mLbl.Text = msg
	mLbl.TextColor3 = Color3.fromRGB(220, 225, 230)
	mLbl.Font = Enum.Font.Gotham
	mLbl.TextSize = 10
	mLbl.TextXAlignment = Enum.TextXAlignment.Left
	mLbl.Parent = notif

	task.spawn(function()
		task.wait(duration)
		Helpers.tween(notif, {BackgroundTransparency = 1}, 0.3)
		Helpers.tween(tLbl, {TextTransparency = 1}, 0.3)
		Helpers.tween(mLbl, {TextTransparency = 1}, 0.3)
		Helpers.tween(stroke, {Transparency = 1}, 0.3)
		task.wait(0.3)
		notif:Destroy()
	end)
end

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.fromOffset(48, 48)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
OpenBtn.Text = "⚡"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 140)
OpenBtn.TextSize = 22
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = OpenBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 255, 140)
openStroke.Thickness = 1.5
openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
openStroke.Parent = OpenBtn

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 650, 0, 430)
Main.Position = UDim2.new(0.5, -325, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 255, 140)
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.3
mainStroke.Parent = Main

OpenBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
	if Main.Visible then
		Helpers.tween(Main, {Size = UDim2.new(0, 650, 0, 430)}, 0.2)
	end
end)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(14, 17, 24)
Header.Parent = Main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTRA ADMIN PANEL v18.0 [CORE SYSTEM]"
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 90)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -55)
Sidebar.Position = UDim2.fromOffset(10, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
Sidebar.Parent = Main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 10)
sideCorner.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 4)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -165, 1, -55)
Content.Position = UDim2.fromOffset(155, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

shared.UltraAdmin.UI = {}
shared.UltraAdmin.ContentFrame = Content
shared.UltraAdmin.SidebarFrame = Sidebar

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Content

	local pad = Instance.new("UIPadding")
	pad.PaddingRight = UDim.new(0, 6)
	pad.Parent = page

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.Parent = page

	shared.UltraAdmin.Pages[name] = page
	return page
end

local function createTab(text, pageName)
	local page = createPage(pageName)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(140, 150, 165)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.Parent = Sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	shared.UltraAdmin.SideButtons[pageName] = btn

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(shared.UltraAdmin.Pages) do
			p.Visible = false
		end
		for _, b in pairs(shared.UltraAdmin.SideButtons) do
			b.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			b.TextColor3 = Color3.fromRGB(140, 150, 165)
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return page
end

shared.UltraAdmin.UI.createTab = createTab
shared.UltraAdmin.UI.createPage = createPage

-- РЕНДЕРИНГ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ UI
function shared.UltraAdmin.UI.createToggle(parent, text, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 40)
	holder.BackgroundColor3 = Color3.fromRGB(16, 20, 27)
	holder.Parent = parent

	local holderCorner = Instance.new("UICorner")
	holderCorner.CornerRadius = UDim.new(0, 6)
	holderCorner.Parent = holder

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -60, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(230, 235, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(38, 20)
	toggle.Position = UDim2.new(1, -48, 0.5, -10)
	if default then
		toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		toggle.BackgroundColor3 = Color3.fromRGB(40, 46, 60)
	end
	toggle.Text = ""
	toggle.Parent = holder

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(14, 14)
	if default then
		knob.Position = UDim2.new(1, -16, 0.5, -7)
	else
		knob.Position = UDim2.new(0, 2, 0.5, -7)
	end
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = toggle

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		local targetColor = Color3.fromRGB(40, 46, 60)
		local targetPos = UDim2.new(0, 2, 0.5, -7)
		if state then
			targetColor = Color3.fromRGB(0, 180, 100)
			targetPos = UDim2.new(1, -16, 0.5, -7)
		end
		Helpers.tween(toggle, {BackgroundColor3 = targetColor}, 0.15)
		Helpers.tween(knob, {Position = targetPos}, 0.15)
		Helpers.safeExecute(function()
			callback(state)
		end)
	end)
end

function shared.UltraAdmin.UI.createSlider(parent, text, minVal, maxVal, defaultVal, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 50)
	holder.BackgroundColor3 = Color3.fromRGB(16, 20, 27)
	holder.Parent = parent

	local holderCorner = Instance.new("UICorner")
	holderCorner.CornerRadius = UDim.new(0, 6)
	holderCorner.Parent = holder

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -70, 0, 20)
	lbl.Position = UDim2.fromOffset(10, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(230, 235, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = holder

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0, 50, 0, 20)
	valLbl.Position = UDim2.new(1, -60, 0, 4)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(defaultVal)
	valLbl.TextColor3 = Color3.fromRGB(0, 255, 140)
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 10
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.Parent = holder

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 8)
	bar.Position = UDim2.fromOffset(10, 32)
	bar.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
	bar.Parent = holder

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	local percent = (defaultVal - minVal) / (maxVal - minVal)
	fill.Size = UDim2.new(percent, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	fill.Parent = bar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local dragging = false
	local function update(input)
		local pos = input.Position.X - bar.AbsolutePosition.X
		local clampPos = math.clamp(pos / bar.AbsoluteSize.X, 0, 1)
		local calculatedValue = math.floor(minVal + (maxVal - minVal) * clampPos)
		fill.Size = UDim2.new(clampPos, 0, 1, 0)
		valLbl.Text = tostring(calculatedValue)
		Helpers.safeExecute(function()
			callback(calculatedValue)
		end)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

function shared.UltraAdmin.UI.createBtn(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = color or Color3.fromRGB(20, 26, 36)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 245, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.Parent = parent

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		Helpers.safeExecute(function()
			callback()
		end)
	end)
	return btn
end

-- ЛОГИКА ВКЛАДКИ ПЕРСОНАЖА (HOME)
local PageHome = createTab("🏠 Персонаж", "Home")
PageHome.Visible = true
shared.UltraAdmin.SideButtons.Home.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
shared.UltraAdmin.SideButtons.Home.TextColor3 = Color3.fromRGB(255, 255, 255)

shared.UltraAdmin.UI.createToggle(PageHome, "✈️ Свободный Полет (Fly)", false, function(state)
	shared.UltraAdmin.State.Fly = state
	local hum = Helpers.getHum()
	local root = Helpers.getRoot()
	if not hum or not root then return end

	if state then
		hum.PlatformStand = true
		Helpers.disconnect("Fly")
		shared.UltraAdmin.Connections.Fly = Services.RunService.RenderStepped:Connect(function()
			if not shared.UltraAdmin.State.Fly or not root.Parent then return end
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0 then
				root.AssemblyLinearVelocity = moveDir.Unit * shared.UltraAdmin.Config.FlySpeed
			else
				root.AssemblyLinearVelocity = Vector3.zero
			end
			root.CFrame = CFrame.lookAt(root.Position, root.Position + Camera.CFrame.LookVector)
		end)
	else
		Helpers.disconnect("Fly")
		if root then root.AssemblyLinearVelocity = Vector3.zero end
		hum.PlatformStand = false
	end
end)

shared.UltraAdmin.UI.createToggle(PageHome, "⚡ Ускоренный Бег (Speed)", false, function(state)
	shared.UltraAdmin.State.Speed = state
	local hum = Helpers.getHum()
	if hum then
		if state then
			hum.WalkSpeed = shared.UltraAdmin.Config.WalkSpeed
		else
			hum.WalkSpeed = 16
		end
	end
end)

shared.UltraAdmin.UI.createToggle(PageHome, "🦘 Супер Прыжок (JumpPower)", false, function(state)
	shared.UltraAdmin.State.SuperJump = state
	local hum = Helpers.getHum()
	if hum then
		if state then
			hum.JumpPower = shared.UltraAdmin.Config.JumpPower
		else
			hum.JumpPower = 50
		end
	end
end)

shared.UltraAdmin.UI.createToggle(PageHome, "👻 Сквозь стены (Noclip)", false, function(state)
	shared.UltraAdmin.State.Noclip = state
	Helpers.disconnect("Noclip")
	if state then
		shared.UltraAdmin.Connections.Noclip = Services.RunService.Stepped:Connect(function()
			local char = Helpers.getChar()
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end)

shared.UltraAdmin.UI.createToggle(PageHome, "♾️ Бесконечный Прыжок (Infinite Jump)", false, function(state)
	shared.UltraAdmin.State.InfiniteJump = state
	Helpers.disconnect("InfJump")
	if state then
		shared.UltraAdmin.Connections.InfJump = Services.UserInputService.JumpRequest:Connect(function()
			local hum = Helpers.getHum()
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end
end)

shared.UltraAdmin.UI.createSlider(PageHome, "Скорость бега", 16, 250, 50, function(val)
	shared.UltraAdmin.Config.WalkSpeed = val
	if shared.UltraAdmin.State.Speed then
		local hum = Helpers.getHum()
		if hum then hum.WalkSpeed = val end
	end
end)

shared.UltraAdmin.UI.createSlider(PageHome, "Сила прыжка", 50, 300, 100, function(val)
	shared.UltraAdmin.Config.JumpPower = val
	if shared.UltraAdmin.State.SuperJump then
		local hum = Helpers.getHum()
		if hum then hum.JumpPower = val end
	end
end)

shared.UltraAdmin.UI.createBtn(PageHome, "🔄 Сброс Персонажа (Reset)", Color3.fromRGB(150, 40, 50), function()
	local hum = Helpers.getHum()
	if hum then hum.Health = 0 end
end)

Helpers.notify("Ultra Admin", "Часть 1 ядра успешно загружена!", 3)
print("⚡ Ultra Admin Panel v18.0 [Часть 1 из 5] полностью готова!")
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v18.0 [PART 2: VISUALS & ESP]
--==================================================================

if not shared.UltraAdmin or not shared.UltraAdmin.Helpers then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 (Ядро UI)!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Helpers = shared.UltraAdmin.Helpers
local UI = shared.UltraAdmin.UI

-- Состояния и настройки ESP
shared.UltraAdmin.State.ESP_Boxes = false
shared.UltraAdmin.State.ESP_Names = false
shared.UltraAdmin.State.ESP_Distance = false
shared.UltraAdmin.State.ESP_Highlight = false

shared.UltraAdmin.ESPFolder = shared.UltraAdmin.ESPFolder or Instance.new("Folder")
shared.UltraAdmin.ESPFolder.Name = "UltraAdmin_ESP"
pcall(function()
	shared.UltraAdmin.ESPFolder.Parent = Services.CoreGui
end)
if not shared.UltraAdmin.ESPFolder.Parent then
	shared.UltraAdmin.ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Создаём новую вкладку через ядро UI
local PageVisuals = UI.createTab("👁️ Визуалы / ESP", "Visuals")

-- Подсистема Highlight (Подсветка сквозь стены)
local function applyHighlight(player)
	if player == LocalPlayer then return end
	local char = Helpers.getChar(player)
	if not char then return end

	local hl = char:FindFirstChild("UltraAdmin_Highlight")
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = "UltraAdmin_Highlight"
		hl.FillColor = Color3.fromRGB(255, 50, 75)
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = char
	end
end

local function removeHighlight(player)
	local char = Helpers.getChar(player)
	if char then
		local hl = char:FindFirstChild("UltraAdmin_Highlight")
		if hl then
			hl:Destroy()
		end
	end
end

-- Подсистема 2D-Элементов (Boxes, Names, Distance)
local function createESPStorage(player)
	local id = "ESP_" .. player.Name
	local existing = shared.UltraAdmin.ESPFolder:FindFirstChild(id)
	if existing then existing:Destroy() end

	local holder = Instance.new("BillboardGui")
	holder.Name = id
	holder.AlwaysOnTop = true
	holder.Size = UDim2.fromOffset(200, 50)
	holder.StudsOffset = Vector3.new(0, 3, 0)
	holder.Parent = shared.UltraAdmin.ESPFolder

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Name = "NameLabel"
	nameLbl.Size = UDim2.new(1, 0, 0, 20)
	nameLbl.Position = UDim2.fromOffset(0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = player.DisplayName
	nameLbl.TextColor3 = Color3.fromRGB(0, 255, 140)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 11
	nameLbl.TextStrokeTransparency = 0.2
	nameLbl.Visible = false
	nameLbl.Parent = holder

	local distLbl = Instance.new("TextLabel")
	distLbl.Name = "DistLabel"
	distLbl.Size = UDim2.new(1, 0, 0, 16)
	distLbl.Position = UDim2.fromOffset(0, 18)
	distLbl.BackgroundTransparency = 1
	distLbl.Text = "0m"
	distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	distLbl.Font = Enum.Font.Gotham
	distLbl.TextSize = 10
	distLbl.TextStrokeTransparency = 0.3
	distLbl.Visible = false
	distLbl.Parent = holder

	local boxFrame = Instance.new("Frame")
	boxFrame.Name = "BoxFrame"
	boxFrame.Size = UDim2.fromOffset(45, 65)
	boxFrame.Position = UDim2.new(0.5, -22, 0.5, -30)
	boxFrame.BackgroundTransparency = 1
	boxFrame.Visible = false
	boxFrame.Parent = holder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(0, 255, 140)
	boxStroke.Thickness = 1.5
	boxStroke.Parent = boxFrame

	return holder
end

local function removeESPStorage(player)
	local holder = shared.UltraAdmin.ESPFolder:FindFirstChild("ESP_" .. player.Name)
	if holder then
		holder:Destroy()
	end
end

-- Главный цикл обновления визуала
local function updateESP()
	Helpers.disconnect("ESP_Render")
	
	shared.UltraAdmin.Connections.ESP_Render = Services.RunService.RenderStepped:Connect(function()
		local myRoot = Helpers.getRoot(LocalPlayer)
		
		for _, plr in ipairs(Services.Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local char = Helpers.getChar(plr)
				local head = char and char:FindFirstChild("Head")
				local root = Helpers.getRoot(plr)
				
				if char and head and root then
					-- Управление Highlight
					if shared.UltraAdmin.State.ESP_Highlight then
						applyHighlight(plr)
					else
						removeHighlight(plr)
					end

					-- Управление 2D Billboard
					local holder = shared.UltraAdmin.ESPFolder:FindFirstChild("ESP_" .. plr.Name)
					if not holder then
						holder = createESPStorage(plr)
					end
					
					holder.Adornee = head
					
					local nameLbl = holder:FindFirstChild("NameLabel")
					local distLbl = holder:FindFirstChild("DistLabel")
					local boxFrame = holder:FindFirstChild("BoxFrame")

					if nameLbl then
						nameLbl.Visible = shared.UltraAdmin.State.ESP_Names
					end

					if distLbl then
						distLbl.Visible = shared.UltraAdmin.State.ESP_Distance
						if myRoot and shared.UltraAdmin.State.ESP_Distance then
							local dist = math.floor((root.Position - myRoot.Position).Magnitude)
							distLbl.Text = tostring(dist) .. " studs"
						end
					end

					if boxFrame then
						boxFrame.Visible = shared.UltraAdmin.State.ESP_Boxes
					end
				else
					removeHighlight(plr)
					removeESPStorage(plr)
				end
			end
		end
	end)
end

-- Добавление элементов на страницу Visuals
UI.createToggle(PageVisuals, "🔮 Обводка сквозь стены (Highlight)", false, function(state)
	shared.UltraAdmin.State.ESP_Highlight = state
	if not state then
		for _, plr in ipairs(Services.Players:GetPlayers()) do
			removeHighlight(plr)
		end
	end
	updateESP()
end)

UI.createToggle(PageVisuals, "📦 Отрисовка Боксов (2D Boxes)", false, function(state)
	shared.UltraAdmin.State.ESP_Boxes = state
	updateESP()
end)

UI.createToggle(PageVisuals, "🏷️ Отображение Имен (Player Names)", false, function(state)
	shared.UltraAdmin.State.ESP_Names = state
	updateESP()
end)

UI.createToggle(PageVisuals, "📏 Дистанция до целей (Distance)", false, function(state)
	shared.UltraAdmin.State.ESP_Distance = state
	updateESP()
end)

UI.createBtn(PageVisuals, "🧹 Очистить и перезагрузить ESP", Color3.fromRGB(40, 50, 70), function()
	for _, plr in ipairs(Services.Players:GetPlayers()) do
		removeHighlight(plr)
		removeESPStorage(plr)
	end
	updateESP()
	Helpers.notify("ESP Engine", "Все визуалы успешно очищены и пересозданы!", 2)
end)

-- Авто-очистка при выходе игроков
Services.Players.PlayerRemoving:Connect(function(plr)
	removeHighlight(plr)
	removeESPStorage(plr)
end)

Helpers.notify("Ultra Admin", "Часть 2 (ESP & Visuals) успешно активирована!", 3)
print("⚡ Ultra Admin Panel v18.0 [Часть 2 из 5] полностью готова!")
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v18.0 [PART 3: PLAYERS & TELEPORTS]
--==================================================================

if not shared.UltraAdmin or not shared.UltraAdmin.Helpers then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 (Ядро UI)!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Helpers = shared.UltraAdmin.Helpers
local UI = shared.UltraAdmin.UI

-- Состояния Вкладки 3
shared.UltraAdmin.State.Spectating = false
shared.UltraAdmin.State.SavedCheckpoint = nil
shared.UltraAdmin.State.TargetPlayer = nil

-- Создаем Вкладку 3
local PagePlayers = UI.createTab("👥 Игроки / ТП", "Players")

-- Поиск игрока по части имени
local function findPlayer(query)
	if not query or query == "" then return nil end
	query = string.lower(query)
	for _, plr in ipairs(Services.Players:GetPlayers()) do
		if string.find(string.lower(plr.Name), query) or string.find(string.lower(plr.DisplayName), query) then
			return plr
		end
	end
	return nil
end

-- UI Поле ввода имени игрока
local targetInputHolder = Instance.new("Frame")
targetInputHolder.Size = UDim2.new(1, 0, 0, 40)
targetInputHolder.BackgroundColor3 = Color3.fromRGB(16, 20, 27)
targetInputHolder.Parent = PagePlayers

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 6)
targetCorner.Parent = targetInputHolder

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(1, -20, 1, 0)
targetBox.Position = UDim2.fromOffset(10, 0)
targetBox.BackgroundTransparency = 1
targetBox.PlaceholderText = "Введите имя игрока (Part/Full)..."
targetBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 125)
targetBox.Text = ""
targetBox.TextColor3 = Color3.fromRGB(0, 255, 140)
targetBox.Font = Enum.Font.GothamBold
targetBox.TextSize = 11
targetBox.TextXAlignment = Enum.TextXAlignment.Left
targetBox.Parent = targetInputHolder

targetBox.FocusLost:Connect(function()
	local found = findPlayer(targetBox.Text)
	if found then
		shared.UltraAdmin.State.TargetPlayer = found
		Helpers.notify("Игрок найден", "Выбран: " .. found.DisplayName .. " (@" .. found.Name .. ")", 2)
	else
		shared.UltraAdmin.State.TargetPlayer = nil
		if targetBox.Text ~= "" then
			Helpers.notify("Ошибка", "Игрок не найден на сервере!", 2)
		end
	end
end)

-- Инструменты взаимодействия
UI.createBtn(PagePlayers, "🚀 Телепорт к игроку (TP)", Color3.fromRGB(20, 35, 50), function()
	local target = shared.UltraAdmin.State.TargetPlayer or findPlayer(targetBox.Text)
	if not target then
		Helpers.notify("Ошибка", "Укажите корректного игрока!", 2)
		return
	end
	
	local myRoot = Helpers.getRoot(LocalPlayer)
	local targetRoot = Helpers.getRoot(target)
	
	if myRoot and targetRoot then
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
		Helpers.notify("Телепорт", "Вы телепортировались к " .. target.DisplayName, 2)
	end
end)

UI.createBtn(PagePlayers, "🧲 Притянуть к себе (Bring / Local CFrame)", Color3.fromRGB(20, 35, 50), function()
	local target = shared.UltraAdmin.State.TargetPlayer or findPlayer(targetBox.Text)
	if not target then
		Helpers.notify("Ошибка", "Укажите корректного игрока!", 2)
		return
	end

	local myRoot = Helpers.getRoot(LocalPlayer)
	local targetRoot = Helpers.getRoot(target)

	if myRoot and targetRoot then
		targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
		Helpers.notify("Bring", "Попытка притянуть " .. target.DisplayName, 2)
	end
end)

UI.createToggle(PagePlayers, "👁️ Слежка за игроком (Spectate)", false, function(state)
	shared.UltraAdmin.State.Spectating = state
	if state then
		local target = shared.UltraAdmin.State.TargetPlayer or findPlayer(targetBox.Text)
		if not target then
			Helpers.notify("Ошибка", "Игрок не выбран!", 2)
			shared.UltraAdmin.State.Spectating = false
			return
		end
		local targetHum = Helpers.getHum(target)
		if targetHum then
			Camera.CameraSubject = targetHum
			Helpers.notify("Spectate", "Слежение за: " .. target.DisplayName, 2)
		end
	else
		local myHum = Helpers.getHum(LocalPlayer)
		if myHum then
			Camera.CameraSubject = myHum
			Helpers.notify("Spectate", "Слежение отключено", 2)
		end
	end
end)

-- Система Чекпоинтов
UI.createBtn(PagePlayers, "📌 Сохранить Точку (Save Checkpoint)", Color3.fromRGB(30, 60, 45), function()
	local root = Helpers.getRoot(LocalPlayer)
	if root then
		shared.UltraAdmin.State.SavedCheckpoint = root.CFrame
		Helpers.notify("Чекпоинт", "Текущая позиция сохранена!", 2)
	end
end)

UI.createBtn(PagePlayers, "📍 Загрузить Точку (TP to Checkpoint)", Color3.fromRGB(30, 60, 45), function()
	local root = Helpers.getRoot(LocalPlayer)
	if root then
		if shared.UltraAdmin.State.SavedCheckpoint then
			root.CFrame = shared.UltraAdmin.State.SavedCheckpoint
			Helpers.notify("Чекпоинт", "Телепортировано на сохраненную позицию!", 2)
		else
			Helpers.notify("Ошибка", "Сначала сохраните чекпоинт!", 2)
		end
	end
end)

-- Быстрые телепорты по картам / спавнам
UI.createBtn(PagePlayers, "🌀 Телепорт в Центр Карты (0, 50, 0)", Color3.fromRGB(40, 40, 60), function()
	local root = Helpers.getRoot(LocalPlayer)
	if root then
		root.CFrame = CFrame.new(0, 50, 0)
		Helpers.notify("Телепорт", "Перемещение в центр карты", 2)
	end
end)

UI.createBtn(PagePlayers, "🎲 К случайному игроку", Color3.fromRGB(40, 40, 60), function()
	local allPlrs = Services.Players:GetPlayers()
	local validPlrs = {}
	for _, p in ipairs(allPlrs) do
		if p ~= LocalPlayer and Helpers.getRoot(p) then
			table.insert(validPlrs, p)
		end
	end
	
	if #validPlrs > 0 then
		local randomPlr = validPlrs[math.random(1, #validPlrs)]
		local myRoot = Helpers.getRoot(LocalPlayer)
		local targetRoot = Helpers.getRoot(randomPlr)
		if myRoot and targetRoot then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
			Helpers.notify("Телепорт", "Случайный ТП к " .. randomPlr.DisplayName, 2)
		end
	else
		Helpers.notify("Ошибка", "Нет доступных игроков!", 2)
	end
end)

Helpers.notify("Ultra Admin", "Часть 3 (Управление игроками) загружена!", 3)
print("⚡ Ultra Admin Panel v18.0 [Часть 3 из 5] полностью готова!")
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v18.0 [PART 4: ENVIRONMENT & FUN]
--==================================================================

if not shared.UltraAdmin or not shared.UltraAdmin.Helpers then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 (Ядро UI)!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	Lighting = game:GetService("Lighting"),
	TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Helpers = shared.UltraAdmin.Helpers
local UI = shared.UltraAdmin.UI

-- Инициализация состояний 4 части
shared.UltraAdmin.State.RainbowCharacter = false
shared.UltraAdmin.State.Spinbot = false
shared.UltraAdmin.State.Freeze = false
shared.UltraAdmin.State.Fullbright = false
shared.UltraAdmin.Config.SpinSpeed = 30

-- Создание вкладок для Окружения и Веселья
local PageEnv = UI.createTab("🌍 Окружение", "Environment")
local PageFun = UI.createTab("🎉 Веселье", "Fun")

-- ==========================================
-- СЕКЦИЯ 1: УПРАВЛЕНИЕ ОКРУЖЕНИЕМ (LIGHTING)
-- ==========================================

UI.createToggle(PageEnv, "☀️ Вечный День (Time = 14:00)", false, function(state)
	Helpers.disconnect("DayLoop")
	if state then
		shared.UltraAdmin.Connections.DayLoop = Services.RunService.RenderStepped:Connect(function()
			Services.Lighting.ClockTime = 14
		end)
	else
		Services.Lighting.ClockTime = 12
	end
end)

UI.createToggle(PageEnv, "🌙 Вечная Ночь (Time = 00:00)", false, function(state)
	Helpers.disconnect("NightLoop")
	if state then
		shared.UltraAdmin.Connections.NightLoop = Services.RunService.RenderStepped:Connect(function()
			Services.Lighting.ClockTime = 0
		end)
	else
		Services.Lighting.ClockTime = 12
	end
end)

UI.createSlider(PageEnv, "Время суток (ClockTime)", 0, 24, 12, function(val)
	Services.Lighting.ClockTime = val
end)

UI.createSlider(PageEnv, "Яркость мира (Brightness)", 0, 10, 2, function(val)
	Services.Lighting.Brightness = val
end)

UI.createSlider(PageEnv, "Плотность Тумана (FogEnd)", 100, 100000, 100000, function(val)
	Services.Lighting.FogEnd = val
end)

UI.createBtn(PageEnv, "🌫️ Полное удаление тумана и размытия", Color3.fromRGB(30, 45, 60), function()
	Services.Lighting.FogStart = 0
	Services.Lighting.FogEnd = 9e9
	for _, child in ipairs(Services.Lighting:GetChildren()) do
		if child:IsA("Atmosphere") or child:IsA("DepthOfFieldEffect") or child:IsA("BlurEffect") then
			child.Enabled = false
		end
	end
	Helpers.notify("Окружение", "Туман и эффекты размытия успешно отключены!", 2)
end)

UI.createBtn(PageEnv, "🎨 Кислотные Шейдеры (ColorCorrection)", Color3.fromRGB(60, 30, 70), function()
	local cc = Services.Lighting:FindFirstChild("UltraAdmin_CC")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "UltraAdmin_CC"
		cc.Parent = Services.Lighting
	end
	cc.Saturation = 2
	cc.Contrast = 0.5
	cc.TintColor = Color3.fromRGB(255, 200, 230)
	Helpers.notify("Шейдеры", "Применены кастомные цветовые настройки!", 2)
end)

UI.createBtn(PageEnv, "🔄 Сброс всех настроек освещения", Color3.fromRGB(70, 30, 35), function()
	Helpers.disconnect("DayLoop")
	Helpers.disconnect("NightLoop")
	Services.Lighting.ClockTime = 14
	Services.Lighting.Brightness = 2
	Services.Lighting.GlobalShadows = true
	Services.Lighting.FogEnd = 100000
	local cc = Services.Lighting:FindFirstChild("UltraAdmin_CC")
	if cc then cc:Destroy() end
	Helpers.notify("Окружение", "Настройки освещения сброшены по умолчанию.", 2)
end)


-- ==========================================
-- СЕКЦИЯ 2: ВЕСЕЛЬЕ И ИНСТРУМЕНТЫ (FUN ENGINE)
-- ==========================================

-- 1. Spinbot (Вращение персонажа)
UI.createToggle(PageFun, "🌀 Быстрое Вращение (Spinbot)", false, function(state)
	shared.UltraAdmin.State.Spinbot = state
	Helpers.disconnect("Spinbot")
	if state then
		shared.UltraAdmin.Connections.Spinbot = Services.RunService.RenderStepped:Connect(function(dt)
			local root = Helpers.getRoot(LocalPlayer)
			if root then
				local speed = shared.UltraAdmin.Config.SpinSpeed or 30
				root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed), 0)
			end
		end)
	end
end)

UI.createSlider(PageFun, "Скорость вращения (Spin Speed)", 5, 100, 30, function(val)
	shared.UltraAdmin.Config.SpinSpeed = val
end)

-- 2. Радужная подсветка персонажа
UI.createToggle(PageFun, "🌈 Радужный Персонаж (Rainbow Aura)", false, function(state)
	shared.UltraAdmin.State.RainbowCharacter = state
	Helpers.disconnect("RainbowChar")
	
	if state then
		local hue = 0
		shared.UltraAdmin.Connections.RainbowChar = Services.RunService.RenderStepped:Connect(function()
			hue = hue + 0.005
			if hue > 1 then hue = 0 end
			local color = Color3.fromHSV(hue, 1, 1)
			
			local char = Helpers.getChar(LocalPlayer)
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.Color = color
					end
				end
			end
		end)
	end
end)

-- 3. Эффект Заморозки
UI.createToggle(PageFun, "🧊 Ледяная Заморозка (Ice Freeze)", false, function(state)
	shared.UltraAdmin.State.Freeze = state
	local root = Helpers.getRoot(LocalPlayer)
	local char = Helpers.getChar(LocalPlayer)
	
	if root then
		root.Anchored = state
	end
	
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if state then
					part.Material = Enum.Material.Ice
					part.Color = Color3.fromRGB(120, 210, 255)
				else
					part.Material = Enum.Material.Plastic
				end
			end
		end
	end
end)

-- 4. Визуальный Взрыв с ударной волной
UI.createBtn(PageFun, "💥 Совершить Взрыв (Visual Explosion FX)", Color3.fromRGB(80, 40, 20), function()
	local root = Helpers.getRoot(LocalPlayer)
	if not root then return end
	
	local pos = root.Position
	
	-- Визуальный партикл взрыва
	local exp = Instance.new("Explosion")
	exp.Position = pos
	exp.BlastPressure = 0
	exp.DestroyPartRadiusHit = 0
	exp.Parent = workspace
	
	-- Кастомная анимированная сфера
	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(2, 2, 2)
	sphere.Position = pos
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.Material = Enum.Material.Neon
	sphere.Color = Color3.fromRGB(255, 100, 30)
	sphere.Transparency = 0.2
	sphere.Parent = workspace
	
	task.spawn(function()
		for i = 1, 25 do
			sphere.Size = sphere.Size + Vector3.new(2, 2, 2)
			sphere.Transparency = sphere.Transparency + 0.03
			task.wait(0.015)
		end
		sphere:Destroy()
	end)
	
	Helpers.notify("Fun FX", "Эффект взрыва успешно сгенерирован!", 2)
end)

-- 5. Тряска камеры (Camera Shake)
UI.createBtn(PageFun, "📳 Имитация Землетрясения (Cam Shake)", Color3.fromRGB(60, 40, 70), function()
	local cam = workspace.CurrentCamera
	task.spawn(function()
		for i = 1, 30 do
			local rx = math.random(-5, 5) / 10
			local ry = math.random(-5, 5) / 10
			cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(rx), math.rad(ry), 0)
			task.wait(0.02)
		end
	end)
	Helpers.notify("Fun FX", "Эффект землетрясения запущен!", 2)
end)

Helpers.notify("Ultra Admin", "Часть 4 (Окружение и Веселье) загружена!", 3)
print("⚡ Ultra Admin Panel v18.0 [Часть 4 из 5] полностью готова!")
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v18.0 [PART 5: SETTINGS & UTILS]
--==================================================================

if not shared.UltraAdmin or not shared.UltraAdmin.Helpers then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 (Ядро UI)!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	Lighting = game:GetService("Lighting"),
	TeleportService = game:GetService("TeleportService"),
	HttpService = game:GetService("HttpService"),
	UserInputService = game:GetService("UserInputService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Helpers = shared.UltraAdmin.Helpers
local UI = shared.UltraAdmin.UI

-- Инициализация вкладок Настроек и Сервера
local PageServer = UI.createTab("🛠️ Сервер", "Server")
local PageSettings = UI.createTab("⚙️ Настройки", "Settings")

-- ==========================================
-- СЕКЦИЯ 1: УТИЛИТЫ СЕРВЕРА (SERVER UTILS)
-- ==========================================

UI.createBtn(PageServer, "🔄 Переподключиться (Rejoin Server)", Color3.fromRGB(35, 50, 75), function()
	Helpers.notify("Сервер", "Переподключение к текущему серверу...", 3)
	Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

UI.createBtn(PageServer, "🔀 Сменить Сервер (Server Hop)", Color3.fromRGB(35, 60, 50), function()
	Helpers.notify("Сервер", "Поиск доступного сервера...", 3)
	pcall(function()
		local sfUrl = "https://games.roblox.com/v1/places/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
		local req = game:HttpGet(sfUrl)
		local data = Services.HttpService:JSONDecode(req)
		
		if data and data.data then
			for _, server in ipairs(data.data) do
				if server.id ~= game.JobId and server.playing < server.maxPlayers then
					Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
					return
				end
			end
		end
		Helpers.notify("Ошибка", "Не удалось найти подходящий сервер!", 2)
	end)
end)

UI.createBtn(PageServer, "📋 Копировать JobID", Color3.fromRGB(50, 40, 60), function()
	if setclipboard then
		setclipboard(tostring(game.JobId))
		Helpers.notify("Утилиты", "JobID скопирован в буфер обмена!", 2)
	else
		Helpers.notify("Ошибка", "Ваш эксплоит не поддерживает setclipboard", 2)
	end
end)

UI.createBtn(PageServer, "⚡ Оптимизация FPS (FPS Booster)", Color3.fromRGB(40, 60, 40), function()
	pcall(function()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v:Destroy()
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
				v.Enabled = false
			end
		end
		Services.Lighting.GlobalShadows = false
		Helpers.notify("FPS Booster", "Текстуры и эффекты упрощены!", 3)
	end)
end)

-- ==========================================
-- СЕКЦИЯ 2: TONKIE НАСТРОЙКИ (SETTINGS & CONFIG)
-- ==========================================

UI.createToggle(PageSettings, "💡 Режим Ночного Зрения (Fullbright)", false, function(state)
	shared.UltraAdmin.State.Fullbright = state
	Helpers.disconnect("FullbrightLoop")
	
	if state then
		shared.UltraAdmin.Connections.FullbrightLoop = Services.RunService.RenderStepped:Connect(function()
			Services.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Services.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
			Services.Lighting.Brightness = 2
		end)
	else
		Services.Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
end)

UI.createSlider(PageSettings, "Скорость Полета (Fly Speed)", 10, 300, 50, function(val)
	shared.UltraAdmin.Config.FlySpeed = val
end)

UI.createSlider(PageSettings, "Скорость Бега по умолчанию", 16, 250, 16, function(val)
	shared.UltraAdmin.Config.WalkSpeed = val
	local hum = Helpers.getHum(LocalPlayer)
	if hum then
		hum.WalkSpeed = val
	end
end)

UI.createSlider(PageSettings, "Высота Прыжка по умолчанию", 50, 300, 50, function(val)
	shared.UltraAdmin.Config.JumpPower = val
	local hum = Helpers.getHum(LocalPlayer)
	if hum then
		hum.JumpPower = val
	end
end)

-- ==========================================
-- СЕКЦИЯ 3: ПОЛНАЯ ВЫГРУЗКА И ЗАКРЫТИЕ (UNLOAD)
-- ==========================================

UI.createBtn(PageSettings, "⛔ Выгрузить скрипт полностью (Unload Script)", Color3.fromRGB(120, 30, 30), function()
	-- 1. Отключение всех RenderStepped/Stepped соединений
	for name, conn in pairs(shared.UltraAdmin.Connections) do
		if conn then
			conn:Disconnect()
		end
	end
	shared.UltraAdmin.Connections = {}

	-- 2. Очистка ESP и Визуалов
	if shared.UltraAdmin.ESPFolder then
		shared.UltraAdmin.ESPFolder:Destroy()
	end
	for _, plr in ipairs(Services.Players:GetPlayers()) do
		local char = Helpers.getChar(plr)
		if char then
			local hl = char:FindFirstChild("UltraAdmin_Highlight")
			if hl then hl:Destroy() end
		end
	end

	-- 3. Восстановление параметров персонажа
	local root = Helpers.getRoot(LocalPlayer)
	local hum = Helpers.getHum(LocalPlayer)
	if root then root.Anchored = false end
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		Camera.CameraSubject = hum
	end

	-- 4. Удаление UI
	if shared.UltraAdmin.ScreenGui then
		shared.UltraAdmin.ScreenGui:Destroy()
	end

	-- 5. Сброс shared таблицы
	shared.UltraAdmin = nil

	print("🔴 Ultra Admin Panel v18.0 полностью выгружена из памяти!")
end)

Helpers.notify("Ultra Admin", "Все 5 частей скрипта успешно инициализированы!", 4)
print("🚀 [ALL PARTS LOADED] Ultra Admin Panel v18.0 готова к работе!")
