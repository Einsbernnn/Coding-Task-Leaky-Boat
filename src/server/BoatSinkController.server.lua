-- ServerScript: BoatSinkController.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local clickEvent = ReplicatedStorage:WaitForChild("MaterialClickedEvent")
local boatFolder = workspace:WaitForChild("Boats")

local playerData = {}

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

	task.spawn(function()
		for i = 1, 200 do
			if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then break end
			if data.correctClicks >= 4 then break end

			primaryPart.Position -= Vector3.new(0, 0.05 * data.sinkRate, 0)

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

	if isCorrect then
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

		-- Apply boost
		local boat = data.boat
		if boat and boat.PrimaryPart then
			local velocity = Vector3.new(-1, 0, 0) * (20 + data.correctClicks * 5)
			boat.PrimaryPart.AssemblyLinearVelocity = velocity
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