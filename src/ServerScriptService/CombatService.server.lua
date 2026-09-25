--!strict
-- SCRIPT: CombatService (server) — caricature big heads, basketball damage,
-- and the triple-kill streak that lights a player's hair on fire.
-- Whoever last touched a basketball before it hits a player owns the kill.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local streaks: { [Player]: { count: number, lastKill: number } } = {}
local ballOwner: { [BasePart]: Player? } = {}

local function makeFlame(head: BasePart)
	local existing = head:FindFirstChild("FlameHair")
	if existing then
		existing:Destroy()
	end
	local fire = Instance.new("Fire")
	fire.Name = "FlameHair"
	fire.Size = Config.FlameSize.X
	fire.ColorStyle = Enum.ColorStyle.Custom
	fire.Color = Config.FlameColor
	fire.SecondaryColor = Color3.fromRGB(255, 220, 120)
	fire.Heat = 20
	fire.Parent = head
end

local function clearFlame(character: Model?)
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if head then
		local f = head:FindFirstChild("FlameHair")
		if f then
			f:Destroy()
		end
	end
end

Players.CharacterAdded:Connect(function(character)
	task.wait()
	local head = character:FindFirstChild("Head") :: BasePart?
	if head then
		local w = Config.CaricatureHeadWidth
		local h = Config.CaricatureHeadHeight
		local d = Config.CaricatureHeadDepth
		local cf = head.CFrame
		local oldY = head.Size.Y
		head.Size = head.Size * Vector3.new(w, h, d)
		-- grow upward from the neck so the head doesn't swallow the torso
		head.CFrame = cf * CFrame.new(0, (head.Size.Y - oldY) / 2, 0)
	end

	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if player and humanoid then
		streaks[player] = { count = 0, lastKill = 0 }
		humanoid.Died:Connect(function()
			clearFlame(character)
			local s = streaks[player]
			if s then
				s.count = 0
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	streaks[player] = nil
end)

local function registerKill(attacker: Player?, victim: Player?)
	if not attacker or attacker == victim then
		return
	end
	local s = streaks[attacker]
	local now = os.clock()
	if not s then
		s = { count = 0, lastKill = 0 }
		streaks[attacker] = s
	end
	if now - s.lastKill > Config.StreakWindowSeconds then
		s.count = 0
	end
	s.count += 1
	s.lastKill = now
	if s.count % Config.FlameStreak == 0 then
		local character = attacker.Character
		local head = character and character:FindFirstChild("Head")
		if head then
			makeFlame(head)
		end
	end
end

local function connectBallTouch(ball: BasePart)
	local touchedLock: { [Player]: number } = {}
	ball.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character then
			return
		end
		local victim = Players:GetPlayerFromCharacter(character)
		if not victim then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local owner = ballOwner[ball]
		local isHead = hit.Name == "Head"
		if owner and owner ~= victim then
			local lastAt = touchedLock[victim]
			if lastAt and os.clock() - lastAt < 0.5 then
				return
			end
			touchedLock[victim] = os.clock()
			humanoid:TakeDamage(isHead and Config.BallDamage * 1.5 or Config.BallDamage)
			if humanoid.Health <= 0 then
				registerKill(owner, victim)
			end
		end

		local toucher = Players:GetPlayerFromCharacter(character)
		if toucher then
			ballOwner[ball] = toucher
		end
	end)
end

RunService.Heartbeat:Connect(function()
	local gym = workspace:FindFirstChild("SchoolGymnasium")
	if not gym then
		return
	end
	local folder = gym:FindFirstChild("Basketballs")
	if not folder then
		return
	end
	for _, ball in ipairs(folder:GetChildren()) do
		if ball:IsA("BasePart") and not ball:GetAttribute("CombatReady") then
			ball:SetAttribute("CombatReady", true)
			ballOwner[ball] = nil
			connectBallTouch(ball)
		end
	end
end)

print("[Trital] combat service armed")
