--!strict
local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

local module = {}

function module:DetectInput(InputType : Enum.KeyCode | Enum.UserInputType, Client : Types.Client)
	local Remote : RemoteEvent = Replicated.Remotes.InputRemotes:FindFirstChild(InputType.Name)
	if not Remote then
		Remote = Instance.new('RemoteEvent', Replicated.Remotes.InputRemotes)
	end
	Remote.Name = InputType.Name
	
	if Client.Player then
		Replicated.Remotes.DetectInput:FireClient(Client.Player, InputType)
	else
		
	end
	return Remote.OnServerEvent
end

return module
