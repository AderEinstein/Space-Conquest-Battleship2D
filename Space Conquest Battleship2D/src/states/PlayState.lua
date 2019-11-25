--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the state of the game in which we are actively playing;
    player should control the helicopter, with the enemies actively attacking us. 
    If we get hurt by a bullet from the enemy, we lose one point of health and we're taken either to the Game
    Over screen if at 0 health or the start level screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:init()
    self.timer1 = 0 -- Controls enemy spawning
    self.timer2 = 0 -- Controls powerUp spawning
    self.timer3 = 0 -- Controls coin spawning
    self.playerBullets = {}
    self.coins = {}
    self.explosions = {}
    self.enemies = {}
    self.powerUps = {}
    self.paused = false
    self.transitionBeta = 0 -- For fading out after player dies
    self.transitioning = false
    self.canShoot = true
    self.shootingTimer = 0 -- Will count down until the user can shoot next, This will prevents the user from shooting continuously at the speed of a machine gun
    self.drawIce = false


    -- To produce particle system upon the collection of a powerUp by the spaceship
    self.psystem = love.graphics.newParticleSystem(gTextures['particle-intro'], 64)
    self.psystem:setParticleLifetime(0.75, 1.5)
    self.psystem:setLinearAcceleration(-15, 0, 15, 20)
    self.psystem:setAreaSpread('normal', 10, 10)
    self.psystem:setSpin(20, 50)

    -- Nav Buttons
    self.backButton = Button(Buttons['back'])
    self.pauseButton = Button(Buttons['pause'])
end

function PlayState:enter(params)
    self.helicopter = params.helicopter or Helicopter(1)
    self.health = params.health or 3
    self.score = params.score or 0
    self.highScores = params.highScores
    self.level = params.level or 1
    self.backgroundScroll = params.backgroundScroll or 0

    -- Insert level's reference enemy at beginning of level
    table.insert(self.enemies, Enemy(math.min(self.level, 4), self.helicopter))

    self.showLevelCompletion = false
end

