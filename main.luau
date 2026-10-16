local root = script.Parent
local butter = root.Parent
local RawButterID = math.random(0,99999999)
local butterID = "butter_" .. string.rep("0",8 - #tostring(RawButterID)) .. tostring(RawButterID)
butter.Name = butterID
local fakeChat = game:GetService("ReplicatedStorage"):WaitForChild("ChatRemotes"):WaitForChild("FakeMessage")
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