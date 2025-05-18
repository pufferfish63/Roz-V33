-- ROZ V34 - King of the Monarch Edition
-- Custom Green & Gold UI with FPS Boost, Aimbot, Cleaner, Fun Modes

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")

-- Button template
local function createButton(name, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = Frame
    btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Green
    btn.Position = UDim2.new(0.1, 0, yPos, 0)
    btn.Size = UDim2.new(0.8, 0, 0.08, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    local corner = Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

ScreenGui.Name = "ROZV34"
ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold
Frame.Position = UDim2.new(0.7, 0, 0.2, 0)
Frame.Size = UDim2.new(0.28, 0, 0.65, 0)
UICorner.Parent = Frame

Title.Parent = Frame
Title.Text = "ROZ V34 UI"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextScaled = true
Title.BackgroundTransparency = 1

-- BUTTONS & CALLBACKS

createButton("FPS60", "Set FPS to 60", 0.12, function()
    setfpscap(60)
end)

createButton("FPS90", "Set FPS to 90", 0.22, function()
    setfpscap(90)
end)

createButton("Aimbot", "Toggle Aimbot", 0.32, function()
    -- Sample aimbot (simple lock-on)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local function getClosest()
        local closest, dist = nil, math.huge
        for i,v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local diff = (v.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if diff < dist then
                    dist = diff
                    closest = v
                end
            end
        end
        return closest
    end
    mouse.Button2Down:Connect(function()
        local target = getClosest()
        if target then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, target.Character.HumanoidRootPart.Position)
        end
    end)
end)

createButton("Cleaner", "Remove Particles", 0.42, function()
    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
            v:Destroy()
        end
    end
end)

createButton("Effects", "Cleanup Effects", 0.52, function()
    game.Lighting.FogEnd = 100000
    game.Lighting.Brightness = 2
    game.Lighting.GlobalShadows = false
end)

createButton("Jump", "High Jump", 0.62, function()
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = 120
end)

createButton("Speed", "Speed Boost", 0.72, function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 80
end)

createButton("Spinbot", "Spinbot ON", 0.82, function()
    local char = game.Players.LocalPlayer.Character
    while wait() do
        char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(30), 0))
    end
end)

createButton("Noclip", "Noclip Toggle", 0.92, function()
    local player = game.Players.LocalPlayer
    game:GetService("RunService").Stepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end)
