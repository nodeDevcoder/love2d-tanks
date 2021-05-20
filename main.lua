-- VIRTUAL_WIDTH = 640
-- VIRTUAL_HEIGHT = 360

Class = require 'class'

-- push = require 'push'
require 'Tank'
require 'Bullet'
require 'Misc'
require 'Defences'

atlas = love.graphics.newImage('Kenney_topdownTanks/Spritesheet/sheet_tanks.png')
shields = love.graphics.newImage('shield.jpg')
shield = love.graphics.newQuad(291, 6, 212, 250, shields:getDimensions())

whizz_by = love.audio.newSource('whizz-by.mp3', 'static')
empty_click = love.audio.newSource('empty_click.mp3', 'static')
def_hit = love.audio.newSource('defence_hit.mp3', 'static')
collectAmmo = love.audio.newSource('collected_misc.wav', 'static')
collectHealth = love.audio.newSource('health.wav', 'static')
shoot = love.audio.newSource('shoot.wav', 'static')
hit = love.audio.newSource('hit.mp3', 'static')
drive = love.audio.newSource('drive.mp3', 'static')
dead = love.audio.newSource('dead.mp3', 'static')
home = love.audio.newSource('home-screen.mp3', 'static')
victory = love.audio.newSource('victory.mp3', 'static')
endscreen = love.audio.newSource('end-screen.mp3', 'static')
gunshot = love.audio.newSource('gunshot.mp3', 'static')
beep = love.audio.newSource('beep.mp3', 'static')

string = 'Hello'
miscItems = {}
defItems = {}
counter = 5
killed = {}
kill_nums = {}
gameState = 'start'
ready_pl = {}

sm_font = love.graphics.newFont('flappy.ttf', 24)
med_font = love.graphics.newFont('flappy.ttf', 38)
lg_font = love.graphics.newFont('flappy.ttf', 56)

function round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function damageCalc(num)
    if num > 180 and num < 300 then dmg = math.random(10, 15)
    elseif num > 300 and num < 500 then dmg = math.random(15, 20)
    elseif num > 500 and num < 700 then dmg = math.random(20, 25)
    elseif num > 700 and num < 1000 then dmg = math.random(30, 35)
    elseif num > 1000 then dmg = math.random(35, 40) end
    return dmg
end

function spawnBG()  
    home:setLooping(true)
    home:play()

    graytank = nil
    greentank = nil
    bluetank = nil
    redtank = nil

    counter = 5
    rem_time = 3
    vict_time = nil
    kill_nums = {}
    miscItems = {}
    defItems = {}
    killed = {}

    graytank = Tank(world, 'Gray', 'big')
    greentank = Tank(world, 'Green', 'big')
    bluetank = Tank(world, 'Blue', 'big')
    redtank = Tank(world, 'Red', 'big')

    spawnDefs()
    spawnMisc()

    backgrounds = {
        dirt = love.graphics.newQuad(0, 0, 128, 128, atlas:getDimensions()), 
        grass = love.graphics.newQuad(0, 128, 128, 128, atlas:getDimensions()),
        ice = love.graphics.newQuad(0, 256, 128, 128, atlas:getDimensions())
    }
    
    backgroundData = {}

    for i = 0, 10 do -- rows
        for p = 0, 5 do  -- columns
            randBg = math.random(1, 3)
            if randBg == 1 then
                table.insert(backgroundData, { type = backgrounds['dirt'], x = i * 128, y = p * 128 })
            elseif randBg == 2 then
                table.insert(backgroundData, { type = backgrounds['grass'], x = i * 128, y = p * 128 })
            elseif randBg == 3 then
                table.insert(backgroundData, { type = backgrounds['ice'], x = i * 128, y = p * 128 })
            end
        end
    end
end

function love.conf(t)
    t.modules.joystick = false
end

