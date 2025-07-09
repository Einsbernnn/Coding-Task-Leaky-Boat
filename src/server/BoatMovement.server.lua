-- File: BoatMovementController.lua

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local boatsFolder = Workspace:WaitForChild("Boats")
local finishLine = Workspace:WaitForChild("FinishLine")

local raceDuration = 40

-- Offsets per boat to avoid overlapping at finish
local finishZOffsets = {
	[1] = -30, -- Boat_1
	[2] = -10, -- Boat_2
	[3] = 10,  -- Boat_3
	[4] = 30   -- Boat_4
}

-- Get a usable part from a model
local function getMainPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then return p end
	end
	return nil
end

-- Move a boat straight forward to a custom finish point
local function moveBoatModel(boatModel, finishTargetPos)
	local startCFrame = boatModel:GetPivot()
	local startPos = startCFrame.Position
	local finishPos = Vector3.new(finishTargetPos.X, startPos.Y, finishTargetPos.Z)
	local direction = (finishPos - startPos).Unit
	local distance = (finishPos - startPos).Magnitude

	-- Tween controller
	local progress = Instance.new("NumberValue")
	progress.Value = 0

	local tween = TweenService:Create(progress, TweenInfo.new(raceDuration, Enum.EasingStyle.Linear), { Value = 1 })

	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = progress.Value
		local currentPos = startPos + direction * distance * alpha
		local newCFrame = CFrame.new(currentPos, currentPos + startCFrame.LookVector)
		boatModel:PivotTo(newCFrame)
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		progress:Destroy()
		print("✅", boatModel.Name, "reached target.")
	end)

	tween:Play()
	print("🚤", boatModel.Name, "started moving.")
end

-- Move all boats with unique lanes
for i = 1, 4 do
	local boat = boatsFolder:FindFirstChild("Boat_" .. i)
	if boat then
		local finishPart = getMainPart(finishLine)
		if finishPart then
			local offsetZ = finishZOffsets[i] or 0
			local targetPos = finishPart.Position + Vector3.new(0, 0, offsetZ)
			moveBoatModel(boat, targetPos)
		else
			warn("❌ FinishLine part not found.")
		end
	else
		warn("🚫 Missing Boat_" .. i)
	end
end

-- ✅ Timer for debugging
task.spawn(function()
	for t = 1, raceDuration do
		wait(1)
		print("⏱️ Time:", t .. "s")
	end
end)