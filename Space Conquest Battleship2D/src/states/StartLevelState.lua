--[[
    GD50
    Breakout Remake

    -- StartLevelState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    The state in which we are waiting to start the game. here, we are
    basically just moving the helicopter around until we
    press Enter, though everything in the actual game now should render in
    preparation for the game play to start, including our current health and score, as
    well as the level we're on.
]]

StartLevelState = Class{__includes = BaseState}

function StartLevelState:enter(params)
    self.canPlay = false
    -- start our level # label off-screen
    self.levelLabelY = -64
    -- grab game state from params
    self.helicopter = params.helicopter or Helicopter(1)
    self.health = params.health or 3
    self.score = params.score or 0
    self.highScores = params.highScores
    self.level = params.level or 1

    self.backgroundScroll = 0

     -- Play state sound
     gSounds['music-intro']:stop()
     gSounds['music-game']:play()
     gSounds['music-game']:setLooping(true)

    -- Nav Button(s)
    self.backButton = Button(Buttons['back'])
    self.pauseButton = Button(Buttons['pause'])

    Timer.tween(0.5, {
        [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
    })
    -- after that, pause for one second with Timer.after
    :finish(function()
        self.canPlay = true
    end)
    
end

function StartLevelState:update(dt)

    self.backgroundScroll = (self.backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    if self.canPlay then
        self.helicopter:update(dt)
    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    if love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y) and self.canPlay then
        gStateMachine:change('start', { highScores = loadHighScores() })
    end

    if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.mouse.wasPressed(1)) and self.canPlay then
        self.canPlay = false
        Timer.tween(0.5, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
        }):finish(function()
            -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            helicopter = self.helicopter,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            level = self.level,
            backgroundScroll = self.backgroundScroll
        })
        end)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

end

function StartLevelState:render()

    --render scrolling background
    love.graphics.draw(gTextures['background-game'], 
        -- draw at coordinates 0, -backgroundScroll
        0, -self.backgroundScroll, 
        -- no rotation
        0)

    self.helicopter:render()


    renderScore(self.score, self.level)
    renderHealth(self.health)
    
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('level :', STATS_X, 20)
    love.graphics.print(tostring(self.level), STATS_X + 45, 18)

    -- render Level # label and background rect
    love.graphics.setColor(40, 160, 200, 200)
    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 65)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press enter to begin!', 0, self.levelLabelY + 35, VIRTUAL_WIDTH, 'center')

    self.backButton:render()
    
end