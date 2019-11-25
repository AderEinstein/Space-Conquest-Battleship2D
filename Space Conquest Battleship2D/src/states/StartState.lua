--[[
    GD50
    Battleship Helicopter 2D

    -- StartState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the state the game is in when we've just started; should
    display "Battle Ship Helicopter" in large text, game instructions in a menu, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class{__includes = BaseState}

function StartState:init()
end
-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function StartState:enter(params)
    self.transitioning = false
    self.highScores = params.highScores

    self.transitionAlpha = 0

 -- Nav Button for Mobile
    self.backButton = Button(Buttons['back'])
    self.startButton = Button(Buttons['start'])
    self.hightScoreButton = Button(Buttons['high-scores'])

    -- Reset all locks to false every time we come back to start state since we reinitialize all the moving spaceships
    for i = 1, 9 do
        Origins[i].lock = false
    end
    self.spaceships = {}
    for i = 1, 9 do
        table.insert(self.spaceships, Spaceship(i))
    end
end

function StartState:exit()
    self.spaceships = {}
end

function StartState:update(dt)

    -- update our Timer, which will be used for our fade transitions
    Timer.update(dt)
    
    for i, spaceship in pairs(self.spaceships) do
        spaceship:update(dt)
    end

    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') and not self.transitioning then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    -- confirm whichever option we have selected to change screens
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') and not self.transitioning then
        self.transitioning = true
        gSounds['confirm']:play()
        if highlighted == 2 then
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            })
            :finish(function()
                gStateMachine:change('high-scores', {
                highScores = self.highScores,
                spaceships = self.spaceships
            })
                
            end)
            
        elseif highlighted == 1 then
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('helicopter-select', {
                    highScores = self.highScores,
                    spaceships = self.spaceships
                })
            end)
        end
    end

    if love.mouse.wasPressed(1) and not self.transitioning then
        if MouseIn(self.hightScoreButton, x, y) then
            self.transitioning = true
            gSounds['confirm']:play()
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('high-scores', {
                highScores = self.highScores})
            end)
            
        elseif MouseIn(self.startButton, x, y) then
            self.transitioning = true
            gSounds['confirm']:play()
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('helicopter-select', {
                    highScores = self.highScores    
                })
            end)
        end
    end
                        
    if love.keyboard.wasPressed('escape') or (love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y)) then
        gSounds['wall-hit']:play()
        love.event.quit()
    end

end

local function loadGif(path)
    local gifFile = love.filesystem.newFile(path, 'r')
    if not gifFile then
      return nil
    end
    gif = GifNew()
    repeat
      local s = gifFile:read(65536)
      if s == nil or s == "" then
        break
      end
      gif:update(s)
    until false
  
    gifFile:close()
  
    return gif:done()
  end
  

function StartState:render()
    -- title
    love.graphics.setFont(gFonts['large'])
    --love.graphics.printf("Space Conquest", 0, VIRTUAL_HEIGHT / 3,
    --    VIRTUAL_WIDTH, 'center')
    --love.graphics.printf('Battleship 2D', 0, VIRTUAL_HEIGHT / 3 + 35, VIRTUAL_WIDTH, 'center')

    for k, spaceship in pairs(self.spaceships) do
        spaceship:render()
    end

    --love.graphics.draw(gTextures['instructions'], 5, 5)
    --DisplayInstruction()
    love.graphics.setFont(gFonts['small'])

    -- Render menu buttons
    self.startButton:render()
    self.hightScoreButton:render()
    self.backButton:render()

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(199,75,25, 255)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- render option 2 blue if we're highlighting that one
    if highlighted == 2 then
        love.graphics.setColor(199,75,25, 255)
    end

    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- gif load
    local titleGif = loadGif('graphics/title.gif')
    -- Title
    local imgData, positionX, positionY, delay, disposal = gif:frame(N)
    love.graphics.draw(love.graphics.newImage(imgData), VIRTUAL_WIDTH / 50, VIRTUAL_HEIGHT / 7)

    -- draw our transition rect; is normally fully transparent, unless we're moving to a new state
    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    
    -- reset to white (for particle system below to be white!)
    love.graphics.setColor(255, 255, 255, 255)
    -- draw special effect to produce snow effect
    love.graphics.draw (Psystem, VIRTUAL_WIDTH / 2, 0)
end