-- ROZ V3 Antilag + UI | Strongest Battlegrounds Only
if game.PlaceId == 11349125039 then
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer

    -- Create UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ROZV3_UI"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.Position = UDim2.new(0.35, 0, 0.4, 0)
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Position = UDim2.new(0.1, 0, 0.3, 0)
    Button.Size = UDim2.new(0.8, 0, 0.4, 0)
    Button.Text = "Activate Antilag"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextScaled = true
    Button.Parent = Frame

    local antlagActivated = false

    Button.MouseButton1Click:Connect(function()
        if antlagActivated then
            return
        end
        antlagActivated = true

        -- Antilag Boost: Destroy heavy effects
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") then
                v:Destroy()
            end
        end

        -- Lighting tweaks
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0

        Button.Text = "Antilag Activated"
        Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end)
else
    warn("ROZ V3 UI: This script only runs in Strongest Battlegrounds.")
end
