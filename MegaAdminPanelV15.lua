--[[
============================================================
    ULTIMATE LOCAL PANEL v15.0
    LOCAL-ONLY ADMIN / TEST PANEL
============================================================

    LOCAL FEATURES:
    • Fly
    • Speed
    • Jump
    • Gravity
    • Noclip
    • Local Invisibility
    • Player ESP
    • Player Info
    • Spectate
    • Camera Aim Assist
    • FOV
    • Player Teleport
    • World/Zone Teleport
    • Named Checkpoints
    • Search Players
    • Search World Objects
    • Mobile-friendly UI

============================================================
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// CLEAN OLD PANEL
local old = PlayerGui:FindFirstChild("MegaAdminPanelV15")
if old then
    old:Destroy()
end

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
    WalkSpeed = 50,
    JumpPower = 100,
    Gravity = 196.2,

    FlySpeed = 70,

    AimFOV = 180,
    AimSmoothness = 0.18,
    AimMaxDistance = 1000,

    ESPColor = Color3.fromRGB(0,255,140),
    SelectedColor = Color3.fromRGB(255,210,70),
}

--============================================================
-- STATE
--============================================================

local State = {
    Fly = false,
    Noclip = false,
    Speed = false,
    SuperJump = false,
    Invisibility = false,

    ESP = false,
    Aim = false,
    AimFOV = true,

    Spectating = false,
    SpectateTarget = nil,

    AimPart = "Head",
}

local Connections = {}

local Checkpoints = {}
local ESPObjects = {}

local OriginalTransparency = {}
local OriginalGravity = workspace.Gravity

--============================================================
-- HELPERS
--============================================================

local function getCharacter(player)
    player = player or LocalPlayer

    return player.Character
end

local function getHumanoid(player)
    local char = getCharacter(player)

    if not char then
        return nil
    end

    return char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(player)
    local char = getCharacter(player)

    if not char then
        return nil
    end

    return char:FindFirstChild("HumanoidRootPart")
end

local function tween(obj, props, time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function disconnect(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local function notify(text)
    if Toast then
        Toast.Text = text
        Toast.Visible = true

        task.delay(2.2, function()
            if Toast then
                Toast.Visible = false
            end
        end)
    end
end

--============================================================
-- GUI ROOT
--============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaAdminPanelV15"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--============================================================
-- FLOATING BUTTON
--============================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(58,58)
OpenButton.Position = UDim2.new(0,18,0.45,0)
OpenButton.BackgroundColor3 = Color3.fromRGB(18,21,30)
OpenButton.Text = "⚡"
OpenButton.TextColor3 = Color3.fromRGB(0,255,150)
OpenButton.TextSize = 25
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui

Instance.new("UICorner",OpenButton).CornerRadius = UDim.new(1,0)

local openStroke = Instance.new("UIStroke",OpenButton)
openStroke.Color = Color3.fromRGB(0,255,150)
openStroke.Thickness = 2

--============================================================
-- MAIN WINDOW
--============================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.92,0,0.76,0)
Main.Position = UDim2.new(0.5,0,0.5,0)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(13,16,23)
Main.Visible = false
Main.Active = true
Main.Parent = ScreenGui

local mainConstraint = Instance.new("UISizeConstraint",Main)
mainConstraint.MinSize = Vector2.new(320,420)
mainConstraint.MaxSize = Vector2.new(720,600)

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,16)

local mainStroke = Instance.new("UIStroke",Main)
mainStroke.Color = Color3.fromRGB(38,50,65)
mainStroke.Thickness = 1.5

--============================================================
-- TOP BAR
--============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,54)
Header.BackgroundColor3 = Color3.fromRGB(20,24,34)
Header.Parent = Main

Instance.new("UICorner",Header).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-110,1,0)
Title.Position = UDim2.fromOffset(18,0)
Title.BackgroundTransparency = 1
Title.Text = "MEGA PANEL  •  v15"
Title.TextColor3 = Color3.fromRGB(240,245,250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(100,54)
Status.Position = UDim2.new(1,-150,0,0)
Status.BackgroundTransparency = 1
Status.Text = "● LOCAL"
Status.TextColor3 = Color3.fromRGB(0,255,150)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 10
Status.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(36,36)
Close.Position = UDim2.new(1,-46,0,9)
Close.BackgroundColor3 = Color3.fromRGB(55,29,35)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255,100,110)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 22
Close.AutoButtonColor = false
Close.Parent = Header

Instance.new("UICorner",Close).CornerRadius = UDim.new(0,9)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--============================================================
-- SIDEBAR
--============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,112,1,-70)
Sidebar.Position = UDim2.fromOffset(10,60)
Sidebar.BackgroundColor3 = Color3.fromRGB(17,20,29)
Sidebar.Parent = Main

Instance.new("UICorner",Sidebar).CornerRadius = UDim.new(0,12)

