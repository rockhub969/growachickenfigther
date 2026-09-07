-- ==============================================================================
--              SYSHUB | GROW A CHICKEN FIGHTER (COMPLETE SUITE)
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ==============================================================================
-- [1] PEMUATAN PUSTAKA WINDUI RESMI
-- ==============================================================================
local WindUI = nil
local successUI, resultUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if successUI and resultUI then
    WindUI = resultUI
else
    local okRaw, rawResult = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if okRaw and rawResult then
        WindUI = rawResult
    end
end

if not WindUI then
    warn("[SysHub ERROR]: Gagal memuat library WindUI dari GitHub! Periksa koneksi internet.")
    return
end

local Window = nil
local successWindow, resultWindow = pcall(function()
    return WindUI:CreateWindow({
        Title = "SysHub - Grow A Chicken Fighter",
        Icon = "egg",
        Author = "SysHub Team",
        Folder = "SysHub",
        Size = UDim2.fromOffset(640, 420),
        MinSize = Vector2.new(480, 320),
        MaxSize = Vector2.new(950, 650),
        Transparent = true,
        NewElements = true,
        Theme = "Sky",
        Resizable = true,
        SideBarWidth = 160,
        BackgroundImageTransparency = 0.42,
        HideSearchBar = true,
        ScrollBarEnabled = true
    })
end)

if successWindow and resultWindow then
    Window = resultWindow
else
    warn("[SysHub ERROR]: Gagal membuat Window: " .. tostring(resultWindow))
    return
end

pcall(function()
    Window:EditOpenButton({
        Title = "SysHub",
        Icon = "egg",
        CornerRadius = UDim.new(0, 30),
        StrokeThickness = 1.5,
        Color = ColorSequence.new(Color3.fromHex("87CEFA"), Color3.fromHex("191970")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true
    })
end)

-- ==============================================================================
-- [FIX WINDUI DROPDOWN POPUP WIDTH]: UNLOCK UISizeConstraint & AUTO-EXPAND
-- Mengatasi batasan default WindUI (180px - 300px) agar daftar popup ayam
-- bisa terbuka lebar (300px) dan seluruh teks ayam terlihat utuh!
-- ==============================================================================
local expandDropdown = nil
local function setupDropdownPopupExpander()
    local TARGET_POPUP_WIDTH = 300

    local function patchGui(gui)
        if not gui then
            return
        end
        local function fixDescendant(inst)
            pcall(function()
                if inst:IsA("UISizeConstraint") then
                    inst:Destroy()
                elseif inst:IsA("Frame") and inst.Parent == gui then
                    inst.Size = UDim2.new(0, TARGET_POPUP_WIDTH, inst.Size.Y.Scale, inst.Size.Y.Offset)
                    for _, child in ipairs(inst:GetChildren()) do
                        if child:IsA("UISizeConstraint") then
                            child:Destroy()
                        end
                    end
                end
            end)
        end

        for _, desc in ipairs(gui:GetDescendants()) do
            fixDescendant(desc)
        end
        gui.DescendantAdded:Connect(function(desc)
            task.defer(function()
                fixDescendant(desc)
            end)
        end)
    end

    pcall(function()
        if WindUI and WindUI.DropdownGui then
            patchGui(WindUI.DropdownGui)
        end

        local hGui = (gethui and gethui()) or CoreGui
        if hGui then
            local dropScreen = hGui:FindFirstChild("WindUI/Dropdowns") or hGui:FindFirstChild("DropdownGui")
            if dropScreen then
                patchGui(dropScreen)
            end
            hGui.ChildAdded:Connect(function(child)
                if child.Name:find("Dropdown") then
                    patchGui(child)
                end
            end)
        end

        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            local dropScreen = pGui:FindFirstChild("WindUI/Dropdowns")
            if dropScreen then
                patchGui(dropScreen)
            end
            pGui.ChildAdded:Connect(function(child)
                if child.Name:find("Dropdown") then
                    patchGui(child)
                end
            end)
        end
    end)
end
setupDropdownPopupExpander()

expandDropdown = function(dd, width)
    if not dd then
        return
    end
    local w = width or 300
    pcall(function()
        if dd.UIElements then
            local canvas = dd.UIElements.MenuCanvas
            if canvas then
                for _, c in ipairs(canvas:GetChildren()) do
                    if c:IsA("UISizeConstraint") then
                        c:Destroy()
                    end
                end
                canvas.Size = UDim2.new(0, w, canvas.Size.Y.Scale, canvas.Size.Y.Offset)

                if not canvas:GetAttribute("WidthEnforced") then
                    canvas:SetAttribute("WidthEnforced", true)
                    canvas:GetPropertyChangedSignal("Visible"):Connect(function()
                        if canvas.Visible then
                            pcall(function()
                                for _, c in ipairs(canvas:GetChildren()) do
                                    if c:IsA("UISizeConstraint") then
                                        c:Destroy()
                                    end
                                end
                                canvas.Size = UDim2.new(0, w, canvas.Size.Y.Scale, canvas.Size.Y.Offset)
                            end)
                            task.defer(function()
                                pcall(function()
                                    canvas.Size = UDim2.new(0, w, canvas.Size.Y.Scale, canvas.Size.Y.Offset)
                                end)
                            end)
                            task.delay(0.05, function()
                                pcall(function()
                                    canvas.Size = UDim2.new(0, w, canvas.Size.Y.Scale, canvas.Size.Y.Offset)
                                end)
                            end)
                        end
                    end)

                    canvas:GetPropertyChangedSignal("Size"):Connect(function()
                        if canvas.Size.X.Offset ~= w then
                            canvas.Size = UDim2.new(0, w, canvas.Size.Y.Scale, canvas.Size.Y.Offset)
                        end
                    end)
                end
            end

            if dd.UIElements.Dropdown then
                dd.UIElements.Dropdown.Size = UDim2.new(0, 240, 0, 36)
            end
        end
    end)
end

-- TAB RESMI SESUAI REQUEST USER
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user"
})

local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "sprout"
})

local CoopTab = Window:Tab({
    Title = "Coop",
    Icon = "warehouse"
})

local FlockTab = Window:Tab({
    Title = "Flock",
    Icon = "feather"
})

local ChickenTab = Window:Tab({
    Title = "Chicken",
    Icon = "bird"
})

local RebirthTab = Window:Tab({
    Title = "Rebirth",
    Icon = "party-popper"
})

local RewardsTab = Window:Tab({
    Title = "Rewards",
    Icon = "gift"
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "server"
})

-- ==============================================================================
-- [2] LOGGING & NOTIFICATION HELPERS
-- ==============================================================================
local function logError(featureName, err)
    warn(string.format("[SysHub ERROR - %s]: %s", tostring(featureName), tostring(err)))
end

local function printLog(featureName, msg)
    print(string.format("[SysHub - %s]: %s", tostring(featureName), tostring(msg)))
end

local function notify(title, content)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = title,
                Content = content,
                Duration = 3
            })
        end
    end)
end

local function parseToggle(state)
    if type(state) == "boolean" then
        return state
    end
    if type(state) == "table" and state.Value ~= nil then
        return state.Value == true
    end
    return state == true
end

-- ==============================================================================
-- [3] VARIABEL & PENGATURAN DEFAULT
-- ==============================================================================
-- PLOT IDENTIFICATION
local currentPlotId = player:GetAttribute("Plot") or 1
pcall(function()
    player:GetAttributeChangedSignal("Plot"):Connect(function()
        currentPlotId = player:GetAttribute("Plot") or 1
        if getgenv then
            getgenv().currentPlotId = currentPlotId
        end
    end)
    if getgenv then
        getgenv().currentPlotId = currentPlotId
    end
end)

-- REBIRTH
local autoRebirth = false
local delayRebirth = 1
local autoRebirthSurplus = false
local surplusTargetCoop = 5
local surplusTargetFeederCount = 6
local surplusTargetFeederLevel = 50
local surplusTargetChickenLevel = 90
local surplusTargetTower = 70
local surplusTargetRecycler = 36
local surplusAllTargetsMet = false
local highestFloorReached = 0
local lastSurplusTowerTime = 0

-- COOP
local autoUpgradeCoop = false
local delayCoop = 0.5
local autoUpgradeRecycler = false
local delayRecycler = 0.1
local autoBuyFeeder = false
local delayBuy = 0.1
local autoUpgradeFeeder = false
local delayUpgrade = 0.1
local MAX_FEEDER_SLOTS = 6
local autoCollectNestEggs = false
local delayCollectEgg = 1

-- FARM
local autoClaimIncubator = false
local autoPutIncubator = false
local autoUpgradeIncubator = false
local delayUpgradeIncubator = 1.5
local autoSweep = false
local isSweepRunning = false
local MAX_CAPACITY = 20
local autoTower = false
local retreatFloor = 10
local delayTower = 0.5
local autoSellChickens = false
local delaySellChicken = 0.5
local sellMaxLevelProtection = 5
local selectedSellRarities = {
    ["Common"] = true,
    ["Uncommon"] = true,
    ["Rare"] = false,
    ["Epic"] = false,
    ["Legendary"] = false,
    ["Mythic"] = false,
    ["Divine"] = false,
    ["Celestial"] = false,
    ["Cosmic"] = false,
    ["Secret"] = false
}

-- CHICKEN
local autoPromote = false
local delayPromote = 1
local selectedPromoteTarget = nil
local promoteTargetList = {"Belum di-refresh (Klik tombol Refresh)"}
local promoteTargetMap = {}
local selectedPromoteFodder = nil
local selectedPromoteFoddersMap = {}
local promoteFodderList = {"Pilih ayam target terlebih dahulu"}
local promoteFodderMap = {}
local globalSpeciesTracker = {}
local updatePromoteStatusDisplay = nil
local promoteStatusPara = nil
local autoPromoteToggle = nil

local autoFuse = false
local fuseMainChickenName = nil
local fuseFodderChickenName = nil
local fuseLockedSkill = "Stormcall"

local favoritedChickenIds = {}
local promotedChickenIds = {}
local selectedFavChickenName = nil

-- REWARDS & UPDATE HUB
local UpdateHub = {
    -- REWARDS
    autoClaimPlayToday = false,
    autoClaimDailyStreak = false,
    autoClaimMission = false,
    autoClaimCharmDust = false,
    autoClaimArena = false,
    autoClaimMilestones = false,
    autoClaimIndex = false,

    -- ARENA AUTO-BATTLE (UPDATE)
    autoArenaFight = false,
    delayArenaFight = 3.0,
    isArenaFightRunning = false,

    -- AUTO UFO EVENT (UPDATE)
    autoUfoEvent = false,
    selectedUfoChickenName = nil,
    ufoChickenDropdown = nil,
    isUfoRunning = false,
    ufoEventLive = false,
    ufoChickenStatus = "AT_BASE",
    lastUfoSendTime = 0,

    -- CHARMS AUTOMATION (UPDATE)
    autoRollCharms = false,
    selectedCharmChickenName = nil,
    charmMinTier = "Super Rare+",
    charmPreferredStats = {
        ["atk"] = true,
        ["hp"] = true,
        ["crit"] = true,
        ["critDmg"] = true
    },
    charmDropdown = nil,
    isCharmRolling = false,

    -- EGG UNBOXING & AUTO OPEN (UPDATE)
    autoHatchEggs = false,
    selectedEggType = "Fortune Egg",
    delayHatchEggs = 1.0,
    isHatchingEggs = false,
    eggDropdown = nil,
    eggKeepDropdown = nil,
    selectedKeepSpecies = {},
    autoKeepInverted = true,
    ownedEggTypes = {},

    -- CHICKEN CARE (UPDATE)
    autoPetEncourage = false,
    delayPetEncourage = 5.0
}

local customPromoCode = ""
local promoCodesList = {
    "RELEASE", "CHICKEN", "FIGHTER", "EGG", "ARENA",
    "1KLIKES", "5KLIKES", "10KLIKES", "UPDATE1", "UPDATE2",
    "SECRET", "TOWER", "GOOSE", "BOOST", "FREE", "COOP",
    "DUST", "GOLD", "LUCKY"
}

-- PLAYER
local espPlayerEnabled = false
local espEggEnabled = false
local espScrapEnabled = false
local streamerMode = false
local fakeName = "Anonymous"

-- DROPDOWNS & MAPS
local chickenNames = {"Belum di-refresh (Klik tombol Refresh)"}
local chickenMap = {}
local selectedChickenName = nil
local selectedChickenId = nil
local chickenDropdown = nil
local promoteTargetDropdown = nil
local promoteFodderDropdown = nil
local promoteDropdown = nil
local fuseMainDropdown = nil
local fuseFodderDropdown = nil
local fuseSkillDropdown = nil
local availableFuseSkills = {"Stormcall", "Final Grace", "Lightning Strike", "Inferno Breath", "Void Pulse", "Golden Touch"}
local favDropdown = nil
local updateSurplusStatus = nil

-- ==============================================================================
-- [4] FUNGSI UNIVERSAL PANGGIL REMOTE
-- ==============================================================================
local function invokeRemote(remoteName, ...)
    local args = {...}
    local remote = nil
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if remotesFolder then
        remote = remotesFolder:FindFirstChild(remoteName)
    end

    if not remote then
        local reFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if reFolder then
            remote = reFolder:FindFirstChild(remoteName)
        end
    end

    if not remote then
        for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
            if (desc:IsA("RemoteFunction") or desc:IsA("RemoteEvent")) and desc.Name == remoteName then
                remote = desc
                break
            end
        end
    end

    if not remote then
        logError("invokeRemote", "Remote '" .. tostring(remoteName) .. "' tidak ditemukan!")
        return nil
    end

    local success, ret = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(unpack(args))
        elseif remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
            return true
        end
        return nil
    end)

    if not success then
        logError("invokeRemote (" .. tostring(remoteName) .. ")", ret)
        return nil
    end
    return ret
end

-- ==============================================================================
-- [5] SISTEM AUTO "NO THANKS" & SKIP ANIMASI KO
-- ==============================================================================
local function dismissTowerKOUI()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then
            return
        end

        for _, desc in ipairs(playerGui:GetDescendants()) do
            if desc:IsA("TextButton") or desc:IsA("TextLabel") then
                local txt = (desc.Text or ""):lower()
                if txt:find("no thanks") or txt:find("no, thanks") or txt:find("decline") or txt:find("give up") then
                    local targetBtn = nil
                    if desc:IsA("TextButton") then
                        targetBtn = desc
                    elseif desc.Parent and desc.Parent:IsA("TextButton") then
                        targetBtn = desc.Parent
                    end

                    if targetBtn and firesignal then
                        pcall(function()
                            firesignal(targetBtn.MouseButton1Click)
                        end)
                        pcall(function()
                            firesignal(targetBtn.Activated)
                        end)
                    end
                end
            end
        end
    end)
end

-- Interseptor Jaringan Instan
task.spawn(function()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotesFolder then
        local offerRemote = remotesFolder:FindFirstChild("TowerContinueOffer")
        if offerRemote and offerRemote:IsA("RemoteEvent") then
            offerRemote.OnClientEvent:Connect(function()
                task.wait(0.05)
                invokeRemote("TowerContinueDecline")
                dismissTowerKOUI()
                printLog("Auto Tower", "Mendapat tawaran Robux! Otomatis pilih 'No Thanks' & skip animasi.")
            end)
        end

        local defeatRemote = remotesFolder:FindFirstChild("TowerDefeat")
        if defeatRemote and defeatRemote:IsA("RemoteEvent") then
            defeatRemote.OnClientEvent:Connect(function()
                task.wait(0.05)
                invokeRemote("TowerContinueDecline")
                dismissTowerKOUI()
            end)
        end

        -- LiveEvent Listeners (UFO Invasion dsb)
        local leStarted = remotesFolder:FindFirstChild("LiveEventStarted")
        if leStarted and leStarted:IsA("RemoteEvent") then
            leStarted.OnClientEvent:Connect(function(eventData)
                local str = tostring(eventData):lower()
                if type(eventData) == "table" then
                    str = (eventData.id or eventData.name or eventData.title or ""):lower()
                end
                if str:find("ufo") or str:find("invasion") then
                    UpdateHub.ufoEventLive = true
                    printLog("UFO Event", "LiveEventStarted: UFO INVASION Aktif!")
                end
            end)
        end

        local leEnded = remotesFolder:FindFirstChild("LiveEventEnded")
        if leEnded and leEnded:IsA("RemoteEvent") then
            leEnded.OnClientEvent:Connect(function(eventData)
                local str = tostring(eventData):lower()
                if type(eventData) == "table" then
                    str = (eventData.id or eventData.name or eventData.title or ""):lower()
                end
                if str:find("ufo") or str:find("invasion") then
                    UpdateHub.ufoEventLive = false
                    printLog("UFO Event", "LiveEventEnded: UFO INVASION Selesai!")
                end
            end)
        end
    end
end)

-- Thread Pengawas UI KO
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoTower or autoRebirthSurplus then
            dismissTowerKOUI()
        end
    end
end)

-- ==============================================================================
-- [6] FUNGSI BANTUAN UMUM & KAPASITAS TAS ASLI (DARI SCRIPT KERJA)
-- ==============================================================================
local function isHeldBySomeone(obj)
    local success, result = pcall(function()
        local parent = obj.Parent
        while parent and parent ~= Workspace do
            if parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                return true
            end
            parent = parent.Parent
        end
        return false
    end)
    return success and result or false
end

local function getNearestScrap(currentPos, scrapList)
    local nearest, minDist, nearestIdx = nil, math.huge, nil
    pcall(function()
        for i, obj in ipairs(scrapList) do
            if obj and obj.Parent then
                local targetPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local dist = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(currentPos.X, 0, currentPos.Z)).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                    nearestIdx = i
                end
            end
        end
    end)
    return nearest, nearestIdx
end

local function fireCollectEvents(obj, hrp)
    pcall(function()
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt and obj.Parent then
            prompt = obj.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
        if prompt then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end

        local touch = obj:FindFirstChild("TouchInterest")
        if not touch and obj.Parent then
            touch = obj.Parent:FindFirstChild("TouchInterest")
        end

        if touch and firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, obj, 0)
                task.wait(0.01)
                firetouchinterest(hrp, obj, 1)
            end)
        end
    end)
end

local function getCurrentFloor()
    local success, result = pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local tower = ls:FindFirstChild("Tower")
            if tower and tower:IsA("ValueBase") then
                local val = tonumber(tower.Value)
                return val or 0
            end
        end
        return 0
    end)
    return (success and type(result) == "number") and result or 0
end

local function getRealBackpackCount(char)
    local count = 0
    pcall(function()
        local directScrap = player:GetAttribute("scrapCarry")
        if type(directScrap) == "number" then
            count = directScrap
            return
        end

        for attr, val in pairs(player:GetAttributes()) do
            if type(val) == "number" and (attr:lower():find("carry") or attr:lower():find("scrap") or attr:lower():find("coin")) then
                count = count + val
            end
        end
        if char then
            local physicalCount = 0
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    if obj:GetAttribute("StackKind") or obj:GetAttribute("CarryAttr") then
                        physicalCount = physicalCount + 1
                    end
                end
            end
            if physicalCount > count then
                count = physicalCount
            end
        end
    end)
    return count
end

-- ==============================================================================
-- [7] PENGECEKAN STATUS LENGKAP AYAM (HP & KO)
-- ==============================================================================
local function getChickenStatus()
    local status = {
        HpFrac = 1,
        IsAlive = true,
        IsFull = false,
        InBattle = false
    }
    pcall(function()
        local chickenFolder = Workspace:FindFirstChild("ChickenBodies")
        if not chickenFolder then
            return
        end

        local myChicken = nil
        for _, c in ipairs(chickenFolder:GetChildren()) do
            local ownerId = c:GetAttribute("ovOwner")
            if ownerId and tonumber(ownerId) == player.UserId then
                myChicken = c
                break
            end
        end

        if not myChicken then
            for _, c in ipairs(chickenFolder:GetChildren()) do
                local ownerAttr = c:GetAttribute("Owner") or c:GetAttribute("owner")
                if ownerAttr and string.lower(tostring(ownerAttr)) == string.lower(player.Name) then
                    myChicken = c
                    break
                end
            end
        end

        if not myChicken then
            myChicken = chickenFolder:FindFirstChild("ChickenBody_coop:1")
        end

        if myChicken then
            local ovLife = myChicken:GetAttribute("ovLife")
            if type(ovLife) == "boolean" then
                status.IsAlive = ovLife
            end

            local hpFrac = myChicken:GetAttribute("ovHpFrac")
            if type(hpFrac) == "number" then
                status.HpFrac = hpFrac
                status.IsFull = (hpFrac >= 0.99)
            end

            local ovState = myChicken:GetAttribute("ovState")
            if ovState and tostring(ovState):lower() == "battle" then
                status.InBattle = true
            end
        end
    end)
    return status
end

local function isChickenHpFull()
    return getChickenStatus().IsFull
end

