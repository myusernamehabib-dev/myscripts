--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v17.0 [PART 1: CORE, UI, PLAYER]
--==================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Чистим старые копии интерфейса
if PlayerGui:FindFirstChild("UltraAdminPanelV17") then
	PlayerGui.UltraAdminPanelV17:Destroy()
end

-- Конфиг параметров
local CONFIG = {
	WalkSpeed = 50,
	JumpPower = 100,
	FlySpeed = 75,
	FOVValue = 70,
}

local State = {
	Fly = false,
	Noclip = false,
	Speed = false,
	SuperJump = false,
	Invisibility = false,
	InfiniteJump = false,
	Fullbright = false,
	Spectating = false,
	SpectateTarget = nil,
}

local Connections = {}
local OriginalTransparency = {}
local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
}

-- Хелперы
local Helpers = {}

function Helpers.getChar(player)
	player = player or LocalPlayer
	return player.Character
end

function Helpers.getHum(player)
	local char = Helpers.getChar(player)
	return char and char:FindFirstChildOfClass("Humanoid")
end

function Helpers.getRoot(player)
	local char = Helpers.getChar(player)
	return char and char:FindFirstChild("HumanoidRootPart")
end

function Helpers.tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Helpers.disconnect(name)
	if Connections[name] then
		Connections[name]:Disconnect()
		Connections[name] = nil
	end
end

-- Создание главного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraAdminPanelV17"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Кнопка открытия/закрытия
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.fromOffset(56, 56)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
OpenBtn.Text = "🛡️"
OpenBtn.TextSize = 26
OpenBtn.Active = true
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", OpenBtn)
openStroke.Color = Color3.fromRGB(0, 255, 130)
openStroke.Thickness = 2

-- Окно панели
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 620, 0, 400)
Main.Position = UDim2.new(0.5, -310, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 13, 19)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(30, 40, 55)
mainStroke.Thickness = 1.5

OpenBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
	if Main.Visible then
		Helpers.tween(Main, {Size = UDim2.new(0, 620, 0, 400)}, 0.2)
	end
end)

-- Шапка
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTRA ADMIN PANEL v17.0 [PART 1]"
Title.TextColor3 = Color3.fromRGB(245, 248, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Сайдбар меню
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -62)
Sidebar.Position = UDim2.fromOffset(10, 56)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 18, 25)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 6)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 8)

-- Контейнер страниц
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -154, 1, -62)
Content.Position = UDim2.fromOffset(144, 56)
Content.BackgroundTransparency = 1

local Pages = {}
local SideButtons = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame", Content)
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	
	local pad = Instance.new("UIPadding", page)
	pad.PaddingRight = UDim.new(0, 6)
	
	local list = Instance.new("UIListLayout", page)
	list.Padding = UDim.new(0, 8)
	
	Pages[name] = page
	return page
end

local function createTab(text, pageName)
	local page = createPage(pageName)
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, -12, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 160, 175)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	SideButtons[pageName] = btn
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(Pages) do p.Visible = false end
		for _, b in pairs(SideButtons) do
			b.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
			b.TextColor3 = Color3.fromRGB(150, 160, 175)
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	return page
end

local PageHome = createTab("🏠 Персонаж", "Home")
local PagePlayers = createTab("👥 Игроки", "Players")

-- Активируем вкладку Home по умолчанию
PageHome.Visible = true
SideButtons.Home.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
SideButtons.Home.TextColor3 = Color3.fromRGB(255, 255, 255)

local UI = {}

function UI.createToggle(parent, text, default, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
	
	local lbl = Instance.new("TextLabel", holder)
	lbl.Size = UDim2.new(1, -65, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(235, 240, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local toggle = Instance.new("TextButton", holder)
	toggle.Size = UDim2.fromOffset(40, 22)
	toggle.Position = UDim2.new(1, -50, 0.5, -11)
	toggle.BackgroundColor3 = default and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)
	toggle.Text = ""
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
	
	local knob = Instance.new("Frame", toggle)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	
	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		Helpers.tween(toggle, {BackgroundColor3 = state and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)})
		Helpers.tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
		callback(state)
	end)
