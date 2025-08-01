if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local AliveNotifs, ProfilePicture, NotifUI = {}, "", nil

-- UI Notification
local function CreateNotificationUI()
	if NotifUI then return NotifUI end
	NotifUI = Instance.new("ScreenGui", game.CoreGui)
	NotifUI.Name = "NotificationUI"
	NotifUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return NotifUI
end

local function MakeNotif(title, message, duration, color)
	local ui = CreateNotificationUI()
	local notif = Instance.new("Frame", ui)
	notif.Size = UDim2.new(0, 250, 0, 80)
	notif.Position = UDim2.new(1,50,1,10)
	notif.BackgroundColor3 = Color3.fromRGB(30,30,30)
	notif.BorderSizePixel = 0
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)

	local titleLabel = Instance.new("TextLabel", notif)
	titleLabel.Size = UDim2.new(1,-25,0,25)
	titleLabel.Position = UDim2.new(0,15,0,5)
	titleLabel.Text = title or "Notification"
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextColor3 = color or Color3.fromRGB(255,200,0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local msgLabel = Instance.new("TextLabel", notif)
	msgLabel.Size = UDim2.new(1,-25,0,50)
	msgLabel.Position = UDim2.new(0,15,0,30)
	msgLabel.Text = message or ""
	msgLabel.TextSize = 16
	msgLabel.Font = Enum.Font.SourceSans
	msgLabel.TextColor3 = Color3.fromRGB(255,255,255)
	msgLabel.BackgroundTransparency = 1
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextWrapped = true

	local bar = Instance.new("Frame", notif)
	bar.Size = UDim2.new(0,5,1,0)
	bar.BackgroundColor3 = color or Color3.fromRGB(255,200,0)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

	-- Animation
	local offset = 0
	for _,v in ipairs(AliveNotifs) do offset=offset+v.Instance.Size.Y.Offset+10 end
	table.insert(AliveNotifs,{Instance=notif,ExpireTime=os.time()+duration})
	local toPos=UDim2.new(1,-270,1,-90 - offset)
	TweenService:Create(notif,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Position=toPos}):Play()

	task.spawn(function()
		task.wait(duration or 5)
		TweenService:Create(notif,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Position=UDim2.new(1,50,notif.Position.Y.Scale,notif.Position.Y.Offset)}):Play()
		task.wait(0.5)
		notif:Destroy()
		for i,v in ipairs(AliveNotifs) do if v.Instance==notif then table.remove(AliveNotifs,i) break end end
		-- Re-align
		local curr=0
		for _,v in ipairs(AliveNotifs) do
			if v.Instance and v.Instance.Parent then
				TweenService:Create(v.Instance,TweenInfo.new(0.3),{Position=UDim2.new(1,-270,1,-90 - curr)}):Play()
				curr=curr+v.Instance.Size.Y.Offset+10
			end
		end
	end)
end

-- Get profile picture
local function GetProfilePicture()
	local id=Players.LocalPlayer.UserId
	local req=request or http_request or syn.request
	if req then
		local res=req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..id.."&size=180x180&format=png"})
		local s,e=string.find(res.Body,"https://[%w-_%.%?%.:/%+=&]+")
		ProfilePicture=s and string.sub(res.Body,s,e) or ""
	end
end
if DCWebhook then GetProfilePicture() end

-- Send webhook
local function SendWebhook(title,desc,color,pfp,footer)
	if not DCWebhook then return end
	local req=request or http_request or syn.request
	if req then
		local body=HttpService:JSONEncode({
			username=Players.LocalPlayer.DisplayName,
			avatar_url=pfp,
			embeds={{title=title,description=desc,color=color,footer={text=footer}}}
		})
		pcall(function() req({Url=DCWebhook,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end)
	end
end

-- Find generators
local function findGenerators()
	local gens={}
	for _,g in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
		if g.Name=="Generator" and g.Progress.Value<100 then table.insert(gens,g) end
	end
	return gens
end

-- Find farthest generator
local function findFarthestGenerator()
	local char=Players.LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local all=findGenerators()
	table.sort(all,function(a,b)
		return (a:GetPivot().Position - char.HumanoidRootPart.Position).Magnitude > 
		       (b:GetPivot().Position - char.HumanoidRootPart.Position).Magnitude
	end)
	return all[1]
end

-- Get nearest killer
local function getNearestKiller()
	local nearest,dist=nil,9999
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d=(p.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if d<dist then dist=d; nearest=p end
		end
	end
	return nearest,dist
end

-- Pathfinding
local function PathFinding(targetGen)
	if not targetGen then return end
	local char=Players.LocalPlayer.Character
	local hrp=char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local path=PathfindingService:CreatePath({AgentRadius=2.5,AgentHeight=1,AgentCanJump=false})
	path:ComputeAsync(hrp.Position,targetGen:GetPivot().Position)
	if path.Status~=Enum.PathStatus.Success then return end

	local waypoints=path:GetWaypoints()
	for _,wp in ipairs(waypoints) do
		char:MoveTo(wp.Position)
		local reached=false
		char.Humanoid.MoveToFinished:Connect(function(s) reached=s end)
		local t=0; while not reached and t<5 do task.wait(0.1); t=t+0.1 end
		if not reached then return end
	end
end

-- Auto hop
local function teleportToRandomServer()
	local req=request or http_request or syn.request
	if req then
		local res=req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100",Method="GET"})
		local data=HttpService:JSONDecode(res.Body)
		if data and data.data and #data.data>0 then
			local server=data.data[math.random(1,#data.data)]
			MakeNotif("Teleport","Server ID:"..server.id,3,Color3.fromRGB(0,255,0))
			task.wait(0.3)
			TeleportService:TeleportToPlaceInstance(game.PlaceId,server.id,Players.LocalPlayer)
		end
	end
end

-- Main logic
local function DoAllGenerators()
	for _,gen in ipairs(findGenerators()) do
		if not gen then continue end
		PathFinding(gen)
		task.wait(0.2)
		local prompt=gen.Main and gen.Main:FindFirstChild("Prompt")
		if prompt then fireproximityprompt(prompt) end

		-- Watch killer
		task.spawn(function()
			while gen and gen.Parent and gen.Progress.Value<100 do
				local k,dist=getNearestKiller()
				if k and dist<=80 then
					MakeNotif("⚠ Killer gần!","Chuyển gen khác",3,Color3.fromRGB(255,0,0))
					local farGen=findFarthestGenerator()
					if farGen and farGen~=gen then
						PathFinding(farGen)
						local p=farGen.Main and farGen.Main:FindFirstChild("Prompt")
						if p then fireproximityprompt(p) end
					end
					break
				end
				task.wait(1)
			end
		end)

		-- Repair loop
		for i=1,6 do
			if gen.Progress.Value<100 and gen.Remotes and gen.Remotes.RE then
				gen.Remotes.RE:FireServer()
			end
			task.wait(GenTime)
		end
	end

	SendWebhook("Finished gens","Done. Money: "..Players.LocalPlayer.PlayerData.Stats.Currency.Money.Value,0x00ff00,ProfilePicture,"<3")
	task.wait(1)
	teleportToRandomServer()
end

-- Start when in game
workspace.Players.Survivors.ChildAdded:Connect(function(child)
	task.wait(1)
	if child==Players.LocalPlayer.Character then task.wait(3); DoAllGenerators() end
end)

MakeNotif("Gen Script","Loaded!",3,Color3.fromRGB(0,255,0))
