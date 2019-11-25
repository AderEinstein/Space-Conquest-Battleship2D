--[[
    Space Conquest 
    Battleship 2D

    -- Game Object Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents a collectible for the player 
]]
GameObject = Class{}

function GameObject:init(name)
    self.type = name
    self.texture = GameObjects[name].texture
    self.width = 22
    self.height = 22
    self.remove = false
    self.collected = false -- Flag to note wether or not a GameObject was collected. Only the key(10) and ball_multiplier(9) powerUps are collectible.
    self.animation = Animation{
        frames = GameObjects[name].frames,
        interval = 0.075
    }    
    
    -- Make GameObject spawn down the screen
    self.dx = math.random (-100, 100)
    self.dy = BACKGROUND_SCROLL_SPEED
    -- Make GameObject spawn from anywhere from the top edge of the screen 
    self.x = math.random(0, VIRTUAL_WIDTH - self.width)
    self.y = 0 - self.height
end

function GameObject:collides(target)
    -- AABB Collision Test
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 
    -- if the above aren't true, they're overlapping
    return true
end

function GameObject:hit()
end

function GameObject:update(dt)

    self.animation:update(dt)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- allow paddle to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    self.remove = self.collected == true and true or false -- Set remove flag to true if collected became true
    -- remove powerUp if it goes pass bottom edge of the screen
    if self.y > VIRTUAL_HEIGHT then
        self.remove = true
    end
end

function GameObject:render()
    -- Render game object
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation:getCurrentFrame()], self.x, self.y)
end

