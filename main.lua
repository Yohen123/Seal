require("engine.object")
require("engine.game.gameobject")
require("engine.game.physics")
require("engine.game.unit")
require("player")

local player

local target = {
  x = 600,
  y = 300,
  radius = 10,
}

local score = 0

local function placeTarget()
  local margin = target.radius + 20
  target.x = love.math.random(margin, love.graphics.getWidth() - margin)
  target.y = love.math.random(margin, love.graphics.getHeight() - margin)
end

function love.load()
  player = Player{
    x = 400,
    y = 300,
    radius = 18,
    speed = 240,
  }

  love.graphics.setBackgroundColor(0.06, 0.07, 0.09)
  love.graphics.setLineStyle("rough")
  placeTarget()
end

function love.update(dt)
  player:update(dt)

  if player:is_colliding_with_object(target) then
    score = score + 1
    placeTarget()
  end
end

function love.draw()
  player:draw()

  love.graphics.setColor(1.0, 0.78, 0.25)
  love.graphics.circle("fill", target.x, target.y, target.radius)
  love.graphics.circle("line", target.x, target.y, target.radius + 5)

  love.graphics.setColor(0.92, 0.94, 0.97)
  love.graphics.print("Score: " .. score, 20, 18)
  love.graphics.print("Move: WASD / Arrow Keys", 20, 42)
  love.graphics.print("Quit: Esc", 20, 64)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
