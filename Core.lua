--[[
    OnePanel_PvP - Core.lua
    Player vs. Player, Honor ranking, and PvP rewards plugin for OnePanel Suite.
    Designed exclusively for WoW Forever Beta (Interface 16001).
--]]

local addonName, addonTable = ...
local OnePanel = _G.OnePanel
local Utils = _G.OnePanelUtils

-------------------------------------------------------------------------------
-- PvP Rank Definitions & Progression Data (WoW Forever / Camelot)
-------------------------------------------------------------------------------

local PVP_RANKS = {
    [0] = {
        rank = 0,
        allianceTitle = "Civilian",
        hordeTitle = "Civilian",
        pointsReq = 0,
        nextPoints = 750,
        rewardTitle = "Faction Tabard",
        rewardIconAlliance = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardIconHorde = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardDesc = "Faction Tabard\nPurchased at the Champion's Hall (Alliance) or Hall of Legends (Horde).",
    },
    [1] = {
        rank = 1,
        allianceTitle = "Private",
        hordeTitle = "Scout",
        pointsReq = 750,
        nextPoints = 1500,
        rewardTitle = "Faction Tabard",
        rewardIconAlliance = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardIconHorde = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardDesc = "Private's Tabard (Alliance) or Scout's Tabard (Horde).\nDisplay your military allegiance on the battlefield.",
    },
    [2] = {
        rank = 2,
        allianceTitle = "Corporal",
        hordeTitle = "Grunt",
        pointsReq = 1500,
        nextPoints = 2500,
        rewardTitle = "PvP Insignia",
        rewardIconAlliance = "Interface\\Icons\\INV_Jewelry_TrinketPVP_01",
        rewardIconHorde = "Interface\\Icons\\INV_Jewelry_TrinketPVP_02",
        rewardDesc = "Insignia of the Alliance / Insignia of the Horde.\nTrinket: Dispels all movement impairing, charm, fear, and stun effects.",
    },
    [3] = {
        rank = 3,
        allianceTitle = "Sergeant",
        hordeTitle = "Sergeant",
        pointsReq = 2500,
        nextPoints = 3750,
        rewardTitle = "Sergeant's Cloak & 10% Discount",
        rewardIconAlliance = "Interface\\Icons\\INV_Misc_Cape_02",
        rewardIconHorde = "Interface\\Icons\\INV_Misc_Cape_04",
        rewardDesc = "Sergeant's Cloak / Cape and a permanent 10% discount on all faction vendor items and repairs.",
    },
    [4] = {
        rank = 4,
        allianceTitle = "Master Sergeant",
        hordeTitle = "Senior Sergeant",
        pointsReq = 3750,
        nextPoints = 5250,
        rewardTitle = "PvP Superior Necklace",
        rewardIconAlliance = "Interface\\Icons\\INV_Jewelry_Necklace_04",
        rewardIconHorde = "Interface\\Icons\\INV_Jewelry_Necklace_05",
        rewardDesc = "Master Sergeant's Insignia / Senior Sergeant's Insignia.\nSuperior quality PvP necklace with Stamina and combat stats.",
    },
    [5] = {
        rank = 5,
        allianceTitle = "Sergeant Major",
        hordeTitle = "First Sergeant",
        pointsReq = 5250,
        nextPoints = 7000,
        rewardTitle = "PvP Superior Bracers",
        rewardIconAlliance = "Interface\\Icons\\INV_Bracer_07",
        rewardIconHorde = "Interface\\Icons\\INV_Bracer_06",
        rewardDesc = "Superior quality PvP bracers tailored to your character's armor proficiency.",
    },
    [6] = {
        rank = 6,
        allianceTitle = "Knight",
        hordeTitle = "Stone Guard",
        pointsReq = 7000,
        nextPoints = 9000,
        rewardTitle = "Officer's Colors & Barracks Access",
        rewardIconAlliance = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardIconHorde = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
        rewardDesc = "Knight's Colors / Stone Guard's Herald.\nGrants full access to the Champion's Hall (Stormwind) or Hall of Legends (Orgrimmar).",
    },
    [7] = {
        rank = 7,
        allianceTitle = "Knight-Lieutenant",
        hordeTitle = "Blood Guard",
        pointsReq = 9000,
        nextPoints = 11250,
        rewardTitle = "Rare PvP Boots & Gloves",
        rewardIconAlliance = "Interface\\Icons\\INV_Boots_Plate_01",
        rewardIconHorde = "Interface\\Icons\\INV_Boots_Plate_02",
        rewardDesc = "Rare superior quality PvP set boots and gloves granting specialized class set bonuses.",
    },
    [8] = {
        rank = 8,
        allianceTitle = "Knight-Captain",
        hordeTitle = "Legionnaire",
        pointsReq = 11250,
        nextPoints = 13750,
        rewardTitle = "Rare PvP Chest & Legs",
        rewardIconAlliance = "Interface\\Icons\\INV_Chest_Plate03",
        rewardIconHorde = "Interface\\Icons\\INV_Chest_Plate04",
        rewardDesc = "Rare superior quality PvP set chest and leg armor granting specialized class set bonuses.",
    },
    [9] = {
        rank = 9,
        allianceTitle = "Knight-Champion",
        hordeTitle = "Centurion",
        pointsReq = 13750,
        nextPoints = 16500,
        rewardTitle = "Faction Battle Standard",
        rewardIconAlliance = "Interface\\Icons\\INV_Banner_01",
        rewardIconHorde = "Interface\\Icons\\INV_Banner_02",
        rewardDesc = "Alliance Battle Standard / Horde Battle Standard.\nPlants a banner that increases maximum health of nearby friendly party members by 15%.",
    },
    [10] = {
        rank = 10,
        allianceTitle = "Lieutenant Commander",
        hordeTitle = "Champion",
        pointsReq = 16500,
        nextPoints = 19500,
        rewardTitle = "Rare PvP Helm & Shoulders",
        rewardIconAlliance = "Interface\\Icons\\INV_Helmet_05",
        rewardIconHorde = "Interface\\Icons\\INV_Helmet_06",
        rewardDesc = "Rare superior quality PvP set helmet and shoulder armor, completing the 6-piece Rare set.",
    },
    [11] = {
        rank = 11,
        allianceTitle = "Commander",
        hordeTitle = "Lieutenant General",
        pointsReq = 19500,
        nextPoints = 21750,
        rewardTitle = "Commander's War Mounts",
        rewardIconAlliance = "Interface\\Icons\\Ability_Mount_MountainRam",
        rewardIconHorde = "Interface\\Icons\\Ability_Mount_BlackDireWolf",
        rewardDesc = "Access to purchasing 100% speed Epic PvP War Mounts (no riding skill upgrade required) & World Defense chat privileges.",
    },
    [12] = {
        rank = 12,
        allianceTitle = "Marshal",
        hordeTitle = "General",
        pointsReq = 21750,
        nextPoints = 23250,
        rewardTitle = "Epic PvP Gloves, Legs & Boots",
        rewardIconAlliance = "Interface\\Icons\\INV_Pants_Plate_05",
        rewardIconHorde = "Interface\\Icons\\INV_Pants_Plate_06",
        rewardDesc = "Epic Quality PvP Plate/Mail/Leather/Cloth Armor Set (Part 1).",
    },
    [13] = {
        rank = 13,
        allianceTitle = "Field Marshal",
        hordeTitle = "Warlord",
        pointsReq = 23250,
        nextPoints = 24750,
        rewardTitle = "Epic PvP Helm, Shoulders & Chest",
        rewardIconAlliance = "Interface\\Icons\\INV_Helmet_03",
        rewardIconHorde = "Interface\\Icons\\INV_Helmet_04",
        rewardDesc = "Epic Quality PvP Plate/Mail/Leather/Cloth Armor Set (Part 2 - Complete 6-Piece Epic Set).",
    },
    [14] = {
        rank = 14,
        allianceTitle = "Grand Marshal",
        hordeTitle = "High Warlord",
        pointsReq = 24750,
        nextPoints = 24750,
        rewardTitle = "Grand Marshal / High Warlord Weapons",
        rewardIconAlliance = "Interface\\Icons\\INV_Sword_39",
        rewardIconHorde = "Interface\\Icons\\INV_Sword_40",
        rewardDesc = "Legendary Epic PvP Weapons: Grand Marshal and High Warlord swords, axes, polearms, bows, daggers, shields, and staves.",
    },
}

