local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Cam = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function kirimNotif(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
    end)
end

local NO_TEAM_COLORS = {
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(50, 100, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 255, 255),
}
local NO_TEAM_COLOR_NAMES = { "Merah", "Hijau", "Biru", "Kuning", "Putih" }

local CROSSHAIR_COLORS = {
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 150, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 255, 255),
}
local CROSSHAIR_COLOR_NAMES = { "Hijau", "Merah", "Biru", "Kuning", "Putih" }

local R6_AIM_PARTS = {
    "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
}
local R6_AIM_PART_NAMES = {
    "Head (R6)", "Torso (R6)", "L Arm (R6)", "R Arm (R6)", "L Leg (R6)", "R Leg (R6)"
}

local R15_AIM_PARTS = {
    "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerArm", "RightLowerArm",
    "LeftLowerLeg", "RightLowerLeg"
}
local R15_AIM_PART_NAMES = {
    "Head (R15)", "UprTorso (R15)", "LwrTorso (R15)", "L UprArm (R15)", "R UprArm (R15)",
    "L UprLeg (R15)", "R UprLeg (R15)", "L LwrArm (R15)", "R LwrArm (R15)",
    "L LwrLeg (R15)", "R LwrLeg (R15)"
}

local AUTO_FIRE_MODES = { "Off", "Left Click", "Right Click", "Scope & Shoot" }
local CROSSHAIR_STYLES = { "Cross", "Circle", "Dot" }

local AIM_MODES = { "Manual", "Dynamic" }

local Config = {
    Aimbot = {
        Enabled = true, TeamCheck = true, WallCheck = true,
        AimPartPreset = 1, AimPart = "Head",
        AimMode = "Manual",
        FOV = 150, ShowFOV = false, TriggerMode = false, TriggerKey = Enum.KeyCode.Unknown,
        AutoFireMode = "Off",
        ScopeHoldDuration = 0.3,
        ScopeReleaseDelay = 0.15,
        EasyLepasAim = false, EasyLepasThreshold = 3,
        AutoFlick = false, BigHeadEnabled = false, BigHeadSize = 11, HRPSize = 10,
        SmoothnessEnabled = false, Smoothness = 0.2, RandomizeHitpart = false,
        HitpartWeights = { Head = 70, Torso = 30, Legs = 20 },
        SmartTargeting = false, FlickRange = 200, SpinbotEnabled = false,
        SpinSpeed = 10, SpinMode = "Horizontal",
        TeamCheckWhitelist = {}, TeamCheckWhitelistEnabled = false, ScopeCooldown = 0.9,
        TargetPartKeybind = Enum.KeyCode.J,
        HumanizeAimEnabled = true,
        HumanizeIntensity = 3,
        HumanizeCurveChance = 0.4,
        HumanizeMicroCorrection = 0.3
    },
    ESP = {
        Enabled = true, BoxEnabled = true, SkeletonEnabled = false, TracerEnabled = true,
        NameEnabled = false, DistanceEnabled = false, HealthBarEnabled = false,
        ForceShowAll = false, AutoTeamDetect = true, AutoColorTeam = true,
        MaxDistance = 240, Thickness = 1.5, Transparency = 0.5,
        BoxColor = Color3.fromRGB(0, 150, 255), TracerColor = Color3.fromRGB(0, 150, 255),
        NameColor = Color3.fromRGB(255, 255, 255), DistColor = Color3.fromRGB(200, 200, 200),
        ChamsEnabled = true, ChamsFillTransparency = 0.5, ChamsOutlineTransparency = 0,
        NoTeamColorPreset = 1,
    },
    Crosshair = {
        Enabled = false,
        Style = "Cross",
        Size = 15,
        Thickness = 2,
        Transparency = 0.5,
        ColorPreset = 1,
    },
    CyberVision = {
        Enabled = false, ShowLookLine = true, LookLineLength = 6, TeamCheck = true,
        NormalColor = Color3.fromRGB(255, 255, 0), WarningColor = Color3.fromRGB(255, 0, 0),
        LineThickness = 1.5, Transparency = 0.6, WarnIfLookingAtMe = true,
        LookingAtMeThreshold = 0.7, MaxRender = 10,
    },
    Movement = {
        AutoBhop = false, AntiAim = false, AntiAimAngle = 45,
        AutoStrafe = true, StrafeSpeed = 40,
        WalkSpeedEnabled = false, WalkSpeedValue = 56,
        JumpPowerEnabled = false, JumpPowerValue = 100,
    },
    AutoPlay = {
        Enabled = false, EngageDistance = 80, HPThreshold = 50,
        AutoRespawn = true, CombatStrafeSpeed = 40, HumanMode = true,
        ReactionTime = 0.15, JiggleAim = true, RandomJumps = true,
        LookAround = true, MicroPause = true
    },
    Misc = {
        GuiKey = Enum.KeyCode.B, TeleportKey = Enum.KeyCode.P,
        TeleportHitButton = "Left",
        RGBWeapon = false, FOVChangerEnabled = false, CameraFOV = 70,
        AutoGoldenKnife = false, DimLighting = false, InfiniteAmmo = false,
        AntiLag = false
    }
}

local STATE = {
    ESPPool = {}, ESPActive = {}, ChamsActive = {}, ESPStudsObjects = {},
    MaxESPEntities = 25, GuiVisible = true, AnimatingGui = false, GuiTween = nil,
    TargetInFOV = false, CurrentTarget = nil, LockedTarget = nil,
    flickLockTarget = nil, LeftClickHeld = false, HoldingMouse = false,
    HoldingRightMouse = false, PlayerCache = {}, IsTeamGame = false,
    RGBHue = 0, RGBWeaponParts = {}, NextRGBUpdate = 0,
    lastTargetScan = 0, lastTargetVisible = true, lastBigHeadUpdate = 0,
    lastFOVUpdate = 0, lastBehindScan = 0, lastBehindTarget = nil,
    originalRootJointC0 = nil, AutoTarget = nil,
    currentAutoState = "Roaming", roamingTarget = nil, lastCombatAction = 0,
    lastMicroPause = 0, lastRandomJump = 0, lastLookAround = 0, lookAroundAngle = 0,
    strafePhase = 0, nextStrafeChange = 0, currentStrafeDir = Vector3.new(1, 0, 0),
    ammoValues = {}, storedAmmoValues = {}, ammoConnection = nil,
    CyberVisionPool = {}, spinAngle = 0,
    RenderConnection = nil, HeartbeatConnection = nil,
    InputBeganConnection = nil, InputEndedConnection = nil,
    AutoPlayThread = nil, AutoGoldenKnifeThread = nil,
    currentHitpart = "Head", lastPartChange = 0,
    ShowAimbotStatus = true,
    UIRegistry = {}, presets = {}, currentPresetSlot = "RAGE",
    activeWeightSlider = nil,
    isDraggingMainGui = false, isDraggingMobile = false,
    dragStartPos = nil, dragStartMouse = nil,
    mtDragStartPos = nil, mtDragStartMouse = nil,
    lastMousePos = nil,
    lastScopeShot = 0,
    isScoping = false,
    scopeStartTime = 0,
    hasShotInScope = false,
    CrosshairLines = {},
    CrosshairCircle = nil,
    mouseLockConnection = nil,
    scopeCooldown = 0,
    shotTime = 0,
    aimCurveProgress = 0,
    aimCurveStart = Vector3.zero,
    aimCurveControl = Vector3.zero,
    aimCurveEnd = Vector3.zero,
    isAimCurving = false,
    lastDynamicPartScan = 0,
    dynamicAimPart = "Head",
}

