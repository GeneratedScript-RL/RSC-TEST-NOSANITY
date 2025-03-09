--!strict

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))
local Types = require(Replicated.GlobalTypes)

Replicated.Remotes.Server.NewCharacter.Event:Connect(function(character : Model)
	character.Parent = workspace.Alive
	
	local WalkspeedFolder = Instance.new("Folder", character)
	WalkspeedFolder.Name = "WalkspeedModifiers"
end)