-------------------------------------------------------------------------------
-- Formatting & Atlas Utilities
-------------------------------------------------------------------------------

local function GetStandardFont()
    local fontObj = _G.GameFontHighlight or _G.SystemFont_Med1 or _G.GameFontNormal
    if fontObj and fontObj.GetFont then
        local fontPath = fontObj:GetFont()
        if fontPath and fontPath ~= "" then return fontPath end
    end
    return "Fonts\\FRIZQT__.TTF"
end

local function SafeHasAtlas(atlasName)
    if not atlasName then return false end
    if C_Texture and C_Texture.GetAtlasInfo then
        local ok, info = pcall(C_Texture.GetAtlasInfo, atlasName)
        return ok and info ~= nil
    end
    return false
end

local function FormatNumber(value)
    if not value then return "0" end
    local formatted = tostring(math.floor(value))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

local function ApplyModernPvPBarTexture(bar, isAlliance)
    if not bar then return end
    local atlas = nil
    if SafeHasAtlas("ui-castingbar-filling-channel") then
        atlas = "ui-castingbar-filling-channel"
    elseif SafeHasAtlas("ui-castingbar-filling-applyingcrafting") then
        atlas = "ui-castingbar-filling-applyingcrafting"
    elseif SafeHasAtlas("ui-castingbar-filling-standard") then
        atlas = "ui-castingbar-filling-standard"
    elseif SafeHasAtlas("common-stat-bar-white") then
        atlas = "common-stat-bar-white"
    end

    if atlas then
        pcall(bar.SetStatusBarTexture, bar, atlas)
        if isAlliance then
            bar:SetStatusBarColor(0.20, 0.65, 1.00, 1) -- Radiant Alliance Blue
        else
            bar:SetStatusBarColor(0.95, 0.25, 0.20, 1) -- Crimson Horde Red
        end
    else
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        if isAlliance then
            bar:SetStatusBarColor(0.20, 0.60, 0.95, 1)
        else
            bar:SetStatusBarColor(0.85, 0.20, 0.20, 1)
        end
    end
end

local function UpdateStatusBarSpark(bar, currentVal, maxRange)
    if not bar or not bar.Spark then return end
    if not maxRange or maxRange <= 0 then maxRange = 1 end

    local pct = math.min(1, math.max(0, (currentVal or 0) / maxRange))
    if pct > 0.02 and pct < 0.98 then
        bar.Spark:ClearAllPoints()
        bar.Spark:SetPoint("CENTER", bar, "LEFT", bar:GetWidth() * pct, 0)
        bar.Spark:Show()
    else
        bar.Spark:Hide()
    end
end

-------------------------------------------------------------------------------
-- UI Helper: Create Silver Button
-------------------------------------------------------------------------------

local function CreateSilverActionButton(parent, name, text)
    local btn
    if Utils and Utils.FrameHelper and Utils.FrameHelper.CreateSilverButton then
        btn = Utils.FrameHelper:CreateSilverButton(parent, name, text)
    else
        btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
        if text then btn:SetText(text) end
        if Utils and Utils.FrameHelper and Utils.FrameHelper.StyleButtonAsMetal then
            Utils.FrameHelper:StyleButtonAsMetal(btn)
        end
    end
    local fontStr = btn:GetFontString()
    if fontStr then
        fontStr:SetFont(GetStandardFont(), 12, "")
        fontStr:SetShadowOffset(1, -1)
        fontStr:SetShadowColor(0, 0, 0, 1)
    end
    return btn
end

-------------------------------------------------------------------------------
-- Safe WoW PvP API Data Extraction
-------------------------------------------------------------------------------

