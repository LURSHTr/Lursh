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
local draggingUI, dragInput, dragStart, startPos

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

-- STATES
local flying = false
local noclip = false
local infJump = false
local flySpeed = 60
local currentSpeed = 16
local bv

-- INPUTS
local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0,10,0,35)
speedBox.Size = UDim2.new(0,90,0,20)
speedBox.PlaceholderText = "SPEED"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local jumpBox = Instance.new("TextBox", frame)
jumpBox.Position = UDim2.new(0,120,0,35)
jumpBox.Size = UDim2.new(0,90,0,20)
jumpBox.PlaceholderText = "JUMP"
jumpBox.TextColor3 = Color3.new(1,1,1)
jumpBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function btn(text,y)
    local b = Instance.new("TextButton", frame)
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

-- APPLY
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
    if hum then
        hum.JumpPower = 50
    end
end)

-- FLY TOGGLE (FIXED CORE)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"

    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if flying and root then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e7,1e7,1e7)
        bv.Velocity = Vector3.zero
        bv.Parent = root
    else
        if bv then
            bv:Destroy()
            bv = nil
        end
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

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- MAIN LOOP (CLEAN FIXED ENGINE)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- SPEED (NO CONFLICT)
    if hum then
        hum.WalkSpeed = flying and 0 or currentSpeed
    end

    -- INF JUMP
    if infJump and hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- NOCLIP FIX (stable toggle system)
    if char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not noclip
            end
        end
    end

    -- FLY ENGINE (ONLY CONTROL SOURCE)
    if flying and root and bv then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            bv.Velocity = move.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end
    end
end)
