local root = script.Parent
local butter = root.Parent
local sc = root.ScriptCommunication

local ismoving = false
local rayparam = RaycastParams.new()
rayparam.ExcludeInstances = butter:GetDescendants()
rayparam.RespectCanCollide = true
local overparam = OverlapParams.new()
overparam.ExcludeInstances = butter:GetDescendants()
overparam.RespectCanCollide = true

local function pathfind(range)
	local angles:{number} = {}
	for i = 0,24 do
		local yaw = math.rad(i * 15) + root.Rotation.Y
		local dir = Vector3.new(math.sin(yaw),0,math.cos(yaw)) * range
		
		local result = workspace:Raycast(root.Position + Vector3.yAxis * 2,dir,rayparam)
		if result == nil then
			table.insert(angles,yaw)
		end
		task.wait()
	end
	if #angles == 0 and range <= 10 then 
		sc:Fire("Speak","who trapped me here???")
		return false
	end
	local selected = angles[math.random(1,#angles) or 1]
	local newcframe = CFrame.new(root.CFrame.Position) * CFrame.Angles(0,selected,0)
	butter:PivotTo(newcframe)
	local move = task.spawn(function()
		ismoving = true
		while task.wait() do
			local dir = root.CFrame.LookVector
			root.AssemblyLinearVelocity = Vector3.new(
				dir.X * 8,
				root.AssemblyLinearVelocity.Y,
				dir.Z * 8
			)
		end
	end)
	task.delay(range / 8,function()
		task.cancel(move)
		ismoving = false
	end)
	return true
end
task.spawn(function()
	while butter do
		local parts = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0,0,-4),Vector3.new(3.5,3.5,4),overparam)
		local walls = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0,5,-4),Vector3.new(3.5,3,4),overparam)
		local floors = workspace:GetPartBoundsInBox(root.CFrame,Vector3.new(3,4.2,3),overparam)
		local canjump = true
		local sawbutter = false
		if #walls > 0 and #parts > 0 then
			canjump = false
		end
		for i = 1,#parts do
			if parts[i].Parent:HasTag("buttah") then
				sawbutter = true
			end
		end
		if ismoving and #parts > 0 and root.AssemblyLinearVelocity.Y < 0.1 and #floors > 0 then
			if sawbutter then
				sc:Fire("Speak","hello")
				return
			elseif not canjump then
				sc:Fire("Speak","there is a wall here")
				local newcframe = root.CFrame * CFrame.Angles(0,180,0)
				butter:PivotTo(newcframe)
				return
			else
				sc:Fire("Speak","i will jump")
				root.AssemblyLinearVelocity += Vector3.new(
					root.CFrame.LookVector.X,
					10,
					root.CFrame.LookVector.Z) * 7.5
			end
		end
		task.wait()
	end
end)
while butter do
	if pathfind(math.random(1,8) * 4) then
		task.wait(math.random(200,600) / 50)
	end
	task.wait()
end
