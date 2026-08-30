--[[
=====================================================================
  BUILD & FIGHTER  —  Gundam Themed (Mobile Friendly)
  Single-file Roblox Lua script for Studio Lite / Delta Executor
  Author: Generator (KenopsiaHUB-101)
  Repo : https://github.com/KenopsiaHUB-101/Generator
=====================================================================
  HOW TO USE
  1) Open Roblox -> join "Studio Lite"
  2) In Delta executor, paste the entire contents of this file
     and Execute.  The game builds itself into the live place.
  3) Press Play in Studio Lite and the game is ready immediately.
  NOTE: Everything runs from ONE loadstring. No loader required.

  DESIGN
  - 8 garage plots per server (one per player).
  - New players get a step-by-step tutorial.
  - Kill tiered Gundam monsters -> they drop build parts
    (hands, feet, head, body, weapons, shields, hair, tails, eyes,
     armor) each with their own tier + level requirement.
  - Free-form build: place any part anywhere; the only rule is a
    "Core Seat" must exist so the Gundam can be driven.
  - Sit in the Core Seat -> control the Gundam (walk, jump, melee,
    beam rifle).  Works in PVP 5v5 or open world.
  - Mobile friendly: on-screen buttons + joystick tolerance.
=====================================================================
]]

---------------------------------------------------------------------
-- 0. SAFE ENVIRONMENT & SERVICES
---------------------------------------------------------------------
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local SoundService      = game:GetService("SoundService")
local StarterGui        = game:GetService("StarterGui")

-- Studio Lite sometimes disables server scripts; we run everything
-- inside a single LocalScript-style coroutine so it works client-side.
local IsStudioLite = not RunService:IsRunning() or (RunService:IsStudio() and not game:GetService("RunService"):IsServer())

---------------------------------------------------------------------
-- 1. CONFIGURATION TABLE
---------------------------------------------------------------------
local CFG = {
    MaxPlots          = 8,          -- 8 garages per server
    PlotSize          = Vector3.new(60, 1, 60),
    PlotGap           = 8,
    ArenaSize         = Vector3.new(420, 1, 420),
    StartLevel        = 1,
    MaxLevel          = 100,
    XPPerLevel        = 250,
    BeamCooldown      = 1.4,
    MeleeCooldown     = 0.7,
    MonsterRespawn    = 18,
    MaxMonstersArena  = 14,
    BuildGrid         = 2,          -- snap step in studs (0 = free)
    TutorialVersion   = 3,
    ThemeColors = {
        Primary   = Color3.fromRGB(33, 150, 243),
        Secondary = Color3.fromRGB(0, 230, 118),
        Danger    = Color3.fromRGB(255, 61, 61),
        Warning   = Color3.fromRGB(255, 179, 0),
        Background= Color3.fromRGB(18, 20, 27),
        Panel     = Color3.fromRGB(28, 31, 41),
        Accent    = Color3.fromRGB(120, 200, 255),
        Gold      = Color3.fromRGB(255, 215, 0),
    },
}

-- Tiers used by monsters AND drops.
local TIERS = {
    {name="D",   color=Color3.fromRGB(160,160,160), hp=120,  dmg=8,  xp=60,  reqLvl=1},
    {name="C",   color=Color3.fromRGB(80,200,120),  hp=260,  dmg=14, xp=120, reqLvl=4},
    {name="B",   color=Color3.fromRGB(80,160,255),  hp=520,  dmg=22, xp=240, reqLvl=9},
    {name="A",   color=Color3.fromRGB(180,100,255), hp=900,  dmg=34, xp=460, reqLvl=16},
    {name="S",   color=Color3.fromRGB(255,120,200), hp=1500, dmg=48, xp=820, reqLvl=26},
    {name="SS",  color=Color3.fromRGB(255,210,60),  hp=2400, dmg=66, xp=1500,reqLvl=38},
    {name="SSS", color=Color3.fromRGB(255,80,80),   hp=4000, dmg=90, xp=3000,reqLvl=52},
}

-- Build-part catalog. Each part has a category, default size, mass,
-- and which "slot" it can attach to on the Gundam core.
local PART_CATALOG = {
    -- category   = {displayName, baseSize, slot, statTags}
    Core      = {name="Core Seat",  size=Vector3.new(4,2,4),  slot="core",  tierBoost=0},
    Head      = {name="Head",       size=Vector3.new(3,3,3),  slot="head",  tierBoost=2},
    Body      = {name="Body",       size=Vector3.new(5,5,3),  slot="body",  tierBoost=3},
    Arm       = {name="Arm",        size=Vector3.new(2,5,2),  slot="arm",   tierBoost=1},
    Hand      = {name="Hand",       size=Vector3.new(2,3,2),  slot="hand",  tierBoost=1},
    Leg       = {name="Leg",        size=Vector3.new(3,6,3),  slot="leg",   tierBoost=2},
    Foot      = {name="Foot",       size=Vector3.new(4,1,5),  slot="foot",  tierBoost=1},
    Weapon    = {name="Weapon",     size=Vector3.new(3,3,8),  slot="weapon",tierBoost=4},
    Shield    = {name="Shield",     size=Vector3.new(6,8,1),  slot="shield",tierBoost=3},
    Armor     = {name="Armor Plate",size=Vector3.new(4,4,1),  slot="armor", tierBoost=2},
    Hair      = {name="Hair",       size=Vector3.new(3,2,3),  slot="hair",  tierBoost=1},
    Tail      = {name="Tail",       size=Vector3.new(2,6,2),  slot="tail",  tierBoost=1},
    Eye       = {name="Eye Sensor", size=Vector3.new(1,1,1),  slot="eye",   tierBoost=0},
    Backpack  = {name="Backpack",   size=Vector3.new(5,5,3),  slot="back",  tierBoost=2},
}

---------------------------------------------------------------------
-- 2. UTILITIES
---------------------------------------------------------------------
local function uid()
    return HttpService:GenerateGUID(false)
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function lerp(a,b,t) return a + (b-a)*t end

local function round(n, dp)
    local m = 10^(dp or 0)
    return math.floor(n*m + 0.5)/m
end

-- create a styled Frame
local function panel(parent, size, pos, color, radius)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = color or CFG.ThemeColors.Panel
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0.5,0.5)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = f
    local s = Instance.new("UIStroke")
    s.Color = CFG.ThemeColors.Primary
    s.Thickness = 1.5
    s.Transparency = 0.4
    s.Parent = f
    f.Parent = parent
    return f
end

local function button(parent, text, size, pos, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.AnchorPoint = Vector2.new(0.5,0.5)
    b.BackgroundColor3 = color or CFG.ThemeColors.Primary
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = b
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,6); p.PaddingRight = UDim.new(0,6)
    p.PaddingTop = UDim.new(0,4); p.PaddingBottom = UDim.new(0,4)
    p.Parent = b
    b.Parent = parent
    return b
end

