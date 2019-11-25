--[[
    GD50
    Spaceship 

    -- Spaceship Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents a Spaceship moving around randomly in the start state
]]

Spaceship = Class{}

--[[
    Our Spaceship will initialize at the same spot every time, in the middle
    of the world horizontally, toward the bottom.
]]
function Spaceship:init(skin)
    local origin = math.random(1, 9)
    while Origins[origin].lock do
        origin = math.random(1, 9)
    end
    Origins[origin].lock = true
    self.x = Origins[origin].x
    self.y = Origins[origin].y
    self.dy = 30
    self.dx = 30
    self.rotation = Origins[origin].x

    self.width = HELICOPTER_WIDTH
    self.height = HELICOPTER_HEIGHT

    -- the skin has the effect of changing our color
    self.skin = skin
end

function Spaceship:goInvulnerable(duration)
    self.invincible = true
    self.invulnerableDuration = duration
end

function Spaceship:update(dt, mouseX, mouseY)
    self.rotation = self.rotation + math.rad(0.1)
    self.dx = 16 * math.cos(math.pi/2 - self.rotation)
    self.dy = - 16 * math.sin(math.pi/2 - self.rotation)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--[[
    Render the Spaceship by drawing the main texture, passing in the quad
    that corresponds to the proper skin.
]]
function Spaceship:render()
    love.graphics.setColor(255, 255, 255, 200)
    love.graphics.draw(gTextures['helicopters'], gFrames['helicopters'][self.skin]
    , self.x, self.y
    , self.rotation
    , 1, 1
    ,self.width / 2, self.height / 2
    )
end