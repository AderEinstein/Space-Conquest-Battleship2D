--[[
    Space Conquest 
    Battleship 2D

    -- Bullet Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents a bullet 
]]

Bullet = Class{}

function Bullet:init(bullet, color, helicopter, direction)
    -- type/name of the bullet 
    self.type = bullet
    -- direction of the bullet. Default is down
    self.direction = direction

    -- simple positional and dimensional variables
    self.width = Bullets[bullet].width
    self.height = Bullets[bullet].height
    -- place bullet at helicopter's nose for a default shooting
    self.x = helicopter.x + helicopter.width / 2 - self.width / 2
    if self.direction then
        self.y = helicopter.y + helicopter.height
    else
        self.y = helicopter.y - 3
    end

    self.dy = Bullets[bullet].speed
    if self.direction then
        self.dy = -self.dy
    end
    self.dx = 0

    -- this will effectively be the color of our bullet
    self.skin = Bullets[bullet][color].skin

    -- will indicate wether this bullet is another's pair or part of a sweep bullet
    self.isPair = false     

    self.remove = false
    self.hit = false
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Bullet:collides(target)
    -- AABB Collision detection
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Bullet:update(dt)
    self.y = self.y + self.dy * dt
    self.x = self.x + self.dx * dt

    if self.y + self.width <= 0 then
        self.remove = true
    end
end

function Bullet:render()
    love.graphics.draw(gTextures['bullets'], gFrames[self.type][self.skin], self.x, self.y)
end