if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat
		task.wait()
	until game:IsLoaded()
end
local VIMVIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local Nnnnnnotificvationui
local AliveNotificaiotna = {}
local ProfilePicture = ""

if DCWebhook == "" then
	DCWebhook = false
end

local function CreateNotificationUI()
	if Nnnnnnotificvationui then
		return Nnnnnnotificvationui
	end

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

MakeNotif("Gen Teleport Shit", "It Loaded!", 5, Color3.fromRGB(115, 194, 89))

local function GetProfilePicture()
	local PlayerID = game:GetService("Players").LocalPlayer.UserId
	local request = request or http_request or syn.request
	local response = request({
		Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="
			.. PlayerID
			.. "&size=180x180&format=png",
		Method = "GET",
		Headers = {
			["User-Agent"] = "Mozilla/5.0",
		},
	})
	local urlStart, urlEnd = string.find(response.Body, "https://[%w-_%.%?%.:/%+=&]+")
	if urlStart and urlEnd then
		ProfilePicture = string.sub(response.Body, urlStart, urlEnd)
	else
		ProfilePicture = "https://cdn.sussy.dev/bleh.jpg"
	end
end

if DCWebhook then
	GetProfilePicture()
end

local function SendWebhook(Title, Description, Color, ProfilePicture, Footer)
	if not DCWebhook then
		return
	end
	local request = request or http_request or syn.request
	if not request then
		return
	end

	local success, errorMessage = pcall(function()
		local response = request({
			Url = DCWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = game:GetService("HttpService"):JSONEncode({
				username = game:GetService("Players").LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = {
					{
						title = Title,
						description = Description,
						color = Color,
						footer = { text = Footer },
					},
				},
			}),
		})
		if response and response.Body then
			print(response.Body)
		end
	end)

	MakeNotif("Gen Teleport", "Sent webhook: " .. Title .. "\n" .. Description, 5, Color3.fromRGB(115, 194, 89))
	if not success then
		print("Error: " .. errorMessage)
	end
end

task.spawn(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(
			"UpdateSettings",
			game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.MaliceDisabled,
			true
		)
	end)
end)

if _G.CancelPathEvent then
	_G.CancelPathEvent:Fire()
end

_G.CancelPathEvent = Instance.new("BindableEvent")