local function label(parent, text, size, pos, color, font, scaled)
    local t = Instance.new("TextLabel")
    t.Size = size
    t.Position = pos
    t.AnchorPoint = Vector2.new(0.5,0.5)
    t.BackgroundTransparency = 1
    t.Text = text
    t.Font = font or Enum.Font.GothamMedium
    t.TextColor3 = color or Color3.new(1,1,1)
    t.TextScaled = scaled == nil and true or scaled
    t.TextWrapped = true
    t.Parent = parent
    return t
end

-- play a simple synthesized sound (no asset needed)
local function playSound(parent, id, vol, pitch)
    local s = Instance.new("Sound")
    s.SoundId = id or "rbxassetid://9118823104"
    s.Volume = vol or 0.5
    s.PlaybackSpeed = pitch or 1
    s.Parent = parent or Workspace
    s:Play()
    game:GetService("Debris"):AddItem(s, 4)
    return s
end

local function worldFromScreen(screenPos, dist)
    local cam = Workspace.CurrentCamera
    return cam:ScreenPointToRay(screenPos.X, screenPos.Y, dist)
end

---------------------------------------------------------------------
-- 3. WORLD / ARENA / PLOTS
---------------------------------------------------------------------
local WorldFolder, PlotsFolder, MonstersFolder, FXFolder

local function buildWorld()
    if Workspace:FindFirstChild("BAF_World") then
        Workspace.BAF_World:Destroy()
    end
    local root = Instance.new("Folder")
    root.Name = "BAF_World"
    root.Parent = Workspace

    WorldFolder    = root
    PlotsFolder    = Instance.new("Folder", root); PlotsFolder.Name = "Plots"
    MonstersFolder = Instance.new("Folder", root); MonstersFolder.Name = "Monsters"
    FXFolder       = Instance.new("Folder", root); FXFolder.Name = "FX"

    -- Arena floor
    local arena = Instance.new("Part")
    arena.Name = "ArenaFloor"
    arena.Size = CFG.ArenaSize
    arena.Position = Vector3.new(0, 0, 0)
    arena.Anchored = true
    arena.Material = Enum.Material.Metal
    arena.Color = Color3.fromRGB(35, 40, 55)
    arena.TopSurface = Enum.SurfaceType.Smooth
    arena.Parent = root

    -- grid texture
    local grid = Instance.new("Texture")
    grid.Texture = "rbxassetid://6270499771"
    grid.StudsPerTileU = 8
    grid.StudsPerTileV = 8
    grid.Face = Enum.NormalId.Top
    grid.Transparency = 0.85
    grid.Parent = arena

    -- skybox / atmosphere
    local atm = Instance.new("Atmosphere")
    atm.Density = 0.32
    atm.Offset = 0.2
    atm.Color = Color3.fromRGB(120,170,255)
    atm.Haze = 1.5
    atm.Glare = 0.3
    atm.Parent = Lighting
    Lighting.ClockTime = 14
    Lighting.FogEnd = 900
    Lighting.FogColor = Color3.fromRGB(90,120,170)
    Lighting.Ambient = Color3.fromRGB(70,80,110)
    Lighting.OutdoorAmbient = Color3.fromRGB(80,90,120)

    -- border walls (invisible collide) so mechs don't fly off
    local wallProps = {
        {pos=Vector3.new(0, 30,  CFG.ArenaSize.Z/2 + 5), size=Vector3.new(CFG.ArenaSize.X+20, 60, 4)},
        {pos=Vector3.new(0, 30, -CFG.ArenaSize.Z/2 - 5), size=Vector3.new(CFG.ArenaSize.X+20, 60, 4)},
        {pos=Vector3.new( CFG.ArenaSize.X/2 + 5, 30, 0), size=Vector3.new(4, 60, CFG.ArenaSize.Z+20)},
        {pos=Vector3.new(-CFG.ArenaSize.X/2 - 5, 30, 0), size=Vector3.new(4, 60, CFG.ArenaSize.Z+20)},
    }
    for _,wp in ipairs(wallProps) do
        local w = Instance.new("Part")
        w.Anchored = true
        w.Size = wp.size
        w.Position = wp.pos
        w.Transparency = 1
        w.CanCollide = true
        w.Parent = root
    end

    -- PLOTS
    local cols = 4
    local spacingX = CFG.PlotSize.X + CFG.PlotGap
    local spacingZ = CFG.PlotSize.Z + CFG.PlotGap
    local startX = -((cols-1)/2)*spacingX
    local startZ = 120 -- plots behind arena
    for i=1, CFG.MaxPlots do
        local col = (i-1) % cols
        local row = math.floor((i-1)/cols)
        local px = startX + col*spacingX
        local pz = startZ + row*spacingZ

        local plot = Instance.new("Part")
        plot.Name = "Plot_"..i
        plot.Size = CFG.PlotSize
        plot.Position = Vector3.new(px, 1.05, pz)
        plot.Anchored = true
        plot.Material = Enum.Material.Neon
        plot.Color = CFG.ThemeColors.Primary
        plot.Transparency = 0.85
        plot.CanCollide = false
        plot.Parent = PlotsFolder

        -- garage shell (open box) for looks
        local function shell(offset, size, color)
            local p = Instance.new("Part")
            p.Size = size
            p.Position = Vector3.new(px, 1 + size.Y/2, pz) + offset
            p.Anchored = true
            p.Material = Enum.Material.Metal
            p.Color = color or Color3.fromRGB(45,50,65)
            p.Transparency = 0.15
            p.Parent = PlotsFolder
            return p
        end
        shell(Vector3.new(0, 18,  CFG.PlotSize.Z/2), Vector3.new(CFG.PlotSize.X+4, 36, 2))
        shell(Vector3.new(0, 18, -CFG.PlotSize.Z/2), Vector3.new(CFG.PlotSize.X+4, 36, 2))
        shell(Vector3.new( CFG.PlotSize.X/2, 18, 0), Vector3.new(2, 36, CFG.PlotSize.Z))
        shell(Vector3.new(-CFG.PlotSize.X/2, 18, 0), Vector3.new(2, 36, CFG.PlotSize.Z))
        -- roof
        shell(Vector3.new(0, 37, 0), Vector3.new(CFG.PlotSize.X+4, 2, CFG.PlotSize.Z+4), Color3.fromRGB(30,35,50))

        -- plot number sign
        local sg = Instance.new("SurfaceGui")
        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.fromScale(1,1)
        sl.BackgroundTransparency = 1
        sl.Text = "GARAGE #"..i
        sl.Font = Enum.Font.GothamBlack
        sl.TextColor3 = CFG.ThemeColors.Accent
        sl.TextScaled = true
        sl.Parent = sg
        sg.Face = Enum.NormalId.Top
        local sign = shell(Vector3.new(0, 37.1, 0), Vector3.new(CFG.PlotSize.X+4, 2, CFG.PlotSize.Z+4))
        sg.Parent = sign

        plot:SetAttribute("PlotId", i)
        plot:SetAttribute("Occupant", "")
    end

    -- center spawn pad (tutorial zone)
    local pad = Instance.new("Part")
    pad.Name = "TutorialPad"
    pad.Size = Vector3.new(30,1,30)
    pad.Position = Vector3.new(0,1.05,0)
    pad.Anchored = true
    pad.Material = Enum.Material.Neon
    pad.Color = CFG.ThemeColors.Gold
    pad.Transparency = 0.6
    pad.CanCollide = false
    pad.Parent = root
