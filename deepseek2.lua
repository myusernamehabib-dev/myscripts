--[[
	ULTRA ADMIN PANEL v18.0 — Часть 1: Ядро, UI и Персонаж
	Запускать ПЕРВОЙ!
]]

-- ===== СЕРВИСЫ =====
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
	Lighting = game:GetService("Lighting"),
	Workspace = game:GetService("Workspace"),
	CoreGui = game:GetService("CoreGui"),
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Services.Workspace.CurrentCamera

-- Очистка старых копий
if PlayerGui:FindFirstChild("UltraAdminPanelV18") then
	PlayerGui.UltraAdminPanelV18:Destroy()
end

-- ===== ОБЩЕЕ ОКРУЖЕНИЕ (shared) =====
local Env = {
	Services = Services,
	LocalPlayer = LocalPlayer,
	PlayerGui = PlayerGui,
	Camera = Camera,
	State = {},
	Connections = {},
	Loops = {},
	Pages = {},
	SideButtons = {},
	UI = {},
	Features = {},
	Settings = {
		WalkSpeed = 50,
		JumpPower = 100,
		FlySpeed = 75,
	},
}

shared.UltraAdmin = Env

-- ===== ХЕЛПЕРЫ =====
function Env:GetChar(player)
	player = player or LocalPlayer
	return player.Character
end

function Env:GetHumanoid(player)
	local char = self:GetChar(player)
	return char and char:FindFirstChildOfClass("Humanoid")
end

function Env:GetRoot(player)
	local char = self:GetChar(player)
	return char and char:FindFirstChild("HumanoidRootPart")
end

function Env:Tween(obj, props, time)
	self.Services.TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Env:RegisterFeature(name, enableFunc, disableFunc)
	self.Features[name] = {
		Enable = enableFunc,
		Disable = disableFunc,
	}
end

function Env:StartLoop(name, func)
	self:StopLoop(name)
	self.Loops[name] = self.Services.RunService.Heartbeat:Connect(func)
end

function Env:StopLoop(name)
	if self.Loops[name] then
		self.Loops[name]:Disconnect()
		self.Loops[name] = nil
	end
end

function Env:StopAllLoops()
	for name, conn in pairs(self.Loops) do
		conn:Disconnect()
	end
	self.Loops = {}
end

function Env:ConnectEvent(name, event, func)
	self:DisconnectEvent(name)
	self.Connections[name] = event:Connect(func)
end

function Env:DisconnectEvent(name)
	if self.Connections[name] then
		self.Connections[name]:Disconnect()
		self.Connections[name] = nil
	end
end

function Env:DisconnectAllEvents()
	for name, conn in pairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}
end

-- ===== СОЗДАНИЕ ОСНОВНОГО GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraAdminPanelV18"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Кнопка открытия
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(56, 56)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
OpenBtn.Text = "🛡️"
OpenBtn.TextSize = 26
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 255, 130)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenBtn

-- Главное окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 420)
Main.Position = UDim2.new(0.5, -320, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 13, 19)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(30, 40, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

OpenBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTRA ADMIN PANEL v18.0"
Title.TextColor3 = Color3.fromRGB(245, 248, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

-- Сайдбар
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -62)
Sidebar.Position = UDim2.fromOffset(10, 56)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 18, 25)
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = Sidebar

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -154, 1, -62)
Content.Position = UDim2.fromOffset(144, 56)
Content.BackgroundTransparency = 1
Content.Parent = Main

Env.Main = Main
Env.OpenBtn = OpenBtn
Env.Sidebar = Sidebar
Env.Content = Content

-- ===== СТРАНИЦЫ И ТАБЫ =====
function Env:CreatePage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Content

	local pad = Instance.new("UIPadding")
	pad.PaddingRight = UDim.new(0, 6)
	pad.Parent = page

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = page

	self.Pages[name] = page
	return page
end

function Env:CreateTab(text, pageName)
	local page = self:CreatePage(pageName)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 160, 175)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = Sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	self.SideButtons[pageName] = btn

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(self.Pages) do
			p.Visible = false
		end
		for _, b in pairs(self.SideButtons) do
			b.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
			b.TextColor3 = Color3.fromRGB(150, 160, 175)
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.CurrentPage = pageName
	end)

	return page