local SideList = Instance.new("UIListLayout",Sidebar)
SideList.Padding = UDim.new(0,6)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.SortOrder = Enum.SortOrder.LayoutOrder

local sidePad = Instance.new("UIPadding",Sidebar)
sidePad.PaddingTop = UDim.new(0,8)
sidePad.PaddingLeft = UDim.new(0,7)
sidePad.PaddingRight = UDim.new(0,7)

--============================================================
-- CONTENT
--============================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-132,1,-70)
Content.Position = UDim2.new(0,122,0,60)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(70,80,100)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content

    local padding = Instance.new("UIPadding",page)
    padding.PaddingLeft = UDim.new(0,4)
    padding.PaddingRight = UDim.new(0,4)
    padding.PaddingTop = UDim.new(0,4)
    padding.PaddingBottom = UDim.new(0,8)

    local list = Instance.new("UIListLayout",page)
    list.Padding = UDim.new(0,8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    Pages[name] = page

    return page
end

local PageHome = createPage("Home")
local PagePlayers = createPage("Players")
local PageVisual = createPage("Visual")
local PageTeleport = createPage("Teleport")
local PageCheckpoints = createPage("Checkpoints")
local PageSettings = createPage("Settings")

PageHome.Visible = true

--============================================================
-- SIDEBAR BUTTON
--============================================================

local SideButtons = {}

local function createSideButton(text,pageName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,45)
    button.BackgroundColor3 = Color3.fromRGB(24,28,39)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(170,180,195)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.AutoButtonColor = false
    button.Parent = Sidebar

    Instance.new("UICorner",button).CornerRadius = UDim.new(0,9)

    SideButtons[pageName] = button

    button.MouseButton1Click:Connect(function()

        for name,page in pairs(Pages) do
            page.Visible = false
        end

        Pages[pageName].Visible = true

        for _,b in pairs(SideButtons) do
            b.BackgroundColor3 = Color3.fromRGB(24,28,39)
            b.TextColor3 = Color3.fromRGB(170,180,195)
        end

        button.BackgroundColor3 = Color3.fromRGB(0,155,95)
        button.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    return button
end

createSideButton("⚙  HOME","Home")
createSideButton("👥  PLAYERS","Players")
createSideButton("👁  VISUAL","Visual")
createSideButton("📍  TELEPORT","Teleport")
createSideButton("📌  POINTS","Checkpoints")
createSideButton("⚙  SETTINGS","Settings")

SideButtons.Home.BackgroundColor3 = Color3.fromRGB(0,155,95)
SideButtons.Home.TextColor3 = Color3.fromRGB(255,255,255)

--============================================================
-- TOAST
--============================================================

Toast = Instance.new("TextLabel")
Toast.Size = UDim2.fromOffset(230,38)
Toast.Position = UDim2.new(0.5,-115,1,-48)
Toast.BackgroundColor3 = Color3.fromRGB(22,27,36)
Toast.TextColor3 = Color3.fromRGB(240,245,250)
Toast.Font = Enum.Font.GothamBold
Toast.TextSize = 10
Toast.Visible = false
Toast.ZIndex = 20
Toast.Parent = Main

Instance.new("UICorner",Toast).CornerRadius = UDim.new(0,9)

--============================================================
-- UI COMPONENTS
--============================================================

local function createSection(parent,title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,28)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(0,255,150)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

local function createButton(parent,text,callback,color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,42)
    button.BackgroundColor3 = color or Color3.fromRGB(25,30,42)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235,240,245)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.AutoButtonColor = false
    button.Parent = parent

    Instance.new("UICorner",button).CornerRadius = UDim.new(0,9)

    button.MouseEnter:Connect(function()
        tween(button,{
            BackgroundColor3 = Color3.fromRGB(35,42,56)
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button,{
            BackgroundColor3 = color or Color3.fromRGB(25,30,42)
        })
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

local function createToggle(parent,text,default,callback)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,44)
    holder.BackgroundColor3 = Color3.fromRGB(23,28,39)
    holder.Parent = parent

    Instance.new("UICorner",holder).CornerRadius = UDim.new(0,9)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-70,1,0)
    label.Position = UDim2.fromOffset(12,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235,240,245)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(42,22)
    toggle.Position = UDim2.new(1,-54,0.5,-11)
    toggle.BackgroundColor3 = default
        and Color3.fromRGB(0,190,110)
        or Color3.fromRGB(55,62,76)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = holder

    Instance.new("UICorner",toggle).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16,16)
    knob.Position = default
        and UDim2.new(1,-19,0.5,-8)
        or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = toggle

    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local state = default

    local function setState(newState)
        state = newState

        if state then
            tween(toggle,{
                BackgroundColor3 = Color3.fromRGB(0,190,110)
            })

            tween(knob,{
                Position = UDim2.new(1,-19,0.5,-8)
            })
        else
            tween(toggle,{
                BackgroundColor3 = Color3.fromRGB(55,62,76)
            })

            tween(knob,{
                Position = UDim2.new(0,3,0.5,-8)
            })
        end

        callback(state)
    end

    toggle.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return holder,setState
