-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- allows OOP 
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'

-- used for timers and tweening
Timer = require 'lib/knife.timer'

require 'love.image'
-- For loading and reading gifs
-- https://notabug.org/pgimeno/gifload
GifNew = require ('lib.gifload.gifload.gifload')

-- a few global constants, centralized
require 'src/constants'
-- A combat Helicopter
require 'src/Helicopter'
-- Bullets
require 'src/Bullet'
-- a Pair of Bullets for collecting a powerUp
require 'src/BulletSet'

require 'src/Animation'
require 'src/Explosion'
require 'src/Enemy'
require 'src/GameObject'
require 'src/Spaceship'

-- a powerUp 
require 'src/PowerUp'

-- Nav Buttons for mobile
require 'src/Button'

-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'src/StateMachine'

-- utility functions, mainly for splitting our sprite sheet into various Quads
-- of differing sizes for Helicopters, bullets etc.
require 'src/Util'

-- each of the individual states our game can be in at once; each state has
-- its own update and render methods that can be called by our state machine
-- each frame, to avoid bulky code in main.lua
require 'src/states/BaseState'
require 'src/states/EnterHighScoreState'
require 'src/states/GameOverState'
require 'src/states/HighScoreState'
require 'src/states/HelicopterSelectState'
require 'src/states/PlayState'
require 'src/states/StartLevelState'
require 'src/states/StartState'
require 'src/states/VictoryState'


