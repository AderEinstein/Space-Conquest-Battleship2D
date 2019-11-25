--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the screen where we can view all high scores previously recorded.
]]

HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
    self.highScores = params.highScores
    self.spaceships = params.spaceships

    self.backButton = Button(Buttons['back'])
end

function HighScoreState:update(dt)
    local x, y = push:toGame(love.mouse.getPosition())
    -- return to the start screen if we press escape
    if love.keyboard.wasPressed('escape') or (love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y)) then
        gSounds['wall-hit']:play()
        gStateMachine:change('start', {
            highScores = self.highScores,
            spaceships = self.spaceships
        })
    end
end

function HighScoreState:render()

    love.graphics.setFont(gFonts['large'])
    if not (love.system.getOS() == "Windows") then
        love.graphics.printf('Global High Scores', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('High Scores', 0, 10, VIRTUAL_WIDTH, 'center')
    end

    self.backButton:render()
    
    love.graphics.setFont(gFonts['medium'])

    -- iterate over all high score indices in our high scores table
    for i = 1, 10 do
        local name = self.highScores[i].name or '---'
        local score = self.highScores[i].score or '---'

        -- score number (1-10)
        love.graphics.printf(tostring(i) .. '.', VIRTUAL_WIDTH / 4, 
            40 + i * 16, 50, 'left')

        -- score name
        love.graphics.printf(name, VIRTUAL_WIDTH / 4 + 38, 
            40 + i * 16, 50, 'right')
        
        -- score itself
        love.graphics.printf(tostring(score), VIRTUAL_WIDTH / 2,
            40 + i * 16, 100, 'right')
    end

    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Press Escape to return to the main menu!",
        0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- draw special effect to produce snow effect
    love.graphics.draw (Psystem, VIRTUAL_WIDTH / 2, 0)
end


