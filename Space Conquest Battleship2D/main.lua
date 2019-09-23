--[[
    GD50
    Battlelship Helicopter 2D

    Author: Franklin Ader
    adereinstein1@gmail.com


    Graphics:

    -Franklin Ader

    Credit for music:
    @Epic_Games
]]

require 'src/Dependencies'

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- set the application title bar
    love.window.setTitle('Battleship Space 2D')

    love.graphics.setFont(gFonts['small'])

    gSounds['music-intro']:play()
    gSounds['music-intro']:setLooping(true)
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

    -- a table we'll use to keep track of which keys have been pressed this
    -- frame, to get around the fact that LÖVE's default callback won't let us
    -- test for input from within other functions
    love.keyboard.keysPressed = {}

    -- same for mouse input
    love.mouse.buttonsPressed = {}

    -- Particle system 
    Psystem = love.graphics.newParticleSystem(gTextures['particle-intro'], 64)
    Psystem:setParticleLifetime(1, 3)
    Psystem:setLinearAcceleration(-15, 8, 15, 20)
    Psystem:setAreaSpread('normal', 400, 300)

    backgroundDice = math.random(1, 4)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    
    Timer.update(dt)

    -- Update Psystem
    Psystem:update(dt)

    Psystem:setColors(255, 255, 255, 200, 255, 255, 255, 100, 255, 255, 255, 0)
    
    Psystem:setAreaSpread('normal', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)
    Psystem:emit(5000)

    -- this time, we pass in dt to the state object we're currently using
    gStateMachine:update(dt)

    -- reset keys pressed
    love.keyboard.keysPressed = {}
    -- reset mouse 
    love.mouse.buttonsPressed = {}
    
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

--[[
    Equivalent to our keyboard function from before, but for the mouse buttons.
]]
function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

-- Changing frames of gif title every 0.2 s
N = 0
Timer.every(0.2, function()
    N = (N + 1) % 5
end)

function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:apply('start')
    
    -- Intro Background scaled to fit our virtual resolution
    
    local backgroundWidth = gTextures['background-intro' .. tostring(backgroundDice)]:getWidth()
    local backgroundHeight = gTextures['background-intro' .. tostring(backgroundDice)]:getHeight()

    love.graphics.draw(gTextures['background-intro' .. tostring(backgroundDice)],
        -- draw at coordinates 0, 0
        0, 0,
        -- no rotation
        0,
        -- scale factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    -- use the state machine to defer rendering to the current state we're in
    gStateMachine:render()

    -- display FPS for debugging; simply comment out to remove
    --displayFPS()
    
    push:apply('end')
end

--[[
    Loads high scores from a .lst file, saved in LÖVE2D's default save directory in a subfolder
    called 'battleship'.
]]
function loadHighScores()
    if not (love.system.getOS() == "Windows") then
        local scores = {}
        scores[1] = {name = 'Lee Xu', score = 122500}
        scores[2] = {name = 'Sarah', score = 121800}
        scores[3] = {name = 'Eder', score = 121005}
        scores[4] = {name = 'Park', score = 112500}
        scores[5] = {name = 'Peter', score = 101500}
        scores[6] = {name = 'Ader', score = 93300}
        scores[7] = {name = 'Tommy', score = 90250}
        scores[8] = {name = 'Eric', score = 79830}
        scores[9] = {name = 'Zach', score = 75260}
        scores[10] = {name = 'Mark', score = 62235}
        return scores
    else
        love.filesystem.setIdentity('breakout6')

        -- if the file doesn't exist, initialize it with some default scores
        if not love.filesystem.exists('breakout.lst') then
            local scores = ''
            for i = 10, 1, -1 do
                scores = scores .. 'MBA\n'
                scores = scores .. tostring(i * 100) .. '\n'
            end

            love.filesystem.write('breakout.lst', scores)
        end

        -- flag for whether we're reading a name or not
        local name = true
        local currentName = nil
        local counter = 1

        -- initialize scores table with at least 10 blank entries
        local scores = {}

        for i = 1, 10 do
            -- blank table; each will hold a name and a score
            scores[i] = {
                name = nil,
                score = nil
            }
        end

        -- iterate over each line in the file, filling in names and scores
        for line in love.filesystem.lines('breakout.lst') do
            if name then
                scores[counter].name = string.sub(line, 1, 3)
            else
                scores[counter].score = tonumber(line)
                counter = counter + 1
            end

            -- flip the name flag
            name = not name
        end

        return scores
    end
end

--[[
    Renders hearts based on how much health the player has. First renders
    full hearts, then empty hearts for however much health we're missing.
]]
function renderHealth(health)
    -- start of our health rendering
    local healthX = STATS_X

    
    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 37)
        healthX = healthX + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 37)
        healthX = healthX + 11
    end
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

--[[
    Renders the game hint
]]
function DisplayInstruction()
    -- instructions
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.print('instructions ', 80, 7)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Pause game to view Power-Up guide', 13, 27)
    love.graphics.print('Score 1000 points to swell your paddle', 13, 43)
    love.graphics.print('Collect key power ups to break locks', 13, 59)
end

--[[
    Simply renders the player's score at the top right, with left-side padding
    for the score number.
]]
function renderScore(score, level)
    local Level = level or 1
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('score :', STATS_X, 5)
    love.graphics.print(tostring(score), STATS_X + 45, 5)


end

-- [[Detect tap/mouse on A Button]]
-- x, y : mouse coordinates
function MouseIn(button, x, y)
    if not x or not y then
        return false
    end 
    return (x > button.x and x < button.x + button.width and y > button.y and y < button.y + button.height)
end
function Direction(button, x, y)
    if (x > button.x + button.width / 3.125 and x < button.x + button.width / 1.493 and y > button.y and y < button.y + button.height / 3.125) then
        return 'up'
    elseif (x > button.x + button.width / 1.493 and x < button.x + button.width and y > button.y + button.height / 3.125 and y < button.y + button.height / 1.493) then
        return 'right'
    elseif (x > button.x + button.width / 3.125 and x < button.x + button.width / 1.493 and y > button.y + button.height / 1.493 and y < button.y + button.height) then
        return 'down'
    elseif (x > button.x and x < button.x + button.width / 3.125 and y > button.y + button.height / 3.125 and y < button.y + button.height / 1.493) then
        return 'left'
    end
end