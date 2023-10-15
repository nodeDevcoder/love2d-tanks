Tank = Class{}

ext = {
    clouds = {
        W_E = { 128, 0, 100, 97 },
        G_F = { 478, 384, 89, 99 },
        O_L_F = { 228, 0, 97, 107 }
    },
    misc = {
        oil = { 200, 408, 96, 96 }
    }
}

tanks = {
    size = { big = { w = 82, h = 78, tw = 22, th = 58, bw = 20, bh = 34 } },
    Gray = {
        group = -1,
        big = {
            x = 505,
            y = 0,
            tx = 841,
            ty = 368,
            bx = 671, 
            by = 140
        },
        color = { r = 163, g = 149, b = 149 }
    },
    Blue = { 
        group = -2,
        big = {
            x = 506, 
            y = 78,
            tx = 828,
            ty = 226,
            bx = 148, 
            by = 345
        },
        color = {r = 22, g = 228, b = 242}
    },
    Red = {
        group = -3,
        big = {
            x = 588, 
            y = 0,
            tx = 835, 
            ty = 0,
            bx = 711, 
            by = 140
        },
        color = { r = 237, g = 7, b = 7 }
    },
    Green = { 
        group = -4,
        big = {
            x = 573, 
            y = 275,
            tx = 819,
            ty = 110,
            bx = 691, 
            by = 140
        },
        color = {r = 0, g = 128, b = 28}
    }
}

shootIMG = love.graphics.newImage('Kenney_topdownTanks/PNG/Smoke/smokeWhite3.png')
deadIMG = love.graphics.newImage('Kenney_topdownTanks/PNG/Smoke/smokeOrange3.png')
severeIMG = love.graphics.newImage('Kenney_topdownTanks/PNG/Smoke/smokeGrey4.png')


function Tank:init(world, color, type) 
    self.speed = 100
    self.ammo = 5

    self.health = 100

    self.shield = false
    self.golden = false
    self.speedy = false
    -- self.dblgun = false
    
    self.shtime = 0
    self.gtime = 0
    self.sptime = 0

    -- self.dbltime = 0

    self.color = color
    self.width = tanks.size[type].w
    self.height = tanks.size[type].h
    
    self.spriteX = tanks[color][type].x
    self.spriteY = tanks[color][type].y

    self.turretX = tanks[color][type].tx
    self.turretY = tanks[color][type].ty

    self.turretWidth = tanks.size[type].tw
    self.turretHeight = tanks.size[type].th

    self.hits = 0
    self.kills = 0

    self.image = {
        base = love.graphics.newQuad(self.spriteX, self.spriteY, self.width, self.height, atlas:getDimensions()),
        turret = love.graphics.newQuad(self.turretX, self.turretY, self.turretWidth, self.turretHeight, atlas:getDimensions())
    }
    if color == 'Gray' then
        self.body = love.physics.newBody(world, 75, 75, 'dynamic')
        self.side = 'left'
        self.vert = 'top'
    elseif color == 'Blue' then
        self.body = love.physics.newBody(world, VIRTUAL_WIDTH - 75, 75, 'dynamic')
        self.side = 'right'
        self.vert = 'top'
    elseif color == 'Red' then
        self.body = love.physics.newBody(world, 75, VIRTUAL_HEIGHT - 75, 'dynamic')
        self.side = 'left'
        self.vert = 'bottom'
    elseif color == 'Green' then
        self.body = love.physics.newBody(world, VIRTUAL_WIDTH - 75, VIRTUAL_HEIGHT - 75, 'dynamic')
        self.side = 'right'
        self.vert = 'bottom'
    end
    self.shape = love.physics.newRectangleShape(0, 0, self.width * 0.50, self.height * 0.50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0.2)
    self.fixture:setGroupIndex(tanks[self.color].group)
    self.rotatingClockwise = (self.side == 'left' and true or false)
    self.area = love.physics.newCircleShape((self.width + self.height) / 2)
    self.held = false
    self.fixture:setUserData('Tank')
    self.body:setUserData( self )
    self.alive = true
    self.x = self.body:getX()
    self.y = self.body:getY()
    self.body:setAngle(math.rad(math.random(0, 360)))

    self.bgCont = love.graphics.newQuad(669, 382, 45, 20, atlas:getDimensions())
    self.cHealth = love.graphics.newQuad(250, 242, 45, 20, atlas:getDimensions())
    self.gone = false

	self.psystem = love.graphics.newParticleSystem(deadIMG, 32)
    psystem = self.psystem
    psystem:setParticleLifetime(3, 6) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(5)
	psystem:setSizeVariation(1)
	psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
    self.psystem = psystem

    self.asystem = love.graphics.newParticleSystem(severeIMG, 32)
    asystem = self.asystem
    asystem:setParticleLifetime(3, 6) -- Particles live at least 2s and at most 5s.
	asystem:setEmissionRate(5)
	asystem:setSizeVariation(1)
	asystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
	asystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    self.asystem = asystem
end

