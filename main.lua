push = require 'push'

Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = WINDOW_WIDTH / 4
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 4

BALL_WIDTH = 4
BALL_HEIGHT = 4

TOP_BALL_LIMIT = 0
BOTTOM_BALL_LIMIT = VIRTUAL_HEIGHT - BALL_HEIGHT

PADDLE_SPEED = 200

function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
    })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, BALL_WIDTH, BALL_HEIGHT)

    gameState = 'start'
end

function love.update(dt)
    if gameState == 'play' then
        if ball:collides(player1) or ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.dy = -ball.dy / ball.dy * math.random(10, 150)

            if ball:collides(player1) then
                ball.x = player1.x + player1.width
            end

            if ball:collides(player2) then
                ball.x = player2.x - player2.width
            end
        end

        if ball.y <= TOP_BALL_LIMIT then
            ball.dy = -ball.dy
            ball.y = TOP_BALL_LIMIT
        end

        if ball.y >= BOTTOM_BALL_LIMIT then
            ball.dy = -ball.dy
            ball.y = BOTTOM_BALL_LIMIT
        end
    end

    if ball.x < 0 - ball.width then
        servingPlayer = 1
        player2Score = player2Score + 1
        ball:reset()
        gameState = 'start'
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        ball:reset()
        gameState = 'start'
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' or key == 'q' then
        love.event.quit()
    elseif key == 'return' or key == 'enter' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            ball:reset()
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    love.graphics.printf('Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    player1:render()
    player2:render()

    ball:render()


    push:apply('end')
end
