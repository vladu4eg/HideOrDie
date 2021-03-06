-- This is the primary trollnelves2 trollnelves2 script and should be used to assist in initializing your game mode
-- Set this to true if you want to see a complete debug output of all events/processes done by trollnelves2
-- You can also change the cvar 'trollnelves2_spew' at any time to 1 or 0 for output/no output
TROLLNELVES2_DEBUG_SPEW = true
LinkLuaModifier("modifier_movespeed_x4",
    "libraries/modifiers/modifier_movespeed_x4.lua",
LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_movespeed_x2",
    "libraries/modifiers/modifier_movespeed_x2.lua",
LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_antiblock",
    "libraries/modifiers/modifier_antiblock.lua",
LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_trees",
    "libraries/modifiers/modifier_attack_trees.lua",
LUA_MODIFIER_MOTION_NONE)

if trollnelves2 == nil then
    DebugPrint('[TROLLNELVES2] creating trollnelves2 game mode')
    _G.trollnelves2 = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/util')
require('libraries/notifications')
require('libraries/popups')
require('libraries/team')
require('libraries/player')
require('libraries/entity')
require('libraries/animations')

require('runes')

require('internal/trollnelves2')

require('top')
require('settings')
require('events')
require('donate')
require('reklama')
require('chatcommand')
require('votekick')
require('drop')
require('wearables')
require('SelectPets')
require('pets')
require('shop')
require('flag')
require('filter')
require('speech_bubble/speech_bubble_class')
require('libraries/worldpanels')

trollPlayerID = {}

function trollnelves2:PostLoadPrecache()
    Pets:Init()
    DebugPrint("[BAREBONES] Performing Post-Load precache")
end
-- Gets called when a player chooses if he wants to be troll or not
function OnPlayerTeamChoose(eventSourceIndex, args)
    local playerID = args["playerID"]
    local vote = args["team"]
    GameRules.playerTeamChoices[playerID] = vote
end

function trollnelves2:GameSetup()
    if IsServer() then
        for pID = 0, DOTA_MAX_TEAM_PLAYERS do
            if PlayerResource:IsValidPlayerID(pID) then
                PlayerResource:SetCustomTeamAssignment(pID, DOTA_TEAM_GOODGUYS)
                PlayerResource:SetSelectedHero(pID, ELF_HERO[1])
                GameRules.Score[pID] = 0
                GameRules.PlayersFPS[pID] = false
                local steam = tostring(PlayerResource:GetSteamID(pID))
                CustomNetTables:SetTableValue("Shop", tostring(pID), GameRules.PoolTable)
                Shop.RequestBonusTroll(pID, steam, callback)
                Shop.RequestVip(pID, steam, callback)
                Shop.RequestSkin(pID, steam, callback)
                Shop.RequestPets(pID, steam, callback)
                Shop.RequestBonus(pID, steam, callback)
                Shop.RequestVipDefaults(pID, steam, callback)
                Shop.RequestSkinDefaults(pID, steam, callback)
                Shop.RequestPetsDefaults(pID, steam, callback)
                Stats.RequestData(pID)
                Shop.RequestCoint(pID, steam, callback)
                Shop.RequestChests(pID, steam, callback)
                Shop.RequestSounds(pID, steam, callback)
            end
        end
        Stats.RequestDataTop10("1", callback)
        Stats.RequestDataTop10("2", callback)
        Stats.RequestDataTop10("3", callback)
        Stats.RequestDataTop10("4", callback)
        Donate:CreateList()
        DebugPrint("count player " .. GameRules.PlayersCount)
        Timers:CreateTimer(TEAM_CHOICE_TIME, function()
            GameRules.PlayersCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
            GameRules:SendCustomMessage("<font color='#00FFFF '> Number of players: " .. GameRules.PlayersCount .. "</font>" ,  0, 0)
            SelectHeroes()
            GameRules:FinishCustomGameSetup()
        end)
    end
end

