local lastSendTime = {}
local GoldHero = {}
local LumberHero = {}
local selectHero = {}
require('stats')
require('libraries/entity')
require('drop')
require('settings')

function trollnelves2:OnGameRulesStateChange()
    DebugPrint("GameRulesStateChange ******************")
    local newState = GameRules:State_Get()
    DebugPrint(newState)
    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        trollnelves2:GameSetup()
        trollnelves2:PostLoadPrecache()
        elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
        self:PreStart()
    end
end

-- A player leveled up
function trollnelves2:OnPlayerLevelUp(keys)
    DebugPrint('[BAREBONES] OnPlayerLevelUp')
    DebugPrintTable(keys)
    
    --PrintTable(keys)
    
    local player = PlayerResource:GetPlayer(keys.player_id) --EntIndexToHScript(keys.player)
    local level = keys.level
    local hero = player:GetAssignedHero()  
    
    --времменый фикс вольво пока они сука не вернут всё как было
    if level > 20 and level < 126 then
        hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
    end
    --
end

-- An NPC has spawned somewhere in game.  This includes heroes
function trollnelves2:OnNPCSpawned(keys)
    DebugPrint("OnNPCSpawned:")
    local npc = EntIndexToHScript(keys.entindex)
    if npc.GetPhysicalArmorValue then
        npc:AddNewModifier(npc, nil, "modifier_custom_armor", {})
    end
    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        THINK_INTERVAL = 2
        npc.bFirstSpawned = true
        if IsServer() then
            trollnelves2:OnHeroInGame(npc)
        end
    end
   if npc:IsAngel() and PlayerResource:GetConnectionState(npc:GetPlayerOwnerID()) ~= 2 then
        npc:AddNewModifier(nil, nil, "modifier_disconnected", {})
    end
    if npc:IsWolf() and PlayerResource:GetConnectionState(npc:GetPlayerOwnerID()) ~= 2 then
        npc:AddNewModifier(nil, nil, "modifier_disconnected", {})
    end
    if npc:IsRealHero() then
        local info = {}
        info.PlayerID = npc:GetPlayerID()
        info.hero = npc
        -- local rand = RandomInt(1, 2)
        -- if rand == 1 then
        Pets.CreatePet( info )
		-- end
        --npc:SetCustomHealthLabel("#top1autumn",  123, 11, 78)
    end
    if EVENT_START then
        --Halloween(npc)  
    end
end

function trollnelves2:OnPlayerReconnect(event)
    local playerID = event.PlayerID
    if GameRules.KickList[playerID] == 1 then 
        SendToServerConsole("kick " .. PlayerResource:GetPlayerName(playerID))
    end
    local notSelectedHero = GameRules.disconnectedHeroSelects[playerID]
    if notSelectedHero then
        DebugPrint("notSelectedHero " .. notSelectedHero)
        local player = PlayerResource:GetPlayer(playerID)
        player:SetSelectedHero(notSelectedHero)
        player:RespawnHero(false,false)
        local hero = player:GetAssignedHero()
        trollnelves2:OnHeroInGame(hero)       
    end
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero:IsAngel() then hero:RemoveModifierByName("modifier_disconnected") end
    if hero:IsWolf() then hero:RemoveModifierByName("modifier_disconnected") end
    if hero then
        -- Send info to client]
        UpdateSpells(hero)
        hero:SetAbilityPoints(0)
        PlayerResource:ModifyGold(hero, 0)
        PlayerResource:ModifyLumber(hero, 0)
        PlayerResource:ModifyFood(hero, 0)
        PlayerResource:ModifyWisp(hero, 0)
        ModifyLumberPrice(0)
        hero:RemoveModifierByName("modifier_disconnected")
        if hero:IsElf() and hero.alive == false then
            if hero.dced == true then
                hero.alive = true
                hero.dced = false
                else
                local player = PlayerResource:GetPlayer(playerID)
                if player then
                    CustomGameEventManager:Send_ServerToPlayer(player,
                        "show_helper_options",
                    {})
                end
            end
        end
    end
    if GameRules.KickList[playerID] == 1 then 
        SendToServerConsole("kick " .. PlayerResource:GetPlayerName(playerID))
    end
end

