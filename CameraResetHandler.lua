local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local resetCameraEvent = ReplicatedStorage:WaitForChild("ResetCameraEvent")

resetCameraEvent.OnClientEvent:Connect(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = humanoid.RootPart

	local camera = workspace.CurrentCamera

	-- Step 1: Set Scriptable mode and position the camera behind the player
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(
		root.Position + Vector3.new(0, 5, 0) - root.CFrame.LookVector * 12,
		root.Position + Vector3.new(0, 3, 0)
	)

	-- Step 2: Switch back to Custom follow mode
	task.wait(0.05)
	camera.CameraSubject = humanoid
	camera.CameraType = Enum.CameraType.Custom
end)