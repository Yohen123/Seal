Canvas = Object:extend()

local function begin_canvas(canvas)
  local previous_canvas = love.graphics.getCanvas()
  love.graphics.push("all")
  love.graphics.setCanvas(canvas)
  love.graphics.origin()
  return previous_canvas
end

local function end_canvas(previous_canvas)
  love.graphics.setCanvas(previous_canvas)
  love.graphics.pop()
end

local function clear_canvas(color)
  color = color or {0, 0, 0, 0}
  love.graphics.clear(color[1] or 0, color[2] or 0, color[3] or 0, color[4] or 1)
end

local function get_scale(width, height)
  local window_width, window_height = love.graphics.getDimensions()
  local scale = math.min(window_width / width, window_height / height)
  return scale >= 1 and math.floor(scale) or scale
end

local function get_offset(width, height, scale)
  local window_width, window_height = love.graphics.getDimensions()
  local x = math.floor((window_width - width * scale) / 2)
  local y = math.floor((window_height - height * scale) / 2)
  return x, y
end

local function draw_canvas(canvas, x, y, scale)
  love.graphics.origin()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(canvas, x, y, 0, scale, scale)
end

function Canvas:init(width, height)
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(width, height, {msaa = 0})
  self.canvas:setFilter("nearest", "nearest")
end

function Canvas:draw_to(action, clear_color)
  local previous_canvas = begin_canvas(self.canvas)
  clear_canvas(clear_color)
  action()
  end_canvas(previous_canvas)
  return self
end

function Canvas:get_window_transform()
  local scale = get_scale(self.width, self.height)
  local x, y = get_offset(self.width, self.height, scale)
  return x, y, scale
end

function Canvas:to_canvas_position(x, y)
  local offset_x, offset_y, scale = self:get_window_transform()
  x = (x - offset_x) / scale
  y = (y - offset_y) / scale

  if x < 0 or x > self.width or y < 0 or y > self.height then return end
  return x, y
end

function Canvas:draw_to_window()
  local x, y, scale = self:get_window_transform()

  love.graphics.push("all")
  draw_canvas(self.canvas, x, y, scale)
  love.graphics.pop()
  return self
end
