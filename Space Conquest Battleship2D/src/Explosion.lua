--[[
    Space Conquest 
    Battleship 2D

    -- Explosion Class --

    Author: Franklin Ader
    adereinstein1@gmail.com
]]

Explosion = Class{}

function Explosion:init(target, frames)

    self.target = target
    self.frames = frames
    self.animation = Animation{
            frames = self.frames,
            interval = 0.05
    }    
end

function Explosion:update(dt)
    self.animation:update(dt)
end


function Explosion:render()
    love.graphics.draw(gTextures['explosions'], gFrames['explosions'][self.animation:getCurrentFrame()],
        self.target.x, self.target.y)
end

