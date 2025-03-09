--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local InputHandler = require(script.Parent.Parent.InputHandler)

local module = {} :: Types.SkillComponent

local InputBind = Enum.KeyCode.F

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Combat = require(Replicated.Utils.Combat)

local SkillInfo = require(Replicated.GameStats.Skills.Parry)

function module.AssignSkill(Client : Types.Client)
	local Signal : RBXScriptSignal = InputHandler:DetectInput(InputBind, Client)

	Signal:Connect(function(player)
		if player == Client.Player then else return end
		module.ActivateSkill(Client)
	end)

	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "Parry", "AssignSkill", {Client})
	end
	
	ClientClass:CreateState(Client, "ParryCooldown", false)
end

function module.ActivateSkill(Client : Types.Client)
	if Client.ClientStates.CurrentStunLevel.Value > 2 then return end
	if not Client.Character then return end
	if Client.ClientStates["ActionLevel"].Value[1] < SkillInfo.ActionLevel then else return end
	
	local VunurabilityState = Client.ClientStates.VunurabilityInfo
	
	if VunurabilityState.Value.IsParrying or VunurabilityState.Value.IsBlocking or Client.ClientStates.ParryCooldown.Value then return end
	
	local NewState = {
		IsParrying = true,
		IsBlocking = true,
	}
	
	StateClass:SetState(VunurabilityState, NewState)
	
	task.delay(SkillInfo.BlockAutoWindow, function()
		module.SkillEnd(Client)
	end)
	
	Replicated.Remotes.ReplicateSkill:FireAllClients("Parry", "ActivateSkill", {Client.Character})
	
	task.wait(.3)
	
	VunurabilityState.Value.IsParrying = false
end

function module.SkillEnd(Client : Types.Client)
	local VunurabilityState = Client.ClientStates.VunurabilityInfo
	
	VunurabilityState.Value.IsBlocking = false
	Client.ClientStates.ParryCooldown.Value = true
	
	task.wait(SkillInfo.Cooldown)
	Client.ClientStates.ParryCooldown.Value = false
end

function module.RemoveSkill(Client : Types.Client)
	
end

return module
