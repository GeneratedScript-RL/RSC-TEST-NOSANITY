local RS = game:GetService("RunService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local HRP : BasePart = character:WaitForChild("HumanoidRootPart")
local Hum : Humanoid = character:WaitForChild("Humanoid")

local lv = Vector3.zero

-- tilt settings

RotationPowerFrontBack = 0.05--multiplies rotation by RotationPower
RotationPowerLeftRight = 0.20--multiplies rotation by RotationPower
RotationSpeed = 0.05
OriginalC0 = game.Players.LocalPlayer.Character.HumanoidRootPart:WaitForChild("RootJoint").C0

-- FOV settings

local smoothness = 0.085 -- Adjust the smoothness factor
local deadZone = 0.1 -- Adjust the dead zone

--

local function lerp(a, b, t)
	return a + (b - a) * t
end

local targetFOV = 80

_G.EnableFOVControl = true

RS.RenderStepped:Connect(function()

	if _G.EnableFOVControl == true then
		-- FOV

		local velocity = HRP.AssemblyLinearVelocity
		local speed = velocity.Magnitude

		local a

		-- Adjust FOV based on character velocity
		if speed > 0 then
			local cameraDirection = workspace.CurrentCamera.CFrame.LookVector
			local characterDirection = velocity.unit

			local dotProduct = cameraDirection:Dot(characterDirection)

			-- Adjust FOV based on the direction of movement

			if dotProduct > deadZone then
				a = (HRP.AssemblyLinearVelocity * Vector3.new(1, 0.2, 1)).Magnitude / 1.3
				targetFOV = targetFOV + a
			else
				targetFOV = 8
			end

			targetFOV = math.clamp(targetFOV, 80, 105)

			-- Adjust FOV based on camera position relative to the character
			local cameraToCharacter = HRP.Position - workspace.CurrentCamera.CFrame.Position
			local distanceToCamera = cameraToCharacter.Magnitude

			targetFOV = targetFOV + distanceToCamera * 0.1 -- Adjust the multiplier as needed
		end

		local currentFOV = workspace.CurrentCamera.FieldOfView
		workspace.CurrentCamera.FieldOfView = lerp(currentFOV, targetFOV, smoothness)
	end

	--

	local DotFrontBack = HRP.CFrame.LookVector:Dot(Hum.MoveDirection)
	local DotLeftRight = HRP.CFrame.RightVector:Dot(Hum.MoveDirection)

	HRP:WaitForChild("RootJoint").C0 = HRP.RootJoint.C0:Lerp(OriginalC0 * CFrame.Angles(DotFrontBack*RotationPowerFrontBack,-DotLeftRight*RotationPowerLeftRight,0),RotationSpeed)

	-- motion blur

	game.Lighting.Blur.Size = math.abs(HRP.AssemblyLinearVelocity.Magnitude)*0.065

	-- M1 camera offset

	local cameraOffset = (HRP.CFrame + Vector3.new(0.1, 1.5, 0.1)):pointToObjectSpace(character.Head.CFrame.p)
	local cameraOffsetTween = game:GetService("TweenService"):Create(Hum, TweenInfo.new(0.1), {CameraOffset = cameraOffset})
	cameraOffsetTween:Play()
end)
