--========================================================
-- DEV ADMIN HUD v2 — MOBILE LOCAL SCRIPT
-- PART 1/4
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================
-- CONFIG
--========================================================

local ITEM_TAG = "Item"

local TOUCH_EXCLUDE_NAMES = {
	Baseplate = true,
	Ground = true,
	Terrain = true
}

local MAX_TOUCH_HISTORY = 30
local DEFAULT_INTERVAL = 3
local TP_STEP_UP = 50

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_GRAVITY = 196.2

local MAX_POINTS = 4

--========================================================
-- COLORS
--========================================================

local COLOR_BG      = Color3.fromRGB(12, 12, 17)
local COLOR_PANEL   = Color3.fromRGB(20, 20, 28)
local COLOR_PANEL2  = Color3.fromRGB(25, 25, 34)
local COLOR_BTN     = Color3.fromRGB(32, 32, 43)
local COLOR_BTN_HOV = Color3.fromRGB(45, 45, 58)

local COLOR_ACCENT   = Color3.fromRGB(0, 220, 175)
local COLOR_ACCENT_D = Color3.fromRGB(0, 75, 63)

local COLOR_TEXT = Color3.fromRGB(238, 238, 243)
local COLOR_SUB  = Color3.fromRGB(145, 145, 157)

local COLOR_DANGER = Color3.fromRGB(210, 65, 70)
local COLOR_WARN   = Color3.fromRGB(225, 170, 55)

--========================================================
-- HELPERS
--========================================================

local function AddCorner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = inst
	return c
end

local function AddStroke(inst, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLOR_ACCENT
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.6
	s.Parent = inst
	return s
end

local function AddHover(btn, base, hover)
	btn.MouseEnter:Connect(function()
		if btn:GetAttribute("NoHover") then
			return
		end

		TweenService:Create(
			btn,
			TweenInfo.new(0.1),
			{BackgroundColor3 = hover}
		):Play()
	end)

	btn.MouseLeave:Connect(function()
		if btn:GetAttribute("Active") then
			return
		end

		TweenService:Create(
			btn,
			TweenInfo.new(0.1),
			{BackgroundColor3 = base}
		):Play()
	end)
end

local function SetButtonState(btn, enabled)
	btn:SetAttribute("Active", enabled)

	TweenService:Create(
		btn,
		TweenInfo.new(0.12),
		{
			BackgroundColor3 = enabled and COLOR_ACCENT_D or COLOR_BTN,
			TextColor3 = enabled and COLOR_ACCENT or COLOR_TEXT
		}
	):Play()
end

local function MakeButton(parent, text, width)
	local b = Instance.new("TextButton")

	b.Size = UDim2.new(0, width or 80, 1, 0)
	b.BackgroundColor3 = COLOR_BTN
	b.TextColor3 = COLOR_TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Text = text
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Parent = parent

	AddCorner(b, 9)
	AddHover(b, COLOR_BTN, COLOR_BTN_HOV)

	return b
end

local function MakeRow(parent, height)
	local f = Instance.new("Frame")

	f.Size = UDim2.new(1, 0, 0, height)
	f.BackgroundTransparency = 1
	f.Parent = parent

	local layout = Instance.new("UIListLayout")

	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 7)
	layout.Parent = f

	return f
end

local function MakeLabel(parent, text, width, size)
	local l = Instance.new("TextLabel")

	l.Size = UDim2.new(0, width, 1, 0)
	l.BackgroundTransparency = 1
	l.TextColor3 = COLOR_TEXT
	l.Font = Enum.Font.GothamMedium
	l.TextSize = size or 13
	l.Text = text
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent

	return l
end

local function MakeBox(parent, placeholder, width)
	local b = Instance.new("TextBox")

	b.Size = UDim2.new(0, width or 70, 1, 0)
	b.BackgroundColor3 = COLOR_BTN
	b.TextColor3 = COLOR_TEXT
	b.PlaceholderColor3 = COLOR_SUB
	b.PlaceholderText = placeholder or ""
	b.Text = ""
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.BorderSizePixel = 0
	b.ClearTextOnFocus = false
	b.Parent = parent

	AddCorner(b, 9)

	return b
end

--========================================================
-- GUI ROOT
--========================================================

local old = LocalPlayer.PlayerGui:FindFirstChild("Dev_AC_HUD")

if old then
	old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "Dev_AC_HUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- MOBILE SCALE
--========================================================

local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.85
UIScale.Parent = ScreenGui

--========================================================
-- MAIN BAR
--========================================================

local Bar = Instance.new("Frame")

Bar.Name = "Bar"
Bar.AnchorPoint = Vector2.new(0.5, 1)
Bar.Position = UDim2.new(0.5, 0, 1, -18)

Bar.Size = UDim2.new(
	0.96,
	0,
	0,
	0
)

Bar.AutomaticSize = Enum.AutomaticSize.Y

Bar.BackgroundColor3 = COLOR_PANEL
Bar.BackgroundTransparency = 0.02
Bar.BorderSizePixel = 0
Bar.Parent = ScreenGui

AddCorner(Bar, 18)
AddStroke(Bar, COLOR_ACCENT, 1, 0.6)

local Pad = Instance.new("UIPadding")

Pad.PaddingTop = UDim.new(0, 12)
Pad.PaddingBottom = UDim.new(0, 12)
Pad.PaddingLeft = UDim.new(0, 10)
Pad.PaddingRight = UDim.new(0, 10)

Pad.Parent = Bar

local MainLayout = Instance.new("UIListLayout")

MainLayout.FillDirection = Enum.FillDirection.Vertical
MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainLayout.Padding = UDim.new(0, 7)
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder

MainLayout.Parent = Bar

--========================================================
-- TOAST
--========================================================

local Toast = Instance.new("TextLabel")

Toast.AnchorPoint = Vector2.new(0.5, 1)
Toast.Position = UDim2.new(0.5, 0, 1, -120)
Toast.Size = UDim2.new(0, 300, 0, 35)

Toast.BackgroundColor3 = COLOR_PANEL2
Toast.TextColor3 = COLOR_TEXT
Toast.Font = Enum.Font.GothamMedium
Toast.TextSize = 13
Toast.Text = ""

Toast.Visible = false
Toast.BorderSizePixel = 0
Toast.Parent = ScreenGui

