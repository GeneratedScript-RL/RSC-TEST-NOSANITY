local Replicated = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local DetectedInputs : {} = {

}

Replicated.Remotes.DetectInput.OnClientEvent:Connect(function(input)
	table.insert(DetectedInputs, input)
	print(DetectedInputs)
end)

UIS.InputBegan:Connect(function(i, g)
	if g then return end

	if table.find(DetectedInputs, i.UserInputType) then
		local name : Enum.UserInputType = i.UserInputType.Name
		local Remote : RemoteEvent = Replicated.Remotes.InputRemotes:FindFirstChild(name)

		if not Remote then return end

		Remote:FireServer()
	elseif table.find(DetectedInputs, i.KeyCode) then
		local name : Enum.KeyCode = i.KeyCode.Name
		local Remote : RemoteEvent = Replicated.Remotes.InputRemotes:FindFirstChild(name)

		if not Remote then return end
		Remote:FireServer({UIS:IsKeyDown(Enum.KeyCode.W)})
		-- some abilities have diff behaviour based on held keys
	end
end)
