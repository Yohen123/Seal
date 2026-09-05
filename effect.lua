HitParticle = Object:extend()
HitParticle:implement(GameObject)

local function cubic_in_out(t)
  t = t * 2
  if t < 1 then return 0.5 * t * t * t end
  t = t - 2
  return 0.5 * (t * t * t + 2)
end

local function remap(value, in_min, in_max, out_min, out_max)
  local t = (value - in_min) / (in_max - in_min)
  t = math.max(0, math.min(1, t))
  return out_min + (out_max - out_min) * t
end

local function draw_seal_area_frame(x, y, size, color, fill_color)
  local half = size / 2
  local corner = size * 0.16
  local x1, y1 = x - half, y - half
  local x2, y2 = x + half, y + half
  local line_width = remap(size, 64, 160, 2, 3)

  graphics.rectangle(x, y, size, size, nil, nil, fill_color)
  graphics.polyline(color, line_width, x1, y1 + corner, x1, y1, x1 + corner, y1)
  graphics.polyline(color, line_width, x2 - corner, y1, x2, y1, x2, y1 + corner)
  graphics.polyline(color, line_width, x2, y2 - corner, x2, y2, x2 - corner, y2)
  graphics.polyline(color, line_width, x1 + corner, y2, x1, y2, x1, y2 - corner)
end

function HitParticle:init(args)
  self:init_game_object(args)
  self.speed = self.speed or 50 + love.math.random() * 100
  self.r = args.r or love.math.random() * 2 * math.pi
  self.duration = self.duration or 0.2 + love.math.random() * 0.4
  self.width = self.width or 3.5 + love.math.random() * 3.5
  self.height = self.height or self.width / 2
  self.start_speed = self.speed
  self.start_width = self.width
  self.start_height = self.height
  self.time = 0
end

function HitParticle:update(dt)
  self.time = math.min(self.time + dt, self.duration)
  local progress = cubic_in_out(self.time / self.duration)
  self.width = self.start_width + (2 - self.start_width) * progress
  self.height = self.start_height + (2 - self.start_height) * progress
  self.speed = self.start_speed * (1 - progress)
  self.x = self.x + self.speed * math.cos(self.r) * dt
  self.y = self.y + self.speed * math.sin(self.r) * dt
  if self.time == self.duration then self.dead = true end
end

function HitParticle:draw()
  love.graphics.push("all")
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.r)
  graphics.rectangle(0, 0, self.width, self.height, 2, 2, self.color)
  love.graphics.pop()
end

HitCircle = Object:extend()
HitCircle:implement(GameObject)

function HitCircle:init(args)
  self:init_game_object(args)
  self.radius = self.radius or 12
  self.start_radius = self.radius
  self.duration = self.duration or 0.05
  self.time = 0
end

function HitCircle:update(dt)
  self.time = math.min(self.time + dt, self.duration)
  self.radius = self.start_radius * (1 - cubic_in_out(self.time / self.duration))
  if self.time >= self.duration / 2 then self.color = self.target_color end
  if self.time == self.duration then self.dead = true end
end

function HitCircle:draw()
  graphics.circle(self.x, self.y, self.radius, self.color)
end

AreaPulse = Object:extend()
AreaPulse:implement(GameObject)

function AreaPulse:init(args)
  self:init_game_object(args)
  self.radius = self.radius or 48
  self.duration = self.duration or 0.2
  self.line_width = self.line_width or 2
  self.time = 0
end

function AreaPulse:update(dt)
  self.time = math.min(self.time + dt, self.duration)
  if self.time == self.duration then self.dead = true end
end

function AreaPulse:draw()
  local progress = cubic_in_out(self.time / self.duration)
  graphics.circle(self.x, self.y, self.radius * progress,
    graphics.color_with_alpha(self.color, 1 - progress), self.line_width)
end

BlockBurstEffect = Object:extend()
BlockBurstEffect:implement(GameObject)

