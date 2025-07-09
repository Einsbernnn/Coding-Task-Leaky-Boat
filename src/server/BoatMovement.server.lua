-- File: BoatMovementController.lua

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoatMovement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BoatMovementModule"))

-- Example: Start all boats for all players (call this at race start)
local boatsFolder = Workspace:WaitForChild("Boats")
local Players = game:GetService("Players")

for _, player in ipairs(Players:GetPlayers()) do
	for _, boat in ipairs(boatsFolder:GetChildren()) do
		if boat:GetAttribute("Owner") == player.Name then
			BoatMovement.StartBoat(boat, player)
		end
	end
end

-- All other race logic is now handled in BoatMovementModule and GameManager