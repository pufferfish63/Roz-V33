-- ROZ V37 Full Script

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- AntiLag function
local function antiLag(level)
    -- Remove particles
    for _, particle in pairs(workspace:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Trail") or particle:IsA("Beam") then
            particle.Enabled = false
        end
    end

    -- Simplify lighting
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.new(1,1,1)

    -- FPS boost (switchable)
    if level == 60 then
        settings().Rendering.QualityLevel = "Level01"
        RunService:Set3dRenderingEnabled(true)
    elseif level == 90 then
        settings().Rendering.QualityLevel = "Level02"
        RunService:Set3dRenderingEnabled(true)
    else
        settings().Rendering.QualityLevel = "Level03"
        RunService:Set3dRenderingEnabled(true)
    end
end

-- Aimbot (basic fixed)
local aimbotEnabled = false
local aimPartName = "HumanoidRootPart"
local aimRadius = 40

local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPartName) then
            local pos = player.Character[aimPartName].Position
            local dist = (pos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist and dist <= aimRadius then
                shortestDist = dist
                closest = player
            end
        end
    end
    return closest
end

-- Aura effect toggle
local auraEnabled = false
local auraPart = nil

local function createAura()
    if auraPart then auraPart:Destroy() end
    auraPart = Instance.new("SelectionBox")
    auraPart.Adornee = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    auraPart.Color3 = Color3.new(1, 0, 0)
    auraPart.LineThickness = 0.1
    auraPart.SurfaceTransparency = 0.8
    auraPart.Parent = workspace
end

local function removeAura()
    if auraPart then
        auraPart:Destroy()
        auraPart = nil
    end
end

-- Visual attack effect (Saitama only)
local function visualAttack()
    if LocalPlayer.Character and LocalPlayer.Character.Name:lower():find("saitama") then
        local part = Instance.new("Part")
        part.Size = Vector3.new(5,5,5)
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.new(1,1,0)
        part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        part.Transparency = 0.5
        part.Parent = workspace
        game.Debris:AddItem(part, 2)
    end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ROZ_V37_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 20, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.6
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Goku Image
local GokuImage = Instance.new("ImageLabel")
GokuImage.Size = UDim2.new(0, 60, 0, 60)
GokuImage.Position = UDim2.new(0, 10, 0, 10)
GokuImage.BackgroundTransparency = 1
GokuImage.Image = "rbxassetid://11764264685" -- Goku picture asset id
GokuImage.Parent = MainFrame

-- Header Label
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -80, 0, 60)
Header.Position = UDim2.new(0, 80, 0, 10)
Header.BackgroundTransparency = 1
Header.Text = "ROZ V37 - King of the Monarch"
Header.TextColor3 = Color3.fromRGB(255, 215, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

-- Warning / Credit Label
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -20, 0, 40)
CreditLabel.Position = UDim2.new(0, 10, 1, -50)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Warning: Do not abuse!\nCredit: ROZ & King Monarch"
CreditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.TextSize = 14
CreditLabel.TextWrapped = true
CreditLabel.TextXAlignment = Enum.TextXAlignment.Center
CreditLabel.TextYAlignment = Enum.TextYAlignment.Center
CreditLabel.Parent = MainFrame

-- Toggle Button Template function
local function createToggle(text, position, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = position
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 30)
    toggleBtn.Position = UDim2.new(1, -70, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(34,139,34) -- green on
    toggleBtn.Text = "ON"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 16
    toggleBtn.Parent = frame

    local toggled = true

    local function updateToggle()
        if toggled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(34,139,34) -- green
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(184,134,11) -- goldenrod
            toggleBtn.Text = "OFF"
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        callback(toggled)
    end)

    updateToggle()
    return frame, toggleBtn
end

-- UI Toggles and functions
local fpsLevel = 60
local antiLagOn = true
local aimbotOn = false
local auraOn = false
local visualAttackOn = false

-- FPS toggle
createToggle("FPS Boost 60 / 90", UDim2.new(0, 10, 0, 80), function(state)
    if state then
        fpsLevel = 90
    else
        fpsLevel = 60
    end
    antiLag(fpsLevel)
end)

-- AntiLag toggle
createToggle("Extreme AntiLag", UDim2.new(0, 10, 0, 130), function(state)
    antiLagOn = state
    if antiLagOn then
        antiLag(fpsLevel)
    else
        -- Reset Lighting to default if disabled
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 1000
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        RunService:Set3dRenderingEnabled(true)
    end
end)

-- Aimbot toggle
createToggle("Aimbot", UDim2.new(0, 10, 0, 180), function(state)
    aimbotOn = state
end)

-- Aura toggle
createToggle("Aura Effect", UDim2.new(0, 10, 0, 230), function(state)
    auraOn = state
    if auraOn then createAura() else removeAura() end
end)

-- Visual Attack toggle
createToggle("Visual Attack (Saitama)", UDim2.new(0, 10, 0, 280), function(state)
    visualAttackOn = state
end)

-- Show/Hide UI Button
local showUI = true
local showHideBtn = Instance.new("TextButton")
showHideBtn.Size = UDim2.new(0, 100, 0, 30)
showHideBtn.Position = UDim2.new(0, 20, 0, 460)
showHideBtn.BackgroundColor3 = Color3.fromRGB(184,134,11)
showHideBtn.Font = Enum.Font.GothamBold
showHideBtn.TextColor3 = Color3.new(1,1,1)
showHideBtn.TextSize = 16
showHideBtn.Text = "Hide UI"
showHideBtn.Parent = ScreenGui

showHideBtn.MouseButton1Click:Connect(function()
    showUI = not showUI
    MainFrame.Visible = showUI
    if showUI then
        showHideBtn.Text = "Hide UI"
    else
        showHideBtn.Text = "Show UI"
    end
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    if antiLagOn then
        antiLag(fpsLevel)
    end

    if aimbotOn then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Aim smoothly toward target
                local targetPos = target.Character.HumanoidRootPart.Position
                local currentPos = Mouse.Hit.p
                local direction = (targetPos - currentPos).Unit
                local newPos = currentPos + direction * 1000
                Mouse.Hit = CFrame.new(newPos)
            end
        end
    end

    if auraOn then
        if not auraPart then createAura() end
    else
        removeAura()
    end

    if visualAttackOn then
        visualAttack()
    end
end)
