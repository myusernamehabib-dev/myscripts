--==================================================================
--    ADVANCED MOTION RECORDER v1.0 [PART 1: CORE, UI & RECORDING]
--==================================================================

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Глобальная структура состояния
_G.MotionRecorder = _G.MotionRecorder or {
	State = {
		IsRecording = false,
		IsPaused = false,
		RecordInterval = 0.05, -- В секундах (по умолчанию 20 FPS)
		CurrentTime = 0,
		TotalFrames = 0,
		SelectedTab = "Record",
		AutoSave = true
	},
	CurrentData = {
		Name = "New_Recording",
		Frames = {}, -- {Time, CFrame, Velocity, RotVelocity, HumanoidState, CamCFrame, IsJumping}
		Duration = 0,
		CreatedAt = 0
	},
	SavedRecordings = {}, -- Хранилище всех записей
	TargetPlayer = nil,
	Connections = {},
	UI = {}
}

local System = _G.MotionRecorder

-- Вспомогательные функции защиты и утилиты
local function SafeCall(fn, ...)
	local success, result = pcall(fn, ...)
	if not success then
		warn("[MotionRecorder Error]: " .. tostring(result))
	end
	return success, result
end

local function GetRoot(player)
	player = player or LocalPlayer
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function GetHum(player)
	player = player or LocalPlayer
	if player and player.Character then
		return player.Character:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

-- ==========================================
-- СЕКЦИЯ 1: ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (UI)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MotionRecorder_UI"
ScreenGui.ResetOnSpawn = false

SafeCall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

System.UI.ScreenGui = ScreenGui

-- Главный Контейнер (Draggable Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(520, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 60, 140)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Система перетаскивания (Draggable for PC & Mobile)
local Dragging = false
local DragInput, DragStart, StartPos

local function UpdateDrag(input)
	local delta = input.Position - DragStart
	MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)

Services.UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		UpdateDrag(input)
	end
end)

-- Анимированный Фон Звёзд (Starfield/Sparkles FX)
local StarCanvas = Instance.new("Frame")
StarCanvas.Name = "StarCanvas"
StarCanvas.Size = UDim2.fromScale(1, 1)
StarCanvas.BackgroundTransparency = 1
StarCanvas.ClipsDescendants = true
StarCanvas.Parent = MainFrame

local function SpawnStar()
	local star = Instance.new("Frame")
	local size = math.random(2, 4)
	star.Size = UDim2.fromOffset(size, size)
	star.Position = UDim2.new(math.random(), 0, math.random(), 0)
	star.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
	star.BorderSizePixel = 0
	star.BackgroundTransparency = 1
	star.Parent = StarCanvas

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = star

	local tweenIn = Services.TweenService:Create(star, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		BackgroundTransparency = math.random(2, 6) / 10
	})
	local tweenOut = Services.TweenService:Create(star, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		BackgroundTransparency = 1
	})

	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		tweenOut:Play()
		tweenOut.Completed:Connect(function()
			star:Destroy()
		end)
	end)
end

task.spawn(function()
	while true do
		if MainFrame.Parent then
			SpawnStar()
		end
		task.wait(0.3)
	end
end)

-- Верхняя Панель (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ MOTION RECORDER PRO v1.0"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Панель Вкладок (Tab Bar)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.fromOffset(10, 45)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabListLayout.Parent = TabBar

local PagesFolder = Instance.new("Folder")
PagesFolder.Name = "Pages"
PagesFolder.Parent = MainFrame

System.UI.Tabs = {}
System.UI.Pages = {}

local function CreateTab(name, icon, pageName)
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. pageName
	btn.Size = UDim2.new(0, 118, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
	btn.Text = icon .. " " .. name
	btn.TextColor3 = Color3.fromRGB(160, 160, 180)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.AutoButtonColor = false
	btn.Parent = TabBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 70)
	stroke.Thickness = 1
	stroke.Parent = btn

	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. pageName
	page.Size = UDim2.new(1, -20, 1, -95)
	page.Position = UDim2.fromOffset(10, 85)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(120, 90, 220)
	page.Visible = false
	page.Parent = PagesFolder

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(System.UI.Tabs) do
			Services.TweenService:Create(t, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(28, 28, 40),
				TextColor3 = Color3.fromRGB(160, 160, 180)
			}):Play()
		end
		for _, p in pairs(System.UI.Pages) do
			p.Visible = false
		end
		
		Services.TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(100, 65, 210),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
		page.Visible = true
		System.State.SelectedTab = pageName
	end)

	System.UI.Tabs[pageName] = btn
	System.UI.Pages[pageName] = page
	return page
end

-- Создаем вкладки
local RecordPage = CreateTab("Запись", "🔴", "Record")
local ReplayPage = CreateTab("Повтор", "▶️", "Replay")
local BindPage = CreateTab("Привязка", "🔗", "Bind")
local SettingsPage = CreateTab("Опции", "⚙️", "Settings")

-- Активируем вкладку по умолчанию
System.UI.Tabs["Record"].BackgroundColor3 = Color3.fromRGB(100, 65, 210)
System.UI.Tabs["Record"].TextColor3 = Color3.fromRGB(255, 255, 255)
System.UI.Pages["Record"].Visible = true

-- Вспомогательный конструктор элемента UI
local UIBuilder = {}

function UIBuilder.CreateButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseEnter:Connect(function()
		Services.TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
	end)
	btn.MouseLeave:Connect(function()
		Services.TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		SafeCall(callback)
	end)
	return btn
end