local function SafeGetPvPData()
    local factionGroup = UnitFactionGroup and UnitFactionGroup("player") or "Alliance"
    local isAlliance = (factionGroup == "Alliance")

    local currentRank = 0
    if UnitPVPRank then
        local ok, r = pcall(UnitPVPRank, "player")
        if ok and type(r) == "number" then
            currentRank = math.max(0, math.min(14, r))
        end
    end

    local rankName = nil
    if GetPVPRankInfo then
        local ok, name = pcall(GetPVPRankInfo, currentRank, "player")
        if ok and name and name ~= "" then
            rankName = name
        end
    end

    local rankInfo = PVP_RANKS[currentRank] or PVP_RANKS[0]
    if not rankName then
        rankName = isAlliance and rankInfo.allianceTitle or rankInfo.hordeTitle
    end

    local progressPct = 0
    if GetPVPRankProgress then
        local ok, prog = pcall(GetPVPRankProgress)
        if ok and type(prog) == "number" then
            progressPct = math.min(1, math.max(0, prog))
        end
    end

    -- Determine Rank Points:
    -- In WoW Forever, Rank 0 starts at 0 with 750 required for Rank 1.
    local curThreshold = rankInfo.pointsReq or 0
    local nextThreshold = rankInfo.nextPoints or 750
    local span = nextThreshold - curThreshold
    if span <= 0 then span = 1 end

    local currentPoints = curThreshold + math.floor(progressPct * span)
    if currentRank == 14 then
        currentPoints = 24750
        nextThreshold = 24750
    end

    -- Check if native CharacterHonorFrame has explicit text to adopt
    if CharacterHonorFrame and CharacterHonorFrame.RankPoints and CharacterHonorFrame.RankPoints.GetText then
        local ok, txt = pcall(CharacterHonorFrame.RankPoints.GetText, CharacterHonorFrame.RankPoints)
        if ok and txt and txt ~= "" then
            local c, m = txt:match("(%d+)[^%d]+(%d+)")
            if c and m then
                currentPoints = tonumber(c) or currentPoints
                nextThreshold = tonumber(m) or nextThreshold
            end
        end
    end

    -- Session & Lifetime Stats
    local todayHK, todayHonor = 0, 0
    if GetPVPSessionStats then
        local ok, hk, cp = pcall(GetPVPSessionStats)
        if ok then
            todayHK = hk or 0
            todayHonor = cp or 0
        end
    end

    local yesterdayHK, yesterdayHonor = 0, 0
    if GetPVPYesterdayStats then
        local ok, hk, cp = pcall(GetPVPYesterdayStats)
        if ok then
            yesterdayHK = hk or 0
            yesterdayHonor = cp or 0
        end
    end

    local thisWeekHK, thisWeekHonor = 0, 0
    if GetPVPThisWeekStats then
        local ok, hk, cp = pcall(GetPVPThisWeekStats)
        if ok then
            thisWeekHK = hk or 0
            thisWeekHonor = cp or 0
        end
    end

    local lifetimeHK, lifetimeDK, highestRank = 0, 0, 0
    if GetPVPLifetimeStats then
        local ok, hk, dk, hr = pcall(GetPVPLifetimeStats)
        if ok then
            lifetimeHK = hk or 0
            lifetimeDK = dk or 0
            highestRank = hr or currentRank
        end
    end

    local highestRankInfo = PVP_RANKS[highestRank] or PVP_RANKS[0]
    local highestRankTitle = isAlliance and highestRankInfo.allianceTitle or highestRankInfo.hordeTitle

    return {
        isAlliance = isAlliance,
        factionGroup = factionGroup,
        currentRank = currentRank,
        rankName = rankName,
        currentPoints = currentPoints,
        nextPoints = nextThreshold,
        progressPct = progressPct,
        todayHK = todayHK,
        todayHonor = todayHonor,
        yesterdayHK = yesterdayHK,
        yesterdayHonor = yesterdayHonor,
        thisWeekHK = thisWeekHK,
        thisWeekHonor = thisWeekHonor,
        lifetimeHK = lifetimeHK,
        lifetimeDK = lifetimeDK,
        highestRank = highestRank,
        highestRankTitle = highestRankTitle,
    }
end

-------------------------------------------------------------------------------
-- View Construction: Player vs. Player Master Container
-------------------------------------------------------------------------------

