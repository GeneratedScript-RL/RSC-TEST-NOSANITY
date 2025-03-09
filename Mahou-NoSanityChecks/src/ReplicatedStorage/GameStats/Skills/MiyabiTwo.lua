--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

return {
	Cooldown = 3,
	Damage = 10,
	Passives = {},
	Skills = {},
	SkillComponent = "MiyabiTwo",
	ClientRenderer = "MiyabiTwo",
	ActionLevel = 2,
	Duration = 2,
	Stun = 2,
	Focus = 2,
	Priority = 1,
	Posture = 10,
}