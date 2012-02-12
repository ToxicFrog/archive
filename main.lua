require "Object"

local tank
local objects

love.score = 0

function love.load()
    tank = new "Tank" { x = 400, y = 300 }
    objects = {}

    love.tank = tank

    objects[tank] = true

    love.graphics.setBackgroundColor(220,220,240)

    math.randomseed(os.time())
end

function love.draw()
    for object in pairs(objects) do
        object:draw()
    end

    -- draw score
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(tostring(love.score), 10, 10)
end

local deferred = {}
function love.update(dt)
    for object in pairs(objects) do
        object:update(dt)
    end
    while #deferred > 0 do
        table.remove(deferred, 1)()
    end
end

function love.defer(f)
    table.insert(deferred, f)
end

function love.mousepressed(x, y, button)
    tank:fireAt(x, y)
end

function love.keypressed(key, unicode)
    if key == "f11" then
        love.graphics.toggleFullscreen()
    elseif key == "q" then
        love.event.push "q"
    end
end

function love.addObject(obj)
    objects[obj] = true
end

function love.removeObject(obj)
    objects[obj] = nil
end

function love.bound(x, y, tolerance)
    local maxx,maxy = love.graphics.getWidth() + tolerance, love.graphics.getHeight() + tolerance
    local minx,miny = 0 - tolerance, 0 - tolerance

    local newx = math.min(maxx, math.max(minx, x))
    local newy = math.min(maxy, math.max(miny, y))

    return newx,newy,(newx ~= x) or (newy ~= y)
end

function love.objects()
    return pairs(objects)
end
