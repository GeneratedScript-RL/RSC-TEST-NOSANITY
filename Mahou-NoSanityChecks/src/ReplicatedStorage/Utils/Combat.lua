--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Types = require(Replicated.GlobalTypes)

local module = {}

function module:Stun(Level : number, Duration : number, Victim : Model)
	local Client = ClientClass:GetClient(Victim.Name) or ClientClass:GetClient(tostring(Victim:GetAttribute("ID")))
	local StunStates = Client.ClientStates["Stuns"]
	
	local Stun : Types.Stun = {
		StunLevel = Level,
		Duration = Duration,
	}
	
	local CurrentStuns = StunStates.Value :: {Types.Stun}
	table.insert(CurrentStuns, Stun)
	
	StateClass:SetState(StunStates, CurrentStuns)
	
	if Duration > 0 then
		task.delay(Duration, function()
			StunStates = Client.ClientStates["Stuns"]
			
			local CurrentStuns = StunStates.Value :: {Types.Stun}
			table.remove(CurrentStuns, table.find(CurrentStuns, Stun))
			
			StateClass:SetState(StunStates, CurrentStuns)
		end)
	end
end

function module:Damage(CharacterVictim : Model, CharacterAttacker : Model, Damage, StunLevel, StunDuration, HitPriority, PostureDamage, FocusReward)
	local VictimClient = ClientClass:GetClient(CharacterVictim.Name) or ClientClass:GetClient(tostring(CharacterVictim:GetAttribute("ID")))
	local AttackerClient = ClientClass:GetClient(CharacterAttacker.Name) or ClientClass:GetClient(tostring(CharacterAttacker:GetAttribute("ID")))
	
	if not VictimClient.Character then return end
	if not AttackerClient.Character then return end
	
	local VunurabilityInfoVictim = VictimClient.ClientStates.VunurabilityInfo
	
	local IsParrying = VunurabilityInfoVictim["Parrying"]
	local IsBlocking = VunurabilityInfoVictim["Blocking"]
	
	local MaxPosture = VictimClient.ClientStates.MaxPosture.Value
	
	if IsParrying then
		-- Reward Posture
		
		local NewPosture = VictimClient.ClientStates.Posture.Value+PostureDamage
		StateClass:SetState(VictimClient.ClientStates.Posture, math.min(NewPosture, MaxPosture))
		Replicated.Remotes.Client.LandedParry:FireAllClients(VictimClient)
		Replicated.Remotes.Client.HitParry:FireAllClients(AttackerClient)
		module:Stun(2, 1, AttackerClient.Character)
		
		Replicated.Remotes.ReplicateSkill:FireAllClients("Parry", "SuccessfulParry", {VictimClient.Character, AttackerClient.Character})
		
		return
	elseif IsBlocking then
		
		local NewPosture = VictimClient.ClientStates.Posture.Value-PostureDamage
		local ClampedPosture = math.max(NewPosture, 0)
		
		if ClampedPosture < 1 then 
			
			local GBreakAnim = Replicated.Assets.Animations.BlockBreak
			local Humanoid = CharacterVictim:WaitForChild("Humanoid") :: Humanoid
			local Animator = Humanoid:WaitForChild("Animator") :: Animator
			local Track = Animator:LoadAnimation(GBreakAnim) :: AnimationTrack
			
			Track:Play()
			module:Stun(2, 1, VictimClient.Character)
			ClampedPosture = 100
		else
			StateClass:SetState(VictimClient.ClientStates.Posture, ClampedPosture)

			Replicated.Remotes.Client.LandedBlock:FireAllClients(VictimClient)
			Replicated.Remotes.Client.HitBlock:FireAllClients(AttackerClient)
			return
		end
	end
	
	local CurrentHealthValues = VictimClient.ClientStates.HealthValues

	local HealthValue = table.clone(CurrentHealthValues.Value) :: {[string] : number}
	HealthValue.Health = math.max(HealthValue.Health - Damage, 0)
	
	StateClass:SetState(CurrentHealthValues, HealthValue)
	module:Stun(StunLevel, StunDuration, VictimClient.Character)
	
	if VictimClient.Player then
		Replicated.Remotes.Client.TookDamage:FireClient(VictimClient.Player, HitPriority)
		Replicated.Remotes.Server.ClientTookDamage:Fire(VictimClient, HitPriority)
		Replicated.Remotes.Client.DealtDamage:FireAllClients(VictimClient.Character, Damage)
	end
	
	print(HealthValue)
	
	return true
	
end

--[[

STATES OF A CLIENT:

CharacterPlaying
HealthValues
Stuns
MaxPosture
Posture
Focus
VunurabilityInfo
Skills

--]]

return module
