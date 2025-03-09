--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local module = {}

local InputBind = Enum.UserInputType.MouseButton1

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))

local SkillInfo = require(Replicated.GameStats.Skills.MiyabiTwo)

local player = game.Players.LocalPlayer

local AnimationTracks = {
	
}

function module.AssignSkill(Parameters)

end

local function TweenLighting()
	local CC = game.Lighting.ScriptedLighting
	CC.Brightness = game.Lighting.MiyabiGlow.Brightness
	CC.Contrast = game.Lighting.MiyabiGlow.Contrast
	CC.TintColor = game.Lighting.MiyabiGlow.TintColor
	CC.Saturation = game.Lighting.MiyabiGlow.Saturation

	tweenService:Create(CC, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
		Brightness = game.Lighting.DefaultLightingColor.Brightness,
		Contrast = game.Lighting.DefaultLightingColor.Contrast,
		TintColor = game.Lighting.DefaultLightingColor.TintColor,
		Saturation = game.Lighting.DefaultLightingColor.Saturation,
	}):Play()
end

function module.ActivateSkill(Parameters : {any})
	local Client = Parameters[1] :: Types.Client
	local Player = Client.Player :: Player
	local Character = Player.Character :: Model
	local HRP = Character:FindFirstChild("HumanoidRootPart") :: Part
	local Rarm = Character:WaitForChild("Right Arm") :: Part

	if not Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.Priority then else return end
	
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	local Animation = Animator:LoadAnimation(script.Action)
	Animation:Play()

	repeat task.wait() until Animation.Length > 0

	local currentLength = Animation.Length
	local newSpeed = currentLength / SkillInfo.Duration
	local newLength = currentLength*newSpeed
	Animation:AdjustSpeed(newSpeed)
	
	local tim = tick()
	
	Animation:GetMarkerReachedSignal("Shine"):Connect(function()
		local ShineAttachment = Replicated.Assets["Right Arm"].Star:Clone()
		ShineAttachment.Parent = Rarm
		
		ShineAttachment["1"]:Emit(ShineAttachment["1"]:GetAttribute("EmitCount"))
		ShineAttachment["2"]:Emit(ShineAttachment["2"]:GetAttribute("EmitCount"))
		
		Debris:AddItem(ShineAttachment, 1)
	end)
	
	Animation:GetMarkerReachedSignal("Hit"):Connect(function()
		TweenLighting()
		
		--print((tick()-tim)/newLength)
		
	end)
end

function module.SkillEnd()
	
end

function module.RemoveSkill()
	
end

return module
