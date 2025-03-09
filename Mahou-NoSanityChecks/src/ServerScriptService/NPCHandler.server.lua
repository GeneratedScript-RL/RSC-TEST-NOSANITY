--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Types = require(Replicated.GlobalTypes)

local Combat = require(Replicated.Utils.Combat)

function CreateNPCClient(Model : Model)
	Model:SetAttribute("ID", tostring(math.random(1, 1000)*math.random(-1000, 1000)))
	local Client = ClientClass.new(Model)
	local PlayerUsingCharacter = require(Replicated.GameStats.Characters.Default)

	local CharacterPlayableState = ClientClass:CreateState(Client, "CharacterPlaying", PlayerUsingCharacter)
	local CurrentPlayingCharacter : Types.PlayableCharacter = CharacterPlayableState.Value

	ClientClass:CreateState(Client, "HealthValues", CurrentPlayingCharacter.HealthValues)
	local StunState = ClientClass:CreateState(Client, "Stuns", {})

	ClientClass:CreateState(Client, "MaxPosture", CurrentPlayingCharacter.Posture)
	ClientClass:CreateState(Client, "Posture", CurrentPlayingCharacter.Posture)
	ClientClass:CreateState(Client, "Focus", 0)
	ClientClass:CreateState(Client, "Blocking", false)
	ClientClass:CreateState(Client, "VunurabilityInfo", {Parrying = false, Blocking = false})
	ClientClass:CreateState(Client, "ActionLevel", {0, 0})

	Model.Destroying:Connect(function()
		local Client : Types.Client = ClientClass:GetClient(Model:GetAttribute("ID"))

		for name, state : Types.State in Client.ClientStates do
			state.stateChanged:Destroy()
			state.Value = nil
		end

		Client.ClientStates = {}
		Client = {} :: Types.Client
	end)

	-- ADD SKILLS

	local CurrentSkills = ClientClass:CreateState(Client, "Skills", CurrentPlayingCharacter.Skills)

	for _, Skill in CurrentSkills.Value do
		local SkillComponent = require(Modules.SkillComponents:FindFirstChild(Skill.SkillComponent))

		SkillComponent.AssignSkill(Client)
	end
end

for _, Model : Model in CollectionService:GetTagged("NPC") do
	CreateNPCClient(Model)
end

CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(Model : Model)
	CreateNPCClient(Model)
end)