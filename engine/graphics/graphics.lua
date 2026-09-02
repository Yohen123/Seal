graphics = {}

local function set_color(color)
    love.graphics.setColor(
        color.r or color[1] or 1,
        color.g or color[2] or 1,
        color.b or color[3] or 1,
        color.a or color[4] or 1
    )
end

function graphics.set_color(color)
    set_color(color)
end

function graphics.shape(shape, color, line_width, ...)
    local r, g, b, a = love.graphics.getColor()
    local previous_line_width = love.graphics.getLineWidth()

    if color then
        set_color(color)
    end

    if line_width then
        love.graphics.setLineWidth(line_width)
        love.graphics[shape]("line", ...)
    elseif color then
        love.graphics[shape]("fill", ...)
    else
        love.graphics[shape]("line", ...)
    end

    love.graphics.setLineWidth(previous_line_width)
    love.graphics.setColor(r, g, b, a)
end

function graphics.rectangle(x, y, width, height, rx, ry, color, line_width)
    graphics.shape(
        "rectangle",
        color,
        line_width,
        x - width / 2,
        y - height / 2,
        width,
        height,
        rx,
        ry
    )
end

function graphics.rectangle2(x, y, width, height, rx, ry, color, line_width)
    graphics.shape("rectangle", color, line_width, x, y, width, height, rx, ry)
end

function graphics.line(x1, y1, x2, y2, color, line_width)
    local r, g, b, a = love.graphics.getColor()
    local previous_line_width = love.graphics.getLineWidth()

    if color then
        set_color(color)
    end

    if line_width then
        love.graphics.setLineWidth(line_width)
    end

    love.graphics.line(x1, y1, x2, y2)
    love.graphics.setLineWidth(previous_line_width)
    love.graphics.setColor(r, g, b, a)
end