function SelectHeroes()
    local allPlayersIDs = {}
    local wannabeTrollIDs = {}
    local donateTroll = {}
    for pID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(pID) then
            table.insert(allPlayersIDs, pID)
            local playerSelection = GameRules.playerTeamChoices[pID]
            if playerSelection == "troll" and
                PlayerResource:GetConnectionState(pID) == 2 then
                table.insert(wannabeTrollIDs, pID)
            end
            PlayerResource:SetCustomTeamAssignment(pID, DOTA_TEAM_GOODGUYS)
        end
    end
    local countTroll = 0
    
    if GameRules.PlayersCount >= 1 and GameRules.PlayersCount <= 5 then
        countTroll = 1
        elseif GameRules.PlayersCount >= 6 and GameRules.PlayersCount <= 8 then
        countTroll = 2
        else
        countTroll = 3
    end
    DebugPrint("First countTroll " .. countTroll)  
    if #wannabeTrollIDs > 0 then
        if #GameRules.BonusTrollIDs > 0 then
            DebugPrint("Count Donate: " .. #GameRules.BonusTrollIDs)
            for i, bonus in ipairs(GameRules.BonusTrollIDs) do
                local playerID, chance = unpack(bonus)
                for j = 1, #wannabeTrollIDs do
                    if playerID == wannabeTrollIDs[j] then
                        DebugPrint("Do table.remove(wannabeTrollIDs, j)" .. #wannabeTrollIDs)
                        table.insert(donateTroll, {playerID, chance})
                        table.remove(wannabeTrollIDs, j)
                        DebugPrint("Posle table.remove(wannabeTrollIDs, j)" .. #wannabeTrollIDs)
                    end
                end
            end
        end
    end
    if #donateTroll >= 1 then
        for i, donate in ipairs(donateTroll) do
            local playerID, chance = unpack(donate)
            if countTroll > 0 then
                trollPlayerID[#trollPlayerID+1] = playerID
                DebugPrint("donateTroll >= 1 countTrol " .. countTroll) 
                DebugPrint("donateTroll >= 1 playerID " .. playerID) 
                table.remove(allPlayersIDs, i)	
                countTroll = countTroll - 1
            end
        end
    end
    if #wannabeTrollIDs > 0 and countTroll > 0 then
        for i, playerID in ipairs(wannabeTrollIDs) do
            if countTroll > 0 then
                trollPlayerID[#trollPlayerID+1] = playerID
                DebugPrint("#wannabeTrollIDs > 0 countTrol " .. countTroll) 
                DebugPrint("donateTroll >= 1 playerID " .. playerID) 
                table.remove(allPlayersIDs, i)
                countTroll = countTroll - 1
            end
        end
    end
    if countTroll > 0 then
        DebugPrint("countTroll " .. countTroll)
        DebugPrint("wannabeTrollIDs " .. #wannabeTrollIDs)
        DebugPrint("allPlayersIDs " .. #allPlayersIDs)
        DebugPrint("BonusTrollIDs " .. #GameRules.BonusTrollIDs)
        for i, pID in ipairs(allPlayersIDs) do
            if countTroll > 0 then
                DebugPrint("in countTroll > 0 pID " .. pID)
                trollPlayerID[#trollPlayerID+1] = pID
                table.remove(allPlayersIDs, i)
                countTroll = countTroll - 1
            end
        end
    end    
    if not GameRules.test then
        DebugPrint("not GameRules.test countTroll " .. countTroll)
        DebugPrint("not GameRules.test #trollPlayerID " .. #trollPlayerID)
        GameRules.TrollCount = #trollPlayerID
		for i=1, #trollPlayerID do
            DebugPrint("trollPlayerID[i] " .. trollPlayerID[i])
			PlayerResource:SetCustomTeamAssignment(trollPlayerID[i] , DOTA_TEAM_BADGUYS)
			PlayerResource:SetSelectedHero(trollPlayerID[i], TROLL_HERO[1])
        end
    end
    local elfCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    for i = 1, elfCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, i)
        PlayerResource:SetSelectedHero(pID, ELF_HERO[1])
        if GameRules.colorCounter <= #PLAYER_COLORS then
            local color = PLAYER_COLORS[GameRules.colorCounter]
            PlayerResource:SetCustomPlayerColor(pID, color[1], color[2], color[3])
            GameRules.colorCounter = GameRules.colorCounter + 1
        end
    end
end

function trollnelves2:OnHeroInGame(hero)
    DebugPrint("OnHeroInGame")
    local team = hero:GetTeamNumber()
    InitializeHero(hero)
    if team == DOTA_TEAM_BADGUYS then InitializeBadHero(hero) end
    
    if hero:IsElf() or PlayerResource:GetSelectedHeroName(hero:GetPlayerOwnerID()) == "npc_dota_hero_dark_seer" then
        InitializeBuilder(hero)
        elseif hero:IsTroll() or PlayerResource:GetSelectedHeroName(hero:GetPlayerOwnerID()) == "npc_dota_hero_wisp" then
        InitializeTroll(hero)
        elseif hero:IsAngel() then
        InitializeAngel(hero)
        elseif hero:IsWolf() then
        InitializeWolf(hero)
    end
end

function InitializeHero(hero)
    DebugPrint("Initialize hero")
    PlayerResource:SetGold(hero, 0)
    PlayerResource:SetLumber(hero, 0)
    if not GameRules.startTime then
        hero:AddNewModifier(nil, nil, "modifier_stunned", nil)
    end
    
    hero:ClearInventory()
    local team = hero:GetTeamNumber()
    if team ~= DOTA_TEAM_BADGUYS then
        -- Learn all abilities (this isn't necessary on creatures)
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability then ability:SetLevel(ability:GetMaxLevel()) end
        end
        hero:SetAbilityPoints(0)
        hero:SetStashEnabled(false)
    end
    hero:AddNewModifier(hero, nil, "modifier_antiblock", {})
end

function InitializeBadHero(hero)
    DebugPrint("Initialize bad hero")
    local playerID = hero:GetPlayerOwnerID()
    hero.hpReg = 0
    hero.hpRegDebuff = 0
    Timers:CreateTimer(function()
        if hero:IsNull() then return end
        local rate = FrameTime()
        local fullHpReg = math.max(hero.hpReg - hero.hpRegDebuff, 0)
        if fullHpReg > 0 and hero:IsAlive() then
            local optimalRate = 1 / fullHpReg
            rate = optimalRate > rate and optimalRate or rate
            local ratedHpReg = fullHpReg * rate
            hero:SetHealth(hero:GetHealth() + ratedHpReg)
        end
        return rate
    end)
    
    -- Give small flying vision around hero to see elf walls/rocks on highground
--    Timers:CreateTimer(function()
 --       if not hero or hero:IsNull() then return end
--        if hero:IsAlive() then
 --           AddFOWViewer(hero:GetTeamNumber(), hero:GetAbsOrigin(), 50, 0.1, false)
 --       end
 --       return 0.1
 --   end)
    if PlayerResource:GetSelectedHeroName(playerID) ~= "npc_dota_hero_wisp" then
    Timers:CreateTimer(BUFF_XP1_TIME, function() 
        hero:AddExperience(BUFF_XP1_SUM, DOTA_ModifyXP_Unspecified, false,false)
        local abil = hero:FindAbilityByName("reveal_area")
        abil:EndCooldown()
        hero:CalculateStatBonus(true)
    end)  
    Timers:CreateTimer(BUFF_XP2_TIME, function() 
        hero:AddExperience(BUFF_XP1_SUM, DOTA_ModifyXP_Unspecified, false,false)
        hero:CalculateStatBonus(true)
    end)  
    Timers:CreateTimer(BUFF_XP3_TIME, function() 
        hero:AddExperience(BUFF_XP1_SUM, DOTA_ModifyXP_Unspecified, false,false)
        hero:CalculateStatBonus(true)
    end) 
    local abil2 = hero:FindAbilityByName("reveal_area")
    abil2:StartCooldown(BUFF_XP1_TIME)
    abil2:SetLevel(abil2:GetMaxLevel())
    abil2 = hero:FindAbilityByName("treewrecker")
    abil2:StartCooldown(BUFF_XP1_TIME)
    abil2:SetLevel(abil2:GetMaxLevel())
    abil2 = hero:FindAbilityByName("attack_tree_skill")
    abil2:SetLevel(abil2:GetMaxLevel())
    abil2 = hero:FindAbilityByName("troll_teleport")
    abil2:SetLevel(abil2:GetMaxLevel())
    hero:AddExperience(50, DOTA_ModifyXP_Unspecified, false,false)
    else    
    local abil = hero:FindAbilityByName("pick_nevermore")
    abil:SetLevel(abil:GetMaxLevel())
    abil = hero:FindAbilityByName("pick_warlock")
    abil:SetLevel(abil:GetMaxLevel())
    abil = hero:FindAbilityByName("pick_stalker")
    abil:SetLevel(abil:GetMaxLevel())
    abil = hero:FindAbilityByName("pick_druid")
    abil:SetLevel(abil:GetMaxLevel())
    abil = hero:FindAbilityByName("pick_dazzle")
    abil:SetLevel(abil:GetMaxLevel())
    abil = hero:FindAbilityByName("pick_bristleback")
    abil:SetLevel(abil:GetMaxLevel())
    end
    --hero:SetStashEnabled(false)
end

function InitializeBuilder(hero)
    DebugPrint("Initialize builder")
    local playerID = hero:GetPlayerOwnerID()
    if PlayerResource:GetSelectedHeroName(hero:GetPlayerOwnerID()) == "npc_dota_hero_furion" then
        GameRules.maxFood[playerID] = 90
    else
        GameRules.maxFood[playerID] = 30
    end

    hero.food = 0
    hero.wisp = 0
    hero.alive = true
    hero.units = {}
    hero.disabledBuildings = {}
    hero.buildings = {} -- This keeps the name and quantity of each building
    for _, buildingName in ipairs(GameRules.buildingNames) do
        hero.buildings[buildingName] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
    end
    hero:SetRespawnsDisabled(true)
        
    hero.goldPerSecond = 0
    hero.lumberPerSecond = 0
    Timers:CreateTimer(function()
        if hero:IsNull() then return end
        PlayerResource:ModifyGold(hero, hero.goldPerSecond)
        PlayerResource:ModifyLumber(hero, hero.lumberPerSecond)
        return 1
    end)
    hero:AddNewModifier(hero, nil, "modifier_attack_trees", {})
    UpdateSpells(hero)
    PlayerResource:SetGold(hero, ELF_STARTING_GOLD)
    PlayerResource:SetLumber(hero, ELF_STARTING_LUMBER)
    PlayerResource:ModifyFood(hero, 0)
    PlayerResource:ModifyWisp(hero, 0)
    hero:SetStashEnabled(false)
    hero:AddItemByName("item_quelling_blade")
    hero:AddItemByName("item_blink_datadriven")
    if GameRules:GetGameTime() >= BUFF_ENIGMA_TIME then
        hero:AddAbility("troll_warlord_battle_trance_datadriven")
        local abil = hero:FindAbilityByName("troll_warlord_battle_trance_datadriven")
        abil:SetLevel(abil:GetMaxLevel())
    end

    if GameRules:GetGameTime() >= BUFF_VISION_TIME then
        hero:AddAbility("elf_debuff_all_vision")
        local abil = hero:FindAbilityByName("elf_debuff_all_vision")
        abil:SetLevel(abil:GetMaxLevel())
    end

    Timers:CreateTimer(BUFF_ENIGMA_TIME, function() 
        if hero:IsElf() then
            hero:AddAbility("troll_warlord_battle_trance_datadriven")
            local abil = hero:FindAbilityByName("troll_warlord_battle_trance_datadriven")
            abil:SetLevel(abil:GetMaxLevel())
            RESPAWN_TREE_TIME_MIN = RESPAWN_TREE_TIME_LAST_MIN
            RESPAWN_TREE_TIME_MAX = RESPAWN_TREE_TIME_LAST_MAX
        end
    end) 
    
    Timers:CreateTimer(BUFF_VISION_TIME, function() 
        if hero:IsElf() then
            hero:AddAbility("elf_debuff_all_vision")
            local abil = hero:FindAbilityByName("elf_debuff_all_vision")
            abil:SetLevel(abil:GetMaxLevel())
        end
    end)

    hero:CalculateStatBonus(true)
end

function InitializeTroll(hero)
    local playerID = hero:GetPlayerOwnerID()
    DebugPrint("Initialize troll, playerID: ", playerID)
    if GameRules.trollID == nil then
        GameRules.trollHero = hero
        GameRules.trollID = playerID
        hero.units = {}
        hero.disabledBuildings = {}
        hero.buildings = {} -- This keeps the name and quantity of each building
        hero.buildings["troll_hut_1"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_2"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_3"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_4"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_5"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_6"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        hero.buildings["troll_hut_7"] = {
            startedConstructionCount = 0,
            completedConstructionCount = 0
        }
        local units = Entities:FindAllByClassname("npc_dota_creature")
        for _, unit in pairs(units) do
            local unit_name = unit:GetUnitName();
            if string.match(unit_name, "shop") or
                string.match(unit_name, "troll_hut") then
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(playerID, true)
                unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
                unit:AddNewModifier(unit, nil, "modifier_phased", {})
                if string.match(unit_name, "troll_hut") then
                    unit.ancestors = {}
                    ModifyStartedConstructionBuildingCount(hero, unit_name, 1)
                    ModifyCompletedConstructionBuildingCount(hero, unit_name, 1)
                    BuildingHelper:AddModifierBuilding(unit)
                    BuildingHelper:BlockGridSquares(GetUnitKV(unit_name, "ConstructionSize"), 0, unit:GetAbsOrigin())
                    elseif string.match(unit_name, "npc_dota_units_base2") then
                    unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
                    unit:AddNewModifier(unit, nil, "modifier_phased", {})
                end
            end
        end
        
        else
        PlayerResource:SetUnitShareMaskForPlayer(GameRules.trollID, playerID, 2, true)
    end
    
    -- hero:AddAbility("special_bonus_cooldown_reduction_50"):SetLevel(1)
    if GameRules.MapSpeed == 1 then
        hero:RemoveAbility("special_bonus_cooldown_reduction_50")
        hero:RemoveAbility("special_bonus_cooldown_reduction_30")
        elseif GameRules.MapSpeed == 2 then
        hero:RemoveAbility("special_bonus_cooldown_reduction_30")
        hero:AddNewModifier(hero, nil, "modifier_movespeed_x2", {})
        elseif GameRules.MapSpeed >= 4 then
        hero:AddNewModifier(hero, nil, "modifier_movespeed_x4", {})
    end
    hero:AddNewModifier(hero, nil, "modifier_attack_trees", {})
   -- hero:AddItemByName("item_quelling_blade")
    hero:RemoveAbility("lone_druid_spirit_bear_datadriven")    
    if GameRules.test then
        hero:AddItemByName("item_dmg_12")
        hero:AddItemByName("item_armor_12")
        hero:AddItemByName("item_hp_12")
        hero:AddItemByName("item_hp_reg_12")
        hero:AddItemByName("item_atk_spd_6")
        hero:AddItemByName("item_disable_repair_2")
        hero:AddItemByName("item_disable_repair")
    end
    hero:SetStashEnabled(false)
    
    -- check count elf 
    Timers:CreateTimer(function()
        local countElf = 0
        if not hero or hero:IsNull() then return end
        if hero:IsAlive() then
            local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, hero:GetAbsOrigin() , nil, 900 , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL , DOTA_UNIT_TARGET_FLAG_NONE, 0 , false)
            for _,unit in pairs(units) do
                if unit ~= nil then
                    if unit:IsElf() then
                        countElf = countElf + 1
                    end
                end
            end
            if countElf > 2 then			
                if hero:HasModifier("modifier_antiblock") then
                    hero:RemoveModifierByName("modifier_antiblock")
                end
                else
                if not hero:HasModifier("modifier_antiblock") then
                    hero:AddNewModifier(hero, nil, "modifier_antiblock", {})
                end
            end
        end
        return 0.1
    end)    
    hero:CalculateStatBonus(true)
end

function InitializeAngel(hero)
    DebugPrint("Initialize angel")
    --if not string.match(GetMapName(),"halloween") then 
    --    hero:RemoveAbility("silence_datadriven")
    --end
    hero:CalculateStatBonus(true)
end

function InitializeWolf(hero)
    local playerID = hero:GetPlayerOwnerID()
    DebugPrint("Initialize wolf, playerID: " .. playerID)
    DebugPrint("GameRules.trollID: " .. GameRules.trollID)
    local trollNetworth = GameRules.trollHero:GetNetworth()
    local lumber = trollNetworth / 64000 * WOLF_STARTING_RESOURCES_FRACTION
    local gold = math.floor((lumber - math.floor(lumber)) * 64000)
    lumber = math.floor(lumber)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, lumber)
    PlayerResource:SetUnitShareMaskForPlayer(GameRules.trollID, playerID, 2, true)
    local abil = hero:FindAbilityByName("troll_warlord_battle_trance_datadriven")
    if abil ~= nil then
        abil:RemoveAbility("troll_warlord_battle_trance_datadriven")
    end
    if GameRules.trollHero.bear ~= nil then
        hero:SetControllableByPlayer(playerID, false)
    end
    hero:CalculateStatBonus(true)
end

function trollnelves2:PreStart()
    StartCreatingMinimapBuildings()
    local gameStartTimer = PRE_GAME_TIME
    ModifyLumberPrice(0)
    Timers:CreateTimer(function()
        if gameStartTimer > 0 then
            Notifications:ClearBottomFromAll()
            Notifications:BottomToAll({
                text = "Game starts in " .. gameStartTimer,
                style = {color = '#E62020'},
                duration = 1
            })
            gameStartTimer = gameStartTimer - 1
            local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
            for i = 1, trollCount do
            local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
                if PlayerResource:IsValidPlayerID(pID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(pID)
                    if hero ~= nil then
                        PlayerResource:SetGold(hero , 0)
                    end
                end
            end
            
            return 1
            else
            
            if GameRules.trollHero or GameRules.test then
                Notifications:ClearBottomFromAll()
                Notifications:BottomToAll(
                    {
                        text = "Game started!",
                        style = {color = '#E62020'},
                        duration = 1
                    })
                    GameRules.startTime = GameRules:GetGameTime()
                    
                    -- Unstun the elves
                    local elfCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
                    for i = 1, elfCount do
                        local pID = PlayerResource:GetNthPlayerIDOnTeam(
                        DOTA_TEAM_GOODGUYS, i)
                        local playerHero = PlayerResource:GetSelectedHeroEntity(pID)
                        if playerHero then
                            playerHero:RemoveModifierByName("modifier_stunned")
                        end
                    end
                    StartRunesSpawn()
                    Timers:CreateTimer(END_GAME_TIME, function() 
                        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
                    end)   
                    local trollSpawnTimer = TROLL_SPAWN_TIME
                    for i=1, #trollPlayerID do
                        DebugPrint("#trollPlayerID " .. #trollPlayerID)
                        local trollHero = PlayerResource:GetSelectedHeroEntity(trollPlayerID[i])
                        trollHero:AddNewModifier(nil, nil, "modifier_stunned", {duration = trollSpawnTimer})
                        if GameRules.TrollCount  == 1 then
                            PlayerResource:SetGold(trollHero, TROLL_STARTING_GOLD_X1)
                        elseif GameRules.TrollCount  == 2 then 
                            PlayerResource:SetGold(trollHero, TROLL_STARTING_GOLD_X2)
                        else
                            PlayerResource:SetGold(trollHero, TROLL_STARTING_GOLD)
                        end
                        PlayerResource:SetLumber(trollHero, TROLL_STARTING_LUMBER)
                        
                        if GameRules.test and trollHero:IsElf() then
                            PlayerResource:SetGold(trollHero, ELF_STARTING_GOLD)
                            PlayerResource:SetLumber(trollHero, ELF_STARTING_LUMBER)
                        end
                    end
                    
                    Timers:CreateTimer(function()
                        if trollSpawnTimer > 0 then
                            Notifications:ClearBottomFromAll()
                            Notifications:BottomToAll(
                                {
                                    text = "Infernals spawns in " .. trollSpawnTimer,
                                    style = {color = '#E62020'},
                                    duration = 1
                                })
                                trollSpawnTimer = trollSpawnTimer - 1
                                return 1.0
                        end
                    end)
                    else
                    Notifications:ClearBottomFromAll()
                    Notifications:BottomToAll(
                        {
                            text = "Infernals hasn't spawned yet!Resetting!",
                            style = {color = '#E62020'},
                            duration = 1
                        })
                        gameStartTimer = 3
                        return 1.0
            end
        end
    end)
    
    if IsServer() then
        for pID = 0, DOTA_MAX_TEAM_PLAYERS do
            if PlayerResource:IsValidPlayerID(pID) then
               -- local hero = PlayerResource:GetSelectedHeroEntity(pID)
                local steam = tostring(PlayerResource:GetSteamID(pID))
                Stats.RequestVip(pID, steam, callback)
                Stats.RequestBonus(pID, steam, callback)
                Stats.RequestData(pID)
                Stats.RequestVipDefaults(pID, steam, callback)
                Stats.RequestPetsDefaults(pID, steam, callback)
                Stats.RequestPets(pID, steam, callback)
                Timers:CreateTimer(120, function() wearables:SetPart() end)     
                Timers:CreateTimer(120, function() SelectPets:SetPets() end)    
            end
        end
        Stats.RequestDataTop10("1", callback)
        Stats.RequestDataTop10("2", callback)
        Stats.RequestDataTop10("3", callback)
        Stats.RequestDataTop10("4", callback)
    Donate:CreateList()
    end
    
    end
    
    function StartCreatingMinimapBuildings()
    Timers:CreateTimer(0.3, function()
    if GameRules:State_Get() > DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    return
    end
    -- Create minimap entities for buildings that are visible and don't already have a minimap entity
    local allEntities = Entities:FindAllByClassname("npc_dota_creature")
    for _, unit in pairs(allEntities) do
    if not unit:IsNull() and IsCustomBuilding(unit) and
    not unit.minimapEntity and unit:GetTeamNumber() ~=
    DOTA_TEAM_BADGUYS and
    IsLocationVisible(DOTA_TEAM_BADGUYS, unit:GetAbsOrigin()) then
    unit.minimapEntity = CreateUnitByName("minimap_entity",
    unit:GetAbsOrigin(),
    false, unit:GetOwner(),
    unit:GetOwner(),
    unit:GetTeamNumber())
    unit.minimapEntity:AddNewModifier(unit.minimapEntity, nil,
    "modifier_minimap", {})
    unit.minimapEntity.correspondingEntity = unit
    end
    end
    -- Kill minimap entities of dead buildings when location is scouted
    local minimapEntities = Entities:FindAllByClassname("npc_dota_building")
    for k, minimapEntity in pairs(minimapEntities) do
    if not minimapEntity:IsNull() and minimapEntity.correspondingEntity ==
    "dead" and
    IsLocationVisible(DOTA_TEAM_BADGUYS,
    minimapEntity:GetAbsOrigin()) then
    minimapEntity.correspondingEntity = nil
    minimapEntity:ForceKill(false)
    UTIL_Remove(minimapEntity)
    end
    end
    return 0.3
    end)
    end
    
    -- This function initializes the game mode and is called before anyone loads into the game
    -- It can be used to pre-initialize any values/tables that will be needed later
    function trollnelves2:Inittrollnelves2()
    trollnelves2 = self
    DebugPrint('[TROLLNELVES2] Starting to load trollnelves2 trollnelves2...')
    trollnelves2:_Inittrollnelves2()
    DebugPrint('[TROLLNELVES2] Done loading trollnelves2 trollnelves2!\n\n')
    end
    
    function ModifyLumberPrice(amount)
    amount = string.match(amount, "[-]?%d+") or 0
    GameRules.lumberPrice = math.max(GameRules.lumberPrice + amount,
    MINIMUM_LUMBER_PRICE)
    CustomGameEventManager:Send_ServerToTeam(DOTA_TEAM_GOODGUYS,
    "player_lumber_price_changed", {
    lumberPrice = GameRules.lumberPrice
    })
    end
    
    function SetResourceValues()
        if GameRules.startTime == nil then
            GameRules.startTime = 1
        end
    for pID = 0, DOTA_MAX_PLAYERS do
    if PlayerResource:IsValidPlayer(pID) then
    CustomNetTables:SetTableValue("resources",
    tostring(pID) .. "_resource_stats", {
    gold = PlayerResource:GetGold(pID),
    lumber = PlayerResource:GetLumber(pID),
    goldGained = PlayerResource:GetGoldGained(pID),
    lumberGained = PlayerResource:GetLumberGained(pID),
    goldGiven = PlayerResource:GetGoldGiven(pID),
    lumberGiven = PlayerResource:GetLumberGiven(pID),
    timePassed = GameRules:GetGameTime() - GameRules.startTime,
    PlayerChangeScore = GameRules.Score[pID]
    })
    end
    end
    end
    
    function GetModifiedName(orgName)
        for i = 1, #TROLL_HERO do
            if string.match(orgName, TROLL_HERO[i]) then
                return "<font color='#FF0000'>The Mighty Infernal</font>"
            end
        end
        for i = 1, #ELF_HERO do
            if string.match(orgName, ELF_HERO[i]) then
                return "<font color='#00CC00'>Elf</font>"
            end
        end
    if string.match(orgName, WOLF_HERO) then
    return "<font color='#800000'>Wolf</font>"
    elseif string.match(orgName, ANGEL_HERO) then
    return "<font color='#0099FF'>Angel</font>"
    else
    return "?"
    end
end
    
    function SellItem(args)
    local item = EntIndexToHScript(args.itemIndex)
    if item then
    if not item:IsSellable() then
    SendErrorMessage(issuerID, "#error_item_not_sellable")
    end
    local gold_cost = item:GetSpecialValueFor("gold_cost")
    local lumber_cost = item:GetSpecialValueFor("lumber_cost")
    local hero = item:GetCaster()
    UTIL_Remove(item)
    PlayerResource:ModifyGold(hero, gold_cost, true)
    PlayerResource:ModifyLumber(hero, lumber_cost, true)
    local player = hero:GetPlayerOwner()
    EmitSoundOnClient("DOTA_Item.Hand_Of_Midas", player)
    end
    
    end
    
    function UpdateSpells(unit)
    local playerID = unit:GetPlayerOwnerID()
    local hero = unit
    for a = 0, unit:GetAbilityCount() - 1 do
    local tempAbility = unit:GetAbilityByIndex(a)
    if tempAbility then
    local abilityKV = GetAbilityKV(tempAbility:GetAbilityName());
    local bIsBuilding = abilityKV and abilityKV.Building or 0
    if bIsBuilding == 1 then
    local buildingName = abilityKV.UnitName
    DisableAbilityIfMissingRequirements(playerID, hero, tempAbility,
    buildingName)
    end
    end
    end
    end
    
    function UpdateUpgrades(building)
    if not building or building:IsNull() then return end
    
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    for a = 0, building:GetAbilityCount() - 1 do
    local ability = building:GetAbilityByIndex(a)
    if ability and ability.upgradedUnitName then
    DisableAbilityIfMissingRequirements(playerID, hero, ability,
    ability.upgradedUnitName)
    end
    end
    end
    
    function AddUpgradeAbilities(building)
    if not building or building:IsNull() then return end
    
    local upgrades = GetUnitKV(building:GetUnitName()).Upgrades
    if upgrades and upgrades.Count then
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local abilities = {}
    for a = 0, building:GetAbilityCount() - 1 do
    local tempAbility = building:GetAbilityByIndex(a)
    if tempAbility then
    table.insert(abilities, {tempAbility:GetAbilityName(), tempAbility:GetLevel()})
    building:RemoveAbility(tempAbility:GetAbilityName())
    end
    end
    
    local count = tonumber(upgrades.Count)
    for i = 1, count, 1 do
    local upgrade = upgrades[tostring(i)]
    local upgradedUnitName = upgrade.unit_name
    
    local abilityName = "upgrade_to_" .. upgradedUnitName
    local upgradeAbility = building:AddAbility(abilityName)
    upgradeAbility.upgradedUnitName = upgradedUnitName
    
    DisableAbilityIfMissingRequirements(playerID, hero, upgradeAbility, upgradedUnitName)
    end
    for _, ability in ipairs(abilities) do
    local abilityName, abilityLevel = unpack(ability)
    if not string.match(abilityName, "upgrade_to") then
    local abilityHandle = building:AddAbility(abilityName)
    abilityHandle:SetLevel(abilityLevel)
    end
    end
    end
    end
    
    function DisableAbilityIfMissingRequirements(playerID, hero, abilityHandle, unitName)
    local missingRequirements = {}
    local disableAbility = false
    local requirements = GameRules.buildingRequirements[unitName]
    if requirements then
    for _, requiredUnitName in ipairs(requirements) do
    local requiredBuildingCurrentCount = hero.buildings[requiredUnitName].completedConstructionCount
    if requiredBuildingCurrentCount < 1 then
    table.insert(missingRequirements, requiredUnitName)
    disableAbility = true
    end
    end
    end
    CustomNetTables:SetTableValue("buildings", playerID .. unitName,
    missingRequirements)
    
    local limit = GetUnitKV(unitName, "Limit")
    if limit ~= nil then
    DebugPrint(unitName)
    local currentCount = hero.buildings[unitName].startedConstructionCount
    if currentCount >= limit then disableAbility = true end
    end
    
    if disableAbility and not GameRules.test2 then
    abilityHandle:SetLevel(0)
    hero.disabledBuildings[unitName] = true
    else
    abilityHandle:SetLevel(1)
    hero.disabledBuildings[unitName] = false
    end
    end
    
    function GetClass(unitName)
    if string.match(unitName, "rock") or string.match(unitName, "wall") then
    return "wall"
    elseif string.match(unitName, "tower") then
    return "tower"
    elseif string.match(unitName, "tent") or string.match(unitName, "barrack") then
    return "tent"
    elseif string.match(unitName, "trader") then
    return "trader"
    elseif string.match(unitName, "workers_guild") then
    return "workers_guild"
    elseif string.match(unitName, "mother_of_nature") then
    return "mother_of_nature"
    elseif string.match(unitName, "research_lab") then
    return "research_lab"
    end
    end
        