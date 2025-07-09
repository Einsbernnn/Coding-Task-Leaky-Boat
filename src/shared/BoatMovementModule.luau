-- BoatMovementModule.luau
-- This module is the single source of truth for boat movement and speed boost logic.
-- Used by both BoatSinkController and BoatMovement server scripts.

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local boatsFolder = Workspace:WaitForChild("Boats")
local finishLine = Workspace:WaitForChild("FinishLine")

local raceDuration = 40

local finishZOffsets = {
	[1] = -30, -- Boat_1
	[2] = -10, -- Boat_2
	[3] = 10,  -- Boat_3
	[4] = 30   -- Boat_4
}

local boatTweens = {}
local boatProgressValues = {}
local boatStartTimes = {}
local boatTargetTimes = {}

local function getMainPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then return p end
	end
	return nil
end

local function moveBoatModel(boatModel, finishTargetPos, player, onFinish)
	print("[DEBUG] moveBoatModel called for:", boatModel and boatModel.Name or "nil")
	if not boatModel then print("[ERROR] boatModel is nil!") return end
	if not boatModel.PrimaryPart then print("[ERROR] PrimaryPart missing for boat:", boatModel.Name) return end
	local startCFrame = boatModel:GetPivot()
	local startPos = startCFrame.Position
	local finishPos = Vector3.new(finishTargetPos.X, startPos.Y, finishTargetPos.Z)
	local direction = (finishPos - startPos).Unit
	local distance = (finishPos - startPos).Magnitude

	local progress = Instance.new("NumberValue")
	progress.Value = 0
	boatProgressValues[boatModel] = progress

	local duration = raceDuration
	boatTargetTimes[boatModel] = duration
	boatStartTimes[boatModel] = tick()

	print("[DEBUG] Creating tween for boat:", boatModel.Name, "duration:", duration)
	local tween = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Value = 1 })
	boatTweens[boatModel] = tween

	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = progress.Value
		local currentPos = startPos + direction * distance * alpha
		local newCFrame = CFrame.new(currentPos, currentPos + direction)
		boatModel:PivotTo(newCFrame)
		-- Force zero velocity to override water/physics
		if boatModel.PrimaryPart then
			boatModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			boatModel.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
		end
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		progress:Destroy()
		boatTweens[boatModel] = nil
		boatProgressValues[boatModel] = nil
		boatStartTimes[boatModel] = nil
		boatTargetTimes[boatModel] = nil
		print("✅", boatModel.Name, "reached target.")
		if onFinish then onFinish(boatModel, player) end
	end)

	print("[DEBUG] Playing tween for boat:", boatModel.Name)
	tween:Play()
	print("🚤", boatModel.Name, "started moving.")
end

local function ApplyBoatSpeedBoost(boatModel, percentBoost)
	local progress = boatProgressValues[boatModel]
	local tween = boatTweens[boatModel]
	if not progress or not tween then return end

	local elapsed = tick() - (boatStartTimes[boatModel] or 0)
	local oldTarget = boatTargetTimes[boatModel] or raceDuration
	local remaining = oldTarget - elapsed
	if remaining <= 0 then return end

	local newRemaining = math.max(remaining * (1 - percentBoost), 2)
	boatTargetTimes[boatModel] = elapsed + newRemaining

	tween:Cancel()

	local newTween = TweenService:Create(progress, TweenInfo.new(newRemaining, Enum.EasingStyle.Linear), { Value = 1 })
	boatTweens[boatModel] = newTween
	newTween.Completed:Connect(function()
		if boatProgressValues[boatModel] then
			boatProgressValues[boatModel]:Destroy()
			boatProgressValues[boatModel] = nil
		end
		boatTweens[boatModel] = nil
		boatStartTimes[boatModel] = nil
		boatTargetTimes[boatModel] = nil
		print("✅", boatModel.Name, "reached target (boosted).")
	end)
	newTween:Play()
end

local function StartAllBoats(onFinish)
	print("[DEBUG] StartAllBoats called")
	for i = 1, 4 do
		local boat = boatsFolder:FindFirstChild("Boat_" .. i)
		if boat then
			print("[DEBUG] Found boat:", boat.Name)
			local finishPart = getMainPart(finishLine)
			if finishPart then
				local offsetZ = finishZOffsets[i] or 0
				local targetPos = finishPart.Position + Vector3.new(0, 0, offsetZ)
				moveBoatModel(boat, targetPos, nil, onFinish)
			else
				warn("❌ FinishLine part not found.")
			end
		else
			warn("🚫 Missing Boat_" .. i)
		end
	end
end

return {
	moveBoatModel = moveBoatModel,
	ApplyBoatSpeedBoost = ApplyBoatSpeedBoost,
	StartAllBoats = StartAllBoats
} 