local R15Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local COLORS = {
    Accent = Color3.fromRGB(0, 150, 255), Bg = Color3.fromRGB(12, 12, 16),
    Card = Color3.fromRGB(24, 24, 32), Text = Color3.fromRGB(255, 255, 255),
    Sidebar = Color3.fromRGB(8, 8, 12),
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function updateIgnoreList()
    local currentInstances = { Cam }
    if LocalPlayer.Character then table.insert(currentInstances, LocalPlayer.Character) end
    rayParams.FilterDescendantsInstances = currentInstances
end
LocalPlayer.CharacterAdded:Connect(updateIgnoreList)
updateIgnoreList()

local wallCheckCache = setmetatable({}, { __mode = "k" })
local function isPlayerVisible(p, partName)
    if not Config.Aimbot.WallCheck then return true end
    local char = p.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return false end
    local targetPart = char:FindFirstChild(partName); if not targetPart then return false end
    local now = tick(); local cached = wallCheckCache[p]
    if cached and (now - cached.lastChecked) < 0.03 then return cached.visible end
    local myChar = LocalPlayer.Character; local head = myChar and myChar:FindFirstChild("Head")
    local origin = head and head.Position or Cam.CFrame.Position
    if #rayParams.FilterDescendantsInstances < 2 and myChar then updateIgnoreList() end
    local r = Workspace:Raycast(origin, targetPart.Position - origin, rayParams)
    local visible = not r or r.Instance:IsDescendantOf(char)
    wallCheckCache[p] = { visible = visible, lastChecked = now }
    return visible
end

local function isWhitelisted(player)
    if not Config.Aimbot.TeamCheckWhitelistEnabled then return false end
    if not player then return false end
    local whitelist = Config.Aimbot.TeamCheckWhitelist
    local displayName = player.DisplayName or ""
    local playerName = player.Name or ""
    for _, keyword in ipairs(whitelist) do
        local kw = string.lower(tostring(keyword))
        if string.find(string.lower(displayName), kw) or string.find(string.lower(playerName), kw) then
            return true
        end
    end
    return false
end

local function isPlayerAlive(p)
    if not p or p.Parent == nil then return false end
    local char = p.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Position.Y < -100 then return false end
    return hum and hum.Health > 0 and char:FindFirstChild("Head") ~= nil and hrp ~= nil
end

local function isCharacterR15(char)
    return char:FindFirstChild("UpperTorso") ~= nil
end

local function getAvailableAimParts(character)
    if not character then return R6_AIM_PARTS end
    if isCharacterR15(character) then
        return R15_AIM_PARTS
    else
        return R6_AIM_PARTS
    end
end

local function getAimPartNameFromPreset(p)
    local char = p.Character
    if not char then return "Head" end
    local availableParts = getAvailableAimParts(char)
    local presetIndex = Config.Aimbot.AimPartPreset
    if presetIndex < 1 or presetIndex > #availableParts then
        return availableParts[1] or "Head"
    end
    return availableParts[presetIndex] or availableParts[1] or "Head"
end

local function getDynamicAimPart(player)
    if tick() - STATE.lastDynamicPartScan < 0.1 then
        return STATE.dynamicAimPart
    end
    STATE.lastDynamicPartScan = tick()
    
    local char = player.Character
    if not char then
        STATE.dynamicAimPart = "Head"
        return STATE.dynamicAimPart
    end
    
    local isR15 = isCharacterR15(char)
    local priorityParts = isR15 and 
        {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm"} or
        {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    
    local mousePos = Cam.ViewportSize / 2
    local bestPart, bestDist = "Head", math.huge
    
    for _, partName in ipairs(priorityParts) do
        local part = char:FindFirstChild(partName)
        if part then
            local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
            if onScreen and screenPos.Z > 0 then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = partName
                end
            end
        end
    end
    
    STATE.dynamicAimPart = bestPart
    return STATE.dynamicAimPart
end

local function getAimPart(p)
    if Config.Aimbot.AimMode == "Dynamic" then
        return getDynamicAimPart(p)
    end
    
    if not Config.Aimbot.RandomizeHitpart then
        return getAimPartNameFromPreset(p)
    end
    if tick() - STATE.lastPartChange > 0.25 then
        STATE.lastPartChange = tick(); local char = p.Character
        if not char then STATE.currentHitpart = "Head"; return STATE.currentHitpart end
        local isR15 = isCharacterR15(char)
        local head = char:FindFirstChild("Head")
        local torso = isR15 and char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local legs = isR15 and char:FindFirstChild("LowerTorso") or char:FindFirstChild("Left Leg")
        if Config.Aimbot.SmartTargeting then
            local parts = {}
            if head then table.insert(parts, { part = head, key = "Head", weight = Config.Aimbot.HitpartWeights.Head }) end
            if torso then table.insert(parts, { part = torso, key = "Torso", weight = Config.Aimbot.HitpartWeights.Torso }) end
            if legs then table.insert(parts, { part = legs, key = "Legs", weight = Config.Aimbot.HitpartWeights.Legs }) end
            if #parts == 0 then STATE.currentHitpart = "Head"; return STATE.currentHitpart end
            local screenPositions = {}; local totalWeight = 0; local halfFOV = Config.Aimbot.FOV * 0.5
            for _, data in ipairs(parts) do
                local vec, onScreen = Cam:WorldToViewportPoint(data.part.Position)
                local screenDist = 9999
                if onScreen then screenDist = (Vector2.new(vec.X, vec.Y) - Cam.ViewportSize / 2).Magnitude end
                local closeness = math.clamp(1 - (screenDist / halfFOV), 0.1, 1)
                local w = data.weight * closeness; totalWeight = totalWeight + w
                table.insert(screenPositions, { key = data.key, part = data.part, weight = w })
            end
            if totalWeight <= 0 then STATE.currentHitpart = "Head"; return STATE.currentHitpart end
            local roll = math.random() * totalWeight; local cumulative = 0
            for _, data in ipairs(screenPositions) do
                cumulative = cumulative + data.weight
                if roll <= cumulative then STATE.currentHitpart = data.part.Name; return STATE.currentHitpart end
            end
            STATE.currentHitpart = screenPositions[#screenPositions].part.Name; return STATE.currentHitpart
        else
            local w = Config.Aimbot.HitpartWeights; local totalWeight = w.Head + w.Torso + w.Legs
            if totalWeight <= 0 then totalWeight = 1 end
            local roll = math.random(1, totalWeight)
            if roll <= w.Head then STATE.currentHitpart = "Head"
            elseif roll <= (w.Head + w.Torso) then STATE.currentHitpart = torso and torso.Name or "Head"
            else STATE.currentHitpart = legs and legs.Name or "Head" end
        end
    end
    return STATE.currentHitpart
end

local function getEnemyBehind()
    if tick() - STATE.lastBehindScan < 0.05 then return STATE.lastBehindTarget end
    STATE.lastBehindScan = tick()
    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then STATE.lastBehindTarget = nil; return nil end
    local camLook = Cam.CFrame.LookVector; local originPos = Cam.CFrame.Position; local candidates = {}
    for _, p in ipairs(STATE.PlayerCache) do
        if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
        if isWhitelisted(p) then continue end
        if not isPlayerAlive(p) then continue end
        local enemyHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if enemyHRP then
            local toEnemy = (enemyHRP.Position - originPos); local dist = toEnemy.Magnitude
            if dist < Config.Aimbot.FlickRange then
                if camLook:Dot(toEnemy.Unit) < -0.1 then table.insert(candidates, { player = p, dist = dist }) end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    for _, c in ipairs(candidates) do
        if isPlayerVisible(c.player, getAimPart(c.player)) then STATE.lastBehindTarget = c.player; return c.player end
    end
    STATE.lastBehindTarget = nil; return nil
end

local function getClosestInFOV(ignorePlayer)
    local mousePos = Cam.ViewportSize / 2; local nearest, fovCount = nil, 0
    if STATE.CurrentTarget and isPlayerAlive(STATE.CurrentTarget) and STATE.CurrentTarget ~= ignorePlayer then
        local aimPartName = getAimPart(STATE.CurrentTarget)
        local part = STATE.CurrentTarget.Character:FindFirstChild(aimPartName)
        if part and part.Position.Y > -50 then
            local vec, onScreen = Cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = math.sqrt((vec.X - mousePos.X) ^ 2 + (vec.Y - mousePos.Y) ^ 2)
                if dist < Config.Aimbot.FOV and isPlayerVisible(STATE.CurrentTarget, aimPartName) then
                    STATE.TargetInFOV = true; return STATE.CurrentTarget, 1
                end
            end
        end
    end
    local candidates = {}; local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil, 0 end
    for _, p in ipairs(STATE.PlayerCache) do
        if p == ignorePlayer then continue end
        if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
        if isWhitelisted(p) then continue end
        if not isPlayerAlive(p) then continue end
        local char = p.Character; local aimPartName = getAimPart(p)
        local part = char and char:FindFirstChild(aimPartName)
        local enemyHRP = char and char:FindFirstChild("HumanoidRootPart")
        if part and enemyHRP and part.Position.Y > -50 then
            local charDist = (myHRP.Position - enemyHRP.Position).Magnitude
            if charDist > Config.ESP.MaxDistance then continue end
            local vec, onScreen = Cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = math.sqrt((vec.X - mousePos.X) ^ 2 + (vec.Y - mousePos.Y) ^ 2)
                if dist < Config.Aimbot.FOV then
                    fovCount = fovCount + 1
                    table.insert(candidates, { player = p, fovDist = dist, charDist = charDist })
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.charDist < b.charDist end)
    for _, c in ipairs(candidates) do
        if isPlayerVisible(c.player, getAimPart(c.player)) then nearest = c.player; break end
    end
    STATE.TargetInFOV = nearest ~= nil
    if nearest then STATE.CurrentTarget = nearest; STATE.currentHitpart = "Head"; STATE.lastPartChange = 0 end
    return nearest, fovCount
end

local function humanizeTargetPosition(rawTargetPos)
    if not Config.Aimbot.HumanizeAimEnabled then return rawTargetPos end
    
    local intensity = Config.Aimbot.HumanizeIntensity * 0.5
    
    local randomOffset = Vector3.new(
        (math.random() - 0.5) * 2 * intensity,
        (math.random() - 0.5) * 2 * intensity * 0.7,
        (math.random() - 0.5) * 2 * intensity
    )
    
    local humanizedPos = rawTargetPos + randomOffset
    
    if math.random() < Config.Aimbot.HumanizeMicroCorrection then
        local correction = Vector3.new(0, (math.random() - 0.5) * intensity, 0)
        humanizedPos = humanizedPos + correction
    end
    
    return humanizedPos
end

local function startAimCurve(fromPos, toPos)
    if not Config.Aimbot.HumanizeAimEnabled or math.random() > Config.Aimbot.HumanizeCurveChance then
        STATE.isAimCurving = false
        return toPos
    end
    
    local distance = (toPos - fromPos).Magnitude
    local controlOffset = distance * 0.3 * (Config.Aimbot.HumanizeIntensity / 5)
    
    local midPoint = fromPos:Lerp(toPos, 0.5)
    local controlPoint = midPoint + Vector3.new(
        (math.random() - 0.5) * controlOffset,
        (math.random() - 0.5) * controlOffset * 0.5,
        (math.random() - 0.5) * controlOffset
    )
    
    STATE.isAimCurving = true
    STATE.aimCurveProgress = 0
    STATE.aimCurveStart = fromPos
    STATE.aimCurveControl = controlPoint
    STATE.aimCurveEnd = toPos
    
    return toPos
end

local function getCurvePoint()
    if not STATE.isAimCurving then return nil end
    
    STATE.aimCurveProgress = math.min(STATE.aimCurveProgress + 0.05, 1)
    
    local t = STATE.aimCurveProgress
    local u = 1 - t
    local point = (u * u * STATE.aimCurveStart) + (2 * u * t * STATE.aimCurveControl) + (t * t * STATE.aimCurveEnd)
    
    if t >= 1 then
        STATE.isAimCurving = false
    end
    
    return point
end

local function lookAt(targetPos)
    if not targetPos or targetPos == Vector3.zero then return end
    if targetPos.Y < -50 then return end
    local origin = Cam.CFrame.Position
    if (targetPos - origin).Magnitude < 0.1 then return end
    
    local humanizedTarget = humanizeTargetPosition(targetPos)
    
    if Config.Aimbot.SmoothnessEnabled then
        local curvePoint = getCurvePoint()
        local finalTarget = curvePoint or humanizedTarget
        
        if not curvePoint and STATE.isAimCurving == false and math.random() < 0.05 then
            startAimCurve(origin, humanizedTarget)
        end
        
        Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(origin, finalTarget), Config.Aimbot.Smoothness)
    else
        Cam.CFrame = CFrame.lookAt(origin, humanizedTarget)
    end
end

local function updateSpinbot()
    if not Config.Aimbot.SpinbotEnabled then return end
    if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0.5
        Cam.CameraType = Enum.CameraType.Custom
    end
    STATE.spinAngle = (STATE.spinAngle + Config.Aimbot.SpinSpeed) % 360
    if Config.Aimbot.SpinMode == "Camera" then
        Cam.CFrame = Cam.CFrame * CFrame.Angles(0, math.rad(Config.Aimbot.SpinSpeed), 0)
    else
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then myHRP.CFrame = myHRP.CFrame * CFrame.Angles(0, math.rad(Config.Aimbot.SpinSpeed), 0) end
    end
end

local function getBoundingBox2D(char)
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false, 0, 0, 0, 0 end
    local hrpPos = hrp.Position
    local top, onScreen1 = Cam:WorldToViewportPoint(hrpPos + Vector3.new(0, 3, 0))
    local bottom, onScreen2 = Cam:WorldToViewportPoint(hrpPos - Vector3.new(0, 3.5, 0))
    if onScreen1 or onScreen2 then
        local h = math.abs(top.Y - bottom.Y); local w = h * 0.55
        return true, top.X - (w / 2), top.X + (w / 2), top.Y, bottom.Y
    end
    return false, 0, 0, 0, 0
end

local function createESPEntity()
    local e = { Box = {}, Tracer = Drawing.new("Line"), Name = Drawing.new("Text"), HPBg = Drawing.new("Line"), HPFill = Drawing.new("Line"), Skeleton = {} }
    for i = 1, 4 do local l = Drawing.new("Line"); l.Visible = false; l.Thickness = Config.ESP.Thickness; e.Box[i] = l end
    for i = 1, 15 do local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1; l.Transparency = 1; table.insert(e.Skeleton, l) end
    e.Tracer.Visible = false; e.Tracer.Thickness = 1
    e.Name.Visible = false; e.Name.Size = 13; e.Name.Center = true; e.Name.Outline = true; e.Name.Font = 2
    e.HPBg.Visible = false; e.HPBg.Thickness = 2; e.HPFill.Visible = false; e.HPFill.Thickness = 2
    return e
end

local function getEffectiveColor(player)
    if STATE.IsTeamGame and player.Team then
        return player.Team.TeamColor.Color
    elseif not player.Team then
        return NO_TEAM_COLORS[Config.ESP.NoTeamColorPreset] or NO_TEAM_COLORS[1]
    else
        return Config.ESP.BoxColor
    end
end

local function createDistanceDisplay(player)
    if STATE.ESPStudsObjects[player] then return end
    local gui = Instance.new("BillboardGui"); gui.Name = "DistanceUI"; gui.Size = UDim2.new(0, 100, 0, 25)
    gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true
    local label = Instance.new("TextLabel", gui); label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1; label.Text = ""; label.Font = Enum.Font.GothamBlack; label.TextSize = 18
    label.TextStrokeTransparency = 0.3; label.TextStrokeColor3 = Color3.new(0, 0, 0)
    STATE.ESPStudsObjects[player] = { GUI = gui, Label = label }
    task.spawn(function()
        while player and player.Parent and STATE.ESPStudsObjects[player] do
            local char = player.Character; local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if head and hrp and myHRP and Config.ESP.DistanceEnabled and Config.ESP.Enabled then
                local distance = (myHRP.Position - hrp.Position).Magnitude
                local teamOk = true
                if STATE.IsTeamGame and Config.ESP.AutoTeamDetect and player.Team == LocalPlayer.Team and not Config.ESP.ForceShowAll then teamOk = false end
                if distance <= Config.ESP.MaxDistance and teamOk then
                    local _, onScreen = Cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        label.Text = math.floor(distance) .. " studs"; label.TextColor3 = getEffectiveColor(player)
                        gui.Adornee = head; gui.Parent = CoreGui; gui.Enabled = true
                    else gui.Enabled = false end
                else gui.Enabled = false end
            else gui.Enabled = false end
            task.wait(0.1)
        end
        if gui then gui:Destroy() end
        STATE.ESPStudsObjects[player] = nil
    end)
end

local function restoreHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            local hb = char:FindFirstChild("HeadHB")
            if hb then local orig = hb:FindFirstChild("RapzX_OrigSize"); if orig then hb.Size = orig.Value; orig:Destroy() end; hb.Transparency = 0; hb.CanCollide = true end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local origSize = hrp:FindFirstChild("RapzX_OrigHRPSize"); if origSize then hrp.Size = origSize.Value; origSize:Destroy() end
                local origTrans = hrp:FindFirstChild("RapzX_OrigHRPTrans"); if origTrans then hrp.Transparency = origTrans.Value; origTrans:Destroy() end
                hrp.CanCollide = true
            end
        end
    end
end

local function updateBigHead()
    if not Config.Aimbot.BigHeadEnabled then return end
    for _, v in ipairs(STATE.PlayerCache) do
        if v ~= LocalPlayer and v.Character then
            local headHB = v.Character:FindFirstChild("HeadHB")
            if headHB and headHB:IsA("BasePart") then
                if not headHB:FindFirstChild("RapzX_OrigSize") then
                    local origValue = Instance.new("Vector3Value", headHB)
                    origValue.Name = "RapzX_OrigSize"
                    origValue.Value = headHB.Size
                end
                headHB.CanCollide = false
                headHB.Transparency = 1
                headHB.Size = Vector3.new(Config.Aimbot.BigHeadSize, Config.Aimbot.BigHeadSize, Config.Aimbot.BigHeadSize)
            end
        end
    end
end

local function updateESP()
    for _, e in pairs(STATE.ESPActive) do e.assigned = false end
    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local visibleData = {}
    for _, p in ipairs(STATE.PlayerCache) do
        if not Config.ESP.Enabled or (STATE.IsTeamGame and Config.ESP.AutoTeamDetect and p.Team == LocalPlayer.Team and not Config.ESP.ForceShowAll) then continue end
        if isWhitelisted(p) then continue end
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (myHRP.Position - hrp.Position).Magnitude <= Config.ESP.MaxDistance then
            local onScreen, lx, rx, minY, maxY = getBoundingBox2D(p.Character)
            if onScreen then table.insert(visibleData, { player = p, lx = lx, rx = rx, cy = minY, by = maxY, hrpPos = hrp.Position }) end
        end
    end
    while #visibleData > STATE.MaxESPEntities do table.remove(visibleData, #visibleData) end
    for i, data in ipairs(visibleData) do
        local p = data.player; local entity = STATE.ESPPool[i] or createESPEntity()
        STATE.ESPPool[i] = entity; STATE.ESPActive[p] = entity; entity.assigned = true
        if entity.player ~= p then entity.player = p; entity.Name.Text = p.Name end
        local char = p.Character; local hum = char:FindFirstChildOfClass("Humanoid")
        local lx, rx, cy, by = data.lx, data.rx, data.cy, data.by; local h = math.abs(by - cy); local cx = (lx + rx) / 2
        local bc = getEffectiveColor(p)
        if Config.ESP.BoxEnabled then
            entity.Box[1].From, entity.Box[1].To = Vector2.new(lx, cy), Vector2.new(rx, cy)
            entity.Box[2].From, entity.Box[2].To = Vector2.new(lx, by), Vector2.new(rx, by)
            entity.Box[3].From, entity.Box[3].To = Vector2.new(lx, cy), Vector2.new(lx, by)
            entity.Box[4].From, entity.Box[4].To = Vector2.new(rx, cy), Vector2.new(rx, by)
            for _, l in ipairs(entity.Box) do l.Visible = true; l.Color = bc; l.Transparency = 1 - Config.ESP.Transparency end
        else for _, l in ipairs(entity.Box) do l.Visible = false end end
        if Config.ESP.SkeletonEnabled then
            local boneStructure = char:FindFirstChild("UpperTorso") ~= nil and R15Bones or R6Bones; local skeletonIdx = 1
            for _, pair in ipairs(boneStructure) do
                local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                if p1 and p2 then
                    local v1, onScreen1 = Cam:WorldToViewportPoint(p1.Position); local v2, onScreen2 = Cam:WorldToViewportPoint(p2.Position)
                    local line = entity.Skeleton[skeletonIdx]
                    if onScreen1 and onScreen2 and line then
                        line.From = Vector2.new(v1.X, v1.Y); line.To = Vector2.new(v2.X, v2.Y); line.Color = bc; line.Visible = true; skeletonIdx = skeletonIdx + 1
                    end
                end
            end
            for j = skeletonIdx, #entity.Skeleton do entity.Skeleton[j].Visible = false end
        else for _, l in ipairs(entity.Skeleton) do l.Visible = false end end
        if Config.ESP.TracerEnabled then entity.Tracer.From = Cam.ViewportSize / 2; entity.Tracer.To = Vector2.new(cx, by); entity.Tracer.Visible = true; entity.Tracer.Color = bc; entity.Tracer.Transparency = 1 - Config.ESP.Transparency else entity.Tracer.Visible = false end
        if Config.ESP.NameEnabled then entity.Name.Position = Vector2.new(cx, cy - 14); entity.Name.Visible = true; entity.Name.Color = Config.ESP.NameColor else entity.Name.Visible = false end
        if hum and Config.ESP.HealthBarEnabled then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1); local bx = lx - 5
            entity.HPBg.From = Vector2.new(bx, cy); entity.HPBg.To = Vector2.new(bx, by); entity.HPBg.Visible = true; entity.HPBg.Color = Color3.fromRGB(20, 20, 20)
            entity.HPFill.From = Vector2.new(bx, by - (h * pct)); entity.HPFill.To = Vector2.new(bx, by); entity.HPFill.Visible = true
            entity.HPFill.Color = pct > 0.6 and Color3.fromRGB(0, 255, 100) or (pct > 0.3 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50))
        else entity.HPBg.Visible = false; entity.HPFill.Visible = false end
    end
    for i = #visibleData + 1, #STATE.ESPPool do
        local e = STATE.ESPPool[i]; if e then for _, l in ipairs(e.Box) do l.Visible = false end; for _, l in ipairs(e.Skeleton) do l.Visible = false end; e.Tracer.Visible = false; e.Name.Visible = false; e.HPBg.Visible = false; e.HPFill.Visible = false end
    end
