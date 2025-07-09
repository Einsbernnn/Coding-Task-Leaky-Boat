-- File: CountdownUI.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local countdownGui = Instance.new("ScreenGui")
countdownGui.Name = "MKCountdownGui"
countdownGui.ResetOnSpawn = false
countdownGui.Parent = player:WaitForChild("PlayerGui")

-- Centered label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Position = UDim2.new(0.5, 0, 0.5, 0)
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.FredokaOne
label.TextStrokeTransparency = 0.2
label.TextStrokeColor3 = Color3.new(0, 0, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.Text = ""
label.Parent = countdownGui

-- Mario Kart countdown full audio
local fullSound = SoundService:FindFirstChild("CountdownSounds") -- It's a single Sound object

-- Pop animation
local function pop()
	local scaleTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	label.Size = UDim2.new(1, 0, 1, 0)
	local tween = TweenService:Create(label, scaleTweenInfo, {
		Size = UDim2.new(1.1, 0, 1.1, 0)
	})
	tween:Play()
end

-- Show simple visual countdown while audio plays
local function showCountdown(callback)
	local countdown = {
		{ text = "3", color = Color3.fromRGB(255, 0, 0) },
		{ text = "2", color = Color3.fromRGB(255, 153, 0) },
		{ text = "1", color = Color3.fromRGB(255, 255, 0) },
		{ text = "GO!", color = Color3.fromRGB(0, 255, 0) },
	}

	if fullSound and fullSound:IsA("Sound") then
		fullSound:Play()
	end

	for _, entry in ipairs(countdown) do
		label.Text = entry.text
		label.TextColor3 = entry.color
		pop()
		wait(1)
	end

	countdownGui:Destroy()

	if callback then callback() end
end

-- Start countdown
showCountdown(function()
	local event = ReplicatedStorage:FindFirstChild("OpenGatesEvent")
	if event and event:IsA("RemoteEvent") then
		event:FireServer()
	else
		warn("OpenGatesEvent not found!")
	end
end)