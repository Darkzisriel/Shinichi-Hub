if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local VIMVIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local AliveNotificaiotna, Nnnnnnotificvationui, ProfilePicture = {}, nil, ""
if DCWebhook == "" then DCWebhook = false end

local function CreateNotificationUI()
	if Nnnnnnotificvationui then return Nnnnnnotificvationui end
	Nnnnnnotificvationui = Instance.new("ScreenGui")
	Nnnnnnotificvationui.Name = "NotificationUI"
	Nnnnnnotificvationui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Nnnnnnotificvationui.Parent = game:GetService("CoreGui")
	return Nnnnnnotificvationui
end

local function MakeNotif(title, message, duration, color)
	local ui = CreateNotificationUI()
	color = color or Color3.fromRGB(255, 200, 0)
	duration = duration or 5
	local frame = Instance.new("Frame")
	frame.Size, frame.Position = UDim2.new(0, 250, 0, 80), UDim2.new(1, 50, 1, 10)
	frame.BackgroundColor3, frame.BorderSizePixel, frame.Parent = Color3.fromRGB(30, 30, 30), 0, ui
	local corner = Instance.new("UICorner", frame) corner.CornerRadius = UDim.new(0, 8)
	Instance.new("TextLabel", frame).Text, Instance.new("TextLabel", frame).TextSize = title, 18
	Instance.new("TextLabel", frame).Text, Instance.new("TextLabel", frame).TextSize = message, 16
	local colorBar = Instance.new("Frame", frame)
	colorBar.Size, colorBar.Position, colorBar.BackgroundColor3 = UDim2.new(0, 5, 1, 0), UDim2.new(0, 0, 0, 0), color
	Instance.new("UICorner", colorBar).CornerRadius = UDim.new(0, 8)
	local off = 0
	for _,v in pairs(AliveNotificaiotna) do if v.Instance and v.Instance.Parent then off = off + v.Instance.Size.Y.Offset+10 end end
	local target = UDim2.new(1,-270,1,-90-off)
	table.insert(AliveNotificaiotna,{Instance=frame,ExpireTime=os.time()+duration})
	game:GetService("TweenService"):Create(frame,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Position=target}):Play()
	task.spawn(function() task.wait(duration) frame:Destroy() end)
	return frame
end

local function GetProfilePicture()
	local PlayerID=Players.LocalPlayer.UserId
	local req = request or http_request or syn.request
	local res = req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..PlayerID.."&size=180x180&format=png",Method="GET"})
	local start, end_ = string.find(res.Body, "https://[%w-_%.%?%.:/%+=&]+")
	if start and end_ then ProfilePicture = string.sub(res.Body,start,end_) else ProfilePicture = "https://cdn.sussy.dev/bleh.jpg" end
end

if DCWebhook then GetProfilePicture() end

local function SendWebhook(title, desc, color, pfp, footer)
	if not DCWebhook then return end
	local req = request or http_request or syn.request
	local success,msg = pcall(function()
		req({
			Url=DCWebhook, Method="POST",
			Headers={["Content-Type"]="application/json"},
			Body=HttpService:JSONEncode({
				username=Players.LocalPlayer.DisplayName, avatar_url=pfp,
				embeds={{title=title,description=desc,color=color,footer={text=footer}}}
			})
		})
	end)
	if not success then print("Webhook failed: "..msg) end
end

local function VisualizePivot(model)
	local pivot=model:GetPivot()
	for _,info in ipairs({
		{pivot.LookVector,Color3.fromRGB(0,255,0),"Front"},
		{-pivot.LookVector,Color3.fromRGB(255,0,0),"Back"},
		{pivot.RightVector,Color3.fromRGB(255,255,0),"Right"},
		{-pivot.RightVector,Color3.fromRGB(0,0,255),"Left"},
	}) do
		local part=Instance.new("Part")
		part.Anchored, part.CanCollide, part.Color= true, false, info[2]
		part.Position = pivot.Position+info[1]*5
		part.Size, part.Parent= Vector3.new(1,1,1), workspace
	end
end

local function teleportToRandomServer()
	local Counter,MaxRetry,RetryDelay=0,10,10
	local req=http_request or request or syn.request
	if req then
		local url="https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"
		while Counter<MaxRetry do
			local succ,res=pcall(function() return req({Url=url,Method="GET"}) end)
			if succ and res and res.Body then
				local data=HttpService:JSONDecode(res.Body)
				if data and data.data and #data.data>0 then
					local server=data.data[math.random(1,#data.data)]
					if server.id then
						MakeNotif("Teleporting..","Server: "..server.id,5,Color3.fromRGB(115,194,89))
						TeleportService:TeleportToPlaceInstance(18687417158,server.id,Players.LocalPlayer)
						return
					end
				end
			end
			Counter=Counter+1
			MakeNotif("Retrying","Attempt "..Counter,5,Color3.fromRGB(255,0,0))
			task.wait(RetryDelay)
		end
	end
end

task.delay(2.5,function()
	pcall(function()
		local t=Players.LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local m,s=t:match("(%d+):(%d+)")
		local total=tonumber(m)*60+tonumber(s)
		MakeNotif("Round ends in",total.." seconds",5,Color3.fromRGB(115,194,89))
		if total>90 then teleportToRandomServer() end
	end)
end)

local function findGenerators()
	local folder=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map=folder and folder:FindFirstChild("Map")
	local list={}
	if map then
		for _,g in ipairs(map:GetChildren()) do
			if g.Name=="Generator" and g.Progress.Value<100 then table.insert(list,g) end
		end
	end
	return list
end

local function InGenerator()
	for _,v in ipairs(Players.LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		if string.sub(v.Name,1,3)=="Gen" then return false end
	end
	return true
end

local function DoAllGenerators()
	for _,g in ipairs(findGenerators()) do
		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			Players.LocalPlayer.Character.HumanoidRootPart.CFrame = g:GetPivot()+g:GetPivot().LookVector*3
			VisualizePivot(g)
			task.wait(0.5)
			local prompt=g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
			if prompt then
				fireproximityprompt(prompt)
				task.wait(0.5)
				if not InGenerator() then
					for _,pos in ipairs({g:GetPivot().Position - g:GetPivot().RightVector*3, g:GetPivot().Position + g:GetPivot().RightVector*3}) do
						Players.LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(pos)
						task.wait(0.25)
						fireproximityprompt(prompt)
						if InGenerator() then break end
					end
				end
			end
			for i=1,6 do
				if g.Progress.Value<100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
					g.Remotes.RE:FireServer()
				end
				if i<6 and g.Progress.Value<100 then task.wait(GenTime) end
			end
		end
	end
	SendWebhook("Autofarm Done","Finished generators!",0x00FF00,ProfilePicture,".gg/fartsaken")
	task.wait(1)
	teleportToRandomServer()
end

local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(c)
		task.wait(1)
		if c==Players.LocalPlayer.Character then task.wait(4) DoAllGenerators() end
	end)
end

local function DidiDie()
	while task.wait(0.5) do
		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			if Players.LocalPlayer.Character.Humanoid.Health==0 then
				SendWebhook("Died","Killer killed me!",0xFF0000,ProfilePicture,".gg/fartsaken")
				task.wait(0.5)
				teleportToRandomServer()
				break
			end
		end
	end
end

pcall(task.spawn,DidiDie)
AmIInGameYet()
