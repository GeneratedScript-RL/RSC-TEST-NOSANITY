--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)
local State = require(script.Parent.State)

local ClientClass = {}
ClientClass.Clients = {}

function ClientClass.new(Entity : Player | Model)
	local NewClient
	
	if Entity:IsA("Player") then
		NewClient = {
			Player = Entity,
			Character = Entity.Character or Entity.CharacterAdded:Wait(),
			ClientStates = {},
		} :: Types.Client

		ClientClass.Clients[Entity.Name] = NewClient
	elseif Entity:IsA("Model") then
		NewClient = {
			Player = nil,
			Character = Entity,
			ClientStates = {},
		} :: Types.Client

		ClientClass.Clients[tostring(Entity:GetAttribute("ID"))] = NewClient
	end

	return NewClient
end

function ClientClass:GetClient(ClientName : string)
	return ClientClass.Clients[ClientName]
end

function ClientClass:CreateState(Client : Types.Client, stateName : string, value : any)
	local Newstate = State.new(value)
	Client.ClientStates[stateName] = Newstate
	
	return Newstate
end

return ClientClass
