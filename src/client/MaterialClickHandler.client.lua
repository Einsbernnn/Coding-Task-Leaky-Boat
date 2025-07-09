-- LocalScript: MaterialClickHandler.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MaterialsGui")
local buttonsFrame = gui:WaitForChild("Frame"):WaitForChild("Buttons")

local waterproofMaterials = {
	Plastic = true,
	Metal = true,
	Concrete = true,
	Rubber = true,
}

local clickedCorrect = 0

local clickEvent = ReplicatedStorage:WaitForChild("MaterialClickedEvent") -- RemoteEvent

for _, btn in ipairs(buttonsFrame:GetChildren()) do
	if btn:IsA("TextButton") then
		btn.Activated:Connect(function()
			if not btn:GetAttribute("Clicked") then
				btn:SetAttribute("Clicked", true)

				local material = btn.Name
				local isCorrect = waterproofMaterials[material]

				if isCorrect then
					clickedCorrect += 1
					btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
				else
					btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
				end

				btn.AutoButtonColor = false
				btn.Active = false
				btn.TextTransparency = 0.3

				clickEvent:FireServer(material, isCorrect)
			end
		end)
	end
end