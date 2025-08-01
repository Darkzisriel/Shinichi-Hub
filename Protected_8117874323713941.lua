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
	title = title or "Notification"
	message = message or ""
	duration = duration or 5
	color = color or Color3.fromRGB(255, 200, 0)
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 250, 0, 80)
	notification.Position = UDim2.new(1, 50, 1, 10)
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	notification.BorderSizePixel = 0
	notification.Parent = ui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification
	local SIGMABERFIOENEW = Instance.new("TextLabel")
	SIGMABERFIOENEW.Name = "Title"
	SIGMABERFIOENEW.Size = UDim2.new(1, -25, 0, 25)
	SIGMABERFIOENEW.Position = UDim2.new(0, 15, 0, 5)
	SIGMABERFIOENEW.Font = Enum.Font.SourceSansBold
	SIGMABERFIOENEW.Text = title
	SIGMABERFIOENEW.TextSize = 18
	SIGMABERFIOENEW.TextColor3 = color
	SIGMABERFIOENEW.BackgroundTransparency = 1
	SIGMABERFIOENEW.TextXAlignment = Enum.TextXAlignment.Left
	SIGMABERFIOENEW.Parent = notification
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, -25, 0, 50)
	messageLabel.Position = UDim2.new(0, 15, 0, 30)
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.Text = message
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notification
	local colorBar = Instance.new("Frame")
	colorBar.Name = "ColorBar"
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.Position = UDim2.new(0, 0, 0, 0)
	colorBar.BackgroundColor3 = color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = notification
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = colorBar
	local offsit = 0
	for _, notif in pairs(AliveNotificaiotna) do
		if notif.Instance and notif.Instance.Parent then
			offsit = offsit + notif.Instance.Size.Y.Offset + 10
		end
	end
	local tagit = UDim2.new(1, -270, 1, -90 - offsit)
	table.insert(AliveNotificaiotna, {
		Instance = notification,
		ExpireTime = os.time() + duration,
	})
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local ok = game:GetService("TweenService"):Create(notification, tweenInfo, { Position = tagit })
	ok:Play()
	task.spawn(function()
		task.wait(duration)
		local tweenOut = game:GetService("TweenService"):Create(
			notification,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset) }
		)
		tweenOut:Play()
		tweenOut.Completed:Wait()
		for i, notif in pairs(AliveNotificaiotna) do
			if notif.Instance == notification then
				table.remove(AliveNotificaiotna, i)
				break
			end
		end
		notification:Destroy()
		task.wait()
		local currentOffset = 0
		for _, notif in pairs(AliveNotificaiotna) do
			if notif.Instance and notif.Instance.Parent then
				game:GetService("TweenService")
					:Create(
						notif.Instance,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -270, 1, -90 - currentOffset) }
					)
					:Play()
				currentOffset = currentOffset + notif.Instance.Size.Y.Offset + 10
			end
		end
	end)
	return notification
end

task.spawn(function()
	while task.wait(1) do
		local currentTime = os.time()
		local reposition = false
		for i = #AliveNotificaiotna, 1, -1 do
			local notif = AliveNotificaiotna[i]
			if currentTime > notif.ExpireTime and notif.Instance and notif.Instance.Parent then
				notif.Instance:Destroy()
				table.remove(AliveNotificaiotna, i)
				reposition = true
			end
		end
		if reposition then
			local currentOffset = 0
			for _, notif in pairs(AliveNotificaiotna) do
				if notif.Instance and notif.Instance.Parent then
					notif.Instance.Position = UDim2.new(1, -270, 1, -90 - currentOffset)
					currentOffset = currentOffset + notif.Instance.Size.Y.Offset + 10
				end
			end
		end
	end
end)

MakeNotif("Strawberry Cat Hub", "Script Loaded!", 5, Color3.fromRGB(115, 194, 89))

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
	local pivot = model:GetPivot()
	for i, dir in ipairs({
		{ pivot.LookVector, Color3.fromRGB(0, 255, 0), "Front" },
		{ -pivot.LookVector, Color3.fromRGB(255, 0, 0), "Back" },
		{ pivot.RightVector, Color3.fromRGB(255, 255, 0), "Right" },
		{ -pivot.RightVector, Color3.fromRGB(0, 0, 255), "Left" },
	}) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Color = dir[2]
		part.Name = dir[3]
		part.Position = pivot.Position + dir[1] * 5
		part.Parent = workspace
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
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				local playersNearby = false
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= Players.LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
						playersNearby = true
					end
				end
				if not playersNearby then
					table.insert(generators, g)
				end
			end
		end
	end
	return generators
end

local function GetFurthestGenerator()
	local furthest, maxDistance = nil, 0
	if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local myPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
		for _, g in ipairs(findGenerators()) do
			local dist = (g:GetPivot().Position - myPos).Magnitude
			if dist > maxDistance then
				furthest = g
				maxDistance = dist
			end
		end
	end
	return furthest
end

local function CheckNearbyKillerAndRun()
	while task.wait(0.5) do
		if #workspace.Players:WaitForChild("Killers"):GetChildren() >= 1 then
			for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
				local char = Players.LocalPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") and killer:FindFirstChild("HumanoidRootPart") then
					local dist = (killer.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
					if dist <= 100 then
						local furthestGen = GetFurthestGenerator()
						if furthestGen then
							char.HumanoidRootPart.CFrame = furthestGen:GetPivot() + furthestGen:GetPivot().LookVector*3
							MakeNotif("Warning", "Killer nearby! Teleported to furthest generator.", 5, Color3.fromRGB(255, 100, 100))
						end
					end
				end
			end
		end
	end
end

local function InGenerator()
	for i, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		if string.sub(v.Name, 1, 3) == "Gen" then
			return false
		end
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
						task.wait(1)
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
	SendWebhook("Autofarm Done","Finished generators!",0x00FF00,ProfilePicture,"Strawberry Cat Hub")
	task.wait(1)
	teleportToRandomServer()
end

local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child == game:GetService("Players").LocalPlayer.Character then
			task.wait(4)
			DoAllGenerators()
		end
	end)
end

local function DidiDie()
	while task.wait(0.5) do
		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			if Players.LocalPlayer.Character.Humanoid.Health==0 then
				SendWebhook("Died","Killer killed me!",0xFF0000,ProfilePicture,"Strawberry Cat Hub")
				task.wait(0.5)
				teleportToRandomServer()
				break
			end
		end
	end
end

pcall(task.spawn,DidiDie)
pcall(task.spawn,CheckNearbyKillerAndRun)
AmIInGameYet()
