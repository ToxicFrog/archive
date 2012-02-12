local lg = love.graphics

class("Tank", "Entity")

x,y = 0,0
turret = 0
chassis = 0
speed = 60 -- movement speed in px/s
heat = 0
cooldown = 1 -- cooldown rate in heat/s
spawn = 1

function draw(self)
    lg.translate(self.x, self.y)

    -- draw chassis
    lg.rotate(self.chassis)
    lg.setLineWidth(2)
--    lg.setColor(134, 143, 184) -- treads
--    lg.rectangle("fill", -12, -17, 4, 30)
    lg.setColor(0, 0, 0) -- outline
    lg.rectangle("fill", -10, -18, 20, 28)
    lg.setColor(84, 150, 184) -- body
    lg.rectangle("fill", -9, -17, 18, 26)
    lg.setColor(0, 0, 0)
    lg.rectangle("fill", -6, -15, 12, 6)
    lg.setColor(84, 150, 184) -- body
    lg.rectangle("fill", -5, -14, 10, 4)
    lg.rotate(-self.chassis)

    -- draw turret
    lg.rotate(self.turret)

    lg.setLineWidth(5)
    lg.setColor(0, 0, 0)
    lg.circle("fill", 0, 0, 6)
    lg.line(0, 0, 0, 12)

    lg.setColor(84, 150, 184)
    lg.setLineWidth(3)
    lg.circle("fill", 0, 0, 5)
    lg.line(0, 0, 0, 11)

    lg.rotate(-self.turret)

    -- pop
    lg.translate(-self.x, -self.y)
end

function update(self, dt)
    -- aim turret
    self:aimTowards(love.mouse.getPosition())

    -- cool down
    if self.heat > 0 then
        self.heat = math.max(0, self.heat - self.cooldown)
    end

    -- move
    local dx =
        (love.keyboard.isDown("a") and -1 or 0)
        + (love.keyboard.isDown("d") and 1 or 0)
    local dy =
        (love.keyboard.isDown("w") and -1 or 0)
        + (love.keyboard.isDown("s") and 1 or 0)

    if dx ~= 0 or dy ~= 0 then
        self:turnTowards(self.x + dx, self.y + dy)
    end

    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.5^0.5
        dy = dy * 0.5^0.5
    end

    self.x, self.y = love.bound(
        self.x + (dx * self.speed * dt),
        self.y + (dy * self.speed * dt),
        -10)

    -- spawn enemies
    -- they can show up anywhere around the edges, at a rate dependent
    -- on your score
    local spawnrate = 0.5 + (love.score/10000)
    self.spawn = self.spawn - spawnrate * dt
    while self.spawn <= 0 do
        -- spawn an enemy
        love.addObject(new "Target" {})
        -- reset timer
        self.spawn = self.spawn + 1
    end
end

function aimTowards(self, x, y)
    self.turret = self:angleTo(x, y)
end

function turnTowards(self, x, y)
    self.chassis = self:angleTo(x, y)
end

function fireAt(self, x, y)
    if self.heat > 0 then return end

    self:aimTowards(x, y)

    local gift = new "Shot" {
        x = self.x;
        y = self.y;
        angle = self.turret;
    }

    -- move it to the end of the turret, which is 12px long
    gift:update(12/gift.speed)

    love.addObject(gift)
end
