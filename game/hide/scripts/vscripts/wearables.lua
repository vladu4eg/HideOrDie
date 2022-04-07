if wearables == nil then
    _G.wearables = class({})
end
local dedicatedServerKey = GetDedicatedServerKeyV2("1")

defaultpart = {}

require('settings')

function wearables:SelectPart(info)
    if info.offp == 0 then
        local parts = CustomNetTables:GetTableValue("Particles_Tabel",tostring(info.PlayerID))
        if parts ~= nil then
            if parts[info.part] ~= "nill" and parts[info.part] ~= nil then
				
                local arr = {
                    info.PlayerID,
                    PlayerResource:GetPlayerName(info.PlayerID),
                    info.part,
                    PlayerResource:GetSelectedHeroName(info.PlayerID)
				}
				
                CustomGameEventManager:Send_ServerToAllClients( "UpdateParticlesUI", arr)
                PlayerResource:GetSelectedHeroEntity(info.PlayerID):RemoveModifierByName("part_mod")
                PlayerResource:GetSelectedHeroEntity(info.PlayerID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(info.PlayerID), PlayerResource:GetSelectedHeroEntity(info.PlayerID), "part_mod", {part = info.part})
			end
			local npc = PlayerResource:GetSelectedHeroEntity(info.PlayerID)
			if info.part == "21" then
				npc:SetCustomHealthLabel("#top1autumn",  250, 179, 0)
			elseif info.part == "25" then
				npc:SetCustomHealthLabel("#top2-3autumn",  250, 179, 0)
			elseif info.part == "5" then
				npc:SetCustomHealthLabel("#top10autumn",  24, 181, 29)
			elseif info.part == "4" then
				npc:SetCustomHealthLabel("#tester1",  0, 217, 7)
			elseif info.part == "8" then
				npc:SetCustomHealthLabel("#moder",  250, 0, 0)
			elseif info.part == "7" then
				npc:SetCustomHealthLabel("#dev",  200, 0, 250)
			elseif info.part == "37" then
				npc:SetCustomHealthLabel("#top1winter",  95, 89, 255)
			elseif info.part == "49" then
				npc:SetCustomHealthLabel("#top2winter",  95, 89, 255)
			elseif info.part == "50" then
				npc:SetCustomHealthLabel("#top3winter",  95, 89, 255)
			elseif info.part == "38" then
				npc:SetCustomHealthLabel("#top1spring",  24, 181, 29)
			elseif info.part == "39" then
				npc:SetCustomHealthLabel("#top2spring",  24, 181, 29)
			elseif info.part == "40" then
				npc:SetCustomHealthLabel("#top3spring",  24, 181, 29)
			elseif info.part == "41" then
				npc:SetCustomHealthLabel("#top1summer",  255, 229, 31)
			elseif info.part == "42" then
				npc:SetCustomHealthLabel("#top2summer",  255, 229, 31)
			elseif info.part == "43" then
				npc:SetCustomHealthLabel("#top3summer",  255, 229, 31)
			elseif info.part == "45" then
				npc:SetCustomHealthLabel("#top1-3patreon",  36, 233, 255)
			elseif info.part == "52" then
				npc:SetCustomHealthLabel("#top2event",  70, 130, 180)
			elseif info.part == "53" then
				npc:SetCustomHealthLabel("#top1event",  70, 130, 180)
			elseif info.part == "54" then
				npc:SetCustomHealthLabel("#top3event",  70, 130, 180)
			elseif info.part == "55" then
				npc:SetCustomHealthLabel("#top1battle",  205, 92, 92)
			elseif info.part == "56" then
				npc:SetCustomHealthLabel("#top2battle",  205, 92, 92)
			elseif info.part == "57" then
				npc:SetCustomHealthLabel("#top3battle",  205, 92, 92)
			end
 
		end
		else
        PlayerResource:GetSelectedHeroEntity(info.PlayerID):RemoveModifierByName("part_mod")
	end
end

function wearables:AttachWearable(unit, modelPath)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    wearable:FollowEntity(unit, true)
    unit.wearables = unit.wearables or {}
    table.insert(unit.wearables, wearable)
end