function UIBuilder.CreateStatusLabel(parent, titleText)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 28)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = titleText
	lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	return lbl
end

-- ==========================================
-- СЕКЦИЯ 2: МОДУЛЬ ЗАПИСИ ДВИЖЕНИЙ
-- ==========================================

local RecordStatsLabel = UIBuilder.CreateStatusLabel(RecordPage, "📊 Статус: Готов к записи")
local TimeStatsLabel = UIBuilder.CreateStatusLabel(RecordPage, "⏱️ Время: 00:00.00 | Кадры: 0")

-- Кнопка Начать/Остановить Запись
local RecBtn
RecBtn = UIBuilder.CreateButton(RecordPage, "🔴 НАЧАТЬ ЗАПИСЬ", Color3.fromRGB(180, 40, 60), function()
	if not System.State.IsRecording then
		-- Старт Записи
		System.State.IsRecording = true
		System.State.IsPaused = false
		System.CurrentData.Frames = {}
		System.CurrentData.Duration = 0
		System.CurrentData.CreatedAt = os.time()
		
		RecBtn.Text = "⏹️ ОСТАНОВИТЬ ЗАПИСЬ"
		RecBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 40)
		RecordStatsLabel.Text = "📊 Статус: 🔴 ИДЕТ ЗАПИСЬ..."
		
		local startTime = tick()
		local lastInterval = tick()
		
		System.Connections["RecordingLoop"] = Services.RunService.Heartbeat:Connect(function()
			if not System.State.IsRecording or System.State.IsPaused then return end
			
			local now = tick()
			if now - lastInterval >= System.State.RecordInterval then
				lastInterval = now
				
				local target = System.TargetPlayer or LocalPlayer
				local root = GetRoot(target)
				local hum = GetHum(target)
				
				if root and hum then
					local frameData = {
						Time = now - startTime,
						CFrame = root.CFrame,
						Velocity = root.AssemblyLinearVelocity,
						RotVelocity = root.AssemblyAngularVelocity,
						HumState = hum:GetState().Value,
						CamCFrame = Camera.CFrame,
						IsJumping = hum.Jump
					}
					table.insert(System.CurrentData.Frames, frameData)
					System.CurrentData.Duration = frameData.Time
					
					local frameCount = #System.CurrentData.Frames
					TimeStatsLabel.Text = string.format("⏱️ Время: %.2f сек | Кадры: %d", frameData.Time, frameCount)
				end
			end
		end)
	else
		-- Стоп Записи
		System.State.IsRecording = false
		System.State.IsPaused = false
		if System.Connections["RecordingLoop"] then
			System.Connections["RecordingLoop"]:Disconnect()
			System.Connections["RecordingLoop"] = nil
		end
		
		RecBtn.Text = "🔴 НАЧАТЬ ЗАПИСЬ"
		RecBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
		RecordStatsLabel.Text = string.format("📊 Статус: Запись завершена! (Записано кадров: %d)", #System.CurrentData.Frames)
		
		-- Автосохранение в локальный список
		if #System.CurrentData.Frames > 0 then
			local newRec = {
				Name = "Rec_" .. os.date("%H:%M:%S"),
				Frames = System.CurrentData.Frames,
				Duration = System.CurrentData.Duration
			}
			table.insert(System.SavedRecordings, newRec)
		end
	end
end)

-- Кнопка Паузы
UIBuilder.CreateButton(RecordPage, "⏸️ Пауза / Продолжить", Color3.fromRGB(50, 50, 70), function()
	if System.State.IsRecording then
		System.State.IsPaused = not System.State.IsPaused
		if System.State.IsPaused then
			RecordStatsLabel.Text = "📊 Статус: ⏸️ ЗАПИСЬ НА НАПАУЗЕ"
		else
			RecordStatsLabel.Text = "📊 Статус: 🔴 ИДЕТ ЗАПИСЬ..."
		end
	end
end)

-- Управление Частотой Записи (Интервал)
local IntervalLabel = UIBuilder.CreateStatusLabel(RecordPage, "⚙️ Интервал записи: 0.05 сек (20 FPS)")

UIBuilder.CreateButton(RecordPage, "⚡ Высокая точность (0.01s / 100 FPS)", Color3.fromRGB(30, 60, 90), function()
	System.State.RecordInterval = 0.01
	IntervalLabel.Text = "⚙️ Интервал записи: 0.01 сек (100 FPS)"
end)

UIBuilder.CreateButton(RecordPage, "🎯 Стандарт (0.05s / 20 FPS)", Color3.fromRGB(30, 60, 90), function()
	System.State.RecordInterval = 0.05
	IntervalLabel.Text = "⚙️ Интервал записи: 0.05 сек (20 FPS)"
end)

UIBuilder.CreateButton(RecordPage, "🔋 Экономо-режим (0.1s / 10 FPS)", Color3.fromRGB(30, 60, 90), function()
	System.State.RecordInterval = 0.1
	IntervalLabel.Text = "⚙️ Интервал записи: 0.10 сек (10 FPS)"
end)

print("⚡ Motion Recorder Pro v1.0 [Часть 1 из 4] загружена успешно!")
--==================================================================
--    ADVANCED MOTION RECORDER v1.0 [PART 2: REPLAY & TIMELINE]
--==================================================================

if not _G.MotionRecorder or not _G.MotionRecorder.UI then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 (Ядро UI)!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local System = _G.MotionRecorder

-- Расширяем состояние системы для воспроизведения
System.State.IsReplaying = false
System.State.ReplayPaused = false
System.State.ReplaySpeed = 1.0
System.State.LoopReplay = false
System.State.MirrorReplay = false
System.State.CurrentFrameIndex = 1
System.State.SelectedRecordingIndex = nil

