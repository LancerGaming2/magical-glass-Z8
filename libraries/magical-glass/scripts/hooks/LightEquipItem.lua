---@class LightEquipItem : Item
---@overload fun(...) : LightEquipItem
local LightEquipItem, super = Class("LightEquipItem", true)

function LightEquipItem:init()
    super.init(self)

    self.attack_bolts = 1

    self.attack_speed = 11 -- negative if left, positive if right.
    self.attack_speed_variance = 2

    self.attack_start = -16 -- number or table of where the bolt spawns. if it's a table, a value is chosen randomly
    self.multibolt_variance = {{50, 75, 100}, {150, 175, 200}}

    self.attack_direction = "right" -- "right", "left", or "random"

    self.attack_miss_zone = 295 -- negative if left, positive if right

    -- Sound played when attacking, defaults to laz_c
    self.attack_sound = "laz_c"

    self.attack_pitch = 1

end

function LightEquipItem:getAttackBolts() return self.attack_bolts end

function LightEquipItem:getAttackSpeed()
    if self:getAttackSpeedVariance() then
        return self.attack_speed + self:getAttackSpeedVariance()
    else
        return self.attack_speed
    end
end
function LightEquipItem:getAttackSpeedVariance() return self.attack_speed_variance end

function LightEquipItem:getAttackStart()
    if type(self.attack_start) == "table" then
        return Utils.pick(self.attack_start)
    elseif type(self.attack_start) == "number" then
        return self.attack_start
    end
end

function LightEquipItem:getMultiboltVariance(index)
    return Utils.pick(self.multibolt_variance[index]) or 0
end

function LightEquipItem:getAttackDirection() 
    if self.attack_direction == "random" then
        return Utils.pick({"right", "left"})
    else
        return self.attack_direction
    end
end

function LightEquipItem:getAttackMissZone() return self.attack_miss_zone end
function LightEquipItem:getAttackSound() return self.attack_sound end
function LightEquipItem:getAttackPitch() return self.attack_pitch end

-- these need to be modified for more than one party member
function LightEquipItem:showEquipText()
    Game.world:showText("* You equipped the "..self:getName()..".")
end

-- why the fuck doesn't this work
function LightEquipItem:onWorldUse(target)
    Assets.playSound("item")
    local chara = Game.party[1]
    local replacing = nil
    if self.type == "weapon" then
        if chara:getWeapon() then
            replacing = chara:getWeapon()
            replacing:onUnequip(chara, self)
            Game.inventory:replaceItem(self, replacing)
        end
        chara:setWeapon(self)
    elseif self.type == "armor" then
        if chara:getArmor(1) then
            replacing = chara:getArmor(1)
            replacing:onUnequip(chara, self)
            Game.inventory:replaceItem(self, replacing)
        end
        chara:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end

    self:onEquip(chara, replacing)

    self:showEquipText()
    return false
end

function LightEquipItem:getLightBattleText(user, target)
    return "* You equipped the " .. self:getName() .. "."
end

function LightEquipItem:onLightBattleUse(user, target)
    Assets.playSound("item")
    local chara = user.chara
    local replacing = nil
    if self.type == "weapon" then
        if chara:getWeapon() then
            replacing = chara:getWeapon()
            replacing:onUnequip(chara, self)
            Game.inventory:replaceItem(self, replacing)
        end
        chara:setWeapon(self)
    elseif self.type == "armor" then
        if chara:getArmor(1) then
            replacing = chara:getArmor(1)
            replacing:onUnequip(chara, self)
            Game.inventory:replaceItem(self, replacing)
        end
        chara:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end

    self:onEquip(chara, replacing)
end

function LightEquipItem:onAttack(battler, enemy, damage, stretch)

    local sprite = Sprite("effects/attack/strike")
    local scale = (stretch * 2) - 0.5
    sprite:setScale(scale, scale)
    sprite:setOrigin(0.5, 0.5)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2) - 5, (enemy.height / 2) - 5))
    sprite.layer = enemy.layer + 0.01
    sprite.color = battler.chara.color -- need to swap this to the get function
    enemy.parent:addChild(sprite)
    sprite:play((stretch / 4) / 1.5, false, function(this) -- timing may still be incorrect    
        local sound = enemy:getDamageSound() or "damage"
        if sound and type(sound) == "string" then
            Assets.stopAndPlaySound(sound)
        end
        enemy:hurt(damage, battler)

        battler.chara:onAttackHit(enemy, damage)
        this:remove()

        Game.battle:endAttack()

    end)

end

function LightEquipItem:onMiss(battler, enemy)
    enemy:lightStatusMessage("msg", "miss", {battler.chara:getDamageColor()}, false) -- needs a special miss message that doesn't animate
    Game.battle:endAttack()
end

return LightEquipItem