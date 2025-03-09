--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

return {
	Cooldown = 3,
	Passives = {},
	Skills = {},
	SkillComponent = "Dash",
	ClientRenderer = "Dash",
	ActionLevel = 1,
	Duration = .5,
} 