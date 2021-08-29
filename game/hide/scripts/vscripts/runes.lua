runeTypes = {
	item_lia_rune_of_healing = 1,
	item_lia_rune_of_mana = 1,
	item_lia_rune_of_restoration = 1, 
	item_lia_rune_of_speed = 1,
	item_lia_rune_of_strength = 1,
	item_lia_rune_of_agility = 1,
	item_lia_rune_of_intellect = 1,
	item_lia_rune_of_lifesteal = 1,
	item_lia_rune_of_luck = 1,
	item_lia_rune_gold = 0.8,
	item_lia_rune_lumber = 0.8, --эта руна будет появляться в два раза реже руны с значением 1
}

runeSpawnTime = 1 --период появления рун
Q = 1

local vRuneSpawnMin = Vector(-1, -1, 0)
local vRuneSpawnMax = Vector(1, 1, 0)

	
runesSpawnChanceSumm = 0
for k,v in pairs(runeTypes) do
	runesSpawnChanceSumm = runesSpawnChanceSumm + v
	runeTypes[k] = runesSpawnChanceSumm
end


function GetRandomRuneType()
	local f = RandomFloat(0,runesSpawnChanceSumm)
	for k,v in pairs(runeTypes) do
		if v>=f then
			return k
		end
	end
end

function GetRuneSpawnPos()
	if runeSpawnRegionType == "rectangle" then
		return Vector(RandomFloat(vRuneSpawnMin.x,vRuneSpawnMax.x), RandomFloat(vRuneSpawnMin.y,vRuneSpawnMax.y), 0)
	elseif runeSpawnRegionType == "circle" then
		return vRuneSpawnMin+RandomVector(RandomInt(0,16000))
	else
		return Vector(RandomFloat(vRuneSpawnMin.x,vRuneSpawnMax.x), RandomFloat(vRuneSpawnMin.y,vRuneSpawnMax.y), 0)
	end
end

function SpawnRune()
	local rune = CreateItem(GetRandomRuneType(), nil, nil)
	CreateItemOnPositionSync(GetRuneSpawnPos(), rune)
end

function StartRunesSpawn()
	Timers:CreateTimer("LiAruneSpawner",
		{
            endTime = runeSpawnTime, 
            callback = function() 
            	SpawnRune() 
            	Q = Q + 1
            	if Q == 150 then 
            		return nil 
            	end
            	return runeSpawnTime 
            end
        }
    )
end

function StopRunesSpawn()
	Timers:RemoveTimer("LiAruneSpawner")
end

function SetRuneSpawnRegion(regionType,vMin,vMax)
	if regionType == "circle" then
		runeSpawnRegionType = regionType
		vRuneSpawnMin = vMin
	elseif regionType == "rectangle" then
		runeSpawnRegionType = regionType
		vRuneSpawnMin = vMin
		vRuneSpawnMax = vMax
	else
		runeSpawnRegionType = "all_world"
		vRuneSpawnMin = Entities:FindByName(nil, "world_bounds_min"):GetAbsOrigin()
		vRuneSpawnMax = Entities:FindByName(nil, "world_bounds_max"):GetAbsOrigin()
	end
end

                    --SetRuneSpawnRegion("all_world",Entities:FindByName(nil, "world_bounds_min"):GetAbsOrigin(),Entities:FindByName(nil, "world_bounds_max"):GetAbsOrigin())

--[[
test = {}
for i=1,10000 do
	q = GetRandomRuneType()
	if test[q] then 
		test[q] = test[q] + 1
	else
		test[q] = 1
	end
	--print(q)
	
end
DeepPrintTable(test)
]]