end

-- ===== UI КОМПОНЕНТЫ =====
function Env.UI:CreateToggle(parent, text, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
	holder.Parent = parent

	local holderCorner = Instance.new("UICorner")
	holderCorner.CornerRadius = UDim.new(0, 10)
	holderCorner.Parent = holder

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -65, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(235, 240, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(40, 22)
	toggle.Position = UDim2.new(1, -50, 0.5, -11)
	if default then
		toggle.BackgroundColor3 = Color3.fromRGB(0, 190, 110)
	else
		toggle.BackgroundColor3 = Color3.fromRGB(45, 52, 68)
	end
	toggle.Text = ""
	toggle.Parent = holder

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	if default then
		knob.Position = UDim2.new(1, -18, 0.5, -8)
	else
		knob.Position = UDim2.new(0, 2, 0.5, -8)
	end
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = toggle

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		if state then
			Env:Tween(toggle, { BackgroundColor3 = Color3.fromRGB(0, 190, 110) }, 0.15)
			Env:Tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.15)
		else
			Env:Tween(toggle, { BackgroundColor3 = Color3.fromRGB(45, 52, 68) }, 0.15)
			Env:Tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.15)
		end
		callback(state)
	end)

	return toggle
end

function Env.UI:CreateButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = color or Color3.fromRGB(22, 28, 38)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 245, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(callback)
	return btn
end