AddCorner(Toast, 10)
AddStroke(Toast, COLOR_ACCENT, 1, 0.65)

local toastId = 0

local function Notify(text)
	toastId += 1

	local id = toastId

	Toast.Text = text
	Toast.Visible = true
	Toast.TextTransparency = 1

	TweenService:Create(
		Toast,
		TweenInfo.new(0.15),
		{TextTransparency = 0}
	):Play()

	task.delay(1.7, function()

		if id ~= toastId then
			return
		end

		TweenService:Create(
			Toast,
			TweenInfo.new(0.2),
			{TextTransparency = 1}
		):Play()

		task.wait(0.2)

		if id == toastId then
			Toast.Visible = false
		end
	end)
end

--========================================================
-- STATS ROW
--========================================================

local StatsRow = MakeRow(Bar, 22)

local StatsLabel = MakeLabel(
	StatsRow,
	"● 0ms   ⚡ 0   Y:0   FPS:0   👥 0",
	600,
	12
)

StatsLabel.TextColor3 = COLOR_SUB

--========================================================
-- TABS
--========================================================

local TabsRow = MakeRow(Bar, 38)

local MODES = {
	"Players",
	"Items",
	"Touch",
	"Move",
	"Points"
}

local MODE_LABELS = {
	Players = "👤 Игроки",
	Items = "📦 Предметы",
	Touch = "👆 Touch",
	Move = "⚙ Move",
	Points = "📍 Точки"
}

local currentMode = "Players"

local indices = {
	Players = 1,
	Items = 1,
	Touch = 1,
	Move = 1,
	Points = 1
}

local tabButtons = {}

for _, mode in ipairs(MODES) do

	local b = MakeButton(
		TabsRow,
		MODE_LABELS[mode],
		95
	)

	b.mode = mode

	table.insert(
		tabButtons,
		{
			btn = b,
			mode = mode
		}
	)
end

local CollapseBtn = MakeButton(
	TabsRow,
	"▾",
	34
)

--========================================================
-- TARGET ROW
--========================================================

local TargetRow = MakeRow(Bar, 58)

local ArrowLeft = MakeButton(
	TargetRow,
	"◀",
	38
)

local TargetContainer = Instance.new("Frame")

TargetContainer.Size = UDim2.new(0, 390, 1, 0)
TargetContainer.BackgroundTransparency = 1
TargetContainer.Parent = TargetRow

local TargetName = Instance.new("TextLabel")

TargetName.Size = UDim2.new(1, 0, 0.55, 0)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = COLOR_TEXT
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 14
TargetName.Text = "Нет целей"
TargetName.TextTruncate = Enum.TextTruncate.AtEnd

TargetName.Parent = TargetContainer

local TargetInfo = Instance.new("TextLabel")

TargetInfo.Position = UDim2.new(0, 0, 0.52, 0)
TargetInfo.Size = UDim2.new(1, 0, 0.48, 0)
TargetInfo.BackgroundTransparency = 1
TargetInfo.TextColor3 = COLOR_SUB
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.TextSize = 10
TargetInfo.Text = ""

TargetInfo.Parent = TargetContainer

local ArrowRight = MakeButton(
	TargetRow,
	"▶",
	38
)

--========================================================
-- ACTION ROW
--========================================================

local ActionsRow = MakeRow(Bar, 36)

local TPBtn = MakeButton(
	ActionsRow,
	"🎯 TP",
	70
)

local FollowBtn = MakeButton(
	ActionsRow,
	"👁 VIEW",
	78
)

local ESPBtn = MakeButton(
	ActionsRow,
	"◉ ESP",
	72
)

local BringBtn = MakeButton(
	ActionsRow,
	"↔ BRING",
	78
)

local InfoBtn = MakeButton(
	ActionsRow,
	"ⓘ INFO",
	72
)

--========================================================
-- PLAYER MOVEMENT ROW
--========================================================

local MoveRow = MakeRow(Bar, 36)

local WalkLabel = MakeLabel(
	MoveRow,
	"Speed",
	42,
	10
)

local WalkBox = MakeBox(
	MoveRow,
	"16",
	55
)

local WalkSet = MakeButton(
	MoveRow,
	"SET",
	48
)

local JumpLabel = MakeLabel(
	MoveRow,
	"Jump",
	40,
	10
)

local JumpBox = MakeBox(
	MoveRow,
	"50",
	55
)

local JumpSet = MakeButton(
	MoveRow,
	"SET",
	48
)

--========================================================
-- MOVEMENT ACTION ROW
--========================================================

local MoveActionsRow = MakeRow(Bar, 36)

local NoclipBtn = MakeButton(
	MoveActionsRow,
	"🚫 NOCLIP",
	85
)

local FlyBtn = MakeButton(
	MoveActionsRow,
	"✈ FLY",
	72
)

local GravityBtn = MakeButton(
	MoveActionsRow,
	"G GRAVITY",
	90
)

local UpBtn = MakeButton(
	MoveActionsRow,
	"↑ +50",
	65
)

local DownBtn = MakeButton(
	MoveActionsRow,
	"↓ Y10",
	65
)

--========================================================
-- POINTS ROW
--========================================================

local PointsRow = MakeRow(Bar, 36)

local PointButtons = {}

for i = 1, MAX_POINTS do

	local b = MakeButton(
		PointsRow,
		"SAVE " .. i,
		70
	)

	PointButtons[i] = b
end

local ClearPointsBtn = MakeButton(
	PointsRow,
	"CLEAR",
	65
)

--========================================================
-- SEARCH ROW
--========================================================

local SearchRow = MakeRow(Bar, 34)

local SearchBox = MakeBox(
	SearchRow,
	"Название предмета...",
	260
)

local SearchBtn = MakeButton(
	SearchRow,
	"🔎 НАЙТИ",
	85
)

--========================================================
-- DEBUG INFO
--========================================================

local DebugRow = MakeRow(Bar, 46)

local DebugLabel = MakeLabel(
	DebugRow,
	"",
	600,
	9
)

DebugLabel.TextColor3 = COLOR_SUB

--========================================================
-- DATA
--========================================================

local touchedHistory = {}
local touchedSet = {}

local savedPoints = {}

local playerESP = false
local itemESP = false

