
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- STATES
local flying = false
local noclip = false
local infJump = false
local espEnabled = false

local espColor = Color3.fromRGB(255,0,0)
local espObjects = {}

------------------------------------------------
-- GUI
------------------------------------------------
local screen = Instance.new("ScreenGui")
screen.Name = "LurshGui"
screen.Parent = gui
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 340, 0, 390)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

------------------------------------------------
-- TOPBAR
------------------------------------------------
local topBar = Instance.new("Frame")
topBar.Parent = mainFrame
topBar.Size = UDim2.new(1,0,0,35)
topBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Parent = topBar
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "LURSH"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,0,0)

------------------------------------------------
-- DRAG
------------------------------------------------
local dragging, dragStart, startPos

topBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = mainFrame.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + d.X,
			startPos.Y.Scale,
			startPos.Y.Offset + d.Y
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

------------------------------------------------
-- TABS
------------------------------------------------
local tabFrame = Instance.new("Frame")
tabFrame.Parent = mainFrame
tabFrame.Size = UDim2.new(1,-20,0,35)
tabFrame.Position = UDim2.new(0,10,0,45)
tabFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = tabFrame
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,8)

local function tab(name)
	local b = Instance.new("TextButton")
	b.Parent = tabFrame
	b.Size = UDim2.new(0,95,1,0)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local mainTab = tab("Main")
local visualsTab = tab("Visuals")
local bindTab = tab("Bind")

------------------------------------------------
-- PAGES
------------------------------------------------
local function page()
	local p = Instance.new("Frame")
	p.Parent = mainFrame
	p.Position = UDim2.new(0,0,0,90)
	p.Size = UDim2.new(1,0,1,-95)
	p.BackgroundTransparency = 1
	return p
end

local mainPage = page()
local visualsPage = page()
local bindPage = page()

visualsPage.Visible = false
bindPage.Visible = false

local function switch(p)
	mainPage.Visible = false
	visualsPage.Visible = false
	bindPage.Visible = false
	p.Visible = true
end

mainTab.MouseButton1Click:Connect(function() switch(mainPage) end)
visualsTab.MouseButton1Click:Connect(function() switch(visualsPage) end)
bindTab.MouseButton1Click:Connect(function() switch(bindPage) end)

------------------------------------------------
-- BUTTON
------------------------------------------------
local function btn(txt,y,parent)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(0,260,0,35)
	b.Position = UDim2.new(0.5,-130,0,y)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(170,0,0)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

------------------------------------------------
-- SPEED + JUMP
------------------------------------------------
local speedBox = Instance.new("TextBox")
speedBox.Parent = mainPage
speedBox.Size = UDim2.new(0,125,0,35)
speedBox.Position = UDim2.new(0.5,-130,0,10)
speedBox.PlaceholderText = "Speed"
speedBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
speedBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,10)

local jumpBox = Instance.new("TextBox")
jumpBox.Parent = mainPage
jumpBox.Size = UDim2.new(0,125,0,35)
jumpBox.Position = UDim2.new(0.5,5,0,10)
jumpBox.PlaceholderText = "Jump"
jumpBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
jumpBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0,10)

local applyBtn = btn("Apply",60,mainPage)
local flyBtn = btn("Fly OFF",105,mainPage)
local noclipBtn = btn("Noclip OFF",150,mainPage)
local infBtn = btn("InfJump OFF",195,mainPage)
local closeBtn = btn("Close GUI",240,mainPage)

------------------------------------------------
-- APPLY
------------------------------------------------
applyBtn.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = tonumber(speedBox.Text) or 16
		hum.JumpPower = tonumber(jumpBox.Text) or 50
	end
end)

------------------------------------------------
-- TOGGLES
------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	flyBtn.Text = flying and "Fly ON" or "Fly OFF"
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip ON" or "Noclip OFF"
end)

infBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	infBtn.Text = infJump and "InfJump ON" or "InfJump OFF"
end)

closeBtn.MouseButton1Click:Connect(function()
	screen.Enabled = false
end)

------------------------------------------------
-- VISUALS
------------------------------------------------
local espBtn = btn("ESP OFF",10,visualsPage)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "ESP ON" or "ESP OFF"
end)

------------------------------------------------
-- COLOR PALETTE
------------------------------------------------
local colors = {
	Color3.fromRGB(255,0,0),
	Color3.fromRGB(0,255,0),
	Color3.fromRGB(0,0,255),
	Color3.fromRGB(255,255,0),
	Color3.fromRGB(255,255,255),
	Color3.fromRGB(255,0,255),
	Color3.fromRGB(0,255,255),
}

local paletteFrame = Instance.new("Frame")
paletteFrame.Parent = visualsPage
paletteFrame.Size = UDim2.new(0,260,0,40)
paletteFrame.Position = UDim2.new(0.5,-130,0,55)
paletteFrame.BackgroundTransparency = 1

local pl = Instance.new("UIListLayout")
pl.Parent = paletteFrame
pl.FillDirection = Enum.FillDirection.Horizontal
pl.Padding = UDim.new(0,5)

for _,c in ipairs(colors) do
	local b = Instance.new("TextButton")
	b.Parent = paletteFrame
	b.Size = UDim2.new(0,25,0,25)
	b.BackgroundColor3 = c
	b.Text = ""
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)

	b.MouseButton1Click:Connect(function()
		espColor = c
	end)
end

------------------------------------------------
-- ESP LOOP (FIXED & STABLE)
------------------------------------------------
RunService.RenderStepped:Connect(function()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")

			if root then
				local box = espObjects[plr]

				if espEnabled then
					if not box then
						box = Instance.new("BoxHandleAdornment")
						box.Parent = workspace
						box.Adornee = root
						box.Size = Vector3.new(4,5,1)
						box.Transparency = 0.5
						box.AlwaysOnTop = true
						espObjects[plr] = box
					end
					box.Color3 = espColor
				else
					if box then
						box:Destroy()
						espObjects[plr] = nil
					end
				end
			end
		end
	end
end)

------------------------------------------------
-- INF JUMP
------------------------------------------------
UIS.JumpRequest:Connect(function()
	if infJump then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)