end

--============================================================
-- HOME PAGE
--============================================================

createSection(PageHome,"MOVEMENT")

createToggle(PageHome,"✈️  Free Fly",false,function(state)

    State.Fly = state

    local hum = getHumanoid()
    local root = getRoot()

    if not hum or not root then
        return
    end

    if state then

        hum.PlatformStand = true

        disconnect("Fly")

        Connections.Fly = RunService.RenderStepped:Connect(function()

            if not State.Fly then
                return
            end

            if not root.Parent then
                return
            end

            local direction = hum.MoveDirection

            if direction.Magnitude > 0 then
                root.AssemblyLinearVelocity =
                    direction.Unit * CONFIG.FlySpeed
            else
                root.AssemblyLinearVelocity = Vector3.zero
            end

            root.CFrame = CFrame.lookAt(
                root.Position,
                root.Position + Camera.CFrame.LookVector
            )

        end)

    else

        disconnect("Fly")

        if root then
            root.AssemblyLinearVelocity = Vector3.zero
        end

        hum.PlatformStand = false
    end
end)

createToggle(PageHome,"⚡  Speed x3",false,function(state)

    State.Speed = state

    local hum = getHumanoid()

    if hum then
        hum.WalkSpeed = state and CONFIG.WalkSpeed or 16
    end
end)

createToggle(PageHome,"🦘  Super Jump",false,function(state)

    State.SuperJump = state

    local hum = getHumanoid()

    if hum then
        hum.JumpPower = state and CONFIG.JumpPower or 50
    end
end)

createToggle(PageHome,"👻  Local Noclip",false,function(state)

    State.Noclip = state

    disconnect("Noclip")

    if state then

        Connections.Noclip = RunService.Stepped:Connect(function()

            local char = getCharacter()

            if not char then
                return
            end

            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = false
                end
            end

        end)

    end
end)

createSection(PageHome,"LOCAL UTILITIES")

createButton(PageHome,"🔄  Reset Local Movement",function()

    local hum = getHumanoid()

    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    workspace.Gravity = OriginalGravity

    State.Speed = false
    State.SuperJump = false

    notify("Movement reset")
end)

--============================================================
-- INVISIBILITY
--============================================================

local function setInvisibility(state)

    local char = getCharacter()

    if not char then
        return
    end

    for _,obj in ipairs(char:GetDescendants()) do

        if obj:IsA("BasePart") then

            if state then

                if OriginalTransparency[obj] == nil then
                    OriginalTransparency[obj] = obj.Transparency
                end

                obj.Transparency = 1

            else

                if OriginalTransparency[obj] ~= nil then
                    obj.Transparency = OriginalTransparency[obj]
                end

            end

        elseif obj:IsA("Decal") then

            if state then

                if OriginalTransparency[obj] == nil then
                    OriginalTransparency[obj] = obj.Transparency
                end

                obj.Transparency = 1

            else

                if OriginalTransparency[obj] ~= nil then
                    obj.Transparency[obj] = OriginalTransparency[obj]
                end

            end
        end
    end
end

--============================================================
-- ESP
--============================================================

local function removeESP(player)

    local data = ESPObjects[player]

    if data then

        for _,obj in pairs(data) do
            if typeof(obj) == "Instance" and obj.Parent then
                obj:Destroy()
            end
        end

        ESPObjects[player] = nil
    end
end

local function createESP(player)

    if player == LocalPlayer then
        return
    end

    removeESP(player)

    local char = player.Character

    if not char then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MegaESP"
    highlight.Adornee = char
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = CONFIG.ESPColor
    highlight.FillTransparency = 0.72
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.OutlineTransparency = 0
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MegaESPInfo"
    billboard.Adornee = char:FindFirstChild("Head")
    billboard.Size = UDim2.fromOffset(180,55)
    billboard.StudsOffset = Vector3.new(0,3.2,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.TextStrokeTransparency = 0.5
    text.Font = Enum.Font.GothamBold
    text.TextSize = 10
    text.Parent = billboard

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Text = text
    }

    task.spawn(function()

        while State.ESP
            and player.Parent
            and ESPObjects[player] do

            local root = getRoot(player)
            local myRoot = getRoot(LocalPlayer)
            local hum = getHumanoid(player)

            local distance = 0

            if root and myRoot then
                distance = (root.Position - myRoot.Position).Magnitude
            end

            local hp = hum and math.floor(hum.Health) or 0

            text.Text =
                player.DisplayName ..
                "\n@" .. player.Name ..
                "  •  " .. math.floor(distance) .. "m" ..
                "\nHP: " .. hp

            task.wait(0.2)
        end
    end)
end

local function refreshESP()

    for player in pairs(ESPObjects) do
        removeESP(player)
    end

    if not State.ESP then
        return
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
end

