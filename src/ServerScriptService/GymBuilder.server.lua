--!strict
-- SCRIPT: GymBuilder (server) — school gymnasium on the north pole of Trital,
-- complete with a basketball court. Basketballs are physics props that hurt.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local R = Config.PlanetRadius
local BASE = R + 2

local gym = workspace:FindFirstChild("SchoolGymnasium")
if gym then
	gym:Destroy()
end
gym = Instance.new("Model")
gym.Name = "SchoolGymnasium"
gym.Parent = workspace

local function part(name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = true
	p.Parent = gym
	return p
end

-- court floor + markings
part("CourtFloor", Vector3.new(80, 1, 40), Vector3.new(0, BASE + 0.5, 0), Color3.fromRGB(203, 140, 74))
part("CourtLineCenter", Vector3.new(0.6, 0.3, 40), Vector3.new(0, BASE + 1.15, 0), Color3.new(1, 1, 1))
local circle = Instance.new("Part")
circle.Name = "CourtCenterCircle"
circle.Anchored = true
circle.Shape = Enum.PartType.Cylinder
circle.Size = Vector3.new(0.3, 12, 12)
circle.CFrame = CFrame.new(Vector3.new(0, BASE + 1.15, 0)) * CFrame.Angles(math.rad(90), 0, 0)
circle.Color = Color3.new(1, 1, 1)
circle.Material = Enum.Material.SmoothPlastic
circle.Parent = gym

-- walls + bleachers
for _, sx in ipairs({ -1, 1 }) do
	part("GymWall", Vector3.new(1.5, 14, 40), Vector3.new(sx * 47, BASE + 7, 12), Color3.fromRGB(90, 84, 96))
end
for _, sz in ipairs({ -1, 1 }) do
	part("GymWall", Vector3.new(80, 14, 1.5), Vector3.new(0, BASE + 7, 14 + sz * 10), Color3.fromRGB(90, 84, 96))
end
for row = 0, 3 do
	part("Bleachers", Vector3.new(80, 2, 4), Vector3.new(0, BASE + 1 + row, 20 + row * 5), Color3.fromRGB(140, 60, 70))
end

-- hoops at each end of the court
for _, sx in ipairs({ -1, 1 }) do
	local x = sx * 38
	part("Backboard", Vector3.new(0.6, 4.5, 7), Vector3.new(x, BASE + 11.5, 0), Color3.new(1, 1, 1))
	local rim = Instance.new("Part")
	rim.Name = "Rim"
	rim.Anchored = true
	rim.Shape = Enum.PartType.Cylinder
	rim.Size = Vector3.new(0.4, 2.6, 2.6)
	rim.CFrame = CFrame.new(Vector3.new(x - sx, BASE + 10, 0)) * CFrame.Angles(math.rad(90), 0, 0)
	rim.Color = Color3.fromRGB(255, 90, 40)
	rim.Material = Enum.Material.Neon
	rim.Parent = gym
	local net = Instance.new("Part")
	net.Name = "Net"
	net.Anchored = true
	net.Shape = Enum.PartType.Cylinder
	net.Size = Vector3.new(0.6, 2, 1.4)
	net.CFrame = CFrame.new(Vector3.new(x - sx, BASE + 9.2, 0)) * CFrame.Angles(math.rad(90), 0, 0)
	net.Transparency = 0.5
	net.Color = Color3.new(1, 1, 1)
	net.CanCollide = false
	net.Parent = gym
end

-- basketballs, respawned periodically for pickup-hoop brawls
local ballFolder = Instance.new("Folder")
ballFolder.Name = "Basketballs"
ballFolder.Parent = gym

local function makeBall()
	local ball = Instance.new("Part")
	ball.Name = "Basketball"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(2.4, 2.4, 2.4)
	ball.Material = Enum.Material.SmoothPlastic
	ball.Color = Color3.fromRGB(220, 100, 30)
	ball.BounceFactor = 0.65
	ball.Position = Vector3.new(math.random(-10, 10), BASE + Config.BallSpawnHeight, math.random(-5, 5))
	ball.Parent = ballFolder
	return ball
end

task.spawn(function()
	while true do
		local ball = makeBall()
		local age = 0
		while ball.Parent == ballFolder and age < 60 do
			task.wait(1)
			age += 1
		end
		if ball.Parent == ballFolder then
			ball:Destroy()
		end
		task.wait(4)
	end
end)

print("[Trital] school gymnasium built on the pole")
