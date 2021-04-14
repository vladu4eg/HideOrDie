modifier_attack_trees = class({})

function modifier_attack_trees:CheckState() 
    local state = {
        [MODIFIER_PROPERTY_CAN_ATTACK_TREES] = 1,
    }
    return state
end

function modifier_attack_trees:DeclareFunctions()
    return { MODIFIER_PROPERTY_CAN_ATTACK_TREES }
end

function modifier_attack_trees:GetModifierCanAttackTrees()
    return 0
end

function modifier_attack_trees:IsHidden()
    return true
end

function modifier_attack_trees:IsPurgable()
    return false
end