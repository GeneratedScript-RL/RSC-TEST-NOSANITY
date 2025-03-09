--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local module = {}

local InputBind = Enum.UserInputType.MouseButton1

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))

local M1SetInfo = require(Replicated.GameStats.DefaultSet)
local AnimationFolder = M1SetInfo.AnimationFolder

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Humanoid : Humanoid = character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local AnimationTracks = {
	
}

function module.AssignSkill(Parameters)

end

function module.ActivateSkill(Parameters : {any})
	local CharParrier = Parameters[1] :: Model
	local Humanoid = CharParrier:FindFirstChild("Humanoid") :: Humanoid
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator
	
	Animator:LoadAnimation(script.Default_Parry):Play()
end

function module.SuccessfulParry(Parameters : {any})
	local Parrier = Parameters[1] :: Model
	local Parried = Parameters[2] :: Model
	local HRP = Parrier:FindFirstChild("HumanoidRootPart") :: BasePart
	local HRPParried = Parried:FindFirstChild("HumanoidRootPart") :: BasePart
	
	local Sound = script.ParrySound:Clone()
	Sound.Parent = Parrier.PrimaryPart
	Sound:Play()
	
	Debris:AddItem(Sound, Sound.TimeLength+1)
	
	for _, effect : ParticleEmitter in script.Parrier:GetChildren() do
		effect = effect:Clone() :: ParticleEmitter
		effect.Parent = HRP:FindFirstChildWhichIsA("Attachment")
		effect:Emit(effect:GetAttribute("EmitCount"))
		Debris:AddItem(effect, 1)
	end
	
end

function module.SkillEnd()
	
end

function module.RemoveSkill()
	
end

return module
