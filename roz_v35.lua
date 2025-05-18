-- ROZ V35 UI by King of the Monarch
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleUIBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

local fpsToggle = Instance.new("TextButton")
local aimbotToggle = Instance.new("TextButton")
local antilagToggle = Instance.new("TextButton")

local isUIVisible = true
local fpsEnabled = false
local aimbotEnabled = false
local antilagEnabled = false

-- Gui setup
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ROZ_V35_UI"

MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ROZ V35"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Parent = MainFrame

ToggleUIBtn.Size = UDim2.new(0, 80, 0, 25)
ToggleUIBtn.Position = UDim2.new(0, 220, 0.2, 0)
ToggleUIBtn.Text = "Toggle UI"
ToggleUIBtn.Parent = ScreenGui

fpsToggle.Size = UDim2.new(1, -20, 0, 30)
fpsToggle.Position = UDim2.new(0, 10, 0, 50)
fpsToggle.Text = "FPS Boost: OFF"
fpsToggle.Parent = MainFrame

aimbotToggle.Size = UDim2.new(1, -20, 0, 30)
aimbotToggle.Position = UDim2.new(0, 10, 0, 90)
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.Parent = MainFrame

antilagToggle.Size = UDim2.new(1, -20, 0, 30)
antilagToggle.Position = UDim2.new(0, 10, 0, 130)
antilagToggle.Text = "AntiLag: OFF"
antilagToggle.Parent = MainFrame

-- Toggle UI button function
ToggleUIBtn.MouseButton1Click:Connect(function()
	isUIVisible = not isUIVisible
	MainFrame.Visible = isUIVisible
end)

-- FPS Toggle
fpsToggle.MouseButton1Click:Connect(function()
	fpsEnabled = not fpsEnabled
	if fpsEnabled then
		fpsToggle.Text = "FPS Boost: ON"
		-- Simulate 90 FPS: Disable effects, shadows, etc.
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	else
		fpsToggle.Text = "FPS Boost: OFF"
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	end
end)

-- Aimbot Toggle (placeholder)
aimbotToggle.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimbotToggle.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
	-- Insert aimbot logic here
end)

-- AntiLag Toggle
antilagToggle.MouseButton1Click:Connect(function()
	antilagEnabled = not antilagEnabled
	if antilagEnabled then
		antilagToggle.Text = "AntiLag: ON"
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
				obj.Enabled = false
			end
		end
		lighting = game:GetService("Lighting")
		lighting.Brightness = 1
		lighting.GlobalShadows = false
	else
		antilagToggle.Text = "AntiLag: OFF"
	end
end)
