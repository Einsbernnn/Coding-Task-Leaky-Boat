-- File: BoatAssignmentServer.lua

local Players = game:GetService("Players")
local boatsFolder = workspace:WaitForChild("Boats")

local assignedBoats = {}
local playerBoats = {}

local function assignBoatToPlayer(player)
	for _, boat in ipairs(boatsFolder:GetChildren()) do
		if not assignedBoats[boat] then
			assignedBoats[boat] = true
			playerBoats[player] = boat
			boat:SetAttribute("Owner", player.Name)
			print("🚤 Assigned", player.Name, "to", boat.Name)
			return boat
		end
	end
	warn("⚠️ No available boats for", player.Name)
end

local function unassignBoat(player)
	local boat = playerBoats[player]
	if boat then
		boat:SetAttribute("Owner", nil)
		assignedBoats[boat] = false
		playerBoats[player] = nil
		print("🚮 Unassigned boat from", player.Name)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		assignBoatToPlayer(player)
	end)
end)

Players.PlayerRemoving:Connect(unassignBoat)