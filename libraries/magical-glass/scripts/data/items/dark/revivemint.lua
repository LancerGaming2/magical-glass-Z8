local item, super = Class("revivemint", true)

function item:onLightBattleUse(user, target)
    item:onBattleUse(user, target)
    Assets.stopAndPlaySound("power")
    Game.battle:battleText(self:getLightBattleText(user, target))
end

return item