local function CreatePvPView(parentFrame)
    local container = CreateFrame("Frame", "OnePanel_PvPContainer", parentFrame)
    container:SetAllPoints(parentFrame)

    local inspectedRank = nil -- Currently previewed reward rank in subpanel (defaults to next rank)

    ---------------------------------------------------------------------------
    -- Left Area: Faction Crest Centerpiece, Rank Points, and Performance Hover
    ---------------------------------------------------------------------------

    local leftArea = CreateFrame("Frame", "OnePanel_PvPLeftArea", container)
    leftArea:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    leftArea:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    leftArea:SetWidth(338)
    container.LeftArea = leftArea

    -- Top Rank Title (Center Stage, 17pt Friz Quadrata)
    local rankTitle = leftArea:CreateFontString(nil, "OVERLAY")
    rankTitle:SetPoint("TOP", leftArea, "TOP", 0, -42)
    rankTitle:SetFont(GetStandardFont(), 17, "")
    rankTitle:SetTextColor(1, 1, 1, 1)
    rankTitle:SetShadowOffset(1, -1)
    rankTitle:SetShadowColor(0, 0, 0, 1)
    rankTitle:SetText("Civilian")
    leftArea.RankTitle = rankTitle

    -- Blizzard Native Title Accent Line (atlas: UI-Character-Info-Honor-LevelBG)
    local titleDivider = leftArea:CreateTexture(nil, "ARTWORK")
    titleDivider:SetPoint("TOP", rankTitle, "BOTTOM", 0, -8)
    if SafeHasAtlas("UI-Character-Info-Honor-LevelBG") then
        titleDivider:SetAtlas("UI-Character-Info-Honor-LevelBG", true)
    else
        titleDivider:SetSize(180, 1)
        titleDivider:SetColorTexture(0.35, 0.35, 0.35, 0.45)
    end

    -- Faction Crest & Circular Emblem Container (Centerpiece)
    local emblemFrame = CreateFrame("Frame", "OnePanel_PvPEmblemFrame", leftArea)
    emblemFrame:SetSize(190, 170)
    emblemFrame:SetPoint("TOP", rankTitle, "BOTTOM", 0, -14)

    -- Background Soft Glow (Blizzard atlas: UI-Character-Info-Honor-Bar-BG-Glow)
    local emblemGlow = emblemFrame:CreateTexture(nil, "BACKGROUND", nil, -2)
    emblemGlow:SetSize(230, 245)
    emblemGlow:SetPoint("CENTER", emblemFrame, "CENTER", 0, 0)
    if SafeHasAtlas("UI-Character-Info-Honor-Bar-BG-Glow") then
        emblemGlow:SetAtlas("UI-Character-Info-Honor-Bar-BG-Glow")
    else
        emblemGlow:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        emblemGlow:SetVertexColor(0.04, 0.04, 0.06, 0.95)
    end
    emblemFrame.Glow = emblemGlow

    -- Background Circular Disk (Blizzard atlas: UI-Character-Info-Honor-Bar-BG-Alliance / -Horde)
    local emblemBg = emblemFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    emblemBg:SetSize(115, 115)
    emblemBg:SetPoint("CENTER", emblemFrame, "CENTER", 0, 0)
    if SafeHasAtlas("UI-Character-Info-Honor-Bar-BG-Alliance") then
        emblemBg:SetAtlas("UI-Character-Info-Honor-Bar-BG-Alliance", true)
    else
        emblemBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        emblemBg:SetVertexColor(0.04, 0.04, 0.06, 0.95)
    end
    emblemFrame.Bg = emblemBg

    -- Central Faction Crest / Rank Icon (Blizzard atlas: UI-Character-Info-Honor-Icon-Alliance / -Horde or -%d)
    local emblemIcon = emblemFrame:CreateTexture(nil, "ARTWORK")
    emblemIcon:SetSize(72, 84)
    emblemIcon:SetPoint("CENTER", emblemFrame, "CENTER", 0, 0)
    if SafeHasAtlas("UI-Character-Info-Honor-Icon-Alliance") then
        emblemIcon:SetAtlas("UI-Character-Info-Honor-Icon-Alliance", true)
    else
        emblemIcon:SetSize(88, 88)
        emblemIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
    end
    emblemFrame.Icon = emblemIcon

    -- Outer Metallic Ring / Bezel with dragon/flourish wings (Blizzard atlas: UI-Character-Info-Honor-Bar)
    local emblemRing = emblemFrame:CreateTexture(nil, "BORDER")
    emblemRing:SetSize(190, 169)
    emblemRing:SetPoint("CENTER", emblemFrame, "CENTER", 0, -1)
    if SafeHasAtlas("UI-Character-Info-Honor-Bar") then
        emblemRing:SetAtlas("UI-Character-Info-Honor-Bar")
    else
        emblemRing:SetSize(140, 140)
        emblemRing:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        emblemRing:SetVertexColor(0.65, 0.65, 0.70, 1)
    end
    emblemFrame.Ring = emblemRing

    -- Bottom Rank Number Medallion (Circular golden coin badge anchored to bottom rim)
    -- Matching Blizzard's PVPHonorRewardTemplate: size 36x36, ring 48x48
    local rankBadge = CreateFrame("Frame", "OnePanel_PvPRankBadge", emblemFrame)
    rankBadge:SetSize(36, 36)
    rankBadge:SetPoint("BOTTOM", emblemFrame, "BOTTOM", 0, 4)

    -- Dark circular backing for rank badge
    local rankBadgeBacking = rankBadge:CreateTexture(nil, "BACKGROUND")
    rankBadgeBacking:SetSize(28, 28)
    rankBadgeBacking:SetPoint("CENTER", rankBadge, "CENTER", 0, 0)
    rankBadgeBacking:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    rankBadgeBacking:SetVertexColor(0.1, 0.1, 0.1, 1)

    -- Circular Golden Ring (Blizzard atlas: UI-Character-Info-Honor-RewardRing, perfectly concentric)
    local rankBadgeRing = rankBadge:CreateTexture(nil, "BORDER")
    rankBadgeRing:SetSize(48, 48)
    rankBadgeRing:SetPoint("CENTER", rankBadge, "CENTER", 0, 0)
    if SafeHasAtlas("UI-Character-Info-Honor-RewardRing") then
        rankBadgeRing:SetAtlas("UI-Character-Info-Honor-RewardRing")
    else
        rankBadgeRing:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild-Ring")
    end
    rankBadge.Ring = rankBadgeRing

    -- Rank Number Text (Center-aligned, perfectly centered in the concentric ring)
    local rankBadgeText = rankBadge:CreateFontString(nil, "OVERLAY")
    rankBadgeText:SetPoint("CENTER", rankBadge, "CENTER", 0, 1)
    rankBadgeText:SetFont(GetStandardFont(), 15, "")
    rankBadgeText:SetTextColor(1, 0.85, 0.1, 1)
    rankBadgeText:SetShadowOffset(1, -1)
    rankBadgeText:SetShadowColor(0, 0, 0, 1)
    rankBadgeText:SetText("0")
    emblemFrame.RankBadgeText = rankBadgeText

    -- Rank Points Text (e.g. "Rank Points: 0 / 750")
    local rankPointsLabel = leftArea:CreateFontString(nil, "OVERLAY")
    rankPointsLabel:SetPoint("TOP", emblemFrame, "BOTTOM", 0, -10)
    rankPointsLabel:SetFont(GetStandardFont(), 14, "")
    rankPointsLabel:SetShadowOffset(1, -1)
    rankPointsLabel:SetShadowColor(0, 0, 0, 1)
    rankPointsLabel:SetText("|cffffcc00Rank Points:|r |cffffffff0 / 750|r")
    leftArea.RankPointsLabel = rankPointsLabel

    -- Modern Gradient Rank Points Progress Bar
    local rankPointsBar = CreateFrame("StatusBar", "OnePanel_PvPRankPointsBar", leftArea)
    rankPointsBar:SetSize(240, 18)
    rankPointsBar:SetPoint("TOP", rankPointsLabel, "BOTTOM", 0, -8)

    local barBg = rankPointsBar:CreateTexture(nil, "BACKGROUND", nil, -2)
    barBg:SetAllPoints(rankPointsBar)
    if SafeHasAtlas("ui-castingbar-background") then
        barBg:SetAtlas("ui-castingbar-background")
    else
        barBg:SetColorTexture(0.04, 0.04, 0.06, 0.95)
    end
    rankPointsBar.Bg = barBg

    local barBorder = rankPointsBar:CreateTexture(nil, "OVERLAY", nil, 1)
    barBorder:SetPoint("TOPLEFT", rankPointsBar, "TOPLEFT", -2, 2)
    barBorder:SetPoint("BOTTOMRIGHT", rankPointsBar, "BOTTOMRIGHT", 2, -2)
    if SafeHasAtlas("ui-castingbar-frame") then
        barBorder:SetAtlas("ui-castingbar-frame")
    else
        barBorder:SetColorTexture(0.20, 0.18, 0.15, 0.9)
    end
    rankPointsBar.Border = barBorder

    local barSpark = rankPointsBar:CreateTexture(nil, "OVERLAY", nil, 2)
    barSpark:SetSize(8, 18)
    if SafeHasAtlas("ui-castingbar-pip") then
        barSpark:SetAtlas("ui-castingbar-pip")
    else
        barSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        barSpark:SetBlendMode("ADD")
    end
    barSpark:Hide()
    rankPointsBar.Spark = barSpark

    local barText = rankPointsBar:CreateFontString(nil, "OVERLAY", nil, 3)
    barText:SetPoint("CENTER", rankPointsBar, "CENTER", 0, 0)
    barText:SetFont(GetStandardFont(), 13, "")
    barText:SetShadowOffset(1, -1)
    barText:SetShadowColor(0, 0, 0, 1)
    barText:SetTextColor(1, 1, 1, 1)
    rankPointsBar.Text = barText
    leftArea.RankPointsBar = rankPointsBar

    -- Cached PvP data for hover tooltip
    local cachedPvPData = nil

    -- Interactive Tooltip on the Progress Bar (Honor & Combat Performance details)
    rankPointsBar:EnableMouse(true)
    rankPointsBar:SetScript("OnEnter", function(self)
        if not cachedPvPData then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Honor & Combat Performance", 1, 0.82, 0, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)

        GameTooltip:AddDoubleLine("Today's HKs:", FormatNumber(cachedPvPData.todayHK), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddDoubleLine("Today's Honor:", FormatNumber(cachedPvPData.todayHonor), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)

        GameTooltip:AddDoubleLine("Yesterday's HKs:", FormatNumber(cachedPvPData.yesterdayHK), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddDoubleLine("Yesterday's Honor:", FormatNumber(cachedPvPData.yesterdayHonor), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)

        GameTooltip:AddDoubleLine("This Week's HKs:", FormatNumber(cachedPvPData.thisWeekHK), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddDoubleLine("This Week's Honor:", FormatNumber(cachedPvPData.thisWeekHonor), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)

        GameTooltip:AddDoubleLine("Lifetime HKs:", FormatNumber(cachedPvPData.lifetimeHK), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddDoubleLine("Highest Rank:", string.format("%s (Rank %d)", cachedPvPData.highestRankTitle, cachedPvPData.highestRank), 0.8, 0.8, 0.8, 1, 0.82, 0)
        if cachedPvPData.lifetimeDK > 0 then
            GameTooltip:AddDoubleLine("Dishonorable Kills:", FormatNumber(cachedPvPData.lifetimeDK), 0.8, 0.8, 0.8, 1, 0.2, 0.2)
        end

        GameTooltip:Show()
    end)
    rankPointsBar:SetScript("OnLeave", function() GameTooltip_Hide() end)

    -- Subtle 1-Line Career Record Footer (Uncluttered, matches Blizzard frame aesthetics)
    local careerFooter = leftArea:CreateFontString(nil, "OVERLAY")
    careerFooter:SetPoint("BOTTOM", leftArea, "BOTTOM", 0, 14)
    careerFooter:SetFont(GetStandardFont(), 12, "")
    careerFooter:SetShadowOffset(1, -1)
    careerFooter:SetShadowColor(0, 0, 0, 1)
    careerFooter:SetText("|cff888888Lifetime HKs:|r |cffffffff0|r     |cff888888Highest Rank:|r |cffffcc00Civilian|r")
    leftArea.CareerFooter = careerFooter

    ---------------------------------------------------------------------------
    -- Right Area: Collapsible Side Details Panel
    ---------------------------------------------------------------------------

    local subPanel = CreateFrame("Frame", "OnePanel_PvPSubPanel", container)
    subPanel:SetPoint("TOPRIGHT", container, "TOPRIGHT", -6, -12)
    subPanel:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -6, 12)
    subPanel:SetWidth(198)
    container.SubPanel = subPanel

    -- Vertical Metal Divider separating left area from details
    local vDivider = container:CreateTexture("OnePanel_PvPVerticalDivider", "OVERLAY", nil, 2)
    vDivider:SetTexture("Interface\\FrameGeneral\\UIFrameMetalVertical")
    vDivider:SetTexCoord(258/512, 265/512, 0, 1)
    vDivider:SetVertTile(true)
    vDivider:SetWidth(7)
    vDivider:SetPoint("TOP", leftArea, "TOPRIGHT", 1, 10)
    vDivider:SetPoint("BOTTOM", leftArea, "BOTTOMRIGHT", 1, -14)
    container.VerticalDivider = vDivider

    -- Native Right-Side Collapse / Expand Toggle Button
    local toggleBtn = CreateFrame("Button", "OnePanel_PvPSideToggleButton", leftArea)
    toggleBtn:SetSize(28, 28)
    toggleBtn:SetPoint("TOPRIGHT", leftArea, "TOPRIGHT", -14, -18)
    toggleBtn:SetFrameLevel(510)

    local toggleIcon = toggleBtn:CreateTexture(nil, "ARTWORK")
    toggleIcon:SetAllPoints(toggleBtn)
    local setNorm = pcall(function() toggleIcon:SetTexture(130869) end)
    if not setNorm or not toggleIcon:GetTexture() then
        toggleIcon:SetTexture("Interface\\Buttons\\UI-SpellbookSearch-DrillDown")
    end
    toggleBtn.Icon = toggleIcon

    local toggleHilight = toggleBtn:CreateTexture(nil, "HIGHLIGHT")
    toggleHilight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    toggleHilight:SetBlendMode("ADD")
    toggleHilight:SetAllPoints(toggleBtn)

    local function UpdateToggleIcon()
        if OnePanel and OnePanel.isExpanded then
            toggleIcon:SetTexCoord(0, 1, 0, 1)
        else
            toggleIcon:SetTexCoord(1, 0, 0, 1)
        end
    end
    toggleBtn.UpdateIcon = UpdateToggleIcon
    UpdateToggleIcon()

    toggleBtn:SetScript("OnClick", function()
        if OnePanel and OnePanel.SetPanelExpanded then
            OnePanel:SetPanelExpanded(not OnePanel.isExpanded)
        end
        UpdateToggleIcon()
    end)

    toggleBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText((OnePanel and OnePanel.isExpanded) and "Collapse Details Panel" or "Expand Details Panel", 1, 1, 1)
        GameTooltip:Show()
    end)
    toggleBtn:SetScript("OnLeave", function() GameTooltip_Hide() end)
    container.RightSideToggleButton = toggleBtn

    -- Sync subPanel and vertical divider visibility with OnePanel master expand state
    if OnePanel then
        subPanel:SetShown(OnePanel.isExpanded ~= false)
        vDivider:SetShown(OnePanel.isExpanded ~= false)
    end
    if Utils and Utils.EventBus then
        Utils.EventBus:Register("ONEPANEL_EXPAND_STATE_CHANGED", function(isExpanded)
            if subPanel and subPanel.SetShown then
                subPanel:SetShown(isExpanded)
            end
            if vDivider and vDivider.SetShown then
                vDivider:SetShown(isExpanded)
            end
            if toggleBtn and toggleBtn.UpdateIcon then
                toggleBtn:UpdateIcon()
            end
        end)
    end

    ---------------------------------------------------------------------------
    -- Sub-Panel Details Widgets (Matching WoW Forever In-Game PvP Layout)
    ---------------------------------------------------------------------------

    -- Detail Header: Rank Title (17pt Friz Quadrata light gold/white, centered)
    local detailHeader = subPanel:CreateFontString(nil, "OVERLAY")
    detailHeader:SetPoint("TOPLEFT", subPanel, "TOPLEFT", 6, -14)
    detailHeader:SetPoint("TOPRIGHT", subPanel, "TOPRIGHT", -6, -14)
    detailHeader:SetJustifyH("CENTER")
    detailHeader:SetFont(GetStandardFont(), 17, "")
    detailHeader:SetTextColor(1, 0.9, 0.6, 1)
    detailHeader:SetShadowOffset(1, -1)
    detailHeader:SetShadowColor(0, 0, 0, 1)
    subPanel.DetailHeader = detailHeader

    -- Cap Explanation Paragraph (13pt Friz Quadrata, spacing 3)
    local capExplanation = subPanel:CreateFontString(nil, "OVERLAY")
    capExplanation:SetPoint("TOPLEFT", subPanel, "TOPLEFT", 10, -44)
    capExplanation:SetPoint("TOPRIGHT", subPanel, "TOPRIGHT", -10, -44)
    capExplanation:SetJustifyH("LEFT")
    capExplanation:SetWordWrap(true)
    capExplanation:SetFont(GetStandardFont(), 13, "")
    capExplanation:SetSpacing(3)
    capExplanation:SetTextColor(0.90, 0.90, 0.90, 1)
    capExplanation:SetShadowOffset(1, -1)
    capExplanation:SetShadowColor(0, 0, 0, 1)
    capExplanation:SetText("Each week, the Rank Points cap is increased, up to a maximum of 24750 for Rank 14.")
    subPanel.CapExplanation = capExplanation

    -- Milestone Rewards Navigation Banner (Blizzard atlas: UI-Character-Info-Title, 192x36)
    local rewardsNav = CreateFrame("Frame", "OnePanel_PvPRewardsNav", subPanel)
    rewardsNav:SetPoint("TOPLEFT", subPanel, "TOPLEFT", 3, -118)
    rewardsNav:SetPoint("TOPRIGHT", subPanel, "TOPRIGHT", -3, -118)
    rewardsNav:SetHeight(36)
    subPanel.RewardsNav = rewardsNav

    -- Background Banner Texture (atlas: UI-Character-Info-Title, matching Blizzard CharacterFrameSidePaneCategoryTemplate)
    local bannerBg = rewardsNav:CreateTexture(nil, "BACKGROUND")
    bannerBg:SetAllPoints(rewardsNav)
    if SafeHasAtlas("UI-Character-Info-Title") then
        bannerBg:SetAtlas("UI-Character-Info-Title")
    else
        bannerBg:SetColorTexture(0.12, 0.10, 0.08, 0.85)
    end
    rewardsNav.Bg = bannerBg

    -- Previous Rank Arrow Button (<) embedded inside left edge
    local prevBtn = CreateFrame("Button", "OnePanel_PvPPrevRewardBtn", rewardsNav)
    prevBtn:SetSize(18, 18)
    prevBtn:SetPoint("LEFT", rewardsNav, "LEFT", 6, 0)
    prevBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookSearch-PrevPage-Up")
    prevBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookSearch-PrevPage-Down")
    prevBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookSearch-PrevPage-Disabled")
    prevBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    rewardsNav.PrevBtn = prevBtn

    -- Next Rank Arrow Button (>) embedded inside right edge
    local nextBtn = CreateFrame("Button", "OnePanel_PvPNextRewardBtn", rewardsNav)
    nextBtn:SetSize(18, 18)
    nextBtn:SetPoint("RIGHT", rewardsNav, "RIGHT", -6, 0)
    nextBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookSearch-NextPage-Up")
    nextBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookSearch-NextPage-Down")
    nextBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookSearch-NextPage-Disabled")
    nextBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    rewardsNav.NextBtn = nextBtn

    -- Center Title Label (11pt GameFontNormal, gold, perfectly sized to never overflow 150px inner width)
    local bannerText = rewardsNav:CreateFontString(nil, "OVERLAY")
    bannerText:SetPoint("LEFT", prevBtn, "RIGHT", 4, 1)
    bannerText:SetPoint("RIGHT", nextBtn, "LEFT", -4, 1)
    bannerText:SetJustifyH("CENTER")
    bannerText:SetJustifyV("MIDDLE")
    bannerText:SetWordWrap(false)
    bannerText:SetFont(GetStandardFont(), 11, "")
    bannerText:SetTextColor(1, 0.82, 0, 1)
    bannerText:SetShadowOffset(1, -1)
    bannerText:SetShadowColor(0, 0, 0, 1)
    bannerText:SetText("Next Rewards at Rank 1")
    rewardsNav.BannerText = bannerText

    -- Arrow Click Navigation Handlers
    prevBtn:SetScript("OnClick", function()
        inspectedRank = math.max(1, (inspectedRank or 1) - 1)
        if container.Refresh then container:Refresh() end
    end)

    nextBtn:SetScript("OnClick", function()
        inspectedRank = math.min(14, (inspectedRank or 1) + 1)
        if container.Refresh then container:Refresh() end
    end)

    -- Reward Item Container Card (Matching CharacterFrameSidePaneIconRowTemplate)
    local rewardCard = CreateFrame("Frame", nil, subPanel)
    rewardCard:SetPoint("TOPLEFT", rewardsNav, "BOTTOMLEFT", 0, -12)
    rewardCard:SetPoint("TOPRIGHT", rewardsNav, "BOTTOMRIGHT", 0, -12)
    rewardCard:SetHeight(40)

    -- Item Icon Slot (atlas: UI-Character-Info-GearSlot)
    local rewardItemIcon = CreateFrame("Button", nil, rewardCard)
    rewardItemIcon:SetSize(36, 36)
    rewardItemIcon:SetPoint("LEFT", rewardCard, "LEFT", 4, 0)

    local iconSlotBg = rewardItemIcon:CreateTexture(nil, "BACKGROUND")
    iconSlotBg:SetSize(36, 36)
    iconSlotBg:SetPoint("CENTER", rewardItemIcon, "CENTER", 0, 0)
    if SafeHasAtlas("UI-Character-Info-GearSlot") then
        iconSlotBg:SetAtlas("UI-Character-Info-GearSlot", true)
    else
        iconSlotBg:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    end
    rewardItemIcon.SlotBg = iconSlotBg

    local iconTex = rewardItemIcon:CreateTexture(nil, "ARTWORK")
    iconTex:SetSize(30, 30)
    iconTex:SetPoint("CENTER", rewardItemIcon, "CENTER", 0, 0)
    iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    rewardItemIcon.Texture = iconTex

    -- Reward Title Text
    local rewardTitleText = rewardCard:CreateFontString(nil, "OVERLAY")
    rewardTitleText:SetPoint("LEFT", rewardItemIcon, "RIGHT", 8, 0)
    rewardTitleText:SetPoint("RIGHT", rewardCard, "RIGHT", -2, 0)
    rewardTitleText:SetJustifyH("LEFT")
    rewardTitleText:SetWordWrap(true)
    rewardTitleText:SetFont(GetStandardFont(), 13, "")
    rewardTitleText:SetTextColor(1, 0.82, 0, 1)
    rewardTitleText:SetShadowOffset(1, -1)
    rewardTitleText:SetShadowColor(0, 0, 0, 1)
    rewardTitleText:SetText("Faction Tabard")
    rewardCard.TitleText = rewardTitleText
    subPanel.RewardCard = rewardCard

    -- Quartermaster Location Instruction
    local quartermasterText = subPanel:CreateFontString(nil, "OVERLAY")
    quartermasterText:SetPoint("TOPLEFT", rewardCard, "BOTTOMLEFT", 4, -14)
    quartermasterText:SetPoint("TOPRIGHT", rewardCard, "BOTTOMRIGHT", -4, -14)
    quartermasterText:SetJustifyH("LEFT")
    quartermasterText:SetWordWrap(true)
    quartermasterText:SetFont(GetStandardFont(), 13, "")
    quartermasterText:SetSpacing(3)
    quartermasterText:SetTextColor(0.85, 0.85, 0.85, 1)
    quartermasterText:SetShadowOffset(1, -1)
    quartermasterText:SetShadowColor(0, 0, 0, 1)
    subPanel.QuartermasterText = quartermasterText

    ---------------------------------------------------------------------------
    -- Master Refresh Engine
    ---------------------------------------------------------------------------

    local function Refresh()
        local data = SafeGetPvPData()
        cachedPvPData = data

        -- Left Area Updates
        rankTitle:SetText(data.rankName)
        emblemFrame.RankBadgeText:SetText(tostring(data.currentRank))

        if data.isAlliance then
            if SafeHasAtlas("UI-Character-Info-Honor-Bar-BG-Alliance") then
                emblemFrame.Bg:SetAtlas("UI-Character-Info-Honor-Bar-BG-Alliance", true)
            else
                emblemFrame.Bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
                emblemFrame.Bg:SetVertexColor(0.04, 0.04, 0.06, 0.95)
            end

            if data.currentRank == 0 then
                if SafeHasAtlas("UI-Character-Info-Honor-Icon-Alliance") then
                    emblemFrame.Icon:SetAtlas("UI-Character-Info-Honor-Icon-Alliance", true)
                else
                    emblemFrame.Icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
                end
            else
                local rankAtlas = string.format("UI-Character-Info-Honor-Icon-%d", data.currentRank)
                if SafeHasAtlas(rankAtlas) then
                    emblemFrame.Icon:SetAtlas(rankAtlas, true)
                else
                    emblemFrame.Icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
                end
            end
        else
            if SafeHasAtlas("UI-Character-Info-Honor-Bar-BG-Horde") then
                emblemFrame.Bg:SetAtlas("UI-Character-Info-Honor-Bar-BG-Horde", true)
            else
                emblemFrame.Bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
                emblemFrame.Bg:SetVertexColor(0.04, 0.04, 0.06, 0.95)
            end

            if data.currentRank == 0 then
                if SafeHasAtlas("UI-Character-Info-Honor-Icon-Horde") then
                    emblemFrame.Icon:SetAtlas("UI-Character-Info-Honor-Icon-Horde", true)
                else
                    emblemFrame.Icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde")
                end
            else
                local rankAtlas = string.format("UI-Character-Info-Honor-Icon-%d", data.currentRank)
                if SafeHasAtlas(rankAtlas) then
                    emblemFrame.Icon:SetAtlas(rankAtlas, true)
                else
                    emblemFrame.Icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde")
                end
            end
        end

        -- Rank Points & Bar
        local curPts = data.currentPoints
        local maxPts = data.nextPoints
        if maxPts <= 0 then maxPts = 750 end

        rankPointsLabel:SetText(string.format("|cffffcc00Rank Points:|r |cffffffff%s / %s|r", FormatNumber(curPts), FormatNumber(maxPts)))

        rankPointsBar:SetMinMaxValues(0, maxPts)
        rankPointsBar:SetValue(math.min(maxPts, curPts))
        ApplyModernPvPBarTexture(rankPointsBar, data.isAlliance)
        UpdateStatusBarSpark(rankPointsBar, curPts, maxPts)

        local pct = math.min(100, math.floor((curPts / maxPts) * 100))
        if data.currentRank == 14 then
            barText:SetText(string.format("%s / %s (Max Rank)", FormatNumber(curPts), FormatNumber(maxPts)))
        else
            barText:SetText(string.format("%s / %s (%d%%)", FormatNumber(curPts), FormatNumber(maxPts), pct))
        end

        -- Career Footer
        careerFooter:SetText(string.format(
            "|cff888888Lifetime HKs:|r |cffffffff%s|r     |cff888888Highest Rank:|r |cffffcc00%s (Rank %d)|r",
            FormatNumber(data.lifetimeHK),
            data.highestRankTitle,
            data.highestRank
        ))

        -- SubPanel Updates
        detailHeader:SetText(data.rankName)

        -- Determine preview rank (default to player rank + 1, min 1, max 14)
        if not inspectedRank then
            inspectedRank = math.min(14, math.max(1, data.currentRank + 1))
        end

        local previewInfo = PVP_RANKS[inspectedRank] or PVP_RANKS[1]
        local previewTitle = data.isAlliance and previewInfo.allianceTitle or previewInfo.hordeTitle

        -- Update Banner Plate Text and Arrow Button States
        if inspectedRank == (data.currentRank + 1) then
            rewardsNav.BannerText:SetText(string.format("Next Rewards at Rank %d", inspectedRank))
        else
            rewardsNav.BannerText:SetText(string.format("Rewards at Rank %d", inspectedRank))
        end

        prevBtn:SetEnabled(inspectedRank > 1)
        nextBtn:SetEnabled(inspectedRank < 14)

        local rewardIcon = data.isAlliance and previewInfo.rewardIconAlliance or previewInfo.rewardIconHorde
        iconTex:SetTexture(rewardIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        rewardTitleText:SetText(previewInfo.rewardTitle or "PvP Reward")

        -- Item Tooltip on Hover
        rewardItemIcon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(previewInfo.rewardTitle, 1, 0.82, 0, 1)
            if previewInfo.rewardDesc then
                GameTooltip:AddLine(previewInfo.rewardDesc, 1, 1, 1, true)
            end
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(string.format("Requires PvP Rank %d (%s)", inspectedRank, previewTitle), 0.5, 0.8, 1)
            GameTooltip:Show()
        end)
        rewardItemIcon:SetScript("OnLeave", function() GameTooltip_Hide() end)

        if data.isAlliance then
            quartermasterText:SetText("Rewards may be purchased at the Champion's Hall in Stormwind.")
        else
            quartermasterText:SetText("Rewards may be purchased at the Hall of Legends in Orgrimmar.")
        end
    end

    container.Refresh = Refresh

    ---------------------------------------------------------------------------
    -- Event Listener
    ---------------------------------------------------------------------------

    local eventFrame = CreateFrame("Frame", nil, container)
    eventFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
    eventFrame:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
    eventFrame:RegisterEvent("HONOR_XP_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    eventFrame:SetScript("OnEvent", function(self, event)
        if container:IsVisible() and Refresh then
            Refresh()
        end
    end)

    return container
end

-------------------------------------------------------------------------------
-- OnePanel Plugin Registration
-------------------------------------------------------------------------------

local function RegisterPvPPlugin()
    if not OnePanel then return end

    OnePanel:RegisterPlugin({
        id = "PvP",
        title = "Player vs. Player",
        order = 40, -- Tab 4, positioned directly after Skills (30)
        icon = "Interface\\Icons\\Spell_Holy_FistOfJustice",
        CreateView = CreatePvPView,
        OnShow = function(container)
            if OnePanel and OnePanel.SetTitleText then
                OnePanel:SetTitleText("Player vs. Player")
            end
            if OnePanel and OnePanel.SetHeaderPortrait then
                OnePanel:SetHeaderPortrait("Interface\\Icons\\Spell_Holy_FistOfJustice", nil, false)
            end
            if container and container.Refresh then
                container:Refresh()
            end
        end,
        OnHide = function(container)
            GameTooltip_Hide()
        end
    })
end

-------------------------------------------------------------------------------
-- Initialization Listener
-------------------------------------------------------------------------------

local loadFrame = CreateFrame("Frame", "OnePanel_PvP_LoadFrame")
loadFrame:RegisterEvent("PLAYER_LOGIN")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        RegisterPvPPlugin()
    end
end)

-------------------------------------------------------------------------------
-- Diagnostic Slash Command
-------------------------------------------------------------------------------

SLASH_OPPVP1 = "/oppvp"
SlashCmdList["OPPVP"] = function()
    local d = SafeGetPvPData()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[OnePanel_PvP Debug]|r Faction: " .. tostring(d.factionGroup))
    DEFAULT_CHAT_FRAME:AddMessage("  Current Rank: " .. tostring(d.currentRank) .. " (" .. tostring(d.rankName) .. ")")
    DEFAULT_CHAT_FRAME:AddMessage("  Rank Points: " .. tostring(d.currentPoints) .. " / " .. tostring(d.nextPoints))
    DEFAULT_CHAT_FRAME:AddMessage("  Today: " .. tostring(d.todayHK) .. " HKs, " .. tostring(d.todayHonor) .. " Honor")
    DEFAULT_CHAT_FRAME:AddMessage("  Yesterday: " .. tostring(d.yesterdayHK) .. " HKs, " .. tostring(d.yesterdayHonor) .. " Honor")
    DEFAULT_CHAT_FRAME:AddMessage("  This Week: " .. tostring(d.thisWeekHK) .. " HKs, " .. tostring(d.thisWeekHonor) .. " Honor")
    DEFAULT_CHAT_FRAME:AddMessage("  Lifetime: " .. tostring(d.lifetimeHK) .. " HKs, " .. tostring(d.lifetimeDK) .. " DKs, Highest Rank: " .. tostring(d.highestRankTitle))
end
