local item, super = Class(LightEquipItem, "tough_glove_2")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Tough Glove 2"
    self.short_name = "TuffGlove2"
    self.serious_name = "Glove 2"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Weapon AT 5\n* A worn pink leather glove.\nFor five-fingered folk."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 5
    }

    self.attack_bolts = 4
    self.attack_speed = 8
    self.attack_speed_variance = nil
    self.attack_direction = "random"
    self.attack_miss_zone = 22
    self.multibolt_variance = {{15}, {50}, {85}}

    self.attack_sound = "punchstrong"

end

function item:getLightBattleText()
    return "* You equipped Tough Glove 2."
end

function item:onHit(lane)
    local battler = lane.battler
    local enemy = Game.battle:getActionBy(battler).target

    Assets.playSound("punchweak")
    local small_punch = Sprite("effects/attack/hyperfist")
    small_punch:setOrigin(0.5, 0.5)
    small_punch:setScale(0.5, 0.5)
    small_punch.layer = BATTLE_LAYERS["above_ui"] + 5
    small_punch.color = battler.chara.color -- need to swap this to the get function
    small_punch:setPosition(enemy:getRelativePos((love.math.random(enemy.width)), (love.math.random(enemy.height))))
    enemy.parent:addChild(small_punch)
    small_punch:play(2/30, false, function(s) s:remove() end)
end

function item:onAttack(battler, enemy, damage, stretch, crit)
    local src = Assets.stopAndPlaySound(self:getAttackSound() or "laz_c")
    src:setPitch(self:getAttackPitch() or 1)

    local sprite = Sprite("effects/attack/hyperfist")
    sprite:setOrigin(0.5, 0.5)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
    sprite.layer = BATTLE_LAYERS["above_ui"] + 5
    sprite.color = battler.chara.color -- need to swap this to the get function
    enemy.parent:addChild(sprite)
    Game.battle:shakeCamera(3, 3, 2)

    if crit then
        Assets.stopAndPlaySound("saber3", 0.7)
    end

    Game.battle.timer:during(1, function() -- can't even tell if this is accurate
        sprite.x = sprite.x - 2 * DTMULT
        sprite.y = sprite.y - 2 * DTMULT
        sprite.x = sprite.x + Utils.random(4) * DTMULT
        sprite.y = sprite.y + Utils.random(4) * DTMULT
    end)

    sprite:play(2/30, false, function(this) -- timing may still be incorrect    
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

return item