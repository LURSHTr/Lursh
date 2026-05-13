local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera

-- Değişkenler
local connections = {}
local tracerLines = {}
local nameTags = {}
local savedPosition = nil 

-- STATES & DEFAULTS
local states = { 
    flying = false, noclip = false, infJump = false, 
    espEnabled = false, tracersEnabled = false, namesEnabled = false,
    aimbotEnabled = false, aimbotTeamCheck = false 
}
local binds = { 
    flying = Enum.KeyCode.F, 
    noclip = Enum.KeyCode.N, 
    infJump = Enum.KeyCode.J,
    savePos = Enum.KeyCode.K,
    tpPos = Enum.KeyCode.L,
    aimKey = Enum.UserInputType.MouseButton2
}
local settings = { 
    walkSpeed = 16, jumpPower = 50, flySpeed = 50, 
    aimSmoothness = 1, aimFOV = 150 
}
local currentESPColor = Color3.fromRGB(175, 238, 238)
local iceBlue = Color3.fromRGB(175, 238, 238)
local bindingTarget = nil

------------------------------------------------
-- DRAWING HELPERS
------------------------------------------------
local function createDrawing(type, properties)
    local obj = Drawing.new(type)
    for prop, val in pairs(properties) do obj[prop] = val end
    return obj
end

------------------------------------------------
-- GUI SETUP
------------------------------------------------
local screen = Instance.new("ScreenGui")
screen.Name = "LurshPremiumV3_CleanFix"
screen.Parent = gui
screen.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 380, 0, 500)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

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

-- Sürükleme Mantığı
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = mainFrame.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

