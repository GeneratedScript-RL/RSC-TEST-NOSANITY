local Replicated = game:GetService("ReplicatedStorage")

local Modules = Replicated:FindFirstChild("Modules")
local Classes = Modules:FindFirstChild("Classes")

local Types = require(Replicated.GlobalTypes)

local ClientClass = require(Classes:FindFirstChild("Client"))
local StateClass = require(Classes:FindFirstChild("State"))

local player = game.Players.LocalPlayer
local Renderers = script:FindFirstChild("ClientSkillRenderers")

Replicated.Remotes.ReplicateSkill.OnClientEvent:Connect(function(SkillModuleName, FunctionName, Parameters : {any})
	require(Renderers[SkillModuleName])[FunctionName](Parameters)
end)