function love.load() 
    love.window.setFullscreen(true)

    VIRTUAL_WIDTH = love.graphics.getWidth()
    VIRTUAL_HEIGHT = love.graphics.getHeight()

    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Tanks!!!')
    love.window.setMode(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    -- push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    --     fullscreen = false,
    --     vsync = true,
    --     resizable = false
    -- })

    world = love.physics.newWorld(0, 0, false)

    environment = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 'dynamic')

    
    function beginContact(a, b, coll)
        local types = {}
        types[a:getUserData()] = true
        types[b:getUserData()] = true

        string = a:getUserData() ..b:getUserData()

        if types['Tank'] and types['Bullet'] then
            if a:getUserData() == 'Tank' then 
              tank = a
              bullet = b
            else 
              tank = b
              bullet = a
            end
            hit:stop()
            hit:play()
            bullet = bullet:getBody():getUserData()
            tank = tank:getBody():getUserData()
            if not(tank.shield) then
                if bullet.tank.color == 'Gray' then
                    graytank.hits = graytank.hits + 1
                elseif bullet.tank.color == 'Green' then
                    greentank.hits = greentank.hits + 1
                elseif bullet.tank.color == 'Blue' then
                    bluetank.hits = bluetank.hits + 1
                else 
                    redtank.hits = redtank.hits + 1
                end
                damage = bullet:remove()
                dmg = tostring(damage)
                dmg = round(dmg)
                totDmg = damageCalc(dmg)
                tank.health = tank.health - totDmg
                if tank.health <= 0 and tank.alive == true then 
                    if bullet.tank.color == 'Gray' then
                        graytank.kills = graytank.kills + 1
                    elseif bullet.tank.color == 'Green' then
                        greentank.kills = greentank.kills + 1
                    elseif bullet.tank.color == 'Blue' then
                        bluetank.kills = bluetank.kills + 1
                    else 
                        redtank.kills = redtank.kills + 1
                    end
                end
            else 
                bullet:remove()
            end
        elseif types['Defences'] and types['Bullet'] then
            if a:getUserData() == 'Bullet' then 
                bullet = a
                defence = b
            else 
                defence = a
                bullet = b
            end
              string = defence:getBody():getUserData()
              def_hit:stop()
              def_hit:play()
              bullet = bullet:getBody():getUserData()
              bullet:remove()
        elseif types['Bullet'] and types['Bullet'] then
            -- Explosion!!!
        elseif types['Tank'] and types['Miscellaneous'] then
          if a:getUserData() == 'Tank' then 
            tank = a
            item = b
          else 
            tank = b
            item = a
          end
          tank = tank:getBody():getUserData()
          item = item:getBody():getUserData()
          if item.type == 'Health' then 
            collectHealth:play()
            rand = math.random(10, 30)
            tank.health = tank.health + rand
          elseif item.type == 'Ammo' then
            collectAmmo:play()
            rand = math.random(1, 5)
            tank.ammo = tank.ammo + rand
          elseif item.type == 'Mine' then
            dmg = math.random(5, 60)
            tank.health = tank.health - dmg
          elseif item.type == 'Special' then
            pwr = math.random(1, 2)
            if pwr == 1 then
                tank.shield = true
                tank.shtime = love.timer.getTime() + math.random(12, 25)
            elseif pwr == 2 then
                tank.speedy = true
                tank.sptime = love.timer.getTime() + math.random(12, 25)
            end
          end
          item:remove()
        end
    end

    function endContact(a, b, coll)

    end

    function preSolve(a, b, coll)

    end

    function postSolve(a, b, coll, normalImpulse, tangentImpulse)

    end

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)


    borderDimensions = {
        { x = 0, y = 0, w = VIRTUAL_WIDTH, h = 0 },
        { x = 0, y = VIRTUAL_HEIGHT, w = VIRTUAL_WIDTH, h = 0 },
        { x = VIRTUAL_WIDTH, y = 0, w = 0, h = VIRTUAL_HEIGHT },
        { x = 0, y = 0, w = 0, h = VIRTUAL_HEIGHT }
    }


    borders = {}

    for i = 1, 4 do
        table.insert(borders, { 
            body = love.physics.newBody(world, borderDimensions[i]['x'], borderDimensions[i]['y'], 'static'),
            shape = love.physics.newEdgeShape(0, 0, borderDimensions[i]['w'], borderDimensions[i]['h'])
        })
    end

    fixtures = {}

    for i = 1, 4 do
        fixture = love.physics.newFixture(borders[i]['body'], borders[i]['shape'])
        fixture:setCategory(10)
        fixture:setUserData('Border')
        table.insert(fixtures, fixture)
    end
end