function Tank:update(dt, move) 

 if self.alive == true and self.health <= 0 then 
    self.time = love.timer.getTime()
    self.alive = false 
 end

 if self.alive == false and self.gone == false then 
    if love.timer.getTime() - self.time >= 3 then
        self.gone = true;
        self:killed()
    end
 end

 if self.alive and self.body and self.fixture:isDestroyed() == false then

    if self.shield == true then
        if not(self.shtime == nil) and self.shtime - love.timer.getTime() <= 0 then
            self.shtime = nil
            self.shield = false
        end
    end

    if self.health > 100 then self.health = 100 end
    if self.ammo > 7 then self.ammo = 7 end
    self.cHealth = love.graphics.newQuad(250, 242, self.health * 0.45, 20, atlas:getDimensions())

    if not(self.sptime == nil) and self.sptime - love.timer.getTime() <= 0 then
        self.speedy = false
    end

    if self.speedy == false then
        self.speed = math.max(self.health, 40)
    else 
        self.speed = 120
    end



    if move and self.body then
        if self.ammo < 1 and not(self.held) then
            empty_click:stop()
            empty_click:play()
        end

        if self.ammo > 0 and not(self.held) then
            self:shoot()
        end
        horizontal = math.rad(0)
        angle = self.body:getAngle() - math.pi / 2 - horizontal
        x = math.cos(angle)
        y = math.sin(angle)
        self.body:setX(self.body:getX() + x * self.speed * dt)
        self.body:setY(self.body:getY() + y * self.speed * dt)
        self.x = self.body:getX()
        self.y = self.body:getY()
        self.held = true
    else 
        if self.body then
            if self.rotatingClockwise then 
                self.body:setAngle(self.body:getAngle() + math.rad(2))
            else 
                self.body:setAngle(self.body:getAngle() - math.rad(2))
            end
        end
    end
    if self.health > 50 and self.health <= 100 then self.severity = 0 
    elseif self.health < 50 and self.health > 30 then self.severity = 1 
    elseif self.health < 30 and self.health > 0 then self.severity = 2 
    else self.severity = -1 end
end
    self.psystem:update(dt)
    self.asystem:update(dt)

if #kill_nums >= 3 and self.alive == true and self.fixture:isDestroyed() == false and self.body:isDestroyed() == false then
    if not(victory_time) then
        victory_time = 5
    else 
        victory_time = victory_time - dt
    end
    if victory_time <= 0 then
        victory_time = nil
        self.fixture:destroy()
        self.body:destroy()
        kill_nums[#kill_nums + 1] = self
    end
 end

end

function Tank:released()
    self.held = false
    self.rotatingClockwise = not(self.rotatingClockwise)
end

function Tank:shoot() 
    gunshot:stop()
    bullet = Bullet(self)
    gunshot:play()
    self.ammo = self.ammo - 1
    self.shooting = true
end

function Tank:killed()
    dead:stop()
    dead:play()
    self.fixture:destroy()
    self.body:destroy()
    kill_nums[#kill_nums + 1] = self
    killed[self] = true
end

function Tank:render()

    if self.side == 'left' then 
        self.ammo_x = 0 
        self.kills_x = 5
    else 
        self.ammo_x = VIRTUAL_WIDTH - 40
        self.kills_x = VIRTUAL_WIDTH - 30
     end
    if self.vert == 'top' then 
        self.ammo_y = 50
        self.kills_y = 0
    else 
        self.ammo_y = VIRTUAL_HEIGHT - 200 
        self.kills_y = VIRTUAL_HEIGHT - 250
    end

    if self.gone == false and self.body and #kill_nums <= 3 then 
        love.graphics.draw(atlas, self.image.base, math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(), 0.50, 0.50, self.width / 2, self.height / 2)
        love.graphics.draw(atlas, self.image.turret, math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle() + math.rad(180), 0.50, 0.45, self.turretWidth / 2, 7)
    end

    if self.alive == true and self.body and #kill_nums < 3 then
        love.graphics.draw(atlas, self.bgCont, math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(), _, 0.50, self.width / 4, -65)
        love.graphics.setColor(1, 0, 0)

        love.graphics.draw(atlas, self.cHealth, math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(), _, 0.50, self.width / 4, -65)
        love.graphics.setColor(1, 1, 1)
        
        if self.severity == 2 then 
            love.graphics.draw(self.asystem, math.floor(self.body:getX()), math.floor(self.body:getY()), _, 0.25, 0.25)
        end

        love.graphics.setColor(255, 255, 255, 0.7)
        love.graphics.rectangle('fill', self.ammo_x, self.ammo_y, 40, 168)
        love.graphics.setColor(1, 1, 1)
        
        love.graphics.setColor(184, 0, 0)
        love.graphics.print(tostring(self.kills), self.kills_x, self.kills_y)
        love.graphics.setColor(1, 1, 1)


        for i = 0, self.ammo - 1 do 
            self.ammo_bullet = love.graphics.newQuad(tanks[self.color].big.bx, tanks[self.color].big.by, 20, 34, atlas:getDimensions())
            self.ammo_side = self.side == 'left' and math.rad(90) or math.rad(270)
            add = self.side == 'right' and 0 or 34
            subtr = self.side == 'right' and i + 1 or i
            love.graphics.draw(atlas, self.ammo_bullet, self.ammo_x + add + 3, self.ammo_y + 20 * subtr + 3 * i + 3, self.ammo_side)
        end

        if self.shield == true then
            love.graphics.setColor(53 / 255, 158/ 255, 232 / 255)
            love.graphics.setLineWidth(2)
            love.graphics.circle('line', math.floor(self.body:getX()), math.floor(self.body:getY()), self.height * 0.35 + 5)
            love.graphics.setColor(149 / 255, 179 / 255, 227 / 255, 0.46)
            love.graphics.circle('fill', math.floor(self.body:getX()), math.floor(self.body:getY()), self.height * 0.35 + 5)
            love.graphics.setLineWidth(0)
            love.graphics.setColor(1, 1, 1)
        end
    end

    if self.alive == false and self.gone == false and self.body then
        -- local smoke = ext.clouds['O_L_F']
        love.graphics.draw(self.psystem, math.floor(self.body:getX()), math.floor(self.body:getY()), _, 0.25, 0.25)
    end

end