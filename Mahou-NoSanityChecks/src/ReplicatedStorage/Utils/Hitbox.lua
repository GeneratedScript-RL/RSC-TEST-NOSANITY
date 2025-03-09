local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local module = {}

local OverlapParam = OverlapParams.new()
OverlapParam.FilterType = Enum.RaycastFilterType.Include
OverlapParam.FilterDescendantsInstances = {workspace.Alive}

function module:HitboxM1(part : BasePart, Cframe : CFrame, Character : Model)
	
	local NewHitbox = part:Clone()
	NewHitbox.Parent = workspace.Hitboxes
	NewHitbox.CFrame = Cframe
	
	Debris:AddItem(NewHitbox, .2)
	
	local listOfPartsInPart = workspace:GetPartsInPart(NewHitbox, OverlapParam)
	
	for index, part in listOfPartsInPart do
		if part:IsDescendantOf(Character) then
			table.remove(listOfPartsInPart, table.find(listOfPartsInPart, part)) 
		end
	end
	
	local charactersHit = {}
	
	for _, CharacterBodypart in listOfPartsInPart do
		local CharacterHit = CharacterBodypart:FindFirstAncestorWhichIsA("Model")
		local Humanoid = CharacterHit:FindFirstChild("Humanoid")
		
		if not Humanoid or not CharacterHit then continue end
		if table.find(charactersHit, CharacterHit) then continue end
		if CharacterHit == Character then continue end
		
		table.insert(charactersHit, CharacterHit)
	end
	
	return charactersHit
	
end

return module
