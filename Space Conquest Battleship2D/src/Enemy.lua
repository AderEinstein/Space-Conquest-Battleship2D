--[[
    Space Conquest 
    Battleship 2D

    -- Enemy Class --

    Author: Franklin Ader
    adereinstein1@gmail.com
]]

Enemy = Class{}

function Enemy: init(level, player)
    self.player = player
    self.level = level
    self.type = 'enemies-' .. self.level
    self.width = Enemies[self.type].width
    self.height = Enemies[self.type].height
    -- Initial shooting intervel
    self.shootingInterval = math.random(math.max(0, 4-self.level), math.max(1, 6-self.level))
    
    self.shootingTimer = 0
    self.bullets = {}

    self.remove = false
    self.destroy = false -- Flag to note wether an Enemy was hurt by a bullet.
    self.bulletHitPlayer = false -- to note if player gets hit by enemy bullet
    
    -- Make Enemy spawn down the screen
    self.dx = math.random(-ENEMY_DX, ENEMY_DX)
    self.dy = math.random(ENEMY_DY, ENEMY_DY + 20)

    -- Make Enemy spawn from anywhere from the top edge of the screen 
    self.x = math.random(0, VIRTUAL_WIDTH - self.width) 
    self.y = 0 - self.height  

    -- this will effectively be the color of enemy bullet relative to the its type
    self.skin = math.random(1, Enemies[self.type].count)

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-15, 0, 15, 20)
    self.psystem:setAreaSpread('normal', 10, 10)

end
--[[
    Expects an argument with a bounding box: only the paddle will be a valid candidate in terms of the game logic
    and returns true if the powerUp bounding boxes and the paddle's overlap.
]]
function Enemy:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Enemy:update(dt)

    self.psystem:update(dt)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- allow enemy to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
    end
    if self.x >= VIRTUAL_WIDTH - self.width then
        self.x = VIRTUAL_WIDTH - self.width
        self.dx = -self.dx
    end
    -- remove enemy if it goes pass bottom edge of the screen
    if self.y > VIRTUAL_HEIGHT then
        self.remove = true
    end
    -- Set remove flag to true if destroy became true
    -- self.remove = self.destroy == true and true or false

    self.shootingTimer = self.shootingTimer + dt
    if self.shootingTimer > self.shootingInterval then
        local dice = math.random(2)
        local bulletColor = 'green'
        if dice == 1 then
            bulletColor = 'blue'
        end
        gSounds['shot']:stop()
        gSounds['shot']:play()
        -- gSounds['shot']:setVolume(2)
        table.insert(self.bullets, Bullet('foot-longs', bulletColor, self, 'down'))
        self.shootingTimer = 0
        self.shootingInterval = math.random(math.max(self.shootingInterval - 0.5, 0), self.shootingInterval + 0.5)
    end

    -- update enemy bullets
    for k, bullet in pairs(self.bullets) do
        bullet:update(dt)
    end

    for k, bullet in pairs(self.bullets) do
        if bullet:collides(self.player) then
            self.bulletHitPlayer = true
        end
    end
end

function Enemy:render()
    love.graphics.draw(gTextures['enemies'], gFrames[self.type][self.skin], self.x, self.y)
    -- render enemy bullets
    for k, bullet in pairs(self.bullets) do
        bullet:render(0.5)
    end
end

function Enemy:renderParticles()
    love.graphics.draw(self.psystem, self.x, self.y)
end