local noclipEnabled = false
local flyEnabled = false
local gravityPreview = false

local autoEnabled = false

local savedCFrame = nil
local isTeleported = false

local currentCameraTarget = nil

--========================================================
-- ITEM FUNCTIONS
--========================================================

local function GetItemPosition(inst)

	if inst:IsA("BasePart") then
		return inst.Position

	elseif inst:IsA("Model") then

		if inst.PrimaryPart then
			return inst.PrimaryPart.Position
		end

		local ok, cf = pcall(function()
			return inst:GetBoundingBox()
		end)

		if ok and cf then
			return cf.Position
		end
	end

	return nil
end

local function GetItems()

	local items = {}
	local seen = {}

	for _, inst in ipairs(
		CollectionService:GetTagged(ITEM_TAG)
	) do

		if (
			inst:IsA("BasePart")
			or inst:IsA("Model")
		) and not seen[inst] then

			seen[inst] = true
			table.insert(items, inst)
		end
	end

	local folder = workspace:FindFirstChild("Items")

	if folder then

		for _, inst in ipairs(
			folder:GetDescendants()
		) do

			if (
				inst:IsA("BasePart")
				or (
					inst:IsA("Model")
					and inst.PrimaryPart
				)
			) and not seen[inst] then

				seen[inst] = true
				table.insert(items, inst)
			end
		end
	end

	return items
end

--========================================================
-- PLAYER FUNCTIONS
--========================================================

