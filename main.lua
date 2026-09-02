local player = {
  x = 400,
  y = 300,
  radius = 18,
  speed = 240,
}

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
  love.graphics.setBackgroundColor(0.06, 0.07, 0.09)
  love.graphics.setLineStyle("rough")
  placeTarget()
end

function love.update(dt)
  local dx, dy = 0, 0

  if love.keyboard.isDown("left", "a") then dx = dx - 1 end
  if love.keyboard.isDown("right", "d") then dx = dx + 1 end
  if love.keyboard.isDown("up", "w") then dy = dy - 1 end
  if love.keyboard.isDown("down", "s") then dy = dy + 1 end

  local length = math.sqrt(dx * dx + dy * dy)
  if length > 0 then
    dx, dy = dx / length, dy / length
  end

  player.x = player.x + dx * player.speed * dt
  player.y = player.y + dy * player.speed * dt

  local width, height = love.graphics.getDimensions()
  player.x = math.max(player.radius, math.min(width - player.radius, player.x))
  player.y = math.max(player.radius, math.min(height - player.radius, player.y))

  local tx, ty = target.x - player.x, target.y - player.y
  local collisionDistance = player.radius + target.radius
  if tx * tx + ty * ty <= collisionDistance * collisionDistance then
    score = score + 1
    placeTarget()
  end
end

function love.draw()
  love.graphics.setColor(0.35, 0.82, 0.96)
  love.graphics.circle("fill", player.x, player.y, player.radius)

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
