local PlayerCombat = {}

function PlayerCombat:get_attack_target(enemies)
    local hero = self:get_active_hero()
    if not hero then return end

    local target
    local nearest_distance = hero.attack_range * hero.attack_range
    for _, enemy in ipairs(enemies) do
        if not enemy.dead then
            local dx, dy = enemy.x - self.x, enemy.y - self.y
            local distance = dx * dx + dy * dy
            if distance <= nearest_distance then
                target = enemy
                nearest_distance = distance
            end
        end
    end
    return target
end

function PlayerCombat:update_attack(enemies, projectiles)
    local hero = self:get_active_hero()
    if not hero or not hero:can_attack() then return end

    local target = self:get_attack_target(enemies)
    if not target then return end
    projectiles[#projectiles + 1] = hero:attack(self.x, self.y, target.x, target.y)
end

return PlayerCombat
