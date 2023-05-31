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

SCORE_TO_WIN = 10

PADDLE_SPEED = 200

function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallerFont = love.graphics.newFont('font.ttf', 8)
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

    servingPlayer = math.random(2)
    winningPlayer = 0

    player1 = Paddle(10, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, BALL_WIDTH, BALL_HEIGHT)

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-100, 100)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
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
    

        if ball.x < 0 - ball.width then
            servingPlayer = 1
            player2Score = player2Score + 1
            
            if player2Score == SCORE_TO_WIN then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            
            if player1Score == SCORE_TO_WIN then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
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
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallerFont)
        love.graphics.printf('Press ENTER to start', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallerFont)
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallerFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then 

    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallerFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