end

---------------------------------------------------------------------
-- 4. PLAYER DATA / LEVEL / INVENTORY
---------------------------------------------------------------------
local PlayerData = {}  -- [player] = { level, xp, plotId, inventory, equipped, mech, hasTutorial }

local function newData()
    return {
        level = CFG.StartLevel,
        xp = 0,
        plotId = nil,
        inventory = {},      -- list of {uid, category, tier, levelReq}
        equipped = {},       -- category -> item
        mech = nil,          -- built Gundam model reference
        hasTutorial = false,
        inBuildMode = false,
        killStreak = 0,
        team = "Open",
    }
end

local function assignPlot(player)
    local data = PlayerData[player]
    if not data then return end
    if data.plotId then return data.plotId end
    for _,p in ipairs(PlotsFolder:GetChildren()) do
        if p:GetAttribute("Occupant") == "" or p:GetAttribute("Occupant") == nil then
            p:SetAttribute("Occupant", player.Name)
            data.plotId = p:GetAttribute("PlotId")
            data.plotPart = p
            return data.plotId
        end
    end
end

local function giveXP(player, amount)
    local data = PlayerData[player]
    if not data then return end
    data.xp = data.xp + amount
    while data.xp >= CFG.XPPerLevel and data.level < CFG.MaxLevel do
        data.xp = data.xp - CFG.XPPerLevel
        data.level = data.level + 1
        playSound(player:FindFirstChildWhichIsA("PlayerGui"), "rbxassetid://9118823104", 0.6, 1.4)
    end
end

local function addItem(player, category, tierIndex)
    local data = PlayerData[player]
    if not data then return end
    local cat = PART_CATALOG[category]
    if not cat then return end
    table.insert(data.inventory, {
        uid = uid(),
        category = category,
        name = cat.name,
        tier = tierIndex,
        levelReq = TIERS[tierIndex].reqLvl,
    })
end

---------------------------------------------------------------------
-- 5. MONSTER SYSTEM
---------------------------------------------------------------------
local Monsters = {}  -- active monster refs

local function makeMonster(tierIndex, position)
    local tier = TIERS[tierIndex]
    local model = Instance.new("Model")
    model.Name = "GundamBeast_"..tier.name

    -- torso
    local torso = Instance.new("Part")
    torso.Name = "HumanoidRootPart"
    torso.Size = Vector3.new(6,7,4)
    torso.Position = position + Vector3.new(0, 6, 0)
    torso.Material = Enum.Material.Metal
    torso.Color = tier.color
    torso.Parent = model
    model.PrimaryPart = torso

    -- head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(4,4,4)
    head.Color = Color3.fromRGB(30,30,40)
    head.Material = Enum.Material.Neon
    head.Parent = model
    local wj = Instance.new("WeldConstraint"); wj.Part0 = torso; wj.Part1 = head; wj.Parent = torso
    head.Position = torso.Position + Vector3.new(0, 5, 0)

    -- eyes (glow)
    for _,xo in ipairs({-1,1}) do
        local eye = Instance.new("Part")
        eye.Size = Vector3.new(0.8,0.8,0.4)
        eye.Color = Color3.fromRGB(255,40,40)
        eye.Material = Enum.Material.Neon
        eye.Parent = model
        eye.Position = head.Position + Vector3.new(xo*1.1, 0, 2)
        local ew = Instance.new("WeldConstraint"); ew.Part0=head; ew.Part1=eye; ew.Parent=head
    end

    -- arms
    for _,xo in ipairs({-1,1}) do
        local arm = Instance.new("Part")
        arm.Size = Vector3.new(2,7,2)
        arm.Color = tier.color
        arm.Material = Enum.Material.Metal
        arm.Parent = model
        arm.Position = torso.Position + Vector3.new(xo*5, 0, 0)
        local aw = Instance.new("WeldConstraint"); aw.Part0=torso; aw.Part1=arm; aw.Parent=torso
    end

    -- legs
    for _,xo in ipairs({-1,1}) do
        local leg = Instance.new("Part")
        leg.Size = Vector3.new(3,9,3)
        leg.Color = Color3.fromRGB(40,45,60)
        leg.Material = Enum.Material.Metal
        leg.Parent = model
        leg.Position = torso.Position + Vector3.new(xo*2, -8, 0)
        local lw = Instance.new("WeldConstraint"); lw.Part0=torso; lw.Part1=leg; lw.Parent=torso
    end

    -- health
    local hum = Instance.new("Humanoid")
    hum.MaxHealth = tier.hp
    hum.Health = tier.hp
    hum.WalkSpeed = 14
    hum.Parent = model

    model:SetAttribute("Tier", tierIndex)
    model:SetAttribute("Damage", tier.dmg)
    model:SetAttribute("XP", tier.xp)
    model.Parent = MonstersFolder

    -- behavior: wander + chase nearest player's mech/char
    task.spawn(function()
        local rng = Random.new()
        local target = nil
        while model.Parent and hum.Health > 0 do
            -- find nearest player character within 200 studs
            local nearest, ndist = nil, 999
            for _,pl in ipairs(Players:GetPlayers()) do
                local char = pl.Character or (data and data.mech)
                if char and char.PrimaryPart then
                    local d = (char.PrimaryPart.Position - torso.Position).Magnitude
                    if d < ndist then nearest, ndist = char, d end
                end
            end
            if nearest and ndist < 160 then
                -- chase
                local dir = (nearest.PrimaryPart.Position - torso.Position)
                dir = Vector3.new(dir.X, 0, dir.Z).Unit
                torso.CFrame = torso.CFrame:Lerp(CFrame.new(torso.Position + dir*hum.WalkSpeed*0.2, nearest.PrimaryPart.Position), 0.2)
            else
                -- wander
                local ang = rng:NextNumber(-math.pi, math.pi)
                local dir = Vector3.new(math.cos(ang),0,math.sin(ang))
                torso.CFrame = torso.CFrame:Lerp(CFrame.new(torso.Position + dir*hum.WalkSpeed*0.15, torso.Position + dir*100), 0.15)
            end
            -- attack if close
            if nearest and ndist < 12 then
                local victim = nearest:FindFirstChildOfClass("Humanoid")
                if victim and victim.Health > 0 then
                    victim:TakeDamage(tier.dmg)
                    -- hit FX
                    local fx = Instance.new("Part")
                    fx.Size = Vector3.new(2,2,2)
                    fx.Color = CFG.ThemeColors.Danger
                    fx.Material = Enum.Material.Neon
                    fx.Anchored = true
                    fx.CanCollide = false
                    fx.Position = nearest.PrimaryPart.Position
                    fx.Parent = FXFolder
                    game:GetService("Debris"):AddItem(fx, 0.3)
                    playSound(Workspace, "rbxassetid://9118823104", 0.4, 0.7)
                end
            end
            task.wait(0.4)
        end
    end)

    return model, hum
end