local function GetOtherPlayers()

	local list = {}

	for _, p in ipairs(
		Players:GetPlayers()
	) do

		if p ~= LocalPlayer then
			table.insert(list, p)
		end
	end

	table.sort(list, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	return list
end

local function GetListForMode(mode)

	if mode == "Players" then
		return GetOtherPlayers()

	elseif mode == "Items" then
		return GetItems()

	elseif mode == "Touch" then
		return touchedHistory
	end

	return {}
end

local function IsValidEntry(mode, entry)

	if not entry then
		return false
	end

	if mode == "Players" then
		return entry.Parent == Players
	end

	return entry:IsDescendantOf(workspace)
end

local function PositionOf(mode, entry)

	if mode == "Players" then

		local char = entry.Character

		local hrp = char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		return hrp and hrp.Position
	end

	return GetItemPosition(entry)
end

--========================================================
-- TARGET REFRESH
--========================================================

local function RefreshTarget()

	local list = GetListForMode(currentMode)

	local idx = indices[currentMode] or 1

	if #list == 0 then

		TargetName.Text = "Нет целей"
		TargetInfo.Text = ""

		return
	end

	if idx < 1 then
		idx = #list
	end

	if idx > #list then
		idx = 1
	end

	indices[currentMode] = idx

	local entry = list[idx]

	if currentMode == "Players" then

		local char = entry.Character

		local hum = char
			and char:FindFirstChildOfClass(
				"Humanoid"
			)

		local pos = PositionOf(
			currentMode,
			entry
		)

		local distance = 0

		local myChar = LocalPlayer.Character

		local myHRP = myChar
			and myChar:FindFirstChild(
				"HumanoidRootPart"
			)

		if myHRP and pos then

			distance = math.floor(
				(myHRP.Position - pos).Magnitude
			)
		end

		TargetName.Text = string.format(
			"%s   (@%s)   %d/%d",
			entry.DisplayName,
			entry.Name,
			idx,
			#list
		)

		if hum then

			TargetInfo.Text = string.format(
				"♥ %d/%d     ⚡ %.0f     📍 %d studs",
				math.floor(hum.Health),
				math.floor(hum.MaxHealth),
				hum.WalkSpeed,
				distance
			)

		else

			TargetInfo.Text =
				"Персонаж отсутствует"

		end

	else

		local pos = PositionOf(
			currentMode,
			entry
		)

		local distance = 0

		local char = LocalPlayer.Character

		local hrp = char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		if hrp and pos then

			distance = math.floor(
				(hrp.Position - pos).Magnitude
			)
		end

		TargetName.Text = string.format(
			"%s   %d/%d",
			entry.Name,
			idx,
			#list
		)

		TargetInfo.Text = pos and string.format(
			"📍 %.0f / %.0f / %.0f     %d studs",
			pos.X,
			pos.Y,
			pos.Z,
			distance
		) or ""
	end
end

--========================================================
-- TELEPORT
--========================================================

local function DoTeleportToCurrent()

	local list = GetListForMode(currentMode)

	local idx = indices[currentMode]

	local entry = list[idx]

	if not entry
		or not IsValidEntry(currentMode, entry) then
		return false
	end

	local pos = PositionOf(
		currentMode,
		entry
	)

	local char = LocalPlayer.Character

	local hrp = char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	if hrp and pos then

		if not isTeleported then

			savedCFrame = hrp.CFrame
			isTeleported = true
		end

		hrp.CFrame =
			CFrame.new(
				pos + Vector3.new(0,3,0)
			)

		Notify(
			"✓ Teleported to "
			.. entry.Name
		)

		return true
	end

	return false
end

--========================================================
-- TOUCH HISTORY
--========================================================

local function OnTouched(otherPart)

	if not otherPart:IsA("BasePart") then
		return
	end

	if TOUCH_EXCLUDE_NAMES[
		otherPart.Name
	] then
		return
	end

	local char = LocalPlayer.Character

	if char
		and otherPart:IsDescendantOf(char) then
		return
	end

	local target = otherPart

	local model =
		otherPart:FindFirstAncestorOfClass(
			"Model"
		)

	if model and model.PrimaryPart then
		target = model
	end

	if touchedSet[target] then
		return
	end

	touchedSet[target] = true

	table.insert(
		touchedHistory,
		1,
		target
	)

	if #touchedHistory >
		MAX_TOUCH_HISTORY then

		local removed =
			table.remove(
				touchedHistory
			)

		touchedSet[removed] = nil
	end

	if currentMode == "Touch" then
		RefreshTarget()
	end
end

local function HookCharacterTouches(char)

	for _, part in ipairs(
		char:GetDescendants()
	) do

		if part:IsA("BasePart") then

			part.Touched:Connect(
				OnTouched
			)
		end
	end

	char.DescendantAdded:Connect(
		function(desc)

			if desc:IsA("BasePart") then

				desc.Touched:Connect(
					OnTouched
				)
			end
		end
	)
end

if LocalPlayer.Character then
	HookCharacterTouches(
		LocalPlayer.Character
	)
end

LocalPlayer.CharacterAdded:Connect(
	function(char)

		task.wait(0.3)

		HookCharacterTouches(char)
	end
)

--========================================================
-- END PART 1/4
--========================================================
--========================================================
-- DEV ADMIN HUD v2
-- PART 2/4
--========================================================

--========================================================
-- SPECTATE
--========================================================

local function StopSpectate()

	local char = LocalPlayer.Character

	local hum = char
		and char:FindFirstChildOfClass("Humanoid")

	if hum then
		Camera.CameraSubject = hum
	end

	currentCameraTarget = nil

	Notify("👁 Spectate OFF")
end

local function SpectateCurrent()

	if currentMode ~= "Players" then
		StopSpectate()
		return
	end

	local list = GetOtherPlayers()

	local target =
		list[indices.Players]

	if not target then
		return
	end

	local char = target.Character

	local hum = char
		and char:FindFirstChildOfClass(
			"Humanoid"
		)

	if not hum then
		Notify("Нет Humanoid")
		return
	end

	Camera.CameraSubject = hum
	currentCameraTarget = target

	Notify(
		"👁 Viewing "
		.. target.Name
	)
end

--========================================================
-- PLAYER INFO
--========================================================

InfoBtn.MouseButton1Click:Connect(function()

	if currentMode ~= "Players" then
		return
	end

	local list = GetOtherPlayers()

	local target =
		list[indices.Players]

	if not target then
		return
	end

	local char = target.Character

	local hum = char
		and char:FindFirstChildOfClass(
			"Humanoid"
		)

	local hrp = char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	local myChar = LocalPlayer.Character

	local myHRP = myChar
		and myChar:FindFirstChild(
			"HumanoidRootPart"
		)

	if hum and hrp then

		local distance = 0

		if myHRP then

			distance = (
				myHRP.Position
				- hrp.Position
			).Magnitude
		end

		Notify(string.format(
			"%s | HP %d | %.0f studs",
			target.Name,
			hum.Health,
			distance
		))
	end
end)

--========================================================
-- BRING
--========================================================

BringBtn.MouseButton1Click:Connect(function()

	if currentMode ~= "Players" then
		return
	end

	local list = GetOtherPlayers()

	local target =
		list[indices.Players]

	local myChar = LocalPlayer.Character

	local myHRP = myChar
		and myChar:FindFirstChild(
			"HumanoidRootPart"
		)

	local targetChar =
		target and target.Character

	local targetHRP =
		targetChar
		and targetChar:FindFirstChild(
			"HumanoidRootPart"
		)

	if myHRP and targetHRP then

		targetHRP.CFrame =
			myHRP.CFrame
			* CFrame.new(0,0,-4)

		Notify(
			"↔ Brought "
			.. target.Name
		)
	end
end)

--========================================================
-- PLAYER ESP
--========================================================

local function RemovePlayerESP()

	for _, p in ipairs(
		Players:GetPlayers()
	) do

		local char = p.Character

		if char then

			local h =
				char:FindFirstChild(
					"DevAdminESP"
				)

			if h then
				h:Destroy()
			end

			local bill =
				char:FindFirstChild(
					"DevAdminName"
				)

			if bill then
				bill:Destroy()
			end
		end
	end
end

local function AddPlayerESP(player)

	if player == LocalPlayer then
		return
	end

	local char = player.Character

	if not char then
		return
	end

	local old =
		char:FindFirstChild(
			"DevAdminESP"
		)

	if old then
		old:Destroy()
	end

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"DevAdminESP"

	highlight.FillColor =
		COLOR_ACCENT

	highlight.OutlineColor =
		Color3.new(1,1,1)

	highlight.FillTransparency =
		0.82

	highlight.OutlineTransparency =
		0.15

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = char

	local bill =
		Instance.new("BillboardGui")

	bill.Name =
		"DevAdminName"

	bill.Size =
		UDim2.new(0,180,0,45)

	bill.StudsOffset =
		Vector3.new(0,3.2,0)

	bill.AlwaysOnTop = true
	bill.Parent = char

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(1,0,1,0)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		Color3.new(1,1,1)

	label.TextStrokeTransparency =
		0.4

	label.Font =
		Enum.Font.GothamBold

	label.TextSize = 12

	label.Text =
		player.DisplayName
		.. "\n@"
		.. player.Name

	label.Parent = bill
end

local function UpdatePlayerESP()

	if not playerESP then

		RemovePlayerESP()

		return
	end

	for _, p in ipairs(
		Players:GetPlayers()
	) do

		AddPlayerESP(p)
	end
end

--========================================================
-- ITEM ESP
--========================================================

local function RemoveItemESP()

	for _, item in ipairs(
		GetItems()
	) do

		local h =
			item:FindFirstChild(
				"DevItemESP"
			)

		if h then
			h:Destroy()
		end

		local bill =
			item:FindFirstChild(
				"DevItemName"
			)

		if bill then
			bill:Destroy()
		end
	end
end

local function AddItemESP(item)

	local part

	if item:IsA("BasePart") then

		part = item

	elseif item:IsA("Model") then

		part = item.PrimaryPart
	end

	if not part then
		return
	end

	local old =
		item:FindFirstChild(
			"DevItemESP"
		)

	if old then
		old:Destroy()
	end

	local h =
		Instance.new("Highlight")

	h.Name =
		"DevItemESP"

	h.FillColor =
		COLOR_WARN

	h.OutlineColor =
		Color3.new(1,1,1)

	h.FillTransparency =
		0.82

	h.OutlineTransparency =
		0.2

	h.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	h.Parent = item

	local bill =
		Instance.new("BillboardGui")

	bill.Name =
		"DevItemName"

	bill.Size =
		UDim2.new(0,140,0,30)

	bill.StudsOffset =
		Vector3.new(0,2.5,0)

	bill.AlwaysOnTop = true

	bill.Adornee = part
	bill.Parent = item

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.new(1,0,1,0)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		COLOR_WARN

	label.TextStrokeTransparency =
		0.35

	label.Font =
		Enum.Font.GothamBold

	label.TextSize = 11

	label.Text =
		item.Name

	label.Parent = bill
end

local function UpdateItemESP()

	if not itemESP then

		RemoveItemESP()

		return
	end

	for _, item in ipairs(
		GetItems()
	) do

		AddItemESP(item)
	end
end

--========================================================
-- ESP BUTTON
--========================================================

ESPBtn.MouseButton1Click:Connect(function()

	if currentMode == "Players" then

		playerESP = not playerESP

		SetButtonState(
			ESPBtn,
			playerESP
		)

		UpdatePlayerESP()

		Notify(
			"ESP Players: "
			.. (
				playerESP
				and "ON"
				or "OFF"
			)
		)

	elseif currentMode == "Items" then

		itemESP = not itemESP

		SetButtonState(
			ESPBtn,
			itemESP
		)

		UpdateItemESP()

		Notify(
			"ESP Items: "
			.. (
				itemESP
				and "ON"
				or "OFF"
			)
		)
	end
end)

--========================================================
-- PLAYER RESPAWN ESP
--========================================================

Players.PlayerAdded:Connect(
	function(player)

		player.CharacterAdded:Connect(
			function()

				task.wait(0.5)

				if playerESP then
					AddPlayerESP(player)
				end
			end
		)
	end
)

--========================================================
-- TP / VIEW / NAVIGATION
--========================================================

ArrowLeft.MouseButton1Click:Connect(
	function()

		indices[currentMode] =
			(indices[currentMode] or 1)
			- 1

		RefreshTarget()
	end
)

ArrowRight.MouseButton1Click:Connect(
	function()

		indices[currentMode] =
			(indices[currentMode] or 1)
			+ 1

		RefreshTarget()
	end
)

TPBtn.MouseButton1Click:Connect(
	function()
		DoTeleportToCurrent()
	end
)

FollowBtn.MouseButton1Click:Connect(
	function()

		if currentMode == "Players" then
			SpectateCurrent()
		else
			StopSpectate()
		end
	end
)

--========================================================
-- WALK SPEED
--========================================================

local function ApplyWalkSpeed()

	local value =
		tonumber(WalkBox.Text)

	if not value then

		Notify(
			"⚠ Некорректная скорость"
		)

		return
	end

	value =
		math.clamp(
			value,
			0,
			250
		)

	local char =
		LocalPlayer.Character

	local hum =
		char
		and char:FindFirstChildOfClass(
			"Humanoid"
		)

	if hum then

		hum.WalkSpeed =
			value

		Notify(
			"⚡ WalkSpeed = "
			.. value
		)
	end
end

WalkSet.MouseButton1Click:Connect(
	ApplyWalkSpeed
)

WalkBox.FocusLost:Connect(
	function(enterPressed)

		if enterPressed then
			ApplyWalkSpeed()
		end
	end
)

--========================================================
-- JUMP POWER
--========================================================

local function ApplyJumpPower()

	local value =
		tonumber(JumpBox.Text)

	if not value then

		Notify(
			"⚠ Некорректный JumpPower"
		)

		return
	end

	value =
		math.clamp(
			value,
			0,
			250
		)

	local char =
		LocalPlayer.Character

	local hum =
		char
		and char:FindFirstChildOfClass(
			"Humanoid"
		)

	if hum then

		hum.UseJumpPower = true
		hum.JumpPower = value

		Notify(
			"↑ JumpPower = "
			.. value
		)
	end
end

JumpSet.MouseButton1Click:Connect(
	ApplyJumpPower
)

JumpBox.FocusLost:Connect(
	function(enterPressed)

		if enterPressed then
			ApplyJumpPower()
		end
	end
)

--========================================================
-- NOCLIP
--========================================================

local function SetNoclip(state)

	noclipEnabled = state

	SetButtonState(
		NoclipBtn,
		state
	)

	Notify(
		"Noclip: "
		.. (
			state
			and "ON"
			or "OFF"
		)
	)
end

NoclipBtn.MouseButton1Click:Connect(
	function()

		SetNoclip(
			not noclipEnabled
		)
	end
)

RunService.Stepped:Connect(
	function()

		if not noclipEnabled then
			return
		end

		local char =
			LocalPlayer.Character

		if not char then
			return
		end

		for _, obj in ipairs(
			char:GetDescendants()
		) do

			if obj:IsA("BasePart") then
				obj.CanCollide = false
			end
		end
	end
)

--========================================================
-- FLY OBJECTS
--========================================================

local flyVelocity
local flyGyro

local flySpeed = 65

local function StopFly()

	if flyVelocity then

		flyVelocity:Destroy()
		flyVelocity = nil
	end

	if flyGyro then

		flyGyro:Destroy()
		flyGyro = nil
	end
end

local function StartFly()

	local char =
		LocalPlayer.Character

	local hrp =
		char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hrp then
		return
	end

	flyVelocity =
		Instance.new("BodyVelocity")

	flyVelocity.Name =
		"DevAdminFlyVelocity"

	flyVelocity.MaxForce =
		Vector3.new(
			1e6,
			1e6,
			1e6
		)

	flyVelocity.Velocity =
		Vector3.zero

	flyVelocity.Parent = hrp

	flyGyro =
		Instance.new("BodyGyro")

	flyGyro.Name =
		"DevAdminFlyGyro"

	flyGyro.MaxTorque =
		Vector3.new(
			1e6,
			1e6,
			1e6
		)

	flyGyro.P =
		10000

	flyGyro.CFrame =
		hrp.CFrame

	flyGyro.Parent = hrp
end

--========================================================
-- END PART 2/4
--===================================================
--========================================================
-- DEV ADMIN HUD v2
-- PART 3/4
--========================================================

--========================================================
-- FLY BUTTON
--========================================================

FlyBtn.MouseButton1Click:Connect(function()

	flyEnabled = not flyEnabled

	SetButtonState(
		FlyBtn,
		flyEnabled
	)

	if flyEnabled then

		StartFly()

		Notify("✈ Fly ON")

	else

		StopFly()

		Notify("✈ Fly OFF")
	end
end)

--========================================================
-- FLY MOVEMENT
--========================================================

RunService.RenderStepped:Connect(function()

	if not flyEnabled then
		return
	end

	local char =
		LocalPlayer.Character

	local hrp =
		char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hrp then
		return
	end

	if not flyVelocity then
		return
	end

	local direction =
		Vector3.zero

	local camCF =
		Camera.CFrame

	-- PC controls
	if UserInputService:IsKeyDown(
		Enum.KeyCode.W
	) then

		direction +=
			camCF.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.S
	) then

		direction -=
			camCF.LookVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.D
	) then

		direction +=
			camCF.RightVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.A
	) then

		direction -=
			camCF.RightVector
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.Space
	) then

		direction +=
			Vector3.yAxis
	end

	if UserInputService:IsKeyDown(
		Enum.KeyCode.LeftControl
	) then

		direction -=
			Vector3.yAxis
	end

	if direction.Magnitude > 0 then

		direction =
			direction.Unit
	end

	flyVelocity.Velocity =
		direction * flySpeed

	if flyGyro then

		flyGyro.CFrame =
			CFrame.lookAt(
				hrp.Position,
				hrp.Position
					+ camCF.LookVector
			)
	end
