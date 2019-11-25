--[[
    Space Conquest 
    Battleship 2D

    -- Utilities Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Helper functions for writing games
]]

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]
function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function GenerateQuadsBullets(atlas, startY, width, height, number)
    local x = 0
    local y = startY
    local quads = {}
    local counter = 1
    for i = 1, number do
        quads[counter] = love.graphics.newQuad(x, y, width, height, atlas:getDimensions())
        x = x + width 
        counter = counter + 1
        if width == 33 and startY == 72 then  -- Custom addition to piece out enemy-3, 3 properly
            width = 35
        end
    end

    return quads
end

--[[
    This function is specifically made to piece out the power ups from the
    sprite sheet
]]

function GeneratePowerUps(atlas)
    local x = 0
    local y = 192

    local counter = 1
    local quads = {}

    for i = 1, 10 do
        quads[i] = love.graphics.newQuad(x, y, 16, 16, atlas:getDimensions())
        x = x + 16
    end

    return quads
end