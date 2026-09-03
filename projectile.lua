Projectile = Object:extend()
Projectile:implement(GameObject)
Projectile:implement(Physics)

function Projectile:init(args)
    self:init_game_object(args)
    self:init_physics(args)
    self.speed = self.speed or 220
    self.width = self.width or 6
    self.height = self.height or 2
    self.color = self.color or {1, 1, 1, 1}
    self:set_as_rectangle(self.width, self.height, "dynamic", "projectile")
    self:set_velocity(self.speed * math.cos(self.r), self.speed * math.sin(self.r))
end

function Projectile:update(dt)
    self:update_game_object(dt)

    if self.x < -self.width or self.x > gw + self.width or
        self.y < -self.width or self.y > gh + self.width then
        self.dead = true
    end
end

function Projectile:draw()
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.r)
    graphics.rectangle(0, 0, self.width, self.height, 1, 1, self.color)
    love.graphics.pop()
end
