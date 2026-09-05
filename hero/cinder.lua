Cinder = Hero:extend()

function Cinder:init(args)
  self.name = "CINDER"
  self.attack_range = 160
  self.attack_interval = 0.6
  self.burning_attack_interval = 4.0
  self.projectile_speed = 160
  self.projectile_damage = 10
  Cinder.super.init(self, args)
end

function Cinder:get_attack_interval()
  if self.level >= 3 then return self.burning_attack_interval end
  return self.attack_interval
end

function Cinder:perform_attack(player, target, enemies, projectiles, effects)
  if self.level >= 3 then
    effects[#effects + 1] = BurningSquareArea{
      x = target.x,
      y = target.y,
      size = 96,
      rotation = player.aim_r or 0,
      color = self.color,
      damage = 2,
      duration = 3.0,
    }
    return true
  end

  if #projectiles >= player.max_projectiles then return false end

  projectiles[#projectiles + 1] = Projectile{
    x = player.x,
    y = player.y,
    r = math.atan2(target.y - player.y, target.x - player.x),
    speed = self.projectile_speed,
    damage = self.projectile_damage,
    color = self.color,
    effects = effects,
    pierce = self.level >= 2 and 2 or 0,
    damage_decay = 0.75,
  }
  return true
end