------------------------------------------------
-- PAGES
------------------------------------------------
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", mainFrame)
    p.Size = UDim2.new(1, 0, 1, -110)
    p.Position = UDim2.new(0, 0, 0, 95)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    
    local b = Instance.new("TextButton", tabFrame)
    b.Size = UDim2.new(0, 68, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(function()
        for _,pg in pairs(pages) do pg.Visible = false end
        p.Visible = true
    end)
    return p
end

local mainPage = createPage("Main")
local visualsPage = createPage("Visuals")
local aimPage = createPage("Aim")
local bindPage = createPage("Bind")
local tpPage = createPage("TP")
mainPage.Visible = true

------------------------------------------------
-- UI COMPONENTS
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
    label.TextSize = 11
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
    b.Size = UDim2.new(0, 300, 0, 32)
    b.Position = UDim2.new(0.5, -150, 0, y)
    b.BackgroundColor3 = iceBlue
    b.Text = text
    b.TextColor3 = Color3.fromRGB(10, 10, 10)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- MAIN PAGE
createSlider(mainPage, "Walk Speed", 10, 200, 16, function(v) settings.walkSpeed = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
createSlider(mainPage, "Jump Power", 45, 300, 50, function(v) settings.jumpPower = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
createSlider(mainPage, "Fly Speed", 80, 500, 50, function(v) settings.flySpeed = v end)
local flyBtn = createBtn("Fly: OFF", 120, mainPage, function() states.flying = not states.flying end)
local noclipBtn = createBtn("Noclip: OFF", 160, mainPage, function() states.noclip = not states.noclip end)
local infBtn = createBtn("InfJump: OFF", 200, mainPage, function() states.infJump = not states.infJump end)

createBtn("CLOSE GUI (UNLOAD)", 340, mainPage, function() 
    for _, c in pairs(connections) do if c then c:Disconnect() end end
    for _, l in pairs(tracerLines) do l:Remove() end
    for _, n in pairs(nameTags) do n:Remove() end
    if FOVCircle then FOVCircle:Remove() end
    screen:Destroy()
end)

-- VISUALS PAGE
local espBtn = createBtn("ESP: OFF", 10, visualsPage, function() states.espEnabled = not states.espEnabled end)
local tracerBtn = createBtn("Tracers: OFF", 50, visualsPage, function() states.tracersEnabled = not states.tracersEnabled end)
local nameBtn = createBtn("Names: OFF", 90, visualsPage, function() states.namesEnabled = not states.namesEnabled end)

local colorGrid = Instance.new("Frame", visualsPage)
colorGrid.Size = UDim2.new(0, 300, 0, 40)
colorGrid.Position = UDim2.new(0.5, -150, 0, 140)
colorGrid.BackgroundTransparency = 1
Instance.new("UIListLayout", colorGrid).FillDirection = Enum.FillDirection.Horizontal
colorGrid.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorGrid.UIListLayout.Padding = UDim.new(0, 8)

local palette = {Color3.fromRGB(175, 238, 238), Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 255, 50), Color3.fromRGB(255, 255, 50), Color3.fromRGB(255, 50, 255), Color3.fromRGB(255, 255, 255)}
for _, color in pairs(palette) do
    local cBtn = Instance.new("TextButton", colorGrid)
    cBtn.Size = UDim2.new(0, 30, 0, 30)
    cBtn.BackgroundColor3 = color
    cBtn.Text = ""
    Instance.new("UICorner", cBtn)
    cBtn.MouseButton1Click:Connect(function() currentESPColor = color title.TextColor3 = color end)
end

-- AIMBOT
local aimBtn = createBtn("Aimbot: OFF", 10, aimPage, function() states.aimbotEnabled = not states.aimbotEnabled end)
local teamCheckBtn = createBtn("Team Check: OFF", 50, aimPage, function() states.aimbotTeamCheck = not states.aimbotTeamCheck end)
createSlider(aimPage, "Smoothness", 90, 10, 1, function(v) settings.aimSmoothness = math.max(1, v) end)
createSlider(aimPage, "FOV Radius", 125, 600, 150, function(v) settings.aimFOV = v end)
local FOVCircle = createDrawing("Circle", {Thickness = 1, Transparency = 0.7, Color = currentESPColor, Visible = false})

-- TP PAGE
local statusLabel = Instance.new("TextLabel", tpPage)
statusLabel.Size = UDim2.new(0, 300, 0, 30) statusLabel.Position = UDim2.new(0.5, -150, 0, 10)
statusLabel.BackgroundTransparency = 1 statusLabel.Text = "No Position Saved" statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.GothamBold statusLabel.TextSize = 11

createBtn("SAVE CURRENT POS", 50, tpPage, function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then savedPosition = player.Character.HumanoidRootPart.CFrame statusLabel.Text = "Saved Waypoint!" statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50) end end)
createBtn("TELEPORT TO SAVED", 95, tpPage, function() if savedPosition and player.Character then player.Character.HumanoidRootPart.CFrame = savedPosition end end)
createBtn("DELETE WAYPOINT", 140, tpPage, function() savedPosition = nil statusLabel.Text = "Position Deleted" statusLabel.TextColor3 = Color3.fromRGB(255, 255, 50) end)

-- BIND PAGE
local function createBindRow(text, y, keyName)
    local label = Instance.new("TextLabel", bindPage)
    label.Size = UDim2.new(0, 150, 0, 25) label.Position = UDim2.new(0, 40, 0, y)
    label.Text = text label.TextColor3 = Color3.new(1,1,1) label.Font = Enum.Font.GothamBold label.TextSize = 10 label.TextXAlignment = Enum.TextXAlignment.Left
    local bBox = Instance.new("TextButton", bindPage)
    bBox.Size = UDim2.new(0, 100, 0, 25) bBox.Position = UDim2.new(0, 200, 0, y)
    bBox.BackgroundColor3 = Color3.fromRGB(30,30,30) bBox.Text = tostring(binds[keyName]):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
    bBox.TextColor3 = iceBlue bBox.TextSize = 10 Instance.new("UICorner", bBox)
    bBox.MouseButton1Click:Connect(function() bindingTarget = keyName bBox.Text = "..." end)
end
createBindRow("Fly", 10, "flying"); createBindRow("Noclip", 40, "noclip"); createBindRow("InfJump", 70, "infJump")
createBindRow("Save Pos", 100, "savePos"); createBindRow("TP to Pos", 130, "tpPos"); createBindRow("Aimbot Key", 160, "aimKey")

------------------------------------------------
-- LOGICS (CLEANUP ADDED)
------------------------------------------------
local function getClosest()
    local target, shortestDist = nil, settings.aimFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            if states.aimbotTeamCheck and p.Team == player.Team then continue end
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if dist < shortestDist then target = p shortestDist = dist end
            end
        end
    end
    return target
end

-- NOCLIP LOOP
connections.NoclipLoop = RunService.Stepped:Connect(function()
    if states.noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)

connections.MainLoop = RunService.RenderStepped:Connect(function()
    flyBtn.Text = "Fly: "..(states.flying and "ON" or "OFF")
    noclipBtn.Text = "Noclip: "..(states.noclip and "ON" or "OFF")
    infBtn.Text = "InfJump: "..(states.infJump and "ON" or "OFF")
    aimBtn.Text = "Aimbot: "..(states.aimbotEnabled and "ON" or "OFF")
    espBtn.Text = "ESP: "..(states.espEnabled and "ON" or "OFF")
    tracerBtn.Text = "Tracers: "..(states.tracersEnabled and "ON" or "OFF")
    nameBtn.Text = "Names: "..(states.namesEnabled and "ON" or "OFF")

    FOVCircle.Visible = states.aimbotEnabled
    FOVCircle.Radius = settings.aimFOV
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Color = currentESPColor

    -- FLY
    local char = player.Character
    if states.flying and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not hrp:FindFirstChild("LFlyVel") then
            local bv = Instance.new("BodyVelocity", hrp); bv.Name = "LFlyVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            local bg = Instance.new("BodyGyro", hrp); bg.Name = "LFlyGyro"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        end
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        hrp.LFlyVel.Velocity = moveDir * settings.flySpeed
        hrp.LFlyGyro.CFrame = camera.CFrame
        char.Humanoid.PlatformStand = true
    else
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart:FindFirstChild("LFlyVel") then char.HumanoidRootPart.LFlyVel:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("LFlyGyro") then char.HumanoidRootPart.LFlyGyro:Destroy() end
            char.Humanoid.PlatformStand = false
        end
    end

    -- AIMBOT LOGIC
    local isAiming = tostring(binds.aimKey):find("MouseButton") and UIS:IsMouseButtonPressed(binds.aimKey) or UIS:IsKeyDown(binds.aimKey)
    if states.aimbotEnabled and isAiming then
        local target = getClosest()
        if target then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), 1/settings.aimSmoothness) end
    end

    -- VISUALS LOOP & CLEANUP (SİLEN KISIM BURASI)
    for name, line in pairs(tracerLines) do
        local p = Players:FindFirstChild(name)
        if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            line:Remove()
            tracerLines[name] = nil
        end
    end
    for name, tag in pairs(nameTags) do
        local p = Players:FindFirstChild(name)
        if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            tag:Remove()
            nameTags[name] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            -- ESP Highlight
            local h = p.Character:FindFirstChild("LurshH")
            if states.espEnabled then
                if not h then h = Instance.new("Highlight", p.Character) h.Name = "LurshH" end
                h.FillColor = currentESPColor
            elseif h then h:Destroy() end

            -- Tracer Drawing
            if not tracerLines[p.Name] then tracerLines[p.Name] = createDrawing("Line", {Thickness = 1.5, Visible = false}) end
            local line = tracerLines[p.Name]
            if states.tracersEnabled and onScreen then
                line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Color = currentESPColor
                line.Visible = true
            else line.Visible = false end

            -- Nametag Drawing
            if not nameTags[p.Name] then nameTags[p.Name] = createDrawing("Text", {Size = 14, Center = true, Outline = true, Visible = false}) end
            local tag = nameTags[p.Name]
            if states.namesEnabled and onScreen then
                local headPos = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                tag.Position = Vector2.new(headPos.X, headPos.Y)
                tag.Text = p.Name .. " [" .. math.floor(p.Character.Humanoid.Health) .. "]"
                tag.Color = currentESPColor
                tag.Visible = true
            else tag.Visible = false end
        end
    end
end)

-- INPUTS
UIS.InputBegan:Connect(function(input, gpe)
    if bindingTarget then
        binds[bindingTarget] = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
        for _,v in pairs(bindPage:GetChildren()) do if v:IsA("TextButton") and v.Text == "..." then v.Text = tostring(binds[bindingTarget]):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "") end end
        bindingTarget = nil return
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then screen.Enabled = not screen.Enabled end
    if not gpe then
        if input.KeyCode == binds.flying then states.flying = not states.flying end
        if input.KeyCode == binds.noclip then states.noclip = not states.noclip end
        if input.KeyCode == binds.infJump then states.infJump = not states.infJump end
        if input.KeyCode == binds.savePos then savedPosition = player.Character.HumanoidRootPart.CFrame statusLabel.Text = "Saved!" end
        if input.KeyCode == binds.tpPos and savedPosition then player.Character.HumanoidRootPart.CFrame = savedPosition end
    end
end)

UIS.JumpRequest:Connect(function() if states.infJump and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
