--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local module = {}

local InputBind = Enum.UserInputType.MouseButton1

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))

local M1SetInfo = require(Replicated.GameStats.DefaultSet)
local AnimationFolder = M1SetInfo.AnimationFolder

local player = game.Players.LocalPlayer

export type SkillInfo = {
	M1 : number
}

local AnimationTracks = {
	Character = nil,
	Tracks = {},
}

local function UpdateAnims()
	local character = player.Character or player.Character:Wait()

	local Humanoid : Humanoid = character:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	
	local Anims : {Animation} = AnimationFolder:GetChildren() :: {Animation}
	
	for _, Anim : Animation in Anims do
		
		AnimationTracks.Tracks[Anim.Name] = Animator:LoadAnimation(Anim)
		AnimationTracks.Tracks[Anim.Name].Priority = Enum.AnimationPriority.Action2
	end
end

function module.AssignSkill(Parameters)
	UpdateAnims()
end

function module.ActivateSkill(Parameters : {any})
	local character = player.Character or player.CharacterAdded:Wait()
	
	local Client : Types.Client = Parameters[1]
	local SkillState = Parameters[2] :: SkillInfo
	local M1State = tostring(SkillState.M1) or "1"
	local Animation = AnimationFolder:FindFirstChild(tostring(M1State)) :: Animation
	
	if AnimationTracks.Character == character then else
		UpdateAnims()
	end
	
	if not Animation then return end
	
	local Track : AnimationTrack = AnimationTracks.Tracks[tostring(M1State)]
	Track:Play()
	
	local currentLength = Track.Length
	local newSpeed = currentLength / M1SetInfo.DurationPerM1
	Track:AdjustSpeed(newSpeed)
	
	local Connection = Replicated.Remotes.Client.TookDamage.OnClientEvent:Connect(function(HitPriority : number)
		if HitPriority >= M1SetInfo.M1Priority then
			Track:Stop()
		end
	end)
	
	Track.Ended:Wait()
	Connection:Disconnect()
end

function module.M1HitFX(Parameters : {any})
	for _, Victim : Model in Parameters do
		local NewAttachment = Instance.new('Attachment', Victim.PrimaryPart)
		
		for _, ParticleEmitter in M1SetInfo.HitFXFolder:GetChildren() do
			if ParticleEmitter:IsA("ParticleEmitter") then else continue end
			
			local pe = ParticleEmitter:Clone() :: ParticleEmitter
			pe.Parent = NewAttachment
			
			pe:Emit(pe:GetAttribute("EmitCount"))
		end
		
		Debris:AddItem(NewAttachment, 1)
	end
end

function module.SkillEnd(player : Player)
	print(player)
end

function module.RemoveSkill(player : Player)
	print(player)
end

return module