local ReplayPage = System.UI.Pages["Replay"]

-- Вспомогательные вызовы
local function SafeCall(fn, ...)
	local success, result = pcall(fn, ...)
	if not success then
		warn("[MotionRecorder Part2 Error]: " .. tostring(result))
	end
	return success, result
end

local function GetRoot(player)
	player = player or LocalPlayer
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function GetHum(player)
	player = player or LocalPlayer
	if player and player.Character then
		return player.Character:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

-- ==========================================
-- СЕКЦИЯ 1: ИНТЕРФЕЙС ТАЙМЛАЙНА И ВОСПРОИЗВЕДЕНИЯ
-- ==========================================

local ReplayStatsLabel = Instance.new("Frame")
ReplayStatsLabel.Size = UDim2.new(1, 0, 0, 28)
ReplayStatsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ReplayStatsLabel.Parent = ReplayPage

local ReplayCorner = Instance.new("UICorner")
ReplayCorner.CornerRadius = UDim.new(0, 5)
ReplayCorner.Parent = ReplayStatsLabel

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.fromOffset(10, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "▶️ Статус: Ожидание выбора записи..."
StatusText.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = ReplayStatsLabel

-- ТАЙМЛАЙН (Прогресс-бар)
local TimelineContainer = Instance.new("Frame")
TimelineContainer.Size = UDim2.new(1, 0, 0, 30)
TimelineContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TimelineContainer.Parent = ReplayPage

local TimelineCorner = Instance.new("UICorner")
TimelineCorner.CornerRadius = UDim.new(0, 6)
TimelineCorner.Parent = TimelineContainer

local TimelineBar = Instance.new("Frame")
TimelineBar.Size = UDim2.new(1, -20, 0, 8)
TimelineBar.Position = UDim2.new(0, 10, 0.5, -4)
TimelineBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TimelineBar.Parent = TimelineContainer

local TimelineBarCorner = Instance.new("UICorner")
TimelineBarCorner.CornerRadius = UDim.new(1, 0)
TimelineBarCorner.Parent = TimelineBar

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(120, 80, 240)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = TimelineBar

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(1, 0)
ProgressCorner.Parent = ProgressFill

local ScrubberHandle = Instance.new("Frame")
ScrubberHandle.Size = UDim2.fromOffset(14, 14)
ScrubberHandle.Position = UDim2.new(0, -7, 0.5, -7)
ScrubberHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrubberHandle.Parent = ProgressFill

local HandleCorner = Instance.new("UICorner")
HandleCorner.CornerRadius = UDim.new(1, 0)
HandleCorner.Parent = ScrubberHandle

-- Клик/перетаскивание по таймлайну (Скраббинг)
local IsDraggingTimeline = false

local function UpdateTimelinePosition(input)
	local relX = math.clamp(input.Position.X - TimelineBar.AbsolutePosition.X, 0, TimelineBar.AbsoluteSize.X)
	local alpha = relX / TimelineBar.AbsoluteSize.X
	
	ProgressFill.Size = UDim2.new(alpha, 0, 1, 0)
	
	local rec = System.SavedRecordings[System.State.SelectedRecordingIndex]
	if rec and rec.Frames and #rec.Frames > 0 then
		local targetIndex = math.clamp(math.floor(alpha * #rec.Frames), 1, #rec.Frames)
		System.State.CurrentFrameIndex = targetIndex
		
		-- Мгновенный переход тела к кадру
		local frame = rec.Frames[targetIndex]
		local root = GetRoot(LocalPlayer)
		if root and frame then
			root.CFrame = frame.CFrame
		end
		StatusText.Text = string.format("▶️ Кадр: %d / %d (%.1f%%)", targetIndex, #rec.Frames, alpha * 100)
	end
end

TimelineBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsDraggingTimeline = true
		UpdateTimelinePosition(input)
	end
end)

Services.UserInputService.InputChanged:Connect(function(input)
	if IsDraggingTimeline and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		UpdateTimelinePosition(input)
	end
end)

Services.UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsDraggingTimeline = false
	end
end)

-- ==========================================
-- СЕКЦИЯ 2: ДВИЖОК ВОСПРОИЗВЕДЕНИЯ (REPLAY ENGINE)
-- ==========================================

local PlayBtn

local function StopReplay()
	System.State.IsReplaying = false
	System.State.ReplayPaused = false
	if System.Connections["ReplayLoop"] then
		System.Connections["ReplayLoop"]:Disconnect()
		System.Connections["ReplayLoop"] = nil
	end
	if PlayBtn then
		PlayBtn.Text = "▶️ ВОСПРОИЗВЕСТИ"
		PlayBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	end
	local root = GetRoot(LocalPlayer)
	if root then root.Anchored = false end
	StatusText.Text = "▶️ Статус: Воспроизведение остановлено."
end

local function StartReplay()
	local recIndex = System.State.SelectedRecordingIndex
	if not recIndex or not System.SavedRecordings[recIndex] then
		StatusText.Text = "⚠️ Ошибка: Сначала выберите запись из списка!"
		return
	end

	local rec = System.SavedRecordings[recIndex]
	local frames = rec.Frames
	if not frames or #frames == 0 then return end

	System.State.IsReplaying = true
	System.State.ReplayPaused = false
	
	if PlayBtn then
		PlayBtn.Text = "⏹️ ОСТАНОВИТЬ"
		PlayBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 50)
	end

	local root = GetRoot(LocalPlayer)
	if root then root.Anchored = true end

	if System.State.CurrentFrameIndex >= #frames then
		System.State.CurrentFrameIndex = System.State.MirrorReplay and #frames or 1
	end

	local lastStep = tick()

	System.Connections["ReplayLoop"] = Services.RunService.Heartbeat:Connect(function()
		if not System.State.IsReplaying or System.State.ReplayPaused then return end
		if IsDraggingTimeline then return end

		local now = tick()
		local delta = (now - lastStep) * System.State.ReplaySpeed
		lastStep = now

		local framesCount = #frames
		local idx = System.State.CurrentFrameIndex

		if idx >= 1 and idx <= framesCount then
			local currentFrame = frames[idx]
			root = GetRoot(LocalPlayer)
			local hum = GetHum(LocalPlayer)

			if root and currentFrame then
				root.CFrame = currentFrame.CFrame
				root.AssemblyLinearVelocity = currentFrame.Velocity or Vector3.new()
				root.AssemblyAngularVelocity = currentFrame.RotVelocity or Vector3.new()
			end

			-- Обновление UI таймлайна
			local progress = idx / framesCount
			ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
			StatusText.Text = string.format("▶️ [x%.1f] Кадр: %d / %d (%.1f сек)", System.State.ReplaySpeed, idx, framesCount, currentFrame.Time)

			-- Движение индекса (Зеркальный режим или Обычный)
			if System.State.MirrorReplay then
				idx = idx - 1
				if idx < 1 then
					if System.State.LoopReplay then
						idx = framesCount
					else
						StopReplay()
						return
					end
				end
			else
				idx = idx + 1
				if idx > framesCount then
					if System.State.LoopReplay then
						idx = 1
					else
						StopReplay()
						return
					end
				end
			end
			System.State.CurrentFrameIndex = idx
		else
			StopReplay()
		end
	end)
end

-- Кнопка Старт/Стоп
PlayBtn = Instance.new("TextButton")
PlayBtn.Size = UDim2.new(1, 0, 0, 35)
PlayBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
PlayBtn.Text = "▶️ ВОСПРОИЗВЕСТИ"
PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.TextSize = 11
PlayBtn.AutoButtonColor = false
PlayBtn.Parent = ReplayPage

local PlayCorner = Instance.new("UICorner")
PlayCorner.CornerRadius = UDim.new(0, 6)
PlayCorner.Parent = PlayBtn

PlayBtn.MouseButton1Click:Connect(function()
	if System.State.IsReplaying then
		StopReplay()
	else
		StartReplay()
	end
end)

-- Кнопка Пауза / Продолжить
local PauseBtn = Instance.new("TextButton")
PauseBtn.Size = UDim2.new(1, 0, 0, 30)
PauseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
PauseBtn.Text = "⏸️ Пауза / Плей"
PauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PauseBtn.Font = Enum.Font.GothamMedium
PauseBtn.TextSize = 10
PauseBtn.Parent = ReplayPage

local PauseCorner = Instance.new("UICorner")
PauseCorner.CornerRadius = UDim.new(0, 5)
PauseCorner.Parent = PauseBtn

PauseBtn.MouseButton1Click:Connect(function()
	if System.State.IsReplaying then
		System.State.ReplayPaused = not System.State.ReplayPaused
		StatusText.Text = System.State.ReplayPaused and "⏸️ Воспроизведение на паузе" or "▶️ Продолжение воспроизведения..."
	end
end)

-- Переключатели (Зацикливание и Зеркало)
local TogglesContainer = Instance.new("Frame")
TogglesContainer.Size = UDim2.new(1, 0, 0, 30)
TogglesContainer.BackgroundTransparency = 1
TogglesContainer.Parent = ReplayPage

local ToggleLayout = Instance.new("UIListLayout")
ToggleLayout.FillDirection = Enum.FillDirection.Horizontal
ToggleLayout.Padding = UDim.new(0, 10)
ToggleLayout.Parent = TogglesContainer

local function CreateToggleBtn(parent, title, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -5, 1, 0)
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(90, 60, 180) or Color3.fromRGB(28, 28, 40)
	btn.Text = title
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 10
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn

	local active = defaultState
	btn.MouseButton1Click:Connect(function()
		active = not active
		Services.TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = active and Color3.fromRGB(90, 60, 180) or Color3.fromRGB(28, 28, 40)
		}):Play()
		callback(active)
	end)
	return btn
