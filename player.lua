Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)

local function ease_out_cubic(t)
    return 1 - (1 - t) ^ 3
end

local function color_with_alpha(color, alpha)
    return {color.r or color[1], color.g or color[2], color.b or color[3], alpha}
end

function Player:init(args)
    self:init_game_object(args)
    self:init_physics(args)
    self:init_unit(args)
    self.size = self.size or 7
    self:set_as_rectangle(self.size, self.size, "dynamic", "player")
    self.color = self.color or {250 / 255, 207 / 255, 0, 1}
    self.shadow_color = self.shadow_color or {0, 0, 0, 0.35}
    self.heroes = self.heroes or {}
    self.active_hero_index = 1
    self.aim_r = 0
    self.arrow_distance = 13
    self.dash_distance = 48
    self.dash_windup = 0.05
    self.dash_travel = 0.08
    self.dash_land = 0.10
    self.dash_duration = self.dash_windup + self.dash_travel + self.dash_land
    self.dash_cooldown = 0.5
    self.dash_cooldown_time = 0
    self.dashing = false
    self.dash_time = 0
    self.switching = false
    self.switch_time = 0
    self.switch_cooldown = 2
    self.switch_cooldown_time = 0
    self.switch_shrink_end = 0.06
    self.switch_pop_end = 0.14
    self.switch_duration = 0.20
end

function Player:set_aim_position(x, y)
    if not x or not y or self.dashing then return end
    if (x - self.x) ^ 2 + (y - self.y) ^ 2 > 1 then
        self.aim_r = math.atan2(y - self.y, x - self.x)
    end
end

function Player:can_dash()
    return not self.dashing and self.dash_cooldown_time == 0
end

function Player:start_dash()
    if not self:can_dash() then return end

    local half_size = self.size / 2
    self.dash_start_x, self.dash_start_y = self.x, self.y
    self.dash_target_x = math.max(half_size,
        math.min(gw - half_size, self.x + math.cos(self.aim_r) * self.dash_distance))
    self.dash_target_y = math.max(half_size,
        math.min(gh - half_size, self.y + math.sin(self.aim_r) * self.dash_distance))
    self.dash_time = 0
    self.dashing = true
    self.dash_cooldown_time = self.dash_cooldown
end

function Player:get_dash_travel_progress()
    return math.max(0, math.min(1,
        (self.dash_time - self.dash_windup) / self.dash_travel))
end

function Player:update_dash(dt)
    self.dash_cooldown_time = math.max(self.dash_cooldown_time - dt, 0)
    if not self.dashing then return end

    self.dash_time = math.min(self.dash_time + dt, self.dash_duration)
    local progress = ease_out_cubic(self:get_dash_travel_progress())
    self.x = self.dash_start_x + (self.dash_target_x - self.dash_start_x) * progress
    self.y = self.dash_start_y + (self.dash_target_y - self.dash_start_y) * progress
    if self.dash_time == self.dash_duration then self.dashing = false end
end

function Player:get_active_hero()
    return self.heroes[self.active_hero_index]
end

function Player:get_standby_hero()
    if #self.heroes < 2 then return end
    return self.heroes[self.active_hero_index == 1 and 2 or 1]
end

function Player:get_color()
    if self:get_active_hero() then return self:get_active_hero().color end
    return self.color
end

function Player:can_switch()
    return #self.heroes > 1 and not self.switching and self.switch_cooldown_time == 0
end

function Player:start_switch()
    if not self:can_switch() then return end
    self.switching = true
    self.hero_switched = false
    self.switch_time = 0
    self.switch_cooldown_time = self.switch_cooldown
end

function Player:update_switch(dt)
    self.switch_cooldown_time = math.max(self.switch_cooldown_time - dt, 0)
    if not self.switching then return end

    self.switch_time = math.min(self.switch_time + dt, self.switch_duration)

    if not self.hero_switched and self.switch_time >= self.switch_shrink_end then
        self.active_hero_index = self.active_hero_index == 1 and 2 or 1
        self.hero_switched = true
    end

    if self.switch_time == self.switch_duration then self.switching = false end
end

function Player:update_heroes(dt)
    for _, hero in ipairs(self.heroes) do hero:update(dt) end
end

function Player:get_attack_target(enemies)
    local hero = self:get_active_hero()
    if not hero then return end

    local target
    local nearest_distance = hero.attack_range * hero.attack_range
    for _, enemy in ipairs(enemies) do
        if not enemy.dead then
            local dx, dy = enemy.x - self.x, enemy.y - self.y
            local distance = dx * dx + dy * dy
            if distance <= nearest_distance then
                target = enemy
                nearest_distance = distance
            end
        end
    end
    return target
