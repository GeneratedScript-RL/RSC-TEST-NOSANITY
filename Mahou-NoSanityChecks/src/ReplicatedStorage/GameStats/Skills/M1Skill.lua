--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)
local M1 = require(Replicated.GameStats.DefaultSet)

return {
	Cooldown = M1.CooldownPerM1,
	Damage = M1.Damage,
	Passives = {},
	Skills = {},
	SkillComponent = "M1Functionality",
	ClientRenderer = "M1",
	ActionLevel = 1,
} :: Types.Skill