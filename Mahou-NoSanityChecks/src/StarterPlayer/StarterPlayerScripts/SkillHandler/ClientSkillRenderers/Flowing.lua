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

local SkillInfo = require(Replicated.GameStats.Skills.Flowing)

function module.AssignSkill(Parameters)

end

function module.ActivateSkill(Parameters : {any})
	local Client = Parameters[1] :: Types.Client
	local Player = Client.Player :: Player
	local Character = Player.Character :: Model
	local HRP = Character:FindFirstChild("HumanoidRootPart") :: Part
	
	if not Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.Priority then else return end
	
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	local Animation = Animator:LoadAnimation(script.Attack)
	Animation:Play()
	Animation.Looped = false
	
	repeat task.wait() until Animation.Length > 0
	
	local currentLength = Animation.Length
	local newSpeed = currentLength / SkillInfo.Duration
	Animation:AdjustSpeed(newSpeed)
	
	local VFX = script.Skill:Clone()
	
	local timetil = tick()
	
	Animation:GetMarkerReachedSignal("Attack"):Wait()
	
	local timetilnew = tick()-timetil
	local adjustedtime = (Animation.Length/newSpeed)
	local percent = timetilnew/adjustedtime

	print(timetilnew)
	print(percent)
	print(adjustedtime*percent)
	
	local Bpos = script.BodyPosition:Clone()
	Bpos.Position = (HRP.CFrame * CFrame.new(0, 0, -50)).Position
	Bpos.Parent = HRP
	
	for _, part in Character:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 1
		end
	end
	
	VFX.Parent = workspace.VFX
	VFX.CFrame = HRP.CFrame * CFrame.new(0, -2, -50) * CFrame.Angles(0, math.rad(-180), 0)
	
	task.delay(.25, function()
		for _, emitter in VFX:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			elseif emitter:IsA("Beam") then
				
				task.spawn(function()
					local trans = 0
					emitter.Transparency = NumberSequence.new(0)
					repeat
						trans += .04
						emitter.Transparency = NumberSequence.new(trans)
						task.wait()
					until trans > .99
				end)
				
			end
		end
	end)
	
	Debris:AddItem(VFX, 4)
	Debris:AddItem(Bpos, .25)
	
	task.wait(.25)
	
	for _, part in Character:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0
		end
	end	
end

function module.SkillEnd()
	
end

function module.RemoveSkill()
	
end

return module