end

function UI.createBtn(parent, text, color, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = color or Color3.fromRGB(22, 28, 38)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 245, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- ==========================================
-- ВКЛАДКА 1: ПЕРСОНАЖ (HOME)
-- ==========================================

UI.createToggle(PageHome, "✈️ Свободный Полет (Fly)", false, function(state)
	State.Fly = state
	local hum = Helpers.getHum()
	local root = Helpers.getRoot()
	if not hum or not root then return end
	
	if state then
		hum.PlatformStand = true
		Helpers.disconnect("Fly")
		Connections.Fly = RunService.RenderStepped:Connect(function()
			if not State.Fly or not root.Parent then return end
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0 then
				root.AssemblyLinearVelocity = moveDir.Unit * CONFIG.FlySpeed
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

UI.createToggle(PageHome, "⚡ Ускоренный Бег (Speed x3)", false, function(state)
	State.Speed = state
	local hum = Helpers.getHum()
	if hum then hum.WalkSpeed = state and CONFIG.WalkSpeed or 16 end
end)

UI.createToggle(PageHome, "🦘 Супер Прыжок (JumpPower)", false, function(state)
	State.SuperJump = state
	local hum = Helpers.getHum()
	if hum then hum.JumpPower = state and CONFIG.JumpPower or 50 end
end)

UI.createToggle(PageHome, "👻 Режим Noclip (Сквозь стены)", false, function(state)
	State.Noclip = state
	Helpers.disconnect("Noclip")
	if state then
		Connections.Noclip = RunService.Stepped:Connect(function()
			local char = Helpers.getChar()
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end
end)

UI.createToggle(PageHome, "♾️ Бесконечный Прыжок (Infinite Jump)", false, function(state)
	State.InfiniteJump = state
	Helpers.disconnect("InfJump")
	if state then
		Connections.InfJump = UserInputService.JumpRequest:Connect(function()
			local hum = Helpers.getHum()
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
end)

UI.createToggle(PageHome, "💡 Полный Свет (Fullbright / Без теней)", false, function(state)
	State.Fullbright = state
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


-- ==========================================
-- ВКЛАДКА 2: ИГРОКИ И СПЕКТАТОР (PLAYERS)
-- ==========================================

local PlayerScroll = Instance.new("Frame", PagePlayers)
PlayerScroll.Size = UDim2.new(1, 0, 0, 0)
PlayerScroll.AutomaticSize = Enum.AutomaticSize.Y
PlayerScroll.BackgroundTransparency = 1
local pListLayout = Instance.new("UIListLayout", PlayerScroll)
pListLayout.Padding = UDim.new(0, 6)

local function rebuildPlayerList()
	for _, child in ipairs(PlayerScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local card = Instance.new("Frame", PlayerScroll)
			card.Size = UDim2.new(1, 0, 0, 48)
			card.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
			
			local nameLbl = Instance.new("TextLabel", card)
			nameLbl.Size = UDim2.new(1, -210, 1, 0)
			nameLbl.Position = UDim2.fromOffset(12, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = "👤 " .. player.DisplayName .. " (@" .. player.Name .. ")"
			nameLbl.TextColor3 = Color3.fromRGB(240, 245, 250)
			nameLbl.Font = Enum.Font.GothamBold
			nameLbl.TextSize = 11
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			
			-- Кнопка Телепорта (TP)
			local tpBtn = Instance.new("TextButton", card)
			tpBtn.Size = UDim2.fromOffset(50, 28)
			tpBtn.Position = UDim2.new(1, -195, 0.5, -14)
			tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 190)
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.TextSize = 10
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
			tpBtn.MouseButton1Click:Connect(function()
				local targetRoot = Helpers.getRoot(player)
				local myRoot = Helpers.getRoot()
				if targetRoot and myRoot then
					myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 3)
				end
			end)
			
			-- Кнопка Призыва (Bring - если сервер позволяет)
			local bringBtn = Instance.new("TextButton", card)
			bringBtn.Size = UDim2.fromOffset(60, 28)
			bringBtn.Position = UDim2.new(1, -139, 0.5, -14)
			bringBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 0)
			bringBtn.Text = "Bring"
			bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			bringBtn.Font = Enum.Font.GothamBold
			bringBtn.TextSize = 10
			Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 6)
			bringBtn.MouseButton1Click:Connect(function()
				local targetRoot = Helpers.getRoot(player)
				local myRoot = Helpers.getRoot()
				if targetRoot and myRoot then
					targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
				end
			end)
			
			-- Кнопка Слежки (Spectate)
			local specBtn = Instance.new("TextButton", card)
			specBtn.Size = UDim2.fromOffset(70, 28)
			specBtn.Position = UDim2.new(1, -75, 0.5, -14)
			specBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 160)
			specBtn.Text = "Spec"
			specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			specBtn.Font = Enum.Font.GothamBold
			specBtn.TextSize = 10
			Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 6)
			specBtn.MouseButton1Click:Connect(function()
				State.Spectating = not State.Spectating
				if State.Spectating then
					State.SpectateTarget = player
					specBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
					specBtn.Text = "Unspec"
					Helpers.disconnect("Spectate")
					Connections.Spectate = RunService.RenderStepped:Connect(function()
						if not State.Spectating or not State.SpectateTarget or not State.SpectateTarget.Character then
							Camera.CameraSubject = Helpers.getHum()
							return
						end
						local targetHum = State.SpectateTarget.Character:FindFirstChildOfClass("Humanoid")
						if targetHum then
							Camera.CameraSubject = targetHum
						end
					end)
				else
					State.SpectateTarget = nil
					Camera.CameraSubject = Helpers.getHum()
					specBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 160)
					specBtn.Text = "Spec"
					Helpers.disconnect("Spectate")
				end
			end)
		end
	end
end

UI.createBtn(PagePlayers, "🔄 Обновить список игроков", Color3.fromRGB(0, 130, 90), rebuildPlayerList)
rebuildPlayerList()

-- Авто-обновление списка при входе/выходе игроков
Players.PlayerAdded:Connect(rebuildPlayerList)
Players.PlayerRemoving:Connect(rebuildPlayerList)
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v17.0 [PART 2: VISUAL, ESP, TP]
--==================================================================

-- Убедимся, что интерфейс первой части уже создан, иначе выдадим ошибку в консоль
local ScreenGui = PlayerGui:FindFirstChild("UltraAdminPanelV17")
if not ScreenGui then
	warn("⚠️ Сначала запустите Часть 1 скрипта!")
	return
end

local Main = ScreenGui:FindFirstChild("Frame")
local Sidebar = Main and Main:FindFirstChild("Frame")
local Content = Main and Main:FindFirstChild("Content") -- если создавали отдельно или ищем по имени

-- Если структура контента из Part 1 недоступна напрямую по переменной, находим её:
for _, child in ipairs(Main:GetChildren()) do
	if child:IsA("Frame") and child.Name ~= "Frame" and child ~= Sidebar and child.Size.X.Offset > 100 then
		Content = child
		break
	end
end

-- Дополнительные переменные состояния для Визуала
local VisualState = {
	ESP = false,
	Tracers = false,
	ESPColor = Color3.fromRGB(0, 255, 140),
}

local ESPHighlights = {}
local TracerLines = {}

-- Создаем новые вкладки через безопасный поиск или добавление
local function createExtraTab(text, pageName)
	-- Ищем сайдбар повторно
	local sb = Main:FindFirstChildOfClass("Frame")
	for _, c in ipairs(Main:GetChildren()) do
		if c:IsA("Frame") and c ~= sb and c ~= Main:FindFirstChildOfClass("Frame") then
			-- это может быть шапка, ищем контейнер страниц
		end
	end
	
	-- Упрощенный поиск Sidebar и Content из первой части
	local side = Main:FindFirstChild("Frame") -- Первый фрейм внутри Main — это Sidebar (по структуре Part 1)
	-- Создадим кнопку прямо в существующий UI сайдбара
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, -12, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 160, 175)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	-- Создаем страницу в Content
	local page = Instance.new("ScrollingFrame", Content)
	page.Name = pageName
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	
	local pad = Instance.new("UIPadding", page)
	pad.PaddingRight = UDim.new(0, 6)
	
	local list = Instance.new("UIListLayout", page)
	list.Padding = UDim.new(0, 8)
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(Content:GetChildren()) do
			if p:IsA("ScrollingFrame") then p.Visible = false end
		end
		for _, b in pairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
				b.TextColor3 = Color3.fromRGB(150, 160, 175)
			end
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	
	return page
