--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local InputHandler = require(script.Parent.Parent.InputHandler)
local Hitbox = require(Replicated.Utils.Hitbox)


local module = {}

local InputBind = Enum.KeyCode.Q

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Combat = require(Replicated.Utils.Combat)

local ModuleHit = require(Replicated.Utils.Hitbox)

local OverlapParam = OverlapParams.new()
OverlapParam.FilterType = Enum.RaycastFilterType.Include
OverlapParam.FilterDescendantsInstances = {workspace.Alive}

local M1SetInfo = require(Replicated.GameStats.DefaultSet)
local SkillInfo = require(Replicated.GameStats.Skills.Dash)

function module.AssignSkill(Client : Types.Client)
	local Character = Client.Character :: Model
	local Arm = Character:FindFirstChild("Right Arm") :: Part
	
	local Signal : RBXScriptSignal = InputHandler:DetectInput(InputBind, Client)
	
	Signal:Connect(function(player, Parameters)
		if player == Client.Player then else return end
		
		module.ActivateSkill(Client, Parameters :: {any})
	end)
	
	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "Dash", "AssignSkill", {Client})
	end
	
end

function module.ActivateSkill(Client : Types.Client, Parameters : {any})
	
	if not Client.Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.ActionLevel then else return end
	if Client.ClientStates.CurrentStunLevel.Value > 0 then return end
	
	local ID = math.random(1, 10000) * math.random(-10, 10)
	
	local HRP = Client.Character:WaitForChild("HumanoidRootPart") :: BasePart
	local Humanoid = Client.Character:FindFirstChild("Humanoid") :: Humanoid
	
	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "Dash", "ActivateSkill", {Client})
	end
	
	StateClass:SetState(Client.ClientStates["ActionLevel"], {SkillInfo.ActionLevel, ID})
	task.wait(SkillInfo.Duration)
	StateClass:SetState(Client.ClientStates["ActionLevel"], {0,0})

end

function module.SkillEnd(Client : Types.Client)
	
end

function module.RemoveSkill(Client : Types.Client)
	print(Client)
end

return module
