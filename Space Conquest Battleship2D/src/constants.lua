--[[
    Space Conquest 
    Battleship 2D

    -- constants --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 648
WINDOW_HEIGHT = 377

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Helicopter
HELICOPTER_SPEED = 185
HELICOPTER_WIDTH = 60
HELICOPTER_HEIGHT = 60

-- Enemy speed
ENEMY_DX = 150
ENEMY_DY = 50


-- Where score rendering begins
STATS_X = VIRTUAL_WIDTH - 90

-- Background scrolling variables
BACKGROUND_LOOPING_POINT = 455

BACKGROUND_SCROLL_SPEED = 60


Buttons = {
    ['left-arrow'] = {
        texture = 'arrows',
        frame = 1,
        width = 24,
        height = 24,
        x = VIRTUAL_WIDTH / 4 - 24,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    },
    ['right-arrow'] = {
        texture = 'arrows',
        frame = 2,
        width = 24,
        height = 24,
        x = VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    },
    ['select-button'] = {
        texture = 'select-button',
        frame = 1,
        width = 71,
        height = 25,
        x = VIRTUAL_WIDTH / 2 - 35,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3 + 30
    },

    ['back'] = {
        texture = 'arrows',
        frame = 1,
        width = 24,
        height = 24,
        x = 5,
        y = 5
    },

    ['pause'] = {
        texture = 'arrows',
        frame = 3,
        width = 24,
        height = 24,
        x = 5,
        y = 30  
    },

    ['start'] = {
        x = VIRTUAL_WIDTH / 2 - 26.5,
        y = VIRTUAL_HEIGHT / 2 + 69,
        width = 52,
        height = 20
    },

    ['high-scores'] = {
        x = VIRTUAL_WIDTH / 2 - 60,
        y = VIRTUAL_HEIGHT / 2 + 70 + 20,
        width = 120,
        height = 20
    },

    ['gamepad-move'] = {
        texture = 'gamepad-move',
        x = 5,
        y = VIRTUAL_HEIGHT / 2 + 25,
        width = 100,
        height = 100
    },
    ['gamepad-shoot'] = {
        texture = 'gamepad-shoot',
        x = VIRTUAL_WIDTH - 60,
        y = VIRTUAL_HEIGHT / 2 + 35,
        width = 50,
        height = 50
    },
    ['gamepad-speedup'] = {
        texture = 'gamepad-speedup',
        x = VIRTUAL_WIDTH - 90,
        y = VIRTUAL_HEIGHT / 2 + 65,
        width = 50,
        height = 50
    },
}

Bullets = {
    ['projectiles'] = { 
        ['width'] = 14,
        ['height'] = 22,
        ['speed'] = -200,
        ['red'] = {['skin'] = 1},
        ['purple'] = {['skin'] = 2},
        ['blue'] = {['skin'] = 3},
        ['green'] = {['skin'] = 4}
    },
    ['missiles'] = {
        ['width'] = 13,
        ['height'] = 25,
        ['speed'] = -200,
        ['red'] = {['skin'] = 1},
        ['blue'] = {['skin'] = 2},
    },
    ['rain-drops'] = {
        ['width'] = 13,
        ['height'] = 21,
        ['speed'] = -200,

        ['red'] = {['skin'] = 1},
        ['blue'] = {['skin'] = 2},
        ['yellow'] = {['skin'] = 3}
    },
    ['spheres'] = {
        ['width'] = 13,
        ['height'] = 13,
        ['speed'] = -200,

        ['red'] = {['skin'] = 1},
        ['purple'] = {['skin'] = 2},
        ['yellow'] = {['skin'] = 3},
        ['blue'] = {['skin'] = 4},
        ['green'] = {['skin'] = 5},
        ['orange'] = {['skin'] = 6},
        ['pink'] = {['skin'] = 7},
    },
    ['foot-longs'] = {
        ['width'] = 8,
        ['height'] = 19,
        ['speed'] = -200,

        ['green'] = {
            ['skin'] = 1},
        ['blue'] = {
            ['skin'] = 2},
    }
}

Enemies = {
    ['enemies-1'] = {
        ['width'] = 31,
        ['height'] = 34,
        ['count'] = 2,
        ['shootingInterval'] = 4
    },
    ['enemies-2'] = {
        ['width'] = 33,
        ['height'] = 38,
        ['count'] = 2,
        ['shootingInterval'] = 4
    },
    ['enemies-3'] = {
        ['width'] = 33,
        ['height'] = 35,
        ['count'] = 3,
        ['shootingInterval'] = 4 
    },
    ['enemies-4'] = {
        ['width'] = 50,
        ['height'] = 32,
        ['count'] = 4,
        ['shootingInterval'] = 3

    }
}

SpacecraftBullet = {
    [1] = {
        type = 'spheres',
        color = 'red'
    },
    [2] = {
        type = 'foot-longs',
        color = 'green'
    },
    [3] = {
        type = 'missiles',
        color = 'red'
    },
    [4] = {
        type = 'spheres',
        color = 'orange'
    },
    [5] = {
        type = 'projectiles',
        color = 'red'
    },
    [6] = {
        type = 'foot-longs',
        color = 'blue'
    },
    [7] = {
        type = 'rain-drops',
        color = 'blue'
    },
    [8] = {
        type = 'projectiles',
        color = 'purple'
    },
    [9] = {
        type = 'rain-drops',
        color = 'yellow',
    }

}

-- Will represent frames for rotating powerups like coins
GameObjects = {
    [4] = {
        texture = 'star-coins',
        frames = {1, 2, 3, 4, 5, 6}
    },
    [3] = {
        texture = 'gold-coins',
        frames = {1, 2, 3, 4, 5, 6, 7, 8}
    },
    [2] = {
        texture = 'silver-coins',
        frames = {1, 2, 3, 4, 5, 6, 7, 8}
    },
    [1] = {
        texture = 'copper-coins',
        frames = {1, 2, 3, 4, 5, 6, 7, 8}
    },
    
}


Origins = {
    [1] = {
        x = 30,
        y = VIRTUAL_HEIGHT - 60,
        rotation = math.rad(0),
        lock = false
    },
    [2] = {
        x = 90,
        y = VIRTUAL_HEIGHT / 2,
        rotation = math.rad(210),
        lock = false
    },
    [3] = {
        x = 60,
        y = 0,
        rotation = math.rad(160),
        lock = false
    },
    [4] = {
        x = 120,
        y = VIRTUAL_HEIGHT + 60,
        rotation = math.rad(45),
        lock = false
    },
    [5] = {
        x = 320,
        y = VIRTUAL_HEIGHT / 2,
        rotation = math.rad(135),
        lock = false
    },
    [6] = {
        x = 430,
        y = 0,
        rotation = math.rad(180),
        lock = false
    },
    [7] = {
        x = 210,
        y = 50,
        rotation = math.rad(250),
        lock = false
    },
    [8] = {
        x = -30,
        y = VIRTUAL_HEIGHT - 90,
        rotation = math.rad(0),
        lock = false
    },
    [9] = {
        x = 460,
        y = VIRTUAL_HEIGHT / 3,
        rotation = math.rad(270),
        lock = false
    },
}


-- some of the colors in our palette (to be used with particle systems)
paletteColors = {
    -- blue                 red
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green                blue
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red                  yellow
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold                 purple
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    },
    -- dark grey
    [6] = {
        ['r'] = 169,
        ['g'] = 169,
        ['b'] = 169
    }
}