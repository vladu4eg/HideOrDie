item_mega_blade_of_stat = class({})
LinkLuaModifier("modifier_item_mega_blade_of_stat","items/item_mega_blade_of_stat.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mega_blade_of_stat_active","items/item_mega_blade_of_stat.lua",LUA_MODIFIER_MOTION_NONE)

function item_mega_blade_of_stat:GetIntrinsicModifierName()
	return "modifier_item_mega_blade_of_stat"
end

function item_mega_blade_of_stat:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_mega_blade_of_stat_active", {duration = self:GetSpecialValueFor("duration")} )	
end

---------------------------------------

modifier_item_mega_blade_of_stat = class({})

function modifier_item_mega_blade_of_stat:IsHidden() 
	return true
end

function modifier_item_mega_blade_of_stat:IsPurgable()
	return false
end

function modifier_item_mega_blade_of_stat:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_item_mega_blade_of_stat:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
 
	return funcs
end

function modifier_item_mega_blade_of_stat:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_item_mega_blade_of_stat:GetModifierBonusStats_Agility()
	return self.bonusAgility
end
function modifier_item_mega_blade_of_stat:GetModifierBonusStats_Strength()
	return self.bonusAgility
end
function modifier_item_mega_blade_of_stat:GetModifierBonusStats_Intellect()
	return self.bonusAgility
end

function modifier_item_mega_blade_of_stat:GetModifierAttackSpeedBonus_Constant()
	return self.bonusAttackSpeed
end

function modifier_item_mega_blade_of_stat:OnCreated()
	self.bonusDamage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.bonusAgility = self:GetAbility():GetSpecialValueFor("bonus_agility") 
	self.bonusAttackSpeed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

-----------------------------------------------------

modifier_item_mega_blade_of_stat_active = class({})

function modifier_item_mega_blade_of_stat_active:IsBuff()
	return true
end

function modifier_item_mega_blade_of_stat_active:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end

function modifier_item_mega_blade_of_stat_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then

	function modifier_item_mega_blade_of_stat_active:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		}
	 
		return funcs
	end

	function modifier_item_mega_blade_of_stat_active:GetModifierBonusStats_Agility()
		return self.bonusAgility
	end
	
	function modifier_item_mega_blade_of_stat_active:GetModifierBonusStats_Strength()
		return self.bonusAgility
	end
	
	function modifier_item_mega_blade_of_stat_active:GetModifierBonusStats_Intellect()
		return self.bonusAgility
	end
	
	function modifier_item_mega_blade_of_stat_active:OnCreated()
		self.bonusAgility = self:GetParent():GetBaseAgility() * self:GetAbility():GetSpecialValueFor("agi_percent") / 100
		self:SetStackCount(self.bonusAgility)
	end

end

