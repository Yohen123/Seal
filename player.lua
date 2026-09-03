Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)

function Player:init(args)
    self:init_game_object(args)
    self:init_physics(args)
    self:init_unit(args)
    self.mvspd = self.mvspd or self.speed or 240
    self.size = self.size or 7
    self:set_as_rectangle(self.size, self.size, "dynamic", "player")
    self.color = self.color or {250 / 255, 207 / 255, 0, 1}
    self.shadow_color = self.shadow_color or {0, 0, 0, 0.35}
    self.heroes = self.heroes or {}
    self.active_hero_index = 1
    self.keys_down = {}
    self.switching = false
    self.switch_time = 0
    self.switch_cooldown = 2
    self.switch_cooldown_time = 0
    self.switch_shrink_end = 0.06
    self.switch_pop_end = 0.14
    self.switch_duration = 0.20
end

function Player:is_held(...)
    for _, key in ipairs({...}) do
        if self.keys_down[key] then return true end
    end
    return false
end

function Player:input_direction()
    local dx, dy = 0, 0
    if self:is_held("left", "a") then dx = dx - 1 end
    if self:is_held("right", "d") then dx = dx + 1 end
    if self:is_held("up", "w") then dy = dy - 1 end
    if self:is_held("down", "s") then dy = dy + 1 end
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then return dx / length, dy / length end
    return 0, 0
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

function Player:update_movement(dt)
    local dx, dy = self:input_direction()
    self:set_velocity(dx * self.mvspd, dy * self.mvspd)
    self:update_game_object(dt)
    self:keep_inside(0, 0, gw, gh)
end

function Player:update(dt)
    self:update_movement(dt)
    self:update_switch(dt)
end

function Player:shoot(x, y)
    if not self:get_active_hero() then return end
    return self:get_active_hero():shoot(self.x, self.y, x, y)
end

function Player:keypressed(key, scancode)
    self.keys_down[scancode or key] = true
    if (scancode or key) == "q" then self:start_switch() end
end

function Player:keyreleased(key, scancode)
    self.keys_down[scancode or key] = nil
end

function Player:clear_input()
    self.keys_down = {}
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
    self:draw_rounded_square(self.x + 1, self.y + 1, size, self.shadow_color)
    self:draw_rounded_square(self.x, self.y, size, self:get_color())
end

function Player:draw()
    self:draw_core(self:get_draw_size())
end