--============================================================
-- VISUAL PAGE
--============================================================

createSection(PageVisual,"PLAYER VISUALS")

createToggle(PageVisual,"👁  Player ESP",false,function(state)

    State.ESP = state

    refreshESP()

    notify(state and "ESP enabled" or "ESP disabled")
end)

createToggle(PageVisual,"👻  Local Invisibility",false,function(state)

    State.Invisibility = state

    setInvisibility(state)
end)

createToggle(PageVisual,"⭕  Aim FOV",true,function(state)

    State.AimFOV = state
end)

createToggle(PageVisual,"🎯  Camera Aim Assist",false,function(state)

    State.Aim = state

    disconnect("Aim")

    if state then

        Connections.Aim = RunService.RenderStepped:Connect(function()

            if not State.Aim then
                return
            end

            local target = nil
            local closest = CONFIG.AimFOV

            local center = Vector2.new(
                Camera.ViewportSize.X/2,
                Camera.ViewportSize.Y/2
            )

            for _,player in ipairs(Players:GetPlayers()) do

                if player ~= LocalPlayer then

                    local char = player.Character
                    local hum = getHumanoid(player)
                    local part = char and char:FindFirstChild(State.AimPart)

                    if part and hum and hum.Health > 0 then

                        local screen, visible =
                            Camera:WorldToViewportPoint(part.Position)

                        if visible then

                            local distance =
                                (Vector2.new(screen.X,screen.Y)-center).Magnitude

                            local worldDistance =
                                (part.Position-Camera.CFrame.Position).Magnitude

                            if distance < closest
                                and worldDistance <= CONFIG.AimMaxDistance then

                                closest = distance
                                target = part
                            end
                        end
                    end
                end
            end

            if target then

                local cameraPosition = Camera.CFrame.Position

                local desired =
                    CFrame.lookAt(
                        cameraPosition,
                        target.Position
                    )

                Camera.CFrame =
                    Camera.CFrame:Lerp(
                        desired,
                        CONFIG.AimSmoothness
                    )
            end

        end)

    end
end)

createButton(PageVisual,"🔄  Refresh ESP",function()

    refreshESP()
    notify("ESP refreshed")

end)

--============================================================
-- PLAYER SEARCH
--============================================================

createSection(PagePlayers,"PLAYER LIST")

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1,0,0,40)
SearchBox.BackgroundColor3 = Color3.fromRGB(22,27,38)
SearchBox.PlaceholderText = "🔎  Search username / display name..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(110,120,135)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(240,245,250)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 10
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = PagePlayers

Instance.new("UICorner",SearchBox).CornerRadius = UDim.new(0,9)

local PlayerListContainer = Instance.new("Frame")
PlayerListContainer.Size = UDim2.new(1,0,0,0)
PlayerListContainer.AutomaticSize = Enum.AutomaticSize.Y
PlayerListContainer.BackgroundTransparency = 1
PlayerListContainer.Parent = PagePlayers

local playerList = Instance.new("UIListLayout",PlayerListContainer)
playerList.Padding = UDim.new(0,7)

local function createPlayerCard(player)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,76)
    card.BackgroundColor3 = Color3.fromRGB(22,27,38)
    card.Parent = PlayerListContainer

    Instance.new("UICorner",card).CornerRadius = UDim.new(0,10)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1,-180,0,25)
    name.Position = UDim2.fromOffset(12,8)
    name.BackgroundTransparency = 1
    name.Text = player.DisplayName
    name.TextColor3 = Color3.fromRGB(245,245,250)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(1,-180,0,20)
    username.Position = UDim2.fromOffset(12,31)
    username.BackgroundTransparency = 1
    username.Text = "@" .. player.Name
    username.TextColor3 = Color3.fromRGB(130,145,165)
    username.Font = Enum.Font.Gotham
    username.TextSize = 9
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = card

    local tp = Instance.new("TextButton")
    tp.Size = UDim2.fromOffset(48,28)
    tp.Position = UDim2.new(1,-165,0.5,-14)
    tp.BackgroundColor3 = Color3.fromRGB(35,90,140)
    tp.Text = "TP"
    tp.TextColor3 = Color3.fromRGB(255,255,255)
    tp.Font = Enum.Font.GothamBold
    tp.TextSize = 9
    tp.Parent = card

    Instance.new("UICorner",tp).CornerRadius = UDim.new(0,7)

    tp.MouseButton1Click:Connect(function()

        local targetRoot = getRoot(player)
        local myRoot = getRoot()

        if targetRoot and myRoot then
            myRoot.CFrame =
                targetRoot.CFrame *
                CFrame.new(0,0,4)

            notify("Teleported to " .. player.DisplayName)
        end
    end)

    local spec = Instance.new("TextButton")
    spec.Size = UDim2.fromOffset(48,28)
    spec.Position = UDim2.new(1,-110,0.5,-14)
    spec.BackgroundColor3 = Color3.fromRGB(100,65,145)
    spec.Text = "SPEC"
    spec.TextColor3 = Color3.fromRGB(255,255,255)
    spec.Font = Enum.Font.GothamBold
    spec.TextSize = 8
    spec.Parent = card

    Instance.new("UICorner",spec).CornerRadius = UDim.new(0,7)

    spec.MouseButton1Click:Connect(function()

        local hum = getHumanoid(player)

        if hum then

            Camera.CameraSubject = hum

            State.Spectating = true
            State.SpectateTarget = player

            notify("Spectating " .. player.DisplayName)
        end
    end)

    local aim = Instance.new("TextButton")
    aim.Size = UDim2.fromOffset(48,28)
    aim.Position = UDim2.new(1,-55,0.5,-14)
    aim.BackgroundColor3 = Color3.fromRGB(130,90,35)
    aim.Text = "AIM"
    aim.TextColor3 = Color3.fromRGB(255,255,255)
    aim.Font = Enum.Font.GothamBold
    aim.TextSize = 8
    aim.Parent = card

    Instance.new("UICorner",aim).CornerRadius = UDim.new(0,7)

    aim.MouseButton1Click:Connect(function()

        State.Aim = true
        notify("Aim enabled")

        local hum = getHumanoid(player)

        if hum then
            Camera.CameraSubject = hum
        end
    end)

    return card