end)

--========================================================
-- MOBILE FLY CONTROLS
--========================================================

local MobileFlyFrame =
	Instance.new("Frame")

MobileFlyFrame.Name =
	"MobileFlyControls"

MobileFlyFrame.AnchorPoint =
	Vector2.new(1, 1)

MobileFlyFrame.Position =
	UDim2.new(
		1,
		-20,
		1,
		-150
	)

MobileFlyFrame.Size =
	UDim2.new(
		0,
		150,
		0,
		120
	)

MobileFlyFrame.BackgroundTransparency =
	1

MobileFlyFrame.Visible = false

MobileFlyFrame.Parent =
	ScreenGui

local function MobileFlyButton(
	text,
	x,
	y
)

	local b =
		Instance.new("TextButton")

	b.Size =
		UDim2.new(
			0,
			48,
			0,
			48
		)

	b.Position =
		UDim2.new(
			0,
			x,
			0,
			y
		)

	b.BackgroundColor3 =
		COLOR_BTN

	b.TextColor3 =
		COLOR_TEXT

	b.Text =
		text

	b.Font =
		Enum.Font.GothamBold

	b.TextSize = 18

	b.BorderSizePixel = 0

	b.AutoButtonColor = false

	b.Parent =
		MobileFlyFrame

	AddCorner(b, 12)
	AddStroke(
		b,
		COLOR_ACCENT,
		1,
		0.7
	)

	AddHover(
		b,
		COLOR_BTN,
		COLOR_BTN_HOV
	)

	return b
