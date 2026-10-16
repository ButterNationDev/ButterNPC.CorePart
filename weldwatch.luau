local root = script.Parent
local welds = root.Welds
local sc = root.ScriptCommunication
local db = false
local dead = false
local clean = root.Parent.CleanupEvent
conn = welds.ChildRemoved:Connect(function()
	if not db and not dead then
		task.wait(0.1)
		sc:Fire("Speak","ouch")
		db = true
		task.delay(5,function()
			db = false
		end)
	end
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