function Env.UI:CreateSectionLabel(parent, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(180, 190, 200)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = parent
	return lbl
end

-- ===== СОЗДАНИЕ СТРАНИЦ =====
local PageHome = Env:CreateTab("🏠 Персонаж", "Home")
local PagePlayers = Env:CreateTab("👥 Игроки", "Players")
local PageVisual = Env:CreateTab("👁️ Визуал", "Visual")
local PageTeleport = Env:CreateTab("🌐 Телепорт", "Teleport")
local PageCheckpoints = Env:CreateTab("📌 Чекпоинты", "Checkpoints")
local PageEnvironment = Env:CreateTab("🌍 Окружение", "Environment")
local PageFun = Env:CreateTab("🎉 Веселье", "Fun")

-- Активация первой страницы
PageHome.Visible = true
Env.SideButtons.Home.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
Env.SideButtons.Home.TextColor3 = Color3.fromRGB(255, 255, 255)
Env.CurrentPage = "Home"

-- ===== ФУНКЦИИ ФИЧ =====
-- Fly
Env:RegisterFeature("Fly", function()
	local hum = Env:GetHumanoid()
	local root = Env:GetRoot()
	if not hum or not root then return end
	hum.PlatformStand = true
	Env:StartLoop("Fly", function()
		if not Env.State.Fly then return end
		local dir = hum.MoveDirection
		if dir.Magnitude > 0 then
			root.AssemblyLinearVelocity = dir.Unit * Env.Settings.FlySpeed
		else
			root.AssemblyLinearVelocity = Vector3.zero
		end
		root.CFrame = CFrame.lookAt(root.Position, root.Position + Env.Camera.CFrame.LookVector)
	end)
end, function()
	Env:StopLoop("Fly")
	local root = Env:GetRoot()
	if root then root.AssemblyLinearVelocity = Vector3.zero end
	local hum = Env:GetHumanoid()
	if hum then hum.PlatformStand = false end
end)

-- Speed
Env:RegisterFeature("Speed", function()
	local hum = Env:GetHumanoid()
	if hum then hum.WalkSpeed = Env.Settings.WalkSpeed end
end, function()
	local hum = Env:GetHumanoid()
	if hum then hum.WalkSpeed = 16 end
end)

-- Super Jump
Env:RegisterFeature("SuperJump", function()
	local hum = Env:GetHumanoid()
	if hum then hum.JumpPower = Env.Settings.JumpPower end
end, function()
	local hum = Env:GetHumanoid()
	if hum then hum.JumpPower = 50 end
end)

-- Noclip
Env:RegisterFeature("Noclip", function()
	Env:StartLoop("Noclip", function()
		local char = Env:GetChar()
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
end, function()
	Env:StopLoop("Noclip")
end)

-- Infinite Jump
Env:RegisterFeature("InfiniteJump", function()
	Env:ConnectEvent("InfJump", Env.Services.UserInputService.JumpRequest, function()
		local hum = Env:GetHumanoid()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end, function()
	Env:DisconnectEvent("InfJump")
end)

-- ===== ПЕРСОНАЖ — UI =====
Env.UI:CreateToggle(PageHome, "✈️ Свободный полёт", false, function(state)
	Env.State.Fly = state
	if state then
		Env.Features.Fly.Enable()
	else
		Env.Features.Fly.Disable()
	end
end)

Env.UI:CreateToggle(PageHome, "⚡ Ускоренный бег (Speed x3)", false, function(state)
	Env.State.Speed = state
	if state then
		Env.Features.Speed.Enable()
	else
		Env.Features.Speed.Disable()
	end
end)

Env.UI:CreateToggle(PageHome, "🦘 Супер прыжок", false, function(state)
	Env.State.SuperJump = state
	if state then
		Env.Features.SuperJump.Enable()
	else
		Env.Features.SuperJump.Disable()
	end
end)

Env.UI:CreateToggle(PageHome, "👻 Noclip (сквозь стены)", false, function(state)
	Env.State.Noclip = state
	if state then
		Env.Features.Noclip.Enable()
	else
		Env.Features.Noclip.Disable()
	end
end)

Env.UI:CreateToggle(PageHome, "♾️ Бесконечный прыжок", false, function(state)
	Env.State.InfiniteJump = state
	if state then
		Env.Features.InfiniteJump.Enable()
	else
		Env.Features.InfiniteJump.Disable()
	end
end)

Env.UI:CreateButton(PageHome, "🔄 Рестарт персонажа", Color3.fromRGB(150, 40, 50), function()
	local hum = Env:GetHumanoid()
	if hum then hum.Health = 0 end
end)

print("✅ Часть 1 загружена: Ядро, UI, Персонаж")
--[[
	ULTRA ADMIN PANEL v18.0 — Часть 2: Визуал и ESP
	Запускать ПОСЛЕ Части 1
]]

if not shared.UltraAdmin then
	warn("⚠️ Сначала запустите Часть 1!")
	return
end

local Env = shared.UltraAdmin
local Services = Env.Services
local Players = Services.Players
local RunService = Services.RunService
local LocalPlayer = Env.LocalPlayer

local ESPObjects = {}

local ESP = {
	Enabled = false,
	Boxes = false,
	Names = false,
	Health = false,
	Distance = false,
	Color = Color3.fromRGB(0, 255, 140),
}

-- ===== ОЧИСТКА ESP =====
local function clearESP()
	for _, data in pairs(ESPObjects) do
		for _, obj in pairs(data) do
			if obj and obj.Parent then
				obj:Destroy()
			end
		end
	end
	ESPObjects = {}
end

-- ===== ОБНОВЛЕНИЕ ESP =====
local function updateESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				if not ESPObjects[player] or not ESPObjects[player].highlight.Parent then
					-- Highlight
					local highlight = Instance.new("Highlight")
					highlight.Adornee = char
					highlight.FillColor = ESP.Color
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0
					highlight.Parent = char
					-- BillboardGui
					local billboard = Instance.new("BillboardGui")
					billboard.Size = UDim2.fromOffset(120, 50)
					billboard.StudsOffset = Vector3.new(0, 3.5, 0)
					billboard.Adornee = char:WaitForChild("Head", 5)
					billboard.AlwaysOnTop = true
					billboard.Parent = char
					-- SelectionBox
					local selBox = Instance.new("SelectionBox")
					selBox.Adornee = char
					selBox.Color3 = ESP.Color
					selBox.LineThickness = 0.05
					selBox.Transparency = 0.5
					selBox.Parent = char

					ESPObjects[player] = {
						highlight = highlight,
						billboard = billboard,
						selBox = selBox,
					}
				end

				local data = ESPObjects[player]
				-- Highlight видимость
				data.highlight.Enabled = ESP.Enabled
				-- SelectionBox
				data.selBox.Visible = ESP.Boxes
				data.selBox.Color3 = ESP.Color
				-- Billboard
				data.billboard.Enabled = ESP.Names or ESP.Distance
				if data.billboard.Enabled then
					local displayText = ""
					if ESP.Names then
						displayText = displayText .. player.Name
					end
					if ESP.Distance then
						local root = Env:GetRoot()
						local targetRoot = char:FindFirstChild("HumanoidRootPart")
						if root and targetRoot then
							local dist = (root.Position - targetRoot.Position).Magnitude
							displayText = displayText .. "\n" .. string.format("%.0f м", dist)
						end
					end
					-- Обновляем TextLabel внутри Billboard
					local label = data.billboard:FindFirstChildOfClass("TextLabel")
					if not label then
						label = Instance.new("TextLabel")
						label.Size = UDim2.fromScale(1, 1)
						label.BackgroundTransparency = 1
						label.TextColor3 = Color3.fromRGB(255, 255, 255)
						label.Font = Enum.Font.GothamBold
						label.TextSize = 12
						label.Parent = data.billboard
					end
					label.Text = displayText
				end
			end
		end
	end
end

-- ===== ЦИКЛ ОБНОВЛЕНИЯ ESP =====
function Env:StartESP()
	if ESP.Enabled then return end
	ESP.Enabled = true
	RunService.Heartbeat:Connect(function()
		if not ESP.Enabled then return end
		updateESP()
	end)
end

function Env:StopESP()
	ESP.Enabled = false
	clearESP()
end

-- ===== СТРОИМ UI =====
local PageVisual = Env.Pages.Visual

Env.UI:CreateSectionLabel(PageVisual, "── Основные настройки ──")

Env.UI:CreateToggle(PageVisual, "👁️ Включить ESP", false, function(state)
	ESP.Enabled = state
	if state then
		Env:StartESP()
	else
		Env:StopESP()
	end
end)

Env.UI:CreateToggle(PageVisual, "📦 Боксы (SelectionBox)", false, function(state)
	ESP.Boxes = state
end)

Env.UI:CreateToggle(PageVisual, "🏷️ Имена игроков", false, function(state)
	ESP.Names = state
end)

Env.UI:CreateToggle(PageVisual, "❤️ Здоровье (скоро)", false, function(state)
	-- Заглушка
end)

Env.UI:CreateToggle(PageVisual, "📏 Дистанция", false, function(state)
	ESP.Distance = state
end)

Env.UI:CreateButton(PageVisual, "🎨 Сменить цвет ESP", Color3.fromRGB(30, 80, 140), function()
	ESP.Color = Color3.fromHSV(math.random(), 1, 1)
end)

print("✅ Часть 2 загружена: Визуал и ESP")
--[[
	ULTRA ADMIN PANEL v18.0 — Часть 3: Игроки, Телепорт и Чекпоинты
	Запускать ПОСЛЕ Части 1
]]

if not shared.UltraAdmin then
	warn("⚠️ Сначала запустите Часть 1!")
	return
end

local Env = shared.UltraAdmin
local Services = Env.Services
local Players = Services.Players
local Workspace = Services.Workspace
local LocalPlayer = Env.LocalPlayer

-- ===== СПИСОК ИГРОКОВ =====
local PlayerScroll = Instance.new("Frame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 0)
PlayerScroll.AutomaticSize = Enum.AutomaticSize.Y
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.Parent = Env.Pages.Players

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 6)
PlayerListLayout.Parent = PlayerScroll

local function rebuildPlayerList()
	for _, child in ipairs(PlayerScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local card = Instance.new("Frame")
			card.Size = UDim2.new(1, 0, 0, 48)
			card.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
			card.Parent = PlayerScroll

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 10)
			corner.Parent = card

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -210, 1, 0)
			nameLbl.Position = UDim2.fromOffset(12, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = "👤 " .. player.DisplayName .. " (@" .. player.Name .. ")"
			nameLbl.TextColor3 = Color3.fromRGB(240, 245, 250)
			nameLbl.Font = Enum.Font.GothamBold
			nameLbl.TextSize = 11
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.Parent = card

			-- TP
			local tpBtn = Instance.new("TextButton")
			tpBtn.Size = UDim2.fromOffset(50, 28)
			tpBtn.Position = UDim2.new(1, -195, 0.5, -14)
			tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 190)
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.TextSize = 10
			tpBtn.Parent = card

			local tpCorner = Instance.new("UICorner")
			tpCorner.CornerRadius = UDim.new(0, 6)
			tpCorner.Parent = tpBtn

			tpBtn.MouseButton1Click:Connect(function()
				local targetRoot = Env:GetRoot(player)
				local myRoot = Env:GetRoot()
				if targetRoot and myRoot then
					myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 3)
				end
			end)

			-- Bring
			local bringBtn = Instance.new("TextButton")
			bringBtn.Size = UDim2.fromOffset(60, 28)
			bringBtn.Position = UDim2.new(1, -139, 0.5, -14)
			bringBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 0)
			bringBtn.Text = "Bring"
			bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			bringBtn.Font = Enum.Font.GothamBold
			bringBtn.TextSize = 10
			bringBtn.Parent = card

			local bringCorner = Instance.new("UICorner")
			bringCorner.CornerRadius = UDim.new(0, 6)
			bringCorner.Parent = bringBtn

			bringBtn.MouseButton1Click:Connect(function()
				local targetRoot = Env:GetRoot(player)
				local myRoot = Env:GetRoot()
				if targetRoot and myRoot then
					targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
				end
			end)

			-- Spectate
			local specBtn = Instance.new("TextButton")
			specBtn.Size = UDim2.fromOffset(70, 28)
			specBtn.Position = UDim2.new(1, -75, 0.5, -14)
			specBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 160)
			specBtn.Text = "Spec"
			specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			specBtn.Font = Enum.Font.GothamBold
			specBtn.TextSize = 10
			specBtn.Parent = card

			local specCorner = Instance.new("UICorner")
			specCorner.CornerRadius = UDim.new(0, 6)
			specCorner.Parent = specBtn

			specBtn.MouseButton1Click:Connect(function()
				Env.State.Spectating = not Env.State.Spectating
				if Env.State.Spectating then
					Env.State.SpectateTarget = player
					specBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
					specBtn.Text = "Unspec"
					Env:StartLoop("Spectate", function()
						if not Env.State.Spectating or not Env.State.SpectateTarget then
							Env.Camera.CameraSubject = Env:GetHumanoid()
							return
						end
						local targetHum = Env.State.SpectateTarget.Character and Env.State.SpectateTarget.Character:FindFirstChildOfClass("Humanoid")
						if targetHum then
							Env.Camera.CameraSubject = targetHum
						end
					end)
				else
					Env.State.SpectateTarget = nil
					Env.Camera.CameraSubject = Env:GetHumanoid()
					specBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 160)
					specBtn.Text = "Spec"
					Env:StopLoop("Spectate")
				end
			end)
		end
	end
