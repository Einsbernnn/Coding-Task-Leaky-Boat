-- File: BoatStatusClient.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BoatStatusGui")
local sinkBar = gui:WaitForChild("Frame"):WaitForChild("SinkBar")
local boostLabel = gui:WaitForChild("Frame"):WaitForChild("SpeedBoostLabel")

-- Create value container
local sinkValue = Instance.new("NumberValue")
sinkValue.Name = "SinkRate"
sinkValue.Value = 1
sinkValue.Parent = player

local correctCount = Instance.new("IntValue")
correctCount.Name = "CorrectMaterials"
correctCount.Value = 0
correctCount.Parent = player

-- Update UI
sinkValue:GetPropertyChangedSignal("Value"):Connect(function()
	local percent = math.clamp(sinkValue.Value / 1, 0, 1)
	sinkBar.Size = UDim2.new(percent, 0, 1, 0)
	sinkBar.Text = "Sink Rate: " .. math.floor(percent * 100) .. "%"
end)

correctCount:GetPropertyChangedSignal("Value"):Connect(function()
	boostLabel.Text = "Boost: " .. (correctCount.Value * 5) .. "%"
end)