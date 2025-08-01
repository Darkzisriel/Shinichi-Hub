-- SETTINGS
local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5
local RoundTimerThreshold = 90
local KillerRange = 60
local PlaceId = game.PlaceId

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local ProfilePicture = ""
local Notifications = {}
local NotificationGui

---------------------------
-- 📌 Notification UI
---------------------------
local function CreateNotificationUI()
	if NotificationGui then return NotificationGui end
	NotificationGui = Instance.new("ScreenGui")
	NotificationGui.Name = "NotificationUI"
	NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	NotificationGui.Parent = game:GetService("CoreGui")
	return NotificationGui
end

local function MakeNotif(title, message, duration, color)
	duration = duration or 5
	color = color or Color3.fromRGB(255, 200, 0)
	local ui = CreateNotificationUI()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 250, 0, 80)
	frame.Position = UDim2.new(1, 50, 1, 10)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = ui
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0,8)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = color
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1,-25,0,25)
	titleLabel.Position = UDim2.new(0,15,0,5)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local messageLabel = Instance.new("TextLabel", frame)
	messageLabel.Text = message
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Color3.fromRGB(255,255,255)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Size = UDim2.new(1,-25,0,50)
	messageLabel.Position = UDim2.new(0,15,0,30)
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left

	local colorBar = Instance.new("Frame", frame)
	colorBar.Size = UDim2.new(0,5,1,0)
	colorBar.BackgroundColor3 = color
	colorBar.BorderSizePixel = 0

	-- Vị trí
	local offset = 0
	for _, notif in ipairs(Notifications) do
		if notif.Instance and notif.Instance.Parent then
			offset = offset + notif.Instance.Size.Y.Offset + 10
		end
	end
	local goalPos = UDim2.new(1,-270,1,-90 - offset)
	frame.Position = UDim2.new(1,50,1,10)
	table.insert(Notifications, {Instance=frame,ExpireTime=os.time()+duration})
	TweenService:Create(frame,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=goalPos}):Play()

	-- Xoá sau
	task.spawn(function()
		task.wait(duration)
		local tweenOut = TweenService:Create(frame,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(1,50,frame.Position.Y.Scale,frame.Position.Y.Offset)})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		for i,v in ipairs(Notifications) do if v.Instance==frame then table.remove(Notifications,i) break end end
		frame:Destroy()
		-- reposition
		local newOffset=0
		for _, notif in ipairs(Notifications) do
			if notif.Instance and notif.Instance.Parent then
				TweenService:Create(notif.Instance,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-270,1,-90 - newOffset)}):Play()
				newOffset = newOffset + notif.Instance.Size.Y.Offset +10
			end
		end
	end)
end

---------------------------
-- 🌐 Discord Webhook
---------------------------
local function GetProfilePicture()
	local request = request or http_request or syn.request
	if not request then return end
	local success, response = pcall(function()
		return request({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..LocalPlayer.UserId.."&size=180x180&format=png",Method="GET"})
	end)
	if success and response and response.Body then
		local found = response.Body:match('https://[^\"]+')
		ProfilePicture = found or ""
	end
end

local function SendWebhook(title, description, color)
	if not DCWebhook then return end
	local request = request or http_request or syn.request
	if not request then return end
	pcall(function()
		request({
			Url = DCWebhook,
			Method = "POST",
			Headers = {["Content-Type"]="application/json"},
			Body = HttpService:JSONEncode({
				username = LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = {{title=title,description=description,color=color}}
			})
		})
	end)
end

if DCWebhook then GetProfilePicture() end

---------------------------
-- ⚙️ Main logic
---------------------------
local function findRoundTimerValue()
	local gui = LocalPlayer.PlayerGui:FindFirstChild("RoundTimer")
	if gui and gui.Main then
		local content = gui.Main:FindFirstChild("Time")
		if content and content:FindFirstChild("ContentText") then
			local txt = content.ContentText.Text
			if txt and txt:match("^%d+:%d%d$") then
				local min,sec=txt:match("^(%d+):(%d%d)$")
				return tonumber(min)*60+tonumber(sec)
			end
		end
	end
	return nil