end

CreateToggleBtn(TogglesContainer, "🔁 Зацикливание", false, function(st)
	System.State.LoopReplay = st
end)

CreateToggleBtn(TogglesContainer, "🪞 Зеркало (Реверс)", false, function(st)
	System.State.MirrorReplay = st
end)

-- Регулятор скорости (Speed Selector)
local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(1, 0, 0, 28)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Parent = ReplayPage

local SpeedLayout = Instance.new("UIListLayout")
SpeedLayout.FillDirection = Enum.FillDirection.Horizontal
SpeedLayout.Padding = UDim.new(0, 4)
SpeedLayout.Parent = SpeedContainer

local speeds = {0.25, 0.5, 1.0, 2.0, 5.0}
for _, spd in ipairs(speeds) do
	local spdBtn = Instance.new("TextButton")
	spdBtn.Size = UDim2.new(0.2, -3, 1, 0)
	spdBtn.BackgroundColor3 = (spd == 1.0) and Color3.fromRGB(100, 70, 200) or Color3.fromRGB(25, 25, 35)
	spdBtn.Text = tostring(spd) .. "x"
	spdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	spdBtn.Font = Enum.Font.GothamBold
	spdBtn.TextSize = 10
	spdBtn.Parent = SpeedContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = spdBtn

	spdBtn.MouseButton1Click:Connect(function()
		System.State.ReplaySpeed = spd
		for _, child in ipairs(SpeedContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
			end
		end
		spdBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
	end)
end

-- ==========================================
-- СЕКЦИЯ 3: СПИСОК И УДАЛЕНИЕ ЗАПИСЕЙ
-- ==========================================

local ListTitle = Instance.new("TextLabel")
ListTitle.Size = UDim2.new(1, 0, 0, 20)
ListTitle.BackgroundTransparency = 1
ListTitle.Text = "📁 Сохраненные Записи:"
ListTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
ListTitle.Font = Enum.Font.GothamBold
ListTitle.TextSize = 11
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.Parent = ReplayPage

local RecordListFrame = Instance.new("ScrollingFrame")
RecordListFrame.Size = UDim2.new(1, 0, 0, 110)
RecordListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
RecordListFrame.BorderSizePixel = 0
RecordListFrame.ScrollBarThickness = 3
RecordListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
RecordListFrame.Parent = ReplayPage

local RecordListCorner = Instance.new("UICorner")
RecordListCorner.CornerRadius = UDim.new(0, 6)
RecordListCorner.Parent = RecordListFrame

local RecordListLayout = Instance.new("UIListLayout")
RecordListLayout.Padding = UDim.new(0, 4)
RecordListLayout.SortOrder = Enum.SortOrder.LayoutOrder
RecordListLayout.Parent = RecordListFrame

function System.UI.RefreshRecordingsList()
	for _, child in ipairs(RecordListFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for idx, rec in ipairs(System.SavedRecordings) do
		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, -6, 0, 28)
		item.BackgroundColor3 = (System.State.SelectedRecordingIndex == idx) and Color3.fromRGB(60, 45, 100) or Color3.fromRGB(28, 28, 40)
		item.Parent = RecordListFrame

		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 4)
		itemCorner.Parent = item

		local selectBtn = Instance.new("TextButton")
		selectBtn.Size = UDim2.new(1, -35, 1, 0)
		selectBtn.BackgroundTransparency = 1
		selectBtn.Text = string.format("  🎬 %s (%.1fs | %d кадров)", rec.Name or "Rec", rec.Duration or 0, #rec.Frames)
		selectBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
		selectBtn.Font = Enum.Font.GothamMedium
		selectBtn.TextSize = 10
		selectBtn.TextXAlignment = Enum.TextXAlignment.Left
		selectBtn.Parent = item

		selectBtn.MouseButton1Click:Connect(function()
			System.State.SelectedRecordingIndex = idx
			System.State.CurrentFrameIndex = 1
			ProgressFill.Size = UDim2.new(0, 0, 1, 0)
			StatusText.Text = "Выбрано: " .. rec.Name
			System.UI.RefreshRecordingsList()
		end)

		-- Кнопка Удаления (🗑️)
		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.fromOffset(24, 22)
		delBtn.Position = UDim2.new(1, -27, 0.5, -11)
		delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 50)
		delBtn.Text = "🗑️"
		delBtn.TextSize = 10
		delBtn.Parent = item

		local delCorner = Instance.new("UICorner")
		delCorner.CornerRadius = UDim.new(0, 4)
		delCorner.Parent = delBtn

		delBtn.MouseButton1Click:Connect(function()
			table.remove(System.SavedRecordings, idx)
			if System.State.SelectedRecordingIndex == idx then
				System.State.SelectedRecordingIndex = nil
				StopReplay()
			end
			System.UI.RefreshRecordingsList()
		end)
	end
	
	RecordListFrame.CanvasSize = UDim2.new(0, 0, 0, #System.SavedRecordings * 32)
end

-- Авто-обновление списка при открытии вкладки
System.UI.Tabs["Replay"].MouseButton1Click:Connect(function()
	System.UI.RefreshRecordingsList()
end)

print("⚡ Motion Recorder Pro v1.0 [Часть 2 из 4] загружена успешно!")
--==================================================================
--    ADVANCED MOTION RECORDER v1.0 [PART 3: TRACKING & LIVE-COPY]
--==================================================================

if not _G.MotionRecorder or not _G.MotionRecorder.UI then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Часть 1 и Часть 2!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local System = _G.MotionRecorder

-- Расширение состояния системы
System.State.TargetPlayer = nil
System.State.IsTracking = false
System.State.IsFollowing = false
System.State.IsLiveCopying = false
System.State.FollowDistance = 8
System.State.TargetIndex = 1

local TrackPage = System.UI.Pages["Track"]

local function GetRoot(player)
	player = player or LocalPlayer
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function GetPlayersList()
	local list = {}
	for _, p in ipairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p)
		end
	end
	return list
