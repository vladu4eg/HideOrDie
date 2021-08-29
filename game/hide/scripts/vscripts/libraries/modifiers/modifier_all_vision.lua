modifier_all_vision = class({})


function modifier_all_vision:CheckState() 
    return { [MODIFIER_STATE_PROVIDES_VISION] = true,}
end

function modifier_all_vision:IsHidden()
    return true
end

function modifier_all_vision:IsPurgable()
    return false
end