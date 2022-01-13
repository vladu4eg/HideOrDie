PickTable = {}


function picktreant(keys)
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_treant", 0, 0)
    PlayerResource:SetGold(hero, gold+40)
    PlayerResource:SetLumber(hero, wood+20)
    UTIL_Remove(info.hero)
end
function pickchen(keys)
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info.hero)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_chen", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end
function picktiny(keys)
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_tiny", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end
function pickfurion(keys)
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_furion", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end
function pickhunter(keys)
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_bounty_hunter", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

-----------------------------


function picknevermore(keys)
    if PickTable[1] == nil then
        PickTable[1] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_nevermore") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_nevermore", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

function pickwarlock(keys)
    if PickTable[2] == nil then
        PickTable[2] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_warlock") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_warlock", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

function pickstalker(keys)
    if PickTable[3] == nil then
        PickTable[3] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_stalker") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_night_stalker", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

function pickdruid(keys)
    if PickTable[4] == nil then
        PickTable[4] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_druid") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_lone_druid", 0, 0)
    PlayerResource:SetGold(hero, gold)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

function pickdazzle(keys)
    if PickTable[5] == nil then
        PickTable[5] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_dazzle") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_dazzle", 0, 0)
    PlayerResource:SetGold(hero, gold+25)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

function pickbristleback(keys)
    if PickTable[6] == nil then
        PickTable[6] = keys.caster:GetPlayerOwnerID()
        keys.caster:AddNewModifier(nil, nil, "modifier_silence", nil)   
    else 
        return false
    end
    local trollCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    for i = 1, trollCount do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
        if PlayerResource:IsValidPlayerID(pID) then
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            if hero ~= nil then hero:RemoveAbility("pick_bristleback") end
        end
    end
	local info = {}
    info.PlayerID = keys.caster:GetPlayerOwnerID()
    info.hero = keys.caster
	Pets.DeletePet(info)
    local gold = PlayerResource:GetGold(keys.caster:GetPlayerOwnerID())
    local wood = PlayerResource:GetLumber(keys.caster:GetPlayerOwnerID())
    
    local hero = PlayerResource:ReplaceHeroWith(keys.caster:GetPlayerOwnerID(), "npc_dota_hero_bristleback", 0, 0)
    PlayerResource:SetGold(hero, gold+25)
    PlayerResource:SetLumber(hero, wood)
    UTIL_Remove(info.hero)
end

