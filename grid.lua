local grid = {}

local mt = {
    __index = grid;
}

-- equivalent to value % max, except with a range of 1..max rather than 0..max-1
local function wrap(max, value)
    return (value - 1) % max + 1
end

function mt:__call(x, y)
    x = wrap(self.w, x)
    y = wrap(self.h, y)
    return self[x][y]
end

function mt:__eq(other)
    if other.w ~= self.w or other.h ~= self.h then return false end
    
    for x,y,value in self:cells() do
        if value ~= other(x,y) then return false end
    end
    
    return true
end

function grid.new(w, h, value)
    local self = setmetatable({}, mt)
    
    self.w,self.h = w,h
    
    for x=1,w do
        self[x] = {}
        for y=1,h do
            self[x][y] = value
        end
    end
    
    return self
end

function grid:set(x,y,value)
    self[wrap(self.w, x)][wrap(self.h, y)] = value
end

function grid:cells()
    return coroutine.wrap(function()
        for x=1,self.w do
            for y=1,self.h do
                coroutine.yield(x, y, self(x,y))
            end
        end
    end)
end

function grid:foreach(f)
    for x,y,value in self:cells() do f(x,y,value) end
end

function grid:mapxy(f)
    local new = grid.new(self.w, self.h)
    
    for x,y in self:cells() do
        local newx,newy = f(x,y)
        new:set(newx, newy, self(x,y))
    end
    
    return new
end

function grid:translate(dx, dy)
    return self:mapxy(function(x,y)
        return x + dx, y + dy
    end)
end

function grid:rotate(turns)
    if turns > 0 then -- clockwise
        return self:mapxy(function(x,y)
            return self.w - y +1, x
        end):rotate(turns - 1)
    elseif turns < 0 then -- counterclockwise
        return self:mapxy(function(x,y)
            return y, self.h - x +1
        end):rotate(turns + 1)
    else
        return self
    end
end


return grid