end

local PageVisual = createExtraTab("👁️ Визуал", "Visual")
local PageTeleport = createExtraTab("🌐 Миры & ТП", "Teleport")
local PagePoints = createTab("📌 Чекпоинты", "Checkpoints")

-- Локальный вспомогательный метод для создания UI элементов на новых вкладках
local function createVisToggle(parent, text, default, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
	
	local lbl = Instance.new("TextLabel", holder)
	lbl.Size = UDim2.new(1, -65, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(235, 240, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local toggle = Instance.new("TextButton", holder)
	toggle.Size = UDim2.fromOffset(40, 22)
	toggle.Position = UDim2.new(1, -50, 0.5, -11)
	toggle.BackgroundColor3 = default and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)
	toggle.Text = ""
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
	
	local knob = Instance.new("Frame", toggle)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	
	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
		callback(state)
	end)
end

local function createVisBtn(parent, text, color, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = color or Color3.fromRGB(22, 28, 38)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 245, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end


-- ==========================================
-- ВКЛАДКА 3: ВИЗУАЛ И ESP
-- ==========================================

local function clearESP()
	for _, obj in pairs(ESPHighlights) do
		if obj then obj:Destroy() end
	end
	ESPHighlights = {}
end

createVisToggle(PageVisual, "👁️ Подсветка игроков (ESP Highlight)", false, function(state)
	VisualState.ESP = state
	if not state then
		clearESP()
		return
	end
	
	task.spawn(function()
		while VisualState.ESP do
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					if not ESPHighlights[player] or not ESPHighlights[player].Parent then
						local hl = Instance.new("Highlight")
						hl.Adornee = player.Character
						hl.FillColor = VisualState.ESPColor
						hl.FillTransparency = 0.5
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.OutlineTransparency = 0
						hl.Parent = player.Character
						ESPHighlights[player] = hl
					end
				end
			end
			task.wait(1)
		end
		clearESP()
	end)
end)

createVisToggle(PageVisual, "👻 Локальный Инвиз (Transparency)", false, function(state)
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end)


-- ==========================================
-- ВКЛАДКА 4: МИРЫ И ТЕЛЕПОРТАЦИЯ
-- ==========================================

local WorldScroll = Instance.new("Frame", PageTeleport)
WorldScroll.Size = UDim2.new(1, 0, 0, 0)
WorldScroll.AutomaticSize = Enum.AutomaticSize.Y
WorldScroll.BackgroundTransparency = 1
Instance.new("UIListLayout", WorldScroll).Padding = UDim.new(0, 6)

local function scanWorlds()
	for _, c in ipairs(WorldScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	
	local scanned = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			local nameLower = obj.Name:lower()
			if (nameLower:find("spawn") or nameLower:find("world") or nameLower:find("zone") or nameLower:find("portal") or nameLower:find("base")) and not scanned[obj.Name] then
				scanned[obj.Name] = true
				local cf = obj:IsA("BasePart") and obj.CFrame or obj:GetPivot()
				
				createVisBtn(WorldScroll, "🚀 Мир / Зона: " .. obj.Name, Color3.fromRGB(25, 45, 65), function()
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.CFrame = cf + Vector3.new(0, 5, 0)
					end
				end)
			end
		end
	end
end

createVisBtn(PageTeleport, "🔄 Сканировать зоны и порталы", Color3.fromRGB(0, 130, 90), scanWorlds)
scanWorlds()


-- ==========================================
-- ВКЛАДКА 5: ЧЕКПИНТЫ (ТОЧКИ СОХРАНЕНИЯ)
-- ==========================================

local CheckpointsList = {}

local PointsScroll = Instance.new("Frame", PagePoints)
PointsScroll.Size = UDim2.new(1, 0, 0, 0)
PointsScroll.AutomaticSize = Enum.AutomaticSize.Y
PointsScroll.BackgroundTransparency = 1
Instance.new("UIListLayout", PointsScroll).Padding = UDim.new(0, 6)

local function rebuildPointsUI()
	for _, c in ipairs(PointsScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	
	for name, cf in pairs(CheckpointsList) do
		local card = Instance.new("Frame", PointsScroll)
		card.Size = UDim2.new(1, 0, 0, 38)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
		
		local lbl = Instance.new("TextLabel", card)
		lbl.Size = UDim2.new(1, -90, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "📌 " .. name
		lbl.TextColor3 = Color3.fromRGB(240, 245, 250)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		
		local tpBtn = Instance.new("TextButton", card)
		tpBtn.Size = UDim2.fromOffset(36, 26)
		tpBtn.Position = UDim2.new(1, -80, 0.5, -13)
		tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
		tpBtn.Text = "TP"
		tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 10
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
		tpBtn.MouseButton1Click:Connect(function()
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then root.CFrame = cf end
		end)
		
		local delBtn = Instance.new("TextButton", card)
		delBtn.Size = UDim2.fromOffset(36, 26)
		delBtn.Position = UDim2.new(1, -40, 0.5, -13)
		delBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
		delBtn.Text = "✕"
		delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		delBtn.Font = Enum.Font.GothamBold
		delBtn.TextSize = 11
		Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
		delBtn.MouseButton1Click:Connect(function()
			CheckpointsList[name] = nil
			rebuildPointsUI()
		end)
	end
end

createVisBtn(PagePoints, "➕ Сохранить текущую позицию", Color3.fromRGB(0, 150, 100), function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local count = 0
		for _ in pairs(CheckpointsList) do count = count + 1 end
		CheckpointsList["Точка " .. (count + 1)] = root.CFrame
		rebuildPointsUI()
	end
end)

print("⚡ Ultra Admin Panel v17.0 [Part 2] успешно загружена!")
--==================================================================
--    ULTIMATE MEGA ADMIN PANEL v17.0 [PART 3: SERVER, FUN, EXTRAS]
--==================================================================

local ScreenGui = PlayerGui:FindFirstChild("UltraAdminPanelV17")
if not ScreenGui then
	warn("⚠️ Сначала запустите Часть 1 и Часть 2 скрипта!")
	return
end

local Main = ScreenGui:FindFirstChild("Frame")
local Sidebar = Main and Main:FindFirstChild("Frame")
local Content = nil

for _, child in ipairs(Main:GetChildren()) do
	if child:IsA("Frame" ) and child ~= Sidebar and child ~= Main:FindFirstChildOfClass("Frame") then
		Content = child
		break
	end
end

if not Sidebar or not Content then
	warn("⚠️ Не удалось найти структуру UI из прошлых частей.")
	return
end

-- Функция добавления новой вкладки
local function createExtraTab(text, pageName)
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, -12, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 160, 175)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	local page = Instance.new("ScrollingFrame", Content)
	page.Name = pageName
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	
	local pad = Instance.new("UIPadding", page)
	pad.PaddingRight = UDim.new(0, 6)
	
	local list = Instance.new("UIListLayout", page)
	list.Padding = UDim.new(0, 8)
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(Content:GetChildren()) do
			if p:IsA("ScrollingFrame") then p.Visible = false end
		end
		for _, b in pairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
				b.TextColor3 = Color3.fromRGB(150, 160, 175)
			end
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	
	return page
end

local PageServer = createExtraTab("🌍 Окружение", "Server")
local PageFun = createExtraTab("🎉 Веселье", "Fun")

local function createUtilsBtn(parent, text, color, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = color or Color3.fromRGB(22, 28, 38)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 245, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createUtilsToggle(parent, text, default, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.BackgroundColor3 = Color3.fromRGB(18, 22, 31)
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
	
	local lbl = Instance.new("TextLabel", holder)
	lbl.Size = UDim2.new(1, -65, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(235, 240, 245)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local toggle = Instance.new("TextButton", holder)
	toggle.Size = UDim2.fromOffset(40, 22)
	toggle.Position = UDim2.new(1, -50, 0.5, -11)
	toggle.BackgroundColor3 = default and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)
	toggle.Text = ""
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
	
	local knob = Instance.new("Frame", toggle)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	
	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0, 190, 110) or Color3.fromRGB(45, 52, 68)}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
		callback(state)
	end)
end


-- ==========================================
-- ВКЛАДКА 6: ОКРУЖЕНИЕ И СЕРВЕР (SERVER)
-- ==========================================

local Lighting = game:GetService("Lighting")

createUtilsToggle(PageServer, "🌙 Вечная Ночь (ClockTime = 0)", false, function(state)
	Lighting.ClockTime = state and 0.0 or 14.0
end)

createUtilsToggle(PageServer, "☀️ Вечный День (ClockTime = 14)", false, function(state)
	Lighting.ClockTime = state and 14.0 or 14.0
end)

createUtilsBtn(PageServer, "🔄 Снять все кастомные эффекты освещения", Color3.fromRGB(40, 50, 70), function()
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
			child:Destroy()
		end
	end
	Lighting.Brightness = 2
	Lighting.GlobalShadows = true
	Lighting.FogEnd = 100000
end)

createUtilsBtn(PageServer, "♻️ Быстрый Рестарт персонажа (Rejoin/Reset)", Color3.fromRGB(150, 40, 50), function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").Health = 0
	end
end)


-- ==========================================
-- ВКЛАДКА 7: ВЕСЕЛЬЕ И ИНСТРУМЕНТЫ (FUN)
-- ==========================================

createUtilsBtn(PageFun, "💥 Сделать взрывную волну вокруг себя (Visual FX)", Color3.fromRGB(180, 100, 0), function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(5, 5, 5)
	p.Position = root.Position
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 0.3
	p.BrickColor = BrickColor.new("Bright orange")
	p.Parent = workspace
	
	task.spawn(function()
		for i = 1, 30 do
			p.Size = p.Size + Vector3.new(3, 3, 3)
			p.Transparency = p.Transparency + 0.03
			task.wait(0.02)
		end
		p:Destroy()
	end)
end)

createUtilsBtn(PageFun, "🌀 Раскрутить персонажа (Spinbot 3 сек)", Color3.fromRGB(120, 40, 160), function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local duration = 3
	local elapsed = 0
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= duration then
			conn:Disconnect()
			return
		end
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(45), 0)
	end)
end)

createUtilsBtn(PageFun, "🧊 Превратить персонажа в ледяную глыбу", Color3.fromRGB(30, 120, 180), function()
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Ice
			part.Color = Color3.fromRGB(100, 200, 255)
		end
	end
end)

print("⚡ Ultra Admin Panel v17.0 [Part 3] успешно загружена! Все части собраны воедино.")
