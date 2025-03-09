--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

return {
	Cooldown = 3,
	Damage = 3,
	Passives = {},
	Skills = {},
	SkillComponent = "Flowing",
	ClientRenderer = "Flowing",
	ActionLevel = 2,
	Duration = 2,
	Stun = 2,
	Focus = 2,
	Priority = 1,
	Posture = 10,
}