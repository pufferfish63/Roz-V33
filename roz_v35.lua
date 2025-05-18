local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- UI setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "RozV34UI"

local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.Visible = true
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0,0)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ROZ V34 - King UI"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggles = {}

local function createToggle(name, text, yPos, callback)
    local toggleFrame = Instance.new("Frame", mainFrame)
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    toggleFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16

    local button = Instance.new("TextButton", toggleFrame)
    button.Size = UDim2.new(0.3, -5, 1, 0)
    button.Position = UDim2.new(0.7, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    button.TextColor3 = Color3.new(1,1,1)
    button.Text = "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16

    local toggled = false

    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.Text = toggled and "ON" or "OFF"
        button.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
        callback(toggled)
    end)

    toggles[name] = {button = button, toggled = toggled}
end

-- Show/hide UI toggle
local toggleUIBtn = Instance.new("TextButton", ScreenGui)
toggleUIBtn.Size = UDim2.new(0, 100, 0, 30)
toggleUIBtn.Position = UDim2.new(0, 10, 0, 10)
toggleUIBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleUIBtn.TextColor3 = Color3.new(1,1,1)
toggleUIBtn.Font = Enum.Font.GothamBold
toggleUIBtn.TextSize = 16
toggleUIBtn.Text = "Toggle UI"

toggleUIBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)


-- Variables for toggles
local antiLagEnabled = false
local aimbotEnabled = false
local auraEnabled = false
local visualAttackEnabled = false

-- Anti-lag function
createToggle("AntiLag", "Anti-Lag (60/90 FPS + No Particles)", 40, function(on)
    antiLagEnabled = on
    if on then
        -- Cap FPS to 60 for anti-lag
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level1
        -- Remove particles & effects
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Explosion") then
                obj.Enabled = false
            end
        end
    else
        -- Restore quality level (optional, or keep low for lag reduction)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level5
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Explosion") then
                obj.Enabled = true
            end
        end
    end
end)

-- Aimbot basics
createToggle("Aimbot", "Aimbot (Fixed)", 80, function(on)
    aimbotEnabled = on
end)

-- Enemy Aura
local outlines = {}

createToggle("Aura", "Enemy Aura (Green Outline)", 120, function(on)
    auraEnabled = on
    if not auraEnabled then
        for _, outline in pairs(outlines) do
            if outline and outline.Parent then
                outline:Destroy()
            end
        end
        outlines = {}
    else
        spawn(function()
            while auraEnabled and wait(1) do
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                local pos = char.HumanoidRootPart.Position

                -- Cleanup outlines for players out of range
                for plrName, outline in pairs(outlines) do
                    local plr = Players:FindFirstChild(plrName)
                    if not plr or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                        outline:Destroy()
                        outlines[plrName] = nil
                    else
                        local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                        if dist > 50 then
                            outline:Destroy()
                            outlines[plrName] = nil
                        end
                    end
                end

                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                        if dist <= 50 then
                            if not outlines[plr.Name] then
                                local hrp = plr.Character.HumanoidRootPart
                                local outline = Instance.new("SelectionBox")
                                outline.Adornee = hrp
                                outline.LineThickness = 0.05
                                outline.Color3 = Color3.fromRGB(0, 255, 0)
                                outline.Parent = hrp
                                outlines[plr.Name] = outline
                            end
                        else
                            if outlines[plr.Name] then
                                outlines[plr.Name]:Destroy()
                                outlines[plr.Name] = nil
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Visual Attack only if character is "Saitama"
createToggle("VisualAttack", "Saitama Visual Attack", 160, function(on)
    visualAttackEnabled = on
end)

local function playPunchEffect(targetHRP)
    if not targetHRP then return end

    local flash = Instance.new("Part")
    flash.Shape = Enum.PartType.Ball
    flash.Material = Enum.Material.Neon
    flash.Color = Color3.new(1, 1, 0)
    flash.Transparency = 0.5
    flash.Anchored = true
    flash.CanCollide = false
    flash.Size = Vector3.new(5, 5, 5)
    flash.CFrame = targetHRP.CFrame
    flash.Parent = workspace

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {Size = Vector3.new(15, 15, 15), Transparency = 1}
    local tween = TweenService:Create(flash, tweenInfo, goal)
    tween:Play()
    tween.Completed:Connect(function()
        flash:Destroy()
    end)
end

RunService.Heartbeat:Connect(function()
    if visualAttackEnabled then
        local char = player.Character
        if char and char.Name == "Saitama" and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                    if dist <= 5 then
                        playPunchEffect(plr.Character.HumanoidRootPart)
                        -- Add damage or knockback here if your game allows
                    end
                end
            end
        end
    end
end)

-- Aimbot basic implementation
RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local closestDist = math.huge
            local targetHRP = nil
            local pos = char.HumanoidRootPart.Position
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                    if dist < closestDist and dist <= 100 then
                        closestDist = dist
                        targetHRP = plr.Character.HumanoidRootPart
                    end
                end
            end
            if targetHRP then
                -- Aim your mouse at target (simulate aimbot)
                local camera = workspace.CurrentCamera
                local screenPos, onScreen = camera:WorldToViewportPoint(targetHRP.Position)
                if onScreen then
                    mouse.Hit = CFrame.new(targetHRP.Position)
                end
            end
      end
