--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Types = require(Replicated.GlobalTypes)

local Combat = require(Replicated.Utils.Combat)

function HandlePlayerCharacter(player)

	player.CharacterAdded:Connect(function(character : Model)
		Replicated.Remotes.Server.NewCharacter:Fire(character)

		local Humanoid = character:WaitForChild("Humanoid") :: Humanoid

		local Client = ClientClass:GetClient(player.Name)

		Humanoid.Died:Connect(function()
			player:LoadCharacter()
			Client.Character = player.Character
		end)
	end)
	player:LoadCharacter()
end

Players.PlayerAdded:Connect(function(player)
	HandlePlayerCharacter(player)

	local Client = ClientClass.new(player)
	local PlayerUsingCharacter = require(Replicated.GameStats.Characters.Default)

	local CharacterPlayableState = ClientClass:CreateState(Client, "CharacterPlaying", PlayerUsingCharacter)
	local CurrentPlayingCharacter : Types.PlayableCharacter = CharacterPlayableState.Value

	ClientClass:CreateState(Client, "HealthValues", CurrentPlayingCharacter.HealthValues)
	local StunState = ClientClass:CreateState(Client, "Stuns", {})

	ClientClass:CreateState(Client, "MaxPosture", CurrentPlayingCharacter.Posture)
	ClientClass:CreateState(Client, "Posture", CurrentPlayingCharacter.Posture)
	ClientClass:CreateState(Client, "Focus", 0)
	ClientClass:CreateState(Client, "VunurabilityInfo", {Parrying = false, Blocking = false})
	ClientClass:CreateState(Client, "ActionLevel", {0, 0})
	StateClass:SetState(StunState, {})
	local CSL = ClientClass:CreateState(Client, "CurrentStunLevel", 0)
	
	StunState.stateChanged.Event:Connect(function()
		local HighestStun = 0
		
		for _, Stun in Client.ClientStates.Stuns do
			local StunVal = Stun :: Types.Stun
			if StunVal.StunLevel > HighestStun then
				HighestStun = StunVal.StunLevel
			end
		end
		
		StateClass:SetState(CSL, HighestStun)
	end)

	-- ADD SKILLS

	local CurrentSkills = ClientClass:CreateState(Client, "Skills", CurrentPlayingCharacter.Skills)

	for _, Skill in CurrentSkills.Value do
		local SkillComponent = require(Modules.SkillComponents:FindFirstChild(Skill.SkillComponent))

		SkillComponent.AssignSkill(Client)
	end

end)

Players.PlayerRemoving:Connect(function(player)
	local Client : Types.Client = ClientClass:GetClient(player.Name)

	for name, state : Types.State in Client.ClientStates do
		state.stateChanged:Destroy()
		state.Value = nil
	end

	Client.ClientStates = {}
	Client = {} :: Types.Client
end)

Replicated.Remotes.Server.RequestClientClass.OnServerInvoke = function(player)
	return ClientClass:GetClient(player.Name)
end