local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI ANA EKRAN
local screen = Instance.new("ScreenGui", gui)
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,220,0,380) -- Boyut biraz artırıldı
frame.Position = UDim2.new(0.5,-110,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BorderSizePixel = 0

-- DRAG SCRIPT (Sürükleme)
local draggingUI, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingUI = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and draggingUI then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 🌈 RAINBOW AURORA TITLE
local auroraTitle = Instance.new("TextLabel", frame)
auroraTitle.Size = UDim2.new(1,0,0,30)
auroraTitle.Text = "AURORA"
auroraTitle.BackgroundTransparency = 1
auroraTitle.TextScaled = true
auroraTitle.Font = Enum.Font.GothamBold

task.spawn(function()
    local h = 0
    while true do
        h = (h + 0.01) % 1
        auroraTitle.TextColor3 = Color3.fromHSV(h,0.8,1)
        RunService.RenderStepped:Wait()
    end
end)

-- TABS (MAIN / BIND)
local tabContainer = Instance.new("Frame", frame)
tabContainer.Size = UDim2.new(1,0,0,25)
tabContainer.Position = UDim2.new(0,0,0,30)
tabContainer.BackgroundTransparency = 1

local mainTab = Instance.new("TextButton", tabContainer)
mainTab.Size = UDim2.new(0.5,0,1,0)
mainTab.Text = "Main"
mainTab.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainTab.TextColor3 = Color3.new(1,1,1)

local bindTab = Instance.new("TextButton", tabContainer)
bindTab.Size = UDim2.new(0.5,0,1,0)
bindTab.Position = UDim2.new(0.5,0,0,0)
bindTab.Text = "Bind"
bindTab.BackgroundColor3 = Color3.fromRGB(20,20,20)
bindTab.TextColor3 = Color3.new(1,1,1)

local mainFrame = Instance.new("Frame", frame)
mainFrame.Size = UDim2.new(1,0,1,-55)
mainFrame.Position = UDim2.new(0,0,0,55)
mainFrame.BackgroundTransparency = 1

local bindFrame = Instance.new("Frame", frame)
bindFrame.Size = UDim2.new(1,0,1,-55)
bindFrame.Position = UDim2.new(0,0,0,55)
bindFrame.BackgroundTransparency = 1
bindFrame.Visible = false

mainTab.MouseButton1Click:Connect(function()
    mainFrame.Visible = true; bindFrame.Visible = false
    mainTab.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bindTab.BackgroundColor3 = Color3.fromRGB(20,20,20)
end)

bindTab.MouseButton1Click:Connect(function()
    mainFrame.Visible = false; bindFrame.Visible = true
    bindTab.BackgroundColor3 = Color3.fromRGB(30,30,30)
    mainTab.BackgroundColor3 = Color3.fromRGB(20,20,20)
end)

-- LURSH LOGO
local lursh = Instance.new("TextLabel", mainFrame)
lursh.Size = UDim2.new(1,0,0,20)
lursh.Text = "Owner VexR4"
lursh.TextColor3 = Color3.new(1,1,1)
lursh.BackgroundTransparency = 1

-- INPUTS (SPEED/JUMP)
local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Position = UDim2.new(0,10,0,25)
speedBox.Size = UDim2.new(0,90,0,20)
speedBox.PlaceholderText = "SPEED"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local jumpBox = Instance.new("TextBox", mainFrame)
jumpBox.Position = UDim2.new(0,120,0,25)
jumpBox.Size = UDim2.new(0,90,0,20)
jumpBox.PlaceholderText = "JUMP"
jumpBox.TextColor3 = Color3.new(1,1,1)
jumpBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- BUTTON BUILDER
local function btn(text, y)
    local b = Instance.new("TextButton", mainFrame)
    b.Size = UDim2.new(0,180,0,22)
    b.Position = UDim2.new(0.5,-90,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(0,60,150)
    b.TextColor3 = Color3.new(1,1,1)
    b.AutoButtonColor = true
    return b
end

local apply = btn("Apply", 50)
local reset = btn("Reset", 75)
local flyBtn = btn("Fly: OFF", 100)
local noclipBtn = btn("Noclip: OFF", 125)
local infBtn = btn("Infinity Jump: OFF", 150)
local closeBtn = btn("Close GUI", 175)

-- FLY SPEED CONTROLS
local flyLabel = Instance.new("TextLabel", mainFrame)
flyLabel.Text = "Fly Speed: 60"
flyLabel.Size = UDim2.new(1,0,0,20)
flyLabel.Position = UDim2.new(0,0,0,205)
flyLabel.TextColor3 = Color3.new(1,1,1)
flyLabel.BackgroundTransparency = 1

local speedMinus = Instance.new("TextButton", mainFrame)
speedMinus.Text = "-"
speedMinus.Size = UDim2.new(0,30,0,20)
speedMinus.Position = UDim2.new(0.5,-65,0,225)
speedMinus.BackgroundColor3 = Color3.fromRGB(200,0,0)

local speedPlus = Instance.new("TextButton", mainFrame)
speedPlus.Text = "+"
speedPlus.Size = UDim2.new(0,30,0,20)
speedPlus.Position = UDim2.new(0.5,35,0,225)
speedPlus.BackgroundColor3 = Color3.fromRGB(0,200,0)

-- VEXR4 FOOTER
local vexr = Instance.new("TextLabel", frame)
vexr.Size = UDim2.new(1,0,0,20)
vexr.Position = UDim2.new(0,0,1,-20)
vexr.Text = "VEXR4"
vexr.TextColor3 = Color3.fromRGB(100,100,100)
vexr.BackgroundTransparency = 1
vexr.Font = Enum.Font.Code

-- LOGIC STATES
local flying = false
local noclip = false
local infJump = false
local flySpeed = 60
local currentSpeed = 16
local bv

-- SPEED ACTIONS
local function updateFlySpeed(val)
    flySpeed = math.clamp(flySpeed + val, 10, 500)
    flyLabel.Text = "Fly Speed: "..flySpeed
end

speedMinus.MouseButton1Click:Connect(function() updateFlySpeed(-10) end)
speedPlus.MouseButton1Click:Connect(function() updateFlySpeed(10) end)

apply.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        currentSpeed = tonumber(speedBox.Text) or 16
        hum.JumpPower = tonumber(jumpBox.Text) or 50
    end
end)

reset.MouseButton1Click:Connect(function()
    currentSpeed = 16
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 50 end
end)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if flying and root then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e7,1e7,1e7)
        bv.Velocity = Vector3.zero
        bv.Parent = root
    elseif bv then
        bv:Destroy()
        bv = nil
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
end)

infBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    infBtn.Text = infJump and "Infinity Jump: ON" or "Infinity Jump: OFF"
end)

closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then hum.WalkSpeed = flying and 0 or currentSpeed end

    if infJump and hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if noclip and char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if flying and root and bv then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
    end
end)
