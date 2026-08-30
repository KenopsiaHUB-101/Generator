# BUILD & FIGHTER — Gundam Themed (Roblox)

A single-file Roblox Lua game built for **Studio Lite + Delta Executor**.
No loader. No multiple scripts. Just one `build_and_fighter.lua` you paste and Execute.

> Repo: https://github.com/KenopsiaHUB-101/Generator

---

## How to run it

1. Open Roblox → join **Studio Lite**:
   https://www.roblox.com/id/games/10959918411/Studio-Lite
2. Open **Delta Executor**.
3. Paste the **entire contents** of `build_and_fighter.lua`.
4. Press **Execute**. The game builds itself into the live place.
5. Press **Play** in Studio Lite — the game is ready immediately.

---

## What's in the game

- **8 garage plots** per server (one per player). New players auto-claim a free plot.
- **Tutorial** on first join — 7 guided steps explaining build, fight, drops, tiers.
- **Free-form build system**: tap any part in the BUILD menu, then tap anywhere in your
  garage to place it. The only rule is the **Core Seat** (pre-placed) — every part you
  add welds to it automatically. No limitations on shape or layout.
- **Drive your Gundam**: sit in the Core Seat to control it.
  - Walk / jump (works with mobile thumbstick + on-screen JUMP button)
  - **BEAM** rifle (raycast, cooldown) — keyboard `F`
  - **MELEE** slash (area damage) — keyboard `E`
- **Tiered monsters** roam the arena (D → C → B → A → S → SS → SSS).
  Higher tier = more HP, more damage, more XP, better drops.
- **Drops** on kill: hands, feet, head, body, weapons, shields, hair, tails, eyes,
  armor, backpacks — each with its own **tier** and **level requirement**.
- **Level / XP** progression. Level up by killing monsters.
- **Inventory** with equip/level-gating.
- **PVP modes**: 5v5 (Red vs Blue teams) or Open World (fight anyone).
- **Mobile friendly**: on-screen buttons for BUILD, INV, FIGHT, BEAM, MELEE, JUMP;
  thumbstick-aware movement; large touch targets.
- **Professional visuals**: neon Gundam parts per tier, atmosphere + fog, grid arena,
  glowing build ghost preview, tweened spawn/damage/death FX, synthesized sounds.

---

## Controls

| Action        | Keyboard   | Mobile           |
|---------------|------------|------------------|
| Build menu    | `B`        | 🛠 BUILD button  |
| Inventory     | `I`        | 🎒 INV button    |
| Fight / mode  | —          | ⚔ FIGHT button   |
| Beam          | `F`        | BEAM button      |
| Melee         | `E`        | MELEE button     |
| Jump (driving)| `Space`    | JUMP button      |
| Place part    | Click      | Tap in garage    |

---

## File

- `build_and_fighter.lua` — the entire game. Copy-paste into Delta Executor.

## Suggestions baked in (50 updates)

1. 8 plots/garages per server
2. Auto plot assignment
3. First-time tutorial (7 steps, skippable)
4. Tiered monster system (7 tiers)
5. Free-form build with grid snap
6. Core Seat required to drive
7. Auto-weld every part to core
8. Beam rifle with cooldown
9. Melee slash with area damage
10. Mobile on-screen combat buttons
11. Thumbstick-aware mech movement
12. Jump while driving
13. Inventory with tier + level requirements
14. Level-gated part usage
15. XP & level progression (1–100)
16. Kill streak counter
17. PVP 5v5 (Red/Blue teams)
18. Open World mode
19. Mode select panel
20. Neon tier-colored parts
21. Glowing build ghost preview
22. Red/green ghost for valid/invalid placement
23. Plot-bound building enforcement
24. Atmosphere + fog lighting
25. Grid-textured arena floor
26. Invisible arena border walls
27. Garage shells with numbered signs
28. Tweened part spawn animation
29. Tweened part removal
30. Death explosion FX
31. Beam visual + raycast
32. Melee slash FX
33. Hit flash FX on monsters
34. Synthesized sound effects (no asset deps)
35. Toast notification system
36. Top HUD: level / XP bar / streak
37. Scrolling build catalog
38. Scrolling inventory grid
39. Starter inventory (body/weapon/legs)
40. Monster auto-scaling to avg player level
41. Monster wander + chase AI
42. Monster attack with damage
43. Last-attacker tracking for XP/drops
44. 1–3 random drops per kill
45. Speed boost from legs/feet
46. Weapon boost from weapons
47. Armor boost from armor plates
48. Driver UI auto-show/hide
49. Plot cleanup on leave
50. Single-file, no-loader, paste-and-play
