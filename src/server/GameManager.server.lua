-- GameManager.server.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Assume BoatMovement will fire OnBoatFinish when a boat finishes
local BoatMovement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BoatMovementModule"))

local finishOrder = {}

local function onBoatFinish(player)
	if not table.find(finishOrder, player) then
		table.insert(finishOrder, player)
		if #finishOrder == 1 then
			print(player.Name .. " wins!")
			-- TODO: Fire event to clients, show winner UI, etc.
		end
	end
end

if BoatMovement.OnBoatFinish and BoatMovement.OnBoatFinish.Event then
	BoatMovement.OnBoatFinish.Event:Connect(onBoatFinish)
else
	warn("BoatMovement.OnBoatFinish.Event not found! Make sure BoatMovement module exposes this event.")
end 