end

local FlyUpBtn =
	MobileFlyButton(
		"▲",
		51,
		0
	)

local FlyDownBtn =
	MobileFlyButton(
		"▼",
		51,
		58
	)

local FlyForwardBtn =
	MobileFlyButton(
		"↑",
		0,
		29
	)

local FlyBackBtn =
	MobileFlyButton(
		"↓",
		102,
		29
	)

local mobileFlyUp = false
local mobileFlyDown = false
local mobileFlyForward = false
local mobileFlyBack = false

FlyUpBtn.MouseButton1Down:Connect(
	function()
		mobileFlyUp = true
	end
)

FlyUpBtn.MouseButton1Up:Connect(
	function()
		mobileFlyUp = false
	end
)

FlyDownBtn.MouseButton1Down:Connect(
	function()
		mobileFlyDown = true
	end
)

FlyDownBtn.MouseButton1Up:Connect(
	function()
		mobileFlyDown = false
	end
)

FlyForwardBtn.MouseButton1Down:Connect(
	function()
		mobileFlyForward = true
	end
)

FlyForwardBtn.MouseButton1Up:Connect(
	function()
		mobileFlyForward = false
	end
)

FlyBackBtn.MouseButton1Down:Connect(
	function()
		mobileFlyBack = true
	end
)

FlyBackBtn.MouseButton1Up:Connect(
	function()
		mobileFlyBack = false
	end
)

RunService.RenderStepped:Connect(
	function()

		if not flyEnabled then
			return
		end

		local char =
			LocalPlayer.Character

		local hrp =
			char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		if not hrp then
			return
		end

		if not flyVelocity then
			return
		end

		local cam =
			Camera.CFrame

		local dir =
			Vector3.zero

		if mobileFlyForward then
			dir += cam.LookVector
		end

		if mobileFlyBack then
			dir -= cam.LookVector
		end

		if mobileFlyUp then
			dir += Vector3.yAxis
		end

		if mobileFlyDown then
			dir -= Vector3.yAxis
		end

		if dir.Magnitude > 0 then
			dir = dir.Unit
		end

		flyVelocity.Velocity =
			dir * flySpeed
	end
)

--========================================================
-- SHOW MOBILE FLY CONTROLS
--========================================================

local function UpdateMobileControls()

	MobileFlyFrame.Visible =
		flyEnabled
		and UserInputService.TouchEnabled
end

FlyBtn.MouseButton1Click:Connect(
	UpdateMobileControls
)

--========================================================
-- GRAVITY PREVIEW
--========================================================

GravityBtn.MouseButton1Click:Connect(
	function()

		gravityPreview =
			not gravityPreview

		SetButtonState(
			GravityBtn,
			gravityPreview
		)

		if gravityPreview then

			workspace.Gravity = 70

			Notify(
				"G Gravity Preview = 70"
			)

		else

			workspace.Gravity =
				DEFAULT_GRAVITY

			Notify(
				"G Gravity = Default"
			)
		end
	end
)

--========================================================
-- UP
--========================================================

UpBtn.MouseButton1Click:Connect(
	function()

		local char =
			LocalPlayer.Character

		local hrp =
			char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		if hrp then

			hrp.CFrame +=
				Vector3.new(
					0,
					TP_STEP_UP,
					0
				)

			Notify("↑ +50")
		end
	end
)

--========================================================
-- DOWN
--========================================================

DownBtn.MouseButton1Click:Connect(
	function()

		local char =
			LocalPlayer.Character

		local hrp =
			char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		if hrp then

			hrp.CFrame =
				CFrame.new(
					hrp.Position.X,
					10,
					hrp.Position.Z
				)

			Notify("↓ Y = 10")
		end
	end
)

--========================================================
-- SAVED POINTS
--========================================================

