if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local player = Players.LocalPlayer
local currentCharacter = nil
local isInGame = false
local busy = false
local fail_attempt = 0
local ProfilePicture = ""
local ActiveInfiniteStamina = true

-- 🛡️ Infinite stamina
task.spawn(function()
	while ActiveInfiniteStamina do
		pcall(function()
			local m = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
			m.StaminaLossDisabled = true
			m.Stamina = 9999999
		end)
		task.wait(0.1)
	end
end)

-- 👀 check isInGame (dựa vào spectate list)
task.spawn(function()
	while true do
		local spectators = {}
		if workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Spectating") then
			for _, p in ipairs(workspace.Players.Spectating:GetChildren()) do
				table.insert(spectators, p.Name)
			end
		end
		isInGame = not table.find(spectators, player.Name)
		task.wait(1)
	end
end)

-- 🖼️ Get avatar
local function GetProfilePicture()
	local req = request or http_request or syn.request
	if req then
		local res = req({
			Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=180x180&format=png",
			Method="GET"
		})
		if res and res.Body then
			local data = HttpService:JSONDecode(res.Body)
			if data and data.data and data.data[1] then
				ProfilePicture = data.data[1].imageUrl
			end
		end
	end
end
if DCWebhook then GetProfilePicture() end

-- 📢 Send webhook
local function SendWebhook(title,desc,color)
	if not DCWebhook then return end
	local req = request or http_request or syn.request
	if req then
		req({
			Url=DCWebhook,
			Method="POST",
			Headers={["Content-Type"]="application/json"},
			Body=HttpService:JSONEncode({
				username=player.DisplayName,
				avatar_url=ProfilePicture,
				embeds={{title=title,description=desc,color=color}}
			})
		})
	end
end

-- 🔍 Find generators
local function findGenerators()
	local gens={}
	local map = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name=="Generator" and g.Progress.Value<100 then
				table.insert(gens,g)
			end
		end
	end
	table.sort(gens,function(a,b)
		local c=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not c then return false end
		return (a:GetPivot().Position-c.Position).Magnitude < (b:GetPivot().Position-c.Position).Magnitude
	end)
	return gens
end

-- 🏃 Pathfinding
local function PathFinding(target)
	local hum = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
	local root = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return false end
	local path=PathfindingService:CreatePath({AgentRadius=2.5,AgentHeight=1,AgentCanJump=false})
	local ok=pcall(function() path:ComputeAsync(root.Position,target) end)
	if not ok or path.Status~=Enum.PathStatus.Success then return false end
	for _,wp in ipairs(path:GetWaypoints()) do
		hum:MoveTo(wp.Position)
		local t0=tick()
		repeat task.wait() until (root.Position - wp.Position).Magnitude<5 or tick()-t0>4
		if tick()-t0>4 then return false end
	end
	return true
end

-- 🧟 Check killer gần
local function getClosestKiller()
	local killers=workspace.Players:FindFirstChild("Killers") and workspace.Players.Killers:GetChildren()
	local closest=nil
	local minDist=math.huge
	if killers then
		for _,k in ipairs(killers) do
			if k:FindFirstChild("HumanoidRootPart") and currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
				local dist=(k.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
				if dist<80 and dist<minDist then
					minDist=dist
					closest=k
				end
			end
		end
	end
	return closest
end

-- ⚡ Khi killer gần → chạy hoặc teleport
local function runOrTeleport(killer)
	if not currentCharacter then return end
	local hum=currentCharacter:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health<50 then
		-- teleport gen xa nhất
		local gens=findGenerators()
		if #gens>0 then
			local far=gens[#gens]
			currentCharacter.HumanoidRootPart.CFrame=CFrame.new(far:GetPivot().Position+Vector3.new(0,3,0))
			SendWebhook("Low HP!","Teleported to far generator",0xff0000)
		end
	else
		-- chạy hướng ngược killer
		local killerPos=killer.HumanoidRootPart.Position
		local myPos=currentCharacter.HumanoidRootPart.Position
		local dir=(myPos - killerPos).Unit*50
		local target=myPos+dir
		if not PathFinding(target) then
			-- Nếu chạy fail thì teleport gen xa nhất
			local gens=findGenerators()
			if #gens>0 then
				currentCharacter.HumanoidRootPart.CFrame=CFrame.new(gens[#gens]:GetPivot().Position+Vector3.new(0,3,0))
			end
		end
	end
end

-- 🔀 Hop server
local function hopServer()
	local req=request or http_request or syn.request
	if req then
		local res=req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100",Method="GET"})
		if res and res.Body then
			local data=HttpService:JSONDecode(res.Body)
			for _,s in pairs(data.data) do
				if s.playing<s.maxPlayers then
					TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,player)
					return
				end
			end
		end
	end
end

-- ⚙️ Main autofarm
local function doGenerators()
	currentCharacter=nil
	for _,c in ipairs(workspace.Players.Survivors:GetChildren()) do
		if c:GetAttribute("Username")==player.Name then
			currentCharacter=c break
		end
	end
	if not currentCharacter then return end
	while isInGame do
		local killer=getClosestKiller()
		if killer then
			runOrTeleport(killer)
		else
			local gens=findGenerators()
			if #gens==0 then
				SendWebhook("Done","All generators fixed!",0x00ff00)
				hopServer()
				break
			end
			local g=gens[1]
			if PathFinding(g:GetPivot().Position) then
				task.wait(0.5)
				if g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt") then
					fireproximityprompt(g.Main.Prompt)
				end
				for i=1,6 do
					if g.Progress.Value<100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
						g.Remotes.RE:FireServer()
					end
					task.wait(GenTime)
				end
			else
				hopServer()
				break
			end
		end
		task.wait(0.2)
	end
end

-- 🪦 chết thì hop server
task.spawn(function()
	while task.wait(1) do
		if currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid") and currentCharacter.Humanoid.Health<=0 then
			SendWebhook("Dead","Hop server...",0xff0000)
			hopServer()
			break
		end
	end
end)

-- 🔄 loop
task.spawn(function()
	while task.wait(1) do
		if isInGame then doGenerators() end
	end
end)

SendWebhook("Started","AutoFarm ready!",0x00ff00)