-- ==============================================================================
-- [8] SCANNER STATISTIK SURPLUS (ISOLASI PLOT)
-- ==============================================================================
local function getSurplusStats()
    local stats = {
        Coop = 1,
        FeederCount = 0,
        FeederLevel = 0,
        Feeders = {},
        ChickenLevel = 0,
        TowerFloor = 0,
        RecyclerLevel = 0
    }

    local success, err = pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            if ls:FindFirstChild("Level") then
                local matchStr = string.match(tostring(ls.Level.Value), "%d+")
                local parsedLvl = matchStr and tonumber(matchStr)
                if parsedLvl then
                    stats.ChickenLevel = parsedLvl
                end
            end
            if ls:FindFirstChild("Tower") then
                local parsedTower = tonumber(ls.Tower.Value)
                if parsedTower then
                    stats.TowerFloor = parsedTower
                end
            end
        end

        local plotIdAttr = player:GetAttribute("Plot")
        local plotId = (type(plotIdAttr) == "number" and plotIdAttr) or 1
        local coopName = "Coop" .. tostring(plotId)

        local coopsFolder = Workspace:FindFirstChild("Coops")
        local myCoop = coopsFolder and coopsFolder:FindFirstChild(coopName)

        if myCoop then
            local recLvl = myCoop:GetAttribute("PV_Recycler")
            local parsedRecLvl = recLvl and tonumber(recLvl)
            if parsedRecLvl then
                stats.RecyclerLevel = parsedRecLvl
            end

            local pvSlots = myCoop:GetAttribute("PV_Slots")
            local parsedPvSlots = pvSlots and tonumber(pvSlots)
            if parsedPvSlots then
                stats.Coop = math.max(1, parsedPvSlots - 1)
            end

            local feedersAttr = myCoop:GetAttribute("PV_Feeders")
            if feedersAttr and type(feedersAttr) == "string" then
                local fCount = 0
                for entry in string.gmatch(feedersAttr, "[^|]+") do
                    local slotStr, lvlStr = string.match(entry, "(%d+):(%d+)")
                    if slotStr and lvlStr then
                        local sId = tonumber(slotStr)
                        local sLvl = tonumber(lvlStr)
                        if sId and sLvl then
                            stats.Feeders[sId] = sLvl
                            fCount = fCount + 1
                        end
                    end
                end
                stats.FeederCount = fCount

                local minLvl = math.huge
                for id = 1, surplusTargetFeederCount do
                    local curLvl = stats.Feeders[id] or 0
                    if curLvl < minLvl then
                        minLvl = curLvl
                    end
                end
                stats.FeederLevel = (minLvl ~= math.huge and minLvl) or 0
            end

            for _, desc in ipairs(myCoop:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Name == "name" then
                    local txt = desc.Text or desc.ContentText or ""
                    if txt:find("COOP") then
                        local matchLvl = string.match(txt, "Lv%.%s*(%d+)")
                        local num = matchLvl and tonumber(matchLvl)
                        if num then
                            stats.Coop = num
                        end
                    end
                end
            end
        end

        local recyclersFolder = Workspace:FindFirstChild("Recyclers")
        if recyclersFolder then
            local myRecyclerModel = recyclersFolder:FindFirstChild("Recycler" .. tostring(plotId))
            if myRecyclerModel then
                for _, desc in ipairs(myRecyclerModel:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Name == "name" then
                        local txt = desc.Text or desc.ContentText or ""
                        if txt:find("RECYCLER") then
                            local matchLvl = string.match(txt, "Lv%.%s*(%d+)")
                            local num = matchLvl and tonumber(matchLvl)
                            if num then
                                stats.RecyclerLevel = num
                            end
                        end
                    end
                end
            end
        end
    end)

    if not success then
        logError("getSurplusStats", err)
    end
    return stats
end

-- ==============================================================================
-- [9] PENCARIAN RECYCLER KHUSUS PEMAIN (DARI SCRIPT KERJA)
-- ==============================================================================
local function findMyRecycler()
    local success, result = pcall(function()
        local plotIdAttr = player:GetAttribute("Plot")
        local plotId = (type(plotIdAttr) == "number" and plotIdAttr) or 1
        local recyclersFolder = Workspace:FindFirstChild("Recyclers")

        if recyclersFolder then
            local myRec = recyclersFolder:FindFirstChild("Recycler" .. tostring(plotId))
            if myRec then
                local prompt = myRec:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                    return prompt.Parent
                end
                local touch = myRec:FindFirstChild("TouchInterest", true)
                if touch and touch.Parent and touch.Parent:IsA("BasePart") then
                    return touch.Parent
                end
                if myRec:IsA("BasePart") then
                    return myRec
                end
                if myRec:IsA("Model") then
                    return myRec.PrimaryPart or myRec:FindFirstChildWhichIsA("BasePart", true) or myRec
                end
            end
        end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return nil
        end
        local closestRecycler, minDist = nil, math.huge

        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name:lower():find("recycler") then
                local dist = (desc.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestRecycler = desc
                end
            end
        end
        return closestRecycler
    end)
    return success and result or nil
end

-- ==============================================================================
-- [10] SISTEM NOCLIP & MOVEMENT (DARI SCRIPT KERJA)
-- ==============================================================================
local noclipConnection = nil
local function enableNoclip()
    if noclipConnection then
        return
    end
    pcall(function()
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

local function disableNoclip()
    if noclipConnection then
        pcall(function()
            noclipConnection:Disconnect()
            noclipConnection = nil
        end)
    end
end

local function safeWalkTo(targetPos, stopDistance, checkCapacity)
    stopDistance = tonumber(stopDistance) or 3
    local char = player.Character
    if not char then
        return "ERROR"
    end
    local humanoid, hrp = char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then
        return "ERROR"
    end

    enableNoclip()
    pcall(function()
        humanoid:MoveTo(targetPos)
    end)

    local initialDist = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
    local maxWait = math.clamp(initialDist / 8, 8, 25)
    local timeout = 0
    local lastPos = hrp.Position
    local stuckTimer = 0

    while timeout < maxWait do
        if not autoSweep and not (autoRebirthSurplus and surplusAllTargetsMet) then
            break
        end

        local okLoop, resLoop = pcall(function()
            local currentPos = hrp.Position
            local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist <= stopDistance then
                return "STOP"
            end

            if checkCapacity and getRealBackpackCount(char) >= MAX_CAPACITY then
                disableNoclip()
                return "FULL"
            end

            stuckTimer = stuckTimer + 0.1
            if stuckTimer >= 0.5 then
                local moveDist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPos.X, 0, lastPos.Z)).Magnitude
                if moveDist < 1 then
                    local direction = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
                    hrp.CFrame = hrp.CFrame + (direction * 4)
                    humanoid:MoveTo(targetPos)
                end
                lastPos = currentPos
                stuckTimer = 0
            end
            return "CONTINUE"
        end)

        if not okLoop or resLoop == "STOP" then
            break
        elseif resLoop == "FULL" then
            disableNoclip()
            return "FULL"
        end

        timeout = timeout + task.wait(0.1)
    end

    disableNoclip()

    local finalDist = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
    if finalDist <= stopDistance + 3 then
        return "ARRIVED"
    else
        return "TIMEOUT"
    end
end

-- ==============================================================================
-- [11] VISUAL ESP ENGINE (PLAYER, EGG, SCRAP)
-- ==============================================================================
local function cleanESP(tag)
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == tag then
            desc:Destroy()
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, desc in ipairs(p.Character:GetDescendants()) do
                if desc.Name == tag then
                    desc:Destroy()
                end
            end
        end
    end
end

local function createESPBillboard(parent, text, color, offset, tag)
    local existing = parent:FindFirstChild(tag)
    if existing then
        local label = existing:FindFirstChildWhichIsA("TextLabel")
        if label then
            label.Text = text
        end
        return
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = tag
    bb.Adornee = parent
    bb.Size = UDim2.new(0, 160, 0, 35)
    bb.StudsOffset = offset or Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 500

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 13
    tl.Parent = bb

    bb.Parent = parent
end

local function createESPHighlight(parent, fillColor, outlineColor, tag)
    local existing = parent:FindFirstChild(tag)
    if existing and existing:IsA("Highlight") then
        return
    end

    local hl = Instance.new("Highlight")
    hl.Name = tag
    hl.Adornee = parent
    hl.FillColor = fillColor or Color3.fromRGB(0, 255, 120)
    hl.OutlineColor = outlineColor or Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = parent
end

-- ==============================================================================
-- [12] SCANNER FLOCK & FITUR AYAM (PROMOTE, FUSE, FAVORIT, SELL, NEST EGGS)
-- ==============================================================================
local function collectMyNestEggs(isManual)
    local collectedCount = 0
    pcall(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local nestFolder = Workspace:FindFirstChild("NestEggs")
        if nestFolder and hrp then
            for _, egg in ipairs(nestFolder:GetChildren()) do
                if egg:IsA("BasePart") or egg:IsA("Model") then
                    local owner = egg:GetAttribute("owner")
                    if owner and tonumber(owner) == player.UserId then
                        local targetPart = egg:IsA("BasePart") and egg or (egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart)
                        if targetPart and firetouchinterest then
                            firetouchinterest(hrp, targetPart, 0)
                            task.wait(0.02)
                            firetouchinterest(hrp, targetPart, 1)
                            collectedCount = collectedCount + 1
                        end
                        local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                    end
                end
            end
        end
    end)
    return collectedCount
end

local scanFlockChickens = nil

local OFFICIAL_PROMOTE_REQUIREMENTS = {
    ["common"] = {
        [1] = 5, [2] = 10, [3] = 15, [4] = 25, [5] = 40,
        [6] = 60, [7] = 90, [8] = 120, [9] = 160, [10] = 220
    },
    ["uncommon"] = {
        [1] = 4, [2] = 8, [3] = 12, [4] = 20, [5] = 30,
        [6] = 45, [7] = 65, [8] = 90, [9] = 125, [10] = 170
    },
    ["rare"] = {
        [1] = 3, [2] = 5, [3] = 8, [4] = 12, [5] = 20,
        [6] = 30, [7] = 45, [8] = 65, [9] = 95, [10] = 130
    },
    ["epic"] = {
        [1] = 2, [2] = 4, [3] = 6, [4] = 8, [5] = 20,
        [6] = 25, [7] = 35, [8] = 50, [9] = 75, [10] = 100
    },
    ["legendary"] = {
        [1] = 2, [2] = 3, [3] = 5, [4] = 10, [5] = 15,
        [6] = 20, [7] = 30, [8] = 40, [9] = 55, [10] = 75
    },
    ["mythic"] = {
        [1] = 1, [2] = 2, [3] = 3, [4] = 5, [5] = 8,
        [6] = 12, [7] = 20, [8] = 30, [9] = 40, [10] = 55
    },
    ["divine"] = {
        [1] = 1, [2] = 2, [3] = 3, [4] = 5, [5] = 8,
        [6] = 12, [7] = 18, [8] = 25, [9] = 35, [10] = 50
    },
    ["celestial"] = {
        [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 6,
        [6] = 10, [7] = 15, [8] = 20, [9] = 30, [10] = 40
    },
    ["cosmic"] = {
        [1] = 1, [2] = 1, [3] = 2, [4] = 3, [5] = 5,
        [6] = 8, [7] = 12, [8] = 18, [9] = 25, [10] = 35
    },
    ["secret"] = {
        [1] = 1, [2] = 1, [3] = 2, [4] = 2, [5] = 3,
        [6] = 5, [7] = 7, [8] = 10, [9] = 14, [10] = 20
    }
}

local function getRequiredFodders(rarity, currentStars)
    local cur = currentStars or 0
    local nextStar = cur + 1
    if nextStar > 10 then
        nextStar = 10
    end

    -- 1. Panggil langsung fungsi resmi PromotionView dari game jika tersedia
    local dynamicReq = nil
    pcall(function()
        local featChicken = ReplicatedStorage:FindFirstChild("Features") and ReplicatedStorage.Features:FindFirstChild("Chicken")
        local viewMod = featChicken and featChicken:FindFirstChild("PromotionView")
        if viewMod then
            local PromotionView = require(viewMod)
            if PromotionView and PromotionView.requirement then
                local rName = tostring(rarity or "common"):lower()
                local res = PromotionView.requirement(rName, nextStar)
                if type(res) == "number" and res > 0 then
                    dynamicReq = res
                end
            end
        end
    end)
    if dynamicReq then
        return dynamicReq, nextStar
    end

    -- 2. Fallback menggunakan tabel resmi hasil ekstraksi data game
    local rLower = tostring(rarity or "common"):lower()
    local rTable = OFFICIAL_PROMOTE_REQUIREMENTS[rLower] or OFFICIAL_PROMOTE_REQUIREMENTS["common"]
    local req = rTable[nextStar] or rTable[#rTable] or 5
    return req, nextStar
end

local function scanGamePromoteData()
    local results = {}
    local function logLine(s)
        table.insert(results, s)
        print(s)
    end
    logLine("==================================================================")
    logLine("  SYSHUB: SCANNER PERSYARATAN PROMOTE & RARITY ASLI DARI GAME     ")
    logLine("==================================================================")
    logLine("Waktu: " .. os.date("%Y-%m-%d %H:%M:%S"))
    logLine("Player: " .. player.Name)
    logLine("")

    -- 1. Scan ModuleScripts di ReplicatedStorage & PlayerScripts
    local keywords = {"promote", "sacrifice", "chicken", "flock", "rarit", "fuse", "require", "tuning", "config", "setting", "tier", "grade", "star"}
    local candidateModules = {}
    for _, root in ipairs({ReplicatedStorage, player:FindFirstChild("PlayerScripts"), game:GetService("StarterPlayer")}) do
        if root then
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("ModuleScript") then
                    local dName = desc.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if dName:find(kw) then
                            table.insert(candidateModules, desc)
                            break
                        end
                    end
                end
            end
        end
    end

    logLine(string.format("Memeriksa %d ModuleScript yang relevan...", #candidateModules))
    for _, mod in ipairs(candidateModules) do
        pcall(function()
            local res = require(mod)
            if type(res) == "table" then
                local hasMatch = false
                for k, v in pairs(res) do
                    local kStr = tostring(k):lower()
                    if kStr:find("promote") or kStr:find("sacrifice") or kStr:find("requirement") or kStr:find("common") or kStr:find("legendary") or kStr:find("rarit") or kStr:find("star") then
                        hasMatch = true
                        break
                    end
                end
                if hasMatch then
                    logLine("\n[MODUL TERKAIT]: " .. mod:GetFullName())
                    for k, v in pairs(res) do
                        if type(v) == "table" then
                            logLine("  [" .. tostring(k) .. "] = {")
                            local c = 0
                            for subK, subV in pairs(v) do
                                c = c + 1
                                if c > 30 then
                                    logLine("    ... (dipotong)")
                                    break
                                end
                                logLine("    [" .. tostring(subK) .. "] = " .. tostring(subV) .. " (" .. typeof(subV) .. ")")
                            end
                            logLine("  }")
                        else
                            logLine("  [" .. tostring(k) .. "] = " .. tostring(v) .. " (" .. typeof(v) .. ")")
                        end
                    end
                end
            end
        end)
    end

    -- 2. Scan UI TextLabels
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            local dName = desc.Name:lower()
            if dName:find("sacrifice") or dName:find("promote") or dName:find("requirement") then
                if desc:IsA("TextLabel") and desc.Text and #desc.Text > 0 then
                    logLine(string.format("UI Text [%s]: \"%s\"", desc:GetFullName(), desc.Text))
                end
                local attrs = desc:GetAttributes()
                for k, v in pairs(attrs) do
                    logLine(string.format("UI Attr [%s].[%s] = %s", desc.Name, tostring(k), tostring(v)))
                end
            end
        end
    end

    local fullText = table.concat(results, "\n")
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(fullText)
            copied = true
        elseif toclipboard then
            toclipboard(fullText)
            copied = true
        end
    end)
    pcall(function()
        if writefile then
            writefile("promote_data.txt", fullText)
        end
    end)
    return copied, fullText
end

local KNOWN_SPECIES_RARITY = {
    ["CLASSIC ROOSTER"] = "Common",
    ["FARMER ROOSTER"] = "Common",
    ["SCRATCH HEN"] = "Common",
    ["BARN ROOSTER"] = "Common",
    ["BROWN HEN"] = "Common",
    ["WHITE HEN"] = "Common",
    ["CHICKEN"] = "Common",
    ["ROOSTER"] = "Common",
    ["FARMED ROOSTER"] = "Uncommon",
    ["SPOTTED ROOSTER"] = "Uncommon",
    ["GREEN ROOSTER"] = "Uncommon",
    ["FOREST CHICKEN"] = "Uncommon",
    ["DESERT ROOSTER"] = "Uncommon",
    ["404 CHICK"] = "Rare",
    ["PIRATE ROOSTER"] = "Rare",
    ["GOLDEN GOOSE"] = "Legendary",
    ["GOOSE"] = "Legendary",
    ["FOUNDER ROOSTER"] = "Legendary",
    ["FOUNDER"] = "Legendary",
    ["SOVEREIGN ROOSTER"] = "Legendary",
    ["DEVIL CHICKEN"] = "Mythic",
    ["ANGEL CHICKEN"] = "Divine",
    ["NEBULA HEN"] = "Celestial",
    ["COSMIC ROOSTER"] = "Cosmic",
    ["STORM COLOSSUS"] = "Secret",
    ["COLOSSUS"] = "Secret",
    ["JONTOR"] = "Secret",
}

local function evaluateColorRarity(col)
    if not col then
        return nil
    end
    -- Abaikan warna putih terang, abu-abu netral, dan hitam pekat
    if (col.R > 0.95 and col.G > 0.95 and col.B > 0.95) or (col.R < 0.12 and col.G < 0.12 and col.B < 0.12) then
        return nil
    end

    -- 1. Legendary: Emas / Kuning Oranye (R tinggi, G sedang-tinggi, B rendah)
    -- Contoh Founder Rooster latar kartu emas: R ≈ 0.7-0.95, G ≈ 0.45-0.75, B < 0.35
    if col.R > 0.6 and col.G > 0.38 and col.B < 0.35 and (col.R > col.B * 1.8) then
        return "Legendary"
    -- 2. Epic: Ungu / Magenta (R tinggi, B tinggi, G rendah)
    elseif col.R > 0.35 and col.B > 0.35 and col.G < 0.3 and (col.R > col.G * 1.3 or col.B > col.G * 1.3) then
        return "Epic"
    -- 3. Rare: Biru (B tinggi, B > R, B > G)
    elseif col.B > 0.4 and col.B > col.R * 1.25 and col.B > col.G * 1.1 then
        return "Rare"
    -- 4. Uncommon: Hijau (G tinggi, G > R, G > B)
    elseif col.G > 0.35 and col.G > col.R * 1.25 and col.G > col.B * 1.25 then
        return "Uncommon"
    -- 5. Mythic: Merah Pekat (R tinggi, G & B sangat rendah)
    elseif col.R > 0.6 and col.G < 0.3 and col.B < 0.3 then
        return "Mythic"
    end
    return nil
end

local catalogPreloaded = false
local function preloadGameChickenCatalog()
    if catalogPreloaded then
        return
    end
    catalogPreloaded = true
    pcall(function()
        local contentFolder = ReplicatedStorage:FindFirstChild("Content")
        local catMod = contentFolder and contentFolder:FindFirstChild("Catalog")
        if catMod then
            local cat = require(catMod)
            if type(cat) == "table" then
                for _, section in pairs(cat) do
                    if type(section) == "table" then
                        for id, item in pairs(section) do
                            if type(item) == "table" then
                                local r = item.rarity or item.Rarity or item.tier or item.Tier
                                local n = item.name or item.Name or (type(id) == "string" and id)
                                if r and n and type(r) == "string" and type(n) == "string" then
                                    local properR = r:sub(1,1):upper() .. r:sub(2):lower()
                                    KNOWN_SPECIES_RARITY[n:upper()] = properR
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    pcall(function()
        local featChicken = ReplicatedStorage:FindFirstChild("Features") and ReplicatedStorage.Features:FindFirstChild("Chicken")
        if featChicken then
            for _, mod in ipairs(featChicken:GetDescendants()) do
                if mod:IsA("ModuleScript") and mod.Name ~= "PromotionView" and mod.Name ~= "FusionRules" then
                    pcall(function()
                        local data = require(mod)
                        if type(data) == "table" then
                            for id, item in pairs(data) do
                                if type(item) == "table" then
                                    local r = item.rarity or item.Rarity or item.tier or item.Tier
                                    local n = item.name or item.Name or (type(id) == "string" and id)
                                    if r and n and type(r) == "string" and type(n) == "string" then
                                        local properR = r:sub(1,1):upper() .. r:sub(2):lower()
                                        KNOWN_SPECIES_RARITY[n:upper()] = properR
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
end

local function detectChickenRarity(frame, chickenName)
    preloadGameChickenCatalog()
    local upName = chickenName and chickenName:upper():gsub("^%s*(.-)%s*$", "%1")

    -- 1. Cek dari kamus spesies yang sudah terverifikasi
    if upName then
        if KNOWN_SPECIES_RARITY[upName] then
            return KNOWN_SPECIES_RARITY[upName]
        end
        for k, r in pairs(KNOWN_SPECIES_RARITY) do
            if upName:find(k) then
                return r
            end
        end
    end

    -- 2. Cek teks label resmi panel game (format: "SPECIES • RARITY • LVL X")
    local pgui = player:FindFirstChild("PlayerGui")
    if pgui and upName then
        for _, tl in ipairs(pgui:GetDescendants()) do
            if tl:IsA("TextLabel") and tl.Text and tl.Text:find("•") then
                local upText = tl.Text:upper()
                if upText:find(upName) then
                    for _, rCheck in ipairs({"SECRET", "COSMIC", "CELESTIAL", "DIVINE", "MYTHIC", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}) do
                        if upText:find(rCheck) then
                            local properR = rCheck:sub(1,1):upper() .. rCheck:sub(2):lower()
                            KNOWN_SPECIES_RARITY[upName] = properR
                            return properR
                        end
                    end
                end
            end
        end
    end

    if not frame then
        return "Unknown"
    end

    -- 3. Cek atribut pada frame
    for _, attrName in ipairs({"rarity", "Rarity", "tier", "Tier", "grade", "Grade"}) do
        local val = frame:GetAttribute(attrName)
        if val and type(val) == "string" then
            local vLower = val:lower()
            if vLower:find("secret") then
                return "Secret"
            elseif vLower:find("cosmic") then
                return "Cosmic"
            elseif vLower:find("celestial") then
                return "Celestial"
            elseif vLower:find("divine") then
                return "Divine"
            elseif vLower:find("mythic") then
                return "Mythic"
            elseif vLower:find("legend") then
                return "Legendary"
            elseif vLower:find("epic") then
                return "Epic"
            elseif vLower:find("rare") then
                return "Rare"
            elseif vLower:find("uncommon") then
                return "Uncommon"
            elseif vLower:find("common") then
                return "Common"
            end
        end
    end

    -- 4. Cek teks label di dalam kartu
    for _, child in ipairs(frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            local txt = (child.Text or ""):lower():gsub("^%s*(.-)%s*$", "%1")
            if txt == "secret" then
                return "Secret"
            elseif txt == "cosmic" then
                return "Cosmic"
            elseif txt == "celestial" then
                return "Celestial"
            elseif txt == "divine" then
                return "Divine"
            elseif txt == "mythic" then
                return "Mythic"
            elseif txt == "legendary" then
                return "Legendary"
            elseif txt == "epic" then
                return "Epic"
            elseif txt == "rare" then
                return "Rare"
            elseif txt == "uncommon" then
                return "Uncommon"
            elseif txt == "common" then
                return "Common"
            end
        end
    end

    -- 5. Deteksi Warna Visual Kartu (UIGradient, ImageColor3, BackgroundColor3)
    for _, child in ipairs(frame:GetDescendants()) do
        if child:IsA("UIGradient") then
            local keypoints = child.Color and child.Color.Keypoints
            if keypoints and #keypoints > 0 then
                for _, kp in ipairs(keypoints) do
                    local r = evaluateColorRarity(kp.Value)
                    if r then
                        if upName then
                            KNOWN_SPECIES_RARITY[upName] = r
                        end
                        return r
                    end
                end
            end
        end

        if (child:IsA("ImageLabel") or child:IsA("ImageButton")) and child.Visible ~= false then
            local trans = child.ImageTransparency or 0
            if trans < 0.75 then
                local r = evaluateColorRarity(child.ImageColor3)
                if r then
                    if upName then
                        KNOWN_SPECIES_RARITY[upName] = r
                    end
                    return r
                end
            end
        end

        if child:IsA("GuiObject") and child.Visible ~= false then
            local trans = child.BackgroundTransparency or 0
            if trans < 0.75 then
                local r = evaluateColorRarity(child.BackgroundColor3)
                if r then
                    if upName then
                        KNOWN_SPECIES_RARITY[upName] = r
                    end
                    return r
                end
            end
        end
    end

    local fName = frame.Name:upper()
    if KNOWN_SPECIES_RARITY[fName] then
        return KNOWN_SPECIES_RARITY[fName]
    end

    return "Unknown"
end

local function getChickenStarCount(frame, cId, numId)
    if not frame then
        return 0
    end
    local stars = 0

    -- 1. Cek PromotionView.stars jika tersedia secara internal di game
    pcall(function()
        local featChicken = ReplicatedStorage:FindFirstChild("Features") and ReplicatedStorage.Features:FindFirstChild("Chicken")
        local viewMod = featChicken and featChicken:FindFirstChild("PromotionView")
        if viewMod then
            local PromotionView = require(viewMod)
            if PromotionView and type(PromotionView.stars) == "function" then
                local s = PromotionView.stars(frame) or (numId and PromotionView.stars(numId)) or (cId and PromotionView.stars(cId))
                if type(s) == "number" and s > 0 and s <= 10 then
                    stars = math.max(stars, s)
                end
            end
        end
    end)

    -- 2. Cek atribut angka pada frame kartu dan wadah bintang
    for _, obj in ipairs({frame, frame:FindFirstChild("Stars"), frame:FindFirstChild("Content")}) do
        if obj then
            for _, attr in ipairs({"Star", "Stars", "star", "stars", "Promotion", "Promotions", "Rank", "StarCount"}) do
                local val = obj:GetAttribute(attr)
                if val ~= nil and type(val) == "number" and val > 0 and val <= 10 then
                    stars = math.max(stars, val)
                end
            end
        end
    end

    -- 3. Hitung jumlah bintang visual yang menyala aktif pada kartu
    local visualStars = 0
    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
            local dName = desc.Name:lower()
            local pName = desc.Parent and desc.Parent.Name:lower() or ""
            local img = tostring(desc.Image or ""):lower()
            local isStarAsset = (dName:find("star") or pName:find("star") or img:find("85144809432918") or img:find("129382203646873"))

            if isStarAsset and desc.Visible ~= false then
                local trans = desc.ImageTransparency or 0
                local col = desc.ImageColor3
                if trans < 0.6 and col then
                    -- Bintang kosong selalu GELAP PEKAT / HITAM (brightness < 0.28)
                    -- Bintang aktif (emas / kuning / putih / ungu) selalu TERANG (brightness >= 0.28)
                    local brightness = (col.R + col.G + col.B) / 3
                    local isDarkBlack = (col.R < 0.28 and col.G < 0.28 and col.B < 0.28)

                    if not isDarkBlack and brightness >= 0.28 then
                        visualStars = visualStars + 1
                    end
                end
            end
        end

        if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
            local txt = desc.Text
            local count = 0
            for _ in txt:gmatch("★") do
                count = count + 1
            end
            for _ in txt:gmatch("⭐") do
                count = count + 1
            end
            if count > visualStars then
                visualStars = count
            end
        end
    end

    if visualStars > stars then
        stars = visualStars
    end

    return stars
end

local function isChickenPromoted(frame, cId, numId)
    if cId and promotedChickenIds[cId] then
        return true
    end
    if numId and promotedChickenIds[numId] then
        return true
    end
    return getChickenStarCount(frame, cId, numId) > 0
end

local function executeSellChickens(isManual)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        return 0
    end
    local toSellList = {}

    for _, desc in ipairs(playerGui:GetDescendants()) do
        local matchNum = string.match(desc.Name, "^c(%d+)$")
        if matchNum and (desc:IsA("Frame") or desc:IsA("GuiObject") or desc:IsA("TextButton")) then
            local cId = desc.Name
            local numId = tonumber(matchNum)

            -- Ambil nama ayam dari kartu
            local cName = nil
            for _, child in ipairs(desc:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                    local t = child.Text:gsub("^%s*(.-)%s*$", "%1")
                    local tl = t:lower()
                    if not tl:find("lvl") and not tl:find("lv") and not tl:find("^x%d+") and not tl:find("%$") and not tl:find("^%+") and #t > 1 and tl ~= "chicken name" then
                        cName = t
                        break
                    end
                end
            end

            -- SISTEM KEAMANAN & PROTEKSI:
            local isFav = favoritedChickenIds[cId] or (numId and favoritedChickenIds[numId]) or desc:GetAttribute("Favorite") == true or desc:FindFirstChild("Favorite")
            local isPromoted = isChickenPromoted(desc, cId, numId)

            -- Hanya proses ayam yang BUKAN Favorit dan BUKAN Promoted
            if not isFav and not isPromoted then
                local rarity = detectChickenRarity(desc, cName)
                -- HANYA JUAL JIKA RARITY TERKONFIRMASI PASTI (BUKAN Unknown) DAN COCOK DENGAN FILTER
                if rarity and rarity ~= "Unknown" and selectedSellRarities[rarity] == true then
                    table.insert(toSellList, {
                        idStr = cId,
                        idNum = numId,
                        name = cName or cId,
                        rarity = rarity
                    })
                end
            end
        end
    end

    local soldCount = 0
    if #toSellList > 0 then
        -- Jual secara bulk (SellChickens)
        local allStrIds = {}
        local allNumIds = {}
        for _, item in ipairs(toSellList) do
            table.insert(allStrIds, item.idStr)
            if item.idNum then
                table.insert(allNumIds, item.idNum)
            end
        end

        pcall(function()
            invokeRemote("SellChickens", allStrIds)
        end)
        pcall(function()
            if #allNumIds > 0 then
                invokeRemote("SellChickens", allNumIds)
            end
        end)

        -- Juga panggil SellChicken per individu untuk memastikan server memproses
        for _, item in ipairs(toSellList) do
            if not autoSellChickens and not isManual then
                break
            end
            pcall(function()
                invokeRemote("SellChicken", item.idStr)
            end)
            pcall(function()
                if item.idNum then
                    invokeRemote("SellChicken", item.idNum)
                end
            end)
            soldCount = soldCount + 1
            if delaySellChicken > 0 then
                task.wait(delaySellChicken)
            end
        end

        task.wait(0.5)
        scanFlockChickens()
    end
    return soldCount
end

local function extractChickenSkill(frame)
    if not frame then
        return nil
    end
    for _, attr in ipairs({"Skill", "skill", "Ability", "ability", "Special", "special"}) do
        local val = frame:GetAttribute(attr)
        if val and type(val) == "string" and val ~= "" then
            return val:gsub("^%s*(.-)%s*$", "%1")
        end
    end
    for _, child in ipairs(frame:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
            local raw = child.Text:gsub("^%s*(.-)%s*$", "%1")
            local lower = raw:lower()
            if child.Name:lower():find("skill") or child.Name:lower():find("ability") then
                local clean = raw:gsub("^[Ss][Kk][Ii][Ll][Ll]%s*:?%s*", "")
                if clean ~= "" and clean:lower() ~= "skill" and #clean > 2 then
                    return clean
                end
            end
            if lower:find("^skill%s*:") or lower:find("^ability%s*:") then
                local clean = raw:gsub("^[Ss][Kk][Ii][Ll][Ll]%s*:?%s*", ""):gsub("^[Aa][Bb][Ii][Ll][Ii][Tt][Yy]%s*:?%s*", "")
                if clean ~= "" and #clean > 2 then
                    return clean
                end
            end
        end
    end
    return nil
end

local function getSkillFromInspector()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        return nil
    end
    for _, lbl in ipairs(playerGui:GetDescendants()) do
        if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" then
            local raw = lbl.Text:gsub("^%s*(.-)%s*$", "%1")
            local lower = raw:lower()
            if lbl.Name:lower() == "skill" or lbl.Name:lower() == "skillname" or lower:find("^skill%s*:") then
                local s = raw:gsub("^[Ss][Kk][Ii][Ll][Ll]%s*:?%s*", "")
                if s ~= "" and s:lower() ~= "skill" and #s > 2 then
                    return s
                end
            end
        end
    end
    return nil
end

local updateAvailableSkills = nil
local updatePromoteFodders = nil

local cachedDataServiceClient = nil
local function getSharedDataServiceClient()
    if cachedDataServiceClient then
        return cachedDataServiceClient
    end
    pcall(function()
        local dsMod = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("DataService")
        if dsMod then
            local ok, ds = pcall(function() return require(dsMod) end)
            if ok and ds and type(ds) == "table" and ds.client then
                cachedDataServiceClient = ds.client
            end
        end
    end)
    return cachedDataServiceClient
end

local CHICKEN_NAME_BY_TYPE_ID = {
    ["ace_rooster"] = "Ace Rooster",
    ["agent_cluck"] = "Agent Cluck",
    ["alien_chick"] = "Alien Chick",
    ["angel_chicken"] = "Angel Chicken",
    ["astro_chick"] = "Astro Chick",
    ["aurora_hen"] = "Aurora Hen",
    ["ballet_hen"] = "Ballet Hen",
    ["banner_hen"] = "Banner Hen",
    ["barcelos"] = "Barcelos",
    ["barista_hen"] = "Barista Hen",
    ["baron"] = "Baron Cluck",
    ["basilisk"] = "Basilisk Rooster",
    ["beacon_rooster"] = "Beacon Rooster",
    ["beast_rooster"] = "Beast Rooster",
    ["blitz_rooster"] = "Blitz Rooster",
    ["boba_hen"] = "Boba Hen",
    ["bombardier"] = "Bombardier Rooster",
    ["bone_rooster"] = "Bone Rooster",
    ["bonk_hen"] = "Bonk Hen",
    ["boom_rooster"] = "Boom Rooster",
    ["bow_chick"] = "Bow Chick",
    ["boxer_hen"] = "Southpaw Hen",
    ["bravo_rooster"] = "Bravo Rooster",
    ["bucket_rooster"] = "Bucket Rooster",
    ["bulwark_hen"] = "Bulwark Hen",
    ["bunker_hen"] = "Bunker Hen",
    ["butterfly_hen"] = "Butterfly Hen",
    ["caddie_rooster"] = "Caddie Rooster",
    ["capoeira"] = "Capoeira Rooster",
    ["catalyst_hen"] = "Catalyst Hen",
    ["chameleon_hen"] = "Chameleon Hen",
    ["champ_rooster"] = "Belt Champion",
    ["checkmate_hen"] = "Checkmate Hen",
    ["cheer_chick"] = "Cheer Chick",
    ["chef_rooster"] = "Chef Rooster",
    ["classic"] = "Classic Rooster",
    ["clown_chick"] = "Clown Chick",
    ["cockatrice"] = "Cockatrice",
    ["comet_rooster"] = "Comet Rooster",
    ["commando_rooster"] = "Commando Rooster",
    ["cosmo_brat"] = "Cosmo Brat",
    ["crest_rooster"] = "Crest Rooster",
    ["crusader"] = "Bulwark Knight",
    ["crystal_hen"] = "Crystal Hen",
    ["cupcake_chick"] = "Cupcake Chick",
    ["deepfried_hen"] = "Deep Fried Hen",
    ["devil_chicken"] = "Devil Chicken",
    ["dj_rooster"] = "DJ Rooster",
    ["doll_hen"] = "Doll Hen",
    ["domino_chick"] = "Domino Chick",
    ["drone_hen"] = "Drone Hen",
    ["duelist_rooster"] = "Duelist Rooster",
    ["eclipse_hen"] = "Eclipse Hen",
    ["eel_hen"] = "Eel Hen",
    ["error_chick"] = "Error Chick",
    ["fairy_hen"] = "Fairy Hen",
    ["farmer_rooster"] = "Farmer Rooster",
    ["fenghuang"] = "Radiant Fenghuang",
    ["fine_rooster"] = "Fine Rooster",
    ["flame_rooster"] = "Flame Rooster",
    ["founder_rooster"] = "Founder Rooster",
    ["frost_hen"] = "Frostbite Hen",
    ["ghost_hen"] = "Ghost Hen",
    ["glam_hen"] = "Glam Hen",
    ["golden_goose"] = "Golden Goose",
    ["grandmaster_rooster"] = "Grandmaster Rooster",
    ["hacker_hen"] = "Hacker Hen",
    ["halo_hen"] = "Halo Hen",
    ["heart_hen"] = "Heart Hen",
    ["hex_rooster"] = "Hex Rooster",
    ["high_roller_rooster"] = "High Roller Rooster",
    ["hive_rooster"] = "Hive Rooster",
    ["idol_hen"] = "Idol Hen",
    ["impostor_chick"] = "Impostor Chick",
    ["ironcluck"] = "Ironcluck",
    ["jack_rooster"] = "Jack Rooster",
    ["jackal_rooster"] = "Jackal Rooster",
    ["janitor_rooster"] = "Janitor Rooster",
    ["karaoke_rooster"] = "Karaoke Rooster",
    ["kitsune_hen"] = "Nine-Tail Hen",
    ["kitty_chick"] = "Kitty Chick",
    ["laser_rooster"] = "Laser Rooster",
    ["loco_rooster"] = "Loco Rooster",
    ["luchador"] = "Luchador",
    ["magma_cock"] = "Magma Rooster",
    ["magnet_hen"] = "Magnet Hen",
    ["mantis_hen"] = "Mantis Hen",
    ["mecha_rooster"] = "Mecha Rooster",
    ["medic_hen"] = "Medic Hen",
    ["mercy_hen"] = "Mercy Hen",
    ["mermaid_hen"] = "Mermaid Hen",
    ["mime_hen"] = "Mime Hen",
    ["moai_rooster"] = "Stone Face",
    ["moon_hen"] = "Moonwalk Hen",
    ["mummy_hen"] = "Mummy Hen",
    ["nail_hen"] = "Manicure Hen",
    ["nano_rooster"] = "Nano Rooster",
    ["nebula_hen"] = "Nebula Hen",
    ["ninja_rooster"] = "Shadow Ninja",
    ["npc_chick"] = "NPC Chick",
    ["nugget_chick"] = "Nugget Chick",
    ["oracle_chick"] = "Oracle Chick",
    ["overclock"] = "Overclock Rooster",
    ["pact_hen"] = "Pact Hen",
    ["pastel_goth"] = "Pastel Goth",
    ["phoenix_hen"] = "Phoenix Hen",
    ["pizza_rooster"] = "Pizza Rooster",
    ["plumber_hen"] = "Plumber Hen",
    ["plush_chick"] = "Plush Chick",
    ["prism_rooster"] = "Prism Rooster",
    ["probe_rooster"] = "Probe Rooster",
    ["puck_rooster"] = "Enforcer Rooster",
    ["pufferhen"] = "Pufferhen",
    ["puzzle_hen"] = "Puzzle Hen",
    ["quake_rooster"] = "Quake Rooster",
    ["reaper_rooster"] = "Reaper Rooster",
    ["reek_rooster"] = "Reek Rooster",
    ["riot_hen"] = "Riot Hen",
    ["ronin_hen"] = "Ronin Hen",
    ["rumble_rooster"] = "Rumble Rooster",
    ["sapper_hen"] = "Sapper Hen",
    ["satellite_hen"] = "Orbital Hen",
    ["seraph_rooster"] = "Seraph Rooster",
    ["sergeant_hen"] = "Sergeant Hen",
    ["shadow_rooster"] = "Shadow Rooster",
    ["shark_chicken"] = "Shark Chicken",
    ["shockwave_hen"] = "Shockwave Hen",
    ["sigma_rooster"] = "Sigma Rooster",
    ["singular"] = "Singularity Hen",
    ["sirocco"] = "Sandstorm Rooster",
    ["skater_chick"] = "Skater Chick",
    ["skyscrest_rooster"] = "Skyscrest Rooster",
    ["slugger_hen"] = "Slugger Hen",
    ["snapper"] = "Snapper",
    ["sniper_rooster"] = "Sniper Rooster",
    ["solar_rooster"] = "Solar Rooster",
    ["sovereign_rooster"] = "Sovereign Rooster",
    ["spa_hen"] = "Spa Hen",
    ["sparkbeak"] = "Static Chick",
    ["spider_chicken"] = "Spider Chicken",
    ["squire_chick"] = "Squire Chick",
    ["stonks_hen"] = "Stonks Hen",
    ["storm_colossus"] = "Storm Colossus",
    ["strike_hen"] = "Strike Hen",
    ["striker_hen"] = "Striker Hen",
    ["sumo_rooster"] = "Sumo Rooster",
    ["sushi_hen"] = "Sushi Hen",
    ["talon_titan"] = "Talon Titan",
    ["tank_rooster"] = "Tank Rooster",
    ["taser_hen"] = "Taser Hen",
    ["tengu_rooster"] = "Tengu Rooster",
    ["tide_hen"] = "Tsunami Hen",
    ["twin_rooster"] = "Twin Rooster",
    ["twister_hen"] = "Twister Hen",
    ["unicorn_hen"] = "Unicorn Hen",
    ["valkyrie_hen"] = "Valkyrie Hen",
    ["vampire_rooster"] = "Vampire Rooster",
    ["viking_rooster"] = "Viking Rooster",
    ["viper_hen"] = "Viper Hen",
    ["voidbeak"] = "Voidbeak",
    ["witch_hen"] = "Cauldron Hen",
    ["zodiac_hen"] = "Zodiac Hen",
    ["zombie_chick"] = "Zombie Chick",
}

local function formatSpeciesName(typeId)
    if not typeId or typeId == "" then
        return "Unknown Chicken"
    end
    local raw = tostring(typeId):lower():gsub("^%s*(.-)%s*$", "%1")
    if CHICKEN_NAME_BY_TYPE_ID[raw] then
        return CHICKEN_NAME_BY_TYPE_ID[raw]
    end
    local words = {}
    for word in string.gmatch(raw, "[^_]+") do
        local cap = word:sub(1, 1):upper() .. word:sub(2):lower()
        table.insert(words, cap)
    end
    return table.concat(words, " ")
end

scanFlockChickens = function()
    local foundNames = {}
    local newMap = {}
    local duplicateCounter = {}
    local speciesTracker = {}

    -- =========================================================================
    -- [ENGINE 1 - UTAMA]: DETEKSI INSTAN BACKGROUND DARI DATASERVICE MEMORY
    -- (Tidak butuh pemain membuka menu Flock sama sekali!)
    -- =========================================================================
    pcall(function()
        local dsClient = getSharedDataServiceClient()
        local raw = dsClient and dsClient._data and dsClient._data._data
        if raw and raw.roster and raw.roster.chickens and type(raw.roster.chickens) == "table" then
            for _, ch in pairs(raw.roster.chickens) do
                if type(ch) == "table" and ch.id then
                    local cId = tostring(ch.id)
                    local numId = tonumber(string.match(cId, "%d+"))
                    local speciesName = formatSpeciesName(ch.typeId)
                    local cleanSpecies = speciesName:upper()

                    local chickenName = speciesName
                    local cleanTypeId = tostring(ch.typeId):gsub("_", " "):lower()
                    local nickClean = ch.nickname and type(ch.nickname) == "string" and ch.nickname:gsub("^%s*(.-)%s*$", "%1")
                    if nickClean and #nickClean > 0 and nickClean:lower() ~= cleanTypeId and nickClean:lower() ~= tostring(ch.typeId):lower() and nickClean:lower() ~= speciesName:lower() then
                        local nickCap = nickClean:sub(1, 1):upper() .. nickClean:sub(2)
                        chickenName = string.format("%s (%s)", nickCap, speciesName)
                    end

                    local finalLvlNum = tonumber(ch.level) or 1
                    local finalLvlStr = "Lvl " .. tostring(finalLvlNum)
                    local stars = tonumber(ch.promo) or 0
                    local rarity = ch.rarity and tostring(ch.rarity):upper() or "UNKNOWN"
                    local isFav = (ch.favorite == true)
                    local chickenSkill = ch.ability and tostring(ch.ability) or ""

                    local mutationBadge = ""
                    local mutName = nil
                    if ch.mutation then
                        if type(ch.mutation) == "string" and #ch.mutation > 0 and ch.mutation:lower() ~= "none" then
                            mutName = ch.mutation:sub(1, 1):upper() .. ch.mutation:sub(2):lower()
                            mutationBadge = string.format(" [🌀 %s]", mutName)
                        elseif type(ch.mutation) == "table" and ch.mutation.name then
                            local m = tostring(ch.mutation.name)
                            mutName = m:sub(1, 1):upper() .. m:sub(2):lower()
                            mutationBadge = string.format(" [🌀 %s]", mutName)
                        end
                    end

                    if stars > 0 then
                        promotedChickenIds[cId] = true
                        if numId then
                            promotedChickenIds[numId] = true
                        end
                    end
                    if isFav then
                        favoritedChickenIds[cId] = true
                        if numId then
                            favoritedChickenIds[numId] = true
                        end
                    end

                    if not speciesTracker[cleanSpecies] then
                        speciesTracker[cleanSpecies] = {}
                    end
                    table.insert(speciesTracker[cleanSpecies], {
                        Id = cId,
                        NumId = numId,
                        Name = chickenName,
                        Species = cleanSpecies,
                        Lvl = finalLvlStr,
                        LvlNum = finalLvlNum,
                        Frame = nil,
                        Stars = stars,
                        Rarity = rarity,
                        IsFavorite = isFav,
                        Mutation = mutName,
                        MutationBadge = mutationBadge
                    })

                    local starBadge = string.format("★%d", stars)
                    local baseDisplay = string.format("%s %s (%s)%s", chickenName, starBadge, finalLvlStr, mutationBadge)
                    if isFav then
                        baseDisplay = "❤️ " .. baseDisplay
                    end

                    duplicateCounter[baseDisplay] = (duplicateCounter[baseDisplay] or 0) + 1
                    local finalDisplay = baseDisplay
                    if duplicateCounter[baseDisplay] > 1 then
                        finalDisplay = baseDisplay .. " #" .. tostring(duplicateCounter[baseDisplay])
                    end

                    if not newMap[finalDisplay] then
                        table.insert(foundNames, finalDisplay)
                        newMap[finalDisplay] = {
                            Id = cId,
                            Frame = nil,
                            Name = chickenName,
                            Lvl = finalLvlStr,
                            LvlNum = finalLvlNum,
                            Skill = chickenSkill,
                            IsFavorite = isFav,
                            Mutation = mutName,
                            MutationBadge = mutationBadge
                        }
                    end
                end
            end
        end
    end)

    -- =========================================================================
    -- [ENGINE 2 - FALLBACK]: SCAN LEWAT PLAYERGUI JIKA DATASERVICE BELUM SIAP
    -- =========================================================================
    if #foundNames == 0 then
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if not playerGui then
                return
            end

            for _, desc in ipairs(playerGui:GetDescendants()) do
                local matchNumber = string.match(desc.Name, "^c(%d+)$")
                if matchNumber and (desc:IsA("Frame") or desc:IsA("GuiObject") or desc:IsA("TextButton")) then
                    local cId = desc.Name
                    local numId = tonumber(matchNumber)

                    local chickenName = nil
                    local chickenLvl = nil
                    local chickenLvlNum = nil
                    local isEgg = false

                    if desc.Name:lower():find("egg") then
                        isEgg = true
                    end

                    for _, child in ipairs(desc:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                            local txt = child.Text:gsub("^%s*(.-)%s*$", "%1")
                            local txtLower = txt:lower()

                            if txtLower:find("egg") or txtLower:find("telur") then
                                isEgg = true
                            end

                            local lvlMatch = string.match(txt, "[Ll][Vv][Ll]?%.?%s*(%d+)") or string.match(txt, "[Ll]evel%s*(%d+)")
                            if lvlMatch and not chickenLvlNum then
                                chickenLvlNum = tonumber(lvlMatch)
                                chickenLvl = "Lvl " .. lvlMatch
                            else
                                local isGarbage = false
                                if txtLower:find("^%+") or txtLower:find("^%-") or txtLower:find("%%") then
                                    isGarbage = true
                                elseif txtLower:find("xp") or txtLower:find("boost") or txtLower:find("%$") then
                                    isGarbage = true
                                elseif string.match(txtLower, "^x%d+$") or string.match(txtLower, "^%d+x$") then
                                    isGarbage = true
                                elseif string.match(txt, "^%d+%.?%d*[kKmMbBtT]?$") then
                                    isGarbage = true
                                elseif txtLower == "chicken name" or txtLower == "active" or txtLower == "fuse" or txtLower == "promote" or txtLower == "sell" or txtLower == "index" or txtLower == "sell mode" or txtLower == "template" then
                                    isGarbage = true
                                end

                                if not isGarbage and not isEgg and #txt > 1 and not chickenName then
                                    chickenName = txt
                                end
                            end
                        end
                    end

                    if not isEgg and chickenName then
                        local finalLvlNum = chickenLvlNum or 1
                        local finalLvlStr = chickenLvl or ("Lvl " .. tostring(finalLvlNum))
                        local cleanSpecies = chickenName:upper()
                        local stars = getChickenStarCount(desc, cId, numId)
                        local rarity = detectChickenRarity(desc, chickenName)
                        if not rarity or rarity == "" then
                            rarity = "Unknown"
                        end

                        if stars > 0 then
                            promotedChickenIds[cId] = true
                            if numId then
                                promotedChickenIds[numId] = true
                            end
                        end

                        local isFav = favoritedChickenIds[cId] or (numId and favoritedChickenIds[numId]) or desc:GetAttribute("Favorite") == true or desc:FindFirstChild("Favorite")

                        local mutationBadge = ""
                        local mutName = nil
                        local attrMut = desc:GetAttribute("Mutation") or desc:GetAttribute("mutation")
                        if attrMut and type(attrMut) == "string" and #attrMut > 0 and attrMut:lower() ~= "none" then
                            mutName = attrMut:sub(1, 1):upper() .. attrMut:sub(2):lower()
                            mutationBadge = string.format(" [🌀 %s]", mutName)
                        else
                            for _, child in ipairs(desc:GetDescendants()) do
                                if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                                    local txtLower = child.Text:lower()
                                    if txtLower:find("inverted") then
                                        mutName = "Inverted"
                                        mutationBadge = " [🌀 Inverted]"
                                        break
                                    end
                                end
                            end
                        end

                        if not speciesTracker[cleanSpecies] then
                            speciesTracker[cleanSpecies] = {}
                        end
                        table.insert(speciesTracker[cleanSpecies], {
                            Id = cId,
                            NumId = numId,
                            Name = chickenName,
                            Species = cleanSpecies,
                            Lvl = finalLvlStr,
                            LvlNum = finalLvlNum,
                            Frame = desc,
                            Stars = stars,
                            Rarity = rarity,
                            IsFavorite = isFav,
                            Mutation = mutName,
                            MutationBadge = mutationBadge
                        })

                        local starBadge = string.format("★%d", stars)
                        local baseDisplay = string.format("%s %s (%s)%s", chickenName, starBadge, finalLvlStr, mutationBadge)
                        if isFav then
                            baseDisplay = "❤️ " .. baseDisplay
                        end

                        duplicateCounter[baseDisplay] = (duplicateCounter[baseDisplay] or 0) + 1
                        local finalDisplay = baseDisplay
                        if duplicateCounter[baseDisplay] > 1 then
                            finalDisplay = baseDisplay .. " #" .. tostring(duplicateCounter[baseDisplay])
                        end

                        local chickenSkill = extractChickenSkill(desc)

                        if not newMap[finalDisplay] then
                            table.insert(foundNames, finalDisplay)
                            newMap[finalDisplay] = {
                                Id = cId,
                                Frame = desc,
                                Name = chickenName,
                                Lvl = finalLvlStr,
                                LvlNum = finalLvlNum,
                                Skill = chickenSkill,
                                IsFavorite = isFav,
                                Mutation = mutName,
                                MutationBadge = mutationBadge
                            }
                        end
                    end
                end
            end
        end)
    end

    table.sort(foundNames, function(a, b)
        return a < b
    end)
    if #foundNames == 0 then
        table.insert(foundNames, "Buka menu Flock di game lalu klik Refresh!")
    end

    chickenNames = foundNames
    chickenMap = newMap
    if not selectedChickenName or not chickenMap[selectedChickenName] then
        selectedChickenName = chickenNames[1]
        selectedChickenId = chickenMap[selectedChickenName] and chickenMap[selectedChickenName].Id
    end
    if not selectedFavChickenName or not chickenMap[selectedFavChickenName] then
        selectedFavChickenName = chickenNames[1]
    end

    globalSpeciesTracker = speciesTracker

    -- Bangun promoteTargetList & promoteTargetMap untuk Dropdown 1
    local newTargetList = {}
    local newTargetMap = {}
    local targetDupCounter = {}

    for specName, list in pairs(speciesTracker) do
        -- Hanya tampilkan jika jenis ayam ini memiliki duplikat sejenis (> 1 ekor di kawanan)
        if #list > 1 then
            for _, ch in ipairs(list) do
                local mutBadge = ch.MutationBadge or ""
                local favBadge = ch.IsFavorite and "❤️ " or ""
                local baseLabel = string.format("%s%s ★%d (%s)%s", favBadge, ch.Name, ch.Stars, ch.Lvl, mutBadge)
                targetDupCounter[baseLabel] = (targetDupCounter[baseLabel] or 0) + 1
                local label = baseLabel .. " #" .. tostring(targetDupCounter[baseLabel])
                table.insert(newTargetList, label)
                newTargetMap[label] = ch
            end
        end
    end

    table.sort(newTargetList, function(a, b)
        return a < b
    end)
    if #newTargetList == 0 then
        table.insert(newTargetList, "Tidak ada ayam yang memiliki duplikat sejenis")
    end

    promoteTargetList = newTargetList
    promoteTargetMap = newTargetMap
    if not selectedPromoteTarget or not promoteTargetMap[selectedPromoteTarget] then
        selectedPromoteTarget = promoteTargetList[1]
    end

    local function safeRefreshDropdown(dd, list)
        if not dd or not list then
            return
        end
        pcall(function()
            if type(dd.Refresh) == "function" then
                dd:Refresh(list, true)
            elseif type(dd.SetValues) == "function" then
                dd:SetValues(list)
            end
            if type(dd.SetValue) == "function" and list and list[1] then
                dd:SetValue(list[1])
            end
            if expandDropdown then
                expandDropdown(dd, 300)
            end
        end)
    end

    -- Update Dropdown 2 (Bahan) secara real-time berdasarkan ayam target terpilih
    if updatePromoteFodders then
        updatePromoteFodders(selectedPromoteTarget)
    end

    -- Refresh 7 dropdown secara terdistribusi (staggered) agar framerate tetap 60 FPS tanpa freeze
    task.spawn(function()
        pcall(function() safeRefreshDropdown(chickenDropdown, chickenNames) end)
        task.wait(0.02)
        pcall(function()
            safeRefreshDropdown(promoteTargetDropdown, promoteTargetList)
            safeRefreshDropdown(promoteDropdown, promoteTargetList)
        end)
        task.wait(0.02)
        pcall(function()
            safeRefreshDropdown(fuseMainDropdown, chickenNames)
            safeRefreshDropdown(fuseFodderDropdown, chickenNames)
        end)
        task.wait(0.02)
        pcall(function()
            safeRefreshDropdown(favDropdown, chickenNames)
            safeRefreshDropdown(UpdateHub.charmDropdown, chickenNames)
            safeRefreshDropdown(UpdateHub.ufoChickenDropdown, chickenNames)
            if updateAvailableSkills then
                updateAvailableSkills()
            end
        end)
    end)
end

updatePromoteFodders = function(targetLabel)
    if not targetLabel or not promoteTargetMap[targetLabel] then
        promoteFodderList = {"Pilih ayam target terlebih dahulu"}
        if promoteFodderDropdown and promoteFodderDropdown.Refresh then
            pcall(function()
                promoteFodderDropdown:Refresh(promoteFodderList, true)
                if promoteFodderDropdown.SetValue then
                    promoteFodderDropdown:SetValue(promoteFodderList[1])
                end
                if expandDropdown then
                    expandDropdown(promoteFodderDropdown, 300)
                end
            end)
        end
        return
    end

    local target = promoteTargetMap[targetLabel]
    local targetSpecies = target.Species
    local targetRarity = target.Rarity
    local currentStars = target.Stars
    local neededFodders, nextStar = getRequiredFodders(targetRarity, currentStars)

    local candidateFodders = {}
    if globalSpeciesTracker[targetSpecies] then
        for _, ch in ipairs(globalSpeciesTracker[targetSpecies]) do
            if ch.Id ~= target.Id and not favoritedChickenIds[ch.Id] then
                table.insert(candidateFodders, ch)
            end
        end
    end

    -- Urutkan bahan: utamakan ayam tanpa bintang & level terendah
    table.sort(candidateFodders, function(a, b)
        if a.Stars ~= b.Stars then
            return a.Stars < b.Stars
        end
        return a.LvlNum < b.LvlNum
    end)

    local newFodderList = {}
    local newFodderMap = {}
    local defaultSelected = {}
    selectedPromoteFoddersMap = {}

    local fodderDupCounter = {}
    for i, f in ipairs(candidateFodders) do
        local mutBadge = f.MutationBadge or ""
        local baseLabel = string.format("%s ★%d (%s)%s", f.Name, f.Stars, f.Lvl, mutBadge)
        fodderDupCounter[baseLabel] = (fodderDupCounter[baseLabel] or 0) + 1
        local label = baseLabel .. " #" .. tostring(fodderDupCounter[baseLabel])
        table.insert(newFodderList, label)
        newFodderMap[label] = f

        -- Otomatis pre-select bahan sejumlah neededFodders (utamakan ayam tanpa bintang terendah)
        if i <= neededFodders then
            table.insert(defaultSelected, label)
            selectedPromoteFoddersMap[label] = true
        end
    end

    if #newFodderList == 0 then
        table.insert(newFodderList, "Tidak ada ayam sejenis yang dapat dikorbankan")
    end

    promoteFodderList = newFodderList
    promoteFodderMap = newFodderMap

    if promoteFodderDropdown and promoteFodderDropdown.Refresh then
        pcall(function()
            promoteFodderDropdown:Refresh(promoteFodderList, true)
            if #defaultSelected > 0 and promoteFodderDropdown.SetValue then
                promoteFodderDropdown:SetValue(defaultSelected)
            end
            if expandDropdown then
                expandDropdown(promoteFodderDropdown, 300)
            end
        end)
    end

    if updatePromoteStatusDisplay then
        updatePromoteStatusDisplay()
    end
end

updatePromoteStatusDisplay = function()
    if not promoteStatusPara then
        return
    end
    if not selectedPromoteTarget or not promoteTargetMap[selectedPromoteTarget] then
        pcall(function()
            if type(promoteStatusPara.SetTitle) == "function" and type(promoteStatusPara.SetDesc) == "function" then
                promoteStatusPara:SetTitle("Status Persyaratan Promote")
                promoteStatusPara:SetDesc("Silakan pilih ayam target pada Target Promote.")
            elseif type(promoteStatusPara.Set) == "function" then
                promoteStatusPara:Set({
                    Title = "Status Persyaratan Promote",
                    Desc = "Silakan pilih ayam target pada Target Promote."
                })
            end
        end)
        return
    end

    local target = promoteTargetMap[selectedPromoteTarget]
    local neededFodders, nextStar = getRequiredFodders(target.Rarity, target.Stars)

    local chosenCount = 0
    for label, isChecked in pairs(selectedPromoteFoddersMap) do
        if isChecked and promoteFodderMap[label] then
            chosenCount = chosenCount + 1
        end
    end

    local curStarTxt = string.format("★%d", target.Stars)
    local mutTxt = target.MutationBadge or ""
    local title = string.format("Promote: %s%s (%s • %s)", target.Name, mutTxt, curStarTxt, target.Rarity)
    local desc = ""

    if chosenCount < neededFodders then
        local kurang = neededFodders - chosenCount
        desc = string.format("🎯 Target: Naik ke ★ %d (%s)\n📋 Syarat Resmi Game: Butuh %d Ekor Bahan Sejenis\n\n⚠️ Status Bahan: %d/%d Terpilih (Kurang %d ekor)\n👉 Centang %d ekor ayam lagi di Bahan Korban.", nextStar, target.Rarity, neededFodders, chosenCount, neededFodders, kurang, kurang)
    elseif chosenCount > neededFodders then
        local lebih = chosenCount - neededFodders
        desc = string.format("🎯 Target: Naik ke ★ %d (%s)\n📋 Syarat Resmi Game: Butuh %d Ekor Bahan Sejenis\n\n⚠️ Status Bahan: %d/%d Terpilih (Kelebihan %d ekor)\n👉 Hapus centang %d ekor agar pas %d ekor saja.", nextStar, target.Rarity, neededFodders, chosenCount, neededFodders, lebih, lebih, neededFodders)
    else
        desc = string.format("🎯 Target: Naik ke ★ %d (%s)\n📋 Syarat Resmi Game: Butuh %d Ekor Bahan Sejenis\n\n✅ Status Bahan: PAS %d/%d Terpilih!\n✨ Semua bahan aman & siap dikorbankan. Klik tombol di bawah untuk promote.", nextStar, target.Rarity, neededFodders, chosenCount, neededFodders)
    end

    pcall(function()
        if type(promoteStatusPara.SetTitle) == "function" and type(promoteStatusPara.SetDesc) == "function" then
            promoteStatusPara:SetTitle(title)
            promoteStatusPara:SetDesc(desc)
        elseif type(promoteStatusPara.Set) == "function" then
            promoteStatusPara:Set({
                Title = title,
                Desc = desc
            })
        end
    end)
end

local function executePromoteSelectedSpecies()
    if not selectedPromoteTarget or not promoteTargetMap[selectedPromoteTarget] then
        return false, "Pilih ayam target untuk dipromote terlebih dahulu"
    end

    local target = promoteTargetMap[selectedPromoteTarget]
    local targetSpecies = target.Species
    local targetRarity = target.Rarity
    local currentStars = target.Stars
    local neededFodders, nextStar = getRequiredFodders(targetRarity, currentStars)

    -- Kumpulkan ayam bahan yang benar-benar dicentang oleh user di Dropdown 2
    local chosenFodders = {}
    for label, isChecked in pairs(selectedPromoteFoddersMap) do
        if isChecked and promoteFodderMap[label] then
            table.insert(chosenFodders, promoteFodderMap[label])
        end
    end

    -- PROTEKSI KETAT: Jumlah bahan terpilih WAJIB PERSIS SAMA dengan neededFodders!
    if #chosenFodders < neededFodders then
        local kurang = neededFodders - #chosenFodders
        return false, string.format("Dibatalkan: Baru %d/%d bahan terpilih untuk naik ke ★ %d (Kurang %d ekor). Silakan centang bahan di Bahan Korban.", #chosenFodders, neededFodders, nextStar, kurang)
    end

    if #chosenFodders > neededFodders then
        local lebih = #chosenFodders - neededFodders
        return false, string.format("Dibatalkan: Anda mencentang %d bahan (Kelebihan %d ekor). Syarat resmi hanya butuh %d ekor. Harap centang pas %d ekor.", #chosenFodders, lebih, neededFodders, neededFodders)
    end

    -- Kumpulkan HANYA ID dari ayam bahan yang dipilih oleh user
    local selectedFodderStrIds = {}
    local selectedFodderNumIds = {}
    for _, f in ipairs(chosenFodders) do
        table.insert(selectedFodderStrIds, f.Id)
        if f.NumId then
            table.insert(selectedFodderNumIds, f.NumId)
        end
    end

    local initialStars = target.Stars

    -- PANGGIL REMOTE RESMI PROMOTECHICKEN HANYA DENGAN BAHAN TERPILIH (TIDAK PERNAH PANGGIL FUSECHICKENS)
    local anySuccess = false

    -- 1. Format: PromoteChicken(targetId, {fodderId1, fodderId2, ...})
    pcall(function()
        local r1 = invokeRemote("PromoteChicken", target.Id, selectedFodderStrIds)
        if r1 ~= nil and (type(r1) ~= "table" or not r1.error) then
            anySuccess = true
        end
    end)

    -- 2. Format: PromoteChicken(targetNumId, {numId1, numId2, ...})
    if not anySuccess and target.NumId and #selectedFodderNumIds > 0 then
        pcall(function()
            local r2 = invokeRemote("PromoteChicken", target.NumId, selectedFodderNumIds)
            if r2 ~= nil and (type(r2) ~= "table" or not r2.error) then
                anySuccess = true
            end
        end)
    end

    -- 3. Format: PromoteChicken(targetId, fodderId1, fodderId2, ...)
    if not anySuccess and #selectedFodderStrIds > 0 then
        pcall(function()
            local r1b = invokeRemote("PromoteChicken", target.Id, unpack(selectedFodderStrIds))
            if r1b ~= nil and (type(r1b) ~= "table" or not r1b.error) then
                anySuccess = true
            end
        end)
    end

    -- 4. Format: PromoteChicken(targetId) (Server otomatis memproses target jika state bahan siap)
    if not anySuccess then
        pcall(function()
            local r4 = invokeRemote("PromoteChicken", target.Id)
            if r4 ~= nil and (type(r4) ~= "table" or not r4.error) then
                anySuccess = true
            end
        end)
    end

    task.wait(1.5)
    scanFlockChickens()

    local updatedTarget = promoteTargetMap[selectedPromoteTarget]
    local newStars = updatedTarget and updatedTarget.Stars or 0
    local promotedOk = (newStars > initialStars) or anySuccess

    if promotedOk then
        promotedChickenIds[target.Id] = true
        if target.NumId then
            promotedChickenIds[target.NumId] = true
        end
        return true, string.format("%s berhasil dipromote ke ★ %d dengan %d bahan terpilih!", target.Species, nextStar, #chosenFodders)
    else
        return false, "Server belum memproses promote untuk " .. tostring(target.Species)
    end
end

updateAvailableSkills = function()
    local detectedSkills = {}
    local skillSet = {}

    local function addSkill(skillName)
        if skillName and type(skillName) == "string" and skillName ~= "" then
            local trimmed = skillName:gsub("^%s*(.-)%s*$", "%1")
            if not skillSet[trimmed:upper()] and trimmed:lower() ~= "skill" and #trimmed > 2 then
                skillSet[trimmed:upper()] = true
                table.insert(detectedSkills, trimmed)
            end
        end
    end

    if fuseMainChickenName and chickenMap[fuseMainChickenName] then
        local mainData = chickenMap[fuseMainChickenName]
        local s = mainData.Skill or extractChickenSkill(mainData.Frame)
        if s then
            addSkill(s)
        end
    end

    if fuseFodderChickenName and chickenMap[fuseFodderChickenName] then
        local fodderData = chickenMap[fuseFodderChickenName]
        local s = fodderData.Skill or extractChickenSkill(fodderData.Frame)
        if s then
            addSkill(s)
        end
    end

    local insp = getSkillFromInspector()
    if insp then
        addSkill(insp)
    end

    if #detectedSkills == 0 then
        detectedSkills = {"Stormcall", "Final Grace", "Lightning Strike", "Inferno Breath", "Void Pulse", "Golden Touch"}
    end

    availableFuseSkills = detectedSkills
    if not fuseLockedSkill or not skillSet[fuseLockedSkill:upper()] then
        fuseLockedSkill = availableFuseSkills[1]
    end

    pcall(function()
        if fuseSkillDropdown then
            if type(fuseSkillDropdown.Refresh) == "function" then
                fuseSkillDropdown:Refresh(availableFuseSkills, true)
            elseif type(fuseSkillDropdown.SetValues) == "function" then
                fuseSkillDropdown:SetValues(availableFuseSkills)
            end
        end
    end)
end

local function executeFuseChickens()
    if not fuseMainChickenName or not chickenMap[fuseMainChickenName] then
        return false, "Pilih ayam utama!"
    end
    if not fuseFodderChickenName or not chickenMap[fuseFodderChickenName] then
        return false, "Pilih ayam bahan!"
    end
    if fuseMainChickenName == fuseFodderChickenName then
        return false, "Ayam utama & bahan tidak boleh sama!"
    end

    local mainId = chickenMap[fuseMainChickenName].Id
    local fodderId = chickenMap[fuseFodderChickenName].Id
    if favoritedChickenIds[fodderId] then
        return false, "Ayam bahan terkunci sebagai Favorit!"
    end

    invokeRemote("FuseChickens", mainId, fodderId, fuseLockedSkill or "Stormcall")
    invokeRemote("FuseChickens", mainId, fodderId)
    invokeRemote("DevourChicken", fodderId, mainId)
    scanFlockChickens()
    return true, "Penggabungan selesai!"
end

-- ==============================================================================
-- [TAB 1: REBIRTH]
-- ==============================================================================
do
    local NormalRebirthSec = RebirthTab:Section({
        Title = "Auto Rebirth Biasa",
        Opened = false
    })

    NormalRebirthSec:Toggle({ 
        Title = "Auto Rebirth (Langsung)", 
        Callback = function(state) 
            autoRebirth = parseToggle(state) 
            invokeRemote("SetAutoRebirth", autoRebirth)
        end 
    })

    NormalRebirthSec:Input({
        Title = "Rebirth Delay (s)",
        Value = tostring(delayRebirth),
        Callback = function(text)
            delayRebirth = tonumber(text) or delayRebirth
        end
    })

    local SurplusSec = RebirthTab:Section({
        Title = "Auto Rebirth Surplus",
        Opened = true
    })

    local SurplusStatus = SurplusSec:Paragraph({
        Title = "Live Monitor",
        Desc = "Menunggu data..."
    })

    updateSurplusStatus = function(title, desc)
        if not SurplusStatus then
            return
        end
        pcall(function()
            if type(SurplusStatus.SetTitle) == "function" and type(SurplusStatus.SetDesc) == "function" then
                SurplusStatus:SetTitle(title)
                SurplusStatus:SetDesc(desc)
            elseif type(SurplusStatus.Set) == "function" then
                SurplusStatus:Set({
                    Title = title,
                    Desc = desc
                })
            end
        end)
    end

    SurplusSec:Toggle({ 
        Title = "Enable Auto Rebirth Surplus", 
        Callback = function(state) 
            autoRebirthSurplus = parseToggle(state) 
            if not autoRebirthSurplus then
                highestFloorReached = 0
                if not autoSweep then
                    disableNoclip()
                end
            end
        end 
    })

    SurplusSec:Input({
        Title = "Target Coop Level",
        Value = tostring(surplusTargetCoop),
        Callback = function(text)
            surplusTargetCoop = tonumber(text) or 5
        end
    })

    SurplusSec:Input({
        Title = "Target Feeder Count",
        Value = tostring(surplusTargetFeederCount),
        Callback = function(text)
            surplusTargetFeederCount = tonumber(text) or 6
        end
    })

    SurplusSec:Input({
        Title = "Target Feeder Level",
        Value = tostring(surplusTargetFeederLevel),
        Callback = function(text)
            surplusTargetFeederLevel = tonumber(text) or 50
        end
    })

    SurplusSec:Input({
        Title = "Target Chicken Level",
        Value = tostring(surplusTargetChickenLevel),
        Callback = function(text)
            surplusTargetChickenLevel = tonumber(text) or 90
        end
    })

    SurplusSec:Input({
        Title = "Target Tower Floor",
        Value = tostring(surplusTargetTower),
        Callback = function(text)
            surplusTargetTower = tonumber(text) or 70
        end
    })

    SurplusSec:Input({
        Title = "Target Recycler Level",
        Value = tostring(surplusTargetRecycler),
        Callback = function(text)
            surplusTargetRecycler = tonumber(text) or 36
        end
    })
end

-- ==============================================================================
-- [TAB 2: COOP]
-- ==============================================================================
do
    local CoopBuildingSec = CoopTab:Section({
        Title = "Coop & Recycler",
        Opened = true
    })

    CoopBuildingSec:Toggle({
        Title = "Auto Upgrade Coop",
        Callback = function(state)
            autoUpgradeCoop = parseToggle(state)
        end
    })

    CoopBuildingSec:Input({
        Title = "Coop Delay (s)",
        Value = tostring(delayCoop),
        Callback = function(text)
            delayCoop = tonumber(text) or delayCoop
        end
    })

    CoopBuildingSec:Toggle({
        Title = "Auto Upgrade Recycler",
        Callback = function(state)
            autoUpgradeRecycler = parseToggle(state)
        end
    })

    CoopBuildingSec:Input({
        Title = "Recycler Delay (s)",
        Value = tostring(delayRecycler),
        Callback = function(text)
            delayRecycler = tonumber(text) or delayRecycler
        end
    })

    local FeederSec = CoopTab:Section({
        Title = "Feeder Management",
        Opened = true
    })

    FeederSec:Toggle({
        Title = "Auto Buy Feeder",
        Callback = function(state)
            autoBuyFeeder = parseToggle(state)
        end
    })

    FeederSec:Input({
        Title = "Buy Delay (s)",
        Value = tostring(delayBuy),
        Callback = function(text)
            delayBuy = tonumber(text) or delayBuy
        end
    })

    FeederSec:Toggle({
        Title = "Auto Upgrade Feeder",
        Callback = function(state)
            autoUpgradeFeeder = parseToggle(state)
        end
    })

    FeederSec:Input({
        Title = "Upgrade Feeder Delay (s)",
        Value = tostring(delayUpgrade),
        Callback = function(text)
            delayUpgrade = tonumber(text) or delayUpgrade
        end
    })

    local EggSec = CoopTab:Section({
        Title = "Auto Collect Egg",
        Opened = true
    })

    EggSec:Button({
        Title = "Ambil Semua Telur Sarang Sekarang",
        Callback = function()
            local count = collectMyNestEggs(true)
            if count > 0 then
                notify("Auto Collect Egg", count .. " telur berhasil diambil ke tas!")
            else
                notify("Auto Collect Egg", "Tidak ada telur di sarang saat ini.")
            end
        end
    })

    EggSec:Toggle({
        Title = "Auto Claim Telur Coop",
        Callback = function(state)
            autoCollectNestEggs = parseToggle(state)
            if autoCollectNestEggs then
                local count = collectMyNestEggs(false)
                if count > 0 then
                    notify("Auto Collect Egg", count .. " telur terdeteksi & diambil ke tas!")
                end
            end
        end
    })

    local IncubatorSec = CoopTab:Section({
        Title = "Auto Incubator",
        Opened = true
    })

    IncubatorSec:Toggle({
        Title = "Auto Claim Telur Incubator",
        Callback = function(state)
            autoClaimIncubator = parseToggle(state)
        end
    })

    chickenDropdown = IncubatorSec:Dropdown({
        Title = "Ayam Incubator:",
        Values = chickenNames,
        Value = chickenNames[1],
        MenuWidth = 300,
        Multi = false,
        Callback = function(val)
            selectedChickenName = val
            if chickenMap[val] then
                selectedChickenId = chickenMap[val].Id
            end
        end
    })
    if expandDropdown then
        expandDropdown(chickenDropdown, 300)
    end

    IncubatorSec:Button({
        Title = "Refresh List Ayam",
        Callback = function()
            scanFlockChickens()
            if #chickenNames > 0 and chickenNames[1] ~= "Buka menu Flock di game lalu klik Refresh!" then
                notify("Incubator", "Berhasil mendeteksi " .. tostring(#chickenNames) .. " ayam di kawanan!")
            else
                notify("Incubator", "Buka menu Flock di game lalu klik Refresh!")
            end
        end
    })

    IncubatorSec:Toggle({
        Title = "Auto Put Ayam ke Incubator",
        Callback = function(state)
            autoPutIncubator = parseToggle(state)
        end
    })

    IncubatorSec:Toggle({
        Title = "Auto Upgrade Incubator",
        Callback = function(state)
            autoUpgradeIncubator = parseToggle(state)
        end
    })

    IncubatorSec:Input({
        Title = "Upgrade Delay (s)",
        Value = tostring(delayUpgradeIncubator),
        Callback = function(text)
            delayUpgradeIncubator = tonumber(text) or delayUpgradeIncubator
        end
    })

    -- ==============================================================================
    -- SECTION: AUTO OPEN EGG
    -- ==============================================================================
    local OpenEggSec = FlockTab:Section({
        Title = "Auto Open Egg",
        Opened = true
    })

    local VALID_OFFICIAL_EGGS = {
        ["FORTUNE EGG"] = "Fortune Egg",
        ["COLOSSUS EGG"] = "Colossus Egg",
        ["CHARM EGG"] = "Charm Egg",
        ["THUNDER EGG"] = "Thunder Egg",
        ["VOID EGG"] = "Void Egg",
        ["TRICK EGG"] = "Trick Egg",
        ["ASCENSION EGG"] = "Ascension Egg",
        ["CIRCUIT EGG"] = "Circuit Egg",
        ["HAUNT EGG"] = "Haunt Egg",
        ["ROYAL EGG"] = "Royal Egg",
        ["SCRATCH EGG"] = "Scratch Egg",
        ["GRUDGE EGG"] = "Grudge Egg",
        ["DEMONIC EGG"] = "Demonic Egg",
        ["NEST EGG"] = "Nest Egg",
        ["BLAZING EGG"] = "Blazing Egg",
        ["TROPHY EGG"] = "Trophy Egg",
        ["CURSED EGG"] = "Cursed Egg",
        ["BLOOM EGG"] = "Bloom Egg",
        ["DINER EGG"] = "Diner Egg",
        ["ARENA EGG"] = "Arena Egg",
        ["FANG EGG"] = "Fang Egg",
        ["ORDNANCE EGG"] = "Ordnance Egg",
        ["BLESSED EGG"] = "Blessed Egg"
    }

    local EGG_ID_BY_NAME = {
        ["Fortune Egg"] = "golden",
        ["Colossus Egg"] = "colossus",
        ["Charm Egg"] = "charm",
        ["Thunder Egg"] = "storm",
        ["Void Egg"] = "void",
        ["Trick Egg"] = "trick",
        ["Ascension Egg"] = "ascension",
        ["Circuit Egg"] = "circuit",
        ["Haunt Egg"] = "haunt",
        ["Royal Egg"] = "crown",
        ["Scratch Egg"] = "feed",
        ["Grudge Egg"] = "rival",
        ["Demonic Egg"] = "demonic",
        ["Nest Egg"] = "barn",
        ["Blazing Egg"] = "hotEgg",
        ["Trophy Egg"] = "trophy",
        ["Cursed Egg"] = "meme",
        ["Bloom Egg"] = "bloom",
        ["Diner Egg"] = "diner",
        ["Arena Egg"] = "arena",
        ["Fang Egg"] = "fang",
        ["Ordnance Egg"] = "ordnance",
        ["Blessed Egg"] = "blessed"
    }

    local EGG_NAME_BY_ID = {}
    for name, id in pairs(EGG_ID_BY_NAME) do
        EGG_NAME_BY_ID[id] = name
    end

    local STATIC_EGG_POOLS = {
        ["Arena Egg"] = {
            "Agent Cluck", "Baron Cluck", "Belt Champion", "Blitz Rooster",
            "Caddie Rooster", "Capoeira Rooster", "Clown Chick", "Enforcer Rooster",
            "Luchador", "Skater Chick", "Slugger Hen", "Southpaw Hen",
            "Spider Chicken", "Strike Hen", "Striker Hen", "Sumo Rooster"
        },
        ["Ascension Egg"] = {
            "Eclipse Hen", "Halo Hen", "Oracle Chick", "Seraph Rooster",
            "Skyscrest Rooster"
        },
        ["Blazing Egg"] = {
            "Agent Cluck", "Astro Chick", "Aurora Hen", "Baron Cluck",
            "Blitz Rooster", "Boba Hen", "Bravo Rooster", "Commando Rooster",
            "Cosmo Brat", "Crest Rooster", "Crystal Hen", "DJ Rooster",
            "Doll Hen", "Drone Hen", "Error Chick", "Farmer Rooster",
            "Fine Rooster", "Founder Rooster", "Ghost Hen", "Glam Hen",
            "Golden Goose", "Hacker Hen", "Impostor Chick", "Kitty Chick",
            "Laser Rooster", "Loco Rooster", "Mecha Rooster", "Mime Hen",
            "Mummy Hen", "Nebula Hen", "Nine-Tail Hen", "Overclock Rooster",
            "Prism Rooster", "Radiant Fenghuang", "Reaper Rooster", "Sergeant Hen",
            "Shadow Rooster", "Singularity Hen", "Slugger Hen", "Spider Chicken",
            "Unicorn Hen", "Vampire Rooster", "Viking Rooster", "Viper Hen",
            "Voidbeak", "Zodiac Hen"
        },
        ["Blessed Egg"] = {
            "Angel Chicken", "Beacon Rooster", "Mercy Hen"
        },
        ["Bloom Egg"] = {
            "Butterfly Hen", "Cauldron Hen", "Crystal Hen", "Fairy Hen",
            "Heart Hen", "Idol Hen", "Mermaid Hen", "Pastel Goth",
            "Unicorn Hen", "Zodiac Hen"
        },
        ["Charm Egg"] = {
            "Ballet Hen", "Boba Hen", "Bow Chick", "Cheer Chick",
            "Cupcake Chick", "Glam Hen", "Kitty Chick", "Manicure Hen",
            "Plush Chick", "Spa Hen"
        },
        ["Circuit Egg"] = {
            "Drone Hen", "Hacker Hen", "Laser Rooster", "Magnet Hen",
            "Mecha Rooster", "Nano Rooster", "Overclock Rooster", "Taser Hen"
        },
        ["Colossus Egg"] = {
            "Catalyst Hen", "Ironcluck", "Rumble Rooster", "Shockwave Hen",
            "Storm Colossus", "Talon Titan"
        },
        ["Cursed Egg"] = {
            "Bonk Hen", "Deep Fried Hen", "Error Chick", "Fine Rooster",
            "Impostor Chick", "Karaoke Rooster", "NPC Chick", "Sigma Rooster",
            "Stone Face", "Stonks Hen"
        },
        ["Demonic Egg"] = {
            "Devil Chicken", "Hex Rooster", "Pact Hen"
        },
        ["Diner Egg"] = {
            "Barista Hen", "Bucket Rooster", "Chef Rooster", "DJ Rooster",
            "Janitor Rooster", "Mime Hen", "Nugget Chick", "Pizza Rooster",
            "Plumber Hen", "Sushi Hen"
        },
        ["Fang Egg"] = {
            "Beast Rooster", "Bombardier Rooster", "Bravo Rooster", "Bunker Hen",
            "Chameleon Hen", "Eel Hen", "Founder Rooster", "Hive Rooster",
            "Mantis Hen", "Pufferhen", "Reek Rooster", "Shark Chicken",
            "Snapper", "Viking Rooster", "Viper Hen"
        },
        ["Fortune Egg"] = {
            "Baron Cluck", "Founder Rooster", "Golden Goose", "Sovereign Rooster"
        },
        ["Grudge Egg"] = {
            "Agent Cluck", "Belt Champion", "Duelist Rooster"
        },
        ["Haunt Egg"] = {
            "Bone Rooster", "Clown Chick", "Doll Hen", "Ghost Hen",
            "Jack Rooster", "Mummy Hen", "Reaper Rooster", "Shadow Rooster",
            "Vampire Rooster", "Zombie Chick"
        },
        ["Nest Egg"] = {
            "Classic Rooster", "Cosmo Brat", "Farmer Rooster", "Viking Rooster"
        },
        ["Ordnance Egg"] = {
            "Bulwark Knight", "Commando Rooster", "Flame Rooster", "Founder Rooster",
            "Loco Rooster", "Medic Hen", "Riot Hen", "Ronin Hen",
            "Sapper Hen", "Sergeant Hen", "Shadow Ninja", "Sniper Rooster",
            "Tank Rooster"
        },
        ["Royal Egg"] = {
            "Barcelos", "Baron Cluck", "Basilisk Rooster", "Cockatrice",
            "Crest Rooster", "Founder Rooster", "Jackal Rooster", "Nine-Tail Hen",
            "Phoenix Hen", "Radiant Fenghuang", "Spider Chicken", "Tengu Rooster",
            "Twin Rooster", "Valkyrie Hen"
        },
        ["Scratch Egg"] = {
            "Bow Chick", "Cosmo Brat", "Crest Rooster", "Farmer Rooster",
            "NPC Chick", "Pizza Rooster", "Sergeant Hen", "Slugger Hen",
            "Taser Hen", "Viking Rooster"
        },
        ["Thunder Egg"] = {
            "Astro Chick", "Aurora Hen", "Boom Rooster", "Commando Rooster",
            "Crest Rooster", "Founder Rooster", "Frostbite Hen", "Magma Rooster",
            "Prism Rooster", "Quake Rooster", "Sandstorm Rooster", "Sergeant Hen",
            "Static Chick", "Tsunami Hen", "Twister Hen", "Viking Rooster"
        },
        ["Trick Egg"] = {
            "Ace Rooster", "Checkmate Hen", "Domino Chick", "High Roller Rooster",
            "Puzzle Hen"
        },
        ["Trophy Egg"] = {
            "Banner Hen", "Bulwark Hen", "Duelist Rooster", "Grandmaster Rooster",
            "Squire Chick"
        },
        ["Void Egg"] = {
            "Alien Chick", "Astro Chick", "Comet Rooster", "Moonwalk Hen",
            "Nebula Hen", "Orbital Hen", "Probe Rooster", "Singularity Hen",
            "Solar Rooster", "Voidbeak"
        }
    }

    local function cleanEggName(name)
        if type(name) == "table" then
            name = name.Title or name.Name or name[1] or ""
        end
        if not name or type(name) ~= "string" then return "" end
        local clean = name:gsub("%s*%(.*%)", ""):gsub("%s*[xX]%d+", ""):gsub("^%s*(.-)%s*$", "%1")
        local off = VALID_OFFICIAL_EGGS[clean:upper()]
        return off or clean
    end

    local function getEggPool(eggName)
        local clean = cleanEggName(eggName)
        if clean == "" then
            clean = "Fortune Egg"
        end

        local pool = STATIC_EGG_POOLS[clean]
        if not pool then
            local cleanLower = clean:lower():gsub("%s*egg$", "")
            for k, p in pairs(STATIC_EGG_POOLS) do
                local kLower = k:lower():gsub("%s*egg$", "")
                if cleanLower == kLower then
                    pool = p
                    break
                end
            end
        end

        local result = {}
        if pool and #pool > 0 then
            for _, sp in ipairs(pool) do
                table.insert(result, sp)
            end
        else
            table.insert(result, "Classic Rooster")
        end

        table.sort(result)
        return result
    end



    UpdateHub.scanPlayerOwnedEggs = function()
        local detectedMap = {}
        local detectedList = {}

        local function addEgg(offName, qtyStr)
            if not detectedMap[offName] then
                detectedMap[offName] = true
                local disp = offName
                if qtyStr and qtyStr ~= "" then
                    local cleanQty = qtyStr:gsub("^%s*(.-)%s*$", "%1"):lower()
                    if not cleanQty:find("^x") then
                        cleanQty = "x" .. cleanQty
                    end
                    disp = string.format("%s (%s)", offName, cleanQty)
                end
                table.insert(detectedList, disp)
            end
        end

        -- [1] SCAN INSTAN VIA DATASERVICE (0ms, SANGAT SMOOTH TANPA FREEZE)
        pcall(function()
            local dsClient = getSharedDataServiceClient()
            local raw = dsClient and dsClient._data and dsClient._data._data
            if raw then
                local eggTbl = raw.eggs or (raw.roster and raw.roster.eggs) or (raw.inventory and raw.inventory.eggs)
                if type(eggTbl) == "table" then
                    for k, v in pairs(eggTbl) do
                        local count = 0
                        if type(v) == "number" then
                            count = v
                        elseif type(v) == "table" then
                            count = tonumber(v.count or v.amount or v.qty or v[1]) or 0
                        end
                        if count > 0 then
                            local eggId = tostring(k):lower():gsub("_egg$", ""):gsub("%s*egg$", "")
                            local offName = EGG_NAME_BY_ID[eggId] or VALID_OFFICIAL_EGGS[tostring(k):upper()]
                            if offName then
                                addEgg(offName, "x" .. tostring(count))
                            end
                        end
                    end
                end
            end
        end)

        -- [2] SCAN VIA PLAYERGUI FLOCK / INVENTORY (RINGAN & SHALLOW, TIDAK MEMBEBANI ENGINE)
        pcall(function()
            local pg = player:FindFirstChild("PlayerGui")
            if not pg then return end

            for _, desc in ipairs(pg:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                    local tUpper = desc.Text:upper():gsub("^%s*(.-)%s*$", "%1")
                    local offName = VALID_OFFICIAL_EGGS[tUpper]
                    if offName then
                        local fn = desc:GetFullName()
                        if not fn:find("Index") and not fn:find("Templates") and not fn:find("Shop") then
                            local card = desc.Parent
                            local qty = nil
                            if card then
                                for _, sib in ipairs(card:GetChildren()) do
                                    if sib:IsA("TextLabel") and sib ~= desc then
                                        local st = sib.Text:gsub("^%s*(.-)%s*$", "%1")
                                        if st:match("^[xX]%d+$") or st:match("^%d+$") then
                                            qty = st
                                            break
                                        end
                                    end
                                end
                                if not qty then
                                    for _, sib in ipairs(card:GetChildren()) do
                                        if sib:IsA("GuiObject") then
                                            for _, sub in ipairs(sib:GetChildren()) do
                                                if sub:IsA("TextLabel") and sub ~= desc then
                                                    local st = sub.Text:gsub("^%s*(.-)%s*$", "%1")
                                                    if st:match("^[xX]%d+$") or st:match("^%d+$") then
                                                        qty = st
                                                        break
                                                    end
                                                end
                                            end
                                            if qty then break end
                                        end
                                    end
                                end
                            end
                            if qty then
                                addEgg(offName, qty)
                            end
                        end
                    end
                end
            end
        end)

        if #detectedList == 0 then
            return {"Buka menu Flock di game lalu klik Refresh Telur"}
        end

        table.sort(detectedList)
        return detectedList
    end

    local function snapshotFlockIds()
        local ids = {}
        local gotFromDs = false
        pcall(function()
            local dsClient = getSharedDataServiceClient()
            local raw = dsClient and dsClient._data and dsClient._data._data
            if raw and raw.roster and raw.roster.chickens and type(raw.roster.chickens) == "table" then
                for _, ch in pairs(raw.roster.chickens) do
                    if type(ch) == "table" and ch.id then
                        local cId = tostring(ch.id)
                        ids[cId] = true
                        local numId = tonumber(string.match(cId, "%d+"))
                        if numId then
                            ids[numId] = true
                        end
                        gotFromDs = true
                    end
                end
            end
        end)
        -- Fallback hanya jika DataService kosong/tidak ada
        if not gotFromDs then
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, desc in ipairs(playerGui:GetDescendants()) do
                        local matchNum = string.match(desc.Name, "^c(%d+)$")
                        if matchNum and (desc:IsA("Frame") or desc:IsA("GuiObject") or desc:IsA("TextButton")) then
                            ids[desc.Name] = true
                            local numId = tonumber(matchNum)
                            if numId then
                                ids[numId] = true
                            end
                        end
                    end
                end
            end)
        end
        return ids
    end

    -- AUTO SELL FILTER: HANYA jual ayam BARU yang menetas saat open egg dan tidak dipilih
    -- AYAM YANG SUDAH ADA DI KAWANAN SEBELUM BUKA TELUR 100% AMAN & TIDAK DIJUAL!
    UpdateHub.executeHatchAutoFilter = function(preHatchSnapshot)
        -- KEAMANAN MUTLAK: Jika tidak ada snapshot pre-hatch, jangan pernah jual ayam apa pun!
        if not preHatchSnapshot or not next(preHatchSnapshot) then
            return 0
        end

        local toSellList = {}
        local keepCount = 0
        local processedFromDs = false

        -- Engine 1: Cek langsung via DataService memory (0ms, sangat ringan tanpa freeze)
        pcall(function()
            local dsClient = getSharedDataServiceClient()
            local raw = dsClient and dsClient._data and dsClient._data._data
            if raw and raw.roster and raw.roster.chickens and type(raw.roster.chickens) == "table" then
                processedFromDs = true
                for k, ch in pairs(raw.roster.chickens) do
                    local cId = tostring((type(ch) == "table" and ch.id) or k)
                    local numId = tonumber(string.match(cId, "%d+"))

                    -- JIKA SUDAH ADA DI KAWANAN SEBELUM BUKA TELUR -> LEWATI (100% TIDAK DIJUAL)!
                    local isPreExisting = preHatchSnapshot[cId] or (numId and preHatchSnapshot[numId])
                    if not isPreExisting and type(ch) == "table" then
                        local speciesName = formatSpeciesName(ch.typeId)
                        local stars = tonumber(ch.promo) or 0
                        local isFav = (ch.favorite == true) or favoritedChickenIds[cId] or (numId and favoritedChickenIds[numId])
                        local isProm = (stars > 0) or promotedChickenIds[cId] or (numId and promotedChickenIds[numId])

                        if not isFav and not isProm then
                            local isInverted = false
                            if ch.mutation then
                                local m = type(ch.mutation) == "string" and ch.mutation or (type(ch.mutation) == "table" and ch.mutation.name)
                                if m and tostring(m):lower():find("inverted") then
                                    isInverted = true
                                end
                            end

                            local shouldKeep = false
                            if isInverted and UpdateHub.autoKeepInverted then
                                shouldKeep = true
                            end

                            if not shouldKeep then
                                local normCName = speciesName:upper()
                                for keepName, isKeep in pairs(UpdateHub.selectedKeepSpecies) do
                                    if isKeep == true then
                                        local normKeep = keepName:upper()
                                        if normCName == normKeep or normCName:find(normKeep) or normKeep:find(normCName) then
                                            shouldKeep = true
                                            break
                                        end
                                    end
                                end
                            end

                            if shouldKeep then
                                keepCount = keepCount + 1
                            else
                                table.insert(toSellList, { idStr = cId, idNum = numId, name = speciesName })
                            end
                        end
                    end
                end
            end
        end)

        -- Engine 2: Fallback cek via PlayerGui (hanya jika DataService tidak aktif)
        if not processedFromDs and #toSellList == 0 then
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if not playerGui then return end

                for _, desc in ipairs(playerGui:GetDescendants()) do
                    local matchNum = string.match(desc.Name, "^c(%d+)$")
                    if matchNum and (desc:IsA("Frame") or desc:IsA("GuiObject") or desc:IsA("TextButton")) then
                        local cId = desc.Name
                        local numId = tonumber(matchNum)

                        local isPreExisting = preHatchSnapshot[cId] or (numId and preHatchSnapshot[numId])
                        if not isPreExisting then
                            local cName = nil
                            for _, child in ipairs(desc:GetChildren()) do
                                if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                                    local t = child.Text:gsub("^%s*(.-)%s*$", "%1")
                                    local tl = t:lower()
                                    if not tl:find("lvl") and not tl:find("lv") and not tl:find("^x%d+") and not tl:find("%$") and not tl:find("^%+") and #t > 1 and tl ~= "chicken name" then
                                        cName = t
                                        break
                                    end
                                end
                            end

                            if cName then
                                local isFav = favoritedChickenIds[cId] or (numId and favoritedChickenIds[numId]) or desc:GetAttribute("Favorite") == true or desc:FindFirstChild("Favorite")
                                local isPromoted = isChickenPromoted(desc, cId, numId)

                                if not isFav and not isPromoted then
                                    local isInverted = false
                                    local attrMut = desc:GetAttribute("Mutation") or desc:GetAttribute("mutation")
                                    if attrMut and type(attrMut) == "string" and attrMut:lower():find("inverted") then
                                        isInverted = true
                                    else
                                        for _, child in ipairs(desc:GetChildren()) do
                                            if child:IsA("TextLabel") and child.Text and child.Text:lower():find("inverted") then
                                                isInverted = true
                                                break
                                            end
                                        end
                                    end

                                    local shouldKeep = false
                                    if isInverted and UpdateHub.autoKeepInverted then
                                        shouldKeep = true
                                    end

                                    if not shouldKeep then
                                        local normCName = cName:upper()
                                        for keepName, isKeep in pairs(UpdateHub.selectedKeepSpecies) do
                                            if isKeep == true then
                                                local normKeep = keepName:upper()
                                                if normCName == normKeep or normCName:find(normKeep) or normKeep:find(normCName) then
                                                    shouldKeep = true
                                                    break
                                                end
                                            end
                                        end
                                    end

                                    if shouldKeep then
                                        keepCount = keepCount + 1
                                    else
                                        table.insert(toSellList, {
                                            idStr = cId,
                                            idNum = numId,
                                            name = cName
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        if #toSellList > 0 then
            local allStrIds = {}
            for _, it in ipairs(toSellList) do
                table.insert(allStrIds, it.idStr)
            end

            -- Eksekusi penjualan dalam background thread terpisah tanpa membekukan main render thread
            task.spawn(function()
                pcall(function()
                    invokeRemote("SellChickens", allStrIds)
                end)

                printLog("Auto Open Egg", string.format("Filter selesai: %d ayam baru disimpan, %d ayam baru non-pilihan berhasil dijual!", keepCount, #toSellList))
                notify("Auto Open Egg", string.format("%d ayam baru non-pilihan berhasil dijual (Ayam lama tetap aman)!", #toSellList))

                -- Defer scanFlockChickens secara halus di background (0.5s) agar render UI 100% mulus (60 FPS)
                task.delay(0.5, function()
                    pcall(scanFlockChickens)
                end)
            end)
        end

        return #toSellList
    end

    -- FUNGSI HATCH 1X, 10X, MAX (DENGAN JEDA DEFAULT AMAN ANTI-FREEZE)
    local HATCH_WAIT_1X  = 0.8
    local HATCH_WAIT_10X = 1.2
    local HATCH_WAIT_MAX = 1.6

    UpdateHub.executeHatchSingle = function(eggName)
        local preSnapshot = snapshotFlockIds()
        local targetEgg = eggName or UpdateHub.selectedEggType
        local cleanName = cleanEggName(targetEgg)
        local eggId = EGG_ID_BY_NAME[cleanName] or cleanName:lower():gsub("%s+", "_")
        task.spawn(function()
            pcall(function()
                local ok = invokeRemote("HatchEggs", eggId, 1)
                if not ok then
                    invokeRemote("HatchEgg", eggId)
                end
            end)
        end)
        task.wait(HATCH_WAIT_1X)
        task.spawn(function()
            UpdateHub.executeHatchAutoFilter(preSnapshot)
        end)
    end

    UpdateHub.executeHatchTen = function(eggName)
        local preSnapshot = snapshotFlockIds()
        local targetEgg = eggName or UpdateHub.selectedEggType
        local cleanName = cleanEggName(targetEgg)
        local eggId = EGG_ID_BY_NAME[cleanName] or cleanName:lower():gsub("%s+", "_")
        task.spawn(function()
            pcall(function()
                local ok = invokeRemote("HatchEggs", eggId, 10)
                if not ok then
                    invokeRemote("HatchEgg", eggId, 10)
                end
            end)
        end)
        task.wait(HATCH_WAIT_10X)
        task.spawn(function()
            UpdateHub.executeHatchAutoFilter(preSnapshot)
        end)
    end

    UpdateHub.executeAutoHatchMax = function(eggName)
        if UpdateHub.isHatchingEggs then
            return
        end
        UpdateHub.isHatchingEggs = true
        local preSnapshot = snapshotFlockIds()
        task.spawn(function()
            pcall(function()
                local targetEgg = eggName or UpdateHub.selectedEggType
                local cleanName = cleanEggName(targetEgg)
                local eggId = EGG_ID_BY_NAME[cleanName] or cleanName:lower():gsub("%s+", "_")
                local pg = player:FindFirstChild("PlayerGui")
                local colGui = pg and (pg:FindFirstChild("Collection") or pg:FindFirstChild("EggGui") or pg:FindFirstChild("Egg"))
                if colGui then
                    local openMaxBtn = colGui:FindFirstChild("OpenMax", true) or colGui:FindFirstChild("HatchMax", true)
                    if openMaxBtn and (openMaxBtn:IsA("TextButton") or openMaxBtn:IsA("ImageButton")) then
                        if firesignal then
                            firesignal(openMaxBtn.Activated)
                            firesignal(openMaxBtn.MouseButton1Click)
                        end
                    end
                end
                local ok = invokeRemote("HatchEggs", eggId, "max")
                if not ok then
                    invokeRemote("HatchEggs", eggId, 100)
                end
                printLog("Eggs", "Hatch Eggs (" .. tostring(cleanName) .. " / " .. tostring(eggId) .. ") Max dieksekusi!")
            end)
        end)
        task.wait(HATCH_WAIT_MAX)
        task.spawn(function()
            UpdateHub.executeHatchAutoFilter(preSnapshot)
            UpdateHub.isHatchingEggs = false
        end)
    end

    local initialEggList = UpdateHub.scanPlayerOwnedEggs()
    if #initialEggList > 0 and initialEggList[1] ~= "Buka menu Flock di game lalu klik Refresh Telur" then
        UpdateHub.selectedEggType = initialEggList[1]
    else
        UpdateHub.selectedEggType = "Fortune Egg"
    end

    local initialPool = getEggPool(UpdateHub.selectedEggType)
    UpdateHub.selectedKeepSpecies = {}
    for _, sp in ipairs(initialPool) do
        UpdateHub.selectedKeepSpecies[sp] = true
    end

    local function syncKeepDropdown(newPool)
        if not UpdateHub.eggKeepDropdown then return end
        pcall(function()
            if type(UpdateHub.eggKeepDropdown.Refresh) == "function" then
                UpdateHub.eggKeepDropdown:Refresh(newPool)
            end
            if type(UpdateHub.eggKeepDropdown.Select) == "function" then
                UpdateHub.eggKeepDropdown:Select(newPool)
            elseif type(UpdateHub.eggKeepDropdown.SetValue) == "function" then
                UpdateHub.eggKeepDropdown:SetValue(newPool)
            end
            if expandDropdown then
                expandDropdown(UpdateHub.eggKeepDropdown, 300)
            end
        end)
    end

    -- 1. TIPE TELUR & DETEKSI TELUR DI KAWANAN
    UpdateHub.eggDropdown = OpenEggSec:Dropdown({
        Title = "Tipe Telur (Pilih Telur):",
        Values = initialEggList,
        Value = UpdateHub.selectedEggType,
        MenuWidth = 300,
        Multi = false,
        Callback = function(val)
            local chosenStr = (type(val) == "table" and (val.Title or val.Name or val[1])) or val
            if not chosenStr or chosenStr == "" then return end
            UpdateHub.selectedEggType = chosenStr
            local cleanName = cleanEggName(chosenStr)
            local newPool = getEggPool(cleanName)
            UpdateHub.selectedKeepSpecies = {}
            for _, sp in ipairs(newPool) do
                UpdateHub.selectedKeepSpecies[sp] = true
            end
            syncKeepDropdown(newPool)
        end
    })
    if expandDropdown then
        expandDropdown(UpdateHub.eggDropdown, 300)
    end

    OpenEggSec:Button({
        Title = "Deteksi / Refresh Telur Dimiliki",
        Callback = function()
            local detected = UpdateHub.scanPlayerOwnedEggs()
            if UpdateHub.eggDropdown then
                pcall(function()
                    if type(UpdateHub.eggDropdown.Refresh) == "function" then
                        UpdateHub.eggDropdown:Refresh(detected)
                    elseif type(UpdateHub.eggDropdown.SetValues) == "function" then
                        UpdateHub.eggDropdown:SetValues(detected)
                    end
                    if expandDropdown then
                        expandDropdown(UpdateHub.eggDropdown, 300)
                    end
                end)
            end
            if #detected > 0 and detected[1] ~= "Buka menu Flock di game lalu klik Refresh Telur" then
                notify("Auto Open Egg", "Berhasil mendeteksi " .. tostring(#detected) .. " jenis telur di kawanan!")
                local cur = UpdateHub.selectedEggType
                local match = false
                for _, egg in ipairs(detected) do
                    if egg == cur then
                        match = true
                        break
                    end
                end
                if not match and detected[1] then
                    UpdateHub.selectedEggType = detected[1]
                    local cleanName = cleanEggName(detected[1])
                    local newPool = getEggPool(cleanName)
                    UpdateHub.selectedKeepSpecies = {}
                    for _, sp in ipairs(newPool) do
                        UpdateHub.selectedKeepSpecies[sp] = true
                    end
                    syncKeepDropdown(newPool)
                end
            else
                notify("Auto Open Egg", "Buka menu Flock di game lalu klik Refresh Telur!")
            end
        end
    })

    -- 2. DROPDOWN LIST JENIS AYAM DARI TELUR & FILTER SIMPAN
    UpdateHub.eggKeepDropdown = OpenEggSec:Dropdown({
        Title = "Ayam yang Ingin Disimpan (Keep):",
        Values = initialPool,
        Value = initialPool,
        MenuWidth = 300,
        Multi = true,
        Callback = function(list)
            UpdateHub.selectedKeepSpecies = {}
            if type(list) == "table" then
                for k, v in pairs(list) do
                    if type(k) == "string" and v == true then
                        UpdateHub.selectedKeepSpecies[k] = true
                    elseif type(v) == "string" then
                        UpdateHub.selectedKeepSpecies[v] = true
                    end
                end
            elseif type(list) == "string" then
                UpdateHub.selectedKeepSpecies[list] = true
            end
        end
    })
    if expandDropdown then
        expandDropdown(UpdateHub.eggKeepDropdown, 300)
    end

    -- 3. TRIGGER / TOGGLE AUTO SIMPAN SEMUA AYAM INVERTED
    OpenEggSec:Toggle({
        Title = "Auto Simpan Semua Ayam Inverted [🌀]",
        Value = UpdateHub.autoKeepInverted,
        Callback = function(state)
            UpdateHub.autoKeepInverted = parseToggle(state)
            if UpdateHub.autoKeepInverted then
                notify("Auto Open Egg", "Ayam mutasi Inverted [🌀] akan selalu disimpan!")
            else
                notify("Auto Open Egg", "Ayam mutasi Inverted TIDAK diproteksi khusus.")
            end
        end
    })

    -- 4. BUTTON OPEN 1X
    OpenEggSec:Button({
        Title = "Buka Telur (1x)",
        Callback = function()
            notify("Auto Open Egg", "Membuka 1x " .. tostring(UpdateHub.selectedEggType) .. "...")
            task.spawn(function()
                UpdateHub.executeHatchSingle(UpdateHub.selectedEggType)
            end)
        end
    })

    -- 5. BUTTON OPEN 10X
    OpenEggSec:Button({
        Title = "Buka Telur (10x)",
        Callback = function()
            notify("Auto Open Egg", "Membuka 10x " .. tostring(UpdateHub.selectedEggType) .. "...")
            task.spawn(function()
                UpdateHub.executeHatchTen(UpdateHub.selectedEggType)
            end)
        end
    })

    -- 6. BUTTON OPEN MAX
    OpenEggSec:Button({
        Title = "Buka Telur (Max)",
        Callback = function()
            notify("Auto Open Egg", "Membuka Max " .. tostring(UpdateHub.selectedEggType) .. "...")
            task.spawn(function()
                UpdateHub.executeAutoHatchMax(UpdateHub.selectedEggType)
            end)
        end
    })
end

-- ==============================================================================
-- [TAB 3: FARM]
-- ==============================================================================
do
    local SweepSec = FarmTab:Section({
        Title = "Auto Sweep Items",
        Opened = false
    })

SweepSec:Toggle({ 
    Title = "Auto Sweep Items", 
    Callback = function(state) 
        autoSweep = parseToggle(state) 
        if not autoSweep and not autoRebirthSurplus then
            disableNoclip()
        end 
    end 
})

SweepSec:Input({
    Title = "Max Bag Capacity",
    Value = tostring(MAX_CAPACITY),
    Callback = function(text)
        MAX_CAPACITY = tonumber(text) or MAX_CAPACITY
    end
})

local TowerSec = FarmTab:Section({
    Title = "Auto Tower",
    Opened = false
})

TowerSec:Toggle({
    Title = "Auto Tower",
    Callback = function(state)
        autoTower = parseToggle(state)
    end
})

TowerSec:Input({
    Title = "Retreat At Floor",
    Value = tostring(retreatFloor),
    Callback = function(text)
        retreatFloor = tonumber(text) or retreatFloor
    end
})

local SellSec = FlockTab:Section({
    Title = "Auto Sell Ayam",
    Opened = false
})

SellSec:Button({
    Title = "Jual Ayam Sesuai Filter Sekarang",
    Callback = function()
        local count = executeSellChickens(true)
        notify("Auto Sell", count .. " ayam berhasil dijual!")
    end
})

SellSec:Toggle({
    Title = "Auto Sell Ayam",
    Callback = function(state)
        autoSellChickens = parseToggle(state)
    end
})

SellSec:Dropdown({
    Title = "Rarity Dijual:",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Celestial", "Cosmic", "Secret"},
    Value = {"Common", "Uncommon"},
    Multi = true,
    Callback = function(list)
        for k in pairs(selectedSellRarities) do
            selectedSellRarities[k] = false
        end
        if type(list) == "table" then
            for k, v in pairs(list) do
                if type(k) == "string" and v == true then
                    selectedSellRarities[k] = true
                elseif type(v) == "string" then
                    selectedSellRarities[v] = true
                end
            end
        end
    end
})

SellSec:Input({
    Title = "Sell Delay (s)",
    Value = tostring(delaySellChicken),
    Callback = function(text)
        delaySellChicken = tonumber(text) or delaySellChicken
    end
})

UpdateHub.getChickenArenaPower = function(ch)
    if not ch or type(ch) ~= "table" then
        return 0, "0"
    end

    local powerNum = 0
    local powerStr = "0"

    pcall(function()
        local featFolder = ReplicatedStorage:FindFirstChild("Features")
        local arenaFeat = featFolder and featFolder:FindFirstChild("Arena")
        local arenaViewMod = arenaFeat and arenaFeat:FindFirstChild("ArenaView")
        if arenaViewMod then
            local ok, ArenaView = pcall(function() return require(arenaViewMod) end)
            if ok and ArenaView and ArenaView.chickenPower then
                local res = ArenaView.chickenPower(ch)
                if type(res) == "number" then
                    powerNum = res
                    powerStr = tostring(math.floor(res))
                elseif type(res) == "table" or type(res) == "userdata" then
                    if res.toNumber then
                        local okNum, n = pcall(function() return res:toNumber() end)
                        if okNum and n and n == n and n ~= (1/0) and n ~= (-1/0) then
                            powerNum = n
                        end
                    end
                    if powerNum == 0 and res.mantissa and res.exponent then
                        local m = tonumber(res.mantissa) or 1
                        local e = tonumber(res.exponent) or 0
                        powerNum = (e * 1e7) + m
                    end
                    powerStr = tostring(res)
                end
            end
        end
    end)

    if powerNum == 0 then
        local lvl = tonumber(ch.level) or 1
        local promo = tonumber(ch.promo) or 0
        powerNum = (lvl * 100) + (promo * 500)
        if powerStr == "0" then
            powerStr = tostring(powerNum)
        end
    end

    return powerNum, powerStr
end

UpdateHub.executeEquipBestArenaTeam = function()
    local ok, err = pcall(function()
        local dsClient = getSharedDataServiceClient()
        local raw = dsClient and dsClient._data and dsClient._data._data
        local chickens = raw and raw.roster and raw.roster.chickens
        if not chickens or type(chickens) ~= "table" or not next(chickens) then
            notify("Arena", "Gagal memuat data ayam dari memori!")
            return
        end

        local teamSize = 3
        pcall(function()
            local contentFolder = ReplicatedStorage:FindFirstChild("Content")
            local arenaContent = contentFolder and contentFolder:FindFirstChild("Arena")
            if arenaContent then
                local okA, Arena = pcall(function() return require(arenaContent) end)
                if okA and Arena and Arena.team and Arena.team.size then
                    teamSize = tonumber(Arena.team.size) or 3
                end
            end
        end)

        local chickenList = {}
        for k, ch in pairs(chickens) do
            if type(ch) == "table" then
                local cId = ch.id or k
                local pNum, pStr = UpdateHub.getChickenArenaPower(ch)
                local sName = formatSpeciesName(ch.typeId)
                table.insert(chickenList, {
                    id = cId,
                    ch = ch,
                    powerNum = tonumber(pNum) or 0,
                    powerStr = tostring(pStr or "0"),
                    name = sName,
                    level = tonumber(ch.level) or 1,
                    promo = tonumber(ch.promo) or 0,
                })
            end
        end

        if #chickenList == 0 then
            notify("Arena", "Tidak ada ayam yang ditemukan di kawanan!")
            return
        end

        -- STRICT WEAK ORDERING: Terjamin tidak pernah memicu 'invalid order function for sorting'
        table.sort(chickenList, function(a, b)
            local pa = a.powerNum or 0
            local pb = b.powerNum or 0
            if pa ~= pb then
                return pa > pb
            end
            return tostring(a.id) > tostring(b.id)
        end)

        local bestTeam = {}
        local teamIds = {}
        local numTeamIds = {}
        local summaryLines = {}

        local count = math.min(teamSize, #chickenList)
        for i = 1, count do
            local entry = chickenList[i]
            table.insert(bestTeam, entry)
            table.insert(teamIds, entry.id)
            local nId = tonumber(tostring(entry.id):match("%d+")) or entry.id
            table.insert(numTeamIds, nId)

            local starStr = entry.promo > 0 and string.format(" [%d★]", entry.promo) or ""
            table.insert(summaryLines, string.format("#%d: %s (Lv.%d%s | Power: %s)", i, entry.name, entry.level, starStr, entry.powerStr))
        end

        local setSuccess = false
        pcall(function()
            local res = invokeRemote("ArenaSetTeam", teamIds)
            if res then setSuccess = true end
        end)
        if not setSuccess then
            pcall(function()
                local res = invokeRemote("ArenaSetTeam", unpack(teamIds))
                if res then setSuccess = true end
            end)
        end
        if not setSuccess then
            pcall(function()
                local res = invokeRemote("ArenaSetTeam", numTeamIds)
                if res then setSuccess = true end
            end)
        end
        if not setSuccess then
            pcall(function()
                local res = invokeRemote("ArenaSetTeam", unpack(numTeamIds))
                if res then setSuccess = true end
            end)
        end

        local summaryText = table.concat(summaryLines, "\n")
        printLog("Arena", "Tim Arena Terbaik Berhasil Dipasang:\n" .. summaryText)
        notify("Arena", string.format("Tim Arena terbaik (%d ayam) berhasil dipasang!\n%s", count, summaryLines[1] or ""))
    end)
    if not ok then
        logError("executeEquipBestArenaTeam", err)
        notify("Arena", "Terjadi kendala saat memasang tim arena: " .. tostring(err))
    end
end

UpdateHub.executeArenaAutoFight = function()
    if UpdateHub.isArenaFightRunning then
        return
    end
    UpdateHub.isArenaFightRunning = true
    pcall(function()
        local view = invokeRemote("ArenaGetView")
        local targetOpponentId = nil
        if type(view) == "table" then
            local opponents = view.opponents or view.list or view.players or view
            if type(opponents) == "table" then
                local bestRating = math.huge
                for k, opp in pairs(opponents) do
                    if type(opp) == "table" then
                        local oppId = opp.id or opp.userId or opp.playerId or k
                        local rating = tonumber(opp.rating or opp.power or opp.score or opp.level) or 999999
                        if rating < bestRating then
                            bestRating = rating
                            targetOpponentId = oppId
                        end
                    end
                end
            end
        end

        if targetOpponentId then
            invokeRemote("ArenaFight", targetOpponentId)
        else
            invokeRemote("ArenaFight", 1)
            invokeRemote("ArenaFight")
        end

        task.wait(0.2)
        invokeRemote("ArenaSkip")
        invokeRemote("SetArenaAutoAbility", true)
        printLog("Arena", "Arena battle dieksekusi!")
    end)
    UpdateHub.isArenaFightRunning = false
end

local ArenaBattleSec = FarmTab:Section({
    Title = "Auto Arena Battle",
    Opened = false
})

ArenaBattleSec:Button({
    Title = "Gunakan Ayam Terbaik (Equip Best Team)",
    Callback = function()
        task.spawn(UpdateHub.executeEquipBestArenaTeam)
    end
})

ArenaBattleSec:Toggle({
    Title = "Auto Arena Fight",
    Callback = function(state)
        UpdateHub.autoArenaFight = parseToggle(state)
    end
})

ArenaBattleSec:Input({
    Title = "Fight Delay (s)",
    Value = tostring(UpdateHub.delayArenaFight),
    Callback = function(text)
        UpdateHub.delayArenaFight = tonumber(text) or UpdateHub.delayArenaFight
    end
})

ArenaBattleSec:Button({
    Title = "Tantang Lawan Sekarang (1-Fight)",
    Callback = function()
        task.spawn(UpdateHub.executeArenaAutoFight)
        notify("Arena", "Mengeksekusi pertarungan arena...")
    end
})

UpdateHub.isUfoEventActive = function()
    -- 1. Cek event live flag dari network event
    if UpdateHub.ufoEventLive == true then
        return true
    end

    -- 2. Cek remote function LiveEventGetActive
    local rf = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("LiveEventGetActive")
    if not rf then
        rf = ReplicatedStorage:FindFirstChild("LiveEventGetActive", true)
    end
    if rf and rf:IsA("RemoteFunction") then
        local ok, res = pcall(function()
            return rf:InvokeServer()
        end)
        if ok and res then
            local str = ""
            if type(res) == "string" then
                str = res:lower()
            elseif type(res) == "table" then
                for k, v in pairs(res) do
                    str = str .. " " .. tostring(k):lower() .. " " .. tostring(v):lower()
                end
            end
            if str:find("ufo") or str:find("invasion") then
                return true
            end
        end
    end

    -- 3. Cek Workspace untuk objek UFO / Beam / Invasion
    for _, obj in ipairs(Workspace:GetChildren()) do
        local n = obj.Name:lower()
        if (n:find("ufo") or n:find("invasion") or n:find("alien")) and not n:find("chicken") then
            return true
        end
    end
    local world = Workspace:FindFirstChild("World")
    if world then
        for _, obj in ipairs(world:GetChildren()) do
            local n = obj.Name:lower()
            if (n:find("ufo") or n:find("invasion") or n:find("alien")) and not n:find("chicken") then
                return true
            end
        end
    end
    local pit = Workspace:FindFirstChild("Pit") or (world and world:FindFirstChild("Pit"))
    if pit then
        for _, obj in ipairs(pit:GetChildren()) do
            local n = obj.Name:lower()
            if n:find("ufo") or n:find("beam") or n:find("invasion") or n:find("alien") then
                return true
            end
        end
    end

    -- 4. Cek PlayerGui (banner / popup / label UFO INVASION)
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, desc in ipairs(pg:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local txt = (desc.Text or ""):lower()
                if txt:find("ufo invasion") or (txt:find("ufo") and (txt:find("beam") or txt:find("pit") or txt:find("gene") or txt:find("upgrade"))) then
                    return true
                end
            end
        end
    end

    return false
end

UpdateHub.getUfoBeamPosition = function()
    -- 1. Cek langsung part/model Beam atau UFO di Workspace
    local beamPart = nil
    for _, obj in ipairs(Workspace:GetChildren()) do
        local n = obj.Name:lower()
        if (n:find("beam") or n:find("ufo") or n:find("invasion") or n:find("alien")) and not n:find("chicken") then
            if obj:IsA("BasePart") then
                beamPart = obj
                break
            elseif obj:IsA("Model") then
                local b = obj:FindFirstChild("Beam", true) or obj:FindFirstChild("Light", true) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if b and b:IsA("BasePart") then
                    beamPart = b
                    break
                end
            end
        end
    end
    if beamPart then
        return beamPart.Position
    end

    -- 2. Cek Model/Part Pit atau Arena langsung (tempat mendaratnya UFO Invasion)
    local pit = Workspace:FindFirstChild("Pit")
        or (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Pit"))
        or Workspace:FindFirstChild("Arena")
        or (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Arena"))

    if pit then
        if pit:IsA("Model") then
            local floor = pit:FindFirstChild("Floor", true) or pit:FindFirstChild("Base", true) or pit:FindFirstChild("Ground", true)
            if floor and floor:IsA("BasePart") then
                return floor.Position + Vector3.new(0, 1.5, 0)
            end
            local cf, _ = pit:GetBoundingBox()
            return cf.Position + Vector3.new(0, 1.5, 0)
        elseif pit:IsA("BasePart") then
            return pit.Position + Vector3.new(0, 1.5, 0)
        end
    end

    -- 3. Cek posisi tengah dari rata-rata part scrap di PitScrap
    local pitScrap = Workspace:FindFirstChild("PitScrap") or (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("PitScrap"))
    if pitScrap then
        local sumX, sumY, sumZ, count = 0, 0, 0, 0
        for _, desc in ipairs(pitScrap:GetDescendants()) do
            if desc:IsA("BasePart") and (desc.Name == "Loose" or desc.Name:lower():find("scrap")) then
                sumX = sumX + desc.Position.X
                sumY = sumY + desc.Position.Y
                sumZ = sumZ + desc.Position.Z
                count = count + 1
            end
        end
        if count > 0 then
            return Vector3.new(sumX / count, (sumY / count) + 1.5, sumZ / count)
        end
    end

    return Vector3.new(0, 5, 0)
end

UpdateHub.getMyChickenBody = function()
    local chickenFolder = Workspace:FindFirstChild("ChickenBodies")
    if not chickenFolder then
        return nil
    end

    local plotId = player:GetAttribute("Plot") or currentPlotId or 1
    local byName = chickenFolder:FindFirstChild("ChickenBody_coop:" .. tostring(plotId))
    if byName then
        return byName
    end

    for _, c in ipairs(chickenFolder:GetChildren()) do
        local ownerId = c:GetAttribute("ovOwner")
        if ownerId and tonumber(ownerId) == player.UserId then
            return c
        end
    end

    for _, c in ipairs(chickenFolder:GetChildren()) do
        local ownerAttr = c:GetAttribute("Owner") or c:GetAttribute("owner")
        if ownerAttr and string.lower(tostring(ownerAttr)) == string.lower(player.Name) then
            return c
        end
    end

    return nil
end

UpdateHub.getChickenUfoLocation = function()
    local cBody = UpdateHub.getMyChickenBody()
    if not cBody then
        return "AT_BASE"
    end

    -- Jika ayam pingsan/KO oleh UFO beam, berarti sedang/sudah dikirim kembali ke base
    local ovLife = cBody:GetAttribute("ovLife")
    local hpFrac = cBody:GetAttribute("ovHpFrac")
    if ovLife == false or (hpFrac and type(hpFrac) == "number" and hpFrac <= 0) then
        return "AT_BASE"
    end

    local cPos = (cBody:IsA("Model") and cBody:GetPivot().Position) or (cBody:IsA("BasePart") and cBody.Position)
    if not cPos then
        return "AT_BASE"
    end

    -- Dapatkan posisi Pit / Arena tengah
    local pit = Workspace:FindFirstChild("Pit") or (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Pit"))
    local pitPos = (pit and (pit:IsA("Model") and pit:GetPivot().Position or pit.Position)) or Vector3.new(0, 5, 0)
    local distToPit = (cPos - pitPos).Magnitude

    -- Dapatkan posisi Base / Coop pemain
    local plotId = player:GetAttribute("Plot") or currentPlotId or 1
    local coopsFolder = Workspace:FindFirstChild("Coops")
    local myCoop = coopsFolder and coopsFolder:FindFirstChild("Coop" .. tostring(plotId))
    local basePos = nil
    if myCoop then
        basePos = myCoop:GetPivot().Position
    else
        local plots = Workspace:FindFirstChild("Plots") or (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Plots"))
        local myPlot = plots and plots:FindFirstChild("Plot" .. tostring(plotId))
        if myPlot then
            basePos = myPlot:GetPivot().Position
        end
    end

    if distToPit < 65 then
        return "IN_CHAOS"
    end

    if basePos then
        local distToBase = (cPos - basePos).Magnitude
        if distToBase < 65 then
            return "AT_BASE"
        end
    else
        if distToPit > 85 then
            return "AT_BASE"
        end
    end

    return "IN_TRANSIT"
end

UpdateHub.executeSendChickenToUfoBeam = function(silent)
    if UpdateHub.isUfoRunning then
        return
    end
    UpdateHub.isUfoRunning = true

    local success, err = pcall(function()
        local targetName = UpdateHub.selectedUfoChickenName
        if not targetName or not chickenMap[targetName] then
            if not chickenNames or #chickenNames == 0 or chickenNames[1] == "Belum di-refresh (Klik tombol Refresh)" or chickenNames[1] == "Buka menu Flock di game lalu klik Refresh!" then
                scanFlockChickens()
            end
            if chickenNames and #chickenNames > 0 and chickenNames[1] ~= "Tidak ada ayam" and chickenNames[1] ~= "Belum di-refresh (Klik tombol Refresh)" and chickenNames[1] ~= "Buka menu Flock di game lalu klik Refresh!" then
                targetName = UpdateHub.selectedUfoChickenName or chickenNames[1]
                UpdateHub.selectedUfoChickenName = targetName
            end
        end

        local targetData = targetName and chickenMap[targetName]
        if targetData and targetData.Id then
            local cId = targetData.Id
            local numId = targetData.NumId or tonumber(string.match(tostring(cId), "%d+"))

            -- [1] Buat ayam yang dipilih menjadi aktif (Active Rooster) & Equip
            invokeRemote("SetActiveChicken", cId)
            if numId and numId ~= cId then
                invokeRemote("SetActiveChicken", numId)
            end
            invokeRemote("Equip", cId)
            if numId and numId ~= cId then
                invokeRemote("Equip", numId)
            end
            if targetData.Button and firesignal then
                pcall(function()
                    firesignal(targetData.Button.MouseButton1Click)
                    firesignal(targetData.Button.Activated)
                end)
            end
            task.wait(0.1)
        end

        -- [2] Kirim ayam HANYA ke arena tengah (Chaos / The Pit)
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("SetChickenOrder") then
                remotes.SetChickenOrder:FireServer("chaos")
            else
                invokeRemote("SetChickenOrder", "chaos")
            end
        end)

        -- Trigger tombol HUD 'pit' / 'TO CHAOS' di PlayerGui jika ada
        pcall(function()
            local pg = player:FindFirstChild("PlayerGui")
            if pg then
                for _, desc in ipairs(pg:GetDescendants()) do
                    if desc:IsA("GuiButton") or desc:IsA("TextButton") or desc:IsA("ImageButton") then
                        local txt = (desc:IsA("TextButton") and desc.Text or ""):lower()
                        local n = desc.Name:lower()
                        if n == "pit" or txt:find("to chaos") or txt:find("chaos") then
                            if firesignal then
                                firesignal(desc.MouseButton1Click)
                                firesignal(desc.Activated)
                            end
                        end
                    elseif desc:IsA("TextLabel") then
                        local txt = (desc.Text or ""):lower()
                        if txt:find("to chaos") or txt:find("chaos") then
                            local parentBtn = desc:FindFirstAncestorWhichIsA("GuiButton")
                            if parentBtn and firesignal then
                                firesignal(parentBtn.MouseButton1Click)
                                firesignal(parentBtn.Activated)
                            end
                        end
                    end
                end
            end
        end)

        UpdateHub.lastUfoSendTime = os.clock()
        UpdateHub.ufoChickenStatus = "SENT_TO_CHAOS"

        if not silent then
            local dispName = targetData and (targetData.Name or targetName) or "Ayam Aktif"
            printLog("Auto UFO Event", string.format("Ayam '%s' aktif & dikirim ke arena tengah (To Chaos)!", dispName))
            notify("Auto UFO Event", string.format("Ayam '%s' aktif & dikirim ke arena tengah (To Chaos)!", dispName))
        end
    end)

    if not success then
        logError("executeSendChickenToUfoBeam", err)
    end

    UpdateHub.isUfoRunning = false
end

local UfoSec = FarmTab:Section({
    Title = "Auto UFO Event",
    Opened = false
})

UfoSec:Paragraph({
    Title = "UFO INVASION Event (To Chaos)",
    Desc = "1. Pilih ayam dari kawanan flock.\n2. Saat Auto UFO aktif, bot mendeteksi event UFO secara otomatis.\n3. Perintah 'To Chaos' dikirim 1x saat ayam berada di base, tanpa spam agar ayam tidak bulak-balik.\n4. Saat ayam selesai di-upgrade & KO kembali ke base, bot otomatis mendeteksi dan mengirim ulang ayam ke tengah arena sampai event selesai."
})

UfoSec:Button({
    Title = "Refresh Daftar Ayam",
    Callback = function()
        scanFlockChickens()
        notify("UFO Event", "Daftar ayam flock berhasil diperbarui!")
    end
})

UpdateHub.ufoChickenDropdown = UfoSec:Dropdown({
    Title = "Pilih Ayam Target UFO:",
    Values = chickenNames,
    Value = chickenNames[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        UpdateHub.selectedUfoChickenName = val
    end
})
if expandDropdown then
    expandDropdown(UpdateHub.ufoChickenDropdown, 300)
end

UfoSec:Button({
    Title = "Kirim Ayam ke Tengah Arena (To Chaos)",
    Callback = function()
        task.spawn(function()
            UpdateHub.executeSendChickenToUfoBeam(false)
        end)
    end
})

UfoSec:Toggle({
    Title = "Auto Deteksi UFO & Kirim Ayam ke Chaos",
    Callback = function(state)
        UpdateHub.autoUfoEvent = parseToggle(state)
        if UpdateHub.autoUfoEvent then
            UpdateHub.ufoChickenStatus = "AT_BASE"
            notify("Auto UFO Event", "Auto UFO Event aktif! Menunggu deteksi event UFO...")
        end
    end
})
end

-- ==============================================================================
-- [TAB 4: CHICKEN]
-- ==============================================================================
do
    local PromoteSec = FlockTab:Section({
        Title = "Auto Promote",
        Opened = false
    })

promoteStatusPara = PromoteSec:Paragraph({
    Title = "Status Persyaratan Promote",
    Desc = "Pilih ayam target di Target Promote dan centang bahan di Bahan Korban."
})

promoteTargetDropdown = PromoteSec:Dropdown({
    Title = "Target Promote:",
    Values = promoteTargetList,
    Value = promoteTargetList[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        selectedPromoteTarget = val
        if updatePromoteFodders then
            updatePromoteFodders(val)
        end
    end
})
if expandDropdown then
    expandDropdown(promoteTargetDropdown, 300)
end

promoteFodderDropdown = PromoteSec:Dropdown({
    Title = "Bahan Korban:",
    Values = promoteFodderList,
    Value = {},
    MenuWidth = 300,
    Multi = true,
    Callback = function(list)
        selectedPromoteFoddersMap = {}
        if type(list) == "table" then
            for k, v in pairs(list) do
                if type(k) == "string" and v == true then
                    selectedPromoteFoddersMap[k] = true
                elseif type(v) == "string" then
                    selectedPromoteFoddersMap[v] = true
                end
            end
        elseif type(list) == "string" then
            selectedPromoteFoddersMap[list] = true
        end
        if updatePromoteStatusDisplay then
            updatePromoteStatusDisplay()
        end
    end
})
if expandDropdown then
    expandDropdown(promoteFodderDropdown, 300)
end

autoPromoteToggle = PromoteSec:Toggle({
    Title = "Auto Promote",
    Callback = function(state)
        autoPromote = parseToggle(state)
    end
})

PromoteSec:Button({
    Title = "Refresh Daftar Ayam Kawanan",
    Callback = function()
        scanFlockChickens()
        notify("Promote", "Daftar kawanan berhasil diperbarui!")
    end
})

local FuseSec = FlockTab:Section({
    Title = "Auto Fuse",
    Opened = false
})

fuseMainDropdown = FuseSec:Dropdown({
    Title = "Ayam Utama:",
    Values = chickenNames,
    Value = chickenNames[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        fuseMainChickenName = val
        if updateAvailableSkills then
            updateAvailableSkills()
        end
    end
})
if expandDropdown then
    expandDropdown(fuseMainDropdown, 300)
end

fuseFodderDropdown = FuseSec:Dropdown({
    Title = "Ayam Bahan:",
    Values = chickenNames,
    Value = chickenNames[2] or chickenNames[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        fuseFodderChickenName = val
        if updateAvailableSkills then
            updateAvailableSkills()
        end
    end
})
if expandDropdown then
    expandDropdown(fuseFodderDropdown, 300)
end

fuseSkillDropdown = FuseSec:Dropdown({
    Title = "Lock Skill:",
    Values = availableFuseSkills,
    Value = availableFuseSkills[1],
    Multi = false,
    Callback = function(val)
        fuseLockedSkill = val
    end
})

FuseSec:Toggle({
    Title = "Auto Fuse",
    Callback = function(state)
        autoFuse = parseToggle(state)
    end
})

local AutoFavSec = ChickenTab:Section({
    Title = "Auto Favorite Chicken",
    Opened = true
})

AutoFavSec:Button({
    Title = "Refresh Daftar Ayam",
    Callback = function()
        scanFlockChickens()
        notify("Favorite", "Daftar ayam flock berhasil diperbarui!")
    end
})

favDropdown = AutoFavSec:Dropdown({
    Title = "Ayam Favorit:",
    Values = chickenNames,
    Value = chickenNames[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        selectedFavChickenName = val
    end
})
if expandDropdown then
    expandDropdown(favDropdown, 300)
end

AutoFavSec:Button({
    Title = "⭐ Kunci Sebagai Ayam Favorit (Lock)",
    Callback = function()
        if selectedFavChickenName and chickenMap[selectedFavChickenName] then
            local targetData = chickenMap[selectedFavChickenName]
            favoritedChickenIds[targetData.Id] = true
            local numId = tonumber(string.match(targetData.Id, "%d+"))
            if numId then
                favoritedChickenIds[numId] = true
            end
            invokeRemote("SetChickenFavorite", targetData.Id, true)
            scanFlockChickens()
            notify("Auto Favorite", "Ayam '" .. tostring(targetData.Name) .. "' BERHASIL DIKUNCI!")
        end
    end
})

AutoFavSec:Button({
    Title = "🔓 Hapus Kunci Favorit (Unlock)",
    Callback = function()
        if selectedFavChickenName and chickenMap[selectedFavChickenName] then
            local targetData = chickenMap[selectedFavChickenName]
            favoritedChickenIds[targetData.Id] = nil
            local numId = tonumber(string.match(targetData.Id, "%d+"))
            if numId then
                favoritedChickenIds[numId] = nil
            end
            invokeRemote("SetChickenFavorite", targetData.Id, false)
            scanFlockChickens()
            notify("Auto Favorite", "Kunci favorit ayam '" .. tostring(targetData.Name) .. "' dilepas.")
        end
    end
})

-- ==============================================================================
-- [CHARMS CATALOG & STATS CONFIGURATION (OFFICIAL DATA)]
-- ==============================================================================
local CHARM_TIER_BY_NAME = {
    ["Semua Tier"] = 1,
    ["Uncommon+"] = 2,
    ["Rare+"] = 3,
    ["Super Rare+"] = 4,
    ["Legendary+"] = 5,
    ["Ascended"] = 6,
}

local CHARM_STAT_DISPLAY_MAP = {
    ["atk"] = "ATK BOOST",
    ["def"] = "DEF BOOST",
    ["hp"] = "HP BOOST",
    ["crit"] = "CRIT% BOOST",
    ["critRes"] = "CRIT RES BOOST",
    ["critDmg"] = "CRIT DMG BOOST",
    ["ability"] = "ABILITY BOOST",
    ["dmgReduction"] = "DMG REDUCTION",
    ["moveSpeed"] = "MOVEMENT SPEED",
}

local CHARM_STAT_ALIAS_MAP = {
    ["atk"] = "atk",
    ["atkboost"] = "atk",
    ["attack"] = "atk",
    ["attackboost"] = "atk",

    ["def"] = "def",
    ["defboost"] = "def",
    ["defense"] = "def",
    ["defenseboost"] = "def",

    ["hp"] = "hp",
    ["hpboost"] = "hp",
    ["health"] = "hp",
    ["healthboost"] = "hp",

    ["crit"] = "crit",
    ["critboost"] = "crit",
    ["crit%"] = "crit",
    ["crit%boost"] = "crit",
    ["critchance"] = "crit",
    ["critrate"] = "crit",

    ["critres"] = "critRes",
    ["critresboost"] = "critRes",
    ["critresistance"] = "critRes",

    ["critdmg"] = "critDmg",
    ["critdmgboost"] = "critDmg",
    ["criticaldamage"] = "critDmg",

    ["ability"] = "ability",
    ["abilityboost"] = "ability",

    ["dmgreduction"] = "dmgReduction",
    ["damagereduction"] = "dmgReduction",
    ["dmgred"] = "dmgReduction",

    ["movespeed"] = "moveSpeed",
    ["movementspeed"] = "moveSpeed",
    ["speed"] = "moveSpeed",
}

local function normalizeCharmStat(statRaw)
    if not statRaw then return nil end
    local clean = tostring(statRaw):lower():gsub("[^%a%d]", "")
    return CHARM_STAT_ALIAS_MAP[clean] or clean
end

local function getCharmTierRank(tierRaw)
    if not tierRaw then return 1 end
    local s = tostring(tierRaw):lower():gsub("[^%a%d]", "")
    if s == "ascended" or s == "a" or s:find("ascend") then return 6 end
    if s == "legendary" or s == "l" or s:find("legend") then return 5 end
    if s == "superrare" or s == "sr" or s:find("super") then return 4 end
    if s == "rare" or s == "r" then return 3 end
    if s == "uncommon" or s == "u" then return 2 end
    if s == "common" or s == "c" then return 1 end
    return 1
end

local function getCharmMinTierRank(minTierStr)
    if not minTierStr then return 4 end
    if CHARM_TIER_BY_NAME[minTierStr] then
        return CHARM_TIER_BY_NAME[minTierStr]
    end
    local s = tostring(minTierStr):lower():gsub("[^%a%d]", "")
    if s:find("ascend") then return 6 end
    if s:find("legend") then return 5 end
    if s:find("super") or s:find("epic") then return 4 end
    if s:find("rare") then return 3 end
    if s:find("uncommon") then return 2 end
    return 1
end

local CHARM_SLOT_STAR_REQS = { 0, 2, 4, 6, 8, 8, 10, 10 }

UpdateHub.executeAutoRollCharms = function()
    if UpdateHub.isCharmRolling or not UpdateHub.selectedCharmChickenName or not chickenMap[UpdateHub.selectedCharmChickenName] then
        return
    end
    UpdateHub.isCharmRolling = true
    pcall(function()
        local targetData = chickenMap[UpdateHub.selectedCharmChickenName]
        local cId = targetData.Id
        if not cId then
            return
        end

        local dsClient = getSharedDataServiceClient()
        local raw = dsClient and dsClient._data and dsClient._data._data
        local chickenObj = nil
        if raw and raw.roster and raw.roster.chickens and type(raw.roster.chickens) == "table" then
            for k, ch in pairs(raw.roster.chickens) do
                if tostring(ch.id) == tostring(cId) or tostring(k) == tostring(cId) then
                    chickenObj = ch
                    break
                end
            end
        end

        if not chickenObj then
            return
        end

        local promo = tonumber(chickenObj.promo) or 0
        local totalAvailableSlots = 0
        local lockedOrSatisfiedCount = 0
        local needsRoll = false
        local minTierRank = getCharmMinTierRank(UpdateHub.charmMinTier)

        for slotIdx = 1, 8 do
            local starReq = CHARM_SLOT_STAR_REQS[slotIdx] or 0
            if starReq <= promo then
                totalAvailableSlots = totalAvailableSlots + 1
                local charm = chickenObj.charms and chickenObj.charms[slotIdx]
                if charm and type(charm) == "table" then
                    local statId = normalizeCharmStat(charm.stat or charm.type or charm.id or charm.name)
                    local tierRank = getCharmTierRank(charm.tier or charm.rarity or charm.tierId or charm.letter)
                    local isLocked = (charm.locked == true)

                    local dispStat = CHARM_STAT_DISPLAY_MAP[statId] or tostring(statId):upper()
                    local matchesStat = (statId and (UpdateHub.charmPreferredStats[statId] == true or UpdateHub.charmPreferredStats[dispStat] == true))
                    local matchesTier = (tierRank >= minTierRank)

                    if matchesStat and matchesTier then
                        if not isLocked then
                            invokeRemote("SetCharmLock", cId, slotIdx, true)
                            local dispTier = (tierRank == 6 and "Ascended") or (tierRank == 5 and "Legendary") or (tierRank == 4 and "Super Rare") or (tierRank == 3 and "Rare") or (tierRank == 2 and "Uncommon") or "Common"
                            printLog("Charms", string.format("Slot %d (%s [%s]) memenuhi kriteria -> di-LOCK!", slotIdx, dispStat, dispTier))
                        end
                        lockedOrSatisfiedCount = lockedOrSatisfiedCount + 1
                    else
                        if isLocked then
                            lockedOrSatisfiedCount = lockedOrSatisfiedCount + 1
                        else
                            needsRoll = true
                        end
                    end
                else
                    needsRoll = true
                end
            end
        end

        if needsRoll and totalAvailableSlots > 0 then
            local rollRes = invokeRemote("RollCharms", cId)
            if rollRes then
                printLog("Charms", string.format("Roll Charms dieksekusi untuk %s (Slot terkunci: %d/%d)", tostring(targetData.Species or targetData.Name), lockedOrSatisfiedCount, totalAvailableSlots))
            end
        else
            if totalAvailableSlots > 0 and lockedOrSatisfiedCount >= totalAvailableSlots then
                printLog("Charms", string.format("Semua slot charm target (%d slot) telah memenuhi kriteria / terkunci!", totalAvailableSlots))
            end
        end
    end)
    UpdateHub.isCharmRolling = false
end

local CharmsSec = FlockTab:Section({
    Title = "Auto Roll Charms & Lock",
    Opened = false
})

CharmsSec:Paragraph({
    Title = "Panduan Auto Roll Charms",
    Desc = "Pilih ayam target, Min Tier, dan Stat yang diinginkan. Sistem otomatis me-lock stat/tier yang sesuai dan me-roll slot yang belum memenuhi syarat."
})

CharmsSec:Button({
    Title = "Refresh Daftar Ayam",
    Callback = function()
        scanFlockChickens()
        notify("Charms", "Daftar ayam flock berhasil diperbarui!")
    end
})

UpdateHub.charmDropdown = CharmsSec:Dropdown({
    Title = "Target Ayam Charms:",
    Values = chickenNames,
    Value = chickenNames[1],
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        UpdateHub.selectedCharmChickenName = val
    end
})
if expandDropdown then
    expandDropdown(UpdateHub.charmDropdown, 300)
end

local charmTierDropdown = CharmsSec:Dropdown({
    Title = "Min Tier Kunci:",
    Values = {"Super Rare+", "Legendary+", "Ascended", "Rare+", "Uncommon+", "Semua Tier"},
    Value = "Super Rare+",
    MenuWidth = 300,
    Multi = false,
    Callback = function(val)
        UpdateHub.charmMinTier = val
    end
})
if expandDropdown then
    expandDropdown(charmTierDropdown, 300)
end

local charmStatDropdown = CharmsSec:Dropdown({
    Title = "Stat Diinginkan (Kunci):",
    Values = {
        "ATK BOOST",
        "HP BOOST",
        "DEF BOOST",
        "CRIT% BOOST",
        "CRIT DMG BOOST",
        "CRIT RES BOOST",
        "ABILITY BOOST",
        "DMG REDUCTION",
        "MOVEMENT SPEED"
    },
    Value = {"ATK BOOST", "HP BOOST", "CRIT% BOOST", "CRIT DMG BOOST"},
    MenuWidth = 300,
    Multi = true,
    Callback = function(list)
        local newPrefs = {}
        if type(list) == "table" then
            for k, v in pairs(list) do
                local item = nil
                if type(k) == "string" and v == true then
                    item = k
                elseif type(v) == "string" then
                    item = v
                end
                if item then
                    local id = normalizeCharmStat(item)
                    if id then
                        newPrefs[id] = true
                    end
                end
            end
        elseif type(list) == "string" then
            local id = normalizeCharmStat(list)
            if id then
                newPrefs[id] = true
            end
        end
        UpdateHub.charmPreferredStats = newPrefs
    end
})
if expandDropdown then
    expandDropdown(charmStatDropdown, 300)
end

CharmsSec:Toggle({
    Title = "Auto Roll Charms",
    Callback = function(state)
        UpdateHub.autoRollCharms = parseToggle(state)
    end
})

CharmsSec:Button({
    Title = "Roll Charms Sekarang (1x)",
    Callback = function()
        task.spawn(UpdateHub.executeAutoRollCharms)
        notify("Charms", "Mengeksekusi roll charms...")
    end
})

UpdateHub.executePetAndEncourage = function()
    pcall(function()
        invokeRemote("PetChicken")
        if selectedChickenId then
            invokeRemote("EncourageChicken", selectedChickenId)
        end
    end)
end

local ChickenCareSec = ChickenTab:Section({
    Title = "Perawatan Ayam (Care & Boost)",
    Opened = false
})

ChickenCareSec:Toggle({
    Title = "Auto Pet & Encourage Active Chicken",
    Callback = function(state)
        UpdateHub.autoPetEncourage = parseToggle(state)
        if UpdateHub.autoPetEncourage then
            task.spawn(UpdateHub.executePetAndEncourage)
        end
    end
})

    ChickenCareSec:Button({
        Title = "Pet & Encourage Sekarang (1-Klik)",
        Callback = function()
            task.spawn(UpdateHub.executePetAndEncourage)
            notify("Chicken Care", "Ayam peliharaan dielus & disemangati!")
        end
    })
end

-- ==============================================================================
-- [TAB: REWARDS]
-- ==============================================================================

UpdateHub.executeClaimCharmDust = function()
    pcall(function()
        local res = invokeRemote("ClaimShopDust")
        if res then
            printLog("Rewards", "Free Charm Dust berhasil diklaim!")
        end
    end)
end

UpdateHub.executeClaimMilestones = function()
    pcall(function()
        local res = invokeRemote("ClaimRebirthMilestones")
        if res then
            printLog("Rewards", "Rebirth Milestones berhasil diklaim!")
        else
            for m = 1, 20 do
                invokeRemote("ClaimRebirthMilestone", m)
                task.wait(0.05)
            end
        end
    end)
end

UpdateHub.arenaRankIds = {
    "hatchling3", "hatchling2", "hatchling1",
    "bronze3", "bronze2", "bronze1",
    "silver3", "silver2", "silver1",
    "gold3", "gold2", "gold1",
    "crystal3", "crystal2", "crystal1",
    "master3", "master2", "master1",
    "champion"
}

UpdateHub.executeClaimArena = function()
    pcall(function()
        for _, rankId in ipairs(UpdateHub.arenaRankIds) do
            local res = invokeRemote("ArenaClaim", rankId)
            if res and (res == true or (type(res) == "table" and res.ok)) then
                printLog("Rewards", "Reward Arena (" .. tostring(rankId) .. ") berhasil diklaim!")
            end
            task.wait(0.15)
        end
    end)
end

UpdateHub.executeClaimPlayToday = function()
    pcall(function()
        for tier = 1, 6 do
            local res = invokeRemote("DailyClaim", "session", tier)
            if res and (res == true or (type(res) == "table" and res.ok)) then
                printLog("Rewards", "Play Today Tier " .. tostring(tier) .. " berhasil diklaim!")
            end
            task.wait(0.25)
        end
    end)
end

UpdateHub.executeClaimDailyStreak = function()
    pcall(function()
        local res = invokeRemote("DailyClaim", "day", nil)
        if res and (res == true or (type(res) == "table" and res.ok)) then
            printLog("Rewards", "Daily Streak berhasil diklaim!")
        end
    end)
end

UpdateHub.executeClaimMission = function()
    pcall(function()
        local missionsPane = player.PlayerGui:FindFirstChild("MissionsPane", true)
        if missionsPane then
            for _, child in ipairs(missionsPane:GetChildren()) do
                if not child:IsA("UIComponent") and not child:IsA("UILayout") then
                    local btn = child:FindFirstChild("claimBtn", true)
                    local label = child:FindFirstChild("label", true)
                    local isReady = btn ~= nil or (label and label.Text:upper():find("CLAIM"))

                    if isReady then
                        local rawName = child.Name
                        local cleanName = rawName:gsub("^m_", "")
                        invokeRemote("MissionClaim", rawName)
                        invokeRemote("MissionClaim", cleanName)
                        printLog("Rewards", "Misi '" .. tostring(rawName) .. "' diklaim!")
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
end

local function clickGuiButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then
            if btn.Activated then firesignal(btn.Activated) end
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
        end
        local getConn = getconnections or get_signal_cons
        if getConn then
            if btn.Activated then
                for _, c in ipairs(getConn(btn.Activated)) do pcall(function() c:Fire() end) end
            end
            if btn.MouseButton1Click then
                for _, c in ipairs(getConn(btn.MouseButton1Click)) do pcall(function() c:Fire() end) end
            end
        end
    end)
end

UpdateHub.executeClaimIndexMilestones = function()
    pcall(function()
        -- 1. Panggil RemoteFunction Bulk Claim resmi jika didukung server
        pcall(function()
            invokeRemote("ClaimIndexMilestones")
        end)

        -- 2. Dapatkan modul IndexMilestones jika ada
        local IndexMilestonesMod = nil
        pcall(function()
            local content = ReplicatedStorage:FindFirstChild("Content")
            if content and content:FindFirstChild("IndexMilestones") then
                IndexMilestonesMod = require(content.IndexMilestones)
            end
        end)

        -- 3. Cek jumlah ayam yang ditemukan dari DataService
        local discoveredCount = 0
        pcall(function()
            local dsClient = getSharedDataServiceClient()
            local raw = dsClient and dsClient._data and dsClient._data._data
            if raw and raw.roster and raw.roster.discovered then
                if type(raw.roster.discovered) == "table" then
                    for _ in pairs(raw.roster.discovered) do
                        discoveredCount = discoveredCount + 1
                    end
                elseif type(raw.roster.discovered) == "number" then
                    discoveredCount = raw.roster.discovered
                end
            end
        end)

        -- 4. Tentukan batas milestone yang sudah tercapai
        local maxReached = 30
        if IndexMilestonesMod and discoveredCount > 0 then
            local r = IndexMilestonesMod.reachedCount(discoveredCount)
            if type(r) == "number" and r > 0 then
                maxReached = r
            end
        end

        -- Daftar threshold (at) dari data resmi IndexMilestones (STEP=5 hingga 100, lalu TAIL_STEP=10)
        local milestoneThresholds = {
            5, 10, 15, 20, 25, 30, 35, 40, 45, 50,
            55, 60, 65, 70, 75, 80, 85, 90, 95, 100,
            110, 120, 130, 140, 150, 160, 170, 180, 190, 200
        }

        local limit = math.min(#milestoneThresholds, maxReached)
        for idx = 1, limit do
            local atVal = milestoneThresholds[idx]
            if IndexMilestonesMod and IndexMilestonesMod.nth then
                local nthData = IndexMilestonesMod.nth(idx)
                if nthData and nthData.at then
                    atVal = nthData.at
                end
            end

            -- Panggil ClaimIndexMilestone dengan nilai 'at' (contoh: 5, 10, 15 seperti pada log Live Spy)
            invokeRemote("ClaimIndexMilestone", atVal)
            -- Cadangan pemanggilan dengan ordinal index (1, 2, 3...)
            invokeRemote("ClaimIndexMilestone", idx)
            task.wait(0.04)
        end

        -- 5. Interaksi UI Index / Milestones di PlayerGui jika menu sedang terbuka
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            for _, desc in ipairs(pg:GetDescendants()) do
                if desc:IsA("GuiButton") or desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    local btnTxt = (desc:IsA("TextButton") and desc.Text or ""):lower()
                    local btnName = desc.Name:lower()

                    if btnName == "claimall" or btnName == "claim" or btnTxt == "claim all" or btnTxt == "claim" then
                        local isIndexGui = false
                        local cur = desc.Parent
                        while cur and cur ~= pg do
                            local cName = cur.Name:lower()
                            if cName:find("index") or cName:find("milestone") or cName:find("collection") then
                                isIndexGui = true
                                break
                            end
                            cur = cur.Parent
                        end

                        if isIndexGui then
                            clickGuiButton(desc)
                        end
                    end
                end
            end
        end

        printLog("Rewards", "Auto Claim Index Milestones berhasil dijalankan!")
    end)
end


UpdateHub.executeRedeemAllCodes = function()
    task.spawn(function()
        notify("Redeem Codes", "Mulai mencoba menukarkan kode promo aktif...")
        for _, code in ipairs(promoCodesList) do
            pcall(function()
                invokeRemote("RedeemCode", code)
            end)
            task.wait(0.4)
        end
        notify("Redeem Codes", "Selesai mencoba semua kode promo!")
    end)
end

-- SECTIONS TAB REWARDS
do
    local RewardsClaimSec = RewardsTab:Section({
        Title = "Auto Claim",
        Opened = true
    })

    RewardsClaimSec:Toggle({
        Title = "Auto Claim Play Today",
        Callback = function(state)
            UpdateHub.autoClaimPlayToday = parseToggle(state)
            if UpdateHub.autoClaimPlayToday then
                task.spawn(UpdateHub.executeClaimPlayToday)
            end
        end
    })

    RewardsClaimSec:Toggle({
        Title = "Auto Claim Daily Streak",
        Callback = function(state)
            UpdateHub.autoClaimDailyStreak = parseToggle(state)
            if UpdateHub.autoClaimDailyStreak then
                task.spawn(UpdateHub.executeClaimDailyStreak)
            end
        end
    })

    RewardsClaimSec:Toggle({
        Title = "Auto Claim Mission",
        Callback = function(state)
            UpdateHub.autoClaimMission = parseToggle(state)
            if UpdateHub.autoClaimMission then
                task.spawn(UpdateHub.executeClaimMission)
            end
        end
    })

    RewardsClaimSec:Toggle({
        Title = "Auto Claim Charm Dust",
        Callback = function(state)
            UpdateHub.autoClaimCharmDust = parseToggle(state)
            if UpdateHub.autoClaimCharmDust then
                task.spawn(UpdateHub.executeClaimCharmDust)
            end
        end
    })

    RewardsClaimSec:Toggle({
        Title = "Auto Claim Index Milestones",
        Callback = function(state)
            UpdateHub.autoClaimIndex = parseToggle(state)
            if UpdateHub.autoClaimIndex then
                task.spawn(UpdateHub.executeClaimIndexMilestones)
            end
        end
    })

    RewardsClaimSec:Button({
        Title = "Claim All Rewards Now (1-Klik)",
        Callback = function()
            notify("Rewards", "Mengeksekusi klaim seluruh hadiah...")
            task.spawn(function()
                UpdateHub.executeClaimCharmDust()
                task.wait(0.3)
                UpdateHub.executeClaimMilestones()
                task.wait(0.3)
                UpdateHub.executeClaimArena()
                task.wait(0.3)
                UpdateHub.executeClaimDailyStreak()
                task.wait(0.3)
                UpdateHub.executeClaimPlayToday()
                task.wait(0.3)
                UpdateHub.executeClaimMission()
                task.wait(0.3)
                UpdateHub.executeClaimIndexMilestones()
                notify("Rewards", "Selesai mengeksekusi klaim semua reward!")
            end)
        end
    })

    local RewardsCodeSec = RewardsTab:Section({
        Title = "Auto Redeem Code",
        Opened = true
    })

    RewardsCodeSec:Button({
        Title = "Redeem Semua Kode Aktif (1-Klik)",
        Callback = function()
            UpdateHub.executeRedeemAllCodes()
        end
    })

    RewardsCodeSec:Input({
        Title = "Kode Promo Kustom",
        Value = customPromoCode,
        Callback = function(text)
            if text and text ~= "" then
                customPromoCode = text
            end
        end
    })

    RewardsCodeSec:Button({
        Title = "Redeem Kode Kustom",
        Callback = function()
            if customPromoCode and customPromoCode ~= "" then
                pcall(function()
                    invokeRemote("RedeemCode", customPromoCode)
                end)
                notify("Redeem Code", "Kode '" .. customPromoCode .. "' dikirim ke server!")
            else
                notify("Redeem Code", "Ketik kode terlebih dahulu pada kotak di atas!")
            end
        end
    })

    local RewardsMilestoneSec = RewardsTab:Section({
        Title = "Arena & Rebirth Milestones",
        Opened = true
    })

    RewardsMilestoneSec:Toggle({
        Title = "Auto Claim Reward Arena",
        Callback = function(state)
            UpdateHub.autoClaimArena = parseToggle(state)
            if UpdateHub.autoClaimArena then
                task.spawn(UpdateHub.executeClaimArena)
            end
        end
    })

    RewardsMilestoneSec:Toggle({
        Title = "Auto Claim Rebirth Milestones",
        Callback = function(state)
            UpdateHub.autoClaimMilestones = parseToggle(state)
            if UpdateHub.autoClaimMilestones then
                task.spawn(UpdateHub.executeClaimMilestones)
            end
        end
    })

    RewardsMilestoneSec:Button({
        Title = "Claim Arena & Milestones Sekarang",
        Callback = function()
            notify("Rewards", "Mengklaim hadiah Arena & Rebirth Milestones...")
            task.spawn(function()
                UpdateHub.executeClaimMilestones()
                task.wait(0.4)
                UpdateHub.executeClaimArena()
                notify("Rewards", "Klaim Arena & Milestones selesai!")
            end)
        end
    })

end

-- ==============================================================================
-- [TAB 5: PLAYER]
-- ==============================================================================
do
    local EspSec = PlayerTab:Section({
        Title = "Visual ESP",
        Opened = true
    })

    EspSec:Toggle({
        Title = "Player ESP",
        Callback = function(state)
            espPlayerEnabled = parseToggle(state)
            if not espPlayerEnabled then
                cleanESP("SysHub_PlayerESP_HL")
                cleanESP("SysHub_PlayerESP_BB")
            end
        end
    })

    EspSec:Toggle({
        Title = "Egg ESP",
        Callback = function(state)
            espEggEnabled = parseToggle(state)
            if not espEggEnabled then
                cleanESP("SysHub_EggESP_HL")
                cleanESP("SysHub_EggESP_BB")
            end
        end
    })

    EspSec:Toggle({
        Title = "Scrap & Coin ESP",
        Callback = function(state)
            espScrapEnabled = parseToggle(state)
            if not espScrapEnabled then
                cleanESP("SysHub_ScrapESP_HL")
                cleanESP("SysHub_ScrapESP_BB")
            end
        end
    })

    local StreamerSec = PlayerTab:Section({
        Title = "Streamer Mode",
        Opened = true
    })

    StreamerSec:Toggle({ 
        Title = "Streamer Mode (Hide Name)", 
        Callback = function(state) 
            streamerMode = parseToggle(state)
            if not streamerMode and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum.DisplayName = player.DisplayName
                    end)
                end
            end
        end 
    })

    StreamerSec:Input({
        Title = "Custom Fake Name",
        Value = fakeName,
        Callback = function(text)
            if text and text ~= "" then
                fakeName = text
            end
        end
    })
end


-- ==============================================================================
-- [12] TAB MISC - SERVER MANAGEMENT
-- ==============================================================================
do
    local ServerSec = MiscTab:Section({
        Title = "Server Management",
        Opened = true
    })

-- PARAGRAF STATUS SERVER
local ServerStatusPara = ServerSec:Paragraph({
    Title = "Status Server",
    Desc = string.format("ID Server : %s\nJumlah Pemain : %d/%d", 
        (game.JobId and game.JobId ~= "") and game.JobId or "N/A (Studio/Private)", 
        #Players:GetPlayers(), 
        Players.MaxPlayers > 0 and Players.MaxPlayers or 4
    )
})

local function updateServerStatusUI()
    if not ServerStatusPara then
        return
    end
    local currentPlayers = #Players:GetPlayers()
    local maxCap = Players.MaxPlayers > 0 and Players.MaxPlayers or 4
    local sId = (game.JobId and game.JobId ~= "") and game.JobId or "N/A (Studio/Private)"
    local descText = string.format("ID Server : %s\nJumlah Pemain : %d/%d", sId, currentPlayers, maxCap)
    
    pcall(function()
        if type(ServerStatusPara.SetDesc) == "function" then
            ServerStatusPara:SetDesc(descText)
        elseif type(ServerStatusPara.Set) == "function" then
            ServerStatusPara:Set({
                Title = "Status Server",
                Desc = descText
            })
        end
    end)
end

Players.PlayerAdded:Connect(updateServerStatusUI)
Players.PlayerRemoving:Connect(updateServerStatusUI)

ServerSec:Button({
    Title = "Salin ID Server",
    Callback = function()
        local sId = game.JobId
        if sId and sId ~= "" then
            pcall(function()
                if setclipboard then
                    setclipboard(sId)
                elseif toclipboard then
                    toclipboard(sId)
                end
            end)
            notify("Server Management", "ID Server berhasil disalin ke clipboard!")
        else
            notify("Server Management", "ID Server kosong (Studio / Private Server).")
        end
    end
})

-- HELPER AMBIL LIST SERVER DARI ROBLOX API
local function getPublicServerList(sortOrder)
    sortOrder = sortOrder or 1 -- 1 = Ascending (Paling sepi), 2 = Descending
    local placeId = game.PlaceId
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100", tostring(placeId), tostring(sortOrder))
    
    local success, response = pcall(function()
        if type(game.HttpGet) == "function" then
            return game:HttpGet(url)
        end
        local req = request or http_request
        if not req then
            local env = (getfenv and getfenv()) or _G
            local synTable = env and env.syn
            if synTable and type(synTable.request) == "function" then
                req = synTable.request
            end
        end
        if type(req) == "function" then
            local res = req({Url = url, Method = "GET"})
            return res and res.Body
        end
        return nil
    end)

    if success and response then
        local decodeOk, parsed = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if decodeOk and parsed and parsed.data then
            return parsed.data
        end
    end
    return nil
end

-- FITUR 2: REJOIN SERVER ACAK
ServerSec:Button({
    Title = "Rejoin Server Acak",
    Callback = function()
        notify("Server Management", "Mencari server acak...")
        task.spawn(function()
            local servers = getPublicServerList(1)
            local validServers = {}
            if servers then
                for _, s in ipairs(servers) do
                    if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                        table.insert(validServers, s)
                    end
                end
            end

            if #validServers > 0 then
                local chosen = validServers[math.random(1, #validServers)]
                notify("Server Management", string.format("Menghubungkan ke server acak (%d/%d pemain)...", chosen.playing, chosen.maxPlayers))
                task.wait(0.5)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, player)
            else
                notify("Server Management", "Tidak menemukan server lain via API, mencoba teleport default...")
                task.wait(0.5)
                TeleportService:Teleport(game.PlaceId, player)
            end
        end)
    end
})

-- FITUR 3: REJOIN SERVER YANG SAMA
ServerSec:Button({
    Title = "Rejoin Server Saat Ini",
    Callback = function()
        notify("Server Management", "Menghubungkan ulang ke server saat ini...")
        task.spawn(function()
            task.wait(0.5)
            if #Players:GetPlayers() <= 1 or game.JobId == "" then
                -- Jika hanya ada 1 pemain, server akan otomatis tutup saat disconnect, gunakan Teleport biasa
                TeleportService:Teleport(game.PlaceId, player)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end)
    end
})

-- FITUR 4: HOP SERVER SEPI (MAKSIMAL 2 PEMAIN)
ServerSec:Button({
    Title = "Hop Server Sepi (Max 2 Player)",
    Callback = function()
        notify("Server Management", "Mencari server tersepi (maksimal 2 pemain)...")
        task.spawn(function()
            -- sortOrder=1 (Ascending) otomatis mengambil server dengan jumlah player terendah di awal
            local servers = getPublicServerList(1)
            if not servers or #servers == 0 then
                notify("Server Management", "Gagal mengambil daftar server dari Roblox API.")
                return
            end

            local maxTarget = 2
            local underMaxServers = {}
            local allValidServers = {}

            for _, s in ipairs(servers) do
                if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                    table.insert(allValidServers, s)
                    if s.playing <= maxTarget then
                        table.insert(underMaxServers, s)
                    end
                end
            end

            local chosenServer = nil
            if #underMaxServers > 0 then
                -- Urutkan berdasarkan yang paling sedikit pemainnya
                table.sort(underMaxServers, function(a, b)
                    return a.playing < b.playing
                end)
                chosenServer = underMaxServers[1]
                notify("Server Management", string.format("Server sepi ditemukan! (%d/%d pemain). Memulai teleport...", chosenServer.playing, chosenServer.maxPlayers))
            elseif #allValidServers > 0 then
                -- Jika tidak ada yang <= 2 pemain, pilih server dengan pemain paling sedikit yang tersedia
                table.sort(allValidServers, function(a, b)
                    return a.playing < b.playing
                end)
                chosenServer = allValidServers[1]
                notify("Server Management", string.format("Server <= 2 pemain penuh. Memilih server tersepi (%d/%d pemain)...", chosenServer.playing, chosenServer.maxPlayers))
            else
                notify("Server Management", "Tidak ada server yang memenuhi kriteria untuk berpindah.")
                return
            end

            if chosenServer then
                task.wait(0.5)
                local success, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, chosenServer.id, player)
                end)
                if not success then
                    logError("Hop Server", err)
                    notify("Server Management", "Gagal teleport: " .. tostring(err))
                end
            end
        end)
    end
})

TeleportService.TeleportInitFailed:Connect(function(plr, teleportResult, errorMessage)
    if plr == player then
        warn(string.format("[SysHub - Teleport Failed]: %s (%s)", tostring(errorMessage), tostring(teleportResult)))
        notify("Teleport Gagal", tostring(errorMessage))
    end
end)
end

-- ==============================================================================
-- [13] BACKGROUND THREADS & LOOPS
-- ==============================================================================

-- STEALTH ANTI-AFK
do
    local function disableIdleKick()
        local getConn = getconnections or get_signal_cons
        if getConn then
            pcall(function()
                for _, conn in ipairs(getConn(player.Idled)) do
                    if conn.Disable then
                        conn:Disable()
                    elseif conn.Disconnect then
                        conn:Disconnect()
                    end
                end
            end)
        end
    end

    task.spawn(function()
        while true do
            pcall(disableIdleKick)
            task.wait(25)
        end
    end)
end

-- STREAMER MODE ENGINE (MASK KARAKTER, BASE PLOT, PLOTSIGN, COOP, & GUI)
local function safeReplace(text, target, repl)
    if not text or text == "" or not target or target == "" then
        return text
    end
    if text == target then
        return repl
    end
    local escapedTarget = target:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    local ok, res = pcall(function()
        return string.gsub(text, escapedTarget, repl)
    end)
    return ok and res or text
end

local function applyStreamerMode()
    if not streamerMode then
        return
    end

    local pName = player.Name
    local pDisplay = player.DisplayName
    local repl = fakeName or "Anonymous"

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.DisplayName ~= repl then
            pcall(function()
                hum.DisplayName = repl
            end)
        end
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local txt = desc.Text or ""
                if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                    desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                end
            end
        end
    end

    -- Papan Base / Plot di Workspace.World.Plots (PlotX.Owner.PlayerName)
    local plots = (Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Plots")) or Workspace:FindFirstChild("Plots")
    if plots then
        for _, desc in ipairs(plots:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local txt = desc.Text or ""
                if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                    desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                end
            end
        end
    end

    local plotSigns = Workspace:FindFirstChild("PlotSigns")
    if plotSigns then
        for _, desc in ipairs(plotSigns:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local txt = desc.Text or ""
                if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                    desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                end
            end
        end
    end

    local coops = Workspace:FindFirstChild("Coops")
    if coops then
        for _, desc in ipairs(coops:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local txt = desc.Text or ""
                if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                    desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                end
            end
        end
    end

    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local txt = desc.Text or ""
                if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                    desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                end
            end
        end
    end

    -- Leaderboard / PlayerList di CoreGui (Kanan Atas)
    pcall(function()
        local pList = CoreGui:FindFirstChild("PlayerList")
        if pList then
            for _, desc in ipairs(pList:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    local txt = desc.Text or ""
                    if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                        desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                    end
                end
            end
        else
            for _, desc in ipairs(CoreGui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible then
                    local txt = desc.Text or ""
                    if txt == pName or txt == pDisplay or txt:find(pName) or txt:find(pDisplay) then
                        desc.Text = safeReplace(safeReplace(txt, pName, repl), pDisplay, repl)
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.25)
        if streamerMode then
            pcall(applyStreamerMode)
        end
    end
end)

-- REAL-TIME VISUAL ESP THREAD
task.spawn(function()
    while true do
        task.wait(0.4)
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        -- 1. PLAYER ESP
        if espPlayerEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and myHrp then
                        local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                        local tag = "SysHub_PlayerESP"
                        createESPHighlight(p.Character, Color3.fromRGB(0, 255, 150), Color3.fromRGB(255, 255, 255), tag .. "_HL")
                        createESPBillboard(hrp, string.format("%s\n[%dm]", p.DisplayName, dist), Color3.fromRGB(0, 255, 150), Vector3.new(0, 3, 0), tag .. "_BB")
                    end
                end
            end
        end

        -- 2. EGG ESP
        if espEggEnabled then
            local nestFolder = Workspace:FindFirstChild("NestEggs")
            if nestFolder and myHrp then
                for _, egg in ipairs(nestFolder:GetChildren()) do
                    if egg:IsA("BasePart") then
                        local dist = math.floor((egg.Position - myHrp.Position).Magnitude)
                        local tier = tostring(egg:GetAttribute("tier") or "Egg"):upper()
                        local owner = egg:GetAttribute("owner")
                        local isMine = (owner and tonumber(owner) == player.UserId)

                        local eggColor = Color3.fromRGB(255, 255, 255)
                        if tier:find("GOLD") then
                            eggColor = Color3.fromRGB(255, 215, 0)
                        elseif tier:find("CIRCUIT") then
                            eggColor = Color3.fromRGB(0, 255, 255)
                        elseif tier:find("ORDNANCE") then
                            eggColor = Color3.fromRGB(255, 80, 0)
                        end

                        local title = isMine and string.format("[MY EGG: %s]\n%dm", tier, dist) or string.format("[EGG: %s]\n%dm", tier, dist)
                        local tag = "SysHub_EggESP"
                        createESPHighlight(egg, eggColor, Color3.fromRGB(255, 255, 255), tag .. "_HL")
                        createESPBillboard(egg, title, eggColor, Vector3.new(0, 1.5, 0), tag .. "_BB")
                    end
                end
            end
        end

        -- 3. SCRAP & COIN ESP
        if espScrapEnabled and myHrp then
            local pitFolder = Workspace:FindFirstChild("PitScrap")
            if pitFolder then
                for _, scrap in ipairs(pitFolder:GetChildren()) do
                    if scrap:IsA("BasePart") and scrap.Name == "Loose" then
                        local dist = math.floor((scrap.Position - myHrp.Position).Magnitude)
                        local tier = tostring(scrap:GetAttribute("StackTier") or "Scrap"):upper()
                        local kind = tostring(scrap:GetAttribute("StackKind") or "scrap")

                        local sColor = Color3.fromRGB(0, 200, 255)
                        if kind == "goldCoin" or tier:find("GOLD") then
                            sColor = Color3.fromRGB(255, 215, 0)
                        elseif tier:find("SILVER") then
                            sColor = Color3.fromRGB(210, 210, 230)
                        elseif tier:find("BRONZE") then
                            sColor = Color3.fromRGB(205, 127, 50)
                        end

                        local labelTxt = (kind == "goldCoin") and string.format("[GOLD COIN]\n%dm", dist) or string.format("[%s SCRAP]\n%dm", tier, dist)
                        local tag = "SysHub_ScrapESP"
                        createESPHighlight(scrap, sColor, Color3.fromRGB(255, 255, 255), tag .. "_HL")
                        createESPBillboard(scrap, labelTxt, sColor, Vector3.new(0, 1, 0), tag .. "_BB")
                    end
                end
            end
        end
    end
end)

-- AUTO PROMOTE ENGINE (STATUS & SUCCESS DRIVEN - ANTI-SPAM & CRASH PROOF)
task.spawn(function()
    local isPromoteRunning = false
    while true do
        task.wait(3)
        if autoPromote and not isPromoteRunning then
            isPromoteRunning = true
            local success, ok, msg = pcall(executePromoteSelectedSpecies)
            if success and ok then
                autoPromote = false
                pcall(function()
                    if autoPromoteToggle and type(autoPromoteToggle.Set) == "function" then
                        autoPromoteToggle:Set(false)
                    end
                end)
                notify("Auto Promote", tostring(msg) .. " (Auto Promote dinonaktifkan demi keamanan)")
                printLog("Auto Promote", "Sukses: " .. tostring(msg))
            end
            isPromoteRunning = false
        end
    end
end)

-- AUTO FUSE ENGINE (EVENT & STATUS DRIVEN - DENGAN NOTIFIKASI)
task.spawn(function()
    while true do
        task.wait(2)
        if autoFuse then
            if fuseMainChickenName and fuseFodderChickenName and chickenMap[fuseMainChickenName] and chickenMap[fuseFodderChickenName] and fuseMainChickenName ~= fuseFodderChickenName then
                local ok, msg = executeFuseChickens()
                if ok then
                    notify("Auto Fuse", "Berhasil menggabungkan ayam (" .. tostring(fuseMainChickenName) .. ")!")
                    printLog("Auto Fuse", "Penggabungan ayam berhasil dengan skill lock: " .. tostring(fuseLockedSkill))
                end
            end
        end
    end
end)

-- AUTO SELL LOOP
task.spawn(function()
    while true do
        task.wait(2)
        if autoSellChickens then
            pcall(function()
                executeSellChickens(false)
            end)
        end
    end
end)

-- AUTO UPGRADE INCUBATOR LOOP
task.spawn(function()
    while true do
        task.wait(delayUpgradeIncubator)
        if autoUpgradeIncubator then
            invokeRemote("IncubatorUpgrade")
            invokeRemote("IncubatorUpgrade", 1)
        end
    end
end)

-- AUTO COLLECT NEST EGGS (DETEKSI OTOMATIS)
task.spawn(function()
    local nestFolder = Workspace:WaitForChild("NestEggs", 10) or Workspace:FindFirstChild("NestEggs")
    if nestFolder then
        nestFolder.ChildAdded:Connect(function(child)
            if autoCollectNestEggs then
                task.wait(0.15)
                pcall(function()
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        return
                    end
                    local owner = child:GetAttribute("owner")
                    if owner and tonumber(owner) == player.UserId then
                        local targetPart = child:IsA("BasePart") and child or (child:FindFirstChildWhichIsA("BasePart") or child.PrimaryPart)
                        if targetPart and firetouchinterest then
                            firetouchinterest(hrp, targetPart, 0)
                            task.wait(0.02)
                            firetouchinterest(hrp, targetPart, 1)
                        end
                        local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                        printLog("Auto Collect Egg", "Telur baru terdeteksi di sarang! Berhasil diambil ke tas.")
                    end
                end)
            end
        end)
    end

    while true do
        task.wait(2)
        if autoCollectNestEggs then
            local count = collectMyNestEggs(false)
            if count > 0 then
                printLog("Auto Collect Egg", count .. " telur terdeteksi di sarang & berhasil diambil.")
            end
        end
    end
end)

-- AUTO FARM INCUBATOR CLAIM & PUT
task.spawn(function()
    while true do
        task.wait(2)
        if autoClaimIncubator then
            invokeRemote("IncubatorClaim")
            invokeRemote("IncubatorClaim", 1)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2.5)
        if autoPutIncubator and selectedChickenId then
            pcall(function()
                local plotIdAttr = player:GetAttribute("Plot")
                local plotId = (type(plotIdAttr) == "number" and plotIdAttr) or 1
                local myInc = Workspace:FindFirstChild("Incubators") and Workspace.Incubators:FindFirstChild("Incubator" .. tostring(plotId))
                local occ = myInc and myInc:GetAttribute("Occupant")
                if not occ or occ == "" or occ == "{}" or occ == "none" then
                    invokeRemote("IncubatorInsert", selectedChickenId)
                    invokeRemote("IncubatorInsert", 1, selectedChickenId)
                end
            end)
        end
    end
end)

-- AUTO CLAIM REWARDS BACKGROUND LOOP (AMAN & ANTI-CRASH)
task.spawn(function()
    while true do
        task.wait(20)
        pcall(function()
            if UpdateHub.autoClaimCharmDust then
                UpdateHub.executeClaimCharmDust()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimMilestones then
                UpdateHub.executeClaimMilestones()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimArena then
                UpdateHub.executeClaimArena()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimDailyStreak then
                UpdateHub.executeClaimDailyStreak()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimPlayToday then
                UpdateHub.executeClaimPlayToday()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimMission then
                UpdateHub.executeClaimMission()
                task.wait(0.5)
            end
            if UpdateHub.autoClaimIndex then
                UpdateHub.executeClaimIndexMilestones()
                task.wait(0.5)
            end
        end)
    end
end)

-- COOP UPGRADE LOOPS
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoUpgradeCoop then
            invokeRemote("ExpandCoop")
            if delayCoop > 0 then
                task.wait(delayCoop)
            end
        end
        if autoUpgradeRecycler then
            invokeRemote("UpgradeRecycler")
            if delayRecycler > 0 then
                task.wait(delayRecycler)
            end
        end
        if autoRebirth and not autoRebirthSurplus then
            invokeRemote("Rebirth")
            if delayRebirth > 0 then
                task.wait(delayRebirth)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoBuyFeeder then
            for id = 1, MAX_FEEDER_SLOTS do
                if not autoBuyFeeder then
                    break
                end
                invokeRemote("BuyGenerator", id)
                if delayBuy > 0 then
                    task.wait(delayBuy)
                end
            end
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoUpgradeFeeder then
            for id = 1, MAX_FEEDER_SLOTS do
                if not autoUpgradeFeeder then
                    break
                end
                invokeRemote("UpgradeGenerator", id)
                if delayUpgrade > 0 then
                    task.wait(delayUpgrade)
                end
            end
            task.wait(0.5)
        end
    end
end)

-- ==============================================================================
-- [14] THREAD AUTO TOWER (PERSIS SESUAI SCRIPT KERJA USER)
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(1)
        if autoTower then
            local currentFloor = getCurrentFloor()
            local cStatus = getChickenStatus()

            -- Jika ayam KO saat auto tower, langsung skip animasi & No Thanks
            if not cStatus.IsAlive or cStatus.HpFrac <= 0 then
                invokeRemote("TowerContinueDecline")
                dismissTowerKOUI()
                task.wait(1)
            elseif currentFloor >= retreatFloor then
                task.spawn(function()
                    invokeRemote("TowerSurrender")
                end)
                autoTower = false
                task.wait(2)
            else
                if cStatus.IsFull then
                    local targetFloor = (currentFloor > 0 and currentFloor) or 1

                    task.spawn(function()
                        invokeRemote("TowerElevator", math.floor(targetFloor))
                        task.wait(0.5)
                        invokeRemote("TowerStart")
                    end)

                    task.wait(6)
                end
            end
        end
    end
end)

-- ==============================================================================
-- [15] THREAD AUTO REBIRTH SURPLUS (PERSIS SESUAI SCRIPT KERJA USER)
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(1)
        local mainOk, mainErr = pcall(function()
            if autoRebirthSurplus then
                if surplusAllTargetsMet then
                    return
                end

                local stats = getSurplusStats()
                local allMet = true
                local currentActions = {}

                if stats.TowerFloor > highestFloorReached then
                    highestFloorReached = stats.TowerFloor
                end

                if highestFloorReached >= surplusTargetTower and stats.TowerFloor > 0 then
                    task.spawn(function()
                        invokeRemote("TowerSurrender")
                    end)
                end

                -- 1. Target Coop Level
                if stats.Coop < surplusTargetCoop then
                    allMet = false
                    table.insert(currentActions, "Coop")
                    invokeRemote("ExpandCoop")
                end

                -- 2. Target Feeder Count
                if stats.FeederCount < surplusTargetFeederCount then
                    allMet = false
                    table.insert(currentActions, "Beli Feeder")
                    for id = 1, surplusTargetFeederCount do
                        if not stats.Feeders[id] then
                            invokeRemote("BuyGenerator", id)
                        end
                    end
                end

                -- 3. Target Feeder Level
                local feedersNeedUpgrade = false
                for id = 1, surplusTargetFeederCount do
                    local curLvl = stats.Feeders[id] or 0
                    if curLvl < surplusTargetFeederLevel then
                        feedersNeedUpgrade = true
                        invokeRemote("UpgradeGenerator", id)
                    end
                end

                if feedersNeedUpgrade then
                    allMet = false
                    table.insert(currentActions, "Up Feeder")
                end

                -- 4. Target Level Ayam
                if stats.ChickenLevel < surplusTargetChickenLevel then
                    allMet = false
                    table.insert(currentActions, "Ayam")
                end

                -- 5. Target Lantai Tower (Dengan Auto Skip KO & No Thanks)
                if highestFloorReached < surplusTargetTower then
                    allMet = false
                    local cStatus = getChickenStatus()

                    -- Jika ayam mati di dalam Tower (ovLife == false atau HP <= 0), langsung tolak tawaran Robux & skip animasi!
                    if (not cStatus.IsAlive or cStatus.HpFrac <= 0) then
                        invokeRemote("TowerContinueDecline")
                        dismissTowerKOUI()
                        table.insert(currentActions, "Tower (Ayam KO -> Skip No Thanks)")
                    elseif cStatus.IsFull and (tick() - lastSurplusTowerTime >= 6) then
                        table.insert(currentActions, "Tower (Masuk Lantai " .. tostring(stats.TowerFloor > 0 and stats.TowerFloor or 1) .. ")")
                        lastSurplusTowerTime = tick()
                        local targetFloor = (stats.TowerFloor > 0 and stats.TowerFloor) or 1

                        task.spawn(function()
                            invokeRemote("TowerElevator", math.floor(targetFloor))
                            task.wait(0.5)
                            invokeRemote("TowerStart")
                        end)
                    else
                        table.insert(currentActions, "Tower (Regen HP)")
                    end
                end

                -- 6. Target Recycler Level
                if stats.RecyclerLevel < surplusTargetRecycler then
                    allMet = false
                    table.insert(currentActions, "Recycler")
                    invokeRemote("UpgradeRecycler")
                end

                local actionText = "Proses: " .. table.concat(currentActions, ", ")
                if allMet then
                    actionText = "SEMUA TARGET TERCAPAI! Menuju arena tengah mengambil 20 scrap..."
                    printLog("Surplus", "Seluruh target tercapai! Menyerahkan eksekusi ke Auto Sweep...")
                end

                updateSurplusStatus(
                    "Live Monitor",
                    string.format(
                        "Status: %s\n\n[ PROGRESS SAAT INI ]\nCoop: Lvl %d / %d\nJumlah Feeder: %d / %d\nLevel Feeder (Min): %d / %d\nLevel Ayam: %d / %d\nLantai Tower: %d / %d\nLevel Recycler: %d / %d",
                        actionText,
                        stats.Coop,
                        surplusTargetCoop,
                        stats.FeederCount,
                        surplusTargetFeederCount,
                        stats.FeederLevel,
                        surplusTargetFeederLevel,
                        stats.ChickenLevel,
                        surplusTargetChickenLevel,
                        highestFloorReached,
                        surplusTargetTower,
                        stats.RecyclerLevel,
                        surplusTargetRecycler
                    )
                )

                surplusAllTargetsMet = allMet
            else
                surplusAllTargetsMet = false
                highestFloorReached = 0
                updateSurplusStatus("Live Monitor", "Fitur Surplus Nonaktif.")
            end
        end)

        if not mainOk then
            logError("Auto Rebirth Surplus Main Thread", mainErr)
        end
    end
end)

-- ==============================================================================
-- [16] THREAD AUTO SWEEP & STEP AKHIR REBIRTH (PERSIS SESUAI SCRIPT KERJA USER)
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        local loopOk, loopErr = pcall(function()
            local shouldSweep = autoSweep or (autoRebirthSurplus and surplusAllTargetsMet)

            if shouldSweep and not isSweepRunning then
                isSweepRunning = true
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")

                if hrp then
                    local availableScraps = {}
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        local isScrap, stackKind = false, obj:GetAttribute("StackKind")
                        if obj.Name == "Loose" and obj.Parent and obj.Parent.Name == "PitScrap" then
                            isScrap = true
                        elseif stackKind == "scrap" or stackKind == "goldCoin" then
                            isScrap = true
                        elseif obj:GetAttribute("CarryAttr") == "scrapCarry" then
                            isScrap = true
                        elseif obj.Name == "Part" and obj.Parent and obj.Parent.Name == "PitScrap" and stackKind then
                            isScrap = true
                        elseif obj:IsA("ProximityPrompt") and (obj.Parent.Name:lower():find("scrap") or obj.Parent.Name:lower():find("coin") or obj.Parent.Name:lower():find("item")) then
                            isScrap = true
                        end

                        if isScrap and not isHeldBySomeone(obj) then
                            local targetPart = obj:IsA("ProximityPrompt") and obj.Parent or obj
                            local targetPos = targetPart:IsA("Model") and targetPart:GetPivot().Position or targetPart.Position
                            local distFromPlayer = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude

                            if (autoRebirthSurplus and surplusAllTargetsMet) or distFromPlayer <= 150 then
                                table.insert(availableScraps, targetPart)
                            end
                        end
                    end

                    if #availableScraps > 0 then
                        while (autoSweep or (autoRebirthSurplus and surplusAllTargetsMet)) and #availableScraps > 0 do
                            local currentCarry = getRealBackpackCount(character)
                            local isSurplusReady = (autoRebirthSurplus and surplusAllTargetsMet)

                            if currentCarry >= MAX_CAPACITY then
                                local recycler = findMyRecycler()
                                if recycler then
                                    local recPos = recycler:IsA("Model") and recycler:GetPivot().Position or recycler.Position
                                    printLog("Step Akhir", "Tas penuh (20 Scrap). Bergerak menuju Recycler sendiri...")

                                    safeWalkTo(recPos, 5, false)

                                    local currentDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(recPos.X, 0, recPos.Z)).Magnitude

                                    if currentDist <= 8 then
                                        printLog("Step Akhir", "Tiba di Recycler (Jarak: " .. string.format("%.1f", currentDist) .. " stud). Memulai proses Deposit...")

                                        invokeRemote("ScrapDeposited")

                                        local prompt = recycler:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if not prompt and recycler.Parent then
                                            prompt = recycler.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        end
                                        if prompt then
                                            pcall(function()
                                                fireproximityprompt(prompt)
                                            end)
                                        end

                                        if firetouchinterest then
                                            pcall(function()
                                                firetouchinterest(hrp, recycler, 0)
                                                task.wait(0.05)
                                                firetouchinterest(hrp, recycler, 1)
                                            end)
                                        end

                                        local waitDepositTime = 0
                                        while waitDepositTime < 1.5 do
                                            task.wait(0.15)
                                            waitDepositTime = waitDepositTime + 0.15
                                            local carryNow = getRealBackpackCount(character)
                                            if carryNow < currentCarry then
                                                printLog("Step Akhir", "Scrap berhasil masuk ke Recycler!")
                                                break
                                            end
                                        end

                                        if isSurplusReady then
                                            printLog("Step Akhir", "Mengeksekusi Rebirth secara mulus!")
                                            invokeRemote("Rebirth")

                                            surplusAllTargetsMet = false
                                            highestFloorReached = 0
                                            task.wait(6)
                                            break
                                        end

                                        local waitEmpty = 0
                                        while character and getRealBackpackCount(character) > 0 and waitEmpty < 2 do
                                            task.wait(0.2)
                                            waitEmpty = waitEmpty + 0.2
                                        end
                                        break
                                    else
                                        printLog("Step Akhir", "Masih dalam perjalanan ke Recycler (Jarak: " .. math.floor(currentDist) .. " stud). Menunda Rebirth...")
                                        task.wait(0.5)
                                    end
                                else
                                    logError("Auto Sweep", "Recycler pemain tidak ditemukan saat tas penuh!")
                                    task.wait(1)
                                    break
                                end
                            end

                            local nearestScrap, idx = getNearestScrap(hrp.Position, availableScraps)
                            if nearestScrap then
                                table.remove(availableScraps, idx)
                                local targetPos = nearestScrap:IsA("Model") and nearestScrap:GetPivot().Position or nearestScrap.Position
                                local walkStatus = safeWalkTo(targetPos, 3, true)

                                if walkStatus ~= "FULL" and (autoSweep or (autoRebirthSurplus and surplusAllTargetsMet)) then
                                    fireCollectEvents(nearestScrap, hrp)
                                    task.wait(0.05)
                                end
                            else
                                break
                            end
                        end
                    else
                        task.wait(0.4)
                    end
                else
                    logError("Auto Sweep", "HumanoidRootPart tidak ada saat melakukan Sweep!")
                end
                isSweepRunning = false
            end
        end)

        if not loopOk then
            logError("Auto Sweep Main Thread", loopErr)
            isSweepRunning = false
        end
    end
end)

-- ==============================================================================
-- [15] BACKGROUND LOOPS UNTUK FITUR UPDATE BARU
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(UpdateHub.delayArenaFight > 0 and UpdateHub.delayArenaFight or 3.0)
        if UpdateHub.autoArenaFight then
            UpdateHub.executeArenaAutoFight()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if UpdateHub.autoRollCharms then
            UpdateHub.executeAutoRollCharms()
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(1.0)
        if UpdateHub.autoUfoEvent then
            local isLive = UpdateHub.isUfoEventActive()
            if isLive then
                local loc = UpdateHub.getChickenUfoLocation()
                local now = os.clock()

                if loc == "IN_CHAOS" then
                    -- Ayam sedang berada di arena tengah di bawah beam, JANGAN kirim perintah apapun agar tidak bulak-balik!
                    UpdateHub.ufoChickenStatus = "IN_CHAOS"

                elseif loc == "AT_BASE" then
                    -- Ayam berada di base: bisa baru mulai event, atau baru saja KO dari beam lalu respawn di base
                    if UpdateHub.ufoChickenStatus == "IN_CHAOS" or UpdateHub.ufoChickenStatus == "AT_BASE" or (now - (UpdateHub.lastUfoSendTime or 0) > 15) then
                        if UpdateHub.ufoChickenStatus == "IN_CHAOS" then
                            printLog("Auto UFO Event", "Ayam terdeteksi kembali ke base setelah upgrade beam. Mengirim ulang ke arena tengah...")
                            task.wait(1.2)
                        end

                        UpdateHub.executeSendChickenToUfoBeam(true)
                    end

                elseif loc == "IN_TRANSIT" then
                    -- Ayam sedang berlari dari base menuju arena tengah
                    -- Jika terjebak lebih dari 20 detik, reset status agar bisa dikirim ulang
                    if now - (UpdateHub.lastUfoSendTime or 0) > 20 then
                        UpdateHub.ufoChickenStatus = "AT_BASE"
                    end
                end
            else
                if UpdateHub.ufoChickenStatus ~= "AT_BASE" then
                    UpdateHub.ufoChickenStatus = "AT_BASE"
                end
            end
        else
            UpdateHub.ufoChickenStatus = "AT_BASE"
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(UpdateHub.delayPetEncourage > 0 and UpdateHub.delayPetEncourage or 5.0)
        if UpdateHub.autoPetEncourage then
            UpdateHub.executePetAndEncourage()
        end
    end
end)

printLog("Init", "SysHub berhasil dimuat dengan sempurna!")

task.spawn(function()
    task.wait(1.5)
    scanFlockChickens()
end)
