local PLUGIN = PLUGIN

PLUGIN.config = {
    ["npc_citizen"] = {
    rarity = 40,
    dropCurrency = true,
    },
    ["npc_combine_s"] = {
        rarity = 0,
        dropCurrency = true,
    },
    ["npc_metropolice"] = {
        rarity = 0,
        dropCurrency = true,
    },

}

function PLUGIN:OnNPCKilled(ent, ply)
    local config = self.config[ent:GetClass()]

    if not (config and config.dropCurrency) then
        return
    end

    local currencyAmount = math.random(100, 1000)
    ix.currency.Spawn(ent:GetPos() + Vector(0, 0, 16), currencyAmount)
end