end

local function updateCyberVision()
    if not Config.CyberVision.Enabled then
        for _, entry in pairs(STATE.CyberVisionPool) do
            if entry.line then entry.line.Visible = false end
            if entry.dot then entry.dot.Visible = false end
        end
        return
    end
    local myChar = LocalPlayer.Character; local myHead = myChar and myChar:FindFirstChild("Head")
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local activeCount = 0; local maxRender = Config.CyberVision.MaxRender
    for _, player in ipairs(STATE.PlayerCache) do
        if activeCount >= maxRender then break end
        if Config.CyberVision.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if isWhitelisted(player) then continue end
        local char = player.Character; if not char then continue end
        local head = char:FindFirstChild("Head"); local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hrp or not hum or hum.Health <= 0 then continue end
        local distToMe = myHRP and (myHRP.Position - hrp.Position).Magnitude or 9999
        if distToMe > Config.ESP.MaxDistance then continue end
        local headPos, onScreen = Cam:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        if headPos.Z < 0 then continue end
        activeCount = activeCount + 1
        if not STATE.CyberVisionPool[activeCount] then
            local newEntry = {}
            newEntry.line = Drawing.new("Line"); newEntry.line.Thickness = Config.CyberVision.LineThickness; newEntry.line.Transparency = 1 - Config.CyberVision.Transparency
            newEntry.dot = Drawing.new("Circle"); newEntry.dot.Radius = 3; newEntry.dot.Filled = true; newEntry.dot.Transparency = 1 - Config.CyberVision.Transparency; newEntry.dot.Thickness = 0
            STATE.CyberVisionPool[activeCount] = newEntry
        end
        local entry = STATE.CyberVisionPool[activeCount]; local lookDir = hrp.CFrame.LookVector
        local lineStart = head.Position + Vector3.new(0, 0.3, 0); local lineEnd = lineStart + (lookDir * Config.CyberVision.LookLineLength)
        local startVec, startOnScreen = Cam:WorldToViewportPoint(lineStart); local endVec, endOnScreen = Cam:WorldToViewportPoint(lineEnd)
        if startOnScreen and endOnScreen then
            entry.line.From = Vector2.new(startVec.X, startVec.Y); entry.line.To = Vector2.new(endVec.X, endVec.Y)
            entry.dot.Position = Vector2.new(endVec.X, endVec.Y)
            local isLookingAtMe = false
            if Config.CyberVision.WarnIfLookingAtMe and myHead and distToMe < 80 then
                local toMe = (myHead.Position - lineStart).Unit; local dotProduct = lookDir:Dot(toMe)
                if dotProduct > Config.CyberVision.LookingAtMeThreshold then isLookingAtMe = true end
            end
            local lineColor = isLookingAtMe and Config.CyberVision.WarningColor or Config.CyberVision.NormalColor
            entry.line.Color = lineColor; entry.dot.Color = lineColor
            entry.line.Visible = true; entry.dot.Visible = true
        else entry.line.Visible = false; entry.dot.Visible = false end
    end
    for i = activeCount + 1, #STATE.CyberVisionPool do
        if STATE.CyberVisionPool[i] then
            if STATE.CyberVisionPool[i].line then STATE.CyberVisionPool[i].line.Visible = false end
            if STATE.CyberVisionPool[i].dot then STATE.CyberVisionPool[i].dot.Visible = false end
        end
    end
end

local function mouse1press() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) end) end
local function mouse1release() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end) end
local function mouse2press() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0) end) end
local function mouse2release() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0) end) end

local function teleportToClosest()
    local char = LocalPlayer.Character; local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local closestPlayer = nil; local minDist = math.huge
    for _, p in ipairs(STATE.PlayerCache) do
        if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
        if isWhitelisted(p) then continue end
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local d = (myHRP.Position - hrp.Position).Magnitude; if d < minDist then minDist = d; closestPlayer = p end end
    end
    if not closestPlayer then return end
    local target = closestPlayer; local savedPosition = myHRP.CFrame
    local hitButton = Config.Misc.TeleportHitButton
    while target and isPlayerAlive(target) do
        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then break end
        local behindCFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
        myHRP.CFrame = behindCFrame
        Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, targetHRP.Position)
        if hitButton == "Left" then
            mouse1press(); task.wait(0.03); mouse1release()
        elseif hitButton == "Right" then
            mouse2press(); task.wait(0.03); mouse2release()
        end
        task.wait(0.03)
    end
    if myHRP and myHRP.Parent then myHRP.CFrame = savedPosition end
end

local function cacheRGBWeapons()
    table.clear(STATE.RGBWeaponParts)
    local wf = game.ReplicatedStorage:FindFirstChild("Weapons")
    if wf then for _, part in ipairs(wf:GetDescendants()) do if part:IsA("BasePart") then table.insert(STATE.RGBWeaponParts, part) end end end
end

local function applyRGBWeapon()
    if not Config.Misc.RGBWeapon or tick() < STATE.NextRGBUpdate then return end
    STATE.NextRGBUpdate = tick() + 0.1; STATE.RGBHue = (STATE.RGBHue + 0.02) % 1
    local color = Color3.fromHSV(STATE.RGBHue, 1, 1)
    for _, part in ipairs(STATE.RGBWeaponParts) do if part and part.Parent then part.Color = color; part.Material = Enum.Material.Neon end end
end

local function updateAutoBhop()
    if not Config.Movement.AutoBhop then return end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and UserInputService:IsKeyDown(Enum.KeyCode.Space) and humanoid.FloorMaterial ~= Enum.Material.Air then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end

local function updateAntiAim()
    local char = LocalPlayer.Character; local rootJoint = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint")
    if not rootJoint or not rootJoint:IsA("Motor6D") then return end
    if not Config.Movement.AntiAim then if STATE.originalRootJointC0 then rootJoint.C0 = STATE.originalRootJointC0; STATE.originalRootJointC0 = nil end return end
    if not STATE.originalRootJointC0 then STATE.originalRootJointC0 = rootJoint.C0 end
    local jitterAngle = (math.floor(os.clock() * 35) % 2 == 0) and Config.Movement.AntiAimAngle or -Config.Movement.AntiAimAngle
    rootJoint.C0 = STATE.originalRootJointC0 * CFrame.Angles(0, math.rad(jitterAngle), 0)
end

local function updateAutoStrafe()
    if not Config.Movement.AutoStrafe then return end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp and humanoid.FloorMaterial == Enum.Material.Air then
        local mouseDelta = UserInputService:GetMouseDelta()
        if math.abs(mouseDelta.X) > 2 then
            local boostPower = math.min(math.abs(mouseDelta.X) * Config.Movement.StrafeSpeed * 0.003, 15)
            local boost = Cam.CFrame.RightVector * (mouseDelta.X > 0 and boostPower or -boostPower)
            if math.random() < 0.7 then
                hrp.Velocity = Vector3.new(
                    hrp.Velocity.X + boost.X * 0.5,
                    hrp.Velocity.Y,
                    hrp.Velocity.Z + boost.Z * 0.5
                )
            end
            local maxSpeed = 80
            local horizontalSpeed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
            if horizontalSpeed > maxSpeed then
                local scale = maxSpeed / horizontalSpeed
                hrp.Velocity = Vector3.new(hrp.Velocity.X * scale, hrp.Velocity.Y, hrp.Velocity.Z * scale)
            end
        end
    end
end

local function applyWalkSpeedAndJump()
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if Config.Movement.WalkSpeedEnabled then hum.WalkSpeed = Config.Movement.WalkSpeedValue end
    if Config.Movement.JumpPowerEnabled then hum.JumpPower = Config.Movement.JumpPowerValue end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if Config.Movement.WalkSpeedEnabled then hum.WalkSpeed = Config.Movement.WalkSpeedValue end
    if Config.Movement.JumpPowerEnabled then hum.JumpPower = Config.Movement.JumpPowerValue end
end)

local function handleRespawn()
    for _, gui in ipairs({ LocalPlayer:FindFirstChild("PlayerGui"), CoreGui }) do
        if gui then for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Name:lower():find("respawn") then
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2, obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2 + 36, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2, obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2 + 36, 0, false, game, 0)
                end)
                return
            end
        end end
    end
end

local function getNearestEnemy()
    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local nearest, minDist = nil, math.huge
    for _, p in ipairs(STATE.PlayerCache) do
        if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
        if isWhitelisted(p) then continue end
        if not isPlayerAlive(p) then continue end
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local d = (myHRP.Position - hrp.Position).Magnitude; if d < minDist and isPlayerVisible(p, getAimPart(p)) then minDist = d; nearest = p end end
    end
    return nearest
end

