-- ROZ V33 Script: Antilag + Soft Aimbot for Strongest Battlegrounds
-- Made for the King of the Monarch

-- ✅ Antilag Boost (60 to 120 FPS)
local lighting = game:GetService("Lighting")
lighting.GlobalShadows = false
lighting.FogEnd = math.huge
lighting.Brightness = 0
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v:Destroy()
    end
end
sethiddenproperty(lighting, "Technology", Enum.Technology.Compatibility)

-- ✅ Aimbot Assist (Soft Lock on Nearest Enemy)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    closest = player
                    dist = mag
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
end)
