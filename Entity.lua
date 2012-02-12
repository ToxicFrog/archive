local super = class("Entity", "Object")

x,y = 0,0

function angleTo(self, x, y)
    if type(x) ~= "number" then
        return self:angleTo(x.x, x.y)
    end

    local angle = math.atan((self.x - x)/(y - self.y))
    if y < self.y then
        angle = angle + math.pi
    end

    return angle
end

function distanceTo(self, x, y)
    if type(x) ~= "number" then
        return self:distanceTo(x.x, x.y)
    end

    return ((self.x - x)^2 + (self.y - y)^2)^0.5
end
