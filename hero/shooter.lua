Shooter = Hero:extend()

function Shooter:init(args)
  self.name = "SHOOTER"
  self.attack_range = 160
  self.attack_interval = 0.6
  self.projectile_speed = 160
  self.projectile_damage = 10
  Shooter.super.init(self, args)
end

function Shooter:perform_attack(player, target, enemies, projectiles)
  if #projectiles >= player.max_projectiles then return false end

  projectiles[#projectiles + 1] = Projectile{
    x = player.x,
    y = player.y,
    r = math.atan2(target.y - player.y, target.x - player.x),
    speed = self.projectile_speed,
    damage = self.projectile_damage,
    color = self.color,
  }
  return true
end
