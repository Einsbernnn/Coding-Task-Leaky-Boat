-- File: CountAssignment.server.lua

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("OpenGatesEvent")
local gatesFolder = workspace:WaitForChild("Gates")

-- Get the parts
local leftGate = gatesFolder:WaitForChild("GateLeft"):WaitForChild("Gate")
	:WaitForChild("door"):WaitForChild("Union")
local rightGate = gatesFolder:WaitForChild("GateRight"):WaitForChild("Gate")
	:WaitForChild("door"):WaitForChild("Union")

-- Target positions
local leftTarget = Vector3.new(159.459, 10.539, -43.653)
local rightTarget = Vector3.new(159.459, 10.456, 65.786)
local slideTime = 2
local tweenInfo = TweenInfo.new(slideTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Function to slide a part
local function slide(part, goalPosition)
	if not part:IsA("BasePart") or not part.Anchored then
		warn("Invalid or unanchored part:", part:GetFullName())
		return
	end

	part.CanCollide = false
	local tween = TweenService:Create(part, tweenInfo, { Position = goalPosition })
	tween:Play()
	tween.Completed:Connect(function()
		part.CanCollide = true
	end)
end

-- Triggered from client after countdown
event.OnServerEvent:Connect(function(player)
	print("✅ Countdown finished — opening gates!")
	slide(leftGate, leftTarget)
	slide(rightGate, rightTarget)
end)