function trollnelves2:OnDisconnect(event)
    local playerID = event.PlayerID
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    
    local trollLoseTimer = 300
    local elfLoseTimer = 180
    if hero ~= nil then
        local team = hero:GetTeamNumber()
        if team == DOTA_TEAM_GOODGUYS then
            hero:AddNewModifier(nil, nil, "modifier_disconnected", {})
            if hero.alive == true then
                hero.alive = false
                hero.dced = true
                local lastAlive = true
                for i = 0, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) do
                    local pID = PlayerResource:GetNthPlayerIDOnTeam(2, i)
                    local hero2 = PlayerResource:GetSelectedHeroEntity(pID) or false
                    if hero2 and hero2.alive then
                        lastAlive = false
                        break
                    end
                end
                elseif team == DOTA_TEAM_BADGUYS then
                hero:MoveToPosition(Vector(0, 0, 0))
            end
        end
    end
end

function trollnelves2:OnConnectFull(keys)
    DebugPrint("OnConnectFull ******************")
    local entIndex = keys.index + 1
    -- The Player entity of the joining user
    local player = EntIndexToHScript(entIndex)
    local userID = keys.userid
    GameRules.userIds = GameRules.userIds or {}
    -- The Player ID of the joining player
   -- local playerID = player:GetPlayerID()
    GameRules.userIds[userID] = playerID
    trollnelves2:_Capturetrollnelves2()
    
end

function trollnelves2:OnItemPickedUp(keys)
    print('[BAREBONES] OnItemPickedUp')
    DeepPrintTable(keys)
    local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local itemname = keys.itemname
    
    if (hero:IsAngel() or hero:IsElf()) and (string.match(itemname,"hp") or string.match(itemname,"armor") or string.match(itemname,"dmg") or string.match(itemname,"spd") or string.match(itemname,"boots")  or string.match(itemname,"repair")) then 
        hero:RemoveItem(itemEntity)
        return
    end  
    
    if hero:GetNumItemsInInventory() > 6 then
        local spawnPoint = hero:GetAbsOrigin() + RandomFloat(50, 100)
        local newItem = CreateItem(itemname, nil, nil)
        local drop = CreateItemOnPositionForLaunch(spawnPoint, newItem)
        newItem:LaunchLootInitialHeight(false, 0, 150, 0.5, spawnPoint)
        hero:RemoveItem(itemEntity)
    end
end

