local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI
local screen = Instance.new("ScreenGui", gui)
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,320,0,420)
frame.Position = UDim2.new(0.5,-160,0,10)
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

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(0,0,0)
title.Text = "LURSH"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

task.spawn(function()
    local h = 0

    while true do
        h = (h + 0.01) % 1
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
    b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = text
    return b
end

local mainTab = makeTab("Main",0)
local visualsTab = makeTab("Visuals",0.33)
local bindTab = makeTab("Bind",0.66)

-- PAGES
local mainPage = Instance.new("Frame", frame)
mainPage.Size = UDim2.new(1,0,1,-65)
mainPage.Position = UDim2.new(0,0,0,65)
mainPage.BackgroundTransparency = 1

local visualsPage = mainPage:Clone()
visualsPage.Parent = frame
visualsPage.Visible = false

local bindPage = mainPage:Clone()
bindPage.Parent = frame
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

-- BUTTON HELPER
local hellRed = Color3.fromRGB(170,0,0)

local function btn(text,y,parent)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0,260,0,30)
    b.Position = UDim2.new(0.5,-130,0,y)
    b.BackgroundColor3 = hellRed
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = text
    return b
end

-- INPUTS
local speedBox = Instance.new("TextBox", mainPage)
speedBox.Position = UDim2.new(0,15,0,15)
speedBox.Size = UDim2.new(0,130,0,28)
speedBox.PlaceholderText = "SPEED"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local jumpBox = Instance.new("TextBox", mainPage)
jumpBox.Position = UDim2.new(0,175,0,15)
jumpBox.Size = UDim2.new(0,130,0,28)
jumpBox.PlaceholderText = "JUMP"
jumpBox.TextColor3 = Color3.new(1,1,1)
jumpBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- BUTTONS
local apply = btn("Apply",60,mainPage)
local reset = btn("Reset",100,mainPage)
local flyBtn = btn("Fly: OFF",140,mainPage)
local noclipBtn = btn("Noclip: OFF",180,mainPage)
local infBtn = btn("Infinity Jump: OFF",220,mainPage)
local closeBtn = btn("Close GUI",260,mainPage)

-- STATES
local flying = false
local noclip = false
local infJump = false
local flySpeed = 50

-- SLIDER
local bar = Instance.new("Frame", mainPage)
bar.Size = UDim2.new(0,260,0,10)
bar.Position = UDim2.new(0.5,-130,0,320)
bar.BackgroundColor3 = Color3.fromRGB(40,40,40)

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new(0.5,0,1,0)
fill.BackgroundColor3 = hellRed

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

-- MAIN BUTTONS
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

apply.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = tonumber(speedBox.Text) or 16
        hum.JumpPower = tonumber(jumpBox.Text) or 50
    end
end)

reset.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- VISUALS
local espEnabled = false
local tracerEnabled = false
local nametagEnabled = false

local espBtn = btn("Player ESP: OFF",20,visualsPage)
local tracerBtn = btn("Tracers: OFF",60,visualsPage)
local nameBtn = btn("NameTags: OFF",100,visualsPage)

-- BOX ESP
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "Player ESP: ON" or "Player ESP: OFF"

    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then

            local old = plr.Character:FindFirstChild("LurshBoxESP")
            if old then
                old:Destroy()
            end

            if espEnabled then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "LurshBoxESP"
                box.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = Vector3.new(4,6,2)
                box.Color3 = Color3.fromRGB(255,0,0)
                box.Transparency = 0.4
                box.Parent = plr.Character
            end
        end
    end
end)

-- TRACERS
tracerBtn.MouseButton1Click:Connect(function()
    tracerEnabled = not tracerEnabled
    tracerBtn.Text = tracerEnabled and "Tracers: ON" or "Tracers: OFF"
end)

