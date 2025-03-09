--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local InputHandler = require(script.Parent.Parent.InputHandler)

local module = {} :: Types.SkillComponent
local InputBind = Enum.KeyCode.E

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Combat = require(Replicated.Utils.Combat)

local OverlapParam = OverlapParams.new()
OverlapParam.FilterType = Enum.RaycastFilterType.Include
OverlapParam.FilterDescendantsInstances = {workspace.Alive}
OverlapParam.MaxParts = 100

local SkillInfo = require(Replicated.GameStats.Skills.MiyabiTwo)

local ProjectileFacesInitial = {
	CFrame.new(0, 0, -1),
	CFrame.new(.5, 0, -1),
	CFrame.new(-.5, 0, -1),
}

local ProjectileFaces = {
	CFrame.new(0, 0, -1),
	CFrame.new(.5, 0, -1),
	CFrame.new(-.5, 0, -1),
	CFrame.new(1, 0, -1),
	CFrame.new(-1, 0, -1),
}

function module.AssignSkill(Client : Types.Client)
	local Character = Client.Character :: Model
	local Arm = Character:FindFirstChild("Right Arm") :: Part

	local Signal : RBXScriptSignal = InputHandler:DetectInput(InputBind, Client)

	Signal:Connect(function(player)
		if player == Client.Player then else return end

		module.ActivateSkill(Client)
	end)

	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "MiyabiTwo", "AssignSkill", {Client})
	end
end

local function _ChangeEnabledSlash(SlashPart : Part, bool)
	for _, inst in SlashPart:GetDescendants() do
		if inst:IsA("ParticleEmitter") then
			inst.Enabled = bool
		elseif inst:IsA("Trail") then
			inst.Enabled = bool
		end
	end
end

function HandleHitbox(Hitbox : Part, duration : number, Caster:Model)
	local HitEntities = {}
	
	local ticks = 0
	
	repeat
		local Hits = workspace:GetPartsInPart(Hitbox, OverlapParam)
		
		for _, part in Hits do
			local Model = part:FindFirstAncestorWhichIsA("Model")
			if Model and Model ~= Caster and not table.find(HitEntities, Model) then
				table.insert(HitEntities, Model)
				Combat:Damage(Model, Caster, SkillInfo.Damage, SkillInfo.Stun, 0.3, SkillInfo.Priority, SkillInfo.Posture, SkillInfo.Focus)
			end
		end
		
		task.wait(0.01)
		ticks += 0.01
	until ticks >= duration
end

function _ThrowProjectiles(Client : Types.Client, Duration : number, FacesTable : {CFrame})
	if not Client.Character then return end
	
	local HRP = Client.Character:WaitForChild("HumanoidRootPart") :: BasePart
	local Humanoid = Client.Character:FindFirstChild("Humanoid") :: Humanoid
	
	for _, FacingPos : CFrame in FacesTable do -- caching parts cuz bodyvel has initiation time
		task.spawn(function()
			local SlashPart = script.SlashPart:Clone()
			SlashPart.Parent = workspace.VFX
			SlashPart.CFrame = HRP.CFrame * CFrame.new(0, 10, 0)

			SlashPart.Anchored = true
			task.wait(Duration)
			-- ACTIVATE
			SlashPart.Anchored = false
			
			SlashPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -.2)
			local TargP = (HRP.CFrame*FacingPos).Position
			SlashPart.CFrame = CFrame.lookAt(SlashPart.Position, TargP)
			SlashPart.CFrame = SlashPart.CFrame*CFrame.new(0, 2.1, 0)

			local bvel = Instance.new("BodyVelocity", SlashPart)
			bvel.Velocity = SlashPart.CFrame.LookVector*150
			bvel.MaxForce = Vector3.one * math.huge
			
			task.spawn(function()
				task.wait(.1)
				_ChangeEnabledSlash(SlashPart, true)
				HandleHitbox(SlashPart, .4, Client.Character)
				task.wait(.4)
				_ChangeEnabledSlash(SlashPart, false)
			end)
			
			Debris:AddItem(SlashPart, 2)
		end)
	end
	
end

function module.ActivateSkill(Client : Types.Client)
	if not Client.Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.Priority then else return end
	if Client.ClientStates.CurrentStunLevel.Value > 1 then return end
	
	local ID = math.random(1, 10000) * math.random(-10, 10)

	local HRP = Client.Character:WaitForChild("HumanoidRootPart") :: BasePart
	local Humanoid = Client.Character:FindFirstChild("Humanoid") :: Humanoid

	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "MiyabiTwo", "ActivateSkill", {Client})
	end
	
	local WSMs = Client.Character:WaitForChild("WalkspeedModifiers") :: Folder
	local WSMNew = Instance.new("NumberValue", WSMs)
	WSMNew.Value = 0

	StateClass:SetState(Client.ClientStates["ActionLevel"], {SkillInfo.Priority, ID})
	
	local InitialCD = (0.147*SkillInfo.Duration)-0.1
	local SecondCD = (0.351*SkillInfo.Duration)-0.1
	
	task.spawn(function()
		task.wait(SkillInfo.Duration)
		StateClass:SetState(Client.ClientStates["ActionLevel"], {0,0})
		WSMNew:Destroy()
	end)
	
	task.wait(InitialCD)
	_ThrowProjectiles(Client, InitialCD-0.1, ProjectileFacesInitial)
	task.wait(SecondCD-InitialCD)
	_ThrowProjectiles(Client, SecondCD-0.1, ProjectileFaces)
end

function module.SkillEnd(Client : Types.Client)
	
end

function module.RemoveSkill(Client : Types.Client)
	print(Client)
end

return module