function love.update(dt)

    if love.keyboard.isDown('escape') and (gameState == 'play') then
        gameState = 'pause'
    end

    if love.keyboard.isDown('escape') and (gameState == 'start' or gameState == 'end') then
        love.event.quit()
    end

    if gameState == 'play' then
        if #kill_nums >= 3 then
            if not(vict_time) then
                home:stop()
                victory:play()
                vict_time = 5
            else 
                vict_time = vict_time - dt
            end
            if vict_time <= 0 then
                love.graphics.clear()
                vict_time = nil
                for i = #defItems, 1, -1 do
                    defItems[i]:remove()
                    defItems[i] = nil
                end
                for i = #miscItems, 1, -1 do
                    miscItems[i].item:remove()
                end
                gameState = 'end'
            end
        end

        if love.timer.getTime() - time >= 30 then
            if #miscItems < 30 then
                spawnMisc()
            end
            time = love.timer.getTime()
        end 

        if #bullets > 2 then
            whizz_by:play()
        end

        if love.keyboard.isDown('tab') then
            graytank:update(dt, true)
        else 
            graytank:update(dt)
        end
        
        if love.keyboard.isDown('kp0') then
            greentank:update(dt, true)
        else 
            greentank:update(dt)
        end

        if love.keyboard.isDown('lctrl') then
            redtank:update(dt, true)
        else
            redtank:update(dt)
        end

        if love.keyboard.isDown('kp7') then
            bluetank:update(dt, true)
        else
            bluetank:update(dt)
        end

        if love.keyboard.isDown('tab') and graytank.alive or love.keyboard.isDown('kp0') and greentank.alive or love.keyboard.isDown('lctrl') and redtank.alive or love.keyboard.isDown('kp7') and bluetank.alive then
            drive:play()
        else
            drive:stop()
        end

        for i = 1, #bullets do 
            if bullets[i] then
                bullets[i].init:update(dt)
            end
        end
        
        for i = 1, #defItems do 
            defItems[i]:update(dt)
        end
        
        world:update(dt)
        
        counter = counter - 0.1
    elseif gameState == 'start' then

        if love.keyboard.isDown('kp0') and not(ready_pl['br']) then
            ready_pl['br'] = true
            beep:stop()
            beep:play()
        end

        if love.keyboard.isDown('kp7') and not(ready_pl['tr']) then
            ready_pl['tr'] = true
            beep:stop()
            beep:play()
        end
        
        if love.keyboard.isDown('lctrl') and not(ready_pl['bl']) then
            ready_pl['bl'] = true
            beep:stop()
            beep:play()
        end

        if love.keyboard.isDown('tab') and not(ready_pl['tl']) then
            ready_pl['tl'] = true
            beep:stop()
            beep:play()
        end

        if ready_pl['tr'] and ready_pl['tl'] and ready_pl['br'] and ready_pl['bl'] then
            if not(ct_time) then ct_time = 1 else ct_time = ct_time - dt end
            if ct_time <= 0 then
                gameState = 'countdown'
                rem_time = 3
                ct_time = nil
                time = love.timer.getTime()
            end
        end
    elseif gameState == 'pause' then
        if love.keyboard.isDown('return') then
            love.event.quit()
        end
        if love.keyboard.isDown('space') then
            gameState = 'play'
        end
    elseif gameState == 'countdown' then
        rem_time = rem_time - dt
        if rem_time <= 0 then
            gameState = 'play'
            spawnBG()
        end
    elseif gameState == 'end' then
        drive:stop()

        if love.keyboard.isDown('return') then
            ready_pl = {}
            gameState = 'start'
        end
    end
end

function love.keyreleased(key)
    if gameState == 'play' then
        if key == 'tab' then
            graytank:released()
        end

        if key == 'kp0' then
            greentank:released()
        end

        if key == 'lctrl' then
            redtank:released()
        end

        if key == 'kp7' then
            bluetank:released()
        end
    end
end

