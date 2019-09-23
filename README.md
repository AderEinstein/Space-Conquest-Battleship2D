# Space Conquest Battleship2D

A buoyant space exploration/shooting game. 
All the pieces are put together in this game to test your spatial awareness, reflexes, and speed while providing an ultimate fun experience!

# Game States
The game consists of a start, spaceship selection, start level, play , game over, enter highscore and a high score states in between which the user can easily navigate by following prompts or using buttons implemented on the screen.

In the start state a gif is loaded to the scene for the title of the game, a particle system is added to emulate a snow effect, and the spaceships are made to fly in orbital paths in the background.

In the selection state the player can select a spaceship of their choice which all differ by their bullets' texture and dimensions.

In the start level state the level gets announced while the player is allowed to get started before beginning the level in question. Levels are designed.
procedurally as Enemies become more agressive (i.e more variety of enemies, increase of their speed, shooting abilities etc).

In the play state the spaceship moves freely in space collecting coins/medals and avoids attacking enemies while shooting against them.

In the game over state we display the final score and findout whether the player made it to the highscore charts.

In the enter highscore level state we prompt the player to enter his/her name to position them in our highscore table.

Highscore state simply displays the highscores in the highscores table in a proper format.

# PowerUps
HP -- Allows the player to shoot bullet pairs giving it a greater hit impact.

Candy -- Increases player health by 1 unit.

Diamond -- Makes the player indestructible and harmfull to enemies.

Ice -- Freezes the player

# Techniques used
Shaders - To mark the player as indestructible.

2d Animation - For explosions, powerups.

Buttons - For mobile experience.

Gifs - Title.

Tweens - For fading in/out transitions and tweening the position for level announcements.

Timers - For attributing various durations to our powerup collection, (enemy) shooting ability and state transitions.

State Machine - To manage the various states.

Persistent data saving - HighScores.

Particle systems - Snow effect at intro, collection of gameObjects.

Enemy AI.

Collision Detection.