end

Env.UI:CreateButton(Env.Pages.Players, "🔄 Обновить список", Color3.fromRGB(0, 130, 90), rebuildPlayerList)
rebuildPlayerList()

Players.PlayerAdded:Connect(rebuildPlayerList)
Players.PlayerRemoving:Connect(rebuildPlayerList)

-- ===== ТЕЛЕПОРТ ПО ЗОНАМ =====
local WorldScroll = Instance.new("Frame")
WorldScroll.Size = UDim2.new(1, 0, 0, 0)
WorldScroll.AutomaticSize = Enum.AutomaticSize.Y
WorldScroll.BackgroundTransparency = 1
WorldScroll.Parent = Env.Pages.Teleport

local WorldListLayout = Instance.new("UIListLayout")
WorldListLayout.Padding = UDim.new(0, 6)
WorldListLayout.Parent = WorldScroll

local function scanWorlds()
	for _, child in ipairs(WorldScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local seen = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			local lower = obj.Name:lower()
			if (lower:find("spawn") or lower:find("world") or lower:find("zone") or lower:find("portal") or lower:find("base")) and not seen[obj.Name] then
				seen[obj.Name] = true
				local cf
				if obj:IsA("BasePart") then
					cf = obj.CFrame
				else
					cf = obj:GetPivot()
				end
				Env.UI:CreateButton(WorldScroll, "🚀 " .. obj.Name, Color3.fromRGB(25, 45, 65), function()
					local root = Env:GetRoot()
					if root then
						root.CFrame = cf + Vector3.new(0, 5, 0)
					end
				end)
			end
		end
	end
end

Env.UI:CreateButton(Env.Pages.Teleport, "🔄 Сканировать зоны", Color3.fromRGB(0, 130, 90), scanWorlds)
scanWorlds()

-- ===== ЧЕКПОИНТЫ =====
local CheckpointsList = {}

local PointsScroll = Instance.new("Frame")
PointsScroll.Size = UDim2.new(1, 0, 0, 0)
PointsScroll.AutomaticSize = Enum.AutomaticSize.Y
PointsScroll.BackgroundTransparency = 1
PointsScroll.Parent = Env.Pages.Checkpoints

local PointsLayout = Instance.new("UIListLayout")
PointsLayout.Padding = UDim.new(0, 6)
PointsLayout.Parent = PointsScroll

local function rebuildPointsUI()
	for _, child in ipairs(PointsScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for name, cf in pairs(CheckpointsList) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 38)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
		card.Parent = PointsScroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -90, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "📌 " .. name
		lbl.TextColor3 = Color3.fromRGB(240, 245, 250)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = card

		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.fromOffset(36, 26)
		tpBtn.Position = UDim2.new(1, -80, 0.5, -13)
		tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
		tpBtn.Text = "TP"
		tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 10
		tpBtn.Parent = card

		local tpCorner = Instance.new("UICorner")
		tpCorner.CornerRadius = UDim.new(0, 6)
		tpCorner.Parent = tpBtn

		tpBtn.MouseButton1Click:Connect(function()
			local root = Env:GetRoot()
			if root then root.CFrame = cf end
		end)

		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.fromOffset(36, 26)
		delBtn.Position = UDim2.new(1, -40, 0.5, -13)
		delBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
		delBtn.Text = "✕"
		delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		delBtn.Font = Enum.Font.GothamBold
		delBtn.TextSize = 11
		delBtn.Parent = card

		local delCorner = Instance.new("UICorner")
		delCorner.CornerRadius = UDim.new(0, 6)
		delCorner.Parent = delBtn

		delBtn.MouseButton1Click:Connect(function()
			CheckpointsList[name] = nil
			rebuildPointsUI()
		end)
	end
end

Env.UI:CreateButton(Env.Pages.Checkpoints, "➕ Сохранить позицию", Color3.fromRGB(0, 150, 100), function()
	local root = Env:GetRoot()
	if root then
		local count = 0
		for _ in pairs(CheckpointsList) do count = count + 1 end
		CheckpointsList["Точка " .. (count + 1)] = root.CFrame
		rebuildPointsUI()
	end
end)

print("✅ Часть 3 загружена: Игроки, Телепорт, Чекпоинты")
--[[
	ULTRA ADMIN PANEL v18.0 — Часть 4: Окружение и Веселье
	Запускать ПОСЛЕ Части 1
]]

if not shared.UltraAdmin then
	warn("⚠️ Сначала запустите Часть 1!")
	return
end

local Env = shared.UltraAdmin
local Services = Env.Services
local Lighting = Services.Lighting
local RunService = Services.RunService
local LocalPlayer = Env.LocalPlayer

-- ===== ОКРУЖЕНИЕ =====
Env.UI:CreateSectionLabel(Env.Pages.Environment, "── Освещение ──")

Env.UI:CreateToggle(Env.Pages.Environment, "🌙 Вечная ночь", false, function(state)
	if state then
		Lighting.ClockTime = 0
	else
		Lighting.ClockTime = 14
	end
end)

Env.UI:CreateToggle(Env.Pages.Environment, "☀️ Вечный день", false, function(state)
	if state then
		Lighting.ClockTime = 14
	else
		Lighting.ClockTime = 14
	end
end)

Env.UI:CreateButton(Env.Pages.Environment, "🔄 Убрать эффекты освещения", Color3.fromRGB(40, 50, 70), function()
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
			child:Destroy()
		end
	end
	Lighting.Brightness = 2
	Lighting.GlobalShadows = true
	Lighting.FogEnd = 100000
end)

-- ===== ВЕСЕЛЬЕ =====
Env.UI:CreateSectionLabel(Env.Pages.Fun, "── Весёлые функции ──")

-- Взрывная волна
Env.UI:CreateButton(Env.Pages.Fun, "💥 Взрывная волна", Color3.fromRGB(180, 100, 0), function()
	local root = Env:GetRoot()
	if not root then return end
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(5, 5, 5)
	part.Position = root.Position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.3
	part.BrickColor = BrickColor.new("Bright orange")
	part.Parent = Services.Workspace

	task.spawn(function()
		for i = 1, 30 do
			part.Size = part.Size + Vector3.new(3, 3, 3)
			part.Transparency = part.Transparency + 0.03
			RunService.Heartbeat:Wait()
		end
		part:Destroy()
	end)
end)

-- Спинбот
Env.UI:CreateButton(Env.Pages.Fun, "🌀 Спинбот (3 сек)", Color3.fromRGB(120, 40, 160), function()
	local root = Env:GetRoot()
	if not root then return end
	local duration = 3
	local elapsed = 0
	Env:StartLoop("Spinbot", function(dt)
		elapsed += dt
		if elapsed >= duration then
			Env:StopLoop("Spinbot")
			return
		end
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(45), 0)
	end)
end)