end

local function rebuildPlayerList()

    for _,child in ipairs(PlayerListContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local query = SearchBox.Text:lower()

    for _,player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local matches =
                query == "" or
                player.Name:lower():find(query,1,true) or
                player.DisplayName:lower():find(query,1,true)

            if matches then
                createPlayerCard(player)
            end
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(rebuildPlayerList)

Players.PlayerAdded:Connect(function(player)

    player.CharacterAdded:Connect(function()
        task.wait(1)

        if State.ESP then
            createESP(player)
        end
    end)

    task.wait(0.2)
    rebuildPlayerList()
end)

Players.PlayerRemoving:Connect(function(player)

    removeESP(player)

    if State.SpectateTarget == player then
        State.SpectateTarget = nil
        State.Spectating = false

        local hum = getHumanoid()

        if hum then
            Camera.CameraSubject = hum
        end
    end

    rebuildPlayerList()
end)

rebuildPlayerList()

--============================================================
-- SPECTATE CONTROLS
--============================================================

createSection(PagePlayers,"SPECTATE")

local SpectateLabel = Instance.new("TextLabel")
SpectateLabel.Size = UDim2.new(1,0,0,40)
SpectateLabel.BackgroundColor3 = Color3.fromRGB(22,27,38)
SpectateLabel.Text = "No player selected"
SpectateLabel.TextColor3 = Color3.fromRGB(200,210,220)
SpectateLabel.Font = Enum.Font.GothamBold
SpectateLabel.TextSize = 10
SpectateLabel.Parent = PagePlayers

Instance.new("UICorner",SpectateLabel).CornerRadius = UDim.new(0,9)

local function getOtherPlayers()

    local result = {}

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(result,player)
        end
    end

    return result
end

local function spectatePlayer(player)

    local hum = getHumanoid(player)

    if hum then

        Camera.CameraSubject = hum

        State.Spectating = true
        State.SpectateTarget = player

        SpectateLabel.Text =
            "🎥  " .. player.DisplayName ..
            "  •  @" .. player.Name
    end
end

createButton(PagePlayers,"◀  Previous Player",function()

    local list = getOtherPlayers()

    if #list == 0 then
        return
    end

    local currentIndex = 1

    for i,p in ipairs(list) do
        if p == State.SpectateTarget then
            currentIndex = i
            break
        end
    end

    currentIndex -= 1

    if currentIndex < 1 then
        currentIndex = #list
    end

    spectatePlayer(list[currentIndex])

end)

createButton(PagePlayers,"Next Player  ▶",function()

    local list = getOtherPlayers()

    if #list == 0 then
        return
    end

    local currentIndex = 1

    for i,p in ipairs(list) do
        if p == State.SpectateTarget then
            currentIndex = i
            break
        end
    end

    currentIndex += 1

    if currentIndex > #list then
        currentIndex = 1
    end

    spectatePlayer(list[currentIndex])

end)

createButton(PagePlayers,"⏹  Stop Spectate",function()

    State.Spectating = false
    State.SpectateTarget = nil

    local hum = getHumanoid()

    if hum then
        Camera.CameraSubject = hum
    end

    SpectateLabel.Text = "No player selected"

end)

--============================================================
-- TELEPORT PAGE
--============================================================

createSection(PageTeleport,"PLAYER TELEPORT")

local TPPlayerSearch = Instance.new("TextBox")
TPPlayerSearch.Size = UDim2.new(1,0,0,40)
TPPlayerSearch.BackgroundColor3 = Color3.fromRGB(22,27,38)
TPPlayerSearch.PlaceholderText = "🔎  Find player..."
TPPlayerSearch.PlaceholderColor3 = Color3.fromRGB(110,120,135)
TPPlayerSearch.TextColor3 = Color3.fromRGB(240,245,250)
TPPlayerSearch.Text = ""
TPPlayerSearch.Font = Enum.Font.Gotham
TPPlayerSearch.TextSize = 10
TPPlayerSearch.ClearTextOnFocus = false
TPPlayerSearch.Parent = PageTeleport

Instance.new("UICorner",TPPlayerSearch).CornerRadius = UDim.new(0,9)

local function teleportToPlayer(player)

    local target = getRoot(player)
    local me = getRoot()

    if target and me then

        me.CFrame =
            target.CFrame *
            CFrame.new(0,0,4)

        notify("TP → " .. player.DisplayName)
    end
end

local function createTPPlayerButton(player)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1,0,0,45)

    button.BackgroundColor3 =
        Color3.fromRGB(25,31,43)

    button.Text =
        "👤  " ..
        player.DisplayName ..
        "   @" ..
        player.Name

    button.TextColor3 =
        Color3.fromRGB(235,240,245)

    button.Font =
        Enum.Font.GothamBold

    button.TextSize = 9
    button.TextXAlignment = Enum.TextXAlignment.Left

    button.Parent = PageTeleport

    Instance.new("UICorner",button).CornerRadius = UDim.new(0,9)

    button.MouseButton1Click:Connect(function()
        teleportToPlayer(player)
    end)
