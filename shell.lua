Shell = Object:extend()
Shell:implement(GameObject)
Shell:implement(Physics)
Shell:implement(Unit)

local white = {1, 1, 1, 1}

function Shell:init(args)
    self:init_game_object(args)
    self:init_physics(args)
    self:init_unit(args)
    self:set_as_rectangle(self.width or 19, self.height or 19, "dynamic", "shell")
    self.color = self.color or white
    self.accent_color = self.accent_color or white
    self.shadow_color = self.shadow_color or {0, 0, 0, 0.35}
    self.effect_duration = 0.22
    self.effect_time = 0
    self.controlled = false
end

function Shell:is_available()
    return not self.controlled and not self.dead
end

function Shell:set_controlled(value)
    self.controlled = value
    if not value then self:stop() end
end

function Shell:start_possession_effect()
    self.effect_time = self.effect_duration
    self:set_controlled(true)
end

function Shell:set_move_direction(dx, dy)
    self:set_velocity(dx * self.mvspd, dy * self.mvspd)
end

function Shell:update(dt)
    self.effect_time = math.max(0, self.effect_time - dt)
    self:update_game_object(dt)
    self:keep_inside(0, 0, gw, gh)
end

function Shell:get_effect_progress()
    if self.effect_time == 0 then return 1 end
    return 1 - self.effect_time / self.effect_duration
end

function Shell:get_effect_scale()
    local progress = self:get_effect_progress()
    return 1 + 0.35 * math.sin(progress * math.pi)
end

function Shell:draw_target()
    local pulse = 2 + math.sin(love.timer.getTime() * 8)
    graphics.rectangle(self.x, self.y, self.width + 5 + pulse,
        self.height + 5 + pulse, 4, 4, self.accent_color, 1)
end

function Shell:draw_body(scale)
    local color = self:get_effect_progress() < 0.25 and white or self.color
    graphics.rectangle(self.x + 1.5, self.y + 1.5,
        self.width * scale, self.height * scale, 4, 4, self.shadow_color)
    graphics.rectangle(self.x, self.y,
        self.width * scale, self.height * scale, 4, 4, color)
end

function Shell:draw_control_marker()
    if not self.controlled then return end
    graphics.rectangle(self.x, self.y, 5, 5, 2, 2, self.accent_color)
end

function Shell:draw(targeted)
    if targeted then self:draw_target() end
    self:draw_body(self:get_effect_scale())
    self:draw_control_marker()
end
