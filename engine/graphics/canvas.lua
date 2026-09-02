Canvas = Object:extend()

function Canvas:init(width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height, {msaa = 0})
    self.canvas:setFilter("nearest", "nearest")
end

function Canvas:draw_to(action, clear_color)
    local previous_canvas = love.graphics.getCanvas()

    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()

    if clear_color then
        love.graphics.clear(
            clear_color[1] or 0,
            clear_color[2] or 0,
            clear_color[3] or 0,
            clear_color[4] or 1
        )
    else
        love.graphics.clear(0, 0, 0, 0)
    end

    action()

    love.graphics.setCanvas(previous_canvas)
    love.graphics.pop()
    return self
end

function Canvas:get_window_transform()
    local window_width, window_height = love.graphics.getDimensions()
    local scale = math.floor(math.min(
        window_width / self.width,
        window_height / self.height
    ))

    if scale < 1 then
        scale = math.min(
            window_width / self.width,
            window_height / self.height
        )
    end

    local x = math.floor((window_width - self.width * scale) / 2)
    local y = math.floor((window_height - self.height * scale) / 2)
    return x, y, scale
end

function Canvas:draw_to_window()
    local x, y, scale = self:get_window_transform()

    love.graphics.push("all")
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.canvas, x, y, 0, scale, scale)
    love.graphics.pop()
    return self
end
