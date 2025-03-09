--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local InputHandler = require(script.Parent.Parent.InputHandler)

local module = {}

local InputBind = Enum.KeyCode.T

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Combat = require(Replicated.Utils.Combat)

local ModuleHit = require(Replicated.Utils.Hitbox)

local OverlapParam = OverlapParams.new()
OverlapParam.FilterType = Enum.RaycastFilterType.Include
OverlapParam.FilterDescendantsInstances = {workspace.Alive}

local SkillInfo = require(Replicated.GameStats.Skills.Flowing)

function module.AssignSkill(Client : Types.Client)
	local Character = Client.Character :: Model
	local Arm = Character:FindFirstChild("Right Arm") :: Part
	
	local Signal : RBXScriptSignal = InputHandler:DetectInput(InputBind, Client)
	
	Signal:Connect(function(player)
		if player == Client.Player then else return end
		
		module.ActivateSkill(Client)
	end)
	
	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "Flowing", "AssignSkill", {Client})
	end
	
end

function module.DamageHitbox(Hitbox : BasePart, Character : Model)
	local listOfPartsInPart = workspace:GetPartsInPart(Hitbox, OverlapParam)

	for index, part in listOfPartsInPart do
		if part:IsDescendantOf(Character) then
			table.remove(listOfPartsInPart, table.find(listOfPartsInPart, part)) 
		end
	end

	local charactersHit = {}

	for _, CharacterBodypart in listOfPartsInPart do
		local CharacterHit = CharacterBodypart:FindFirstAncestorWhichIsA("Model")
		local Humanoid = CharacterHit:FindFirstChild("Humanoid")

		if not Humanoid or not CharacterHit then continue end
		if table.find(charactersHit, CharacterHit) then continue end
		if CharacterHit == Character then continue end

		table.insert(charactersHit, CharacterHit)
	end

	return charactersHit
end

function module.ActivateSkill(Client : Types.Client)
	
	if not Client.Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.Priority then else return end
	if Client.ClientStates.CurrentStunLevel.Value > 1 then return end
	local ID = math.random(1, 10000) * math.random(-10, 10)
	
	local HRP = Client.Character:WaitForChild("HumanoidRootPart") :: BasePart
	local Humanoid = Client.Character:FindFirstChild("Humanoid") :: Humanoid
	
	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "Flowing", "ActivateSkill", {Client})
	end
	
	StateClass:SetState(Client.ClientStates["ActionLevel"], {SkillInfo.Priority, ID})
	
	local WSMs = Client.Character:WaitForChild("WalkspeedModifiers") :: Folder
	local WSMNew = Instance.new("NumberValue", WSMs)
	WSMNew.Value = 0
	
	task.wait((SkillInfo.Duration*0.28)+0.1)
	
	local Hitbox = script.MiyabiHitbox:Clone()
	Hitbox.CFrame = HRP.CFrame * CFrame.new(0, 0, -(Hitbox.Size.Z/2))
	Hitbox.Parent = workspace.Hitboxes
	
	Debris:AddItem(Hitbox, 1)
	
	local hits = module.DamageHitbox(Hitbox, Client.Character)

	Replicated.Remotes.ReplicateSkill:FireAllClients("M1", "M1HitFX", hits)

	for _, Victim in hits do
		Combat:Damage(Victim, Client.Character, SkillInfo.Damage, SkillInfo.Stun, 1, SkillInfo.ActionLevel, SkillInfo.Damage, SkillInfo.Focus)
	end
	
	StateClass:SetState(Client.ClientStates["ActionLevel"], {0,0})
	WSMNew:Destroy()
end

function module.SkillEnd(Client : Types.Client)
	
end

function module.RemoveSkill(Client : Types.Client)
	print(Client)
end

return module
