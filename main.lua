gw, gh = 480, 270

require("engine.object")
require("engine.graphics.graphics")
require("engine.graphics.canvas")
require("engine.game.gameobject")
require("engine.game.physics")
require("engine.game.unit")
require("player")

local player
local game_canvas
local ui_font
local colors = {
  background = {48 / 255, 48 / 255, 48 / 255, 1},
  background_offset = {46 / 255, 46 / 255, 46 / 255, 1},
  foreground = {218 / 255, 218 / 255, 218 / 255, 1},
  yellow = {250 / 255, 207 / 255, 0, 1},
}

local target = {
  x = 360,
  y = 135,
  radius = 5,
}

local score = 0

local function placeTarget()
  local margin = target.radius + 10
  target.x = love.math.random(margin, gw - margin)
  target.y = love.math.random(margin, gh - margin)
end

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setBackgroundColor(0, 0, 0, 1)
  love.graphics.setLineStyle("rough")

  ui_font = love.graphics.newFont("assets/fonts/BoiledPasta.ttf", 16)
  ui_font:setFilter("nearest", "nearest")
  love.graphics.setFont(ui_font)

  game_canvas = Canvas(gw, gh)
  player = Player{
    x = 240,
    y = 135,
    speed = 120,
    color = colors.foreground,
  }

  placeTarget()
end

function love.update(dt)
  player:update(dt)

  if player:is_colliding_with_object(target) then
    score = score + 1
    placeTarget()
  end
end

local function draw_game()
  for column = 0, math.ceil(gw / 22) do
    for row = 0, math.ceil(gh / 22) do
      if (column + row) % 2 == 1 then
        graphics.rectangle2(
          column * 22,
          row * 22,
          22,
          22,
          nil,
          nil,
          colors.background_offset
        )
      end
    end
  end

  player:draw()

  graphics.set_color(colors.yellow)
  love.graphics.circle("fill", target.x, target.y, target.radius)
  love.graphics.circle("line", target.x, target.y, target.radius + 3)

  graphics.set_color(colors.foreground)
  local line_height = ui_font:getHeight() + 2
  love.graphics.print("Score: " .. score, 10, 9)
  love.graphics.print("Move: WASD / Arrow Keys", 10, 9 + line_height)
  love.graphics.print("Quit: Esc", 10, 9 + line_height * 2)
end

function love.draw()
  game_canvas:draw_to(draw_game, colors.background)
  game_canvas:draw_to_window()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
