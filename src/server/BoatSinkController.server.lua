-- ServerScript: BoatSinkController.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local clickEvent = ReplicatedStorage:WaitForChild("MaterialClickedEvent")
local boatFolder = workspace:WaitForChild("Boats")

local playerData = {}

local BoatMovement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BoatMovementModule"))

-- Initialize player data
local function initPlayer(player)
	playerData[player] = {
		correctClicks = 0,
		sinkRate = 1,
		speedBoost = 0,
		boat = nil
	}

	-- Create GUI-linked values
	local sinkRateVal = Instance.new("NumberValue")
	sinkRateVal.Name = "SinkRate"
	sinkRateVal.Value = 1
	sinkRateVal.Parent = player

	local correctVal = Instance.new("IntValue")
	correctVal.Name = "CorrectMaterials"
	correctVal.Value = 0
	correctVal.Parent = player
end

-- Sinking logic
local function startSinking(player)
	local data = playerData[player]
	local boat = data.boat
	if not boat then return end

	local primaryPart = boat.PrimaryPart
	if not primaryPart then return end

	-- Sinking parameters
	local totalSinkTime = 20 -- seconds to fully sink if no action
	local sinkSteps = 200    -- 0.1s per step
	local sinkPerStep = 1 / sinkSteps -- percent per step
	local baseSinkRate = 0.05 -- base Y offset per step

	task.spawn(function()
		for i = 1, sinkSteps do
			if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then break end
			if data.correctClicks >= 4 then break end

			-- Sinking rate decreases as correctClicks increases
			local rate = math.max(0.2, data.sinkRate)
			primaryPart.Position -= Vector3.new(0, baseSinkRate * rate, 0)

			task.wait(0.1)
		end

		if data.correctClicks < 4 and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.Health = 0 -- player drowns
		end
	end)
end

-- Material button clicked
clickEvent.OnServerEvent:Connect(function(player, material, isCorrect)
	local data = playerData[player]
	if not data then return end

	if isCorrect and data.correctClicks < 4 then
		data.correctClicks += 1
		data.sinkRate = math.max(0.2, data.sinkRate - 0.2)

		-- Update GUI values
		local sinkVal = player:FindFirstChild("SinkRate")
		if sinkVal then
			sinkVal.Value = data.sinkRate
		end

		local correctVal = player:FindFirstChild("CorrectMaterials")
		if correctVal then
			correctVal.Value = data.correctClicks
		end

		-- Apply speed boost
		local boat = data.boat
		if boat then
			BoatMovement.ApplyBoatSpeedBoost(boat, 0.25) -- 25% speed boost per correct material
			print("Speed boost applied to", boat.Name, "for player", player.Name)
		end
	end
end)

-- Boat assignment
Players.PlayerAdded:Connect(function(player)
	initPlayer(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)

		for _, boat in ipairs(boatFolder:GetChildren()) do
			if boat:GetAttribute("Owner") == player.Name then
				playerData[player].boat = boat
				break
			end
		end

		startSinking(player)
	end)
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(player)
	playerData[player] = nil
end) 