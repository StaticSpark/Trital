--!strict
-- LOCALSCRIPT: CameraController (StarterPlayerScripts)
-- Radial third-person camera: the player's "up" is always the direction away
-- from the planet center, so you always appear standing on top of Trital.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local CENTER = Vector3.new(0, 0, 0)
local MIN_TILT = 0.15 -- keep camera slightly above the local horizon even when looking down

local player = Players.LocalPlayer

RunService.PreRender:Connect(function()
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	local up = hrp.Position - CENTER
	if up.Magnitude < 0.1 then return end
	up = up.Unit

	local tf = workspace.CurrentCamera.CFrame
	local look = tf.LookVector
	local upAmount = look:Dot(up)
	if upAmount < -MIN_TILT or upAmount > MIN_TILT then
		local clamped = look - up * math.clamp(upAmount, -MIN_TILT, MIN_TILT)
		if clamped.Magnitude > 0.01 then
			workspace.CurrentCamera.CFrame = CFrame.lookAt(tf.Position, tf.Position + clamped.Unit, up)
		end
	end
end)
