GameObject = Object:extend()

local next_game_object_id = 0

function GameObject:init_game_object(args)
  for key, value in pairs(args or {}) do
    self[key] = value
  end

  self.x = self.x or 0
  self.y = self.y or 0
  self.r = self.r or 0
  self.sx = self.sx or 1
  self.sy = self.sy or 1
  self.dead = self.dead or false

  if self.id == nil then
    next_game_object_id = next_game_object_id + 1
    self.id = next_game_object_id
  end

  return self
end

function GameObject:update_game_object(dt)
  if self.update_physics then
    self:update_physics(dt)
  end

  return self
end

function GameObject:draw_game_object()
  if self.draw_physics then
    self:draw_physics()
  end

  return self
end

function GameObject:mark_dead()
  self.dead = true
  return self
end
