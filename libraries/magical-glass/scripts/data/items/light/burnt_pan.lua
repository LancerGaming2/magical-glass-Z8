local item, super = Class(LightEquipItem, "burnt_pan")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Burnt Pan"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Weapon AT 10\n* Damage is rather consistent.\nConsumable items heal 4 more HP."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 10
    }

    self.attack_bolts = 4
    self.attack_speed = 10
    self.attack_speed_variance = 2
    self.attack_start = -50
    self.attack_miss_zone = 2
    self.multibolt_variance = {{0, 25, 50}, {100, 125, 150}, {200}}
    self.heal_bonus = 4

    self.attack_direction = "left"

    self.attack_sound = "frypan"
    
end

function item:onAttack(battler, enemy, damage, stretch, crit)
    local src = Assets.stopAndPlaySound(self:getAttackSound() or "laz_c")
    src:setPitch(self:getAttackPitch() or 1)

    local sprite = Sprite("effects/attack/frypan_impact")
    local stars = {}
    local angle = 6 * Utils.pick({1, -1})
    local form = 0
    local size = 2
    sprite:setScale(2, 2)
    sprite:setOrigin(0.5, 0.5)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
    sprite.layer = BATTLE_LAYERS["above_ui"] + 5
    sprite.color = battler.chara.color -- need to swap this to the get function
    enemy.parent:addChild(sprite)
    --Game.battle:shakeCamera(3, 3, 2)
    sprite:play(2/30, true)

    if crit then
        sprite:setColor(1, 1, 130/255)
        Assets.stopAndPlaySound("saber3", 0.7)
    end

    for i = 0, 8 do
        local star = Sprite("effects/attack/frypan_star")
        star:setOrigin(0.5, 0.5)
        star:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
        star.layer = BATTLE_LAYERS["above_ui"] + 4
        star.physics.direction = math.rad(360 * i) / 8
        star.physics.friction = 0.34
        star.physics.speed = 8
        star.ang = 12.25
        star.color = battler.chara.color
        if crit then
            star:setColor(1, 1, 130/255)
        end
        enemy.parent:addChild(star)
        table.insert(stars, star)
    end

    Game.battle.timer:during(25/30, function()

        sprite.rotation = sprite.rotation + math.rad(angle) * DTMULT
        if form == 0 then
            size = size + 0.3 * DTMULT
        end

        if size > 2.8 then
            form = 1
        end

        if form == 1 then
            size = size - 0.6 * DTMULT
            sprite.alpha = sprite.alpha - 0.2 * DTMULT
        end

        sprite:setScale(size)

        for _,star in ipairs(stars) do
            if star.physics.speed < 6 then
                star.alpha = star.alpha - 0.05 * DTMULT 
                if star.ang > 1 then
                    star.ang = star.ang + 0.5 * DTMULT
                end
            end

            star.rotation = math.rad(star.ang)
            if star.alpha < 0.05 then
                star:remove()
            end
        end
    end,
    function()
        local sound = enemy:getDamageSound() or "damage"
        if sound and type(sound) == "string" then
            Assets.stopAndPlaySound(sound)
        end
        enemy:hurt(damage, battler)

        battler.chara:onAttackHit(enemy, damage)
        sprite:remove()
        for _,star in ipairs(stars) do
            star:remove()
        end

        Game.battle:endAttack()
    end)

end

return item