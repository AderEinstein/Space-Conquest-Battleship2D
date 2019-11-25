--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level 
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.highScores = params.highScores
    self.health = params.health
    self.backgroundScroll = 0
end

function VictoryState:update(dt)

    self.backgroundScroll = (self.backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- go to play screen if the player presses Enter
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.mouse.wasPressed(1) then
        gStateMachine:change('serve', {
            level = self.level + 1,
            health = self.health,
            score = self.score,
            highScores = self.highScores
        })
    end
end

function VictoryState:render()
    --render scrolling background
    love.graphics.draw(gTextures['background-game'], 
        -- draw at coordinates 0, -backgroundScroll
        0, -self.backgroundScroll, 
        -- no rotation
        0)

    renderHealth(self.health)
    renderScore(self.score)

    -- level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter or Tap to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end