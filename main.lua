gw, gh = 480, 270

require("engine.object")
require("engine.graphics.graphics")
require("engine.graphics.canvas")
require("engine.game.gameobject")
require("engine.game.physics")
require("engine.game.unit")
require("projectile")
require("hero")
require("player")

local player
local projectiles
local game_canvas
local ui_font
local colors = {
  background = {48 / 255, 48 / 255, 48 / 255, 1},
  background_offset = {46 / 255, 46 / 255, 46 / 255, 1},
  foreground = {218 / 255, 218 / 255, 218 / 255, 1},
  yellow = {250 / 255, 207 / 255, 0, 1},
  blue = {1 / 255, 155 / 255, 214 / 255, 1},
  red = {240 / 255, 79 / 255, 79 / 255, 1},
}

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setBackgroundColor(0, 0, 0, 1)
  love.graphics.setLineStyle("rough")

  ui_font = love.graphics.newFont("assets/fonts/BoiledPasta.ttf", 16)
  ui_font:setFilter("nearest", "nearest")
  love.graphics.setFont(ui_font)

  game_canvas = Canvas(gw, gh)
  projectiles = {}
  player = Player{
    x = 240,
    y = 135,
    speed = 120,
    heroes = {
      Hero{name = "SHOOTER", color = colors.yellow},
      Hero{name = "GUARD", color = colors.blue},
    },
  }
end

function love.update(dt)
  player:update(dt)

  for index = #projectiles, 1, -1 do
    projectiles[index]:update(dt)
    if projectiles[index].dead then table.remove(projectiles, index) end
  end
end

local function draw_background()
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
end

local function draw_ui()
  graphics.set_color(colors.foreground)
  local line_height = ui_font:getHeight() + 2
  love.graphics.print("HERO: " .. player:get_active_hero().name, 10, 9)
  love.graphics.print("MOVE: WASD", 10, 9 + line_height)
  if player:can_switch() then
    love.graphics.print("Q: READY", 10, 9 + line_height * 2)
  else
    love.graphics.print(string.format("Q: %.1f", player.switch_cooldown_time),
      10, 9 + line_height * 2)
  end
end

local function draw_game()
  draw_background()
  for _, projectile in ipairs(projectiles) do projectile:draw() end
  player:draw()
  draw_ui()
end

function love.draw()
  game_canvas:draw_to(draw_game, colors.background)
  game_canvas:draw_to_window()
end

function love.keypressed(key, scancode)
  player:keypressed(key, scancode)
  if key == "escape" then
    love.event.quit()
  end
end

function love.keyreleased(key, scancode)
  player:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end
  x, y = game_canvas:to_canvas_position(x, y)
  if not x then return end
  projectiles[#projectiles + 1] = player:shoot(x, y)
end

function love.focus(focused)
  if not focused then player:clear_input() end
end