local function spawnMonsterWave()
    if #MonstersFolder:GetChildren() >= CFG.MaxMonstersArena then return end
    -- tier weighted by random + slight scaling to players avg level
    local avg = 1
    local n = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if PlayerData[pl] then avg = avg + PlayerData[pl].level; n = n+1 end
    end
    avg = n>0 and math.floor(avg/n) or 1
    local tierIdx = math.clamp(math.random(1, math.min(7, 1 + math.floor(avg/8))), 1, #TIERS)
    local ang = math.random()*math.pi*2
    local r = 80 + math.random()*120
    local pos = Vector3.new(math.cos(ang)*r, 1, math.sin(ang)*r)
    local m = makeMonster(tierIdx, pos)
    if m then
        table.insert(Monsters, m)
        m:WaitForChild("Humanoid").Died:Connect(function()
            -- drops + xp to nearest attacker
            local killer = m:GetAttribute("LastAttacker")
            local pl = killer and Players:FindFirstChild(killer)
            if pl and PlayerData[pl] then
                giveXP(pl, m:GetAttribute("XP") or 100)
                PlayerData[pl].killStreak = (PlayerData[pl].killStreak or 0) + 1
                -- drop 1-3 random parts at tier <= monster tier
                local drops = math.random(1,3)
                for _=1,drops do
                    local cats = {}
                    for k in pairs(PART_CATALOG) do if k ~= "Core" then table.insert(cats, k) end end
                    local cat = cats[math.random(#cats)]
                    local dt = math.random(1, m:GetAttribute("Tier"))
                    addItem(pl, cat, dt)
                end
            end
            -- death FX
            local fx = Instance.new("Part")
            fx.Size = Vector3.new(8,8,8)
            fx.Color = CFG.ThemeColors.Gold
            fx.Material = Enum.Material.Neon
            fx.Anchored = true
            fx.CanCollide = false
            fx.Position = m.PrimaryPart.Position
            fx.Transparency = 0.4
            fx.Parent = FXFolder
            tween(fx, TweenInfo.new(0.5), {Size=Vector3.new(20,20,20), Transparency=1})
            game:GetService("Debris"):AddItem(fx, 0.6)
            playSound(Workspace, "rbxassetid://9118823104", 0.7, 0.5)
            task.wait(0.5)
            if m then m:Destroy() end
        end)
    end
end

---------------------------------------------------------------------
-- 6. BUILD SYSTEM (free-form, weld to core seat)
---------------------------------------------------------------------
-- A "Mech" is a folder in the plot containing welded parts + a Seat.
-- Players add parts by clicking; the only requirement is a Core Seat.

local function makePartVisual(part, category, tierIndex)
    local tier = TIERS[tierIndex]
    part.Material = Enum.Material.Metal
    part.Color = tier.color
    -- subtle neon edge via a slightly larger transparent overlay
    local overlay = Instance.new("Part")
    overlay.Size = part.Size + Vector3.new(0.2,0.2,0.2)
    overlay.CFrame = part.CFrame
    overlay.Anchored = true
    overlay.CanCollide = false
    overlay.Transparency = 0.92
    overlay.Material = Enum.Material.Neon
    overlay.Color = tier.color
    overlay.Parent = part
    overlay.Name = "Glow"
end

local function buildCoreSeat(plotPos)
    local core = Instance.new("Part")
    core.Name = "CoreSeat"
    core.Size = PART_CATALOG.Core.size
    core.Position = plotPos + Vector3.new(0, 4, 0)
    core.Anchored = false
    core.CanCollide = true
    core.Material = Enum.Material.Neon
    core.Color = CFG.ThemeColors.Primary
    core.Parent = nil -- assigned later to mech folder
    makePartVisual(core, "Core", 1)
    -- the seat
    local seat = Instance.new("Seat")
    seat.Name = "DriveSeat"
    seat.Size = Vector3.new(4,1,4)
    seat.Position = core.Position + Vector3.new(0, 1.5, 0)
    seat.Color = CFG.ThemeColors.Accent
    seat.Material = Enum.Material.Neon
    seat.Parent = nil
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = core
    weld.Part1 = seat
    weld.Parent = core
    return core, seat, weld
end

-- create a new mech (folder) on a player's plot
local function createMech(player)
    local data = PlayerData[player]
    if not data or not data.plotPart then return end
    if data.mech then data.mech:Destroy() end
    local plotPos = data.plotPart.Position
    local folder = Instance.new("Folder")
    folder.Name = "Mech_"..player.Name
    folder.Parent = WorldFolder

    local core, seat, weld = buildCoreSeat(plotPos)
    core.Parent = folder
    seat.Parent = folder

    data.mech = folder
    data.mechCore = core
    data.mechSeat = seat

    -- mark seat so we know who's driving
    seat:SetAttribute("Owner", player.Name)

    -- when someone sits, we hook controls
    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        local occ = seat.Occupant
        if occ then
            local pl = Players:GetPlayerFromCharacter(occ.Parent)
            if pl then
                data.driver = pl
                seat:SetAttribute("Driving", true)
            end
        else
            data.driver = nil
            seat:SetAttribute("Driving", false)
        end
    end)

    return folder
end

-- add a part to a mech at a given world position (free-form)
local function addPartToMech(player, category, tierIndex, worldPos)
    local data = PlayerData[player]
    if not data or not data.mech then return end
    local cat = PART_CATALOG[category]
    if not cat then return end
    if data.level < TIERS[tierIndex].reqLvl then
        return false, "Level too low for this tier!"
    end
    local core = data.mechCore
    local part = Instance.new("Part")
    part.Name = cat.name
    part.Size = cat.size
    -- snap to grid if enabled
    local pos = worldPos
    if CFG.BuildGrid > 0 then
        pos = Vector3.new(
            math.round(pos.X/CFG.BuildGrid)*CFG.BuildGrid,
            math.round(pos.Y/CFG.BuildGrid)*CFG.BuildGrid,
            math.round(pos.Z/CFG.BuildGrid)*CFG.BuildGrid
        )
    end
    part.Position = pos
    part.Anchored = false
    part.CanCollide = true
    part.Parent = data.mech
    makePartVisual(part, category, tierIndex)
    -- weld to core (the heart of "free form": any part welds to core)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = core
    weld.Part1 = part
    weld.Parent = core
    -- apply tier stat as attribute on the mech (for combat)
    local boost = cat.tierBoost * tierIndex
    data.mech:SetAttribute("ArmorBoost", (data.mech:GetAttribute("ArmorBoost") or 0) + (cat.slot=="armor" and boost or 0))
    data.mech:SetAttribute("WeaponBoost", (data.mech:GetAttribute("WeaponBoost") or 0) + (cat.slot=="weapon" and boost or 0))
    data.mech:SetAttribute("SpeedBoost", (data.mech:GetAttribute("SpeedBoost") or 0) + ((cat.slot=="leg" or cat.slot=="foot") and boost or 0))
    -- animation pop
    part.Transparency = 1
    tween(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Transparency = 0})
    playSound(data.mech, "rbxassetid://9118823104", 0.3, 1.6)
    return part
end

local function removeLastPart(player)
    local data = PlayerData[player]
    if not data or not data.mech then return end
    local parts = {}
    for _,c in ipairs(data.mech:GetChildren()) do
        if c:IsA("BasePart") and c ~= data.mechCore and c ~= data.mechSeat and c.Name ~= "Glow" then
            table.insert(parts, c)
        end
    end
    if #parts > 0 then
        local last = parts[#parts]
        tween(last, TweenInfo.new(0.2), {Transparency=1, Size=last.Size*0.2})
        task.wait(0.2)
        last:Destroy()
    end
end

---------------------------------------------------------------------
-- 7. COMBAT CONTROLS (while driving)
---------------------------------------------------------------------
local function getDriverMech(player)
    local data = PlayerData[player]
    return data and data.mech, data and data.mechCore
end

local function fireBeam(player)
    local data = PlayerData[player]
    if not data or not data.driver == player then return end
    if (data.lastBeam or 0) + CFG.BeamCooldown > os.clock() then return end
    data.lastBeam = os.clock()
    local core = data.mechCore
    if not core then return end
    local cam = Workspace.CurrentCamera
    local origin = core.Position + Vector3.new(0, 4, 0)
    local dir = cam.CFrame.LookVector
    -- beam visual
    local beam = Instance.new("Part")
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Color = CFG.ThemeColors.Secondary
    beam.Size = Vector3.new(1.2, 1.2, 200)
    beam.CFrame = CFrame.new(origin, origin + dir) * CFrame.new(0,0,-100)
    beam.Parent = FXFolder
    tween(beam, TweenInfo.new(0.15), {Transparency=1, Size=Vector3.new(0.2,0.2,200)})
    game:GetService("Debris"):AddItem(beam, 0.2)
    playSound(Workspace, "rbxassetid://9118823104", 0.5, 1.8)
    -- raycast damage
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {data.mech, player.Character, FXFolder}
    local res = Workspace:Raycast(origin, dir * 300, params)
    if res and res.Instance then
        local model = res.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dmg = 30 + (data.mech:GetAttribute("WeaponBoost") or 0) * 5
                hum:TakeDamage(dmg)
                if model.Name:find("GundamBeast") then
                    model:SetAttribute("LastAttacker", player.Name)
                end
            end
        end
    end
end

local function meleeSwing(player)
    local data = PlayerData[player]
    if not data or not data.driver == player then return end
    if (data.lastMelee or 0) + CFG.MeleeCooldown > os.clock() then return end
    data.lastMelee = os.clock()
    local core = data.mechCore
    if not core then return end
    playSound(Workspace, "rbxassetid://9118823104", 0.5, 0.9)
    -- slash fx
    local slash = Instance.new("Part")
    slash.Anchored = true
    slash.CanCollide = false
    slash.Material = Enum.Material.Neon
    slash.Color = CFG.ThemeColors.Warning
    slash.Size = Vector3.new(8, 8, 1)
    slash.CFrame = core.CFrame * CFrame.new(0, 4, -6)
    slash.Parent = FXFolder
    tween(slash, TweenInfo.new(0.2), {Transparency=1, Size=Vector3.new(12,12,1)})
    game:GetService("Debris"):AddItem(slash, 0.25)
    -- damage nearby
    local dmg = 45 + (data.mech:GetAttribute("WeaponBoost") or 0) * 4
    for _,m in ipairs(MonstersFolder:GetChildren()) do
        local hum = m:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 and m.PrimaryPart and (m.PrimaryPart.Position - core.Position).Magnitude < 14 then
            hum:TakeDamage(dmg)
            m:SetAttribute("LastAttacker", player.Name)
        end
    end
end

-- movement while driving: apply velocity based on input
local function setupDriveControls(player)
    local data = PlayerData[player]
    if not data then return end
    local core = data.mechCore
    if not core then return end
    -- weld the player's character to the seat so they ride along
    task.spawn(function()
        while data.driver == player and core.Parent do
            local char = player.Character
            if char and char.PrimaryPart then
                local moveDir = char:FindFirstChild("MoveDirection")
                local hv = Vector3.new(0,0,0)
                -- use Humanoid MoveDirection (works with mobile thumbstick)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hv = hum.MoveDirection
                end
                local speed = 24 + (data.mech:GetAttribute("SpeedBoost") or 0)*2
                -- apply force-ish via CFrame lerp (anchored false mech)
                if hv.Magnitude > 0 then
                    local newPos = core.Position + hv * speed * 0.1
                    -- keep upright
                    core.CFrame = core.CFrame:Lerp(CFrame.new(newPos, newPos + hv), 0.2)
                end
                -- jump
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) or data.mobileJump then
                    if core.AssemblyLinearVelocity.Y > -1 and core.Position.Y < 12 then
                        core.AssemblyLinearVelocity = Vector3.new(core.AssemblyLinearVelocity.X, 60, core.AssemblyLinearVelocity.Z)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

---------------------------------------------------------------------
-- 8. UI (mobile friendly)
---------------------------------------------------------------------
local UIs = {} -- [player] = {screen, ...}

local function buildUI(player)
    if UIs[player] then UIs[player].screen:Destroy() end
    local pg = player:WaitForChild("PlayerGui")

    local screen = Instance.new("ScreenGui")
    screen.Name = "BAF_UI"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = pg

    local refs = {screen = screen}

    -- TOP BAR: level / xp / streak
    local topbar = panel(screen, UDim2.new(0.6,0,0,46), UDim2.new(0.5,0,0,28), CFG.ThemeColors.Panel, 14)
    topbar.AnchorPoint = Vector2.new(0.5,0)
    refs.topbar = topbar
    refs.levelLbl = label(topbar, "LV 1", UDim2.new(0.12,0,0.5,0), UDim2.new(0.08,0,0.5,0), Color3.new(1,1,1), Enum.Font.GothamBlack)
    refs.xpBarBg = panel(topbar, UDim2.new(0.5,0,0,12), UDim2.new(0.4,0,0.5,0), Color3.fromRGB(40,45,60), 8)
    refs.xpBar = panel(refs.xpBarBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0.5,0), CFG.ThemeColors.Secondary, 8)
    refs.xpBar.AnchorPoint = Vector2.new(0,0.5)
    refs.streakLbl = label(topbar, "Streak 0", UDim2.new(0.2,0,1,0), UDim2.new(0.85,0,0.5,0), CFG.ThemeColors.Gold, Enum.Font.GothamBold)

    -- BUILD button (bottom-left)
    refs.buildBtn = button(screen, "🛠 BUILD", UDim2.new(0.16,0,0,52), UDim2.new(0.1,0,0.93,0), CFG.ThemeColors.Primary)
    refs.invBtn   = button(screen, "🎒 INV",   UDim2.new(0.16,0,0,52), UDim2.new(0.27,0,0.93,0), CFG.ThemeColors.Secondary)
    refs.fightBtn = button(screen, "⚔ FIGHT",  UDim2.new(0.16,0,0,52), UDim2.new(0.44,0,0.93,0), CFG.ThemeColors.Danger)

    -- combat buttons (mobile) bottom-right
    refs.beamBtn  = button(screen, "BEAM",   UDim2.new(0.16,0,0,56), UDim2.new(0.82,0,0.86,0), CFG.ThemeColors.Secondary)
    refs.meleeBtn = button(screen, "MELEE",  UDim2.new(0.16,0,0,56), UDim2.new(0.82,0,0.96,0), CFG.ThemeColors.Warning)
    refs.jumpBtn  = button(screen, "JUMP",   UDim2.new(0.14,0,0,56), UDim2.new(0.66,0,0.96,0), CFG.ThemeColors.Primary)

    refs.beamBtn.Visible = false
    refs.meleeBtn.Visible = false
    refs.jumpBtn.Visible = false

    -- BUILD PANEL (center modal)
    refs.buildPanel = panel(screen, UDim2.new(0.5,0,0.7,0), UDim2.new(0.5,0,0.5,0), CFG.ThemeColors.Panel, 16)
    refs.buildPanel.Visible = false
    local bpTitle = label(refs.buildPanel, "BUILD MENU — select a part then click in your garage", UDim2.new(0.9,0,0,30), UDim2.new(0.5,0,0.08,0), CFG.ThemeColors.Accent, Enum.Font.GothamBold)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9,0,0.6,0)
    scroll.Position = UDim2.new(0.5,0,0.5,0)
    scroll.AnchorPoint = Vector2.new(0.5,0.5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 6
    scroll.UIGridLayout = Instance.new("UIGridLayout")
    scroll.UIGridLayout.CellSize = UDim2.new(0.3,0,0,70)
    scroll.UIGridLayout.CellPadding = UDim2.new(0.02,0,0,0.02)
    scroll.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.UIGridLayout.Parent = scroll
    scroll.Parent = refs.buildPanel
    refs.buildScroll = scroll
    refs.buildClose = button(refs.buildPanel, "✕", UDim2.new(0,32,0,32), UDim2.new(0.97,0,0.06,0), CFG.ThemeColors.Danger)
    refs.buildHint = label(refs.buildPanel, "", UDim2.new(0.9,0,0,22), UDim2.new(0.5,0,0.93,0), CFG.ThemeColors.Warning, Enum.Font.GothamMedium)

    -- INVENTORY PANEL
    refs.invPanel = panel(screen, UDim2.new(0.4,0,0.7,0), UDim2.new(0.5,0,0.5,0), CFG.ThemeColors.Panel, 16)
    refs.invPanel.Visible = false
    label(refs.invPanel, "INVENTORY", UDim2.new(0.9,0,0,30), UDim2.new(0.5,0,0.08,0), CFG.ThemeColors.Accent, Enum.Font.GothamBold).Parent = refs.invPanel
    local invScroll = Instance.new("ScrollingFrame")
    invScroll.Size = UDim2.new(0.9,0,0.7,0)
    invScroll.Position = UDim2.new(0.5,0,0.55,0)
    invScroll.AnchorPoint = Vector2.new(0.5,0.5)
    invScroll.BackgroundTransparency = 1
    invScroll.BorderSizePixel = 0
    invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    invScroll.CanvasSize = UDim2.new(0,0,0,0)
    invScroll.ScrollBarThickness = 6
    local ig = Instance.new("UIGridLayout")
    ig.CellSize = UDim2.new(0.45,0,0,64)
    ig.CellPadding = UDim2.new(0.03,0,0,0.03)
    ig.Parent = invScroll
    invScroll.Parent = refs.invPanel
    refs.invScroll = invScroll
    refs.invClose = button(refs.invPanel, "✕", UDim2.new(0,32,0,32), UDim2.new(0.97,0,0.06,0), CFG.ThemeColors.Danger)

    -- TUTORIAL overlay
    refs.tutPanel = panel(screen, UDim2.new(0.7,0,0.55,0), UDim2.new(0.5,0,0.5,0), CFG.ThemeColors.Panel, 18)
    refs.tutPanel.Visible = false
    refs.tutTitle = label(refs.tutPanel, "WELCOME, PILOT", UDim2.new(0.9,0,0,40), UDim2.new(0.5,0,0.12,0), CFG.ThemeColors.Accent, Enum.Font.GothamBlack)
    refs.tutBody = label(refs.tutPanel, "", UDim2.new(0.88,0,0.6,0), UDim2.new(0.5,0,0.5,0), Color3.fromRGB(220,225,240), Enum.Font.GothamMedium)
    refs.tutBody.TextYAlignment = Enum.TextYAlignment.Top
    refs.tutNext = button(refs.tutPanel, "NEXT ➜", UDim2.new(0.3,0,0,44), UDim2.new(0.5,0,0.88,0), CFG.ThemeColors.Primary)
    refs.tutSkip = button(refs.tutPanel, "skip", UDim2.new(0.12,0,0,28), UDim2.new(0.9,0,0.08,0), CFG.ThemeColors.Panel)

    -- MODE SELECT (PVP 5v5 / Open world)
    refs.modePanel = panel(screen, UDim2.new(0.4,0,0.4,0), UDim2.new(0.5,0,0.5,0), CFG.ThemeColors.Panel, 18)
    refs.modePanel.Visible = false
    label(refs.modePanel, "SELECT MODE", UDim2.new(0.9,0,0,30), UDim2.new(0.5,0,0.18,0), CFG.ThemeColors.Accent, Enum.Font.GothamBlack).Parent = refs.modePanel
    refs.modePVP = button(refs.modePanel, "PVP 5v5", UDim2.new(0.4,0,0,46), UDim2.new(0.3,0,0.55,0), CFG.ThemeColors.Danger)
    refs.modeOpen = button(refs.modePanel, "OPEN WORLD", UDim2.new(0.4,0,0,46), UDim2.new(0.7,0,0.55,0), CFG.ThemeColors.Secondary)
    refs.modeClose = button(refs.modePanel, "✕", UDim2.new(0,30,0,30), UDim2.new(0.93,0,0.12,0), CFG.ThemeColors.Danger)

    -- notification toast
    refs.toast = panel(screen, UDim2.new(0.4,0,0,40), UDim2.new(0.5,0,0,0.12), CFG.ThemeColors.Panel, 10)
    refs.toast.Visible = false
    refs.toastLbl = label(refs.toast, "", UDim2.new(0.95,0,1,0), UDim2.new(0.5,0,0.5,0), Color3.new(1,1,1), Enum.Font.GothamBold)

    -- build mode ghost preview
    refs.ghost = Instance.new("Part")
    refs.ghost.Anchored = true
    refs.ghost.CanCollide = false
    refs.ghost.Transparency = 0.6
    refs.ghost.Material = Enum.Material.Neon
    refs.ghost.Color = CFG.ThemeColors.Accent
    refs.ghost.Parent = Workspace
    refs.ghost.Name = "BuildGhost"
    refs.ghost.Transparency = 1

    UIs[player] = refs
    return refs
end

local function toast(player, text)
    local r = UIs[player]
    if not r then return end
    r.toastLbl.Text = text
    r.toast.Visible = true
    r.toast.Position = UDim2.new(0.5,0,0,0.06)
    tween(r.toast, TweenInfo.new(0.3), {Position = UDim2.new(0.5,0,0,0.12)})
    task.delay(2.2, function()
        tween(r.toast, TweenInfo.new(0.3), {Position = UDim2.new(0.5,0,0,0.06)})
        task.wait(0.3)
        if r.toast then r.toast.Visible = false end
    end)
end

---------------------------------------------------------------------
-- 9. TUTORIAL
---------------------------------------------------------------------
local TUT_STEPS = {
    "Welcome to BUILD & FIGHTER! You start in your own garage plot. There are 8 garages per server — one is yours.",
    "Tap 🛠 BUILD to open the build menu. Pick a part, then TAP anywhere in your garage to place it. Build freely — no limits!",
    "Your Gundam needs a CORE SEAT. It's already placed for you. Every part you add welds to it automatically.",
    "Defeat Gundam monsters roaming the arena. Stronger ones (higher tier) drop rarer parts: weapons, shields, armor, tails, eyes and more.",
    "Each part has a TIER and a LEVEL requirement. Level up by killing monsters and earning XP.",
    "When ready, tap ⚔ FIGHT then sit in the Core Seat to drive your Gundam. Use BEAM and MELEE buttons. Works in PVP 5v5 or open world.",
    "Good luck, pilot. Build something legendary!",
}

local function runTutorial(player)
    local data = PlayerData[player]
    local r = UIs[player]
    if not r or not data then return end
    if data.hasTutorial then return end
    local step = 1
    r.tutPanel.Visible = true
    local function show()
        r.tutTitle.Text = step==1 and "WELCOME, PILOT" or ("STEP "..step)
        r.tutBody.Text = TUT_STEPS[step]
        r.tutNext.Text = step < #TUT_STEPS and "NEXT ➜" or "START ▶"
    end
    show()
    r.tutNext.MouseButton1Click:Once(function()
        if step < #TUT_STEPS then
            step = step + 1
            show()
            r.tutNext.MouseButton1Click:Once(function() task.defer(function()
                if step >= #TUT_STEPS then
                    r.tutPanel.Visible = false
                    data.hasTutorial = true
                    toast(player, "Tutorial complete! Go build your Gundam.")
                else
                    step = step + 1
                    show()
                end
            end) end)
        end
    end)
    -- simpler robust handler:
    local conn
    conn = r.tutNext.MouseButton1Click:Connect(function()
        if step < #TUT_STEPS then
            step = step + 1
            show()
        else
            r.tutPanel.Visible = false
            data.hasTutorial = true
            toast(player, "Tutorial complete! Go build your Gundam.")
            conn:Disconnect()
        end
    end)
    r.tutSkip.MouseButton1Click:Once(function()
        r.tutPanel.Visible = false
        data.hasTutorial = true
        toast(player, "Tutorial skipped. Tap BUILD to start.")
    end)
end

---------------------------------------------------------------------
-- 10. INPUT / WIRING
---------------------------------------------------------------------
local function refreshBuildMenu(player)
    local r = UIs[player]
    local data = PlayerData[player]
    if not r or not data then return end
    -- clear
    for _,c in ipairs(r.buildScroll:GetChildren()) do
        if c:IsA("GuiButton") then c:Destroy() end
    end
    -- one button per category (uses best tier the player owns or D)
    local order = {"Core","Head","Body","Arm","Hand","Leg","Foot","Weapon","Shield","Armor","Hair","Tail","Eye","Backpack"}
    for i,cat in ipairs(order) do
        local info = PART_CATALOG[cat]
        local b = button(r.buildScroll, info.name.."\n"..(cat=="Core" and "(placed)" or "Tier D+"), UDim2.new(0.3,0,0,70), UDim2.new(0,0,0,0), cat=="Core" and CFG.ThemeColors.Primary or CFG.ThemeColors.Secondary)
        b.TextWrapped = true
        b.LayoutOrder = i
        b.MouseButton1Click:Connect(function()
            data.selectedCategory = cat
            data.selectedTier = 1
            r.buildHint.Text = "Selected: "..info.name.." — TAP in your garage to place. (Core already placed)"
            toast(player, "Selected "..info.name..". Tap your garage to build.")
        end)
    end
end

local function refreshInventory(player)
    local r = UIs[player]
    local data = PlayerData[player]
    if not r or not data then return end
    for _,c in ipairs(r.invScroll:GetChildren()) do
        if c:IsA("GuiButton") then c:Destroy() end
    end
    if #data.inventory == 0 then
        label(r.invScroll, "No parts yet. Kill monsters to get drops!", UDim2.new(0.9,0,0,40), UDim2.new(0.5,0,0,20), CFG.ThemeColors.Warning, Enum.Font.GothamMedium).Parent = r.invScroll
        return
    end
    for _,item in ipairs(data.inventory) do
        local tier = TIERS[item.tier]
        local b = button(r.invScroll, item.name.."\nTier "..tier.name.."\nReq Lv "..item.levelReq, UDim2.new(0.45,0,0,64), UDim2.new(0,0,0,0), tier.color)
        b.TextWrapped = true
        b.TextScaled = true
        b.MouseButton1Click:Connect(function()
            if data.level >= item.levelReq then
                data.selectedCategory = item.category
                data.selectedTier = item.tier
                toast(player, "Equipped "..item.name.." (Tier "..tier.name.."). Open BUILD and tap your garage.")
                r.invPanel.Visible = false
                refreshBuildMenu(player)
            else
                toast(player, "Need level "..item.levelReq.." to use this!")
            end
        end)
    end
end

local function setupInput(player)
    local r = UIs[player]
    local data = PlayerData[player]
    if not r or not data then return end

    -- BUILD toggle
    r.buildBtn.MouseButton1Click:Connect(function()
        data.inBuildMode = not data.inBuildMode
        r.buildPanel.Visible = data.inBuildMode
        if data.inBuildMode then
            refreshBuildMenu(player)
            r.ghost.Transparency = 0.6
        else
            r.ghost.Transparency = 1
        end
    end)
    r.buildClose.MouseButton1Click:Connect(function()
        data.inBuildMode = false
        r.buildPanel.Visible = false
        r.ghost.Transparency = 1
    end)

    -- INV toggle
    r.invBtn.MouseButton1Click:Connect(function()
        r.invPanel.Visible = not r.invPanel.Visible
        if r.invPanel.Visible then refreshInventory(player) end
    end)
    r.invClose.MouseButton1Click:Connect(function()
        r.invPanel.Visible = false
    end)

    -- FIGHT / MODE
    r.fightBtn.MouseButton1Click:Connect(function()
        r.modePanel.Visible = not r.modePanel.Visible
    end)
    r.modeClose.MouseButton1Click:Connect(function()
        r.modePanel.Visible = false
    end)
    r.modePVP.MouseButton1Click:Connect(function()
        data.team = data.team == "Red" and "Blue" or "Red"
        toast(player, "PVP 5v5 — You joined "..data.team.." team!")
        r.modePanel.Visible = false
    end)
    r.modeOpen.MouseButton1Click:Connect(function()
        data.team = "Open"
        toast(player, "Open World — fight anyone, anywhere!")
        r.modePanel.Visible = false
    end)

    -- COMBAT (mobile buttons + keyboard)
    r.beamBtn.MouseButton1Click:Connect(function() fireBeam(player) end)
    r.meleeBtn.MouseButton1Click:Connect(function() meleeSwing(player) end)
    r.jumpBtn.MouseButton1Click:Connect(function() data.mobileJump = true; task.delay(0.2, function() data.mobileJump = false end) end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F then fireBeam(player) end
        if input.KeyCode == Enum.KeyCode.E then meleeSwing(player) end
        if input.KeyCode == Enum.KeyCode.B then
            data.inBuildMode = not data.inBuildMode
            r.buildPanel.Visible = data.inBuildMode
            if data.inBuildMode then refreshBuildMenu(player); r.ghost.Transparency = 0.6 else r.ghost.Transparency = 1 end
        end
        if input.KeyCode == Enum.KeyCode.I then
            r.invPanel.Visible = not r.invPanel.Visible
            if r.invPanel.Visible then refreshInventory(player) end
        end
    end)

    -- click to place part (mouse / touch)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not data.inBuildMode then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if gp then return end
            -- ignore clicks on UI
            if UserInputService:GetGuiLocation(input.KeyCode) then return end
            local mousePos = input.Position
            local cam = Workspace.CurrentCamera
            local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Include
            params.FilterDescendantsInstances = {WorldFolder}
            local res = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
            if res and res.Position then
                -- only allow building inside the player's plot bounds
                if data.plotPart then
                    local pp = data.plotPart.Position
                    local hs = CFG.PlotSize/2
                    if math.abs(res.Position.X - pp.X) < hs.X and math.abs(res.Position.Z - pp.Z) < hs.Z then
                        local cat = data.selectedCategory or "Body"
                        local tier = data.selectedTier or 1
                        if cat == "Core" then
                            toast(player, "Core Seat is already placed!")
                            return
                        end
                        local ok, err = addPartToMech(player, cat, tier, res.Position + Vector3.new(0,1,0))
                        if not ok and err then toast(player, err) end
                    else
                        toast(player, "Build inside your own garage!")
                    end
                end
            end
        end
    end)

    -- ghost preview follow
    RunService.RenderStepped:Connect(function()
        if not data.inBuildMode or not data.plotPart then r.ghost.Transparency = 1 return end
        local mp = UserInputService:GetMouseLocation()
        local cam = Workspace.CurrentCamera
        local ray = cam:ViewportPointToRay(mp.X, mp.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = {WorldFolder}
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
        if res then
            local cat = data.selectedCategory or "Body"
            local info = PART_CATALOG[cat]
            r.ghost.Size = info.size
            local pp = data.plotPart.Position
            local hs = CFG.PlotSize/2
            if math.abs(res.Position.X - pp.X) < hs.X and math.abs(res.Position.Z - pp.Z) < hs.Z then
                r.ghost.Color = CFG.ThemeColors.Secondary
            else
                r.ghost.Color = CFG.ThemeColors.Danger
            end
            r.ghost.CFrame = CFrame.new(res.Position + Vector3.new(0, info.size.Y/2, 0))
            r.ghost.Transparency = 0.6
        else
            r.ghost.Transparency = 1
        end
    end)
end

---------------------------------------------------------------------
-- 11. DRIVER VISIBILITY (show combat buttons when driving)
---------------------------------------------------------------------
local function updateDriverUI(player)
    local r = UIs[player]
    local data = PlayerData[player]
    if not r or not data then return end
    local driving = data.driver == player
    r.beamBtn.Visible = driving
    r.meleeBtn.Visible = driving
    r.jumpBtn.Visible = driving
    if driving then
        toast(player, "Driving Gundam! BEAM / MELEE / JUMP enabled.")
    end
end

---------------------------------------------------------------------
-- 12. PER-PLAYER SETUP
---------------------------------------------------------------------
local function onPlayerAdded(player)
    PlayerData[player] = newData()
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        assignPlot(player)
        createMech(player)
        buildUI(player)
        setupInput(player)
        if not PlayerData[player].hasTutorial then
            runTutorial(player)
        end
        -- watch for sitting in core seat
        local data = PlayerData[player]
        if data.mechSeat then
            data.mechSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
                local occ = data.mechSeat.Occupant
                if occ and occ.Parent == char then
                    data.driver = player
                    setupDriveControls(player)
                    updateDriverUI(player)
                elseif not occ then
                    data.driver = nil
                    updateDriverUI(player)
                end
            end)
        end
    end)
