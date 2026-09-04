Guard = Hero:extend()

function Guard:init(args)
  self.name = "GUARD"
  self.attack_range = 48
  self.attack_interval = 1
  self.attack_damage = 6
  Guard.super.init(self, args)
end

function Guard:perform_attack(player, target, enemies, projectiles, effects)
  local hit_count = 0
  local range_squared = self.attack_range * self.attack_range
  for _, enemy in ipairs(enemies) do
    local dx, dy = enemy.x - player.x, enemy.y - player.y
    if not enemy.dead and dx * dx + dy * dy <= range_squared then
      enemy:hit(self.attack_damage)
      hit_count = hit_count + 1
    end
  end
  if hit_count == 0 then return false end

  effects[#effects + 1] = AreaPulse{
    x = player.x,
    y = player.y,
    radius = self.attack_range,
    color = self.color,
  }
  return true
end