end

-- ==========================================
-- СЕКЦИЯ 1: СЕЛЕКТОР ИГРОКОВ (◀ TARGET ▶)
-- ==========================================

local SelectorFrame = Instance.new("Frame")
SelectorFrame.Size = UDim2.new(1, 0, 0, 40)
SelectorFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
SelectorFrame.Parent = TrackPage

local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(0, 6)
SelectorCorner.Parent = SelectorFrame

local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0, 35, 1, 0)
PrevBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
PrevBtn.Text = "◀"
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 14
PrevBtn.Parent = SelectorFrame

local PrevCorner = Instance.new("UICorner")
PrevCorner.CornerRadius = UDim.new(0, 6)
PrevCorner.Parent = PrevBtn

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 35, 1, 0)
NextBtn.Position = UDim2.new(1, -35, 0, 0)
NextBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
NextBtn.Text = "▶"
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 14
NextBtn.Parent = SelectorFrame

local NextCorner = Instance.new("UICorner")
NextCorner.CornerRadius = UDim.new(0, 6)
NextCorner.Parent = NextBtn

local TargetInfoLabel = Instance.new("TextLabel")
TargetInfoLabel.Size = UDim2.new(1, -80, 1, 0)
TargetInfoLabel.Position = UDim2.fromOffset(40, 0)
TargetInfoLabel.BackgroundTransparency = 1
TargetInfoLabel.Text = "🎯 Цель: Не выбрана"
TargetInfoLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
TargetInfoLabel.Font = Enum.Font.GothamMedium
TargetInfoLabel.TextSize = 10
TargetInfoLabel.Parent = SelectorFrame

