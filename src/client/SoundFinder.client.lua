local SoundService = game:GetService("SoundService")

local sound = SoundService:FindFirstChild("CountdownSounds")
if sound and sound:IsA("Sound") then
	print(" Find sound:", sound.Name)
	sound:Play()
else
	warn(" Sound not found")
end