Hero = Object:extend()

function Hero:init(args)
    self.name = args.name
    self.color = args.color
    self.projectile_speed = args.projectile_speed or 220
    self.projectile_damage = args.projectile_damage or 10
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
