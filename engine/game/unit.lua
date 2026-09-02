Unit = Object:extend()

function Unit:init_unit(args)
    args = args or {}
    self.level = self.level or args.level or 1
    self.max_hp = self.max_hp or args.max_hp or 100
    self.hp = self.hp or args.hp or self.max_hp
    self.dmg = self.dmg or args.dmg or 10
    self.def = self.def or args.def or 0
    self.mvspd = self.mvspd or args.mvspd or self.speed or args.speed or 240
    self.dead = self.dead or false
    return self
end

function Unit:calculate_damage(amount)
    local defense = math.max(-99, self.def or 0)

    if defense >= 0 then
        return amount * 100 / (100 + defense)
    end

    return amount * (2 - 100 / (100 - defense))
end

function Unit:hit(amount)
    if self.dead then
        return 0
    end

    local damage = math.max(0, self:calculate_damage(amount))
    self.hp = math.max(0, self.hp - damage)

    if self.hp == 0 then
        self.dead = true
        if self.on_death then
            self:on_death()
        end
    end

    return damage
end

function Unit:heal(amount)
    if self.dead then
        return 0
    end

    local old_hp = self.hp
    self.hp = math.min(self.max_hp, self.hp + math.max(0, amount))
    return self.hp - old_hp
end

function Unit:get_health_ratio()
    if self.max_hp <= 0 then
        return 0
    end

    return self.hp / self.max_hp
end

function Unit:is_dead()
    return self.dead
end
