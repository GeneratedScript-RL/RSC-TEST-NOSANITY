--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local InputHandler = require(script.Parent.Parent.InputHandler)

local module = {} :: Types.SkillComponent

local InputBind = Enum.UserInputType.MouseButton1

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Hitbox = require(Replicated.Utils.Hitbox)
local Combat = require(Replicated.Utils.Combat)

local M1SetInfo = require(Replicated.GameStats.DefaultSet)

local AnimationFolder = M1SetInfo.AnimationFolder

function module.AssignSkill(Client : Types.Client)
	local Signal : RBXScriptSignal = InputHandler:DetectInput(InputBind, Client)

	Signal:Connect(function(player)
		if player == Client.Player then else return end
		module.ActivateSkill(Client)
	end)

	if Client.Player then
		Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "M1", "AssignSkill", {Client})
	else

	end

	local SkillStates = {
		M1 = 0,
		IsM1ing = false,
		IsOnCooldown = false,
		M1Id = 0,
	}

	ClientClass:CreateState(Client, "M1SkillStates", SkillStates)

end

function module.ActivateSkill(Client : Types.Client)
	local State = Client.ClientStates["M1SkillStates"].Value
	local char = Client.Character

	if not char then return end
	if State.IsM1ing or State.IsOnCooldown then return end
	if Client.ClientStates["ActionLevel"].Value[1] < M1SetInfo.M1Priority then else return end
	if Client.ClientStates.CurrentStunLevel.Value > 1 then return end

	local rootpart = char:WaitForChild("HumanoidRootPart") :: BasePart

	local NewM1Count = State.M1+1
	local AddDelay = 0
	if NewM1Count > M1SetInfo.ComboCount then
		NewM1Count = 1
	elseif NewM1Count == M1SetInfo.ComboCount then
		AddDelay = M1SetInfo.CooldownPerM1*4
	end

	local NewSkillState = {
		M1 = NewM1Count,
		IsM1ing = true,
		IsOnCooldown = true,
		M1Id = math.random(1, 10000)*math.random(-10, 10),
	}

	StateClass:SetState(Client.ClientStates["ActionLevel"], {M1SetInfo.M1Priority, NewSkillState.M1Id})
	StateClass:SetState(Client.ClientStates["M1SkillStates"], NewSkillState)
	Replicated.Remotes.ReplicateSkill:FireClient(Client.Player, "M1", "ActivateSkill", {Client, NewSkillState})

	local ShouldContinue = true

	local c = Replicated.Remotes.Server.ClientTookDamage.Event:Connect(function(VictimClient : Types.Client, HitPriority)
		if VictimClient == Client and HitPriority >= M1SetInfo.M1Priority then
			ShouldContinue = false
		end
	end)

	task.delay(M1SetInfo.CooldownPerM1, function()
		StateClass:SetState(Client.ClientStates["ActionLevel"], {0,0})
		module.SkillEnd(Client, NewSkillState, AddDelay)
	end)

	task.wait(M1SetInfo.WindupTime)

	c:Disconnect()

	task.delay(M1SetInfo.Decay, function()
		local NewCurStateM1 = Client.ClientStates["M1SkillStates"].Value

		if NewCurStateM1.M1Id == NewSkillState.M1Id then
			print("decay")
			Client.ClientStates["M1SkillStates"].Value.M1 = 0
		end
	end)

	-- DAMAGE SHIT
	if not ShouldContinue then return end

	local CFrame = rootpart.CFrame * CFrame.new(0,0,-(script.Hitbox.Size.Z/2))
	local hitVictims = Hitbox:HitboxM1(script.Hitbox, CFrame, char)

	local DmgTable = M1SetInfo.Damage :: {number}

	Replicated.Remotes.ReplicateSkill:FireAllClients("M1", "M1HitFX", hitVictims)

	for _, Victim in hitVictims do

		Combat:Damage(Victim, char, DmgTable[NewM1Count], M1SetInfo.Stun, 1, M1SetInfo.M1Priority, M1SetInfo.PostureDamage, M1SetInfo.FocusReward)
	end

end

function module.SkillEnd(Client : Types.Client, NewState : {[string] : any}, AddedDelay : number)
	task.delay(M1SetInfo.CooldownPerM1 + AddedDelay, function()
		local NewSkillState = {
			M1 = NewState.M1,
			IsM1ing = false,
			IsOnCooldown = false,
			M1Id = NewState.M1Id,
		}

		StateClass:SetState(Client.ClientStates["M1SkillStates"], NewSkillState)
	end)
end

function module.RemoveSkill(Client : Types.Client)
	print(Client)
end

return module