local function moveToPosition(pos)
    local char = LocalPlayer.Character; local humanoid = char and char:FindFirstChildOfClass("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentMaxSlope = 45 })
    local success = pcall(function() path:ComputeAsync(hrp.Position, pos) end)
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not Config.AutoPlay.Enabled then return end
            local currentEnemy = getNearestEnemy()
            if currentEnemy and (hrp.Position - currentEnemy.Character.HumanoidRootPart.Position).Magnitude <= Config.AutoPlay.EngageDistance then humanoid:Move(Vector3.zero); break end
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(waypoint.Position); local timeout = tick()
            while (hrp.Position - waypoint.Position).Magnitude > 3 do
                if tick() - timeout > 1.5 or not Config.AutoPlay.Enabled or not isPlayerAlive(LocalPlayer) then break end
                local currentEnemy = getNearestEnemy()
                if currentEnemy and (hrp.Position - currentEnemy.Character.HumanoidRootPart.Position).Magnitude <= Config.AutoPlay.EngageDistance then humanoid:Move(Vector3.zero); break end
                task.wait(0.05)
            end
        end
    end
end

local function humanLookAround()
    if not Config.AutoPlay.LookAround then return end
    if tick() - STATE.lastLookAround < 1.5 + math.random() * 2 then return end
    STATE.lastLookAround = tick(); STATE.lookAroundAngle = (math.random() - 0.5) * 60
    local origin = Cam.CFrame.Position; local targetLook = origin + (CFrame.Angles(0, math.rad(STATE.lookAroundAngle), 0) * Cam.CFrame.LookVector) * 50
    lookAt(targetLook)
end

local function humanMicroPause()
    if not Config.AutoPlay.MicroPause then return false end
    if tick() - STATE.lastMicroPause < 3 + math.random() * 5 then return false end
    STATE.lastMicroPause = tick(); return true
end

local function humanRandomJump(humanoid)
    if not Config.AutoPlay.RandomJumps then return end
    if tick() - STATE.lastRandomJump < 2 + math.random() * 4 then return end
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then STATE.lastRandomJump = tick(); humanoid.Jump = true end
end

local function autoPlayLoop()
    while Config.AutoPlay.Enabled do
        local char = LocalPlayer.Character; local humanoid = char and char:FindFirstChildOfClass("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then if Config.AutoPlay.AutoRespawn then handleRespawn() end; STATE.roamingTarget = nil; task.wait(0.5); continue end
        local enemy = getNearestEnemy(); local enemyDist = enemy and (hrp.Position - enemy.Character.HumanoidRootPart.Position).Magnitude or 9999
        if Config.AutoPlay.HumanMode then humanLookAround() end
        if Config.AutoPlay.HumanMode then humanRandomJump(humanoid) end
        if enemy and enemyDist <= Config.AutoPlay.EngageDistance then STATE.currentAutoState = ((humanoid.Health / humanoid.MaxHealth * 100) < Config.AutoPlay.HPThreshold) and "Defensive" or "Combat"
        else STATE.currentAutoState = "Roaming" end
        if Config.AutoPlay.HumanMode and humanMicroPause() then humanoid:Move(Vector3.zero); task.wait(0.1 + math.random() * 0.3) end
        if STATE.currentAutoState == "Combat" then
            STATE.AutoTarget = enemy; local enemyHRP = enemy.Character.HumanoidRootPart
            if tick() > STATE.nextStrafeChange then
                STATE.nextStrafeChange = tick() + 0.3 + math.random() * 0.6; STATE.strafePhase = (STATE.strafePhase + 1) % 8
                local dirs = { Cam.CFrame.RightVector, (Cam.CFrame.RightVector + Cam.CFrame.LookVector).Unit, Cam.CFrame.LookVector, (-Cam.CFrame.RightVector + Cam.CFrame.LookVector).Unit, -Cam.CFrame.RightVector, (-Cam.CFrame.RightVector - Cam.CFrame.LookVector).Unit, -Cam.CFrame.LookVector, (Cam.CFrame.RightVector - Cam.CFrame.LookVector).Unit }
                STATE.currentStrafeDir = dirs[STATE.strafePhase + 1] or Cam.CFrame.RightVector
            end
            local strafeTarget = hrp.Position + STATE.currentStrafeDir * Config.AutoPlay.CombatStrafeSpeed * 0.5; local distToEnemy = (hrp.Position - enemyHRP.Position).Magnitude
            if distToEnemy > 30 then humanoid:MoveTo(enemyHRP.Position + (hrp.Position - enemyHRP.Position).Unit * 15)
            elseif distToEnemy < 10 then humanoid:MoveTo(hrp.Position - (enemyHRP.Position - hrp.Position).Unit * 20)
            else humanoid:MoveTo(strafeTarget) end
            if Config.AutoPlay.HumanMode and Config.AutoPlay.JiggleAim and STATE.AutoTarget then
                local part = STATE.AutoTarget.Character:FindFirstChild(getAimPart(STATE.AutoTarget))
                if part and part.Position.Y > -50 then local jigglePos = part.Position + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.5; lookAt(jigglePos) end
            end
            STATE.lastCombatAction = tick(); task.wait(0.08)
        elseif STATE.currentAutoState == "Defensive" then
            STATE.AutoTarget = enemy; local enemyHRP = enemy.Character.HumanoidRootPart; local retreatDir = (hrp.Position - enemyHRP.Position).Unit
            humanoid:MoveTo(hrp.Position + retreatDir * 40)
            if Config.AutoPlay.HumanMode and tick() % 1.5 < 0.3 then local quickLook = enemyHRP.Position; lookAt(quickLook) end
            task.wait(0.1)
        elseif STATE.currentAutoState == "Roaming" then
            STATE.AutoTarget = nil
            if not enemy or enemyDist > Config.AutoPlay.EngageDistance then
                if not STATE.roamingTarget or (STATE.roamingTarget - hrp.Position).Magnitude < 15 then
                    local randomAngle = math.random() * math.pi * 2; local randomDist = 80 + math.random() * 120
                    STATE.roamingTarget = hrp.Position + Vector3.new(math.cos(randomAngle) * randomDist, 0, math.sin(randomAngle) * randomDist)
                end
                moveToPosition(STATE.roamingTarget)
            end
            if Config.AutoPlay.HumanMode and math.random() < 0.3 then humanoid:Move(Vector3.zero); task.wait(0.2 + math.random() * 0.5) end
            task.wait(0.15)
        end
    end
end

local function startAutoPlay() if not STATE.AutoPlayThread then STATE.AutoPlayThread = task.spawn(autoPlayLoop) end end
local function stopAutoPlay()
    if STATE.AutoPlayThread then task.cancel(STATE.AutoPlayThread); STATE.AutoPlayThread = nil end
    STATE.AutoTarget = nil; STATE.currentAutoState = "Roaming"; STATE.roamingTarget = nil
    pcall(function() local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h:Move(Vector3.zero) end end)
end

local function autoGoldenKnifeLoop()
    while Config.Misc.AutoGoldenKnife do
        if Config.AutoPlay.Enabled then task.wait(0.3); continue end
        local enemy = getNearestEnemy()
        if enemy and isPlayerAlive(enemy) then
            local enemyHRP = enemy.Character:FindFirstChild("HumanoidRootPart"); local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemyHRP and myHRP then
                myHRP.CFrame = enemyHRP.CFrame * CFrame.new(0, 0, -2); local start = tick()
                while Config.Misc.AutoGoldenKnife and enemy and isPlayerAlive(enemy) and enemy.Parent and tick() - start < 5 do mouse1press(); task.wait(0.05); mouse1release(); task.wait(0.05) end
            end
        end
        task.wait(0.1)
    end
end

local function startAutoGoldenKnife() if not STATE.AutoGoldenKnifeThread then STATE.AutoGoldenKnifeThread = task.spawn(autoGoldenKnifeLoop) end end
local function stopAutoGoldenKnife() if STATE.AutoGoldenKnifeThread then task.cancel(STATE.AutoGoldenKnifeThread); STATE.AutoGoldenKnifeThread = nil end end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false; FOVCircle.Thickness = 2; FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Filled = false; FOVCircle.Transparency = 0.8; FOVCircle.Radius = Config.Aimbot.FOV

local function initCrosshair()
    STATE.CrosshairLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = Config.Crosshair.Thickness
        line.Color = CROSSHAIR_COLORS[Config.Crosshair.ColorPreset]
        line.Transparency = 1 - Config.Crosshair.Transparency
        table.insert(STATE.CrosshairLines, line)
    end
    STATE.CrosshairCircle = Drawing.new("Circle")
    STATE.CrosshairCircle.Visible = false
    STATE.CrosshairCircle.Thickness = Config.Crosshair.Thickness
    STATE.CrosshairCircle.Color = CROSSHAIR_COLORS[Config.Crosshair.ColorPreset]
    STATE.CrosshairCircle.Transparency = 1 - Config.Crosshair.Transparency
    STATE.CrosshairCircle.Filled = false
end

local function updateCrosshair()
    if not Config.Crosshair.Enabled then
        for _, line in ipairs(STATE.CrosshairLines) do line.Visible = false end
        STATE.CrosshairCircle.Visible = false
        return
    end
    local center = Cam.ViewportSize / 2
    local size = Config.Crosshair.Size
    local thick = Config.Crosshair.Thickness
    local color = CROSSHAIR_COLORS[Config.Crosshair.ColorPreset]
    local trans = 1 - Config.Crosshair.Transparency
    local style = Config.Crosshair.Style

    if style == "Cross" then
        STATE.CrosshairCircle.Visible = false
        STATE.CrosshairLines[1].From = Vector2.new(center.X - size, center.Y)
        STATE.CrosshairLines[1].To = Vector2.new(center.X + size, center.Y)
        STATE.CrosshairLines[2].From = Vector2.new(center.X, center.Y - size)
        STATE.CrosshairLines[2].To = Vector2.new(center.X, center.Y + size)
        STATE.CrosshairLines[3].Visible = false
        STATE.CrosshairLines[4].Visible = false
        for i = 1, 2 do
            local line = STATE.CrosshairLines[i]
            line.Visible = true
            line.Color = color
            line.Thickness = thick
            line.Transparency = trans
        end
    elseif style == "Circle" then
        for _, line in ipairs(STATE.CrosshairLines) do line.Visible = false end
        STATE.CrosshairCircle.Visible = true
        STATE.CrosshairCircle.Position = center
        STATE.CrosshairCircle.Radius = size
        STATE.CrosshairCircle.Thickness = thick
        STATE.CrosshairCircle.Color = color
        STATE.CrosshairCircle.Transparency = trans
    elseif style == "Dot" then
        STATE.CrosshairCircle.Visible = false
        STATE.CrosshairLines[1].From = Vector2.new(center.X - size, center.Y)
        STATE.CrosshairLines[1].To = Vector2.new(center.X + size, center.Y)
        STATE.CrosshairLines[2].From = Vector2.new(center.X, center.Y - size)
        STATE.CrosshairLines[2].To = Vector2.new(center.X, center.Y + size)
        STATE.CrosshairLines[3].Visible = false
        STATE.CrosshairLines[4].Visible = false
        for i = 1, 2 do
            local line = STATE.CrosshairLines[i]
            line.Visible = true
            line.Color = color
            line.Thickness = thick
            line.Transparency = trans
        end
    end
end

initCrosshair()

local AimbotStatusGui = Instance.new("ScreenGui")
AimbotStatusGui.Name = "AimbotStatusHUD"
AimbotStatusGui.ResetOnSpawn = false
AimbotStatusGui.Parent = CoreGui

local AimbotStatusFrame = Instance.new("Frame", AimbotStatusGui)
AimbotStatusFrame.Size = UDim2.new(0, 140, 0, 30)
AimbotStatusFrame.Position = UDim2.new(0, 12, 0.5, -15)
AimbotStatusFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
AimbotStatusFrame.BorderSizePixel = 0
Instance.new("UICorner", AimbotStatusFrame).CornerRadius = UDim.new(0, 7)

local AimbotStatusStroke = Instance.new("UIStroke", AimbotStatusFrame)
AimbotStatusStroke.Color = Color3.fromRGB(80, 255, 100)
AimbotStatusStroke.Thickness = 1.5

local AimbotStatusText = Instance.new("TextLabel", AimbotStatusFrame)
AimbotStatusText.Size = UDim2.new(1, 0, 1, 0)
AimbotStatusText.BackgroundTransparency = 1
AimbotStatusText.Text = "AIMBOT: ON"
AimbotStatusText.TextColor3 = Color3.fromRGB(80, 255, 100)
AimbotStatusText.Font = Enum.Font.GothamBlack
AimbotStatusText.TextSize = 13
AimbotStatusText.TextXAlignment = Enum.TextXAlignment.Center

local TargetPartIndicator = Instance.new("Frame", AimbotStatusGui)
TargetPartIndicator.Size = UDim2.new(0, 140, 0, 24)
TargetPartIndicator.Position = UDim2.new(0, 12, 0.5, 22)
TargetPartIndicator.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TargetPartIndicator.BorderSizePixel = 0
Instance.new("UICorner", TargetPartIndicator).CornerRadius = UDim.new(0, 7)

local TargetPartStroke = Instance.new("UIStroke", TargetPartIndicator)
TargetPartStroke.Color = Color3.fromRGB(200, 200, 200)
TargetPartStroke.Thickness = 1

local TargetPartText = Instance.new("TextLabel", TargetPartIndicator)
TargetPartText.Size = UDim2.new(1, 0, 1, 0)
TargetPartText.BackgroundTransparency = 1
TargetPartText.Text = "TARGET: Head"
TargetPartText.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPartText.Font = Enum.Font.GothamBold
TargetPartText.TextSize = 12
TargetPartText.TextXAlignment = Enum.TextXAlignment.Center

local function updateAimbotHUD()
    if Config.Aimbot.Enabled then
        AimbotStatusText.Text = "AIMBOT: ON"
        AimbotStatusText.TextColor3 = Color3.fromRGB(80, 255, 100)
        AimbotStatusStroke.Color = Color3.fromRGB(80, 255, 100)
    else
        AimbotStatusText.Text = "AIMBOT: OFF"
        AimbotStatusText.TextColor3 = Color3.fromRGB(255, 70, 70)
        AimbotStatusStroke.Color = Color3.fromRGB(255, 70, 70)
    end
end

local function updateTargetPartHUD()
    local myChar = LocalPlayer.Character
    if Config.Aimbot.AimMode == "Dynamic" then
        TargetPartText.Text = "TARGET: DYNAMIC"
        TargetPartText.TextColor3 = Color3.fromRGB(255, 200, 0)
        TargetPartStroke.Color = Color3.fromRGB(255, 200, 0)
        return
    end
    TargetPartText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetPartStroke.Color = Color3.fromRGB(200, 200, 200)
    local availableParts = getAvailableAimParts(myChar)
    local preset = Config.Aimbot.AimPartPreset
    local partName = availableParts[preset] or "Head"
    TargetPartText.Text = "TARGET: " .. partName
end

local function toggleAimbotHUD()
    STATE.ShowAimbotStatus = not STATE.ShowAimbotStatus
    AimbotStatusFrame.Visible = STATE.ShowAimbotStatus
    TargetPartIndicator.Visible = STATE.ShowAimbotStatus
end

local function cycleTargetPart()
    if Config.Aimbot.AimMode == "Dynamic" then
        kirimNotif("TARGET MODE", "Dynamic mode aktif - part dipilih otomatis")
        return
    end
    local myChar = LocalPlayer.Character
    local availableParts = getAvailableAimParts(myChar)
    local maxPreset = #availableParts
    Config.Aimbot.AimPartPreset = (Config.Aimbot.AimPartPreset % maxPreset) + 1
    Config.Aimbot.AimPart = availableParts[Config.Aimbot.AimPartPreset]
    updateTargetPartHUD()
    kirimNotif("TARGET PART", availableParts[Config.Aimbot.AimPartPreset] .. " (R" .. (isCharacterR15(myChar) and "15" or "6") .. ")")
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "RapzX_Minimalist"; MainGui.Parent = CoreGui

local MainContainer = Instance.new("Frame", MainGui)
MainContainer.Size = UDim2.new(0, 500, 0, 420); MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5); MainContainer.BackgroundColor3 = COLORS.Bg; MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true
local MainScale = Instance.new("UIScale", MainContainer)
Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MainContainer); Stroke.Color = COLORS.Accent; Stroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainContainer)
TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22); TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
local LogoImage = Instance.new("ImageLabel", TitleBar)
LogoImage.Size = UDim2.new(0, 28, 0, 28); LogoImage.Position = UDim2.new(0, 8, 0.5, -14); LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://9895184382"; LogoImage.ScaleType = Enum.ScaleType.Fit
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -60, 1, 0); TitleLabel.Position = UDim2.new(0, 44, 0, 0); TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LionelRappTezetyee | Pro Player v6.8"; TitleLabel.TextColor3 = COLORS.Accent; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainContainer)
Sidebar.Size = UDim2.new(0, 140, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40); Sidebar.BackgroundColor3 = COLORS.Sidebar; Sidebar.BorderSizePixel = 0
local SidebarList = Instance.new("UIListLayout", Sidebar); SidebarList.SortOrder = Enum.SortOrder.LayoutOrder; SidebarList.Padding = UDim.new(0, 5); SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidebarPad = Instance.new("UIPadding", Sidebar); SidebarPad.PaddingTop = UDim.new(0, 10)

local ContentArea = Instance.new("Frame", MainContainer)
ContentArea.Size = UDim2.new(1, -140, 1, -40); ContentArea.Position = UDim2.new(0, 140, 0, 40); ContentArea.BackgroundTransparency = 1

TitleBar.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then STATE.isDraggingMainGui = true; STATE.dragStartMouse = inp.Position; STATE.dragStartPos = MainContainer.Position end end)
UserInputService.InputChanged:Connect(function(inp) if STATE.isDraggingMainGui and inp.UserInputType == Enum.UserInputType.MouseMovement then local delta = inp.Position - STATE.dragStartMouse; MainContainer.Position = UDim2.new(STATE.dragStartPos.X.Scale, STATE.dragStartPos.X.Offset + delta.X, STATE.dragStartPos.Y.Scale, STATE.dragStartPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then STATE.isDraggingMainGui = false; STATE.isDraggingMobile = false end end)

local function ToggleGui()
    if STATE.AnimatingGui then return end
    STATE.AnimatingGui = true
    
    if STATE.GuiTween then STATE.GuiTween:Cancel() end
    
    if STATE.GuiVisible then
        if STATE.mouseLockConnection then
            STATE.mouseLockConnection:Disconnect()
            STATE.mouseLockConnection = nil
        end
        
        STATE.GuiTween = TweenService:Create(MainScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
        STATE.GuiTween:Play()
        STATE.GuiTween.Completed:Connect(function()
            MainContainer.Visible = false
            STATE.GuiVisible = false
            STATE.AnimatingGui = false
            STATE.GuiTween = nil
        end)
    else
        MainContainer.Visible = true
        STATE.GuiVisible = true
        
        if STATE.mouseLockConnection then STATE.mouseLockConnection:Disconnect() end
        STATE.mouseLockConnection = RunService.RenderStepped:Connect(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
        
        STATE.GuiTween = TweenService:Create(MainScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
        STATE.GuiTween:Play()
        STATE.GuiTween.Completed:Connect(function()
            STATE.AnimatingGui = false
            STATE.GuiTween = nil
        end)
    end
end

local MobileToggle = Instance.new("TextButton", MainGui)
MobileToggle.Size = UDim2.new(0, 55, 0, 55); MobileToggle.Position = UDim2.new(0, 20, 0.5, -27); MobileToggle.BackgroundColor3 = COLORS.Accent
MobileToggle.Text = "MENU"; MobileToggle.TextColor3 = Color3.new(1, 1, 1); MobileToggle.Font = Enum.Font.GothamBlack; MobileToggle.TextSize = 12
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(0, 14)
local MTStroke = Instance.new("UIStroke", MobileToggle); MTStroke.Color = Color3.new(1, 1, 1); MTStroke.Thickness = 1.5
MobileToggle.Visible = UserInputService.TouchEnabled

MobileToggle.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then STATE.isDraggingMobile = true; STATE.mtDragStartMouse = inp.Position; STATE.mtDragStartPos = MobileToggle.Position end end)
UserInputService.InputChanged:Connect(function(inp) if STATE.isDraggingMobile and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local delta = inp.Position - STATE.mtDragStartMouse; MobileToggle.Position = UDim2.new(STATE.mtDragStartPos.X.Scale, STATE.mtDragStartPos.X.Offset + delta.X, STATE.mtDragStartPos.Y.Scale, STATE.mtDragStartPos.Y.Offset + delta.Y) end end)
MobileToggle.MouseButton1Click:Connect(ToggleGui)

local function isTriggerKeyPressed(inp)
    if not Config.Aimbot.TriggerMode then return false end
    local trigger = Config.Aimbot.TriggerKey
    if trigger == Enum.KeyCode.Unknown then return inp.UserInputType == Enum.UserInputType.MouseButton1 end
    if tostring(trigger):find("KeyCode") then return inp.KeyCode == trigger end
    if tostring(trigger):find("UserInputType") then return inp.UserInputType == trigger end
    return false
end

STATE.InputBeganConnection = UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == Config.Misc.GuiKey then ToggleGui() end
    if inp.KeyCode == Config.Misc.TeleportKey then teleportToClosest() end
    if inp.KeyCode == Config.Aimbot.TargetPartKeybind then cycleTargetPart() end
    if inp.KeyCode == Enum.KeyCode.T then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        updateAimbotHUD()
        kirimNotif("AIMBOT STATUS", Config.Aimbot.Enabled and "AKTIF (ON)" or "MATI (OFF)")
    end
    if inp.KeyCode == Enum.KeyCode.Y then toggleAimbotHUD() end
    if isTriggerKeyPressed(inp) then STATE.LeftClickHeld = true; STATE.LockedTarget = getClosestInFOV() end
end)

STATE.InputEndedConnection = UserInputService.InputEnded:Connect(function(inp)
    local trigger = Config.Aimbot.TriggerKey; local triggered = false
    if trigger == Enum.KeyCode.Unknown then if inp.UserInputType == Enum.UserInputType.MouseButton1 then triggered = true end
    elseif tostring(trigger):find("KeyCode") and inp.KeyCode == trigger then triggered = true
    elseif tostring(trigger):find("UserInputType") and inp.UserInputType == trigger then triggered = true end
    if triggered then STATE.LeftClickHeld = false; STATE.LockedTarget = nil end
end)

local ContentPages, TabButtons = {}, {}

local function SwitchTab(name)
    for n, page in pairs(ContentPages) do page.Visible = (n == name) end
    for n, btn in pairs(TabButtons) do
        if n == name then btn.BackgroundColor3 = COLORS.Accent; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.TextColor3 = Color3.fromRGB(170, 175, 190) end
    end
end

local function CreateTab(name)
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, -20, 1, -20); page.Position = UDim2.new(0, 10, 0, 10); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = COLORS.Accent; page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0, 0, 0, 0); page.Visible = false
    Instance.new("UIListLayout", page).SortOrder = Enum.SortOrder.LayoutOrder
    ContentPages[name] = page
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -16, 0, 36); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = name; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = btn
    return page
