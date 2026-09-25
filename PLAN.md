# Trital — Plan

**Tritan: school of Jupiter.** A Rivals-style arena shooter set on a small spherical
planet (Trital, a moonlet of Jupiter). Everyone is always standing "on top" from their
own camera angle — gravity pulls to the planet center.

One battle starts in the **school gymnasium** with basketball. From there, teams of 4
join **queues** and line up to challenge the **League Champs** (winner-stays-challenger
ladder).

## Core mechanics

| System | Spec |
|---|---|
| Spherical world | `workspace.Gravity = 0`; per-frame impulse pulls every character assembly toward the planet center (`GravityService`). |
| Camera "up" | Third-person orbit camera whose up vector is always the radial direction from planet center through the player (`CameraController`). |
| Caricature heads | Every player's head scaled ~1.7x anchored at the neck — big-head caricature, N64 basketball style (`CaricatureService`). |
| Triple-kill flame | 3 kill-streak in a match grants light-orange flame hair (Fire instance on the head); streak breaks on death (`CombatService`). |
| Queues & teams | Teams of 4. Players join a queue, fill team slots, get lined up into a match (`QueueService`). |
| League Champs | Persistent reigning champion squad; challenge queue plays them, winner takes the crown (`MatchService`). |

## Phases

- **P0 — Repo & plan**: this repo, plan, issues, PR-per-branch workflow. *(done)*
- **P1 — Core scaffold**: config module + remotes folder. → `feat/core-scaffold`
- **P2 — Spherical world**: planet shell, spherical gravity, radial camera. → `feat/spherical-world`
- **P3 — Game**: gym map builder, caricature heads, kill streaks + flame hair, queue + league champs, HUD. → `feat/gym-and-characters`

## Repo layout (mirrors Roblox places)

```
src/
  ReplicatedStorage/Modules/     ModuleScripts
  ServerScriptService/           Scripts
  StarterPlayer/StarterPlayerScripts/  LocalScripts
```

## Workflow

1. Plan lives here in `PLAN.md`; each workstream is a GitHub issue.
2. One branch per PR (`feat/...`), PR links the issue, squash-merge to `main`.
3. In Studio: scripts are copied from `src/` into matching containers by class
   (`Script` / `LocalScript` / `ModuleScript`).
