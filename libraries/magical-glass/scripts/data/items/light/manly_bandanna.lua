local item, super = Class(LightEquipItem, "light/manly_bandanna")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Manly Bandanna"
    self.short_name = "Mandanna"
    self.serious_name = "Bandanna"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Armor DF 7\n* It has seen some wear.\nIt has abs drawn on it."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        defense = 7
    }

end

return item