-- File: CheckMaterialButtons.client.lua

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("MaterialsGui")

-- 🧱 Navigate to Buttons Frame inside the main Frame
local mainFrame = gui:WaitForChild("Frame")
local buttonsFrame = mainFrame:WaitForChild("Buttons")

-- ✅ Define waterproof materials
local waterproofMaterials = {
	Plastic = true,
	Metal = true,
	Concrete = true,
	Rubber = true,
}

-- 🔊 Load sounds
local correctSound = SoundService:FindFirstChild("Correct")
local wrongSound = SoundService:FindFirstChild("Wrong")

-- 🎯 Hook up a button once
local function connectButton(button)
	if not button:IsA("TextButton") or button:GetAttribute("Connected") then return end
	button:SetAttribute("Connected", true)

	button.Activated:Connect(function()
		local name = button.Name
		print("🟢 Clicked:", name)

		local isCorrect = waterproofMaterials[name]

		button.BackgroundColor3 = isCorrect and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
		button.AutoButtonColor = false
		button.Active = false
		button.TextTransparency = 0.3

		if isCorrect and correctSound then
			correctSound:Play()
		elseif not isCorrect and wrongSound then
			wrongSound:Play()
		end
	end)
end

-- 🔁 Connect all existing buttons (after layout loads)
task.delay(0.2, function()
	for _, child in ipairs(buttonsFrame:GetChildren()) do
		connectButton(child)
	end
end)

-- 🔁 Connect any buttons added dynamically
buttonsFrame.ChildAdded:Connect(function(child)
	task.wait(0.1)
	connectButton(child)
end)

print("✅ Material button script loaded and connected to Buttons frame.")