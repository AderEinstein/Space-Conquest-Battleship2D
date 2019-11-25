--[[
    GD50
    Helicopter 

    -- Helicopter Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents a Helicopter that can travel in space and, shoot bullets and collect coins. The Helicopter can have a skin,
    which the player gets to choose upon starting the game.
]]

Helicopter = Class{}

--[[
    Our Helicopter will initialize at the same spot every time, in the middle
    of the world horizontally, toward the bottom.
]]
function Helicopter:init(skin)
    -- x is placed in the middle
    self.x = VIRTUAL_WIDTH / 2 - HELICOPTER_WIDTH / 2

    -- y is placed a little above the bottom edge of the screen
    self.y = VIRTUAL_HEIGHT - HELICOPTER_HEIGHT

    -- start us off with no velocity
    self.dx = 0
    self.dy = 0
    
    self.width = HELICOPTER_WIDTH
    self.height = HELICOPTER_HEIGHT

    -- the skin has the effect of changing our color
    self.skin = skin

    self.invincible = false
    self.destroyed = false
    self.invulnerableDuration = 0
    self.invulnerableTimer = 0
    self.flashTimer = 0
    self.powerupCollected = false
    self.frozen = false
    self.shot = false
    self.indestructible = false
    self.blinking = false -- for invincibility powerup
    self.whiteShader = love.graphics.newShader[[
        extern float WhiteFactor;

        vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
        {
            vec4 outputcolor = Texel(tex, texcoord) * vcolor;
            outputcolor.rgb += vec3(WhiteFactor);
            return outputcolor;
        }
    ]]

    self.moveButton = Button(Buttons['gamepad-move'])
    self.shootButton = Button(Buttons['gamepad-shoot'])
    self.speedupButton = Button(Buttons['gamepad-speedup'])
end

function Helicopter:goInvulnerable(duration)
    self.invincible = true
    self.invulnerableDuration = duration
end

function Helicopter:update(dt, mouseX, mouseY)

    if self.invincible then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        if self.invulnerableTimer > self.invulnerableDuration then
            self.invincible = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end
    -- grab mouse coordinates
    local x = mouseX or 0
    local y = mouseY or 0
    
    -- keyboard input
    if love.keyboard.isDown('left', 'a') or ((not MouseIn(Button(Buttons['pause']), x, y)) and (love.mouse.isDown(1) and MouseIn(self.moveButton, x, y) and Direction(self.moveButton, x, y) == 'left')) then
        self.dx = -HELICOPTER_SPEED
        self.moveButton.texture = 'gamepad-left'
    elseif love.keyboard.isDown('right', 'd') or ((not MouseIn(Button(Buttons['pause']), x, y)) and (love.mouse.isDown(1) and MouseIn(self.moveButton, x, y) and Direction(self.moveButton, x, y) == 'right')) then
        self.dx = HELICOPTER_SPEED
        self.moveButton.texture = 'gamepad-right'
    elseif love.keyboard.isDown('up', 'w') or ((not MouseIn(Button(Buttons['pause']), x, y)) and (love.mouse.isDown(1) and MouseIn(self.moveButton, x, y) and Direction(self.moveButton, x, y) == 'up')) then
        self.dy = -HELICOPTER_SPEED
        self.moveButton.texture = 'gamepad-up'
    elseif love.keyboard.isDown('down', 's') or ((not MouseIn(Button(Buttons['pause']), x, y)) and (love.mouse.isDown(1) and MouseIn(self.moveButton, x, y) and Direction(self.moveButton, x, y) == 'down')) then
        self.dy = HELICOPTER_SPEED
        self.moveButton.texture = 'gamepad-down'
    else
        self.dx, self.dy = 0, 0
        self.moveButton.texture = 'gamepad-move'
    end

    if (love.mouse.wasPressed(1) and MouseIn(self.shootButton, x, y)) then
        self.shot = true
    else
        self.shot = false
    end
    if (love.mouse.isDown(1) and MouseIn(self.speedupButton, x, y)) and not self.frozen then
        HELICOPTER_SPEED = 250
    elseif self.frozen then
        HELICOPTER_SPEED = 50
    elseif not self.frozen then -- Revert 
        HELICOPTER_SPEED = 185
    end

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    Render the Helicopter by drawing the main texture, passing in the quad
    that corresponds to the proper skin.
]]
function Helicopter:render()
    -- draw sprite slightly transparent if invulnerable every 0.04 seconds
    if self.invincible and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(255, 255, 255, 64)
    end
    -- if blinking is set to true, we'll send 1 to the white shader, which will
    -- convert every pixel of the sprite to pure white
    love.graphics.setShader(self.whiteShader)
    self.whiteShader:send('WhiteFactor', self.blinking and 1 or 0)
    love.graphics.draw(gTextures['helicopters'], gFrames['helicopters'][self.skin], self.x, self.y)
    -- reset shader
    love.graphics.setShader()


    love.graphics.setColor(255, 255, 255, 255)
    if not love.system.OS == 'windows' then
        self.moveButton:render()
        self.shootButton:render()
        self.speedupButton:render()
    end
end