function PlayState:update(dt)
    -- update timer for fading in/out
    Timer.update(dt)

    self.backgroundScroll = (self.backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    self.psystem:update(dt)

    if not self.paused then
        self.timer1 = self.timer1 + dt
        self.timer2 = self.timer2 + dt
        self.timer3 = self.timer3 + dt
        local nextPowerUpTimer = math.random(2, 7)
        local nextEnemyTimer = math.random(math.max(1, 3 - self.level), math.max(4, 8 - self.level))
        local nextCoinTimer = math.random(4, 6)

        if self.timer1 > nextEnemyTimer then
            -- 4 levels/types of enemies exist. As the level increases the enemy corresponding to the current level will be added on to the gameplay. 
            -- From level 5 on, No new enemy will be added to the scene. Rather, the speed of the enemies will be increased to match the level difficulty 
            local enemyLevel = math.random(1, math.min(self.level, 4))
            table.insert(self.enemies, Enemy(enemyLevel, self.helicopter))
            self.timer1 = 0
        end
        if self.timer2 > nextPowerUpTimer then
            table.insert(self.powerUps, PowerUp(math.random(1, 4))) -- Defined powerUps are within this interval in the powerUp table
            self.timer2 = 0
        end
        if self.timer3 > nextCoinTimer then
            table.insert(self.coins, GameObject(math.random(1, 4))) -- Defined coins are within this interval in the powerUp table
            self.timer3 = 0
        end
    end

    self.shootingTimer = self.shootingTimer + dt
    if self.shootingTimer > 1 then
        self.canShoot = true
    end

    if not self.transitioning then
        -- create bullets and add them to playerBullet table on the press of space
        if (love.keyboard.wasPressed('space') or self.helicopter.shot) and not self.paused and self.canShoot then
            self.canShoot = false
            Timer.after(1, function()
                self.canShoot = true
                self.shootingTimer = 0
            end
        )
            gSounds['shot']:stop()
            gSounds['shot']:play()
            gSounds['shot']:setVolume(2)
            
            if self.helicopter.currentShootingPower == 'bullet-pair' then 
                local bullet1 = Bullet(SpacecraftBullet[self.helicopter.skin].type, SpacecraftBullet[self.helicopter.skin].color, self.helicopter)
                bullet1.x, bullet1.y = self.helicopter.x + 10, self.helicopter.y + 16
                local bullet2 = Bullet(SpacecraftBullet[self.helicopter.skin].type, SpacecraftBullet[self.helicopter.skin].color, self.helicopter)
                bullet2.x, bullet2.y = self.helicopter.x + 40, self.helicopter.y + 16
                bullet2.isPair = true
                table.insert(self.playerBullets, bullet1)
                table.insert(self.playerBullets, bullet2)
            else
                local bullet = Bullet(SpacecraftBullet[self.helicopter.skin].type, SpacecraftBullet[self.helicopter.skin].color, self.helicopter)
                table.insert(self.playerBullets, bullet)
            end
        end
    end

    if not self.paused then
        -- update every enemies(s) in table
        for k, enemy in pairs(self.enemies) do
            enemy:update(dt)
        end

        -- update every bullets(s) in table
        for k, bullet in pairs(self.playerBullets) do
            bullet:update(dt)
            -- remove bullet from table if it goes pass the top screen or hits an enemy
            if bullet.remove or bullet.hit then
                table.remove(self.playerBullets, k)
            end
        end

        -- update explosions
        for k, explosion in pairs(self.explosions) do
            explosion:update(dt)
        end

        -- update powerUps position 
        for k, powerUp in pairs(self.powerUps) do
            powerUp:update(dt)
        end

        -- update coins
        for k, coin in pairs(self.coins) do
            coin:update(dt)
        end

    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    -- Update nav button checking if pressed 
    if love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y) then
        love.audio.stop()
        gSounds['music-intro']:play()
        gSounds['wall-hit']:play()
        gStateMachine:change('start', { highScores = loadHighScores() })
    end

    if self.paused then
        if love.keyboard.wasPressed('p') or (love.mouse.wasPressed(1) and MouseIn(self.pauseButton, x, y)) then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('p') or (love.mouse.wasPressed(1) and MouseIn(self.pauseButton, x, y)) then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    if not self.transitioning then
        -- update helicopter position based on velocity 
        self.helicopter:update(dt, x, y)
    end

    local removeNextBullet = false
    local previousBulletsToRemove = {}
    -- check if we hit an enemy with a bullet
    for k, bullet in pairs(self.playerBullets) do
        if removeNextBullet then
            bullet.remove = true
            removeNextBullet = false
            goto continue
        end
        for l, enemy in pairs(self.enemies) do
            if enemy.remove then 
                table.remove(self.enemies, l) -- enemy.destroy = true
                goto continue
            end
            if bullet:collides(enemy) then
                self.score = self.score + (self.level * 10)
                self:Killenemy(enemy)
                table.remove(self.enemies, l) -- enemy.destroy = true
                bullet.remove = true
                if self.helicopter.currentShootingPower == 'bullet-pair' then
                    if bullet.isPair then
                        table.insert(previousBulletsToRemove, k - 1)
                    else
                        removeNextBullet = true
                    end
                else
                    bullet.remove = true
                end
            end
        end
        ::continue::
    end
    -- Remove bullets left behind
    for k, pos in pairs(previousBulletsToRemove) do
        table.remove(self.playerBullets, k)
    end

    -- check if player helicopter gets hit by enemy
    for k, enemy in pairs(self.enemies) do
        if (enemy:collides(self.helicopter) or enemy.bulletHitPlayer) and not self.helicopter.invincible and not self.helicopter.indestructible then
            -- start an explosion animation, and remove it after a cycle.
            -- Intensity of explosion will reflect our health after beign hurt by a enemy space-ship
            enemy.bulletHitPlayer = false
            gSounds['hurt']:play()
            local frames = {}
            if self.health == 3 then
                frames = {31, 32, 33, 34, 35, 36}
                table.insert(self.explosions, Explosion(self.helicopter, frames))
                Timer.after(0.3, function()
                    table.remove(self.explosions, 1)
                end)
            elseif self.health == 2 then
                frames = {25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36}
                table.insert(self.explosions, Explosion(self.helicopter, frames)) 
                Timer.after(0.6, function()
                    table.remove(self.explosions, 1)
                end)
            elseif self.health == 1 then
                for i = 1, 36 do   
                    table.insert(frames, i)
                end
                table.insert(self.explosions, Explosion(self.helicopter, frames)) 
                self.helicopter.destroyed = true
                Timer.after(1.8, function()
                    table.remove(self.explosions, 1)
                end)
                gSounds['paddle_shrink']:play()
                gSounds['explosion']:play()
                self.transitioning = true
                Timer.tween(2, {
                    [self] = {transitionBeta = 255}
                })
                Timer.after(3, function()
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                end)
            end
            self.helicopter:goInvulnerable(3)
            self.health = self.health - 1
            gSounds['explosion']:play()
        elseif (enemy:collides(self.helicopter) or enemy.bulletHitPlayer) and self.helicopter.indestructible then
            self:Killenemy(enemy)
            table.remove(self.enemies, k) 
        end
    end

    -- detect collision & picking Up a powerUp by spaceship
    for k, powerUp in pairs(self.powerUps) do
        if powerUp:collides(self.helicopter) then
            self.psystem:setColors(
                PowerUpColor[powerUp.type].r,
                PowerUpColor[powerUp.type].b,
                PowerUpColor[powerUp.type].g,
                60,
                PowerUpColor[powerUp.type].r,
                PowerUpColor[powerUp.type].b,
                PowerUpColor[powerUp.type].g,
                0
            )
            self.psystem:setAreaSpread('normal', self.helicopter.width - 30, self.helicopter.height - 8)
            self.psystem:emit(1000)

            powerUp.collected = true
            
            gSounds['bullet_powerup']:play()
            -- invicincibility PowerUp
            if powerUp.type == 1 and not self.helicopter.indestructible then -- Only collect we if we are not indestructible already
                --gSounds['bullet_powerup']:play()
                self.helicopter.indestructible = true
                Timer.every(0.2, function()
                    self.helicopter.blinking = not self.helicopter.blinking
                end)
                :limit(100)
                :finish(function()
                    self.blinking = false
                    self.helicopter.indestructible = false
                end)
            -- Bullet PowerUp
            elseif powerUp.type == 2 and not self.helicopter.powerupCollected then  -- Only collect if we are not shooting bullet pairs already
                self.helicopter.powerupCollected = true
                --gSounds['bullet_powerup']:stop()
               --gSounds['bullet_powerup']:play()
                self.helicopter.currentShootingPower = 'bullet-pair'
                Timer.after(20, function()
                    self.helicopter.currentShootingPower = 'regular'
                    self.helicopter.powerupCollected = false
                end)
            -- life PowerUp
            elseif powerUp.type == 3 then
                if self.health < 3 then
                    self.health = self.health + 1
                end
                --gSounds['bullet_powerup']:play()
            -- Ice Powerdown
            elseif powerUp.type == 4 and not self.helicopter.frozen then -- Only collect if we are not frozen already
                self.helicopter.frozen = true
                HELICOPTER_SPEED = 50
                self.drawIce = true
                Timer.after(10, function()
                    self.helicopter.frozen = false
                    HELICOPTER_SPEED = 185
                    self.drawIce = false
                end)
                gSounds['bullet_powerup']:stop()
                gSounds['paddle_shrink']:play()
            end
        end
    end
    -- detect collision & picking Up a Coin by spaceship
    for k, coin in pairs(self.coins) do
        if coin:collides(self.helicopter) then
            self.psystem:setColors(
                PowerUpColor[3].r,
                PowerUpColor[3].b,
                PowerUpColor[3].g,
                60,
                PowerUpColor[3].r,
                PowerUpColor[3].b,
                PowerUpColor[3].g,
                0
            )
            self.psystem:setAreaSpread('normal', self.helicopter.width - 30, self.helicopter.height - 8)
            self.psystem:emit(1000)

            coin.collected = true
            gSounds['pickup']:play()

            -- Player will scores 10 for a Copper coin, 20 for Silver, 30 for Gold and 40 for a Star coin
            self.score = self.score + coin.type * 10
        end
    end

    -- If any powerUp goes below bounds or is collected, remove it from our powerUps table
    for k, powerUp in pairs(self.powerUps) do
        if powerUp.remove or powerUp.collected then
            table.remove(self.powerUps, k)
        end
    end
    
    -- If any coin goes below bounds or is collected, remove it from our coins table
    for k, coin in pairs(self.coins) do
        if coin.remove or coin.collected then
            table.remove(self.coins, k)
        end
    end

    -- The score will be mapped to the level with the relation : new level for every 1000 points scored
    if self.score >= 2^(self.level - 1) * 200 then
        -- Reset Helicopter speed b4 entering a new level. Gives helicopter a normal speed if it was frozen b4 winning the leve
        HELICOPTER_SPEED = 185
        self.helicopter.frozen = false
        ENEMY_DX = ENEMY_DX + 3
        ENEMY_DY = ENEMY_DY + 1
        gSounds['victory']:play()
        gStateMachine:change('start-level', {
        helicopter = self.helicopter,
        health = self.health,
        score = self.score,
        highScores = self.highScores,
        level = self.level + 1
    }) 
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState: Killenemy(enemy)
    -- start an explosion animation, and remove it after a cycle.
    local frames = {}
    for i = 1, 36 do  -- all frames used for an enemy explosion
        table.insert(frames, i)
    end
    table.insert(self.explosions, Explosion(enemy, frames)) 
    Timer.after(1.8, function()
        table.remove(self.explosions, 1)
    end)
    gSounds['explosion']:stop()
    gSounds['explosion']:play()