local function UpdateTargetDisplay()
	local plist = GetPlayersList()
	if #plist == 0 then
		System.State.TargetPlayer = nil
		TargetInfoLabel.Text = "⚠️ Нет других игроков"
		return
	end

	if System.State.TargetIndex > #plist then System.State.TargetIndex = 1 end
	if System.State.TargetIndex < 1 then System.State.TargetIndex = #plist end

	local target = plist[System.State.TargetIndex]
	System.State.TargetPlayer = target
	TargetInfoLabel.Text = string.format("🎯 [%d/%d] %s (@%s)", System.State.TargetIndex, #plist, target.DisplayName, target.Name)
end

PrevBtn.MouseButton1Click:Connect(function()
	System.State.TargetIndex = System.State.TargetIndex - 1
	UpdateTargetDisplay()
end)

NextBtn.MouseButton1Click:Connect(function()
	System.State.TargetIndex = System.State.TargetIndex + 1
	UpdateTargetDisplay()
end)

UpdateTargetDisplay()

-- ==========================================
-- СЕКЦИЯ 2: УПРАВЛЕНИЕ РЕЖИМАМИ СЛЕЖЕНИЯ
-- ==========================================

local function CreateToggleOption(title, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(100, 70, 200) or Color3.fromRGB(28, 28, 40)
	btn.Text = title
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 10
	btn.Parent = TrackPage

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local state = defaultState
	btn.MouseButton1Click:Connect(function()
		state = not state
		Services.TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = state and Color3.fromRGB(100, 70, 200) or Color3.fromRGB(28, 28, 40)
		}):Play()
		callback(state)
	end)
	return btn
end

-- 1. Наблюдение Камерой (Look At)
CreateToggleOption("👁️ Наблюдение камерой (Spectate)", false, function(active)
	System.State.IsTracking = active
	if active then
		System.Connections["SpectateLoop"] = Services.RunService.RenderStepped:Connect(function()
			if System.State.TargetPlayer and System.State.TargetPlayer.Character then
				local tRoot = GetRoot(System.State.TargetPlayer)
				if tRoot then
					Camera.CameraType = Enum.CameraType.Scriptable
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
				end
			end
		end)
	else
		if System.Connections["SpectateLoop"] then
			System.Connections["SpectateLoop"]:Disconnect()
			System.Connections["SpectateLoop"] = nil
		end
		Camera.CameraType = Enum.CameraType.Custom
	end
end)

-- 2. Физическое Преследование (Follow)
CreateToggleOption("🏃 Следование за целью (Follow)", false, function(active)
	System.State.IsFollowing = active
	if active then
		System.Connections["FollowLoop"] = Services.RunService.Heartbeat:Connect(function()
			if System.State.TargetPlayer then
				local myRoot = GetRoot(LocalPlayer)
				local tRoot = GetRoot(System.State.TargetPlayer)
				if myRoot and tRoot then
					local targetPos = tRoot.CFrame * Vector3.new(0, 0, System.State.FollowDistance)
					myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.new(targetPos, tRoot.Position), 0.15)
				end
			end
		end)
	else
		if System.Connections["FollowLoop"] then
			System.Connections["FollowLoop"]:Disconnect()
			System.Connections["FollowLoop"] = nil
		end
	end
end)

-- 3. Live-Copy (Дублирование движений в реальном времени)
CreateToggleOption("🪞 Live-Copy (Копировать движения)", false, function(active)
	System.State.IsLiveCopying = active
	local myRoot = GetRoot(LocalPlayer)
	
	if active then
		if myRoot then myRoot.Anchored = true end
		
		System.Connections["LiveCopyLoop"] = Services.RunService.Heartbeat:Connect(function()
			if System.State.TargetPlayer then
				myRoot = GetRoot(LocalPlayer)
				local tRoot = GetRoot(System.State.TargetPlayer)
				
				if myRoot and tRoot then
					-- Полная синхронизация позиционирования и скоростей
					myRoot.CFrame = tRoot.CFrame
					myRoot.AssemblyLinearVelocity = tRoot.AssemblyLinearVelocity
					myRoot.AssemblyAngularVelocity = tRoot.AssemblyAngularVelocity
				end
			end
		end)
	else
		if System.Connections["LiveCopyLoop"] then
			System.Connections["LiveCopyLoop"]:Disconnect()
			System.Connections["LiveCopyLoop"] = nil
		end
		if myRoot then myRoot.Anchored = false end
	end
end)

-- ==========================================
-- СЕКЦИЯ 3: НАСТРОЙКА ДИСТАНЦИИ (SLIDER)
-- ==========================================