--[[
	This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
	It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function trollnelves2:OnAllPlayersLoaded()
    DebugPrint("[TROLLNELVES2] All Players have loaded into the game")
    
end

function printTryError(...)
	local stack = debug.traceback(...)
	print(stack) 
    GameRules:SendCustomMessage(stack, 1, 1)
	return stack
end

function ErrorCheck(callback, ...)
    print("BuildError")
	return xpcall(callback, printTryError, ...)
end

function trollnelves2:OnEntityKilled(keys)
    local killed = EntIndexToHScript(keys.entindex_killed)
    local attacker = EntIndexToHScript(keys.entindex_attacker)
    local killedPlayerID = killed:GetPlayerOwnerID()
    local attackerPlayerID = attacker:GetPlayerOwnerID()
    local attacker_hero = PlayerResource:GetSelectedHeroEntity(attackerPlayerID)
    if GameRules.Bonus[attackerPlayerID] == nil then
        GameRules.Bonus[attackerPlayerID] = 0
    end
    
    local info = {}
    info.PlayerID = killedPlayerID
    info.hero = killed
    
    if IsBuilder(killed) then BuildingHelper:ClearQueue(killed) end
    if killed:IsRealHero() then
        local bounty = -1
        if killed:IsElf() then
            GameRules.PlayersBase[killedPlayerID] = nil
            bounty = ElfKilled(killed)
            GameRules.Bonus[attackerPlayerID] =
            GameRules.Bonus[attackerPlayerID] + 1
            if CheckTrollVictory() then
                GameRules:SendCustomMessage("Please do not leave the game.", 1, 1)
                local status, nextCall = ErrorCheck(function() 
                    Stats.SubmitMatchData(DOTA_TEAM_BADGUYS, callback)
                end)
                GameRules:SendCustomMessage("The game can be left, thanks!", 1, 1)
                return
            end
            drop:RollItemDrop(killed)
            Pets.DeletePet(info)
            PlayerResource:ModifyLumber( PlayerResource:GetSelectedHeroEntity(attackerPlayerID), 1)
            elseif killed:IsTroll() then
            if CheckElfVictory() then
                GameRules:SendCustomMessage("Please do not leave the game.", 1, 1)
                local status, nextCall = ErrorCheck(function() 
                    Stats.SubmitMatchData(DOTA_TEAM_GOODGUYS, callback)
                end)
                GameRules:SendCustomMessage("The game can be left, thanks!", 1, 1)
                return
            end
            
            if attacker_hero ~= nil then
                local roll_chance = RandomFloat(0, 500)
                if roll_chance <= 100 and not attacker_hero:HasItemInInventory("item_glyph_ability") then
                    attacker_hero:AddItemByName("item_glyph_ability")
                end
                local roll_chance = RandomFloat(0, 500)
                if roll_chance <= 200 then
                    attacker_hero:ClearInventoryBlink()
                    attacker_hero:AddItemByName("item_blink_mega_datadriven")
                end
            end
            
            bounty = 512000
            killed:SetRespawnPosition(Vector(0, -640, 256))
            killed:SetTimeUntilRespawn(TROLL_RESPAWN_TIME)
            killed:RemoveDesol2()
            GameRules.Bonus[attackerPlayerID] = GameRules.Bonus[attackerPlayerID] + 1
            drop:RollItemDrop(killed)
            Pets.DeletePet(info)
            elseif killed:IsWolf() then
            bounty = math.max(killed:GetNetworth() * 0.70,
            GameRules:GetGameTime())
            killed:SetRespawnPosition(Vector(0, -640, 256))
            killed:SetTimeUntilRespawn(WOLF_RESPAWN_TIME * PlayerResource:GetDeaths(killedPlayerID))
            killed:RemoveDesol2()
            if PlayerResource:GetDeaths(killedPlayerID) == 2 then
                GameRules.Bonus[attackerPlayerID] =
                GameRules.Bonus[attackerPlayerID] + 1
            end
            drop:RollItemDrop(killed)
            Pets.DeletePet(info)
            elseif killed:IsAngel() then            
            ReturnElf(killedPlayerID, attackerPlayerID)
            Pets.DeletePet(info)
            
        end
        if bounty >= 0 and attacker ~= killed then
            local killedName = PlayerResource:GetSelectedHeroEntity(
            killedPlayerID) and
            PlayerResource:GetSelectedHeroEntity(
            killedPlayerID):GetUnitName() or
            killed:GetUnitName()
            local attackerName = PlayerResource:GetSelectedHeroEntity(
            attackerPlayerID) and
            PlayerResource:GetSelectedHeroEntity(
            attackerPlayerID):GetUnitName() or
            attacker:GetUnitName()
            bounty = math.floor(bounty)
            PlayerResource:ModifyGold(attacker, bounty)
            local message = "%s1 (" .. GetModifiedName(attackerName) ..
            ") killed " ..
            PlayerResource:GetPlayerName(killedPlayerID) ..
            " (" .. GetModifiedName(killedName) ..
            ") for <font color='#F0BA36'>" .. bounty ..
            "</font> gold!"
            GameRules:SendCustomMessage(message, attackerPlayerID, 0)
        end
        else
        local hero = PlayerResource:GetSelectedHeroEntity(killedPlayerID)
        
        if hero and hero.units and hero.alive then -- hero.units can contain other units besides buildings
            for i = #hero.units, 1, -1 do
                if not hero.units[i]:IsNull() then
                    if hero.units[i]:GetEntityIndex() == keys.entindex_killed then
                        table.remove(hero.units, i)
                        break
                    end
                end
            end
        end
        
        local unitTable = killed:GetKeyValue()
        local gridTable = unitTable and unitTable["Grid"]
        if IsCustomBuilding(killed) or gridTable then
            -- Building Helper grid cleanup
            BuildingHelper:RemoveBuilding(killed, false)
            
            if gridTable then
                for grid_type, v in pairs(gridTable) do
                    if tobool(v.RemoveOnDeath) then
                        local location = killed:GetAbsOrigin()
                        BuildingHelper:print(
                        "Clearing special grid of " .. grid_type)
                        if (v.Radius) then
                            BuildingHelper:RemoveGridType(v.Radius, location,
                            grid_type, "radius")
                            elseif (v.Square) then
                            BuildingHelper:RemoveGridType(v.Square, location,
                            grid_type)
                        end
                    end
                end
            end
            
            if hero then -- Skip looping unnecessarily when elf dies
                local name = killed:GetUnitName()
                -- DebugPrint("name " .. name)
                ModifyStartedConstructionBuildingCount(hero, name, -1)
                if killed.state == "complete" then
                    ModifyCompletedConstructionBuildingCount(hero, name, -1)
                end
                if killed.ancestors then
                    for _, ancestorUnitName in pairs(killed.ancestors) do
                        if name ~= ancestorUnitName then
                            -- DebugPrint("ancestorUnitName " .. ancestorUnitName)
                            ModifyStartedConstructionBuildingCount(hero,
                                ancestorUnitName,
                            -1)
                            ModifyCompletedConstructionBuildingCount(hero,
                                ancestorUnitName,
                            -1)
                        end
                    end
                end
                for _, v in ipairs(hero.units) do
                    UpdateUpgrades(v)
                end
                UpdateSpells(hero)
            end
            elseif killed:GetKeyValue("FoodCost") then
            local foodCost = killed:GetKeyValue("FoodCost")
            PlayerResource:ModifyFood(hero, -foodCost)
            elseif killed:GetKeyValue("WispCost") then
            local wisp = killed:GetKeyValue("WispCost")
            PlayerResource:ModifyWisp(hero, -wisp)
        end
        
        if killed:GetUnitName() == "tent_5" or killed:GetUnitName() == "tent_6" then
            GameRules.maxFood[killedPlayerID] = GameRules.maxFood[killedPlayerID] - 18
            PlayerResource:ModifyFood(hero, 0)
        end
        
    end
end

function ElfKilled(killed)
    local killedID = killed:GetPlayerOwnerID()
    killed.alive = false
    killed.legitChooser = true
    
    for i = 1, #killed.units do
        if killed.units[i] and not killed.units[i]:IsNull() then
            local unit = killed.units[i]
            unit:ForceKill(false)
        end
    end
    
    PlayerResource:SetCameraTarget(killedID, killed)
    Timers:CreateTimer(3, function()
        PlayerResource:SetCameraTarget(killedID, nil)
    end)
    
    local args = {}
    args.team = DOTA_TEAM_GOODGUYS
    args.playerID = killedID
    ChooseHelpSide(killedID, args)
    local bounty = math.min(math.floor((PlayerResource:GetGold(killedID)/1000) + 512), 5000) 
    if (GameRules:GetGameTime() - GameRules.startTime >= 180) or PlayerResource:GetConnectionState(killedID) ~= 2  then
        bounty = 50
    end
    return bounty
end

function CheckTrollVictory()
    for i = 1, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) do
        local playerID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS,i)
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero and hero:IsAlive() and hero:IsElf() then 
            return false 
        end
    end
    return true