end

local function AddToggle(page, text, default, callback, configPath)
    local holder = Instance.new("Frame", page)
    holder.Size = UDim2.new(1, 0, 0, 36); holder.BackgroundColor3 = COLORS.Card; holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    local lab = Instance.new("TextLabel", holder)
    lab.Size = UDim2.new(0.6, 0, 1, 0); lab.Position = UDim2.new(0, 12, 0, 0); lab.BackgroundTransparency = 1; lab.Text = text; lab.TextColor3 = COLORS.Text; lab.Font = Enum.Font.GothamBold; lab.TextSize = 13; lab.TextXAlignment = Enum.TextXAlignment.Left
    local switchBg = Instance.new("Frame", holder)
    switchBg.Size = UDim2.new(0, 40, 0, 20); switchBg.Position = UDim2.new(1, -52, 0.5, -10); switchBg.BackgroundColor3 = default and COLORS.Accent or Color3.fromRGB(50, 50, 60); switchBg.BorderSizePixel = 0
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local switchKnob = Instance.new("Frame", switchBg)
    switchKnob.Size = UDim2.new(0, 14, 0, 14); switchKnob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); switchKnob.BackgroundColor3 = Color3.new(1, 1, 1); switchKnob.BorderSizePixel = 0
    Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)
    local state = default
    holder.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then state = not state; switchBg.BackgroundColor3 = state and COLORS.Accent or Color3.fromRGB(50, 50, 60); switchKnob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); callback(state) end end)
    if configPath then table.insert(STATE.UIRegistry, { type = "toggle", configPath = configPath, update = function(val) state = val; switchBg.BackgroundColor3 = val and COLORS.Accent or Color3.fromRGB(50, 50, 60); switchKnob.Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) end }) end
end

local function AddSlider(page, text, minVal, maxVal, default, decimals, callback, configPath)
    local holder = Instance.new("Frame", page)
    holder.Size = UDim2.new(1, 0, 0, 50); holder.BackgroundColor3 = COLORS.Card; holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    local lab = Instance.new("TextLabel", holder)
    lab.Size = UDim2.new(1, -24, 0, 20); lab.Position = UDim2.new(0, 12, 0, 4); lab.BackgroundTransparency = 1; lab.Text = text .. ": " .. default; lab.TextColor3 = COLORS.Text; lab.Font = Enum.Font.GothamBold; lab.TextSize = 13; lab.TextXAlignment = Enum.TextXAlignment.Left
    local sliderBg = Instance.new("Frame", holder)
    sliderBg.Size = UDim2.new(1, -24, 0, 4); sliderBg.Position = UDim2.new(0, 12, 0, 32); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65); sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0); fill.BackgroundColor3 = COLORS.Accent; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", sliderBg)
    knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -6, 0.5, -6); knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local val, drag = default, false
    knob.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            val = minVal + (maxVal - minVal) * rel; if decimals == 0 then val = math.floor(val) else val = math.floor(val * 10 + 0.5) / 10 end
            fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -6, 0.5, -6); lab.Text = text .. ": " .. val; callback(val)
        end
    end)
    if configPath then table.insert(STATE.UIRegistry, { type = "slider", configPath = configPath, min = minVal, max = maxVal, decimals = decimals, update = function(newVal) val = newVal; local rel = (newVal - minVal) / (maxVal - minVal); fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -6, 0.5, -6); lab.Text = text .. ": " .. newVal end }) end
end

local function AddKeybind(page, text, default, callback)
    local holder = Instance.new("Frame", page)
    holder.Size = UDim2.new(1, 0, 0, 36); holder.BackgroundColor3 = COLORS.Card; holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    local lab = Instance.new("TextLabel", holder)
    lab.Size = UDim2.new(0.6, 0, 1, 0); lab.Position = UDim2.new(0, 12, 0, 0); lab.BackgroundTransparency = 1; lab.Text = text; lab.TextColor3 = COLORS.Text; lab.Font = Enum.Font.GothamBold; lab.TextSize = 13; lab.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.new(0, 100, 0, 26); btn.Position = UDim2.new(1, -112, 0.5, -13); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = (default == Enum.KeyCode.Unknown and "LClick" or default.Name); btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local listen = false; btn.MouseButton1Click:Connect(function() listen = true; btn.Text = "..." end)
    UserInputService.InputBegan:Connect(function(inp)
        if listen then
            if inp.UserInputType == Enum.UserInputType.Keyboard then listen = false; btn.Text = inp.KeyCode.Name; callback(inp.KeyCode)
            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then listen = false; btn.Text = "LClick"; callback(Enum.KeyCode.Unknown)
            elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then listen = false; btn.Text = "RClick"; callback(Enum.UserInputType.MouseButton2)
            elseif inp.UserInputType == Enum.UserInputType.MouseButton3 then listen = false; btn.Text = "MClick"; callback(Enum.UserInputType.MouseButton3) end
        end
    end)
end

local function AddButton(page, text, callback)
    local holder = Instance.new("Frame", page)
    holder.Size = UDim2.new(1, 0, 0, 40); holder.BackgroundColor3 = COLORS.Card; holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.new(1, -24, 0, 30); btn.Position = UDim2.new(0, 12, 0, 5); btn.Text = text; btn.BackgroundColor3 = COLORS.Accent; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); btn.MouseButton1Click:Connect(callback)
end

local function setAntiLag(enabled)
    if enabled then
        Config.ESP.Enabled = false
        Config.ESP.ChamsEnabled = false
        Config.CyberVision.Enabled = false
        Config.Aimbot.ShowFOV = false
        Config.Aimbot.SpinbotEnabled = false
        Config.Misc.RGBWeapon = false
        Config.ESP.MaxDistance = 100
        STATE.MaxESPEntities = 5
    end
end

local PopupFrame = Instance.new("Frame", MainGui)
PopupFrame.Size = UDim2.new(0, 300, 0, 260); PopupFrame.Position = UDim2.new(0.5, 0, 0.5, 0); PopupFrame.AnchorPoint = Vector2.new(0.5, 0.5); PopupFrame.BackgroundColor3 = COLORS.Bg; PopupFrame.BorderSizePixel = 0; PopupFrame.Visible = false; PopupFrame.ZIndex = 10; PopupFrame.ClipsDescendants = true
Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 10)
local PopStroke = Instance.new("UIStroke", PopupFrame); PopStroke.Color = COLORS.Accent; PopStroke.Thickness = 1.5
local PopTitle = Instance.new("TextLabel", PopupFrame)
PopTitle.Size = UDim2.new(1, -40, 0, 35); PopTitle.Position = UDim2.new(0, 12, 0, 0); PopTitle.BackgroundTransparency = 1; PopTitle.Text = "Persentase Prioritas Hitpart"; PopTitle.TextColor3 = COLORS.Accent; PopTitle.Font = Enum.Font.GothamBold; PopTitle.TextSize = 14; PopTitle.TextXAlignment = Enum.TextXAlignment.Left; PopTitle.ZIndex = 11
local ClosePop = Instance.new("TextButton", PopupFrame)
ClosePop.Size = UDim2.new(0, 28, 0, 28); ClosePop.Position = UDim2.new(1, -34, 0, 6); ClosePop.BackgroundColor3 = Color3.fromRGB(40, 40, 50); ClosePop.Text = "X"; ClosePop.TextColor3 = Color3.fromRGB(255, 100, 100); ClosePop.Font = Enum.Font.GothamBlack; ClosePop.TextSize = 16; ClosePop.BorderSizePixel = 0; ClosePop.ZIndex = 11
Instance.new("UICorner", ClosePop).CornerRadius = UDim.new(0, 6); ClosePop.MouseButton1Click:Connect(function() PopupFrame.Visible = false end)
local PopScroll = Instance.new("ScrollingFrame", PopupFrame)
PopScroll.Size = UDim2.new(1, -20, 1, -50); PopScroll.Position = UDim2.new(0, 10, 0, 44); PopScroll.BackgroundTransparency = 1; PopScroll.ScrollBarThickness = 3; PopScroll.ScrollBarImageColor3 = COLORS.Accent; PopScroll.CanvasSize = UDim2.new(0, 0, 0, 220); PopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; PopScroll.ZIndex = 10
local PopList = Instance.new("UIListLayout", PopScroll); PopList.SortOrder = Enum.SortOrder.LayoutOrder; PopList.Padding = UDim.new(0, 8); PopList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function AddPopupSlider(text, key)
    local sHolder = Instance.new("Frame", PopScroll)
    sHolder.Size = UDim2.new(1, -10, 0, 55); sHolder.BackgroundColor3 = COLORS.Card; sHolder.BorderSizePixel = 0; sHolder.ZIndex = 10
    Instance.new("UICorner", sHolder).CornerRadius = UDim.new(0, 6)
    local sLab = Instance.new("TextLabel", sHolder)
    sLab.Size = UDim2.new(1, -20, 0, 22); sLab.Position = UDim2.new(0, 10, 0, 6); sLab.BackgroundTransparency = 1; sLab.Text = text .. ": " .. Config.Aimbot.HitpartWeights[key] .. "%"; sLab.TextColor3 = COLORS.Text; sLab.Font = Enum.Font.GothamBold; sLab.TextSize = 13; sLab.TextXAlignment = Enum.TextXAlignment.Left; sLab.ZIndex = 11
    local sBg = Instance.new("Frame", sHolder)
    sBg.Size = UDim2.new(1, -20, 0, 6); sBg.Position = UDim2.new(0, 10, 0, 34); sBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65); sBg.BorderSizePixel = 0; sBg.ZIndex = 11
    Instance.new("UICorner", sBg).CornerRadius = UDim.new(1, 0)
    local sFill = Instance.new("Frame", sBg)
    local initialFrac = Config.Aimbot.HitpartWeights[key] / 100; sFill.Size = UDim2.new(initialFrac, 0, 1, 0); sFill.BackgroundColor3 = COLORS.Accent; sFill.BorderSizePixel = 0; sFill.ZIndex = 12
    Instance.new("UICorner", sFill).CornerRadius = UDim.new(1, 0)
    local sKnob = Instance.new("Frame", sBg)
    sKnob.Size = UDim2.new(0, 12, 0, 12); sKnob.AnchorPoint = Vector2.new(0.5, 0.5); sKnob.Position = UDim2.new(initialFrac, 0, 0.5, 0); sKnob.BackgroundColor3 = Color3.new(1, 1, 1); sKnob.BorderSizePixel = 0; sKnob.ZIndex = 13
    Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1, 0)
    sKnob.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then STATE.activeWeightSlider = { fill = sFill, knob = sKnob, lab = sLab, bg = sBg, key = key, minVal = 0, maxVal = 100, decimals = 0 } end end)
end

AddPopupSlider("Peluang Kepala", "Head"); AddPopupSlider("Peluang Badan", "Torso"); AddPopupSlider("Peluang Kaki", "Legs")

UserInputService.InputChanged:Connect(function(inp)
    if not STATE.activeWeightSlider then return end; if not PopupFrame.Visible then STATE.activeWeightSlider = nil; return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        local as = STATE.activeWeightSlider; local mousePos = inp.Position; local rel = (mousePos.X - as.bg.AbsolutePosition.X) / as.bg.AbsoluteSize.X; rel = math.clamp(rel, 0, 1)
        local val = as.minVal + (as.maxVal - as.minVal) * rel; if as.decimals == 0 then val = math.floor(val + 0.5) else val = math.floor(val * (10 ^ as.decimals) + 0.5) / (10 ^ as.decimals) end
        as.fill.Size = UDim2.new(rel, 0, 1, 0); as.knob.Position = UDim2.new(rel, 0, 0.5, 0)
        as.lab.Text = (as.key == "Head" and "Peluang Kepala" or as.key == "Torso" and "Peluang Badan" or "Peluang Kaki") .. ": " .. val .. "%"
        Config.Aimbot.HitpartWeights[as.key] = val
    end
end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then STATE.activeWeightSlider = nil end end)

local function RefreshUI()
    for _, item in ipairs(STATE.UIRegistry) do
        local value = Config; local path = item.configPath; for i = 1, #path - 1 do value = value[path[i]] end; local finalKey = path[#path]
        if item.type == "toggle" then item.update(value[finalKey]) elseif item.type == "slider" then item.update(value[finalKey]) end
    end
end

local FILE_NAME = "RapzX_Presets_v68.json"
local function loadPresets() if readfile then local success, result = pcall(function() return readfile(FILE_NAME) end); if success and result then return HttpService:JSONDecode(result) end end; return {} end
local function savePresets(data) if writefile then pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(data)) end) end end
STATE.presets = loadPresets() or {}
local defaultConfig = {}; for k, v in pairs(Config) do if type(v) == "table" then defaultConfig[k] = {}; for k2, v2 in pairs(v) do defaultConfig[k][k2] = v2 end else defaultConfig[k] = v end end