end

function Player:update_attack(enemies, projectiles)
    local hero = self:get_active_hero()
    if not hero or not hero:can_attack() then return end

    local target = self:get_attack_target(enemies)
    if not target then return end

    projectiles[#projectiles + 1] = hero:attack(self.x, self.y, target.x, target.y)
end

function Player:update(dt, enemies, projectiles)
    self:update_dash(dt)
    self:update_switch(dt)
    self:update_heroes(dt)
    self:update_attack(enemies, projectiles)
end

function Player:keypressed(key, scancode)
    if (scancode or key) == "q" then self:start_switch() end
end

function Player:get_draw_size()
    if not self.switching then return self.size end

    if self.switch_time <= self.switch_shrink_end then
        return math.floor(self.size - 2 * self.switch_time / self.switch_shrink_end + 0.5)
    end

    if self.switch_time <= self.switch_pop_end then
        return math.floor(self.size - 2 + 3 *
            (self.switch_time - self.switch_shrink_end) /
            (self.switch_pop_end - self.switch_shrink_end) + 0.5)
    end

    return math.floor(self.size + 1 -
        (self.switch_time - self.switch_pop_end) /
        (self.switch_duration - self.switch_pop_end) + 0.5)
end

function Player:draw_rounded_square(x, y, size, color)
    graphics.rectangle(x, y, size, size - 2, nil, nil, color)
    graphics.rectangle(x, y, size - 2, size, nil, nil, color)
end

function Player:draw_core(size)
    local sx, sy = self:get_dash_scale()
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    if self.dashing then love.graphics.rotate(self.aim_r) end
    love.graphics.scale(sx, sy)
    self:draw_rounded_square(1, 1, size, self.shadow_color)
    self:draw_rounded_square(0, 0, size, self:get_color())
    love.graphics.pop()
end

function Player:get_dash_scale()
    if not self.dashing then return 1, 1 end

    if self.dash_time < self.dash_windup then
        local progress = self.dash_time / self.dash_windup
        return 1 - 0.35 * progress, 1 + 0.15 * progress
    end

    if self.dash_time < self.dash_windup + self.dash_travel then
        local progress = self:get_dash_travel_progress()
        local stretch = math.sin(progress * math.pi)
        return 0.65 + 0.35 * progress + 0.9 * stretch,
            1.15 - 0.15 * progress - 0.55 * stretch
    end

    local progress = (self.dash_time - self.dash_windup - self.dash_travel) / self.dash_land
    local pop = math.sin(progress * math.pi)
    return 1 + 0.2 * pop, 1 + 0.2 * pop
end

function Player:draw_dash_trail(size)
    if not self.dashing or self.dash_time <= self.dash_windup then return end

    local progress = self:get_dash_travel_progress()
    local land_progress = math.max(0,
        (self.dash_time - self.dash_windup - self.dash_travel) / self.dash_land)
    local fade = 1 - math.min(land_progress, 1)

    for index = 1, 2 do
        local trail_progress = ease_out_cubic(math.max(progress - index * 0.14, 0))
        local x = self.dash_start_x + (self.dash_target_x - self.dash_start_x) * trail_progress
        local y = self.dash_start_y + (self.dash_target_y - self.dash_start_y) * trail_progress

        love.graphics.push("all")
        love.graphics.translate(x, y)
        love.graphics.rotate(self.aim_r)
        love.graphics.scale(1.25, 0.6)
        self:draw_rounded_square(0, 0, size,
            color_with_alpha(self:get_color(), 0.18 * fade / index))
        love.graphics.pop()
    end
end

function Player:draw_aim_arrow()
    if self.dashing then return end
    local scale = 1 - 0.35 * self.dash_cooldown_time / self.dash_cooldown
    local x = self.x + math.cos(self.aim_r) * self.arrow_distance
    local y = self.y + math.sin(self.aim_r) * self.arrow_distance

    love.graphics.push("all")
    love.graphics.translate(x, y)
    love.graphics.rotate(self.aim_r)
    love.graphics.scale(scale, scale)
    graphics.polygon({4, 0, -3, -3, -1, 0, -3, 3}, self:get_color())
    love.graphics.pop()
end

function Player:draw()
    local size = self:get_draw_size()
    self:draw_dash_trail(size)
    self:draw_core(size)
    self:draw_aim_arrow()
end