end

local function rebuildTPPlayers()

    for _,child in ipairs(PageTeleport:GetChildren()) do

        if child:GetAttribute("TPPlayerButton") then
            child:Destroy()
        end
    end

    local query = TPPlayerSearch.Text:lower()

    for _,player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local matches =
                query == "" or
                player.Name:lower():find(query,1,true) or
                player.DisplayName:lower():find(query,1,true)

            if matches then

                local button = Instance.new("TextButton")

                button:SetAttribute("TPPlayerButton",true)

                button.Size = UDim2.new(1,0,0,45)
                button.BackgroundColor3 = Color3.fromRGB(25,31,43)
                button.Text =
                    "👤  " ..
                    player.DisplayName ..
                    "   @" ..
                    player.Name
                button.TextColor3 = Color3.fromRGB(235,240,245)
                button.Font = Enum.Font.GothamBold
                button.TextSize = 9
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = PageTeleport

                Instance.new("UICorner",button).CornerRadius = UDim.new(0,9)

                button.MouseButton1Click:Connect(function()
                    teleportToPlayer(player)
                end)
            end
        end
    end
end

TPPlayerSearch:GetPropertyChangedSignal("Text"):Connect(rebuildTPPlayers)

--============================================================
-- WORLD TELEPORT
--============================================================

createSection(PageTeleport,"WORLD / ZONE TELEPORT")

local WorldSearch = Instance.new("TextBox")
WorldSearch.Size = UDim2.new(1,0,0,40)
WorldSearch.BackgroundColor3 = Color3.fromRGB(22,27,38)
WorldSearch.PlaceholderText = "🔎  Search world / zone / portal..."
WorldSearch.PlaceholderColor3 = Color3.fromRGB(110,120,135)
WorldSearch.TextColor3 = Color3.fromRGB(240,245,250)
WorldSearch.Text = ""
WorldSearch.Font = Enum.Font.Gotham
WorldSearch.TextSize = 10
WorldSearch.Parent = PageTeleport

Instance.new("UICorner",WorldSearch).CornerRadius = UDim.new(0,9)

local WorldContainer = Instance.new("Frame")
WorldContainer.Size = UDim2.new(1,0,0,0)
WorldContainer.AutomaticSize = Enum.AutomaticSize.Y
WorldContainer.BackgroundTransparency = 1
WorldContainer.Parent = PageTeleport

local worldLayout = Instance.new("UIListLayout",WorldContainer)
worldLayout.Padding = UDim.new(0,6)

local worldObjects = {}

local function clearWorldButtons()

    for _,button in ipairs(worldObjects) do

        if button and button.Parent then
            button:Destroy()
        end

    end

    worldObjects = {}
end

local function scanWorlds()

    clearWorldButtons()

    local query = WorldSearch.Text:lower()

    local found = {}

    for _,obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("BasePart") or obj:IsA("Model") then

            local name = obj.Name
            local lower = name:lower()

            local interesting =
                lower:find("world") or
                lower:find("zone") or
                lower:find("portal") or
                lower:find("teleport") or
                lower:find("stage") or
                lower:find("area") or
                lower:find("checkpoint")

            if interesting then

                if query == "" or lower:find(query,1,true) then

                    if not found[name] then

                        found[name] = true

                        local cf

                        if obj:IsA("BasePart") then
                            cf = obj.CFrame
                        else
                            cf = obj:GetPivot()
                        end

                        local button = createButton(
                            WorldContainer,
                            "🚀  " .. name,
                            function()

                                local root = getRoot()

                                if root then
                                    root.CFrame =
                                        cf *
                                        CFrame.new(0,4,0)

                                    notify("TP → " .. name)
                                end

                            end,
                            Color3.fromRGB(28,54,75)
                        )

                        table.insert(worldObjects,button)
                    end
                end
            end
        end
    end
