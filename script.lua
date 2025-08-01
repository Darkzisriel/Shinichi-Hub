if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5
local PlaceId = game.PlaceId

local ProfilePicture = ""
local Notifications = {}

local LocalPlayer = Players.LocalPlayer

-- Notification UI (giống đoạn bạn gửi)
local NotificationGui = nil
local AliveNotifications = {}

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
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Text = title or "Notification"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = color
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1,-25,0,25)
	titleLabel.Position = UDim2.new(0,15,0,5)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local messageLabel = Instance.new("TextLabel", frame)
	messageLabel.Text = message or ""
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

	-- Vị trí notification stack
	local offset = 0
	for _, notif in ipairs(AliveNotifications) do
		if notif.Instance and notif.Instance.Parent then
			offset = offset + notif.Instance.Size.Y.Offset + 10
		end
	end

	local goalPos = UDim2.new(1,-270,1,-90 - offset)
	table.insert(AliveNotifications, {Instance=frame, ExpireTime=os.time() + duration})
	TweenService:Create(frame,TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = goalPos}):Play()

	task.spawn(function()
		task.wait(duration)
		local tweenOut = TweenService:Create(frame,TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, frame.Position.Y.Scale, frame.Position.Y.Offset)})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		for i,v in ipairs(AliveNotifications) do
			if v.Instance == frame then
				table.remove(AliveNotifications,i)
				break
			end
		end
		frame:Destroy()
		-- reposition
		local newOffset = 0
		for _, notif in ipairs(AliveNotifications) do
			if notif.Instance and notif.Instance.Parent then
				TweenService:Create(notif.Instance,TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1,-270,1,-90 - newOffset)}):Play()
				newOffset = newOffset + notif.Instance.Size.Y.Offset + 10
			end
		end
	end)
end

-- Discord webhook lấy avatar
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

-- Kiểm tra người chơi có trong game chưa
local function isInGame()
	local specFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Spectating")
	if not specFolder then return false end
	return not specFolder:FindFirstChild(LocalPlayer.Name)
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

local function teleportToRandomServer()
	local req = request or http_request or syn.request
	if not req then
		MakeNotif("Error", "No request function available", 5, Color3.fromRGB(255, 0, 0))
		return
	end
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

local function main()
	while true do
		-- Check round timer lúc vào script
		local timerValue = nil
		pcall(function()
			local timerText = LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
			local m,s = timerText:match("(%d+):(%d+)")
			if m and s then
				timerValue = tonumber(m)*60 + tonumber(s)
			end
		end)
		if not timerValue then
			MakeNotif("Hop", "Không đọc được RoundTimer, hop server", 3, Color3.fromRGB(255, 0, 0))
			teleportToRandomServer()
			return
		end
		MakeNotif("RoundTimer", "Round còn " .. timerValue .. " giây.", 3, Color3.fromRGB(115, 194, 89))
		if timerValue > 90 then
			MakeNotif("Hop", "Round còn dài (>90s), hop server", 3, Color3.fromRGB(255, 0, 0))
			teleportToRandomServer()
			return
		end

		-- Đợi vào game
		MakeNotif("Chờ", "Đợi vào trận...", 3, Color3.fromRGB(255, 255, 0))
		repeat task.wait(1) until isInGame()

		-- Auto làm hết tất cả generator
		MakeNotif("Auto", "Bắt đầu auto generator", 3, Color3.fromRGB(0, 255, 0))
		local gens = findGenerators()
		for _, gen in ipairs(gens) do
			teleportToGenerator(gen)
			local prompt = gen:FindFirstChild("Main") and gen.Main:FindFirstChild("Prompt")
			while gen.Progress.Value < 100 and isInGame() do
				local _, dist = findNearestKiller()
				if dist <= 60 then
					MakeNotif("Danger", "Killer gần!", 3, Color3.fromRGB(255, 0, 0))
					-- Di chuyển ra xa generator gần killer nhất (có thể là generator cuối)
					local farGen = gens[#gens]
					if farGen then teleportToGenerator(farGen) end
				end
				if prompt then fireproximityprompt(prompt) end
				task.wait(GenTime)
			end
			MakeNotif("Xong", "Generator hoàn thành", 3, Color3.fromRGB(0, 255, 0))
		end

		-- Sau khi hoàn thành hết generator, đợi round kết thúc
		MakeNotif("Đợi", "Hoàn thành generator, đợi round kết thúc...", 3, Color3.fromRGB(255, 255, 0))
		while isInGame() do
			local timerNow = nil
			pcall(function()
				local timerText = LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
				local m,s = timerText:match("(%d+):(%d+)")
				if m and s then
					timerNow = tonumber(m)*60 + tonumber(s)
				end
			end)
			if not timerNow or timerNow <= 0 then break end

			local _, dist = findNearestKiller()
			if dist <= 60 then
				local gens2 = findGenerators()
				local farGen = gens2[#gens2]
				if farGen then teleportToGenerator(farGen) end
			end
			task.wait(2)
		end

		MakeNotif("Hop", "Round kết thúc, hop server", 3, Color3.fromRGB(255, 0, 0))
		teleportToRandomServer()
		return
	end
end

-- Giám sát chết để hop server
task.spawn(function()
	while task.wait(1) do
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
			MakeNotif("Chết", "Bạn đã chết!", 3, Color3.fromRGB(255, 0, 0))
			if DCWebhook then SendWebhook("Bạn chết", "Đang hop server", 0xFF0000) end
			teleportToRandomServer()
			break
		end
	end
end)

main()
