local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI
local screen = Instance.new("ScreenGui", gui)
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,220,0,320)
frame.Position = UDim2.new(0.5,-110,0,10)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

-- DRAG
local draggingUI = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingUI = false
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
    if input == dragInput and draggingUI then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- TABS
local mainTab = Instance.new("TextButton", frame)
mainTab.Size = UDim2.new(0.5,0,0,25)
mainTab.Position = UDim2.new(0,0,0,0)
mainTab.Text = "Main"
mainTab.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainTab.TextColor3 = Color3.new(1,1,1)

local bindTab = Instance.new("TextButton", frame)
bindTab.Size = UDim2.new(0.5,0,0,25)
bindTab.Position = UDim2.new(0.5,0,0,0)
bindTab.Text = "Bind"
bindTab.BackgroundColor3 = Color3.fromRGB(10,10,10)
bindTab.TextColor3 = Color3.new(1,1,1)

-- FRAMES
local mainFrame = Instance.new("Frame", frame)
mainFrame.Size = UDim2.new(1,0,1,-25)
mainFrame.Position = UDim2.new(0,0,0,25)
mainFrame.BackgroundTransparency = 1

local bindFrame = Instance.new("Frame", frame)
bindFrame.Size = UDim2.new(1,0,1,-25)
bindFrame.Position = UDim2.new(0,0,0,25)
bindFrame.BackgroundTransparency = 1
bindFrame.Visible = false

-- TAB SWITCH
mainTab.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    bindFrame.Visible = false
end)

bindTab.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    bindFrame.Visible = true
end)

-- TITLE
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,25)
title.Text = "LURSH"
title.BackgroundTransparency = 1
title.TextScaled = true

task.spawn(function()
    local h = 0
    while true do
        h = (h + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(h,1,1)
        RunService.RenderStepped:Wait()
    end
end)

-- INPUTS
local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Position = UDim2.new(0,10,0,35)
speedBox.Size = UDim2.new(0,90,0,20)
speedBox.PlaceholderText = "SPEED"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local jumpBox = Instance.new("TextBox", mainFrame)
jumpBox.Position = UDim2.new(0,120,0,35)
jumpBox.Size = UDim2.new(0,90,0,20)
jumpBox.PlaceholderText = "JUMP"
jumpBox.TextColor3 = Color3.new(1,1,1)
jumpBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- BUTTON FUNCTION
local function btn(text,y)
    local b = Instance.new("TextButton", mainFrame)
    b.Size = UDim2.new(0,180,0,22)
    b.Position = UDim2.new(0.5,-90,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(0,60,150)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local apply = btn("Apply",65)
local reset = btn("Reset",95)
local flyBtn = btn("Fly: OFF",125)
local noclipBtn = btn("Noclip: OFF",155)
local infBtn = btn("Infinity Jump: OFF",185)
local closeBtn = btn("Close GUI",215)

-- STATES
local flying = false
local noclip = false
local infJump = false
local flySpeed = 50
local currentSpeed = 16

-- BINDS
local binds = {
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    InfJump = Enum.KeyCode.J
}

local waitingForBind = nil

-- SLIDER
local bar = Instance.new("Frame", mainFrame)
bar.Size = UDim2.new(0,180,0,8)
bar.Position = UDim2.new(0.5,-90,0,245)
bar.BackgroundColor3 = Color3.fromRGB(40,40,40)

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new(0.5,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(0,60,150)

local dragging = false

bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

bar.InputEnded:Connect(function()
    dragging = false
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,0,1)
        fill.Size = UDim2.new(x,0,1,0)
        flySpeed = math.floor(20 + x*180)
    end
end)

-- BUTTON ACTIONS
apply.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        currentSpeed = tonumber(speedBox.Text) or 16
        hum.WalkSpeed = currentSpeed
        hum.JumpPower = tonumber(jumpBox.Text) or 50
    end
end)

reset.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        currentSpeed = 16
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

-- INPUT SYSTEM
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == binds.Fly then
        flying = not flying
        flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
    end

    if input.KeyCode == binds.Noclip then
        noclip = not noclip
        noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
    end

    if input.KeyCode == binds.InfJump then
        infJump = not infJump
        infBtn.Text = infJump and "Infinity Jump: ON" or "Infinity Jump: OFF"
    end

    if input.KeyCode == Enum.KeyCode.LeftControl then
        screen.Enabled = not screen.Enabled
    end
end)

-- SYSTEM LOOP
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- SPEED FIX
    if hum and not flying then
        hum.WalkSpeed = currentSpeed
    elseif hum and flying then
        hum.WalkSpeed = 0
    end

    -- INF JUMP
    if infJump and hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- NOCLIP
    if noclip and char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- FLY FIXED
    if flying and root then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            root.AssemblyLinearVelocity = move.Unit * flySpeed
        else
            root.AssemblyLinearVelocity = Vector3.zero
        end
    else
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)