-- initialize our nice-looking retro text fonts
gFonts = {
    ['small'] = love.graphics.newFont('fonts/zelda.otf', 14),
    --['small-normal'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['small-normal'] = love.graphics.newFont('fonts/FFF_Tusj.ttf', 10),
    ['medium'] = love.graphics.newFont('fonts/zelda.otf', 20),
    --['medium-normal'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['medium-normal'] = love.graphics.newFont('fonts/FFF_Tusj.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/zelda.otf', 35),
    --['large-normal'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['large-normal'] = love.graphics.newFont('fonts/FFF_Tusj.ttf', 32)
}

-- load up the graphics we'll be using throughout our states
gTextures = {
    ['background-game'] = love.graphics.newImage('graphics/stars.png'),
    ['background-intro1'] = love.graphics.newImage('graphics/background.png'),
    ['background-intro2'] = love.graphics.newImage('graphics/background1.png'),
    ['background-intro3'] = love.graphics.newImage('graphics/background2.png'),
    ['background-intro4'] = love.graphics.newImage('graphics/background3.jpg'),
    ['background-game-over'] = love.graphics.newImage('graphics/GameOver.jpg'),
    ['main'] = love.graphics.newImage('graphics/breakout.png'), 
    ['helicopters'] = love.graphics.newImage('graphics/helicopters.png'),
    ['enemies'] = love.graphics.newImage('graphics/enemies.png'),
    ['explosions'] = love.graphics.newImage('graphics/explosion.png'),
    ['bullets'] = love.graphics.newImage('graphics/bullets.png'),
    ['powerups'] = love.graphics.newImage('graphics/powerups.png'),
    ['bullets'] = love.graphics.newImage('graphics/bullets.png'),
    ['star-coins'] = love.graphics.newImage('graphics/star-coin.png'),
    ['gold-coins'] = love.graphics.newImage('graphics/gold-coin.png'),
    ['silver-coins'] = love.graphics.newImage('graphics/silver-coin.png'),
    ['copper-coins'] = love.graphics.newImage('graphics/copper-coin.png'),
    ['gamepad-up'] = love.graphics.newImage('graphics/gamepad-up.png'),
    ['gamepad-left'] = love.graphics.newImage('graphics/gamepad-left.png'),
    ['gamepad-down'] = love.graphics.newImage('graphics/gamepad-down.png'),
    ['gamepad-right'] = love.graphics.newImage('graphics/gamepad-right.png'),
    ['gamepad-move'] = love.graphics.newImage('graphics/gamepad-move.png'),
    ['gamepad-shoot'] = love.graphics.newImage('graphics/gamepad-shoot.png'),
    ['gamepad-speedup'] = love.graphics.newImage('graphics/gamepad-speedup.png'),

    ['ice'] = love.graphics.newImage('graphics/ice.png'),
    ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png'),
    ['particle-intro'] = love.graphics.newImage('graphics/particle-intro.png'),
    ['select-button'] = love.graphics.newImage('graphics/select.png'),
    ['instructions'] = love.graphics.newImage('graphics/instructions.png'),
    
}

-- Quads we will generate for all of our textures; Quads allow us
-- to show only part of a texture and not the entire thing
gFrames = {

    ['select-button'] = GenerateQuads(gTextures['select-button'], 71, 25),
    ['instructions'] = GenerateQuads(gTextures['instructions'], 191, 105),
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['helicopters'] = GenerateQuads(gTextures['helicopters'], 60, 60),
    ['explosions'] = GenerateQuads(gTextures['explosions'], 70, 70),
    ['star-coins'] = GenerateQuads(gTextures['star-coins'], 22, 22),
    ['gold-coins'] = GenerateQuads(gTextures['gold-coins'], 32, 32),
    ['silver-coins'] = GenerateQuads(gTextures['silver-coins'], 32, 32),
    ['copper-coins'] = GenerateQuads(gTextures['copper-coins'], 32, 32),

    ['enemies-1'] = GenerateQuadsBullets(gTextures['enemies'], 0, 31, 34, 2),
    ['enemies-2'] = GenerateQuadsBullets(gTextures['enemies'], 34, 33, 38, 2),
    ['enemies-3'] = GenerateQuadsBullets(gTextures['enemies'], 72, 33, 35, 3),
    ['enemies-4'] = GenerateQuadsBullets(gTextures['enemies'], 107, 50, 32, 4),

    ['projectiles'] = GenerateQuadsBullets(gTextures['bullets'], 0, 14, 22, 4),
    ['missiles'] = GenerateQuadsBullets(gTextures['bullets'], 22, 13, 25, 2),
    ['rain-drops'] = GenerateQuadsBullets(gTextures['bullets'], 47, 13, 21, 3),
    ['spheres'] = GenerateQuadsBullets(gTextures['bullets'], 68, 13, 13, 7),
    ['foot-longs'] = GenerateQuadsBullets(gTextures['bullets'], 81, 8, 19, 2),

    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
    ['powerups'] = GenerateQuads(gTextures['powerups'], 24, 24),
    ['powerUps'] = GeneratePowerUps(gTextures['main']),
}
-- set up our sound effects
gSounds = {
    ['shot'] = love.audio.newSource('sounds/shot.mp3'),
    ['pickup'] = love.audio.newSource('sounds/pickup.wav'),
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav'),
    ['score'] = love.audio.newSource('sounds/score.wav'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav'),
    ['select'] = love.audio.newSource('sounds/select.wav'),
    ['no-select'] = love.audio.newSource('sounds/no-select.wav'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav'),
    ['victory'] = love.audio.newSource('sounds/victory.wav'),
    ['recover'] = love.audio.newSource('sounds/recover.wav'),
    ['high-score'] = love.audio.newSource('sounds/high_score.wav'),
    ['pause'] = love.audio.newSource('sounds/pause.wav'),
    ['paddle_growth'] = love.audio.newSource('sounds/paddle_growth.wav'),
    ['paddle_shrink'] = love.audio.newSource('sounds/paddle_shrink.wav'),
    ['explosion'] = love.audio.newSource('sounds/explosion.wav'),
    ['pickup'] = love.audio.newSource('sounds/pickup.wav'),
    ['bullet_powerup'] = love.audio.newSource('sounds/bullet_powerup.mp3'),

    ['music-game'] = love.audio.newSource('sounds/game.mp3'),
    ['music-intro'] = love.audio.newSource('sounds/game-intro.mp3'),
}

-- the state machine we'll be using to transition between various states
-- in our game instead of clumping them together in our update and draw
-- methods
--
-- our current game state can be any of the following:
-- 1. 'start' (the beginning of the game, where we're told to press Enter)
-- 2. 'helicopter-select' (where we get to choose the color of our helicopter)
-- 3. 'start-level' (waiting on a key press to start level)
-- 4. 'play' (the helicopter is free to move in space, destroy enemies and collect coins)
-- 5. 'victory' (the current level is over, with a victory jingle)
-- 6. 'game-over' (the player has lost; display score and allow restart)
gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end,
    ['start-level'] = function() return StartLevelState() end,
    ['game-over'] = function() return GameOverState() end,
    ['victory'] = function() return VictoryState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['enter-high-score'] = function() return EnterHighScoreState() end,
    ['helicopter-select'] = function() return HelicopterSelectState() end

}
