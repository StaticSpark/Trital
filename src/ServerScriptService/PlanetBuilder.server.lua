--!strict
-- SCRIPT: PlanetBuilder (workspace-level server script)
-- Builds Trital: a Jovian moonlet sphere with a school-gym plateau on top.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local CENTER = Vector3.new(0, 0, 0)
local R = Config.PlanetRadius

workspace.Gravity = 0

local planet = Instance.new("Model")
planet.Name = "Planet"
planet.Parent = workspace

-- shell sphere
local shell = Instance.new("Part")
shell.Name = "PlanetShell"
shell.Anchored = true
shell.Shape = Enum.PartType.Ball
shell.Size = Vector3.new(R * 2, R * 2, R * 2)
shell.Position = CENTER
shell.Material = Enum.Material.Grass
shell.Color = Color3.fromRGB(96, 148, 70)
shell.CanCollide = true
shell.Parent = planet

-- school field at the north pole (players spawn here)
local pole = Instance.new("Part")
pole.Name = "SchoolField"
pole.Anchored = true
pole.Size = Vector3.new(90, 2, 90)
pole.Position = Vector3.new(0, R + 1, 0)
pole.Material = Enum.Material.SmoothPlastic
pole.Color = Color3.fromRGB(230, 232, 235)
pole.CanCollide = true
pole.Parent = planet

-- Jupiter glow in the sky (pure decoration)
local jupiter = Instance.new("Part")
jupiter.Name = "Jupiter"
jupiter.Anchored = true
jupiter.CanCollide = false
jupiter.Shape = Enum.PartType.Ball
jupiter.Size = Vector3.new(600, 600, 600)
jupiter.Position = Vector3.new(0, 1400, -1600)
jupiter.Material = Enum.Material.Neon
jupiter.Color = Color3.fromRGB(214, 155, 108)
jupiter.Parent = planet

-- spawn location on the field
local spawns = Instance.new("SpawnLocation")
spawns.Anchored = true
spawns.Size = Vector3.new(8, 1.5, 8)
spawns.Position = Vector3.new(0, R + 5.5, 0)
spawns.Duration = 0
spawns.Parent = planet

Players.CharacterAdded:Connect(function(character)
	-- align new characters' standing axis to the radial direction
	task.wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local radial = hrp.Position - CENTER
		if radial.Magnitude > 0.1 then
			local up = radial.Unit
			hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(up.X, 0, up.Z) * 1, up)
		end
	end
end)

print("[Trital] Planet built: radius " .. R .. " studs")