end

function CheckElfVictory()
    for i = 1, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) do
        local playerID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS,i)
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        DebugPrint("hero:GetRespawnTime() " .. hero:GetRespawnTime())
        if hero and hero:IsAlive() and hero:IsTroll() then 
            return false 
        end
    end
    return true
end

function GiveResources(eventSourceIndex, event)
    DebugPrint("Give resources, event source index: ", eventSourceIndex)
    local targetID = event.target
    local casterID = event.casterID
    local gold = math.floor(math.abs(tonumber(event.gold)))
    local lumber = math.floor(math.abs(tonumber(event.lumber)))
    if tonumber(event.gold) ~= nil and tonumber(event.lumber) ~= nil then
        if PlayerResource:GetSelectedHeroEntity(targetID) and
            PlayerResource:GetSelectedHeroEntity(targetID):GetTeam() ==
            PlayerResource:GetSelectedHeroEntity(event.casterID):GetTeam() then
            local hero = PlayerResource:GetSelectedHeroEntity(targetID)
            local casterHero = PlayerResource:GetSelectedHeroEntity(casterID)
            if gold and lumber then
                if PlayerResource:GetGold(casterID) < gold or
                    PlayerResource:GetLumber(casterID) < lumber then
                    SendErrorMessage(casterID, "#error_not_enough_resources")
                    return
                end
                if (lastSendTime[event.target] == nil or
                lastSendTime[event.target] + 120 < GameRules:GetGameTime()) or casterHero:IsAngel() or casterHero:IsTroll() then
                PlayerResource:ModifyGold(casterHero, -gold, true)
                PlayerResource:ModifyLumber(casterHero, -lumber, true)
                PlayerResource:ModifyGold(hero, gold, true)
                PlayerResource:ModifyLumber(hero, lumber, true)
                PlayerResource:ModifyGoldGiven(targetID, -gold)
                PlayerResource:ModifyLumberGiven(targetID, -lumber)
                PlayerResource:ModifyGoldGiven(casterID, gold)
                PlayerResource:ModifyLumberGiven(casterID, lumber)
                if gold > 0 or lumber > 0 then
                    local text = PlayerResource:GetPlayerName(
                    casterHero:GetPlayerOwnerID()) .. "(" ..
                    GetModifiedName(
                    casterHero:GetUnitName()) ..
                    ") has sent "
                    if gold > 0 then
                        text = text .. "<font color='#F0BA36'>" .. gold ..
                        "</font> gold"
                    end
                    if gold > 0 and lumber > 0 then
                        text = text .. " and "
                    end
                    if lumber > 0 then
                        text = text .. "<font color='#009900'>" .. lumber ..
                        "</font> lumber"
                    end
                    text = text .. " to " ..
                    PlayerResource:GetPlayerName(
                    hero:GetPlayerOwnerID()) .. "(" ..
                    GetModifiedName(hero:GetUnitName()) .. ")!"
                    GameRules:SendCustomMessageToTeam(text,
                        casterHero:GetTeamNumber(),
                    0, 0)
                    if casterHero:IsAngel() == false then
                        lastSendTime[event.target] = GameRules:GetGameTime()
                    end
                end
                else
                local timeLeft = math.ceil(
                    lastSendTime[event.target] + 120 -
                GameRules:GetGameTime())
                SendErrorMessage(event.casterID, "You can send money in " ..
                timeLeft .. " seconds!")
                end
                else
                SendErrorMessage(event.casterID, "#error_enter_only_digits")
            end
            else
            SendErrorMessage(event.casterID, "#error_select_only_your_allies")
        end
        else
        SendErrorMessage(event.casterID, "#error_type_only_digits")
    end
