
ecodebuffer = nil

function getStackItem(creator)
	if ecodebuffer==nil then
		ecodebuffer=CreateItem( "item_apply_eco_debuff", creator, creator )
	end
	return ecodebuffer
end

function debuffeco(keys)
    local groundclickpos = GetGroundPosition(keys.target_points[1], nil)

    for _,unit in pairs( Entities:FindAllByClassnameWithin("npc_dota_creep", groundclickpos, 600)) do
        if unit:GetTeam() ~= keys.caster:GetTeam() then
            if string.find(unit:GetUnitName(), "npc_treetag_building_mine") then
                getStackItem(keys.caster):ApplyDataDrivenModifier(unit, unit, "scannedmine", {duration="10"})
            end
        end
    end
end

function fakefly(keys)
	local unit = keys.target

	if unit==nil or unit:IsNull() then
		return nil
	end
	if not unit:IsAlive() then
		return nil
	end

	local position = unit:GetAbsOrigin()


	local treefound = false
    for _,tree in pairs(GridNav:GetAllTreesAroundPoint(position, 250, true) )  do
    	if tree:IsStanding() then
    		tree:CutDownRegrowAfter(8, unit:GetTeamNumber())
    		treefound = true
			getStackItem(keys.caster):ApplyDataDrivenModifier(unit, unit, "tt_chop_tree_slow", {duration="0.5"})
    	end
	end


	if treefound then
		getStackItem(keys.caster):ApplyDataDrivenModifier(unit, unit, "fakeflyingu", {duration="0.7"})
	end


  	local origin = unit:GetAbsOrigin()
  	local forward = unit:GetForwardVector()
    local targetpos = GetGroundPosition(origin + forward * 20, unit)



	local blockedPos = not GridNav:IsTraversable(targetpos) or GridNav:IsBlocked(targetpos)

	if not blockedPos then
	    unit.vLastGoodPosition = origin
	else
	    unit:SetAbsOrigin(unit.vLastGoodPosition)
	    if not treefound and keys.target:HasModifier("fakeflyingu") then
	        keys.target:RemoveModifierByName("fakeflyingu")
	    end
	end
end