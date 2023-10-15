Bullet = Class{}

bullets = {}

function Bullet:init(tank)
        self.tank = tank
        self.speed = 180
        self.width = tanks.size.big.bw
        self.height = tanks.size.big.bh

        self.angle = self.tank.body:getAngle()
        self.x = self.tank.body:getX()
        self.y = self.tank.body:getY()

        self.body = love.physics.newBody(world, self.x, self.y, 'dynamic')
        self.shape = love.physics.newRectangleShape(self.width * 0.65, self.height * 0.65)
        self.fixture = love.physics.newFixture(self.body, self.shape)

        self.body:setAngle(self.angle)
        
        self.image = love.graphics.newQuad(tanks[self.tank.color].big.bx, tanks[self.tank.color].big.by, self.width, self.height, atlas:getDimensions())

        self.fixture:setUserData('Bullet')

        self.body:setUserData(self)

        self.fixture:setGroupIndex(tanks[self.tank.color].group)
        self.fixture:setMask(10)
        self.bulletSpeedExpo = 1
        
        table.insert(bullets, { init = self, group = tanks[tank.color].group })
end

function Bullet:update(dt)
    if self.body:getX() > -5 and self.body:getX() < VIRTUAL_WIDTH + 5 and self.body:getY() > -5 and self.body:getY() < VIRTUAL_HEIGHT + 5 then
        self.bulletSpeedExpo = self.bulletSpeedExpo + 0.045
        num = self.bulletSpeedExpo
        horizontal = math.rad(0)
        angle = self.body:getAngle() - math.pi / 2 - horizontal
        x = math.cos(angle)
        y = math.sin(angle)
        self.body:setX(self.body:getX() + x * self.speed * dt * num)
        self.body:setY(self.body:getY() + y * self.speed * dt * num)
    else 
        self:remove()
    end
end

function Bullet:render()
    for _, v in ipairs(bullets) do
        love.graphics.draw(atlas, v.init.image, math.floor(v.init.body:getX()), math.floor(v.init.body:getY()), v.init.body:getAngle(), 0.65, 0.65, 10, v.init.tank.height - 11)
    end
end

function Bullet:remove()
    for i = 1, #bullets do
        if bullets[i].init == self then
            index = i
        end
    end
    speed = self.speed * self.bulletSpeedExpo
    table.remove(bullets, index)
    self.fixture:destroy() 
    self.body:destroy() 
    return speed
end