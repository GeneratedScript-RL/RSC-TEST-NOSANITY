--!strict

local Replicated = game:GetService("ReplicatedStorage")

local Types = require(Replicated.GlobalTypes)

return {
	ComboCount = 5,
	AnimationFolder = Replicated.Assets.Animations.Fists,
	HitFXFolder = Replicated.Assets.VFX.Fists.HitVFX,
	DurationPerM1 = .5,
	CooldownPerM1 = .25,
	WindupTime = 0.25,
	Damage = {4, 5, 6, 7, 8},
	FocusReward = 10,
	M1Priority = 1,
	Stun = 2,
	Decay = 1.1,
	PostureDamage = 10,
	M1Priority = 1,
} :: Types.M1Set