local function SavePoint(index)

	local char =
		LocalPlayer.Character

	local hrp =
		char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hrp then
		return
	end

	savedPoints[index] =
		hrp.CFrame

	PointButtons[index].Text =
		"✓ POINT "
		.. index

	Notify(string.format(
		"✓ Point %d saved: %.0f / %.0f / %.0f",
		index,
		hrp.Position.X,
		hrp.Position.Y,
		hrp.Position.Z
	))
end

local function TeleportPoint(index)

	local cf =
		savedPoints[index]

	if not cf then

		Notify(
			"⚠ Point "
			.. index
			.. " пуст"
		)

		return
	end

	local char =
		LocalPlayer.Character

	local hrp =
		char
		and char:FindFirstChild(
			"HumanoidRootPart"
		)

	if hrp then

		hrp.CFrame = cf

		Notify(
			"📍 TP Point "
			.. index
		)
	end
end

for i = 1, MAX_POINTS do

	local index = i

	PointButtons[i].MouseButton1Click:Connect(
		function()

			if savedPoints[index] then

				TeleportPoint(index)

			else

				SavePoint(index)
			end
		end
	)

	PointButtons[i].MouseButton2Click:Connect(
		function()

			SavePoint(index)
		end
	)
end

--========================================================
-- CLEAR POINTS
--========================================================

ClearPointsBtn.MouseButton1Click:Connect(
	function()

		savedPoints = {}

		for i = 1, MAX_POINTS do

			PointButtons[i].Text =
				"SAVE "
				.. i
		end

		Notify(
			"✓ Points cleared"
		)
	end
)

--========================================================
-- SEARCH ITEMS
--========================================================

SearchBtn.MouseButton1Click:Connect(
	function()

		local q =
			SearchBox.Text
			:lower()
			:gsub("^%s+", "")
			:gsub("%s+$", "")

		if q == "" then
			return
		end

		local items =
			GetItems()

		for i, inst in ipairs(items) do

			if inst.Name
				:lower()
				:find(
					q,
					1,
					true
				)
			then

				currentMode =
					"Items"

				indices.Items = i

				RefreshTarget()

				DoTeleportToCurrent()

				Notify(
					"✓ Found "
					.. inst.Name
				)

				return
			end
		end

		Notify(
			"❌ Item not found"
		)
	end
)

--========================================================
-- MODE SWITCH
--========================================================

local function UpdateTabs()

	for _, data in ipairs(
		tabButtons
	) do

		SetButtonState(
			data.btn,
			data.mode
				== currentMode
		)
	end
end

local function UpdateVisibility()

	local playerMode =
		currentMode == "Players"

	local itemMode =
		currentMode == "Items"

	local moveMode =
		currentMode == "Move"

	local pointsMode =
		currentMode == "Points"

	TargetRow.Visible =
		not (
			moveMode
			or pointsMode
		)

	ActionsRow.Visible =
		playerMode
		or itemMode

	MoveRow.Visible =
		moveMode

	MoveActionsRow.Visible =
		moveMode

	PointsRow.Visible =
		pointsMode

	SearchRow.Visible =
		itemMode

	DebugRow.Visible = true

	ESPBtn.Visible =
		playerMode
		or itemMode

	if playerMode then

		ESPBtn.Text =
			"◉ ESP"

	elseif itemMode then

		ESPBtn.Text =
			"◉ ITEM ESP"
	end

	if moveMode then

		TargetName.Text =
			"MOVEMENT"

		TargetInfo.Text =
			"Local development controls"
	end

	if pointsMode then

		TargetName.Text =
			"SAVED POINTS"

		TargetInfo.Text =
			"ЛКМ: TP · ПКМ: перезаписать"
	end

	RefreshTarget()
	UpdateTabs()
end

for _, data in ipairs(
	tabButtons
) do

	data.btn.MouseButton1Click:Connect(
		function()

			currentMode =
				data.mode

			UpdateVisibility()
		end
	)
end

--========================================================
-- END PART 3/4
--========================================================
--========================================================
-- DEV ADMIN HUD v2
-- PART 4/4
--========================================================

--========================================================
-- COLLAPSE
--========================================================

local collapsed = false

CollapseBtn.MouseButton1Click:Connect(function()

	collapsed = not collapsed

	CollapseBtn.Text =
		collapsed
		and "▸"
		or "▾"

	for _, child in ipairs(
		Bar:GetChildren()
	) do

		if child:IsA("Frame")
			and child ~= TabsRow
		then

			child.Visible =
				not collapsed
		end
	end

	TabsRow.Visible = true
end)

--========================================================
-- RETURN AFTER TP
--========================================================

local ReturnBtn =
	MakeButton(
		ActionsRow,
		"↩ RETURN",
		85
	)

ReturnBtn.MouseButton1Click:Connect(
	function()

		local char =
			LocalPlayer.Character

		local hrp =
			char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		if hrp and savedCFrame then

			hrp.CFrame =
				savedCFrame

			savedCFrame = nil
			isTeleported = false

			Notify(
				"↩ Returned"
			)
		end
	end
)

--========================================================
-- AUTO
--========================================================

local AutoBtn =
	MakeButton(
		ActionsRow,
		"🔁 AUTO",
		80
	)

AutoBtn.MouseButton1Click:Connect(
	function()

		autoEnabled =
			not autoEnabled

		SetButtonState(
			AutoBtn,
			autoEnabled
		)

		if autoEnabled then

			Notify(
				"🔁 Auto ON"
			)

			task.spawn(
				function()

					while autoEnabled do

						local list =
							GetListForMode(
								currentMode
							)

						if #list > 0 then

							indices[currentMode] =
								(
									indices[currentMode]
									% #list
								) + 1

							RefreshTarget()

							if currentMode
								== "Players"
								or currentMode
								== "Items"
								or currentMode
								== "Touch"
							then

								DoTeleportToCurrent()
							end
						end

						task.wait(
							DEFAULT_INTERVAL
						)
					end
				end
			)

		else

			Notify(
				"🔁 Auto OFF"
			)
		end
	end
)

--========================================================
-- FPS / STATS
--========================================================

local frames = 0
local fps = 60
local lastFPSUpdate =
	os.clock()

