--!strict
-- SCRIPT: GravityService (server) — pulls every character assembly toward
-- the planet center. Players always end up with feet toward center, head
-- toward the sky, i.e. always "on top" from their own camera angle.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local CENTER = Vector3.new(0, 0, 0)
local G = Config.GravityPerMass

RunService.Heartbeat:Connect(function(dt)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then continue end
		local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid or humanoid.Health <= 0 then continue end

		local radial = hrp.Position - CENTER
		local dist = radial.Magnitude
		if dist < 1 then continue end
		local up = radial.Unit

		-- gravity impulse along -up
		local velocity = hrp.AssemblyLinearVelocity
		hrp.AssemblyLinearVelocity = Vector3.new(
			velocity.X - up.X * G,
			velocity.Y - up.Y * G,
			velocity.Z - up.Z * G
		)

		-- terminal fall speed toward the surface
		local radialSpeed = hrp.AssemblyLinearVelocity:Dot(-up)
		if radialSpeed > Config.FallSpeedMax then
			local tangent = hrp.AssemblyLinearVelocity + up * radialSpeed
			hrp.AssemblyLinearVelocity = tangent - up * Config.FallSpeedMax
		end

		-- once landing on the curved surface, stop sinking and stand upright
		if dist <= Config.PlanetRadius + 11 and radialSpeed < 0.2 and humanoid.MoveDirection.Magnitude < 0.1 then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(up.X, 0, up.Z), -up)
		end
	end
end)
