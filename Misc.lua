Misc = Class{}

miscs = {
    Health = {
        img = { x = 746, y = 0, w = 48, h = 48 }
    },
    Ammo = {
        img = { x = 735, y = 252, w = 48, h = 48 }
    },
    Mine = {
        img = { x = 730, y = 454, w = 48, h = 48 }
    },
    Special = {
        img = { x = 735, y = 252, w = 48, h = 48 }
    }

}

function Misc:init()
    self.x = math.random(5, VIRTUAL_WIDTH - 5)
    self.y = math.random(5, VIRTUAL_HEIGHT - 5)
    local type = math.random(1, 20)
    if type <= 7 then type = 'Health' elseif type <= 15 then type = 'Ammo' elseif type <= 19 then type = 'Mine' elseif type <= 20 then type = 'Special' end
    self.type = type


    self.tablet = miscs[self.type].img
    self.image = love.graphics.newQuad(self.tablet.x, self.tablet.y, self.tablet.w, self.tablet.h, atlas:getDimensions())

    self.body = love.physics.newBody(world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newCircleShape(24)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData('Miscellaneous')

    self.body:setUserData(self)
    self.fixture:setCategory(10)

    self.drawer = true
    table.insert(miscItems, { item = self })
end

function Misc:render()
    if self.body and self.fixture then
        if counter <= 0 then ended = true end
        if self.type == 'Special' then love.graphics.setColor(0, 21 / 255, 1) end
        love.graphics.draw(atlas, self.image, math.floor(self.body:getX()), math.floor(self.body:getY()), _, ended == true and 0.50 or 0.50 + counter, ended == true and 0.50 or 0.50 + counter)
        love.graphics.setColor(1, 1, 1)
    end
        -- love.graphics.circle('fill', v.item.shape:getX())
end


function Misc:remove()
    for i = 1, #miscItems do
        if miscItems[i].item == self then
            index = i
        end
    end
    table.remove(miscItems, index)
    self.fixture:destroy() 
    self.body:destroy() 
end

function spawnMisc()
    for i = 1, 10 do
        Misc()
    end
end

function blowUp(tbl, mine)
    differences = {}
    for i = 1, #tbl do
        dx = math.abs(tbl[i].body:getX() - mine.body:getX())
        dy = math.abs(tbl[i].body:getY() - mine.body:getY())
        diff = math.sqrt(dx^2 + dy^2)
        table.insert(differences, diff)
    end
    return differences
end