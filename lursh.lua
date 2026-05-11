```lua
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local gui = player:WaitForChild("PlayerGui")

-- GUI
local screen = Instance.new("ScreenGui", gui)
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,260,0,360)
frame.Position = UDim2.new(0.5,-130,0,10)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,8)

-- DRAG
local dragging = false
local dragInput
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,32)
title.BackgroundTransparency = 1
title.Text = "LURSH"
title.TextScaled = true
title.Font = Enum.Font.GothamBold

task.spawn(function()
	local h = 0

	while true do
		h = (h + 0.005) % 1
		title.TextColor3 = Color3.fromHSV(h,1,1)
		RunService.RenderStepped:Wait()
	end
end)

-- TABS
local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1,0,0,25)
tabFrame.Position = UDim2.new(0,0,0,35)
tabFrame.BackgroundTransparency = 1

local function makeTab(text,pos)
	local b = Instance.new("TextButton", tabFrame)
	b.Size = UDim2.new(0.33,0,1,0)
	b.Position = UDim2.new(pos,0,0,0)
	b.Text = text
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)

	local c = Instance.new("UICorner", b)
	c.CornerRadius = UDim.new(0,5)

	return b
end

local mainTab = makeTab("Main",0)
local visualsTab = makeTab("Visuals",0.33)
local bindTab = makeTab("Bind",0.66)

-- PAGES
local function makePage()
	local p = Instance.new("Frame", frame)
	p.Size = UDim2.new(1,0,1,-65)
	p.Position = UDim2.new(0,0,0,65)
	p.BackgroundTransparency = 1
	return p
end

local mainPage = makePage()
local visualsPage = makePage()
visualsPage.Visible = false
local bindPage = makePage()
bindPage.Visible = false

local function hideAll()
	mainPage.Visible = false
	visualsPage.Visible = false
	bindPage.Visible = false
end

mainTab.MouseButton1Click:Connect(function()
	hideAll()
	mainPage.Visible = true
end)

visualsTab.MouseButton1Click:Connect(function()
	hideAll()
	visualsPage.Visible = true
end)

bindTab.MouseButton1Click:Connect(function()
	hideAll()
	bindPage.Visible = true
end)

-- BUTTON
local function btn(text,y,parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,220,0,28)
	b.Position = UDim2.new(0.5,-110,0,y)
	b.BackgroundColor3 = Color3.fromRGB(170,0,0)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.Text = text

	local c = Instance.new("UICorner", b)
	c.CornerRadius = UDim.new(0,6)

	return b
end

-- INPUTS
local speedBox = Instance.new("TextBox", mainPage)
speedBox.Size = UDim2.new(0,100,0,25)
speedBox.Position = UDim2.new(0,20,0,10)
speedBox.PlaceholderText = "Speed"
speedBox.Text = ""

local jumpBox = speedBox:Clone()
jumpBox.Parent = mainPage
jumpBox.Position = UDim2.new(0,140,0,10)
jumpBox.PlaceholderText = "Jump"

-- BUTTONS
local applyBtn = btn("Apply",50,mainPage)
local resetBtn = btn("Reset",90,mainPage)
local flyBtn = btn("Fly: OFF",130,mainPage)
local noclipBtn = btn("Noclip: OFF",170,mainPage)
local infBtn = btn("Infinity Jump: OFF",210,mainPage)
local closeBtn = btn("Close GUI",250,mainPage)

-- STATES
local flying = false
local noclip = false
local infJump = false
local flySpeed = 60

-- APPLY
applyBtn.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = tonumber(speedBox.Text) or 16
		hum.JumpPower = tonumber(jumpBox.Text) or 50
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
end)

infBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	infBtn.Text = infJump and "Infinity Jump: ON" or "Infinity Jump: OFF"
end)

closeBtn.MouseButton1Click:Connect(function()
	screen:Destroy()
end)

-- ESP SETTINGS
local espEnabled = false
local tracersEnabled = false
local rainbowESP = false

local espColor = Color3.fromRGB(255,0,0)

local espBtn = btn("ESP: OFF",20,visualsPage)
local tracerBtn = btn("Tracers: OFF",60,visualsPage)
local rainbowBtn = btn("Rainbow ESP: OFF",100,visualsPage)

local rBox = Instance.new("TextBox", visualsPage)
rBox.Size = UDim2.new(0,60,0,25)
rBox.Position = UDim2.new(0,20,0,150)
rBox.PlaceholderText = "R"

local gBox = rBox:Clone()
gBox.Parent = visualsPage
gBox.Position = UDim2.new(0,100,0,150)
gBox.PlaceholderText = "G"

local bBox = rBox:Clone()
bBox.Parent = visualsPage
bBox.Position = UDim2.new(0,180,0,150)
bBox.PlaceholderText = "B"

local function makeESP(plr)
	if plr == player then return end
	if not plr.Character then return end

	local root = plr.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local old = plr.Character:FindFirstChild("LurshESP")
	if old then old:Destroy() end

	if espEnabled then
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "LurshESP"
		box.Adornee = root
		box.AlwaysOnTop = true
		box.Size = Vector3.new(4,6,2)
		box.Transparency = 0.4
		box.Color3 = espColor
		box.Parent = plr.Character
	end
end

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"

	local r = tonumber(rBox.Text) or 255
	local g = tonumber(gBox.Text) or 0
	local b = tonumber(bBox.Text) or 0

	espColor = Color3.fromRGB(r,g,b)

	for _,plr in pairs(Players:GetPlayers()) do
		makeESP(plr)
	end
end)

tracerBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracerBtn.Text = tracersEnabled and "Tracers: ON" or "Tracers: OFF"
end)

rainbowBtn.MouseButton1Click:Connect(function()
	rainbowESP = not rainbowESP
	rainbowBtn.Text = rainbowESP and "Rainbow ESP: ON" or "Rainbow ESP: OFF"
end)

-- KEYBINDS
local bindFrames = {}
local activeBindChange

local bindList = {
	{"Fly", flyBtn},
	{"Noclip", noclipBtn},
	{"InfinityJump", infBtn}
}

for i,v in pairs(bindList) do
	local name = v[1]

	local txt = Instance.new("TextLabel", bindPage)
	txt.Size = UDim2.new(0,100,0,30)
	txt.Position = UDim2.new(0,20,0,20 + ((i-1)*50))
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextScaled = true
	txt.Text = name

	local box = Instance.new("TextButton", bindPage)
	box.Size = UDim2.new(0,100,0,30)
	box.Position = UDim2.new(0,140,0,20 + ((i-1)*50))
	box.BackgroundColor3 = Color3.fromRGB(25,25,25)
	box.TextColor3 = Color3.new(1,1,1)
	box.Text = "NONE"

	bindFrames[name] = {
		Key = nil,
		Button = box
	}

	box.MouseButton1Click:Connect(function()
		activeBindChange = name
		box.Text = "PRESS KEY"
	end)
end

-- LOOP
RunService.RenderStepped:Connect(function()

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	-- FLY
	if flying and root then

		local move = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			move += Camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.S) then
			move -= Camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.A) then
			move -= Camera.CFrame.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.D) then
			move += Camera.CFrame.RightVector
		end

		if move.Magnitude > 0 then
			root.Velocity = move.Unit * flySpeed
		end
	end

	-- NOCLIP
	if noclip and char then
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	-- INF JUMP
	if infJump and hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	-- RAINBOW ESP
	if rainbowESP then
		local h = tick()%5/5

		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character then
				local esp = plr.Character:FindFirstChild("LurshESP")

				if esp then
					esp.Color3 = Color3.fromHSV(h,1,1)
				end
			end
		end
	end

	-- TRACERS
	if tracersEnabled then

		for _,plr in pairs(Players:GetPlayers()) do

			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

				local rootPart = plr.Character.HumanoidRootPart

				local beam = Instance.new("Part")
				beam.Anchored = true
				beam.CanCollide = false
				beam.Material = Enum.Material.Neon
				beam.Color = espColor

				local from = Camera.CFrame.Position
				local to = rootPart.Position
				local dist = (from - to).Magnitude

				beam.Size = Vector3.new(0.015,0.015,dist)

				beam.CFrame =
					CFrame.new(from,to)
					* CFrame.new(0,0,-dist/2)

				beam.Parent = workspace

				game.Debris:AddItem(beam,0.03)
			end
		end
	end
end)

-- KEYBINDS
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end

	if activeBindChange then
		bindFrames[activeBindChange].Key = input.KeyCode
		bindFrames[activeBindChange].Button.Text = input.KeyCode.Name
		activeBindChange = nil
		return
	end

	for name,data in pairs(bindFrames) do
		if data.Key and input.KeyCode == data.Key then

			if name == "Fly" then
				flying = not flying
				flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"

			elseif name == "Noclip" then
				noclip = not noclip
				noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"

			elseif name == "InfinityJump" then
				infJump = not infJump
				infBtn.Text = infJump and "Infinity Jump: ON" or "Infinity Jump: OFF"
			end
		end
	end
end)

-- PLAYER ADDED
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(1)

		if espEnabled then
			makeESP(plr)
		end
	end)
end)
```
