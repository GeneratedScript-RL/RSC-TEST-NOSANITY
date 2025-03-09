local Replicated = game:GetService("ReplicatedStorage")

local Remotes = Replicated:FindFirstChild("Remotes"):FindFirstChild("Client")

local CurrentHurtVariant = 1
local HurtAnims : {Animation} = Replicated.Assets.Animations.Pain:GetChildren()

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChildWhichIsA("Animator")

Remotes.TookDamage.OnClientEvent:Connect(function()
	local HurtAnim = HurtAnims[CurrentHurtVariant]
	CurrentHurtVariant += 1
	
	if CurrentHurtVariant > 3 then
		CurrentHurtVariant = 1
	end
	
	local HurtTrack = Animator:LoadAnimation(HurtAnim)
	HurtTrack:Play()
end)