end

function ChooseHelpSide(eventSourceIndex, event)
    DebugPrint("Choose help side: " .. eventSourceIndex);
    local team = event.team
    local playerID = event.playerID
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    hero.legitChooser = false
    selectHero[playerID] = PlayerResource:GetSelectedHeroName(playerID)

    GoldHero[playerID] = math.floor(PlayerResource:GetLumber(playerID)/2+200)
    LumberHero[playerID] = math.floor(PlayerResource:GetGold(playerID)/2+200)
    PlayerResource:SetGold(hero, 0)
    PlayerResource:SetLumber(hero, 0)

    local message = "%s1 became a Dead Treant. Lost " .. GoldHero[playerID] .. " gold and " .. LumberHero[playerID] .. " lumber. "

    local timer = ANGEL_RESPAWN_TIME * PlayerResource:GetDeaths(playerID)
    local pos = RandomAngelLocation()
    PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
    Timers:CreateTimer(function()
        GameRules:SendCustomMessage(message, playerID, 0)
    end)
    
    hero:SetTimeUntilRespawn(timer)
    Timers:CreateTimer(timer, function()
        PlayerResource:ReplaceHeroWith(playerID, ANGEL_HERO, 0, 0)
        UTIL_Remove(hero)
        hero = PlayerResource:GetSelectedHeroEntity(playerID)
        PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS) -- A workaround for wolves sometimes getting stuck on elves team, I don't know why or how it happens.
        FindClearSpaceForUnit(hero, pos, true)
        PlayerResource:SetGold(hero, 0)
        PlayerResource:SetLumber(hero, 0)
    end)
    
end

function ReturnElf(killed, attacker)
    local playerID = killed
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local hero_attacker = PlayerResource:GetSelectedHeroEntity(attacker)
    hero.legitChooser = false
    
    
    local pos = RandomAngelLocation()
    PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)

    hero:SetTimeUntilRespawn(1)
    PlayerResource:ReplaceHeroWith(playerID, selectHero[playerID], 0, 0)
    UTIL_Remove(hero)
    hero = PlayerResource:GetSelectedHeroEntity(playerID)
    PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS) -- A workaround for wolves sometimes getting stuck on elves team, I don't know why or how it happens.
    FindClearSpaceForUnit(hero, pos, true)
    InitializeHero(hero)
    InitializeBuilder(hero)
    PlayerResource:SetCameraTarget(playerID, nil)
    hero:AddNewModifier(hero, nil, "modifier_fountain_glyph", {duration = FOUNTAIN_GLYPH_TIME} )
    PlayerResource:SetGold(hero, GoldHero[playerID])
    PlayerResource:SetLumber(hero, LumberHero[playerID])
    
    PlayerResource:ModifyGold(hero_attacker, math.floor(GoldHero[playerID]/2))
	PlayerResource:ModifyLumber(hero_attacker, math.floor(LumberHero[playerID]/2))

    local message = "%s1 frees himself and gives his savior ".. math.floor(GoldHero[playerID]/2) .. " gold and ".. math.floor(LumberHero[playerID]/2) .. " lumber."
    GameRules:SendCustomMessage(message, playerID, 0)