function love.draw()
    -- push:start()
    
    -- love.graphics.polygon('fill', tank.body:getWorldPoints(tank.shape:getPoints()))
    -- love.graphics.polygon('fill', environment:getWorldPoints(testShape:getPoints())
    if gameState == 'start' then
        love.graphics.setBackgroundColor(73 / 255, 191 / 255, 100 / 255)
        love.graphics.setFont(lg_font)
        love.graphics.printf('Welcome to Tanks 2.0!', VIRTUAL_WIDTH / 2 - 300, 200, VIRTUAL_WIDTH, 'left')
        love.graphics.setFont(med_font)
        love.graphics.printf('Press your buttons to play', 200, 500, 1000, 'center')
        if ready_pl['tr'] then
            love.graphics.setColor(22 / 255, 201 / 255, 224 / 255)
            love.graphics.circle('fill', VIRTUAL_WIDTH - 30, 30, 50)
            love.graphics.setColor(1, 1, 1)
        end

        if ready_pl['tl'] then
            love.graphics.setColor(163 / 255, 149 / 255, 149 / 255)
            love.graphics.circle('fill', 30, 30, 50)
            love.graphics.setColor(1, 1, 1)
        end

        if ready_pl['br'] then
            love.graphics.setColor(6 / 255, 112 / 255, 23 / 255)
            love.graphics.circle('fill', VIRTUAL_WIDTH - 30, VIRTUAL_HEIGHT - 30, 50)
            love.graphics.setColor(1, 1, 1)
        end

        if ready_pl['bl'] then
            love.graphics.setColor(209 / 255, 0, 0)
            love.graphics.circle('fill', 30, VIRTUAL_HEIGHT - 30, 50)
            love.graphics.setColor(1, 1, 1)
        end

    elseif gameState == 'play' then

        for k, v in ipairs(backgroundData) do
            love.graphics.draw(atlas, v.type, v.x, v.y)
        end

        love.graphics.setLineWidth(0)
        love.graphics.setLineStyle('rough')

        for i = 1, #miscItems do
            miscItems[i].item:render() 
        end

        for i = 1, #bullets do 
            bullets[i].init:render()
        end


        graytank:render()
        greentank:render()
        redtank:render()
        bluetank:render()

        for i = 1, #defItems do 
            defItems[i]:render()
        end

        for i = 1, 4 do
            love.graphics.line(borders[i]['body']:getWorldPoints(borders[i]['shape']:getPoints()))
        end

    elseif gameState == 'pause' then
        love.graphics.setFont(lg_font)
        love.graphics.printf('Are you sure you want to quit? \n Click space to continue!', 200, 200, 1000, 'center')
    elseif gameState == 'countdown' then
        n, i = math.modf(rem_time)
        love.graphics.setFont(lg_font)
        love.graphics.print(tostring(n + 1), VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    elseif gameState == 'end' then
        love.graphics.setBackgroundColor(81 / 255, 70 / 255, 145 / 255)
        love.graphics.setFont(lg_font)
        love.graphics.print('🏆Victory Royale!🏆', 400, 100)
        love.graphics.print('Congratulations ', 300, 200)
        love.graphics.setColor(tanks[kill_nums[4].color].color.r / 255, tanks[kill_nums[4].color].color.g / 255, tanks[kill_nums[4].color].color.b / 255)
        love.graphics.print(kill_nums[4].color ..'!', 775, 200 )
        love.graphics.setColor(1, 1, 1)
        font_tbl = { { font = love.graphics.newFont('flappy.ttf', 48) } , { font = love.graphics.newFont('flappy.ttf', 44) } , { font = love.graphics.newFont('flappy.ttf', 42) }, { font = love.graphics.newFont('flappy.ttf', 41) } }
        for i = 4, 1, -1 do
            love.graphics.setFont(font_tbl[5 - i].font)
            love.graphics.print(tostring(5 - i) ..'.  ', 200, 100 * (5 - i) + 250)
            love.graphics.setColor(tanks[kill_nums[i].color].color.r / 255, tanks[kill_nums[i].color].color.g / 255, tanks[kill_nums[i].color].color.b / 255)
            love.graphics.print(kill_nums[i].color, 300, 100 * (5 - i) + 250)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(kill_nums[i].hits) ..' HITS', 600, 100 * (5 - i) + 250)
            love.graphics.print(tostring(kill_nums[i].kills) ..' KILLS', 850, 100 * (5 - i) + 250)

            bltIMG = love.graphics.newQuad(tanks[kill_nums[i].color].big.bx, tanks[kill_nums[i].color].big.by, tanks.size.big.bw, tanks.size.big.bh, atlas:getDimensions())
            for p = 1, kill_nums[i].kills do
                love.graphics.draw(atlas, bltIMG, 1150 + 20 * (p), 100 * (5 - i) + 250, math.rad(340), 0.65, 0.65)
            end
        end
    end
end