end

WorldSearch:GetPropertyChangedSignal("Text"):Connect(scanWorlds)

createButton(PageTeleport,"🔄  Refresh World List",function()
    scanWorlds()
end)

rebuildTPPlayers()
scanWorlds()
--============================================================
-- CHECKPOINTS
--============================================================

createSection(PageCheckpoints,"SAVED CHECKPOINTS")

local CheckpointName = Instance.new("TextBox")
CheckpointName.Size = UDim2.new(1,0,0,40)
CheckpointName.BackgroundColor3 = Color3.fromRGB(22,27,38)
CheckpointName.PlaceholderText = "📌  Checkpoint name..."
CheckpointName.PlaceholderColor3 = Color3.fromRGB(110,120,135)
CheckpointName.TextColor3 = Color3.fromRGB(240,245,250)
CheckpointName.Text = ""
CheckpointName.Font = Enum.Font.Gotham
CheckpointName.TextSize = 10
CheckpointName.ClearTextOnFocus = false
CheckpointName.Parent = PageCheckpoints

Instance.new("UICorner",CheckpointName).CornerRadius = UDim.new(0,9)

local CheckpointContainer = Instance.new("Frame")
CheckpointContainer.Size = UDim2.new(1,0,0,0)
CheckpointContainer.AutomaticSize = Enum.AutomaticSize.Y
CheckpointContainer.BackgroundTransparency = 1
CheckpointContainer.Parent = PageCheckpoints

local checkpointLayout =
    Instance.new("UIListLayout",CheckpointContainer)

checkpointLayout.Padding = UDim.new(0,7)

local function rebuildCheckpoints()

    for _,child in ipairs(CheckpointContainer:GetChildren()) do

        if child:IsA("Frame") then
            child:Destroy()
        end

    end

    for name,data in pairs(Checkpoints) do

        local card = Instance.new("Frame")

        card.Size = UDim2.new(1,0,0,54)

        card.BackgroundColor3 =
            Color3.fromRGB(23,29,40)

        card.Parent = CheckpointContainer

        Instance.new("UICorner",card).CornerRadius =
            UDim.new(0,9)

        local label = Instance.new("TextLabel")

        label.Size =
            UDim2.new(1,-180,1,0)

        label.Position =
            UDim2.fromOffset(12,0)

        label.BackgroundTransparency = 1

        label.Text =
            "📍  " .. name

        label.TextColor3 =
            Color3.fromRGB(240,245,250)

        label.Font =
            Enum.Font.GothamBold

        label.TextSize = 10

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.Parent = card

        local tp = Instance.new("TextButton")

        tp.Size =
            UDim2.fromOffset(48,30)

        tp.Position =
            UDim2.new(1,-105,0.5,-15)

        tp.BackgroundColor3 =
            Color3.fromRGB(0,145,100)

        tp.Text = "TP"

        tp.TextColor3 =
            Color3.fromRGB(255,255,255)

        tp.Font =
            Enum.Font.GothamBold

        tp.TextSize = 9

        tp.Parent = card

        Instance.new("UICorner",tp).CornerRadius =
            UDim.new(0,7)

        tp.MouseButton1Click:Connect(function()

            local root = getRoot()

            if root then
                root.CFrame =
                    data.CFrame *
                    CFrame.new(0,3,0)

                notify("TP → " .. name)
            end

        end)

        local del = Instance.new("TextButton")

        del.Size =
            UDim2.fromOffset(40,30)

        del.Position =
            UDim2.new(1,-52,0.5,-15)

        del.BackgroundColor3 =
            Color3.fromRGB(75,35,42)

        del.Text = "×"

        del.TextColor3 =
            Color3.fromRGB(255,110,120)

        del.Font =
            Enum.Font.GothamBold

        del.TextSize = 16

        del.Parent = card

        Instance.new("UICorner",del).CornerRadius =
            UDim.new(0,7)

        del.MouseButton1Click:Connect(function()

            Checkpoints[name] = nil

            rebuildCheckpoints()

            notify("Checkpoint deleted")
        end)
    end
end