-- NAME TAGS
nameBtn.MouseButton1Click:Connect(function()
    nametagEnabled = not nametagEnabled
    nameBtn.Text = nametagEnabled and "NameTags: ON" or "NameTags: OFF"

    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then

            local old = plr.Character.Head:FindFirstChild("LurshNameTag")
            if old then
                old:Destroy()
            end

            if nametagEnabled then
                local bill = Instance.new("BillboardGui")
                bill.Name = "LurshNameTag"
                bill.AlwaysOnTop = true
                bill.Size = UDim2.new(0,100,0,20)
                bill.StudsOffset = Vector3.new(0,1.5,0)
                bill.Parent = plr.Character.Head

                local txt = Instance.new("TextLabel", bill)
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = plr.Name
                txt.TextColor3 = Color3.new(1,1,1)
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.Font = Enum.Font.SourceSansBold
            end
        end
    end
end)

-- NEW PLAYERS
game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)

        if nametagEnabled and char:FindFirstChild("Head") then
            local bill = Instance.new("BillboardGui")
            bill.Name = "LurshNameTag"
            bill.AlwaysOnTop = true
            bill.Size = UDim2.new(0,100,0,20)
            bill.StudsOffset = Vector3.new(0,1.5,0)
            bill.Parent = char.Head

            local txt = Instance.new("TextLabel", bill)
            txt.Size = UDim2.new(1,0,1,0)
            txt.BackgroundTransparency = 1
            txt.Text = plr.Name
            txt.TextColor3 = Color3.new(1,1,1)
            txt.TextStrokeTransparency = 0
            txt.TextScaled = true
            txt.Font = Enum.Font.SourceSansBold
        end
    end)
end)

-- BINDS
local selectedKey = Enum.KeyCode.LeftControl
local activeBindChange = nil

local bindList = {
    {"Fly", flyBtn},
    {"Noclip", noclipBtn},
    {"InfinityJump", infBtn},
}

local bindFrames = {}

for i,v in pairs(bindList) do
    local name = v[1]
    local actionButton = v[2]

    local txt = Instance.new("TextLabel", bindPage)
    txt.Size = UDim2.new(0,120,0,30)
    txt.Position = UDim2.new(0,20,0,20 + ((i-1)*50))
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1)
    txt.TextScaled = true
    txt.Text = name

    local bindBox = Instance.new("TextButton", bindPage)
    bindBox.Size = UDim2.new(0,120,0,30)
    bindBox.Position = UDim2.new(0,170,0,20 + ((i-1)*50))
    bindBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
    bindBox.TextColor3 = Color3.new(1,1,1)
    bindBox.TextScaled = true
    bindBox.Text = "NONE"

    bindFrames[name] = {
        Key = nil,
        Button = bindBox,
        Action = actionButton
    }

    bindBox.MouseButton1Click:Connect(function()
        activeBindChange = name
        bindBox.Text = "PRESS KEY"
    end)
end

-- SYSTEMS
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

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

    -- FLY
    if flying and root then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move += cam.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move -= cam.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move -= cam.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move += cam.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.new(0,1,0)
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            move -= Vector3.new(0,1,0)
        end

        if move.Magnitude > 0 then
            root.Velocity = move.Unit * flySpeed
        end
    end
end)

-- TRACERS LOOP
RunService.RenderStepped:Connect(function()
    if tracerEnabled then
        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

                local beam = Instance.new("Part")
                beam.Anchored = true
                beam.CanCollide = false
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(255,0,0)

                local root = v.Character.HumanoidRootPart
                local from = workspace.CurrentCamera.CFrame.Position
                local to = root.Position

                local dist = (from - to).Magnitude

                beam.Size = Vector3.new(0.05,0.05,dist)
                beam.CFrame = CFrame.new(from,to) * CFrame.new(0,0,-dist/2)

                beam.Parent = workspace

                game.Debris:AddItem(beam,0.03)
            end
        end
    end
end)

-- KEYBINDS
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end

    -- GUI TOGGLE
    if input.KeyCode == selectedKey then
        screen.Enabled = not screen.Enabled
    end

    -- CHANGE BIND
    if activeBindChange then
        bindFrames[activeBindChange].Key = input.KeyCode
        bindFrames[activeBindChange].Button.Text = input.KeyCode.Name
        activeBindChange = nil
        return
    end

    -- EXECUTE BINDS
    for _,data in pairs(bindFrames) do
        if data.Key and input.KeyCode == data.Key then
            data.Action:Activate()
        end
    end
end)
