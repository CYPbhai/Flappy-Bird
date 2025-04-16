push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

BACKGROUND_SCROLL_SPEED = 30
GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle('Flappy Bird')

    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['BGM'] = love.audio.newSource('sounds/BGM.mp3', 'static')
    }

    sounds['BGM']:setLooping(true)
    sounds['BGM']:play()

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['title'] = function ()
            return TitleScreenState()
        end,
        ['play'] = function ()
            return PlayState()
        end,
        ['score'] = function()
            return ScoreState()
        end,
        ['countdown'] = function()
            return CountdownState()
        end
    }
    gStateMachine:change('title')

    love.keyboard.keysPressed = {}

    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    push:resize(w,h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key]=true
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'p' then
        if scrolling == true then
            scrolling = false
        else
            scrolling = true
        end
    end
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    if scrolling == true then
    backgroundScroll = (backgroundScroll+BACKGROUND_SCROLL_SPEED*dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll+GROUND_SCROLL_SPEED*dt) % VIRTUAL_WIDTH
    end
    gStateMachine:update(dt)
    love.keyboard.keysPressed={}
    love.mouse.buttonsPressed={}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)

    gStateMachine:render()

    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
    push:finish()
end