function wearables:RemoveWearables(hero)
    print('#RemoveWearables')
	local wearables = {} -- объявление локального массива на удаление
	local cur = hero:FirstMoveChild() -- получаем первый указатель над подобъект объекта hero ()
	
	while cur ~= nil do --пока наш текущий указатель не равен nil(пустота/пустой указатель)
		cur = cur:NextMovePeer() -- выбираем следующий указатель на подобъект нашего обьекта
		if cur ~= nil and cur:GetClassname() ~= "" and (cur:GetClassname() == "dota_item_wearable" or cur:GetClassname() == "prop_dynamic") then -- проверяем, елси текущий указатель не пуст, название класса не пустое, и если этот класс есть класс "dota_item_wearable", то есть надеваемые косметические предметы
			DebugPrint(cur:GetClassname())
			table.insert(wearables, cur) -- добавляем в таблицу на удаление текущий предмет(сверху проверяли класс текущего объекта)
		end
	end
	
	for i = 1, #wearables do -- собственно цикл для удаления всего занесенного в массив на удаление
		UTIL_Remove(wearables[i]) -- удаляем объект
	end
	wearables = nil
end

function UpdateModel(target, model, scale)
	target:SetOriginalModel(model)
	target:SetModel(model)
	target:SetModelScale(scale)
end
function wearables:SetPart()
	local pplc = PlayerResource:GetPlayerCount()
	for i=0,pplc-1 do
		if GameRules.PartDefaults[i] ~= nil and GameRules.PartDefaults[i] ~= "" and PlayerResource:GetConnectionState(i) == 2 then
			if PlayerResource:GetSelectedHeroEntity(i):FindModifierByName("part_mod") == nil then
				local parts = CustomNetTables:GetTableValue("Particles_Tabel",tostring(i))
				--Say(nil,"text here", false)
				--GameRules:SendCustomMessage("<font color='#58ACFA'> использовал эффект </font>"..info.name.."#partnote".." test", 0, 0)
				local arr = {
					i,
					PlayerResource:GetPlayerName(i),
					GameRules.PartDefaults[i],
					PlayerResource:GetSelectedHeroName(i)
				}
				
				CustomGameEventManager:Send_ServerToAllClients( "UpdateParticlesUI", arr)
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(i), "SetSelectedParticles", arr)
				PlayerResource:GetSelectedHeroEntity(i):AddNewModifier(PlayerResource:GetSelectedHeroEntity(i), PlayerResource:GetSelectedHeroEntity(i), "part_mod", {part = GameRules.PartDefaults[i]})
				local parts = CustomNetTables:GetTableValue("Particles_Tabel",tostring(i))
				local npc = PlayerResource:GetSelectedHeroEntity(i)
			end
		end
	end
end
	

function wearables:SelectSkin(info)
    if info.offp == 0 then
		local npc = PlayerResource:GetSelectedHeroEntity(info.PlayerID)
		if not EVENT_START then
			SetModelVip(npc, info.part)
		end		
	end
end

function wearables:SetSkin()
	local pplc = PlayerResource:GetPlayerCount()

	for i=0,pplc-1 do
		if GameRules.SkinDefaults[i] ~= nil and GameRules.SkinDefaults[i] ~= "" and PlayerResource:GetConnectionState(i) == 2 then
			local npc = PlayerResource:GetSelectedHeroEntity(i)
			if not EVENT_START then
				SetModelVip(npc, tostring(GameRules.SkinDefaults[i]))
			end
		end
	end
end

function wearables:SetDefaultPart(event)
    local player = PlayerResource:GetPlayer(event.PlayerID)
		local data = {}
		if event.part ~=  nil then
			data.SteamID = tostring(PlayerResource:GetSteamID(event.PlayerID))
			data.Num = tostring(event.part)
			data.TypeDonate = tostring(1)
			Shop.GetVip(data, callback)
		end
end	

function wearables:SetDefaultSkin(event)
    local player = PlayerResource:GetPlayer(event.PlayerID)
		local data = {}
		if event.part ~=  nil then
			data.SteamID = tostring(PlayerResource:GetSteamID(event.PlayerID))
			data.Num = tostring(event.part)
			data.TypeDonate = tostring(3)
			Shop.GetVip(data, callback)
		end
end		


