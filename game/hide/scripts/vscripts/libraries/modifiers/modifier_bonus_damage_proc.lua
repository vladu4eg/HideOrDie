modifier_bonus_damage_proc = class({})

function modifier_bonus_damage_proc:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_PROC,
    }
    return funcs
end

function modifier_bonus_damage_proc:GetModifierPreAttack_BonusDamage_Proc( params )
    return 10
end

function modifier_bonus_damage_proc:IsHidden()
    return true
end