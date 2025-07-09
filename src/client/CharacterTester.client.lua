-- CharacterTester: Sprint and Swim Boost on Shift
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local NORMAL_WALK_SPEED = 16
 local SPRINT_WALK_SPEED = NORMAL_WALK_SPEED * 10
local NORMAL_SWIM_SPEED = 16
local SPRINT_SWIM_SPEED = NORMAL_SWIM_SPEED * 10

-- Fly variables
local flying = false
local flySpeed = 100
local lastSpaceTime = 0
local DOUBLE_TAP_TIME = 0.3 -- seconds
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function updateSpeed()
    if Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
        Humanoid.WalkSpeed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and SPRINT_SWIM_SPEED or NORMAL_SWIM_SPEED
    else
        Humanoid.WalkSpeed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and SPRINT_WALK_SPEED or NORMAL_WALK_SPEED
    end
end

local function startFlying()
    if flying then return end
    flying = true
    Humanoid.PlatformStand = true
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
    flyBodyVelocity.MaxForce = Vector3.new(1,1,1) * 1e5
    flyBodyVelocity.Parent = root
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1,1,1) * 1e5
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
end

local function stopFlying()
    if not flying then return end
    flying = false
    Humanoid.PlatformStand = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local function updateFly(dt)
    if not flying then return end
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local moveDir = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end
    flyBodyVelocity.Velocity = moveDir * flySpeed
    flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        updateSpeed()
    elseif input.KeyCode == Enum.KeyCode.Space then
        local now = tick()
        if now - lastSpaceTime < DOUBLE_TAP_TIME then
            if not flying then
                startFlying()
            else
                stopFlying()
            end
            lastSpaceTime = 0
        else
            lastSpaceTime = now
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        updateSpeed()
    end
end)

Humanoid.StateChanged:Connect(function(_, newState)
    updateSpeed()
end)

game:GetService("RunService").RenderStepped:Connect(updateFly)

-- Reset speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    Humanoid.StateChanged:Connect(function(_, newState)
        updateSpeed()
    end)
    updateSpeed()
    stopFlying()
end)

updateSpeed()
stopFlying()