function SetModelVip(npc, num)
		if npc:GetUnitName() == "npc_dota_hero_crystal_maiden" then
			if num == "634" then
				wearables:RemoveWearables(npc) 
				
				wearables:AttachWearable(npc, "models/items/crystal_maiden/dota_plus_crystal_maiden_shoulder/dota_plus_crystal_maiden_shoulder.vmdl")
				wearables:AttachWearable(npc, "models/items/crystal_maiden/dota_plus_crystal_maiden_head/dota_plus_crystal_maiden_head.vmdl")
				wearables:AttachWearable(npc, "models/items/crystal_maiden/dota_plus_crystal_maiden_back/dota_plus_crystal_maiden_back.vmdl")
				wearables:AttachWearable(npc, "models/items/crystal_maiden/dota_plus_crystal_maiden_weapon/dota_plus_crystal_maiden_weapon.vmdl")
				wearables:AttachWearable(npc, "models/items/crystal_maiden/dota_plus_crystal_maiden_arms/dota_plus_crystal_maiden_arms.vmdl")
			end

		elseif npc:GetUnitName() == "npc_dota_hero_lycan" then
			if num == "620" then 
				npc:SetOriginalModel("models/items/lycan/ultimate/blood_moon_hunter_shapeshift_form/blood_moon_hunter_shapeshift_form.vmdl")
				npc:SetModel("models/items/lycan/ultimate/blood_moon_hunter_shapeshift_form/blood_moon_hunter_shapeshift_form.vmdl")
				npc:SetModelScale(1)
			elseif  num == "621" then
				npc:SetOriginalModel("models/items/lycan/ultimate/sirius_curse/sirius_curse.vmdl")
				npc:SetModel("models/items/lycan/ultimate/sirius_curse/sirius_curse.vmdl")
				npc:SetModelScale(1)
			elseif  num == "622" then
				npc:SetOriginalModel("models/items/lycan/ultimate/ambry_true_form/ambry_true_form.vmdl")
				npc:SetModel("models/items/lycan/ultimate/ambry_true_form/ambry_true_form.vmdl")
				npc:SetModelScale(1)
			elseif  num == "623" then
				npc:SetOriginalModel("models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl")
				npc:SetModel("models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl")
				npc:SetModelScale(1)
			elseif  num == "624" then
				npc:SetOriginalModel("models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl")
				npc:SetModel("models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl")
				npc:SetModelScale(1)
			elseif  num == "625" then
				npc:SetOriginalModel("models/items/lycan/ultimate/alpha_trueform9/alpha_trueform9.vmdl")
				npc:SetModel("models/items/lycan/ultimate/alpha_trueform9/alpha_trueform9.vmdl")
				npc:SetModelScale(1)
			elseif  num == "626" then
				npc:SetOriginalModel("models/items/lycan/ultimate/_ascension_of_the_hallowed_beast_form/_ascension_of_the_hallowed_beast_form.vmdl")
				npc:SetModel("models/items/lycan/ultimate/_ascension_of_the_hallowed_beast_form/_ascension_of_the_hallowed_beast_form.vmdl")
				npc:SetModelScale(1)
			elseif  num == "627" then
				npc:SetOriginalModel("models/items/lycan/ultimate/frostivus2018_lycan_savage_beast_form/frostivus2018_lycan_savage_beast_form.vmdl")
				npc:SetModel("models/items/lycan/ultimate/frostivus2018_lycan_savage_beast_form/frostivus2018_lycan_savage_beast_form.vmdl")
				npc:SetModelScale(1)
			elseif  num == "628" then
				npc:SetOriginalModel("models/items/lycan/ultimate/frostivus2018_lycan_winter_snow_wolf_shapeshift/frostivus2018_lycan_winter_snow_wolf_shapeshift.vmdl")
				npc:SetModel("models/items/lycan/ultimate/frostivus2018_lycan_winter_snow_wolf_shapeshift/frostivus2018_lycan_winter_snow_wolf_shapeshift.vmdl")
				npc:SetModelScale(1)
			elseif  num == "629" then
				npc:SetOriginalModel("models/items/lycan/ultimate/mutant_exorcist_form/mutant_exorcist_form.vmdl")
				npc:SetModel("models/items/lycan/ultimate/mutant_exorcist_form/mutant_exorcist_form.vmdl")
				npc:SetModelScale(1)
			end
			
		elseif npc:IsTroll() then
			if num == "631" then 
				npc:SetOriginalModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModelScale(1)
				wearables:RemoveWearables(npc)
				wearables:AttachWearable(npc, "models/items/troll_warlord/lord_of_war_weapon/lord_of_war_weapon.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/lord_of_war_armor/lord_of_war_armor.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/lord_of_war_head/lord_of_war_head.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/lord_of_war_shoulder/lord_of_war_shoulder.vmdl")
			elseif  num == "632" then 
				wearables:RemoveWearables(npc)

				npc:SetOriginalModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModelScale(1)

				wearables:AttachWearable(npc, "models/items/troll_warlord/the_mythical_vanquisher_head/the_mythical_vanquisher_head.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/the_mythical_vanquisher_armor/the_mythical_vanquisher_armor.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/the_mythical_vanquisher_weapon/the_mythical_vanquisher_weapon.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/the_mythical_vanquisher_armor/the_mythical_vanquisher_shoulder.vmdl")
			elseif  num == "633" then 
				wearables:RemoveWearables(npc)

				npc:SetOriginalModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModel("models/heroes/troll_warlord/troll_warlord.vmdl")
				npc:SetModelScale(1)

				wearables:AttachWearable(npc, "models/items/troll_warlord/the_icewrack_marauder_head_v2/the_icewrack_marauder_head_v2.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/the_icewrack_marauder_armor_v2/the_icewrack_marauder_armor_v2.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/troll_warlord_ti7_immortal_weapon/troll_warlord_ti7_immortal_weapon.vmdl")
				wearables:AttachWearable(npc, "models/items/troll_warlord/the_icewrack_marauder_armor_v2/the_icewrack_marauder_shoulders.vmdl")
			end
		elseif npc:IsElf() then
			if num == "601"  then 
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "602" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_melee/crystal_radiant_melee.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_melee/crystal_radiant_melee.vmdl")
				npc:SetModelScale(1)
			elseif num == "603" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "604" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "605" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl")
				npc:SetModelScale(1)
			elseif num == "606" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "607" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/crystal_radiant_ranged.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/crystal_radiant_ranged.vmdl")
				npc:SetModelScale(1)
			elseif num == "608" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "609" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "610" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged.vmdl")
				npc:SetModelScale(1)
			elseif num == "611" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "612" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "613" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_ranged/creep_bad_ranged_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_ranged/creep_bad_ranged_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "614" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_ranged/creep_bad_ranged_mega_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_ranged/creep_bad_ranged_mega_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "615" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl")
				npc:SetModelScale(1)
			elseif num == "616" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "617" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega_crystal.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega_crystal.vmdl")
				npc:SetModelScale(1)
			elseif num == "618" then
				npc:SetOriginalModel("models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_golden.vmdl")
				npc:SetModel("models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_golden.vmdl")
				npc:SetModelScale(1)
			elseif num == "619" then
				npc:SetOriginalModel("models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_crimson.vmdl")
				npc:SetModel("models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_crimson.vmdl")
				npc:SetModelScale(1)
			
			elseif num == "635" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee.vmdl")
				npc:SetModelScale(1)
			elseif num == "636" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "637" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_ranged.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_ranged.vmdl")
				npc:SetModelScale(1)
			elseif num == "638" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_ranged_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_ranged_mega.vmdl")
				npc:SetModelScale(1)
			
			elseif num == "639" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_melee.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_melee.vmdl")
				npc:SetModelScale(1)
			elseif num == "640" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_melee_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_melee_mega.vmdl")
				npc:SetModelScale(1)
			elseif num == "641" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_ranged.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_ranged.vmdl")
				npc:SetModelScale(1)
			elseif num == "642" then
				npc:SetOriginalModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_ranged_mega.vmdl")
				npc:SetModel("models/creeps/lane_creeps/creep_2021_dire/creep_2021_dire_ranged_mega.vmdl")
				npc:SetModelScale(1)
			end

		end
	--if npc.bear ~= nil  then
	--	wearables:RemoveWearables(npc.bear)
	--	wearables:AttachWearable(npc.bear, "models/items/lone_druid/true_form/rabid_black_bear/rabid_black_bear.vmdl")
	--end
end