local function savePreset(slot)
    local data = {}
    for k, v in pairs(Config) do
        if type(v) == "table" then data[k] = {}; for k2, v2 in pairs(v) do if type(v2) == "EnumItem" then data[k][k2] = { __enum = true, name = v2.Name, enum = tostring(v2.EnumType) } else data[k][k2] = v2 end end
        else if type(v) == "EnumItem" then data[k] = { __enum = true, name = v.Name, enum = tostring(v.EnumType) } else data[k] = v end end
    end
    STATE.presets[slot] = data; savePresets(STATE.presets)
end

local function deepCopy(tbl) local copy = {}; for k, v in pairs(tbl) do if type(v) == "table" then copy[k] = deepCopy(v) else copy[k] = v end end; return copy end

local function loadPreset(slot)
    local data = STATE.presets[slot]; if not data then return end
    local resetConfig = deepCopy(defaultConfig); for k, v in pairs(resetConfig) do Config[k] = v end
    for k, v in pairs(data) do
        if type(v) == "table" and not v.__enum then for k2, v2 in pairs(v) do if type(v2) == "table" and v2.__enum then Config[k][k2] = Enum[v2.enum][v2.name] else Config[k][k2] = v2 end end
        else if type(v) == "table" and v.__enum then Config[k] = Enum[v.enum][v.name] else Config[k] = v end end
    end
    RefreshUI(); updateAimbotHUD(); updateTargetPartHUD(); if Config.AutoPlay.Enabled then startAutoPlay() else stopAutoPlay() end; if not Config.Aimbot.BigHeadEnabled then restoreHitboxes() end
end

local AimPage = CreateTab("Aimbot"); local ESPPage = CreateTab("Visuals"); local CrosshairPage = CreateTab("Crosshair"); local CyberPage = CreateTab("Cyber"); local MovePage = CreateTab("Movement"); local AutoPage = CreateTab("AutoPlay"); local MiscPage = CreateTab("Settings")

AddToggle(AimPage, "Aimbot Master", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v; updateAimbotHUD() end, { "Aimbot", "Enabled" })

local AimModeDropdown = Instance.new("TextButton", AimPage)
AimModeDropdown.Size = UDim2.new(1, 0, 0, 36)
AimModeDropdown.BackgroundColor3 = COLORS.Card
AimModeDropdown.BorderSizePixel = 0
AimModeDropdown.Text = "Aim Mode: " .. Config.Aimbot.AimMode
AimModeDropdown.TextColor3 = COLORS.Text
AimModeDropdown.Font = Enum.Font.GothamBold
AimModeDropdown.TextSize = 13
Instance.new("UICorner", AimModeDropdown).CornerRadius = UDim.new(0, 6)
local aimModeIndex = 1
for i, mode in ipairs(AIM_MODES) do
    if mode == Config.Aimbot.AimMode then aimModeIndex = i break end
