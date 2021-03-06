if drop == nil then
	DebugPrint( 'drop' )
	_G.drop = class({})
end
require('settings')
item_drop = {
	--{items = {"item_branches"}, chance = 5, duration = 5, limit = 3, units = {} },
	{items = {"item_vip","item_event_desert","item_event_winter","item_event_helheim"}, limit = 3, chance = 50, units = {"npc_dota_hero_nevermore","npc_dota_hero_warlock","npc_dota_hero_night_stalker","npc_dota_hero_furion"} },
	{items = {"item_event_birthday"}, limit = 1, chance = 5, units = {"npc_dota_hero_nevermore","npc_dota_hero_warlock","npc_dota_hero_night_stalker","npc_dota_hero_furion"} },
	{items = {"item_recipe2_arcane_boots_datadriven","item_recipe2_phase_boots_datadriven","item_recipe2_power_treads_datadriven", "item_recipe2_mega_blade_datadriven"}, limit = 5, chance = 100, units = {"npc_dota_hero_furion"} },
	{items = {"item_lia_rune_gold", "item_lia_rune_lumber", "item_lia_rune_of_strength", "item_lia_rune_of_agility", "item_lia_rune_of_intellect", "item_lia_rune_of_restoration", "item_lia_rune_of_luck", "item_lia_rune_of_speed", "item_lia_rune_of_lifesteal"}, limit = 50, chance = 500, units = {"npc_dota_hero_nevermore","npc_dota_hero_warlock","npc_dota_hero_night_stalker","npc_dota_hero_furion"} },
	{items = {"item_lia_rune_lumber"}, limit = 10, chance = 5, units = {"ent_dota_tree"} },
		
--{items = {"item_lifesteal"}, limit = 200, chance = 70, units = {"npc_neutral_boss_1"} },
	--{items = {"item_dmg_14"}, limit = 200, chance = 70, units = {"npc_neutral_boss_1"} },
	--{items = {"item_reaver"}, limit = 200, chance = 70, units = {"npc_neutral_boss_1"} },
	
	--{items = {"item_soul_booster "}, limit = 200, chance = 70, units = {"npc_neutral_boss_2"} },
	--{items = {"item_mystic_staff"}, limit = 200, chance = 70, units = {"npc_neutral_boss_2"} },
	
	
	--{items = {"item_belt_of_strength","item_boots_of_elves","item_robe"}, chance = 10, limit = 5, units = {"npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner"}},--50% drop from list with limit
	--{items = {"item_ogre_axe","item_blade_of_alacrity","item_staff_of_wizardry"}, chance = 75, units = {"npc_dota_neutral_black_dragon","npc_dota_neutral_centaur_khan"}},--75% drop from list
	--{items = {"item_clarity","item_flask"}, chance = 25, duration = 10},-- global drop 25%
	--{items = {"item_rapier"}, chance = 10, limit = 1},-- global drop 10% with limit 1
}

function drop:RollItemDrop(unit)
	local unit_name = unit:GetUnitName() 
	if GameRules.PlayersCount >= MIN_RATING_PLAYER then
		for _,drop in ipairs(item_drop) do
			local items = drop.items or nil
			local items_num = #items
			local units = drop.units or nil -- ???????? ?????????? ???? ???????? ????????????????????, ???? ?????????????????????? ?????? ????????????
			local chance = drop.chance or 500 -- ???????? ???????? ???? ?????? ??????????????????, ???? ???? ?????????? 100
			local loot_duration = drop.duration or nil -- ???????????????????????? ?????????? ???????????????? ???? ??????????
			local limit = drop.limit or nil -- ?????????? ??????????????????
			local item_name = items[1] -- ???????????????? ????????????????
			local roll_chance = RandomFloat(0, 500)
			
			if string.match(GetMapName(),"halloween") then 
				chance = 100
			end
			
			if units then 
				for _,current_name in pairs(units) do
					if current_name == unit_name then
						units = nil
						break
					end
				end
			end
			
			if units == nil and (limit == nil or limit > 0) and roll_chance < chance then
				if limit then
					drop.limit = drop.limit - 1
				end
				
				if items_num > 1 then
					item_name = items[RandomInt(1, #items)]
				end
				
				local spawnPoint = unit:GetAbsOrigin()	
				local newItem = CreateItem( item_name, nil, nil )
				local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
				local dropRadius = RandomFloat( 50, 300 )
				
				newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
				if loot_duration then
					newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, loot_duration )
				end
			end
		end	
		
		local randTime = RandomInt( 30, 240 )
		Timers:CreateTimer(randTime, function()
			--if string.match(GetMapName(),SEASON_MAP)  then
				RandomDropLoot()
				--elseif string.match(GetMapName(),"halloween") then 
				--	RandomDropLoot()
				--	RandomDropLoot()
			--end
		end);
		
	end
end

function KillLoot( item, drop )
	
	if drop:IsNull() then
		return
	end
	
	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	--	EmitGlobalSound("Item.PickUpWorld")
	
	UTIL_Remove( item )
	UTIL_Remove( drop )
end

function RandomDropLoot()
	local spawnPoint = Vector(-320,-320,256)
	local newItem = CreateItem( SEASON_ITEM, nil, nil )
	local dropRadius = RandomFloat( 3600, 25000 )
	local randRadius = spawnPoint + RandomVector( dropRadius )
	local drop = CreateItemOnPositionForLaunch( randRadius, newItem )
	newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, randRadius )
end

function TimerRandomDrop(event)
	local unit = event.caster
	local countGift = 0
	local maxGift = RandomInt( 25, 200 )
	Timers:CreateTimer(function()
		if countGift < maxGift then
			local randTime = RandomInt( 20, 60 )
			local spawnPoint = unit:GetAbsOrigin()	
			local newItem = CreateItem( SEASON_ITEM, nil, nil )
			local dropRadius = RandomFloat( 10, 360 )
			local randRadius = spawnPoint + RandomVector( dropRadius )
			local drop = CreateItemOnPositionForLaunch( randRadius, newItem )
			newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, randRadius )
			countGift = countGift + 1
			return randTime
		end	
	end)
end

