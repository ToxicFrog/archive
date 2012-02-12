local super = class(..., "Entity")
local lg = love.graphics

x,y = 0,0
speed = 55
score = 100
image = love.graphics.newImage("steam.png")

function __init(self, ...)
    local face = math.random(1,4)

    if face <= 2 then
        self.x = math.random(-10, love.graphics.getWidth()+10)
        self.y = (face == 1 and -10) or love.graphics.getHeight()+10
    else
        self.x = (face == 3 and -10) or love.graphics.getWidth()+10
        self.y = math.random(-10, love.graphics.getHeight()+10)
    end
end

function update(self, dt)
    -- move towards the tank
    local angle = math.atan((self.x - love.tank.x)/(love.tank.y - self.y))
    if love.tank.y < self.y then
       angle = angle + math.pi
    end

    local dx = -math.sin(angle)
    local dy = math.cos(angle)

    self.x = self.x + (dx * self.speed * dt)
    self.y = self.y + (dy * self.speed * dt)

    -- check for collision with the tank
    if (self.x - love.tank.x)^2 + (self.y - love.tank.y)^2 < 16 then
        print("om nom nom")
        love.removeObject(self)
        require "gameover"
    end
end

function draw(self, dt)
    lg.translate(self.x, self.y)

    lg.setColor(255, 255, 255)
    lg.draw(self.image, -8, -8, 0, 16/256, 16/256)

    -- pop
    lg.translate(-self.x, -self.y)
end

function die(self, bonus)
    love.removeObject(self)
    love.score = love.score + self.score + bonus
    bonus = bonus + 10

    -- possibly explode in a shower of presents
    -- 1/100 chance of a 360 degree, 32-present blast
    -- 2/100 chance of 16 presents
    -- 4/100 chance of 8
    -- 8/100 chance of 4
    -- 16/100 chance of 2
    -- 32/100 chance of 1 in a random direction
    -- 37/100 chance of nothing happening
    local explode = math.random(1, 100)
    if explode <= 1 then
        self:scatter(32, bonus)
    elseif explode <= 3 then
        self:scatter(16, bonus)
    elseif explode <= 7 then
        self:scatter(8, bonus)
    elseif explode <= 15 then
        self:scatter(4, bonus)
    elseif explode <= 31 then
        self:scatter(2, bonus)
    elseif explode <= 63 then
        self:scatter(1, bonus)
    end
end

function scatter(self, count, bonus)
    love.defer(function()
        local angle = math.random() * 2 * math.pi
        for i=1,count do
            local shot = new "Shot" {
                x = self.x;
                y = self.y;
                angle = angle;
                score = bonus;
            }
            love.addObject(shot)
            angle = angle + (2*math.pi)/count
        end
    end)
end