local DistContainer = Instance.new("Frame")
DistContainer.Size = UDim2.new(1, 0, 0, 35)
DistContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
DistContainer.Parent = TrackPage

local DistCorner = Instance.new("UICorner")
DistCorner.CornerRadius = UDim.new(0, 6)
DistCorner.Parent = DistContainer

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, -10, 0, 15)
DistLabel.Position = UDim2.fromOffset(8, 3)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "📏 Дистанция следования: 8 studs"
DistLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
DistLabel.Font = Enum.Font.Gotham
DistLabel.TextSize = 9
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistContainer

local DistSliderBg = Instance.new("Frame")
DistSliderBg.Size = UDim2.new(1, -16, 0, 6)
DistSliderBg.Position = UDim2.new(0, 8, 1, -10)
DistSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
DistSliderBg.Parent = DistContainer

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = DistSliderBg

local DistFill = Instance.new("Frame")
DistFill.Size = UDim2.new(0.3, 0, 1, 0)
DistFill.BackgroundColor3 = Color3.fromRGB(120, 80, 240)
DistFill.BorderSizePixel = 0
DistFill.Parent = DistSliderBg

local DistFillCorner = Instance.new("UICorner")
DistFillCorner.CornerRadius = UDim.new(1, 0)
DistFillCorner.Parent = DistFill

local IsDraggingDist = false

local function UpdateDistance(input)
	local relX = math.clamp(input.Position.X - DistSliderBg.AbsolutePosition.X, 0, DistSliderBg.AbsoluteSize.X)
	local alpha = relX / DistSliderBg.AbsoluteSize.X
	
	DistFill.Size = UDim2.new(alpha, 0, 1, 0)
	local dist = math.floor(2 + (alpha * 28)) -- Дистанция от 2 до 30 studs
	System.State.FollowDistance = dist
	DistLabel.Text = string.format("📏 Дистанция следования: %d studs", dist)
end

DistSliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsDraggingDist = true
		UpdateDistance(input)
	end
end)

Services.UserInputService.InputChanged:Connect(function(input)
	if IsDraggingDist and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		UpdateDistance(input)
	end
end)

Services.UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsDraggingDist = false
	end
end)

print("⚡ Motion Recorder Pro v1.0 [Часть 3 из 4] загружена успешно!")
--==================================================================
--    ADVANCED MOTION RECORDER v1.0 [PART 4: IMPORT/EXPORT & SETTINGS]
--==================================================================

if not _G.MotionRecorder or not _G.MotionRecorder.UI then
	warn("⚠️ Ошибка: Сначала необходимо загрузить Части 1, 2 и 3!")
	return
end

local Services = {
	Players = game:GetService("Players"),
	HttpService = game:GetService("HttpService"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local System = _G.MotionRecorder
local SettingsPage = System.UI.Pages["Settings"]

local function SafeCall(fn, ...)
	local success, result = pcall(fn, ...)
	if not success then
		warn("[MotionRecorder Part4 Error]: " .. tostring(result))
	end
	return success, result
end

-- ==========================================
-- СЕКЦИЯ 1: ЭКСПОРТ И ИМПОРТ ЗАПИСЕЙ (JSON)
-- ==========================================

local ExportTitle = Instance.new("TextLabel")
ExportTitle.Size = UDim2.new(1, 0, 0, 20)
ExportTitle.BackgroundTransparency = 1
ExportTitle.Text = "💾 Импорт / Экспорт данных:"
ExportTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
ExportTitle.Font = Enum.Font.GothamBold
ExportTitle.TextSize = 11
ExportTitle.TextXAlignment = Enum.TextXAlignment.Left
ExportTitle.Parent = SettingsPage

local IOBox = Instance.new("TextBox")
IOBox.Size = UDim2.new(1, 0, 0, 60)
IOBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
IOBox.Text = ""
IOBox.PlaceholderText = "Вставьте JSON код записи для импорта сюда..."
IOBox.TextColor3 = Color3.fromRGB(220, 220, 255)
IOBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
IOBox.Font = Enum.Font.Code
IOBox.TextSize = 10
IOBox.ClearTextOnFocus = false
IOBox.TextWrapped = true
IOBox.Parent = SettingsPage

local IOCorner = Instance.new("UICorner")
IOCorner.CornerRadius = UDim.new(0, 6)
IOCorner.Parent = IOBox

local BtnGrid = Instance.new("Frame")
BtnGrid.Size = UDim2.new(1, 0, 0, 32)
BtnGrid.BackgroundTransparency = 1
BtnGrid.Parent = SettingsPage

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 6)
BtnLayout.Parent = BtnGrid

-- Кнопка Экспорта в JSON
local ExpBtn = Instance.new("TextButton")
ExpBtn.Size = UDim2.new(0.5, -3, 1, 0)
ExpBtn.BackgroundColor3 = Color3.fromRGB(60, 45, 110)
ExpBtn.Text = "📋 Экспорт в JSON"
ExpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpBtn.Font = Enum.Font.GothamMedium
ExpBtn.TextSize = 10
ExpBtn.Parent = BtnGrid

local ExpCorner = Instance.new("UICorner")
ExpCorner.CornerRadius = UDim.new(0, 5)
ExpCorner.Parent = ExpBtn

ExpBtn.MouseButton1Click:Connect(function()
	local idx = System.State.SelectedRecordingIndex
	if not idx or not System.SavedRecordings[idx] then
		IOBox.Text = "⚠️ Сначала выберите запись во вкладке 'Повтор'!"
		return
	end

	local rec = System.SavedRecordings[idx]
	local serializableFrames = {}

	for _, f in ipairs(rec.Frames) do
		local px, py, pz, rx, ry, rz, rw = f.CFrame:GetComponents()
		table.insert(serializableFrames, {
			t = f.Time,
			cf = {px, py, pz, rx, ry, rz, rw}
		})
	end

	local exportData = {
		Name = rec.Name,
		Duration = rec.Duration,
		Frames = serializableFrames
	}

	local jsonStr = Services.HttpService:JSONEncode(exportData)
	IOBox.Text = jsonStr

	if setclipboard then
		setclipboard(jsonStr)
		IOBox.Text = "✅ Код скопирован в буфер обмена!"
	end
end)

-- Кнопка Импорта из JSON
local ImpBtn = Instance.new("TextButton")
ImpBtn.Size = UDim2.new(0.5, -3, 1, 0)
ImpBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 60)
ImpBtn.Text = "📥 Импорт из JSON"
ImpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ImpBtn.Font = Enum.Font.GothamMedium
ImpBtn.TextSize = 10
ImpBtn.Parent = BtnGrid