-- Заморозка
Env.UI:CreateButton(Env.Pages.Fun, "🧊 Заморозить персонажа", Color3.fromRGB(30, 120, 180), function()
	local char = Env:GetChar()
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Ice
			part.Color = Color3.fromRGB(100, 200, 255)
		end
	end
end)

-- Радужный персонаж
local rainbowLoopName = "Rainbow"
Env.UI:CreateToggle(Env.Pages.Fun, "🌈 Радужный персонаж", false, function(state)
	if state then
		Env:StartLoop(rainbowLoopName, function()
			local char = Env:GetChar()
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
					end
				end
			end
		end)
	else
		Env:StopLoop(rainbowLoopName)
	end
end)

print("✅ Часть 4 загружена: Окружение и Веселье")
--[[
	ULTRA ADMIN PANEL v18.0 — Часть 5: Дополнительные настройки
	Запускать ПОСЛЕ Части 1
]]

if not shared.UltraAdmin then
	warn("⚠️ Сначала запустите Часть 1!")
	return
end

local Env = shared.UltraAdmin
local Services = Env.Services
local Lighting = Services.Lighting
local LocalPlayer = Env.LocalPlayer

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
}

-- ===== ПОЛНЫЙ СВЕТ =====
Env.UI:CreateToggle(Env.Pages.Home, "💡 Полный свет (Fullbright)", false, function(state)
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 999999
	else
		Lighting.Brightness = OriginalLighting.Brightness
		Lighting.ClockTime = OriginalLighting.ClockTime
		Lighting.GlobalShadows = OriginalLighting.GlobalShadows
		Lighting.FogEnd = OriginalLighting.FogEnd
	end
end)

-- ===== СКОРОСТЬ ПОЛЁТА =====
Env.UI:CreateButton(Env.Pages.Home, "⚙️ Установить скорость полёта", Color3.fromRGB(30, 60, 90), function()
	if Env.Settings.FlySpeed == 75 then
		Env.Settings.FlySpeed = 200
	else
		Env.Settings.FlySpeed = 75
	end
	print("Скорость полёта:", Env.Settings.FlySpeed)
end)

print("✅ Часть 5 загружена: Дополнительно")