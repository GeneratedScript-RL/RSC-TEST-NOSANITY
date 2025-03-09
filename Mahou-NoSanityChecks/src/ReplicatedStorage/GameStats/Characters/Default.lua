--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)
local M1Set = require(script.Parent.Parent.DefaultSet)

local M1Skill = require(script.Parent.Parent.Skills.M1Skill)
local Parry = require(script.Parent.Parent.Skills.Parry)
local Flow = require(script.Parent.Parent.Skills.Flowing)
local MiyabiTwo = require(script.Parent.Parent.Skills.MiyabiTwo)
local Dash = require(script.Parent.Parent.Skills.Dash)

return {
	HealthValues = {
		Max = 200,
		Health = 200,
	},
	M1Set = M1Set,
	Skills = {M1Skill, Parry, Flow, MiyabiTwo, Dash},
	AutoAssignedPassives = {},
	Walkspeed = 10,
	Posture = 100,
}