end

function PlayState:render()

    --render scrolling background
    love.graphics.draw(gTextures['background-game'],
        -- draw at coordinates 0, -backgroundScroll
        0, -self.backgroundScroll,
        -- no rotation
        0)

    -- render playerBullets
    for k, bullet in pairs(self.playerBullets) do
        bullet:render()
    end
    -- render enemies
    for k, enemy in pairs(self.enemies) do
        enemy:render()
    end
     -- render player helicopter
     self.helicopter:render()

     if self.drawIce then
        love.graphics.setColor(255, 255, 255, 80)
        love.graphics.draw(gTextures['ice'], self.helicopter.x - 1.5, self.helicopter.y - 1.5)
        love.graphics.setColor(255, 255, 255, 255)
     end

     -- render explosions
    for k, explosion in pairs(self.explosions) do
        explosion:render()
    end

    -- render coins
    for k, coin in pairs(self.coins) do
        coin:render()
    end

     love.graphics.setColor(255, 255, 255, 255)
    -- render powerUps
    for k, powerUp in pairs(self.powerUps) do
        powerUp:render()
    end
    --[[ render particle system
    for k, powerUp in pairs(self.powerUps) do
        powerUp:renderParticles()
    end]]
    
    renderScore(self.score, self.level)
    renderHealth(self.health)

    -- Render nav Buttons
    self.backButton:render()
    self.pauseButton:render()

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')
        
    end

    -- draw particle system on helicopter upon collection of a powerup
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw (self.psystem, self.helicopter.x, self.helicopter.y)

    love.graphics.setFont(gFonts['small'])
    love.graphics.print('level :', STATS_X, 20)
    love.graphics.print(tostring(self.level), STATS_X + 45, 18)

    -- fade out
    love.graphics.setColor(0, 0, 0, self.transitionBeta)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end

function PlayState:checkVictory()
    return true
end
