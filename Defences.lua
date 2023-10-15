Defences = Class{}

defs = {
    { t = 'brown', x = 731, y = 410, w = 64, h = 44 },
    { t = 'silver',  x = 796, y = 410, w = 44, h = 62 },
    { t = 'red', x = 805, y = 306, w = 44, h = 62 },
    { t = 'dirt-silver', x = 783, y = 244, w = 44, h = 62 },
    { t = 'dirt-green', x = 790, y = 48, w = 44, h = 62 },
    { t = 'green', x = 746, y = 48, w = 44, h = 62 },
    { t = 'gray', x = 129, y = 301, w = 64, h = 44 }
}

function Defences:init()
    self.x = math.random(100, VIRTUAL_WIDTH - 100)
    self.y = math.random(50, VIRTUAL_HEIGHT - 50)

    rand = math.random(1, 7) 
    self.det = defs[rand]
    self.angle = math.rad(math.random(0, 360))

    self.image = love.graphics.newQuad(self.det.x, self.det.y, self.det.w, self.det.h, atlas:getDimensions())

    self.body = love.physics.newBody(world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newRectangleShape(self.det.w * 0.75 / 2, self.det.h * 0.75 / 2, self.det.w * 0.75, self.det.h * 0.75)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData('Defences')
    self.fixture:setGroupIndex(15)
    self.fixture:setMask(10)

    self.done = false

    self.body:setAngle(self.angle)

    self.body:setUserData(self)
end 

function Defences:update(dt) 

end

function Defences:render()
    love.graphics.draw(atlas, self.image, math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(), 0.75, 0.75)
end

function Defences:remove()
    if self.body and self.fixture:isDestroyed() == false then 
        self.body:setX(-200)
        self.body:setY(-100)
        self.fixture:destroy()
        self.body:destroy()
        self.body = nil
        self.fixture = nil
    end
end

function spawnDefs()
    num = math.random(10, 15)
    for i = 1, num do 
        def = Defences()
        table.insert(defItems, def)
    end
end