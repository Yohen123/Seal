Hero = Object:extend()

function Hero:init(args)
  self.name = args.name
  self.color = args.color
  self.projectile_speed = args.projectile_speed or 160
  self.projectile_damage = args.projectile_damage or 10
  self.attack_range = args.attack_range or 160
  self.attack_interval = args.attack_interval or 0.6
  self.attack_cooldown_time = 0
end

function Hero:update(dt)
  self.attack_cooldown_time = math.max(self.attack_cooldown_time - dt, 0)
end

function Hero:can_attack()
  return self.attack_cooldown_time == 0
end

function Hero:attack(x, y, target_x, target_y)
  if not self:can_attack() then return end
  self.attack_cooldown_time = self.attack_interval
  return self:shoot(x, y, target_x, target_y)
end

function Hero:shoot(x, y, target_x, target_y)
  return Projectile{
    x = x,
    y = y,
    r = math.atan2(target_y - y, target_x - x),
    speed = self.projectile_speed,
    damage = self.projectile_damage,
    color = self.color,
  }
end
