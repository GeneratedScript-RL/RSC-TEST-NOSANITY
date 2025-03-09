--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local module = {}

local InputBind = Enum.UserInputType.MouseButton1

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))

local SkillInfo = require(Replicated.GameStats.Skills.Dash)
local Anims = Replicated.Assets.Animations.Dash

function module.AssignSkill(Parameters)

end

function module.ActivateSkill(Parameters : {any})
	local Client = Parameters[1] :: Types.Client
	local Player = Client.Player :: Player
	local Character = Player.Character :: Model
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local HRP = Character:FindFirstChild("HumanoidRootPart") :: Part
	
	local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator
	
	if not Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.ActionLevel then else return end
	
	local AddedVelocity = HRP.CFrame.LookVector * 75
	
	if Humanoid.FloorMaterial == Enum.Material.Air then
		Anims = Replicated.Assets.Animations.DashAir
	else
		Anims = Replicated.Assets.Animations.Dash
	end
	local Anim = Anims.Forward
	
	if UIS:IsKeyDown(Enum.KeyCode.A) then
		AddedVelocity = -HRP.CFrame.RightVector * 75
		Anim = Anims.Left
	elseif UIS:IsKeyDown(Enum.KeyCode.S) then
		AddedVelocity = -HRP.CFrame.LookVector * 75
		Anim = Anims.Back
	elseif UIS:IsKeyDown(Enum.KeyCode.D) then
		AddedVelocity = HRP.CFrame.RightVector * 75
		Anim = Anims.Right
	end
	
	if Humanoid.FloorMaterial == Enum.Material.Air then
		AddedVelocity = AddedVelocity + HRP.CFrame.UpVector*30
	end
	
	local anim = Animator:LoadAnimation(Anim)
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play()
	
	HRP.AssemblyLinearVelocity = HRP.AssemblyLinearVelocity + AddedVelocity
	
end

function module.SkillEnd()
	
end

function module.RemoveSkill()
	
end

return module
