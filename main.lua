require "util.init"
local grid = require "grid"
local lg = love.graphics

local hidden
local puzzle = grid.new(3, 3, "empty")
local target = grid.new(3, 3, "empty")

local key = {}

local function newpuzzle()
    print("newpuzzle")
    local pieces = math.random(1,5)
    
    target = grid.new(3, 3, "empty")
    
    for i=1,pieces do
        local x,y
        repeat x,y = math.random(1,3),math.random(1,3) until target(x,y) == "empty"
        target:set(x, y, math.random(1,2) == 1 and "red" or "blue")
    end
    
    local dx,dy,dr
    repeat
        dx,dy,dr = math.random(1,3),math.random(1,3),math.random(1,4)
    until dx ~= 3 or dy ~= 3 or dr ~= 4
    
    puzzle = target:translate(dx, dy):rotate(dr)
end

local flash_timer = 0

local function update(op, ...)
    puzzle = puzzle[op](puzzle, ...)
    
    if puzzle == target then
        flash_timer = 3
    end
end

local function updater(op, x, y)
    return function() return update(op, x, y) end
end

do -- keybindings
    key.left    = updater("translate", -1, 0)
    key.right   = updater("translate", 1, 0)
    key.up      = updater("translate", 0, -1)
    key.down    = updater("translate", 0, 1)
    key.z       = updater("rotate", -1)
    key.x       = updater("rotate", 1)
    
    key.s       = newpuzzle
    
    function key.h()
        if hidden then
            puzzle,hidden = hidden,nil
        else
            hidden,puzzle = puzzle,grid.new(3, 3, "empty")
        end
    end
    
    function key.f11()
        love.graphics.toggleFullscreen()
    end
    
    function key.q()
        love.event.push "q"
    end
end

function love.load()
    lg.setBackgroundColor(0, 0, 0)
    lg.setLineWidth(4)
    math.randomseed(os.time())
    
    newpuzzle()
end

function love.draw()
    local puzzle_colours = {
        empty   = { 0, 0, 0 };
        red     = { 255, 64, 64 };
        blue    = { 64, 64, 255 };
    }
    
    local target_colours = {
        empty   = { 32, 32, 32 };
        red     = { 255, 0, 0 };
        blue    = { 0, 0, 255 };
    }
    
    local flash_colours = {
        empty   = { 0, 0, 0 };
        red     = { 255, 0, 0 };
        blue    = { 0, 0, 255 };
    }
    
    local function drawer(colours, style)
        return function(x, y, value)
            lg.setColor(unpack(colours[value]))
            lg.rectangle(style, (x-1) * 110 + 10, (y-1) * 110 + 10, 100, 100)
        end
    end
    
    if flash_timer > 0 then
        puzzle:foreach(drawer(flash_colours, "fill"))
        target:foreach(drawer(target_colours, "line"))
    else
        puzzle:foreach(drawer(puzzle_colours, "fill"))
        target:foreach(drawer(target_colours, "line"))
    end
end

function love.update(dt)
    if flash_timer > 0 and flash_timer < dt then
        newpuzzle()
    end
    
    flash_timer = math.max(0, flash_timer - dt)
end

function love.keypressed(keyname, unicode)
    if flash_timer > 0 then return end
    
    if key[keyname] then
        key[keyname](keyname, unicode)
    end
end
