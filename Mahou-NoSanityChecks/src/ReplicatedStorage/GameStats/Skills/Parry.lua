--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

return {
	Cooldown = 3,
	ParryWindow = .3,
	BlockAutoWindow = .6,
	Passives = {},
	Skills = {},
	ClientRenderer = "Parry",
	SkillComponent = "ParryFunctionality",
	ActionLevel = 1,
}