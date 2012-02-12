local lg = love.graphics

local super = class("Shot", "Entity")

x,y = 0,0
angle = 0
spin = 0
speed = 300 -- movement speed in px/s
score = 0 -- bonus points for this shot

function __init(self, ...)
    super.__init(self, ...)

    self.dx = -math.sin(self.angle)
    self.dy = math.cos(self.angle)
end

function draw(self)
    lg.translate(self.x, self.y)
    lg.rotate(self.spin)

    -- draw a Steam gift
    lg.setColor(82, 82, 82)
    lg.rectangle("fill", -5, -5, 10, 10)
    lg.setColor(212, 208, 163)
    lg.rectangle("fill", -1, -5, 2, 10)
    lg.setLineWidth(2)
    lg.line(0, -5, -3, -2)
    lg.line(0, -5, 3, -2)
    lg.line(0, -5, -2, -6)
    lg.line(0, -5, 2, -6)

    -- pop
    lg.rotate(-self.spin)
    lg.translate(-self.x, -self.y)
end

function update(self, dt)
    local bound

    self.x,self.y,bound = love.bound(
        self.x + (self.dx * self.speed * dt),
        self.y + (self.dy * self.speed * dt),
        10)

    self.spin = self.spin + 4 * math.pi * dt

    -- if we hit a target, handle that
    for obj in love.objects() do
        if obj:isInstanceOf("Target") and obj:distanceTo(self) <= 8 then
            love.removeObject(self)
            obj:die(self.score)
            return
        end
    end

    -- if we go out of bounds, destroy self
    if bound then
        love.removeObject(self)
    end
end