createButton(
    PageCheckpoints,
    "📌  SAVE CURRENT POSITION",
    function()

        local root = getRoot()

        if not root then
            notify("Character not found")
            return
        end

        local name =
            CheckpointName.Text ~= "" and
            CheckpointName.Text or
            ("Point " .. tostring(#Checkpoints + 1))

        Checkpoints[name] = {
            CFrame = root.CFrame
        }

        CheckpointName.Text = ""

        rebuildCheckpoints()

        notify("Saved: " .. name)
    end,
    Color3.fromRGB(0,130,90)
)

createButton(
    PageCheckpoints,
    "🗑  CLEAR ALL CHECKPOINTS",
    function()

        Checkpoints = {}

        rebuildCheckpoints()

        notify("All checkpoints cleared")
    end,
    Color3.fromRGB(70,35,42)
)

--============================================================
-- SETTINGS
--============================================================

createSection(PageSettings,"MOVEMENT SETTINGS")

local function createNumberBox(parent,placeholder,value,callback)

    local box = Instance.new("TextBox")

    box.Size = UDim2.new(1,0,0,40)

    box.BackgroundColor3 =
        Color3.fromRGB(22,27,38)

    box.PlaceholderText =
        placeholder

    box.PlaceholderColor3 =
        Color3.fromRGB(110,120,135)

    box.Text =
        tostring(value)

    box.TextColor3 =
        Color3.fromRGB(240,245,250)

    box.Font =
        Enum.Font.Gotham

    box.TextSize = 10

    box.ClearTextOnFocus = false

    box.Parent = parent

    Instance.new("UICorner",box).CornerRadius =
        UDim.new(0,9)

    box.FocusLost:Connect(function()

        local number =
            tonumber(box.Text)

        if number then
            callback(number)
        end

    end)

    return box
end

createNumberBox(
    PageSettings,
    "WalkSpeed",
    CONFIG.WalkSpeed,
    function(value)

        CONFIG.WalkSpeed = math.clamp(value,1,300)

        if State.Speed then

            local hum = getHumanoid()

            if hum then
                hum.WalkSpeed = CONFIG.WalkSpeed
            end

        end
    end
)

createNumberBox(
    PageSettings,
    "JumpPower",
    CONFIG.JumpPower,
    function(value)

        CONFIG.JumpPower =
            math.clamp(value,1,300)

        if State.SuperJump then

            local hum = getHumanoid()

            if hum then
                hum.JumpPower =
                    CONFIG.JumpPower
            end

        end
    end
)

createNumberBox(
    PageSettings,
    "Fly Speed",
    CONFIG.FlySpeed,
    function(value)

        CONFIG.FlySpeed =
            math.clamp(value,1,300)
    end
)

createNumberBox(
    PageSettings,
    "Aim FOV",
    CONFIG.AimFOV,
    function(value)

        CONFIG.AimFOV =
            math.clamp(value,20,1000)
    end
)

createNumberBox(
    PageSettings,
    "Aim Smoothness",
    CONFIG.AimSmoothness,
    function(value)

        CONFIG.AimSmoothness =
            math.clamp(value,0.01,1)
    end
)

createSection(PageSettings,"AIM TARGET")

createButton(PageSettings,"🎯  Target: Head",function()

    State.AimPart = "Head"

    notify("Aim target: Head")
end)

createButton(PageSettings,"🎯  Target: HumanoidRootPart",function()

    State.AimPart = "HumanoidRootPart"

    notify("Aim target: Root")
end)

--============================================================
-- GRAVITY
--============================================================

createSection(PageSettings,"WORLD")

createNumberBox(
    PageSettings,
    "Gravity",
    CONFIG.Gravity,
    function(value)

        CONFIG.Gravity =
            math.clamp(value,0,1000)

        workspace.Gravity =
            CONFIG.Gravity

        notify("Gravity: " .. CONFIG.Gravity)
    end
)

createButton(PageSettings,"🌍  Reset Gravity",function()

    workspace.Gravity =
        OriginalGravity

    CONFIG.Gravity =
        OriginalGravity

    notify("Gravity reset")
end)

--============================================================
-- CHARACTER RESPAWN HANDLER
--============================================================

LocalPlayer.CharacterAdded:Connect(function(char)

    task.wait(1)

    local hum =
        char:FindFirstChildOfClass("Humanoid")

    if hum then

        if State.Speed then
            hum.WalkSpeed =
                CONFIG.WalkSpeed
        end

        if State.SuperJump then
            hum.JumpPower =
                CONFIG.JumpPower
        end
    end

    if State.Invisibility then
        setInvisibility(true)
    end

    if State.Fly then

        State.Fly = false
        disconnect("Fly")

        notify("Fly disabled after respawn")
    end

    if State.Noclip then

        -- connection remains active
        task.wait(0.2)

    end

end)

--============================================================
-- DRAGGING
--============================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false
            end

        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - dragStart

        Main.Position =
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
    end
end)

--============================================================
-- CLEANUP
--============================================================

ScreenGui.Destroying:Connect(function()

    for name in pairs(Connections) do
        disconnect(name)
    end

    for player in pairs(ESPObjects) do
        removeESP(player)
    end

    workspace.Gravity =
        OriginalGravity

    local hum =
        getHumanoid()

    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.PlatformStand = false
    end

end)

--============================================================
-- STARTUP
--============================================================

notify("Mega Panel v15 loaded")