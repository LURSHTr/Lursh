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
local states = { flying = false, noclip = false, infJump = false, espEnabled = false, tracersEnabled = false, namesEnabled = false }
local binds = { 
    flying = Enum.KeyCode.F, 
    noclip = Enum.KeyCode.N, 
    infJump = Enum.KeyCode.J,
    savePos = Enum.KeyCode.K,
    tpPos = Enum.KeyCode.L
}
local settings = { walkSpeed = 16, jumpPower = 50, flySpeed = 50 }
local currentESPColor = Color3.fromRGB(175, 238, 238)
local iceBlue = Color3.fromRGB(175, 238, 238)
local bindingTarget = nil

------------------------------------------------
-- GUI SETUP
------------------------------------------------
local screen = Instance.new("ScreenGui")
screen.Name = "LurshPremiumV3_Full"
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
title.Text = "LURSH PREMIUM V3 (FIXED)"
title.TextColor3 = iceBlue
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Sürükleme
local dragging, dragStart, startPos
connections.DragStart = topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = mainFrame.Position end end)
connections.DragChange = UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
connections.DragEnd = UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

------------------------------------------------
-- NAVIGATION
------------------------------------------------
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", mainFrame)
    p.Size = UDim2.new(1, 0, 1, -110)
    p.Position = UDim2.new(0, 0, 0, 95)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    
    local b = Instance.new("TextButton", tabFrame)
    b.Size = UDim2.new(0, 80, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
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
local tpPage = createPage("TP")
mainPage.Visible = true

------------------------------------------------
-- HELPERS (SLIDERS & BUTTONS)
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
    b.Size = UDim2.new(0, 300, 0, 32)
    b.Position = UDim2.new(0.5, -150, 0, y)
    b.BackgroundColor3 = iceBlue
    b.Text = text
    b.TextColor3 = Color3.fromRGB(10, 10, 10)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end

------------------------------------------------
-- MAIN PAGE CONTENT (GERİ GELDİLER)
------------------------------------------------
createSlider(mainPage, "Walk Speed", 10, 200, 16, function(v) settings.walkSpeed = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
createSlider(mainPage, "Jump Power", 45, 300, 50, function(v) settings.jumpPower = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
createSlider(mainPage, "Fly Speed", 80, 500, 50, function(v) settings.flySpeed = v end)

local flyBtn = createBtn("Fly: OFF", 120, mainPage, function() states.flying = not states.flying end)
local noclipBtn = createBtn("Noclip: OFF", 160, mainPage, function() states.noclip = not states.noclip end)
local infBtn = createBtn("InfJump: OFF", 200, mainPage, function() states.infJump = not states.infJump end)

createBtn("CLOSE GUI (UNLOAD)", 340, mainPage, function() 
    for _, conn in pairs(connections) do if conn then conn:Disconnect() end end
    for _, line in pairs(tracerLines) do line:Remove() end
    for _, tag in pairs(nameTags) do tag:Remove() end
    screen:Destroy()
end)

------------------------------------------------
-- VISUALS PAGE CONTENT
------------------------------------------------
local espBtn = createBtn("ESP: OFF", 10, visualsPage, function() states.espEnabled = not states.espEnabled end)
local tracerBtn = createBtn("Tracers: OFF", 50, visualsPage, function() states.tracersEnabled = not states.tracersEnabled end)
local nameBtn = createBtn("Nametags: OFF", 90, visualsPage, function() states.namesEnabled = not states.namesEnabled end)

local colorGrid = Instance.new("Frame", visualsPage)
colorGrid.Size = UDim2.new(0, 300, 0, 45)
colorGrid.Position = UDim2.new(0.5, -150, 0, 140)
colorGrid.BackgroundTransparency = 1
Instance.new("UIListLayout", colorGrid).FillDirection = Enum.FillDirection.Horizontal
colorGrid.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorGrid.UIListLayout.Padding = UDim.new(0, 8)

local palette = {Color3.fromRGB(175, 238, 238), Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 255, 50), Color3.fromRGB(255, 255, 50), Color3.fromRGB(255, 50, 255), Color3.fromRGB(255, 255, 255)}
for _, color in pairs(palette) do
    local cBtn = Instance.new("TextButton", colorGrid)
    cBtn.Size = UDim2.new(0, 35, 0, 35)
    cBtn.BackgroundColor3 = color
    cBtn.Text = ""
    Instance.new("UICorner", cBtn)
    cBtn.MouseButton1Click:Connect(function() currentESPColor = color end)
end

------------------------------------------------
-- TP PAGE CONTENT
------------------------------------------------
local function savePosFunc()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = player.Character.HumanoidRootPart.CFrame
        return true
    end
    return false
end

local function tpPosFunc()
    if savedPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = savedPosition
        return true
    end
    return false
end

local statusLabel = Instance.new("TextLabel", tpPage)
statusLabel.Size = UDim2.new(0, 300, 0, 30)
statusLabel.Position = UDim2.new(0.5, -150, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "No Position Saved"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12

createBtn("SAVE CURRENT POS", 50, tpPage, function() 
    if savePosFunc() then 
        statusLabel.Text = "Saved Waypoint!" 
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50) 
    end 
end)

createBtn("TELEPORT TO SAVED", 95, tpPage, function() 
    if not tpPosFunc() then 
        statusLabel.Text = "Error: No Waypoint!" 
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50) 
    end 
end)

createBtn("DELETE WAYPOINT", 140, tpPage, function() 
    savedPosition = nil 
    statusLabel.Text = "Position Deleted" 
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 50) 
end)