local ImpCorner = Instance.new("UICorner")
ImpCorner.CornerRadius = UDim.new(0, 5)
ImpCorner.Parent = ImpBtn

ImpBtn.MouseButton1Click:Connect(function()
	local rawText = IOBox.Text
	if rawText == "" then return end

	SafeCall(function()
		local decoded = Services.HttpService:JSONDecode(rawText)
		if decoded and decoded.Frames then
			local reconstructedFrames = {}
			for _, f in ipairs(decoded.Frames) do
				table.insert(reconstructedFrames, {
					Time = f.t,
					CFrame = CFrame.new(f.cf[1], f.cf[2], f.cf[3], f.cf[4], f.cf[5], f.cf[6], f.cf[7]),
					Velocity = Vector3.new(),
					RotVelocity = Vector3.new()
				})
			end

			local newRec = {
				Name = decoded.Name or "Imported_Rec",
				Duration = decoded.Duration or 0,
				Frames = reconstructedFrames
			}
			table.insert(System.SavedRecordings, newRec)
			IOBox.Text = "✅ Запись успешно импортирована!"
			if System.UI.RefreshRecordingsList then
				System.UI.RefreshRecordingsList()
			end
		end
	end)
end)

-- ==========================================
-- СЕКЦИЯ 2: ГОРЯЧИЕ КЛАВИШИ (HOTKEYS)
-- ==========================================

local KeybindsTitle = Instance.new("TextLabel")
KeybindsTitle.Size = UDim2.new(1, 0, 0, 20)
KeybindsTitle.BackgroundTransparency = 1
KeybindsTitle.Text = "⌨️ Горячие клавиши:"
KeybindsTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
KeybindsTitle.Font = Enum.Font.GothamBold
KeybindsTitle.TextSize = 11
KeybindsTitle.TextXAlignment = Enum.TextXAlignment.Left
KeybindsTitle.Parent = SettingsPage

local KeyInfoLabel = Instance.new("TextLabel")
KeyInfoLabel.Size = UDim2.new(1, 0, 0, 35)
KeyInfoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
KeyInfoLabel.Text = " [ R ] — Старт / Стоп записи\n [ P ] — Старт / Стоп повтора\n [ K ] — Спрятать / Показать UI"
KeyInfoLabel.TextColor3 = Color3.fromRGB(170, 170, 190)
KeyInfoLabel.Font = Enum.Font.Gotham
KeyInfoLabel.TextSize = 9
KeyInfoLabel.Parent = SettingsPage

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 5)
KeyCorner.Parent = KeyInfoLabel

Services.UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		-- Быстрый старт/стоп записи
		local recPage = System.UI.Pages["Record"]
		if recPage then
			for _, btn in ipairs(recPage:GetChildren()) do
				if btn:IsA("TextButton") and string.find(btn.Text, "ЗАПИСЬ") then
					for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
						conn:Fire()
					end
				end
			end
		end
	elseif input.KeyCode == Enum.KeyCode.K then
		-- Скрыть / показать панель
		if System.UI.ScreenGui then
			System.UI.ScreenGui.Enabled = not System.UI.ScreenGui.Enabled
		end
	end
end)

-- ==========================================
-- СЕКЦИЯ 3: ОЧИСТКА И ВЫГРУЗКА (UNLOAD)
-- ==========================================

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, 0, 0, 35)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 35, 45)
UnloadBtn.Text = "⛔ ПОЛНОСТЬЮ ВЫГРУЗИТЬ СКРИПТ (UNLOAD)"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 10
UnloadBtn.Parent = SettingsPage

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.CornerRadius = UDim.new(0, 6)
UnloadCorner.Parent = UnloadBtn

UnloadBtn.MouseButton1Click:Connect(function()
	-- 1. Отключение всех соединений
	for name, conn in pairs(System.Connections) do
		if conn then
			conn:Disconnect()
		end
	end
	System.Connections = {}

	-- 2. Сброс состояния персонажа и камеры
	local char = LocalPlayer.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored = false end
	end
	Camera.CameraType = Enum.CameraType.Custom

	-- 3. Удаление UI
	if System.UI.ScreenGui then
		System.UI.ScreenGui:Destroy()
	end

	-- 4. Очистка глобального состояния
	_G.MotionRecorder = nil

	print("🔴 Motion Recorder Pro v1.0 успешно выгружен!")
end)

print("🚀 Все 4 части Motion Recorder Pro v1.0 полностью инициализированы!")
