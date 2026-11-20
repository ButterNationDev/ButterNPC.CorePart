if not scriptType then return
if scriptType = "Main" then
    local root = script.Parent
    local butter = root.Parent
    local RawButterID = math.random(0,99999999)
    local butterID = "butter_" .. string.rep("0",8 - #tostring(RawButterID)) .. tostring(RawButterID)
    butter.Name = butterID
    local fakeChat = game.ReplicatedStorage.ChatRemotes.FakeMessage
    local sc = root.ScriptCommunication
    local currentmsg = ""
    local function displayMessage(message:string)
    	  if message == currentmsg then return end
	      local billboard = root:FindFirstChild("MessageGUI")
      	billboard.TextLabel.Visible = true
      	billboard.TextLabel.Text = message
       	currentmsg = message
      	task.delay(5,function()
            billboard.TextLabel.Visible = false
	        	currentmsg = ""
      	end)
        fakeChat:Fire(butterID,message,BrickColor.new("Daisy orange").Color)
    end
    if math.random(1,2) == 1 then
	      displayMessage("hello")
    else
	      displayMessage("hi")
    end
    sc.Event:Connect(function(action,extrainfo)
	      if action == "Speak" then
		        displayMessage(extrainfo)
	      elseif action == "Dead" then
		        displayMessage("dead")
	      end
    end)
elseif scriptType = "PFind" then
    local root = script.Parent
local butter = root.Parent
local sc = root.ScriptCommunication

local ismoving = false
local rayparam = RaycastParams.new()
rayparam.ExcludeInstances = butter:GetDescendants()
rayparam.RespectCanCollide = true
rayparam.IgnoreWater = true
local overparam = OverlapParams.new()
overparam.ExcludeInstances = butter:GetDescendants()
overparam.RespectCanCollide = true

local function add_with_weight(t,e,w)
	for i = 1, w do
		table.insert(t,e)
	end
end
local function pathfind(range)
	local angles:{number} = {}
	for i = 0,36 do
		local yaw = math.rad(i * 5) + root.Rotation.Y - math.rad(90)
		local dir = Vector3.new(math.sin(yaw),0,math.cos(yaw)) * range

		local result = workspace:Raycast(root.Position + Vector3.yAxis * 2,dir,rayparam)
		if result == nil then
			if workspace:Raycast(root.CFrame.Position + dir, Vector3.yAxis * -6, rayparam) ~= nil then
				add_with_weight(angles,yaw,3)
			end
		end
		task.wait()
	end
	if #angles <= 0 then
		if range <= 10 then
			return false
		else
			pathfind(range - 5)
		end
	end
	local selected = angles[math.random(math.min(1,#angles),#angles) or 1]
	local newcframe = CFrame.new(root.CFrame.Position) * CFrame.Angles(0,selected or 0,0)
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
		local parts = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0,0,-4),Vector3.new(3.99,3.9,5),overparam)
		local walls = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0,5,-4),Vector3.new(5,5,7),overparam)
		local floors = workspace:GetPartBoundsInBox(root.CFrame,Vector3.new(3,4.2,3),overparam)
		local frontfloors = workspace:GetPartBoundsInBox(CFrame.new(root.Position + root.CFrame.LookVector.Unit * 5,root.Orientation),Vector3.new(3,4.2,3),overparam)
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
				sc:Fire("Speak","hello butter")
			elseif not canjump then
				local newcframe = root.CFrame * CFrame.Angles(0,180,0)
				butter:PivotTo(newcframe)
			else
				root.AssemblyLinearVelocity += Vector3.new(
					root.CFrame.LookVector.X * 100,
					60,
					root.CFrame.LookVector.Z * 100)
			end
		end
		if #frontfloors <= 0 then
			local newcframe = root.CFrame * CFrame.Angles(0,180,0)
			butter:PivotTo(newcframe)
		end
		task.wait()
	end
end)
while butter do
	if pathfind(40) then
		task.wait(math.random(200,300) / 200)
	end
	task.wait()
end
elseif scriptType = "WWatch" then
    local root = script.Parent
local welds = root.Welds
local sc = root.ScriptCommunication
local db = false
local dead = false
local clean = root.Parent.CleanupEvent
conn = welds.ChildRemoved:Connect(function(weld:WeldConstraint)
	if not db and not dead then
		task.wait(0.1)
		sc:Fire("Speak","ouch")
		db = true
		task.delay(5,function()
			db = false
		end)
	end
	local hurt = weld.Part1
	hurt.Parent = root.Parent.Parent
	task.delay(5,function() hurt:Destroy() end)
end)
while task.wait() do
	if #welds:GetChildren() < 20 then
		task.spawn(function()
			task.wait(5)
			root.Parent:Destroy()
		end)
		sc:Fire("Dead")
		dead = true
		conn:Disconnect()
		clean:Fire()
		root:Destroy()
		break
	end
end
end

    
