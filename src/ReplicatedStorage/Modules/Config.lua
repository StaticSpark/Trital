--!strict
-- MODULE: Config (ReplicatedStorage.Modules.Config)
-- Central constants for Trital: school of Jupiter.

local Config = {}

Config.PlanetName = "Trital"

-- Sphere geometry
Config.PlanetRadius = 400 -- studs
Config.SurfaceTopY = Config.PlanetRadius -- top of the sphere

-- Spherical gravity (pull toward planet center)
Config.GravityPerMass = 0.3 -- studs/s per frame impulse factor
Config.FallSpeedMax = 120

-- Character tuning (multipliers on the default R6 head -> big caricature head)
Config.CaricatureHeadWidth = 1.75
Config.CaricatureHeadDepth = 1.75
Config.CaricatureHeadHeight = 1.45

-- Triple kill flame hair
Config.FlameStreak = 3
Config.FlameColor = Color3.fromRGB(255, 150, 60) -- light orange
Config.FlameSize = Vector3.new(2.2, 2.6, 2.2)
Config.StreakWindowSeconds = 30 -- streak only counts these many seconds apart
Config.FlameAnchorHeight = 0.45

-- Basketball
Config.BallSpawnHeight = 6
Config.BallDamage = 12 -- touch damage per hit

-- Teams / queues
Config.TeamSize = 4
Config.QueueWindowSeconds = 45 -- players touching the pad within this window form one team

-- Match simulation
Config.MatchTickSeconds = 0.25
Config.MatchDuration = 6 -- seconds a simulated match plays out on screen

return Config