end

function RandomAngelLocation()
    return (GameRules.angel_spawn_points and #GameRules.angel_spawn_points and
    #GameRules.angel_spawn_points > 0) and
    GameRules.angel_spawn_points[RandomInt(1,
    #GameRules.angel_spawn_points)]:GetAbsOrigin() or
    Vector(0, 0, 0)
    end
    
    function Halloween(npc)
    if string.match(GetMapName(),"halloween") then
    wearables:RemoveWearables(npc)
    if npc:IsAngel() then
    UpdateModel(npc, "models/heroes/death_prophet/death_prophet.vmdl", 1)  
    wearables:AttachWearable(npc, "models/items/death_prophet/drowned_siren_head/drowned_siren_head.vmdl")
    wearables:AttachWearable(npc, "models/items/death_prophet/drowned_siren_drowned_siren_skirt/drowned_siren_drowned_siren_skirt.vmdl")
    wearables:AttachWearable(npc, "models/items/death_prophet/drowned_siren_armor/drowned_siren_armor.vmdl")
    wearables:AttachWearable(npc, "models/items/death_prophet/exorcism/drowned_siren_drowned_siren_crowned_fish/drowned_siren_drowned_siren_crowned_fish.vmdl")
    wearables:AttachWearable(npc, "models/items/death_prophet/drowned_siren_misc/drowned_siren_misc.vmdl")
    elseif npc:IsWolf() then
    UpdateModel(npc, "models/heroes/life_stealer/life_stealer.vmdl", 1)  
    wearables:AttachWearable(npc, "models/items/lifestealer/bloody_ripper_belt/bloody_ripper_belt.vmdl")
    wearables:AttachWearable(npc, "models/items/lifestealer/promo_bloody_ripper_back/promo_bloody_ripper_back.vmdl")
    wearables:AttachWearable(npc, "models/items/lifestealer/bloody_ripper_arms/bloody_ripper_arms.vmdl")       
    wearables:AttachWearable(npc, "models/items/lifestealer/bloody_ripper_head/bloody_ripper_head.vmdl")   
    elseif npc:IsTroll() then            
    UpdateModel(npc, "models/items/wraith_king/arcana/wraith_king_arcana.vmdl", 1)  
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_weapon.vmdl")
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_arms.vmdl")
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_shoulder.vmdl")
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_armor.vmdl")
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_back.vmdl")
    wearables:AttachWearable(npc, "models/items/wraith_king/arcana/wraith_king_arcana_head.vmdl")
    
    --UpdateModel(npc, "models/heroes/pudge/pudge.vmdl", 1)  
    -- wearables:AttachWearable(npc, "models/items/pudge/blackdeath_offhand/blackdeath_offhand.vmdl")
    --wearables:AttachWearable(npc, "models/items/pudge/blackdeath_belt/blackdeath_belt.vmdl")
    --  wearables:AttachWearable(npc, "models/items/pudge/blackdeath_head/blackdeath_head.vmdl")
    --   wearables:AttachWearable(npc, "models/items/pudge/blackdeath_back/blackdeath_back.vmdl")
    --  wearables:AttachWearable(npc, "models/items/pudge/blackdeath_weapon/blackdeath_weapon.vmdl")
    --  wearables:AttachWearable(npc, "models/items/pudge/blackdeath_shoulder/blackdeath_shoulder.vmdl")
    --   wearables:AttachWearable(npc, "models/items/pudge/blackdeath_arms/blackdeath_arms.vmdl")
    elseif npc:IsElf() then
    UpdateModel(npc, "models/items/wraith_king/wk_ti8_creep/wk_ti8_creep.vmdl", 1)  
    end
    end 
    end                                            