------------------------------------------------
-- BIND PAGE CONTENT
------------------------------------------------
local function createBind(text, y, keyName)
    local label = Instance.new("TextLabel", bindPage)
    label.Size = UDim2.new(0, 150, 0, 30)
    label.Position = UDim2.new(0, 40, 0, y)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bBox = Instance.new("TextButton", bindPage)
    bBox.Size = UDim2.new(0, 100, 0, 30)
    bBox.Position = UDim2.new(0, 200, 0, y)
    bBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bBox.Text = binds[keyName].Name
    bBox.TextColor3 = iceBlue
    bBox.TextSize = 11
    Instance.new("UICorner", bBox)

    bBox.MouseButton1Click:Connect(function()
        bindingTarget = keyName
        bBox.Text = "..."
    end)
end

createBind("Fly Toggle", 10, "flying")
createBind("Noclip Toggle", 45, "noclip")
createBind("InfJump Toggle", 80, "infJump")
createBind("Save Waypoint", 115, "savePos")
createBind("TP to Waypoint", 150, "tpPos")

------------------------------------------------
-- LOGICS & LOOPS
------------------------------------------------
local function getDrawing(p, type)
    if type == "Line" then
        if tracerLines[p.Name] then return tracerLines[p.Name] end
        local l = Drawing.new("Line") l.Visible = false l.Thickness = 1.5; tracerLines[p.Name] = l; return l
    else
        if nameTags[p.Name] then return nameTags[p.Name] end
        local t = Drawing.new("Text") t.Visible = false t.Center = true t.Outline = true t.Size = 14; nameTags[p.Name] = t; return t
    end
end

local bv, bg
connections.MainLoop = RunService.RenderStepped:Connect(function()
    -- UI Refresh
    flyBtn.Text = "Fly: "..(states.flying and "ON" or "OFF")
    noclipBtn.Text = "Noclip: "..(states.noclip and "ON" or "OFF")
    infBtn.Text = "InfJump: "..(states.infJump and "ON" or "OFF")
    espBtn.Text = "ESP: "..(states.espEnabled and "ON" or "OFF")
    tracerBtn.Text = "Tracers: "..(states.tracersEnabled and "ON" or "OFF")
    nameBtn.Text = "Nametags: "..(states.namesEnabled and "ON" or "OFF")

    local char = player.Character
    if states.flying and char and char:FindFirstChild("HumanoidRootPart") then
        if not bv then
            bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bg = Instance.new("BodyGyro", char.HumanoidRootPart)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9) bv.MaxForce = Vector3.new(9e9,9e9,9e9)
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

    -- Visuals Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            -- ESP
            local h = p.Character:FindFirstChild("LurshESP")
            if states.espEnabled then
                if not h then h = Instance.new("Highlight", p.Character) h.Name = "LurshESP" end
                h.FillColor = currentESPColor
            elseif h then h:Destroy() end

            -- Tracers
            local line = getDrawing(p, "Line")
            if states.tracersEnabled and onScreen then
                line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Color = currentESPColor
                line.Visible = true
            else line.Visible = false end

            -- Nametags
            local tag = getDrawing(p, "Text")
            if states.namesEnabled and onScreen then
                local headPos = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0))
                tag.Position = Vector2.new(headPos.X, headPos.Y)
                tag.Text = p.Name .. " [" .. math.floor(hum.Health) .. "]"
                tag.Color = currentESPColor
                tag.Visible = true
            else tag.Visible = false end
        else
            if tracerLines[p.Name] then tracerLines[p.Name].Visible = false end
            if nameTags[p.Name] then nameTags[p.Name].Visible = false end
        end
    end
end)

------------------------------------------------
-- INPUTS & CLEANUP
------------------------------------------------
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
    if input.KeyCode == Enum.KeyCode.LeftControl then screen.Enabled = not screen.Enabled end
    if not gpe then
        if input.KeyCode == binds.flying then states.flying = not states.flying end
        if input.KeyCode == binds.noclip then states.noclip = not states.noclip end
        if input.KeyCode == binds.infJump then states.infJump = not states.infJump end
        if input.KeyCode == binds.savePos then savePosFunc() end
        if input.KeyCode == binds.tpPos then tpPosFunc() end
    end
end)

connections.InfJump = UIS.JumpRequest:Connect(function()
    if states.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if tracerLines[p.Name] then tracerLines[p.Name]:Remove() tracerLines[p.Name] = nil end
    if nameTags[p.Name] then nameTags[p.Name]:Remove() nameTags[p.Name] = nil end
end)
