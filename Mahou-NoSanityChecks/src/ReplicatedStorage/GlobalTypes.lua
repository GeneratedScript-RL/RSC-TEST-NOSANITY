local module = {}

export type Skill = {
	Cooldown : number,
	Damage : number | {number},
	Passives : {Passive},
	Skills : {Skill},
	SkillComponent : SkillComponent | string,
	ClientRenderer : string,
	Stun : number,
	ActionLevel : number,
	Focus : number,
}

export type SkillComponent = {
	AssignSkill : (Client, any) -> (),
	ActivateSkill : (Client, any, any) -> (),
	SkillEnd : (Client, any, any) -> (),
	RemoveSkill : (Client, any, any) -> (),
}

export type Passive = {
	
}

export type M1Set = {
	ComboCount : number,
	AnimationFolder : Folder,
	DurationPerM1 : number,
	CooldownPerM1 : number,
	WindupTime : number,
	Damage : {number} | number,
	Stun : number,
	M1Priority : number,
	FocusReward : number,
	PostureDamage : number,
	HitFXFolder : Folder,
	Decay : number,
}

export type PlayableCharacter = {
	HealthValues : HealthValue,
	M1Set : M1Set,
	Skills : {Skill},
	AutoAssignedPassives : {Passive},
	Walkspeed : number,
	Posture : number,
}

export type Stun = {
	StunLevel : number,
	Duration : number,
}

export type State = {
	stateChanged : BindableEvent,
	Value : any,
}

export type HealthValue = {
	Health : number,
	Max : number,
}

export type Client = {
	Player : Player | nil,
	Character : Model?,
	ClientStates : {[string]: State},
}

return module