pcall(function()
	local Controller =
		require(game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	Controller:Disable()
end)

local function teleportToRandomServer()
	local Counter = 0
	local MaxRetry = 10
	local RetryingDelays = 10

	local Request = http_request or syn.request or request
	if Request then
		local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"

		while Counter < MaxRetry do
			local success, response = pcall(function()
				return Request({
					Url = url,
					Method = "GET",
					Headers = { ["Content-Type"] = "application/json" },
				})
			end)

			if success and response and response.Body then
				local data = HttpService:JSONDecode(response.Body)
				if data and data.data and #data.data > 0 then
					local server = data.data[math.random(1, #data.data)]
					if server.id then
						MakeNotif(
							"Teleporting...",
							"Attempting to teleport to server: " .. server.id,
							5,
							Color3.fromRGB(115, 194, 89)
						)
						task.wait(0.25)
						TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
						return
					end
				end
			end

			Counter = Counter + 1
			MakeNotif(
				"Gen Teleport",
				"Retrying to get a server... Attempt " .. Counter .. "/" .. MaxRetry,
				5,
				Color3.fromRGB(255, 0, 0)
			)
			task.wait(RetryingDelays)
		end
	end
end

task.delay(2.5, function()
	pcall(function()
		local timer = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local minutes, seconds = timer:match("(%d+):(%d+)")
		local totalSeconds = tonumber(minutes) * 60 + tonumber(seconds)
		print(totalSeconds .. " Left till round end.")
		MakeNotif("Gen Teleport", "Round ends in " .. totalSeconds .. " seconds.", 5, Color3.fromRGB(115, 194, 89))
		if totalSeconds > 90 then
			teleportToRandomServer()
		end
	end)
end)

local isInGame = false

task.spawn(function()
	while true do
		local Spectators = {}
		for i, child in ipairs(workspace.Players.Spectating:GetChildren()) do
			table.insert(Spectators, child.Name)
		end
		if table.find(Spectators, Players.LocalPlayer.Name) then
			isInGame = false
		else
			isInGame = true
		end
		task.wait(1)
	end
end)

local busy = false
local isSprinting = false
local stamina = 0

task.spawn(function()
	while true do
		if isInGame then
			local success, err = pcall(function()
				local currentCharacter = Players.LocalPlayer.Character
				if currentCharacter and currentCharacter:FindFirstChild("Humanoid") then
					currentCharacter.Humanoid:SetAttribute("BaseSpeed", 14)
					local barText = Players.LocalPlayer.PlayerGui.TemporaryUI.PlayerInfo.Bars.Stamina.Amount.Text
					stamina = tonumber(string.split(barText, "/")[1])
					local isSprintingFOV = currentCharacter.FOVMultipliers.Sprinting.Value == 1.125
					if not isSprintingFOV then
						if stamina >= 70 then
							if busy then
								return
							end
							VIMVIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
						end
					end
				end
			end)
			if not success then
				warn("Error during sprint check:", err)
			end
		end
		task.wait(1)
	end
end)

task.spawn(function()
	task.wait(20 * 60)
	TeleportService:Teleport(game.PlaceId)
end)

local function fireproximityprompt(prompt)
	if prompt and prompt:IsA("ProximityPrompt") then
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("InputHoldBegin", prompt)
		task.wait(0.1)
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("InputHoldEnd", prompt)
	end
end

while true do
	if isInGame then
		local currentCharacter
		for _, surv in ipairs(workspace.Players.Survivors:GetChildren()) do
			if surv:GetAttribute("Username") == Players.LocalPlayer.Name then
				currentCharacter = surv
			end
		end
		if currentCharacter and currentCharacter:FindFirstChild("Humanoid") and currentCharacter:FindFirstChild("HumanoidRootPart") then
			task.spawn(function()
				while true do
					if currentCharacter.Humanoid.Health <= 0 then
						isInGame = false
						isSprinting = false
						busy = false
						break
					end
					task.wait(0.5)
				end
			end)

			for _, completedgen in ipairs(game.ReplicatedStorage.ObjectiveStorage:GetChildren()) do
				local required = completedgen:GetAttribute("RequiredProgress")
				if completedgen.Value == required then
					SendWebhook(
						"Generator Autofarm thing",
						"Finished all generators, Current Balance: "
							.. Players.LocalPlayer.PlayerData.Stats.Currency.Money.Value
							.. "\nTime Played: "
							.. (function()
								local seconds = Players.LocalPlayer.PlayerData.Stats.General.TimePlayed.Value
								local days = math.floor(seconds / (60 * 60 * 24))
								seconds = seconds % (60 * 60 * 24)
								local hours = math.floor(seconds / (60 * 60))
								seconds = seconds % (60 * 60)
								local minutes = math.floor(seconds / 60)
								seconds = seconds % 60
								return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
							end)(),
						0x00FF00,
						ProfilePicture,
						".gg/fartsaken | <3"
					)
					task.wait(1)
					teleportToRandomServer()
					break
				else
					for _, gen in ipairs(workspace.Map.Ingame:WaitForChild("Map"):GetChildren()) do
						if gen.Name == "Generator" and gen.Progress.Value < 100 then
							local goalPos = gen:WaitForChild("Positions").Right.Position
							currentCharacter.HumanoidRootPart.CFrame = CFrame.new(goalPos + Vector3.new(0, 3, 0))
							task.wait(0.1)
							local prompt = gen.Main:FindFirstChild("Prompt")
							if prompt then
								prompt.HoldDuration = 0
								prompt.RequiresLineOfSight = false
								prompt.MaxActivationDistance = 99999
								task.wait(0.1)
								fireproximityprompt(prompt)
								task.wait(0.1)
								busy = true
								local counter = 0
								while gen.Progress.Value < 100 do
									fireproximityprompt(prompt)
									gen.Remotes.RE:FireServer()
									task.wait(GenTime)
									counter = counter + 1
									if counter >= 10 or not isInGame then
										break
									end
								end
								busy = false
							end
						end
					end
				end
			end
		end
	end
	task.wait(0.1)
end
