local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local CollisionGroupName = "Characters"
PhysicsService:RegisterCollisionGroup(CollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(CollisionGroupName, CollisionGroupName, false)

local function setCollisionGroup(model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = CollisionGroupName
		end
	end
end

local Alive = workspace:WaitForChild("Alive")

for _, Model in Alive:GetChildren() do
	Model = Model :: Model
	setCollisionGroup(Model)
	
	for _, part in Model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Massless = true
		end
	end
end

Alive.ChildAdded:Connect(function(Model)
	setCollisionGroup(Model)
	for _, part in Model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Massless = true
		end
	end
end)