end

local function teleportToRandomServer()
	local req = request or http_request or syn.request
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)
	local s,res=pcall(function() return req({Url=url,Method="GET"}) end)
	if s and res and res.Body then
		local data=HttpService:JSONDecode(res.Body)
		if data and data.data and #data.data>0 then
			local candidates={}
			for _,sv in ipairs(data.data) do
				if sv.playing<(sv.maxPlayers*0.4) then table.insert(candidates,sv) end
			end
			if #candidates==0 then candidates=data.data end
			local chosen=candidates[math.random(1,#candidates)]
			if chosen and chosen.id then
				MakeNotif("Hop Server","Đến server mới",2)
				if DCWebhook then SendWebhook("Hop Server","Teleported to "..chosen.id,0x00ff00) end
				TeleportService:TeleportToPlaceInstance(PlaceId,chosen.id)
			end
		end
	end
end

local function findGenerators()
	local f=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
	local gens={}
	if f then
		for _,g in ipairs(f:GetChildren()) do
			if g.Name=="Generator" and g.Progress.Value<100 then table.insert(gens,g) end
		end
	end
	return gens
end

local function teleportToGenerator(gen)
	local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp and gen then
		hrp.CFrame = CFrame.new(gen:GetPivot().Position+Vector3.new(0,5,0))
	end
end

local function findNearestKiller()
	local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil,math.huge end
	local nearest,dist=nil,math.huge
	for _,k in ipairs(workspace.Players.Killers:GetChildren()) do
		local khrp=k:FindFirstChild("HumanoidRootPart")
		if khrp then
			local d=(hrp.Position - khrp.Position).Magnitude
			if d<dist then dist=d; nearest=k end
		end
	end
	return nearest,dist
end

local function main()
	while true do
		local timer=findRoundTimerValue()
		if not timer or timer>RoundTimerThreshold then
			MakeNotif("Hop","Không có trận gần, hop server",2)
			teleportToRandomServer()
			return
		else
			MakeNotif("Chờ","Round sắp bắt đầu...",2)
			repeat task.wait(2)
				local t=findRoundTimerValue()
				if not t or t<=0 then break end
			until false
		end

		MakeNotif("Vào Trận","Bắt đầu sửa generator!",2)
		while true do
			local gens=findGenerators()
			if #gens==0 then break end
			local gen=gens[1]
			teleportToGenerator(gen)
			MakeNotif("Sửa","Đang sửa generator",2)
			local prompt=gen:FindFirstChild("Main") and gen.Main:FindFirstChild("Prompt")
			while gen.Progress.Value<100 do
				local _,dist=findNearestKiller()
				if dist and dist<=KillerRange then
					local far=gens[#gens]
					if far then teleportToGenerator(far) MakeNotif("Danger","Killer gần!",2) end
				end
				if prompt then fireproximityprompt(prompt) end
				task.wait(GenTime)
			end
			MakeNotif("Hoàn thành","Generator xong!",2)
		end
		MakeNotif("Xong","Đợi hết round...",2)
		repeat
			local timer=findRoundTimerValue()
			if not timer or timer<=0 then break end
			local _,dist=findNearestKiller()
			if dist and dist<=KillerRange then
				local far=gens[#gens]
				if far then teleportToGenerator(far) end
			end
			task.wait(2)
		until false
		MakeNotif("Hop","Round hết, hop server",2)
		teleportToRandomServer()
		return
	end
end

task.spawn(function() -- Chết cũng hop
	while true do
		local char=LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health<=0 then
			MakeNotif("Chết","Bạn đã chết!",2)
			if DCWebhook then SendWebhook("Bạn chết","Đang hop server",0xff0000) end
			teleportToRandomServer()
			break
		end
		task.wait(1)
	end
end)

main()
