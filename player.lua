local PlayerDash = require("player.dash")
local PlayerHeroes = require("player.heroes")
local PlayerCombat = require("player.combat")
local PlayerRenderer = require("player.renderer")

Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)
Player:implement(PlayerDash)
Player:implement(PlayerHeroes)
Player:implement(PlayerCombat)
Player:implement(PlayerRenderer)

function Player:init(args)
    self:init_game_object(args)
    self:init_physics(args)
    self:init_unit(args)
    self.size = self.size or 7
    self.color = self.color or {250 / 255, 207 / 255, 0, 1}
    self.shadow_color = self.shadow_color or {0, 0, 0, 0.35}
    self:set_as_rectangle(self.size, self.size, "dynamic", "player")
    self:init_player_dash()
    self:init_player_heroes()
end

function Player:update(dt, enemies, projectiles)
    self:update_dash(dt)
    self:update_switch(dt)
    self:update_heroes(dt)
    self:update_attack(enemies, projectiles)
end

function Player:keypressed(key, scancode)
    if (scancode or key) == "q" then self:start_switch() end
end