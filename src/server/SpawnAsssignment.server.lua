-- File: SpawnAssignment.server.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local resetCameraEvent = ReplicatedStorage:WaitForChild("ResetCameraEvent")

local boatsFolder = workspace:WaitForChild("Boats")
local assignedBoats = {}
local playerBoats = {}

-- Build list of boats (Boat_1 to Boat_4)
local boatList = {}
for i = 1, 4 do
	table.insert(boatList, boatsFolder:WaitForChild("Boat_" .. i))
end

-- Spawn function using SpawnTile
local function spawnPlayerAtBoat(player, boat)
	local function moveCharacter()
		local character = player.Character
		if not character then return end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local spawnPart = boat:FindFirstChild("SpawnTile") or boat.PrimaryPart

		if hrp and spawnPart then
			-- Teleport with orientation and vertical offset
			hrp.CFrame = spawnPart.CFrame * CFrame.new(0, 3, 0)
			print("Spawned " .. player.Name .. " at " .. spawnPart:GetFullName())

			-- Remove any existing WeldConstraint
			local existingWeld = hrp:FindFirstChild("BoatWeld")
			if existingWeld then
				existingWeld:Destroy()
			end

			-- Strictly lock player to boat using Heartbeat update
			if hrp:FindFirstChild("BoatLock") then
				hrp.BoatLock:Destroy()
			end
			local lock = Instance.new("BoolValue")
			lock.Name = "BoatLock"
			lock.Parent = hrp

			-- Prevent movement
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end

			-- Heartbeat connection to keep player on boat
			local conn
			conn = game:GetService("RunService").Heartbeat:Connect(function()
				if not lock.Parent or not hrp or not hrp.Parent or not spawnPart or not spawnPart.Parent then
					if conn then conn:Disconnect() end
					return
				end
				-- Keep player strictly above the spawnPart
				hrp.CFrame = spawnPart.CFrame * CFrame.new(0, 3, 0)
			end)

			-- Tell client to reset camera
			resetCameraEvent:FireClient(player)
		else
			warn("Missing HRP or spawn part for", player.Name)
		end
	end

	task.delay(0.2, moveCharacter)

	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.wait(0.2)
		moveCharacter()
	end)

	-- Cleanup lock on player removal
	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local lock = hrp:FindFirstChild("BoatLock")
					if lock then lock:Destroy() end
				end
			end
		end
	end)
end

-- Assignment logic
local function assignBoatToPlayer(player)
	if playerBoats[player] then
		spawnPlayerAtBoat(player, playerBoats[player])
		return
	end

	for _, boat in ipairs(boatList) do
		if not assignedBoats[boat] then
			assignedBoats[boat] = true
			playerBoats[player] = boat
			spawnPlayerAtBoat(player, boat)
			print("Assigned " .. player.Name .. " to " .. boat.Name)
			return
		end
	end

	warn("No boats available for player: " .. player.Name)
end

-- Cleanup
Players.PlayerRemoving:Connect(function(player)
	local boat = playerBoats[player]
	if boat then
		assignedBoats[boat] = false
		playerBoats[player] = nil
		print("Freed boat " .. boat.Name .. " from " .. player.Name)
	end
end)

-- Assign on join
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()
	assignBoatToPlayer(player)
end)

-- ✅ Console Debug Support
_G.BoatDebug = {
	Assign = function(playerName)
		local player = Players:FindFirstChild(playerName)
		if player then
			assignBoatToPlayer(player)
		else
			warn("No player named:", playerName)
		end
	end,

	Reset = function(playerName)
		local player = Players:FindFirstChild(playerName)
		if player then
			local boat = playerBoats[player]
			if boat then
				assignedBoats[boat] = false
				playerBoats[player] = nil
				print("Unassigned " .. playerName .. " from " .. boat.Name)
			else
				warn("No boat assigned to " .. playerName)
			end
		else
			warn("No player named:", playerName)
		end
	end,

	Print = function()
		parint("=== Boat Assignments ===")
		for player, boat in pairs(playerBoats) do
			print(player.Name .. " -> " .. boat.Name)
		end
		print("========================")
	end
}