function BlockBurstEffect:init(args)
  self:init_game_object(args)
  self.target_size = self.size or self.radius or 28
  self.rotation = self.rotation or love.math.random() * math.pi
  self.fill_alpha = self.fill_alpha or 0.08
  self.flash_duration = 0.12
  self.grow_duration = 0.08
  self.blink_interval = 0.06
  self.blink_count = 4
  self.duration = self.duration or self.flash_duration + self.blink_interval * self.blink_count
  self.size = 0
  self.time = 0
end

function BlockBurstEffect:update(dt)
  self.time = math.min(self.time + dt, self.duration)
  self.size = self.target_size * cubic_in_out(math.min(self.time / self.grow_duration, 1))

  if self.time == self.duration then self.dead = true end
end

function BlockBurstEffect:draw()
  if self.time >= self.flash_duration then
    local blink_index = math.floor((self.time - self.flash_duration) / self.blink_interval)
    if blink_index % 2 == 1 then return end
  end

  local color = self.time < self.flash_duration and {1, 1, 1, 1} or self.color
  local fill_color = graphics.color_with_alpha(self.color, self.fill_alpha)

  love.graphics.push("all")
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.rotation)
  draw_seal_area_frame(0, 0, self.size, color, fill_color)
  love.graphics.pop()
end

BurningSquareArea = Object:extend()
BurningSquareArea:implement(GameObject)

function BurningSquareArea:init(args)
  self:init_game_object(args)
  self.size = self.size or 72
  self.duration = self.duration or 1.4
  self.tick_interval = self.tick_interval or 0.25
  self.damage = self.damage or 2
  self.rotation = self.rotation or 0
  self.fill_alpha = self.fill_alpha or 0.065
  self.entry_blink_duration = 0.16
  self.exit_blink_duration = 0.32
  self.blink_interval = 0.08
  self.time = 0
  self.tick_time = 0
end

function BurningSquareArea:update(dt, enemies)
  self.time = math.min(self.time + dt, self.duration)
  self.tick_time = self.tick_time - dt

  if self.tick_time <= 0 then
    self.tick_time = self.tick_interval
    self:damage_enemies(enemies)
  end

  if self.time == self.duration then self.dead = true end
end

function BurningSquareArea:contains(enemy)
  local dx, dy = enemy.x - self.x, enemy.y - self.y
  local c, s = math.cos(-self.rotation), math.sin(-self.rotation)
  local local_x = dx * c - dy * s
  local local_y = dx * s + dy * c
  return math.abs(local_x) <= self.size / 2 and math.abs(local_y) <= self.size / 2
end

function BurningSquareArea:damage_enemies(enemies)
  for _, enemy in ipairs(enemies or {}) do
    if not enemy.dead and self:contains(enemy) then enemy:hit(self.damage) end
  end
end

function BurningSquareArea:draw()
  local progress = self.time / self.duration
  local remaining = self.duration - self.time
  local entry_blinking = self.time < self.entry_blink_duration
  local exit_blinking = remaining <= self.exit_blink_duration

  if entry_blinking then
    local blink_index = math.floor(self.time / self.blink_interval)
    if blink_index % 2 == 1 then return end
  elseif exit_blinking then
    local blink_index = math.floor((self.exit_blink_duration - remaining) / self.blink_interval)
    if blink_index % 2 == 1 then return end
  end

  local flashing = entry_blinking or exit_blinking
  local alpha = math.max(1 - progress * 0.45, 0)
  local heat = 0.55 + 0.45 * math.sin(self.time * 7) ^ 2
  local color = flashing and {1, 1, 1, 1} or
    graphics.color_with_alpha(self.color, alpha)
  local fill_color = graphics.color_with_alpha(self.color, self.fill_alpha * heat)

  love.graphics.push("all")
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.rotation)
  draw_seal_area_frame(0, 0, self.size, color, fill_color)
  love.graphics.pop()
end