end

local function onPlayerRemoving(player)
    local data = PlayerData[player]
    if data then
        if data.mech then data.mech:Destroy() end
        if data.plotPart then data.plotPart:SetAttribute("Occupant","") end
    end
    if UIs[player] then UIs[player].screen:Destroy() UIs[player]=nil end
    PlayerData[player] = nil
end

---------------------------------------------------------------------
-- 13. MAIN LOOP & SPAWNERS
---------------------------------------------------------------------
local function startGameLoops()
    -- monster spawner
    task.spawn(function()
        while true do
            spawnMonsterWave()
            task.wait(CFG.MonsterRespawn)
        end
    end)

    -- HUD updater
    task.spawn(function()
        while true do
            for pl, data in pairs(PlayerData) do
                local r = UIs[pl]
                if r and pl.Parent then
                    r.levelLbl.Text = "LV "..data.level
                    local pct = math.clamp(data.xp / CFG.XPPerLevel, 0, 1)
                    r.xpBar.Size = UDim2.new(pct, 0, 1, 0)
                    r.streakLbl.Text = "Streak "..(data.killStreak or 0)
                end
            end
            task.wait(0.25)
        end
    end)

    -- driver UI refresh
    task.spawn(function()
        while true do
            for pl,data in pairs(PlayerData) do
                updateDriverUI(pl)
            end
            task.wait(0.5)
        end
    end)
end

---------------------------------------------------------------------
-- 14. BOOT
---------------------------------------------------------------------
local function boot()
    buildWorld()
    -- connect existing + future players
    for _,pl in ipairs(Players:GetPlayers()) do
        onPlayerAdded(pl)
        if pl.Character then
            -- force re-fire
            local char = pl.Character
            task.spawn(function()
                task.wait(0.3)
                assignPlot(pl)
                createMech(pl)
                buildUI(pl)
                setupInput(pl)
                if not PlayerData[pl].hasTutorial then runTutorial(pl) end
            end)
        end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    startGameLoops()
    -- give everyone a small starter inventory
    task.spawn(function()
        while true do
            for pl,data in pairs(PlayerData) do
                if #data.inventory < 3 then
                    addItem(pl, "Body", 1)
                    addItem(pl, "Weapon", 1)
                    addItem(pl, "Leg", 1)
                end
            end
            task.wait(10)
        end
    end)
    print("[BUILD & FIGHTER] Game booted successfully. 8 plots ready. Monsters spawning.")
end

-- RUN IT
boot()