end
AimModeDropdown.MouseButton1Click:Connect(function()
    aimModeIndex = (aimModeIndex % #AIM_MODES) + 1
    Config.Aimbot.AimMode = AIM_MODES[aimModeIndex]
    AimModeDropdown.Text = "Aim Mode: " .. Config.Aimbot.AimMode
    updateTargetPartHUD()
    if Config.Aimbot.AimMode == "Dynamic" then
        kirimNotif("AIM MODE", "Dynamic - otomatis pilih part terdekat crosshair")
    else
        kirimNotif("AIM MODE", "Manual - pilih part via keybind/dropdown")
    end
end)

local AimPartDropdown = Instance.new("TextButton", AimPage)
AimPartDropdown.Size = UDim2.new(1, 0, 0, 36)
AimPartDropdown.BackgroundColor3 = COLORS.Card
AimPartDropdown.BorderSizePixel = 0
AimPartDropdown.Text = "Target Part: Head"
AimPartDropdown.TextColor3 = COLORS.Text
AimPartDropdown.Font = Enum.Font.GothamBold
AimPartDropdown.TextSize = 13
Instance.new("UICorner", AimPartDropdown).CornerRadius = UDim.new(0, 6)
AimPartDropdown.MouseButton1Click:Connect(function()
    if Config.Aimbot.AimMode == "Dynamic" then
        kirimNotif("INFO", "Dynamic mode aktif - gak bisa ganti part manual")
        return
    end
    cycleTargetPart()
    local myChar = LocalPlayer.Character
    local availableParts = getAvailableAimParts(myChar)
    AimPartDropdown.Text = "Target Part: " .. availableParts[Config.Aimbot.AimPartPreset]
end)

AddToggle(AimPage, "Humanize Aim", Config.Aimbot.HumanizeAimEnabled, function(v) Config.Aimbot.HumanizeAimEnabled = v end, { "Aimbot", "HumanizeAimEnabled" })
AddSlider(AimPage, "Humanize Intensity", 1, 10, Config.Aimbot.HumanizeIntensity, 0, function(v) Config.Aimbot.HumanizeIntensity = v end, { "Aimbot", "HumanizeIntensity" })
AddSlider(AimPage, "Curve Chance", 0, 100, math.floor(Config.Aimbot.HumanizeCurveChance * 100), 0, function(v) Config.Aimbot.HumanizeCurveChance = v / 100 end, { "Aimbot", "HumanizeCurveChance" })
AddSlider(AimPage, "Micro Correction", 0, 100, math.floor(Config.Aimbot.HumanizeMicroCorrection * 100), 0, function(v) Config.Aimbot.HumanizeMicroCorrection = v / 100 end, { "Aimbot", "HumanizeMicroCorrection" })

AddToggle(AimPage, "Randomize Hitpart", Config.Aimbot.RandomizeHitpart, function(v) Config.Aimbot.RandomizeHitpart = v end, { "Aimbot", "RandomizeHitpart" })
AddButton(AimPage, "Persentase Prioritas (Setting)", function() PopupFrame.Visible = not PopupFrame.Visible end)
AddToggle(AimPage, "Smart Targeting (FOV-Based)", Config.Aimbot.SmartTargeting, function(v) Config.Aimbot.SmartTargeting = v end, { "Aimbot", "SmartTargeting" })
AddToggle(AimPage, "Auto Flick Behind", Config.Aimbot.AutoFlick, function(v) Config.Aimbot.AutoFlick = v end, { "Aimbot", "AutoFlick" })
AddToggle(AimPage, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end, { "Aimbot", "TeamCheck" })
AddToggle(AimPage, "Wall Check", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end, { "Aimbot", "WallCheck" })
AddToggle(AimPage, "Show FOV", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end, { "Aimbot", "ShowFOV" })

AddToggle(AimPage, "Trigger Mode", Config.Aimbot.TriggerMode, function(v) Config.Aimbot.TriggerMode = v end, { "Aimbot", "TriggerMode" })
AddKeybind(AimPage, "Trigger Keybind", Config.Aimbot.TriggerKey, function(k) Config.Aimbot.TriggerKey = k end)

AddKeybind(AimPage, "Cycle Target Part", Config.Aimbot.TargetPartKeybind, function(k) Config.Aimbot.TargetPartKeybind = k end)

local AutoFireModeDropdown = Instance.new("TextButton", AimPage)
AutoFireModeDropdown.Size = UDim2.new(1, 0, 0, 36)
AutoFireModeDropdown.BackgroundColor3 = COLORS.Card
AutoFireModeDropdown.BorderSizePixel = 0
AutoFireModeDropdown.Text = "Auto Fire: " .. Config.Aimbot.AutoFireMode
AutoFireModeDropdown.TextColor3 = COLORS.Text
AutoFireModeDropdown.Font = Enum.Font.GothamBold
AutoFireModeDropdown.TextSize = 13
Instance.new("UICorner", AutoFireModeDropdown).CornerRadius = UDim.new(0, 6)
local autoFireModeIndex = 1
for i, mode in ipairs(AUTO_FIRE_MODES) do
    if mode == Config.Aimbot.AutoFireMode then autoFireModeIndex = i break end
end
AutoFireModeDropdown.MouseButton1Click:Connect(function()
    autoFireModeIndex = (autoFireModeIndex % #AUTO_FIRE_MODES) + 1
    Config.Aimbot.AutoFireMode = AUTO_FIRE_MODES[autoFireModeIndex]
    AutoFireModeDropdown.Text = "Auto Fire: " .. Config.Aimbot.AutoFireMode
end)

AddSlider(AimPage, "Scope Hold", 1, 10, math.floor(Config.Aimbot.ScopeHoldDuration * 10), 0, function(v) Config.Aimbot.ScopeHoldDuration = v / 10 end)
AddSlider(AimPage, "Scope Release", 0, 10, math.floor(Config.Aimbot.ScopeReleaseDelay * 10), 0, function(v) Config.Aimbot.ScopeReleaseDelay = v / 10 end)

AddToggle(AimPage, "Easy Lepas Aim", Config.Aimbot.EasyLepasAim, function(v) Config.Aimbot.EasyLepasAim = v end, { "Aimbot", "EasyLepasAim" })
AddSlider(AimPage, "Lepas Threshold", 1, 20, Config.Aimbot.EasyLepasThreshold, 0, function(v) Config.Aimbot.EasyLepasThreshold = v end, { "Aimbot", "EasyLepasThreshold" })
AddSlider(AimPage, "FOV Radius", 30, 500, Config.Aimbot.FOV, 0, function(v) Config.Aimbot.FOV = v end, { "Aimbot", "FOV" })
AddToggle(AimPage, "Use Smooth Aim", Config.Aimbot.SmoothnessEnabled, function(v) Config.Aimbot.SmoothnessEnabled = v end, { "Aimbot", "SmoothnessEnabled" })
AddSlider(AimPage, "Smoothness Speed", 1, 100, math.floor(Config.Aimbot.Smoothness * 100), 0, function(v) Config.Aimbot.Smoothness = v / 100 end, { "Aimbot", "Smoothness" })
AddToggle(AimPage, "Silent Aim / Bighead Hitbox", Config.Aimbot.BigHeadEnabled, function(v) Config.Aimbot.BigHeadEnabled = v; if v then updateBigHead() else restoreHitboxes() end end, { "Aimbot", "BigHeadEnabled" })
AddSlider(AimPage, "Head Hitbox Size", 1, 50, Config.Aimbot.BigHeadSize, 0, function(v) Config.Aimbot.BigHeadSize = v end, { "Aimbot", "BigHeadSize" })

AddSlider(AimPage, "Flick Behind Range", 30, 500, Config.Aimbot.FlickRange, 0, function(v) Config.Aimbot.FlickRange = v end, { "Aimbot", "FlickRange" })

AddToggle(AimPage, "Spinbot", Config.Aimbot.SpinbotEnabled, function(v) Config.Aimbot.SpinbotEnabled = v end, { "Aimbot", "SpinbotEnabled" })
AddSlider(AimPage, "Spin Speed", 1, 50, Config.Aimbot.SpinSpeed, 0, function(v) Config.Aimbot.SpinSpeed = v end, { "Aimbot", "SpinSpeed" })

AddToggle(AimPage, "TeamCheck Whitelist Mode", Config.Aimbot.TeamCheckWhitelistEnabled, function(v) Config.Aimbot.TeamCheckWhitelistEnabled = v end, { "Aimbot", "TeamCheckWhitelistEnabled" })

local WhitelistInput = Instance.new("TextBox", AimPage)
WhitelistInput.Size = UDim2.new(1, 0, 0, 36)
WhitelistInput.BackgroundColor3 = COLORS.Card
WhitelistInput.BorderSizePixel = 0
WhitelistInput.Text = "Keyword (pisah koma)..."
WhitelistInput.TextColor3 = COLORS.Text
WhitelistInput.Font = Enum.Font.GothamBold
WhitelistInput.TextSize = 12
WhitelistInput.PlaceholderText = "Contoh: P, rapp, zety"
WhitelistInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
WhitelistInput.ClearTextOnFocus = true
Instance.new("UICorner", WhitelistInput).CornerRadius = UDim.new(0, 6)

local function updateWhitelist()
    local rawText = WhitelistInput.Text
    if rawText == "" or rawText == "Keyword (pisah koma)..." then
        Config.Aimbot.TeamCheckWhitelist = {}
    else
        local keywords = {}
        for kw in string.gmatch(rawText, "[^,]+") do
            local trimmed = string.gsub(kw, "^%s*(.-)%s*$", "%1")
            if trimmed ~= "" then
                table.insert(keywords, trimmed)
            end
        end
        Config.Aimbot.TeamCheckWhitelist = keywords
    end
end

WhitelistInput.FocusLost:Connect(function(enterPressed) updateWhitelist() end)

AddButton(AimPage, "Update Whitelist", function()
    updateWhitelist()
    kirimNotif("WHITELIST", #Config.Aimbot.TeamCheckWhitelist .. " teman dilindungi!")
end)

AddToggle(ESPPage, "ESP Master", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end, { "ESP", "Enabled" })
AddToggle(ESPPage, "Full Body Boxes", Config.ESP.BoxEnabled, function(v) Config.ESP.BoxEnabled = v end, { "ESP", "BoxEnabled" })
AddToggle(ESPPage, "Skeleton ESP", Config.ESP.SkeletonEnabled, function(v) Config.ESP.SkeletonEnabled = v end, { "ESP", "SkeletonEnabled" })
AddToggle(ESPPage, "Tracers", Config.ESP.TracerEnabled, function(v) Config.ESP.TracerEnabled = v end, { "ESP", "TracerEnabled" })
AddToggle(ESPPage, "Names", Config.ESP.NameEnabled, function(v) Config.ESP.NameEnabled = v end, { "ESP", "NameEnabled" })
AddToggle(ESPPage, "Billboard Distance (Studs)", Config.ESP.DistanceEnabled, function(v) Config.ESP.DistanceEnabled = v end, { "ESP", "DistanceEnabled" })
AddToggle(ESPPage, "Clean Health Bars", Config.ESP.HealthBarEnabled, function(v) Config.ESP.HealthBarEnabled = v end, { "ESP", "HealthBarEnabled" })
AddToggle(ESPPage, "ESP Chams", Config.ESP.ChamsEnabled, function(v) Config.ESP.ChamsEnabled = v end, { "ESP", "ChamsEnabled" })
AddToggle(ESPPage, "Auto Team Color", Config.ESP.AutoColorTeam, function(v) Config.ESP.AutoColorTeam = v end, { "ESP", "AutoColorTeam" })
AddSlider(ESPPage, "Max Distance", 50, 2000, Config.ESP.MaxDistance, 0, function(v) Config.ESP.MaxDistance = v end, { "ESP", "MaxDistance" })

local NoTeamColorDropdown = Instance.new("TextButton", ESPPage)
NoTeamColorDropdown.Size = UDim2.new(1, 0, 0, 36)
NoTeamColorDropdown.BackgroundColor3 = COLORS.Card
NoTeamColorDropdown.BorderSizePixel = 0
NoTeamColorDropdown.Text = "No Team Color: " .. NO_TEAM_COLOR_NAMES[Config.ESP.NoTeamColorPreset]
NoTeamColorDropdown.TextColor3 = COLORS.Text
NoTeamColorDropdown.Font = Enum.Font.GothamBold
NoTeamColorDropdown.TextSize = 13
Instance.new("UICorner", NoTeamColorDropdown).CornerRadius = UDim.new(0, 6)
NoTeamColorDropdown.MouseButton1Click:Connect(function()
    Config.ESP.NoTeamColorPreset = (Config.ESP.NoTeamColorPreset % #NO_TEAM_COLORS) + 1
    NoTeamColorDropdown.Text = "No Team Color: " .. NO_TEAM_COLOR_NAMES[Config.ESP.NoTeamColorPreset]
end)

AddToggle(CrosshairPage, "Crosshair Enabled", Config.Crosshair.Enabled, function(v) Config.Crosshair.Enabled = v end, { "Crosshair", "Enabled" })

local CrosshairStyleDropdown = Instance.new("TextButton", CrosshairPage)
CrosshairStyleDropdown.Size = UDim2.new(1, 0, 0, 36)
CrosshairStyleDropdown.BackgroundColor3 = COLORS.Card
CrosshairStyleDropdown.BorderSizePixel = 0
CrosshairStyleDropdown.Text = "Style: " .. Config.Crosshair.Style
CrosshairStyleDropdown.TextColor3 = COLORS.Text
CrosshairStyleDropdown.Font = Enum.Font.GothamBold
CrosshairStyleDropdown.TextSize = 13
Instance.new("UICorner", CrosshairStyleDropdown).CornerRadius = UDim.new(0, 6)
local crosshairStyleIndex = 1
for i, style in ipairs(CROSSHAIR_STYLES) do
    if style == Config.Crosshair.Style then crosshairStyleIndex = i break end
end
CrosshairStyleDropdown.MouseButton1Click:Connect(function()
    crosshairStyleIndex = (crosshairStyleIndex % #CROSSHAIR_STYLES) + 1
    Config.Crosshair.Style = CROSSHAIR_STYLES[crosshairStyleIndex]
    CrosshairStyleDropdown.Text = "Style: " .. Config.Crosshair.Style
end)

AddSlider(CrosshairPage, "Size", 5, 50, Config.Crosshair.Size, 0, function(v) Config.Crosshair.Size = v end, { "Crosshair", "Size" })
AddSlider(CrosshairPage, "Thickness", 1, 10, Config.Crosshair.Thickness, 0, function(v) Config.Crosshair.Thickness = v end, { "Crosshair", "Thickness" })
AddSlider(CrosshairPage, "Transparency", 0, 100, math.floor(Config.Crosshair.Transparency * 100), 0, function(v) Config.Crosshair.Transparency = v / 100 end, { "Crosshair", "Transparency" })

local CrosshairColorDropdown = Instance.new("TextButton", CrosshairPage)
CrosshairColorDropdown.Size = UDim2.new(1, 0, 0, 36)
CrosshairColorDropdown.BackgroundColor3 = COLORS.Card
CrosshairColorDropdown.BorderSizePixel = 0
CrosshairColorDropdown.Text = "Color: " .. CROSSHAIR_COLOR_NAMES[Config.Crosshair.ColorPreset]
CrosshairColorDropdown.TextColor3 = COLORS.Text
CrosshairColorDropdown.Font = Enum.Font.GothamBold
CrosshairColorDropdown.TextSize = 13
Instance.new("UICorner", CrosshairColorDropdown).CornerRadius = UDim.new(0, 6)
CrosshairColorDropdown.MouseButton1Click:Connect(function()
    Config.Crosshair.ColorPreset = (Config.Crosshair.ColorPreset % #CROSSHAIR_COLORS) + 1
    CrosshairColorDropdown.Text = "Color: " .. CROSSHAIR_COLOR_NAMES[Config.Crosshair.ColorPreset]
end)

AddToggle(CyberPage, "Cyber Vision Master", Config.CyberVision.Enabled, function(v) Config.CyberVision.Enabled = v end, { "CyberVision", "Enabled" })
AddToggle(CyberPage, "Show Look Line", Config.CyberVision.ShowLookLine, function(v) Config.CyberVision.ShowLookLine = v end, { "CyberVision", "ShowLookLine" })
AddSlider(CyberPage, "Line Length", 5, 50, Config.CyberVision.LookLineLength, 0, function(v) Config.CyberVision.LookLineLength = v end, { "CyberVision", "LookLineLength" })
AddToggle(CyberPage, "Team Check", Config.CyberVision.TeamCheck, function(v) Config.CyberVision.TeamCheck = v end, { "CyberVision", "TeamCheck" })
AddToggle(CyberPage, "Warn If Looking At Me", Config.CyberVision.WarnIfLookingAtMe, function(v) Config.CyberVision.WarnIfLookingAtMe = v end, { "CyberVision", "WarnIfLookingAtMe" })
AddSlider(CyberPage, "Look Threshold", 0.1, 1.0, Config.CyberVision.LookingAtMeThreshold, 1, function(v) Config.CyberVision.LookingAtMeThreshold = v end, { "CyberVision", "LookingAtMeThreshold" })

AddToggle(MovePage, "Auto Bhop", Config.Movement.AutoBhop, function(v) Config.Movement.AutoBhop = v end, { "Movement", "AutoBhop" })
AddToggle(MovePage, "Anti-Aim", Config.Movement.AntiAim, function(v) Config.Movement.AntiAim = v end, { "Movement", "AntiAim" })
AddSlider(MovePage, "Anti-Aim Angle", 1, 180, Config.Movement.AntiAimAngle, 0, function(v) Config.Movement.AntiAimAngle = v end, { "Movement", "AntiAimAngle" })
AddToggle(MovePage, "Auto-Strafe", Config.Movement.AutoStrafe, function(v) Config.Movement.AutoStrafe = v end, { "Movement", "AutoStrafe" })
AddSlider(MovePage, "Strafe Speed", 0, 100, Config.Movement.StrafeSpeed, 0, function(v) Config.Movement.StrafeSpeed = v end, { "Movement", "StrafeSpeed" })

AddToggle(MovePage, "WalkSpeed", Config.Movement.WalkSpeedEnabled, function(v) Config.Movement.WalkSpeedEnabled = v; if v then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = Config.Movement.WalkSpeedValue end end end, { "Movement", "WalkSpeedEnabled" })
AddSlider(MovePage, "WalkSpeed Value", 16, 250, Config.Movement.WalkSpeedValue, 0, function(v) Config.Movement.WalkSpeedValue = v; if Config.Movement.WalkSpeedEnabled then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end end, { "Movement", "WalkSpeedValue" })
AddToggle(MovePage, "JumpPower", Config.Movement.JumpPowerEnabled, function(v) Config.Movement.JumpPowerEnabled = v; if v then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = Config.Movement.JumpPowerValue end end end, { "Movement", "JumpPowerEnabled" })
AddSlider(MovePage, "JumpPower Value", 50, 500, Config.Movement.JumpPowerValue, 0, function(v) Config.Movement.JumpPowerValue = v; if Config.Movement.JumpPowerEnabled then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v end end end, { "Movement", "JumpPowerValue" })

AddToggle(AutoPage, "AutoPlay Master", Config.AutoPlay.Enabled, function(v) Config.AutoPlay.Enabled = v; if v then startAutoPlay() else stopAutoPlay() end end, { "AutoPlay", "Enabled" })
AddToggle(AutoPage, "Human Mode (Pro Player)", Config.AutoPlay.HumanMode, function(v) Config.AutoPlay.HumanMode = v end, { "AutoPlay", "HumanMode" })
AddToggle(AutoPage, "Jiggle Aim", Config.AutoPlay.JiggleAim, function(v) Config.AutoPlay.JiggleAim = v end, { "AutoPlay", "JiggleAim" })
AddToggle(AutoPage, "Random Jumps", Config.AutoPlay.RandomJumps, function(v) Config.AutoPlay.RandomJumps = v end, { "AutoPlay", "RandomJumps" })
AddToggle(AutoPage, "Look Around", Config.AutoPlay.LookAround, function(v) Config.AutoPlay.LookAround = v end, { "AutoPlay", "LookAround" })
AddToggle(AutoPage, "Micro Pause", Config.AutoPlay.MicroPause, function(v) Config.AutoPlay.MicroPause = v end, { "AutoPlay", "MicroPause" })
AddSlider(AutoPage, "Engage Distance", 20, 200, Config.AutoPlay.EngageDistance, 0, function(v) Config.AutoPlay.EngageDistance = v end, { "AutoPlay", "EngageDistance" })
AddSlider(AutoPage, "HP Threshold", 10, 100, Config.AutoPlay.HPThreshold, 0, function(v) Config.AutoPlay.HPThreshold = v end, { "AutoPlay", "HPThreshold" })
AddToggle(AutoPage, "Auto Respawn", Config.AutoPlay.AutoRespawn, function(v) Config.AutoPlay.AutoRespawn = v end, { "AutoPlay", "AutoRespawn" })
AddSlider(AutoPage, "Strafe Speed", 0, 100, Config.AutoPlay.CombatStrafeSpeed, 0, function(v) Config.AutoPlay.CombatStrafeSpeed = v end, { "AutoPlay", "CombatStrafeSpeed" })

AddKeybind(MiscPage, "GUI Toggle Bind", Config.Misc.GuiKey, function(k) Config.Misc.GuiKey = k end)
AddKeybind(MiscPage, "Teleport Keybind", Config.Misc.TeleportKey, function(k) Config.Misc.TeleportKey = k end)

local TeleportHitDropdown = Instance.new("TextButton", MiscPage)
TeleportHitDropdown.Size = UDim2.new(1, 0, 0, 36)
TeleportHitDropdown.BackgroundColor3 = COLORS.Card
TeleportHitDropdown.BorderSizePixel = 0
TeleportHitDropdown.Text = "Teleport Hit: " .. Config.Misc.TeleportHitButton .. " Click"
TeleportHitDropdown.TextColor3 = COLORS.Text
TeleportHitDropdown.Font = Enum.Font.GothamBold
TeleportHitDropdown.TextSize = 13
Instance.new("UICorner", TeleportHitDropdown).CornerRadius = UDim.new(0, 6)
local teleportHitOptions = { "Left", "Right" }
local teleportHitIndex = Config.Misc.TeleportHitButton == "Left" and 1 or 2
TeleportHitDropdown.MouseButton1Click:Connect(function()
    teleportHitIndex = teleportHitIndex % #teleportHitOptions + 1
    Config.Misc.TeleportHitButton = teleportHitOptions[teleportHitIndex]
    TeleportHitDropdown.Text = "Teleport Hit: " .. Config.Misc.TeleportHitButton .. " Click"
end)

AddToggle(MiscPage, "Dim Lighting (FPS Boost)", Config.Misc.DimLighting, function(v) Config.Misc.DimLighting = v; local Lighting = game:GetService("Lighting"); if not v then Lighting.GlobalShadows = true; Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(0, 0, 0); Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); for _, effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then effect.Enabled = true end end end end, { "Misc", "DimLighting" })

AddToggle(MiscPage, "RGB Weapon", Config.Misc.RGBWeapon, function(v) Config.Misc.RGBWeapon = v; if v then cacheRGBWeapons() end end, { "Misc", "RGBWeapon" })
AddToggle(MiscPage, "FOV Changer", Config.Misc.FOVChangerEnabled, function(v) Config.Misc.FOVChangerEnabled = v; if not v then Cam.FieldOfView = 70 end end, { "Misc", "FOVChangerEnabled" })
AddSlider(MiscPage, "Camera FOV", 30, 120, Config.Misc.CameraFOV, 0, function(v) Config.Misc.CameraFOV = v end, { "Misc", "CameraFOV" })

AddButton(MiscPage, "Fast Fire", function() pcall(function() local wf = game.ReplicatedStorage:FindFirstChild("Weapons"); if wf then for _, v in pairs(wf:GetDescendants()) do if v.Name == "FireRate" or v.Name == "BFireRate" then v.Value = 0.02 end end end end) end)
AddButton(MiscPage, "Teleport to Enemy", teleportToClosest)

AddToggle(MiscPage, "Auto Golden Knife", Config.Misc.AutoGoldenKnife, function(v) Config.Misc.AutoGoldenKnife = v; if v then startAutoGoldenKnife() else stopAutoGoldenKnife() end end, { "Misc", "AutoGoldenKnife" })

AddToggle(MiscPage, "Infinite Ammo", Config.Misc.InfiniteAmmo, function(v) Config.Misc.InfiniteAmmo = v; if v then startInfiniteAmmo() else stopInfiniteAmmo() end end, { "Misc", "InfiniteAmmo" })

AddToggle(MiscPage, "Anti Lag Mode", Config.Misc.AntiLag, function(v) Config.Misc.AntiLag = v; setAntiLag(v) end, { "Misc", "AntiLag" })

local PresetDropdown = Instance.new("TextButton", MiscPage)
PresetDropdown.Size = UDim2.new(1, 0, 0, 36); PresetDropdown.BackgroundColor3 = COLORS.Card; PresetDropdown.Text = "Preset: RAGE"; PresetDropdown.TextColor3 = COLORS.Text; PresetDropdown.Font = Enum.Font.GothamBold; PresetDropdown.TextSize = 13; PresetDropdown.BorderSizePixel = 0
Instance.new("UICorner", PresetDropdown).CornerRadius = UDim.new(0, 6)
local presetSlots = { "RAGE", "LEGIT", "SAFE", "CUSTOM" }; local presetIndex = 1
PresetDropdown.MouseButton1Click:Connect(function() presetIndex = presetIndex % #presetSlots + 1; STATE.currentPresetSlot = presetSlots[presetIndex]; PresetDropdown.Text = "Preset: " .. STATE.currentPresetSlot end)

AddButton(MiscPage, "Load Preset", function() loadPreset(STATE.currentPresetSlot) end)
AddButton(MiscPage, "Save Preset", function() savePreset(STATE.currentPresetSlot) end)

if not STATE.presets["RAGE"] then savePreset("RAGE") end
if not STATE.presets["LEGIT"] then
    local orig = deepCopy(defaultConfig); Config.Aimbot.SmoothnessEnabled = true; Config.Aimbot.Smoothness = 0.3; Config.Aimbot.FOV = 120; Config.Aimbot.BigHeadEnabled = false; Config.AutoPlay.Enabled = false; Config.Aimbot.RandomizeHitpart = false; Config.Aimbot.SmartTargeting = false; savePreset("LEGIT"); for k, v in pairs(orig) do Config[k] = v end
end
if not STATE.presets["SAFE"] then
    local orig = deepCopy(defaultConfig); Config.Aimbot.Enabled = false; Config.Aimbot.AutoFlick = false; Config.ESP.Enabled = false; Config.AutoPlay.Enabled = false; Config.Movement.AntiAim = false; Config.Aimbot.BigHeadEnabled = false; Config.Aimbot.RandomizeHitpart = false; Config.Aimbot.SmartTargeting = false; savePreset("SAFE"); for k, v in pairs(orig) do Config[k] = v end
end

AddButton(MiscPage, "Unload Script", function()
    Config.AutoPlay.Enabled = false
    stopAutoPlay()
    Config.Misc.AutoGoldenKnife = false
    stopAutoGoldenKnife()
    Config.Misc.InfiniteAmmo = false
    stopInfiniteAmmo()
    Config.CyberVision.Enabled = false
    
    STATE.CurrentTarget = nil
    STATE.AutoTarget = nil
    STATE.LockedTarget = nil
    STATE.flickLockTarget = nil
    
    MainGui:Destroy()
    AimbotStatusGui:Destroy()
    
    if STATE.RenderConnection then STATE.RenderConnection:Disconnect(); STATE.RenderConnection = nil end
    if STATE.HeartbeatConnection then STATE.HeartbeatConnection:Disconnect(); STATE.HeartbeatConnection = nil end
    if STATE.InputBeganConnection then STATE.InputBeganConnection:Disconnect(); STATE.InputBeganConnection = nil end
    if STATE.InputEndedConnection then STATE.InputEndedConnection:Disconnect(); STATE.InputEndedConnection = nil end
    if STATE.mouseLockConnection then STATE.mouseLockConnection:Disconnect(); STATE.mouseLockConnection = nil end
    if STATE.tweenConnection then STATE.tweenConnection:Disconnect(); STATE.tweenConnection = nil end
    if STATE.autoSaveConnection then STATE.autoSaveConnection:Disconnect(); STATE.autoSaveConnection = nil end
    
    pcall(function() RunService:UnbindFromRenderStep("RapzX_FOV_Force") end)
    
    FOVCircle:Remove()
    Cam.FieldOfView = 70
    
    for _, e in pairs(STATE.ESPPool) do
        for _, l in ipairs(e.Box) do l:Remove() end
        for _, l in ipairs(e.Skeleton) do l:Remove() end
        e.Tracer:Remove()
        e.Name:Remove()
        e.HPBg:Remove()
        e.HPFill:Remove()
    end
    
    for _, highlight in pairs(STATE.ChamsActive) do highlight:Destroy() end
    
    for _, entry in pairs(STATE.CyberVisionPool) do
        if entry.line then entry.line:Remove() end
        if entry.dot then entry.dot:Remove() end
    end
    table.clear(STATE.CyberVisionPool)
    
    for p, obj in pairs(STATE.ESPStudsObjects) do
        if obj.GUI then obj.GUI:Destroy() end
    end
    table.clear(STATE.ESPStudsObjects)
    
    restoreHitboxes()
    
    if STATE.originalRootJointC0 then
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.RootJoint.C0 = STATE.originalRootJointC0
        end)
    end
    
    for _, line in ipairs(STATE.CrosshairLines) do line:Remove() end
    if STATE.CrosshairCircle then STATE.CrosshairCircle:Remove() end
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = false
end)

SwitchTab("Aimbot")

task.spawn(function()
    while task.wait(0.5) do
        if not MainGui or not MainGui.Parent then break end
        local tempCache = {}; local teams = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and isPlayerAlive(p) then table.insert(tempCache, p); if p.Team then teams[p.Team.Name or tostring(p.Team)] = true end; if not STATE.ESPStudsObjects[p] and Config.ESP.DistanceEnabled and Config.ESP.Enabled then createDistanceDisplay(p) end end end
        STATE.PlayerCache = tempCache; local teamCount = 0; for _ in pairs(teams) do teamCount = teamCount + 1 end; STATE.IsTeamGame = teamCount > 1
        if Config.Misc.RGBWeapon then cacheRGBWeapons() end
        if Config.Misc.DimLighting then
            pcall(function() local Lighting = game:GetService("Lighting"); if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end; if Lighting.Brightness ~= 0.3 then Lighting.Brightness = 0.3 end; if Lighting.Ambient ~= Color3.fromRGB(120, 120, 120) then Lighting.Ambient = Color3.fromRGB(120, 120, 120) end; if Lighting.OutdoorAmbient ~= Color3.fromRGB(120, 120, 120) then Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120) end; for _, effect in ipairs(Lighting:GetChildren()) do if (effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect")) and effect.Enabled then effect.Enabled = false end end end)
        end
        if tick() - STATE.lastBigHeadUpdate > 0.5 then STATE.lastBigHeadUpdate = tick(); if Config.Aimbot.BigHeadEnabled then updateBigHead() end end
        if Config.ESP.Enabled and Config.ESP.ChamsEnabled then
            local activePlayerSet = {}
            for _, p in ipairs(STATE.PlayerCache) do activePlayerSet[p] = true; local teamOk = true; if STATE.IsTeamGame and Config.ESP.AutoTeamDetect and p.Team == LocalPlayer.Team and not Config.ESP.ForceShowAll then teamOk = false end; local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart"); local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local distOk = hrp and myHRP and (myHRP.Position - hrp.Position).Magnitude <= Config.ESP.MaxDistance
                if teamOk and distOk then if not STATE.ChamsActive[p] and p.Character then local h = Instance.new("Highlight"); h.Adornee = p.Character; h.Parent = CoreGui; STATE.ChamsActive[p] = h end; local h = STATE.ChamsActive[p]; if h then h.Enabled = true; local bc = getEffectiveColor(p); h.FillColor = bc; h.OutlineColor = bc; h.FillTransparency = Config.ESP.ChamsFillTransparency; h.OutlineTransparency = Config.ESP.ChamsOutlineTransparency end
                else if STATE.ChamsActive[p] then STATE.ChamsActive[p].Enabled = false end end
            end
            for p, h in pairs(STATE.ChamsActive) do if not activePlayerSet[p] then h:Destroy(); STATE.ChamsActive[p] = nil end end
        else for p, h in pairs(STATE.ChamsActive) do h:Destroy(); STATE.ChamsActive[p] = nil end end
    end
end)

Players.PlayerRemoving:Connect(function(p) if STATE.ChamsActive[p] then STATE.ChamsActive[p]:Destroy(); STATE.ChamsActive[p] = nil end; if STATE.ESPActive[p] then STATE.ESPActive[p] = nil end; if STATE.ESPStudsObjects[p] then if STATE.ESPStudsObjects[p].GUI then STATE.ESPStudsObjects[p].GUI:Destroy() end; STATE.ESPStudsObjects[p] = nil end end)

RunService:BindToRenderStep("RapzX_FOV_Force", Enum.RenderPriority.Camera.Value + 1, function() Cam = workspace.CurrentCamera; if Config.Misc.FOVChangerEnabled then Cam.FieldOfView = Config.Misc.CameraFOV end end)

STATE.RenderConnection = RunService.RenderStepped:Connect(function()
    updateCrosshair()
    updateTargetPartHUD()
    local screenCenter = Cam.ViewportSize / 2
    if Config.Aimbot.Enabled and Config.Aimbot.ShowFOV then FOVCircle.Position = screenCenter; if tick() - STATE.lastFOVUpdate > 0.5 then FOVCircle.Radius = Config.Aimbot.FOV; STATE.lastFOVUpdate = tick() end; FOVCircle.Visible = true; FOVCircle.Color = STATE.TargetInFOV and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) else FOVCircle.Visible = false end
    local currentMousePos = UserInputService:GetMouseLocation(); local deltaMouse = STATE.lastMousePos and (currentMousePos - STATE.lastMousePos).Magnitude or 0; STATE.lastMousePos = currentMousePos
    local ignoreForThisFrame = nil; local easyLepasTriggered = false
    if Config.Aimbot.EasyLepasAim and deltaMouse > Config.Aimbot.EasyLepasThreshold and STATE.CurrentTarget then ignoreForThisFrame = STATE.CurrentTarget; easyLepasTriggered = true end
    local frontTarget = nil
    if tick() - STATE.lastTargetScan > 0.05 then
        STATE.lastTargetScan = tick()
        frontTarget = getClosestInFOV(ignoreForThisFrame)
        if frontTarget and isPlayerAlive(frontTarget) then
            STATE.lastTargetVisible = isPlayerVisible(frontTarget, getAimPart(frontTarget))
        else
            frontTarget = nil
            STATE.lastTargetVisible = false
        end
    else
        frontTarget = STATE.CurrentTarget
        if frontTarget and (not isPlayerAlive(frontTarget) or not STATE.lastTargetVisible) then
            frontTarget = nil
            STATE.TargetInFOV = false
            STATE.CurrentTarget = nil
        end
    end
    local flickTarget = nil
    if Config.Aimbot.Enabled and Config.Aimbot.AutoFlick and not frontTarget and not easyLepasTriggered then
        if STATE.flickLockTarget and isPlayerAlive(STATE.flickLockTarget) and isPlayerVisible(STATE.flickLockTarget, getAimPart(STATE.flickLockTarget)) then
            flickTarget = STATE.flickLockTarget
        else
            STATE.flickLockTarget = nil
        end
        if not flickTarget and not Config.Aimbot.TriggerMode then
            flickTarget = getEnemyBehind()
            if flickTarget and flickTarget ~= ignoreForThisFrame and isPlayerAlive(flickTarget) then
                STATE.flickLockTarget = flickTarget
            else
                flickTarget = nil
            end
        end
    else
        STATE.flickLockTarget = nil
    end
    if flickTarget and isPlayerAlive(flickTarget) then
        STATE.CurrentTarget = flickTarget
        STATE.TargetInFOV = true
        local part = flickTarget.Character:FindFirstChild(getAimPart(flickTarget))
        if part and part.Position.Y > -50 then
            lookAt(part.Position)
            if not STATE.HoldingMouse then STATE.HoldingMouse = true; mouse1press() end
        end
    else
        if Config.AutoPlay.Enabled and STATE.AutoTarget and isPlayerAlive(STATE.AutoTarget) then
            STATE.CurrentTarget = STATE.AutoTarget
            STATE.TargetInFOV = true
            local part = STATE.AutoTarget.Character:FindFirstChild(getAimPart(STATE.AutoTarget))
            if part and part.Position.Y > -50 then lookAt(part.Position) end
        elseif Config.Aimbot.Enabled and frontTarget and isPlayerAlive(frontTarget) then
            local part = frontTarget.Character:FindFirstChild(getAimPart(frontTarget))
            if part and part.Position.Y > -50 then
                if Config.Aimbot.TriggerMode then
                    if STATE.LeftClickHeld and STATE.LockedTarget and isPlayerAlive(STATE.LockedTarget) then
                        local lockPart = STATE.LockedTarget.Character:FindFirstChild(getAimPart(STATE.LockedTarget))
                        if lockPart and lockPart.Position.Y > -50 then lookAt(lockPart.Position) end
                    end
                else
                    lookAt(part.Position)
                end
            end
        else
            if not Config.Aimbot.TriggerMode then
                STATE.TargetInFOV = false
                STATE.CurrentTarget = nil
            end
        end
        if Config.Aimbot.Enabled then
            local autoMode = Config.Aimbot.AutoFireMode
            local canFire = STATE.TargetInFOV or (Config.Aimbot.TriggerMode and STATE.LeftClickHeld and STATE.LockedTarget and isPlayerAlive(STATE.LockedTarget))
            
            if autoMode == "Off" then
                if STATE.HoldingMouse then STATE.HoldingMouse = false; mouse1release() end
                if STATE.HoldingRightMouse then STATE.HoldingRightMouse = false; mouse2release() end
                if STATE.isScoping then mouse2release(); mouse1release(); STATE.isScoping = false; STATE.hasShotInScope = false; STATE.lastScopeShot = 0 end
            elseif autoMode == "Left Click" then
                if canFire then if not STATE.HoldingMouse then STATE.HoldingMouse = true; mouse1press() end
                else if STATE.HoldingMouse then STATE.HoldingMouse = false; mouse1release() end end
            elseif autoMode == "Right Click" then
                if canFire then if not STATE.HoldingRightMouse then STATE.HoldingRightMouse = true; mouse2press() end
                else if STATE.HoldingRightMouse then STATE.HoldingRightMouse = false; mouse2release() end end
            elseif autoMode == "Scope & Shoot" then
                if canFire then
                    if not STATE.isScoping and (tick() - (STATE.scopeCooldown or 0)) >= (Config.Aimbot.ScopeCooldown or 0.2) then
                        STATE.isScoping = true
                        STATE.scopeStartTime = tick()
                        STATE.hasShotInScope = false
                        STATE.shotTime = 0
                        mouse2press()
                    end
                    if STATE.isScoping then
                        local elapsed = tick() - STATE.scopeStartTime
                        if not STATE.hasShotInScope and elapsed >= Config.Aimbot.ScopeHoldDuration then
                            STATE.hasShotInScope = true
                            STATE.shotTime = tick()
                            mouse1press()
                            task.wait(0.03)
                            mouse1release()
                        end
                        if STATE.hasShotInScope and (tick() - STATE.shotTime) >= Config.Aimbot.ScopeReleaseDelay then
                            mouse2release()
                            STATE.isScoping = false
                            STATE.scopeCooldown = tick()
                        end
                        if elapsed > 5.0 then
                            mouse1release()
                            mouse2release()
                            STATE.isScoping = false
                            STATE.scopeCooldown = tick()
                        end
                    end
                else
                    if STATE.isScoping then
                        mouse1release()
                        mouse2release()
                        STATE.isScoping = false
                        STATE.scopeCooldown = tick()
                    end
                end
            end
        end
    end
end)

local function scanAndTrackAmmo()
    table.clear(STATE.ammoValues)
    table.clear(STATE.storedAmmoValues)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            if obj.Name == "Ammo" then
                obj.Value = 90
                table.insert(STATE.ammoValues, obj)
            elseif obj.Name == "StoredAmmo" then
                obj.Value = 90
                table.insert(STATE.storedAmmoValues, obj)
            end
        end
    end
end

local function startInfiniteAmmo()
    if STATE.ammoConnection then return end
    scanAndTrackAmmo()
    STATE.ammoConnection = RunService.Stepped:Connect(function()
        for _, ammo in ipairs(STATE.ammoValues) do
            if ammo and ammo.Parent then
                if ammo.Value <= 998 then ammo.Value = 999 end
            end
        end
        for _, stored in ipairs(STATE.storedAmmoValues) do
            if stored and stored.Parent then
                if stored.Value <= 998 then stored.Value = 999 end
            end
        end
    end)
end

local function stopInfiniteAmmo()
    if STATE.ammoConnection then
        STATE.ammoConnection:Disconnect()
        STATE.ammoConnection = nil
    end
end

game.DescendantAdded:Connect(function(obj)
    if not Config.Misc.InfiniteAmmo then return end
    if obj:IsA("IntValue") or obj:IsA("NumberValue") then
        if obj.Name == "Ammo" then
            obj.Value = 90
            table.insert(STATE.ammoValues, obj)
        elseif obj.Name == "StoredAmmo" then
            obj.Value = 90
            table.insert(STATE.storedAmmoValues, obj)
        end
    end
end)

STATE.HeartbeatConnection = RunService.Heartbeat:Connect(function()
    updateESP(); applyRGBWeapon(); updateAutoBhop(); updateAutoStrafe(); updateAntiAim(); updateCyberVision(); updateSpinbot(); applyWalkSpeedAndJump()
end)
