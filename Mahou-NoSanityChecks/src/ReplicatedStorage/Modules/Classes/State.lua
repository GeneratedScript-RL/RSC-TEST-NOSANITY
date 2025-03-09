--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local StateClass = {}

function StateClass.new(InitialValue: any): Types.State
	local NewState = {
		Value = InitialValue,
		stateChanged = Instance.new("BindableEvent", Replicated.StateBindables),
	} :: Types.State
	
	return NewState
end

function StateClass:SetState(State : Types.State, any)
	
	State.Value = any
	State.stateChanged:Fire()
end

return StateClass
