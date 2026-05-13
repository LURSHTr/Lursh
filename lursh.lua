local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Bağlantıları tutmak için tablo (Kapatınca hepsini durduracağız)
local connections = {}

-- STATES & DEFAULTS
local states = { flying = false, noclip = false, infJump = false }
local binds = { flying = Enum.KeyCode.F, noclip = Enum.KeyCode.N, infJump = Enum.KeyCode.J }
local settings = { walkSpeed = 16, jumpPower = 50, flySpeed = 50 }
local espEnabled = false
local iceBlue = Color3.fromRGB(175, 238, 238)
local bindingTarget = nil

------------------------------------------------
-- GUI SETUP
------------------------------------------------
local screen = Instance.new("ScreenGui")
screen.Name = "LurshPremiumV3_Final"
screen.Parent = gui
screen.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 380, 0, 480)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

-- Topbar
local topBar = Instance.new("Frame")
topBar.Parent = mainFrame
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Parent = topBar
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "LURSH PREMIUM V3"
title.TextColor3 = iceBlue
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Sürükleme
local dragging, dragStart, startPos
connections.DragStart = topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = mainFrame.Position end end)
connections.DragChange = UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
connections.DragEnd = UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

------------------------------------------------
-- NAVIGATION & PAGES
------------------------------------------------
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", tabFrame).FillDirection = Enum.FillDirection.Horizontal
tabFrame.UIListLayout.Padding = UDim.new(0, 10)

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", mainFrame)
    p.Size = UDim2.new(1, 0, 1, -100)
    p.Position = UDim2.new(0, 0, 0, 95)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    
    local b = Instance.new("TextButton", tabFrame)
    b.Size = UDim2.new(0, 110, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(function()
        for _,pg in pairs(pages) do pg.Visible = false end
        p.Visible = true
    end)
    return p
end

local mainPage = createPage("Main")
local visualsPage = createPage("Visuals")
local bindPage = createPage("Bind")
mainPage.Visible = true

------------------------------------------------
-- HELPERS
------------------------------------------------
local function createSlider(parent, text, y, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 300, 0, 25)
    frame.Position = UDim2.new(0.5, -150, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", frame)

    local inner = Instance.new("Frame", frame)
    inner.Size = UDim2.new(default/max, 0, 1, 0)
    inner.BackgroundColor3 = iceBlue
    Instance.new("UICorner", inner)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text..": "..math.floor(default)
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12

    local sDragging = false
    frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if sDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((i.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
            inner.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(pos * max)
            label.Text = text..": "..val
            callback(val)
        end
    end)
end

local function createBtn(text, y, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 300, 0, 35)
    b.Position = UDim2.new(0.5, -150, 0, y)
    b.BackgroundColor3 = iceBlue
    b.Text = text
    b.TextColor3 = Color3.fromRGB(10, 10, 10)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(callback)
    return b
end

------------------------------------------------
-- MAIN CONTENT
------------------------------------------------
createSlider(mainPage, "Walk Speed", 10, 200, 16, function(v) settings.walkSpeed = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
createSlider(mainPage, "Jump Power", 45, 300, 50, function(v) settings.jumpPower = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
createSlider(mainPage, "Fly Speed", 80, 500, 50, function(v) settings.flySpeed = v end)

local flyBtn = createBtn("Fly: OFF", 120, mainPage, function() states.flying = not states.flying end)
local noclipBtn = createBtn("Noclip: OFF", 165, mainPage, function() states.noclip = not states.noclip end)
local infBtn = createBtn("InfJump: OFF", 210, mainPage, function() states.infJump = not states.infJump end)

-- KESİN ÇÖZÜM: TÜM SCRIPT'İ YOK EDEN BUTON
createBtn("CLOSE GUI (UNLOAD)", 330, mainPage, function() 
    -- 1. Tüm döngüleri ve bağlantıları durdur
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    -- 2. Aktif hileleri kapat
    states.flying = false
    states.noclip = false
    states.infJump = false
    espEnabled = false
    -- 3. GUI'yi tamamen sil
    screen:Destroy()
end)

------------------------------------------------
-- BIND PAGE
------------------------------------------------
local function createBind(text, y, keyName)
    local label = Instance.new("TextLabel", bindPage)
    label.Size = UDim2.new(0, 150, 0, 35)
    label.Position = UDim2.new(0, 40, 0, y)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bBox = Instance.new("TextButton", bindPage)
    bBox.Size = UDim2.new(0, 100, 0, 35)
    bBox.Position = UDim2.new(0, 200, 0, y)
    bBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bBox.Text = binds[keyName].Name
    bBox.TextColor3 = iceBlue
    bBox.TextSize = 13
    Instance.new("UICorner", bBox)

    bBox.MouseButton1Click:Connect(function()
        bindingTarget = keyName
        bBox.Text = "..."
    end)
end

createBind("Fly Toggle", 10, "flying")
createBind("Noclip Toggle", 55, "noclip")
createBind("InfJump Toggle", 100, "infJump")

------------------------------------------------
-- LOGICS (Döngüler Bağlantılara Atandı)
------------------------------------------------
local bv, bg
connections.MainLoop = RunService.RenderStepped:Connect(function()
    flyBtn.Text = "Fly: "..(states.flying and "ON" or "OFF")
    noclipBtn.Text = "Noclip: "..(states.noclip and "ON" or "OFF")
    infBtn.Text = "InfJump: "..(states.infJump and "ON" or "OFF")

    local char = player.Character
    if states.flying and char and char:FindFirstChild("HumanoidRootPart") then
        if not bv then
            bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bg = Instance.new("BodyGyro", char.HumanoidRootPart)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            char.Humanoid.PlatformStand = true
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity = dir * settings.flySpeed
        bg.CFrame = cam.CFrame
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end

    if states.noclip and char then
        for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

connections.Input = UIS.InputBegan:Connect(function(input, gpe)
    if bindingTarget then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            binds[bindingTarget] = input.KeyCode
            for _, v in pairs(bindPage:GetChildren()) do
                if v:IsA("TextButton") and v.Text == "..." then v.Text = input.KeyCode.Name end
            end
            bindingTarget = nil
        end
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftControl then
        screen.Enabled = not screen.Enabled
    end

    if not gpe then
        if input.KeyCode == binds.flying then states.flying = not states.flying end
        if input.KeyCode == binds.noclip then states.noclip = not states.noclip end
        if input.KeyCode == binds.infJump then states.infJump = not states.infJump end
    end
end)

connections.InfJump = UIS.JumpRequest:Connect(function()
    if states.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Visuals
local espBtn = createBtn("ESP: OFF", 10, visualsPage, function() espEnabled = not espEnabled end)
connections.ESP = RunService.RenderStepped:Connect(function()
    espBtn.Text = "ESP: "..(espEnabled and "ON" or "OFF")
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("LurshESP")
            if espEnabled then
                if not h then h = Instance.new("Highlight", p.Character) h.Name = "LurshESP" end
                h.FillColor = iceBlue
            elseif h then h:Destroy() end
        end
    end
end)