RunService.RenderStepped:Connect(
	function()

		frames += 1

		local now =
			os.clock()

		if now - lastFPSUpdate >= 1 then

			fps = frames
			frames = 0

			lastFPSUpdate =
				now
		end

		local char =
			LocalPlayer.Character

		local hrp =
			char
			and char:FindFirstChild(
				"HumanoidRootPart"
			)

		local ping = 0

		local ok, pingItem =
			pcall(
				function()

					return Stats
						.Network
						.ServerStatsItem[
							"Data Ping"
						]
						:GetValue()
				end
			)

		if ok and pingItem then

			ping =
				math.floor(
					pingItem
				)
		end

		local speed = 0
		local height = 0

		if hrp then

			speed =
				math.floor(
					Vector3.new(
						hrp.AssemblyLinearVelocity.X,
						0,
						hrp.AssemblyLinearVelocity.Z
					).Magnitude
				)

			height =
				math.floor(
					hrp.Position.Y
				)
		end

		local playerCount =
			#Players:GetPlayers()

		local pingIcon = "●"

		StatsLabel.Text =
			string.format(
				"%s %dms   ⚡%d   Y:%d   FPS:%d   👥%d",
				pingIcon,
				ping,
				speed,
				height,
				fps,
				playerCount
			)

		if ping < 80 then

			StatsLabel.TextColor3 =
				COLOR_ACCENT

		elseif ping < 150 then

			StatsLabel.TextColor3 =
				COLOR_WARN

		else

			StatsLabel.TextColor3 =
				COLOR_DANGER
		end

		local posText = ""

		if hrp then

			posText =
				string.format(
					"XYZ: %.1f / %.1f / %.1f",
					hrp.Position.X,
					hrp.Position.Y,
					hrp.Position.Z
				)
		end

		local hum =
			char
			and char:FindFirstChildOfClass(
				"Humanoid"
			)

		if hum then

			DebugLabel.Text =
				string.format(
					"%s     HP: %d/%d     WalkSpeed: %.0f     JumpPower: %.0f",
					posText,
					hum.Health,
					hum.MaxHealth,
					hum.WalkSpeed,
					hum.JumpPower
				)

		else

			DebugLabel.Text =
				posText
		end

		if currentMode == "Players" then

			RefreshTarget()
		end
	end
)

--========================================================
-- CHARACTER RESET
--========================================================

LocalPlayer.CharacterAdded:Connect(
	function()

		task.wait(0.5)

		if flyEnabled then

			StopFly()

			flyEnabled = false

			SetButtonState(
				FlyBtn,
				false
			)

			UpdateMobileControls()
		end

		if noclipEnabled then

			SetNoclip(false)
		end

		local char =
			LocalPlayer.Character

		local hum =
			char
			and char:FindFirstChildOfClass(
				"Humanoid"
			)

		if hum then

			hum.WalkSpeed =
				tonumber(
					WalkBox.Text
				)
				or DEFAULT_WALKSPEED

			hum.UseJumpPower =
				true

			hum.JumpPower =
				tonumber(
					JumpBox.Text
				)
				or DEFAULT_JUMPPOWER
		end

		if gravityPreview then

			workspace.Gravity = 70

		else

			workspace.Gravity =
				DEFAULT_GRAVITY
		end

		if playerESP then

			task.wait(0.2)

			UpdatePlayerESP()
		end

		RefreshTarget()
	end
)

--========================================================
-- PLAYER CHANGES
--========================================================

Players.PlayerAdded:Connect(
	function()

		task.defer(
			RefreshTarget
		)
	end
)

Players.PlayerRemoving:Connect(
	function(player)

		if currentCameraTarget
			== player
		then

			StopSpectate()
		end

		task.defer(
			RefreshTarget
		)
	end
)

--========================================================
-- MOBILE HUD POSITION
--========================================================

if UserInputService.TouchEnabled then

	Bar.AnchorPoint =
		Vector2.new(
			0.5,
			1
		)

	Bar.Position =
		UDim2.new(
			0.5,
			0,
			1,
			-10
		)

	Bar.Size =
		UDim2.new(
			0.96,
			0,
			0,
			0
		)

	-- немного уменьшаем элементы
	for _, obj in ipairs(
		Bar:GetDescendants()
	) do

		if obj:IsA("TextButton") then

			obj.TextSize = 11

		elseif obj:IsA("TextBox") then

			obj.TextSize = 11
		end
	end
end

--========================================================
-- KEYBINDS
--========================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		-- F2
		if input.KeyCode
			== Enum.KeyCode.F2
		then

			Bar.Visible =
				not Bar.Visible
		end

		-- F3
		if input.KeyCode
			== Enum.KeyCode.F3
		then

			playerESP =
				not playerESP

			UpdatePlayerESP()

			if currentMode
				== "Players"
			then

				SetButtonState(
					ESPBtn,
					playerESP
				)
			end

			Notify(
				"ESP Players: "
				.. (
					playerESP
					and "ON"
					or "OFF"
				)
			)
		end

		-- F4
		if input.KeyCode
			== Enum.KeyCode.F4
		then

			SetNoclip(
				not noclipEnabled
			)
		end

		-- F5
		if input.KeyCode
			== Enum.KeyCode.F5
		then

			flyEnabled =
				not flyEnabled

			SetButtonState(
				FlyBtn,
				flyEnabled
			)

			if flyEnabled then

				StartFly()

			else

				StopFly()
			end

			UpdateMobileControls()

			Notify(
				"Fly: "
				.. (
					flyEnabled
					and "ON"
					or "OFF"
				)
			)
		end
	end
)

--========================================================
-- TOUCH / MOBILE TAB SUPPORT
--========================================================

for _, data in ipairs(
	tabButtons
) do

	data.btn.Activated:Connect(
		function()

			currentMode =
				data.mode

			UpdateVisibility()
		end
	)
end

--========================================================
-- INITIAL VALUES
--========================================================

WalkBox.Text =
	tostring(
		DEFAULT_WALKSPEED
	)

JumpBox.Text =
	tostring(
		DEFAULT_JUMPPOWER
	)

UpdateMobileControls()

UpdateVisibility()

--========================================================
-- MOBILE WELCOME
--========================================================

if UserInputService.TouchEnabled then

	Notify(
		"✓ Mobile Dev Admin loaded"
	)

else

	Notify(
		"✓ Dev Admin HUD v2 loaded"
	)
end

--========================================================
-- DONE
--========================================================
