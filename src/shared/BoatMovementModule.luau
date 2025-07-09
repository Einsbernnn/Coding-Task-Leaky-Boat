-- BoatMovementModule.luau

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local BoatMovement = {}
BoatMovement.OnBoatFinish = Instance.new("BindableEvent")

local raceDuration = 40
local finishLineZ = 18.841
local finishZOffsets = {
	[1] = -30,
	[2] = -10,
	[3] = 10,
	[4] = 30
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

function BoatMovement.StartBoat(boatModel, player)
	if not boatModel or not boatModel:IsA("Model") or not getMainPart(boatModel) then
		warn("[BoatMovement] Invalid boat model provided to StartBoat.")
		return
	end

	local startCFrame = boatModel:GetPivot()
	local startPos = startCFrame.Position
	local boatIndex = tonumber(string.match(boatModel.Name, "_(%d+)$")) or 1
	local baseDistance = 100
	local zOffset = finishZOffsets[boatIndex] or 0
	local totalDistance = baseDistance + zOffset

	local progress = Instance.new("NumberValue")
	progress.Value = 0
	boatProgressValues[boatModel] = progress

	local duration = raceDuration
	boatTargetTimes[boatModel] = duration
	boatStartTimes[boatModel] = tick()

	local tween = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Value = 1 })
	boatTweens[boatModel] = tween

	local finished = false
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = progress.Value
		local forwardOffset = totalDistance * alpha
		local newCFrame = startCFrame * CFrame.new(0, 0, forwardOffset)
		boatModel:PivotTo(newCFrame)

		-- Finish detection
		if not finished then
			local mainPart = getMainPart(boatModel)
			if mainPart and math.abs(mainPart.Position.Z - finishLineZ) < 2 then
				finished = true
				BoatMovement.OnBoatFinish:Fire(player)
			end
		end
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		progress:Destroy()
		boatTweens[boatModel] = nil
		boatProgressValues[boatModel] = nil
		boatStartTimes[boatModel] = nil
		boatTargetTimes[boatModel] = nil
	end)

	tween:Play()
end

function BoatMovement.ApplyBoatSpeedBoost(boatModel, percentBoost)
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

	local currentValue = progress.Value
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
	end)
	newTween:Play()
end

return BoatMovement 