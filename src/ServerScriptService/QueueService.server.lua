--!strict
-- SCRIPT: QueueService (server) — teams of 4 line up on the tryout pad to
-- challenge the League Champs. Winner takes the crown and a fresh crew steps
-- up; losers return to the back of the line.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local R = Config.PlanetRadius
local CROWN_Y = R + 10

local START_CHAMPS = { "Coach Prime", "Dunk Boy", "Swish King", "LayupLarry" }
local champNames: { string } = table.clone(START_CHAMPS)

-- ---------------------------------------------------------------- pad
local pad = workspace:FindFirstChild("TryoutPad")
if pad then
	pad:Destroy()
end
pad = Instance.new("Part")
pad.Name = "TryoutPad"
pad.Anchored = true
pad.Size = Vector3.new(14, 1, 14)
pad.Position = Vector3.new(0, R + 4.5, -26)
pad.Color = Color3.fromRGB(90, 200, 255)
pad.Material = Enum.Material.Neon
pad.Transparency = 0.3
pad.CanCollide = true
pad.Parent = workspace

local signGui = Instance.new("BillboardGui")
signGui.Name = "PadSign"
signGui.Size = UDim2.new(0, 220, 0, 70)
signGui.StudsOffset = Vector3.new(0, 7, 0)
signGui.Parent = pad
local padText = Instance.new("TextLabel")
padText.Size = UDim2.new(1, 0, 1, 0)
padText.BackgroundTransparency = 1
padText.TextStrokeColor3 = Color3.new(0, 0, 0)
padText.TextScaled = true
padText.Font = Enum.Font.GothamBold
padText.TextColor3 = Color3.new(1, 1, 1)
padText.Text = "QUEUE UP — 0/4"
padText.Parent = signGui

-- ---------------------------------------------------------------- board
local board = workspace:FindFirstChild("LeagueBoard")
if board then
	board:Destroy()
end
board = Instance.new("Part")
board.Name = "LeagueBoard"
board.Anchored = true
board.Size = Vector3.new(28, 7, 0.4)
board.Position = Vector3.new(0, R + 26, 14)
board.Color = Color3.fromRGB(18, 18, 28)
board.CanCollide = false
board.Parent = workspace

local surf = Instance.new("SurfaceGui")
surf.Face = Enum.NormalId.Front
surf.Parent = board

local function label(text: string, scale: number, y: number, color: Color3): TextLabel
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.98, 0, scale, 0)
	l.Position = UDim2.new(0.01, 0, y, 0)
	l.BackgroundTransparency = 1
	l.TextColor3 = color
	l.TextScaled = true
	l.Font = Enum.Font.GothamBold
	l.Text = text
	l.Parent = surf
	return l
end

label("★ LEAGUE CHAMPS ★", 0.4, 0.02, Color3.fromRGB(255, 200, 60))
local boardText = label(table.concat(champNames, " · "), 0.52, 0.44, Color3.new(1, 1, 1))

-- ---------------------------------------------------------------- ring
local function rebuildRing()
	local ring = workspace:FindFirstChild("ChampionRing")
	if ring then
		ring:Destroy()
	end
	ring = Instance.new("Model")
	ring.Name = "ChampionRing"
	ring.Parent = workspace

	local n = #champNames
	for i, name in ipairs(champNames) do
		local angle = (i - 1) / n * math.pi * 2
		local pos = Vector3.new(math.sin(angle) * 16, CROWN_Y, math.cos(angle) * 16 - 24)

		local torso = Instance.new("Part")
		torso.Name = "ChampBody"
		torso.Shape = Enum.PartType.Ball
		torso.Size = Vector3.new(3.4, 3.4, 3.4)
		torso.Color = Color3.fromRGB(255, 120, 40)
		torso.Material = Enum.Material.SmoothPlastic
		torso.Anchored = true
		torso.CanCollide = false
		torso.Position = pos
		torso.Parent = ring

		local crown = Instance.new("Part")
		crown.Name = "Crown"
		crown.Shape = Enum.PartType.Ball
		crown.Size = Vector3.new(1.2, 1.2, 1.2)
		crown.Color = Color3.fromRGB(255, 200, 40)
		crown.Material = Enum.Material.Neon
		crown.Anchored = true
		crown.CanCollide = false
		crown.Position = pos + Vector3.new(0, 2.4, 0)
		crown.Parent = ring

		local tag = Instance.new("BillboardGui")
		tag.Name = "NameTag"
		tag.Size = UDim2.new(0, 140, 0, 36)
		tag.StudsOffset = Vector3.new(0, 4, 0)
		tag.AlwaysOnTop = false
		tag.Parent = torso
		local nameText = Instance.new("TextLabel")
		nameText.Size = UDim2.new(1, 0, 1, 0)
		nameText.BackgroundTransparency = 1
		nameText.TextStrokeColor3 = Color3.new(0, 0, 0)
		nameText.Text = name
		nameText.TextColor3 = Color3.fromRGB(255, 200, 60)
		nameText.TextScaled = true
		nameText.Font = Enum.Font.GothamBlack
		nameText.Parent = tag
	end
end

rebuildRing()

-- ---------------------------------------------------------------- queue
local squad: { Player } = {}
local busy = false

local function refreshPad(status: string?)
	if status then
		padText.Text = status
	else
		local names = {}
		for _, p in ipairs(squad) do
			table.insert(names, p.DisplayName)
		end
		padText.Text = ("QUEUE UP — %d/4\n%s"):format(#squad, table.concat(names, ", "))
	end
end

local function leaveSquad(player: Player)
	local idx = table.find(squad, player)
	if idx then
		table.remove(squad, idx)
	end
end

local function runTitleMatch(challengers: { Player })
	local challengerNames: { string } = {}
	for _, p in ipairs(challengers) do
		table.insert(challengerNames, p.DisplayName)
	end
	refreshPad(("TITLE MATCH\n%s\nvs the Champs!"):format(table.concat(challengerNames, ", ")))

	-- simulated title fight: roll the winner, champs slightly favored
	local challengerWins = math.random() < 0.45
	task.wait(6)

	if challengerWins then
		champNames = challengerNames
		rebuildRing()
		boardText.Text = table.concat(champNames, " · ")
		refreshPad("NEW LEAGUE CHAMPS! 👑")
	else
		refreshPad("Champs keep the crown!\nLine re-forms…")
	end
	table.clear(squad)
	task.wait(6)
	refreshPad(nil)
	busy = false
end

local function joinQueue(player: Player)
	if busy then
		return
	end
	if table.find(squad, player) then
		return
	end
	if #squad >= Config.TeamSize then
		return
	end
	table.insert(squad, player)
	refreshPad(nil)
	if #squad == Config.TeamSize then
		busy = true
		local snapshot = table.clone(squad)
		task.spawn(runTitleMatch, snapshot)
	end
end

pad.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		joinQueue(player)
	end
end)

Players.PlayerRemoving:Connect(leaveSquad)
refreshPad(nil)

print("[Trital] queue + League Champs ladder online")
