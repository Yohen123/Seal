function Player:init_player_dash()
  self.aim_r = self.aim_r or 0
  self.arrow_distance = self.arrow_distance or 13
  self.dash_distance = self.dash_distance or 48
  self.dash_windup = self.dash_windup or 0.05
  self.dash_travel = self.dash_travel or 0.08
  self.dash_land = self.dash_land or 0.10
  self.dash_duration = self.dash_windup + self.dash_travel + self.dash_land
  self.dash_cooldown = self.dash_cooldown or 0.5
  self.dash_cooldown_time = 0
  self.dashing = false
  self.dash_time = 0
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

function Player:get_dash_eased_progress()
  local progress = self:get_dash_travel_progress()
  return 1 - (1 - progress) ^ 3
end

function Player:update_dash(dt)
  self.dash_cooldown_time = math.max(self.dash_cooldown_time - dt, 0)
  if not self.dashing then return end

  self.dash_time = math.min(self.dash_time + dt, self.dash_duration)
  local progress = self:get_dash_eased_progress()
  self.x = self.dash_start_x + (self.dash_target_x - self.dash_start_x) * progress
  self.y = self.dash_start_y + (self.dash_target_y - self.dash_start_y) * progress
  if self.dash_time == self.dash_duration then self.dashing = false end
end
