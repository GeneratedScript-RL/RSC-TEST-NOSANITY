--// Services

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Replicated = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

--// Modules

local Types = require(Replicated.GlobalTypes)

--// Constants

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Humanoid : Humanoid = character:WaitForChild("Humanoid")
local Animator : Animator = Humanoid.Animator
local RunAnim : AnimationTrack = Animator:LoadAnimation(script.Run)

local Client = Replicated.Remotes.Server.RequestClientClass:InvokeServer() :: Types.Client
local CharacterPlaying = Client.ClientStates["CharacterPlaying"].Value :: Types.PlayableCharacter

local Humanoid = character:WaitForChild("Humanoid") :: Humanoid
Humanoid.WalkSpeed = CharacterPlaying.Walkspeed

--// Variables

local isrunning = false
local speedtween = nil
local IsRunToggled = false

local maxDelay = 0.15
local t1 = 0
local t2 = 0

function UnRun()

	isrunning = false
	RunAnim:Stop()
	
	--
	
	if speedtween then
		speedtween:Cancel()
		speedtween = nil
	end

	pcall(function()
		character.WalkspeedModifiers:FindFirstChild("Run"):Destroy()
	end)
end

function Run()
	
	local Client = Replicated.Remotes.Server.RequestClientClass:InvokeServer() :: Types.Client
	
	print(Client.ClientStates)
	
	--if character:GetAttribute("StunLevel") > 0 then return end
	--if character:GetAttribute("IsParrying") then return end
	--if character:GetAttribute("IsBlocking") then return end
	--if character:GetAttribute("IsAttacking") then return end
	--if character:GetAttribute("IsUsingSkills") then return end
	
	isrunning = true
	
	---
	
	if speedtween then
		speedtween:Cancel()
		speedtween = nil
	end

	local NewModif = Instance.new("NumberValue")
	NewModif.Value = 2
	NewModif.Name = "Run"
	NewModif.Parent = character.WalkspeedModifiers
end

UIS.InputBegan:Connect(function(i, g)
	
	if g then return end

	if i.KeyCode == Enum.KeyCode.W then
		if tick() - t1 <= maxDelay then
			Run()
		else
			t1 = tick()
		end
	end
	
	if i.KeyCode == Enum.KeyCode.LeftShift then
		if isrunning then
			UnRun()
		else
			Run()
		end
	end
end)

UIS.InputEnded:Connect(function(i, g)
	if i.KeyCode == Enum.KeyCode.W then
		UnRun()
	end
end)

RS.Heartbeat:Connect(function()

	if Humanoid.MoveDirection.Magnitude > 0 then
		if isrunning and not RunAnim.IsPlaying and Humanoid.WalkSpeed > 0 then
			RunAnim:Play()
		end
	else
		RunAnim:Stop()
	end
end)

local WSM = character:WaitForChild("WalkspeedModifiers")

-- update walkspeed when new walkspeed modifier is created

local function Update()
	local DefaultWalkspeed = CharacterPlaying.Walkspeed

	for _, instance in WSM:GetChildren() do
		if instance:IsA("NumberValue") then else continue end
		local walkspeedmodif = instance :: NumberValue

		DefaultWalkspeed = DefaultWalkspeed * walkspeedmodif.Value
	end

	Humanoid.WalkSpeed = DefaultWalkspeed
end

WSM.ChildAdded:Connect(function(child)

	if child:IsA("NumberValue") then else return end

	child.Changed:Connect(function()
		Update()
	end)

	Update()
end)

WSM.ChildRemoved:Connect(Update)
Replicated.Remotes.Client.CastedSkill.OnClientEvent:Connect(UnRun)