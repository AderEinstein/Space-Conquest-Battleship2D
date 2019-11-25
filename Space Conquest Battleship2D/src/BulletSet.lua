--[[
    Space Conquest 
    Battleship 2D

    -- BulletSet Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents a pair of bullets
]]

BulletSet = Class{}

function BulletSet:init(bullet, color, helicopter)
    self.bullet1 = Bullet(bullet, color, helicopter)
    self.bullet1.x, self.bullet1.y = helicopter.x + 13, helicopter.y + 16

    self.bullet2 = Bullet(bullet, color, helicopter)
    self.bullet2.x, self.bullet2.y = helicopter.x + 54, helicopter.y + 16
    

    self.x, self.y = self.bullet1.x, self.bullet1.y

    self.width = 49  -- The distance between the helicopters armors make the hit box of its BulletSets
    self.height = Bullets[bullet].height


    self.remove = false
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function BulletSet:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function BulletSet:collides(target)
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

function BulletSet:update(dt)
    self.bullet1:update(dt)
    self.bullet2:update(dt)
end

function BulletSet:render()
    self.bullet1:render()
    self.bullet2:render()
end

