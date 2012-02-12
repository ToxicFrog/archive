love.graphics.setBackgroundColor(0,0,0)

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("GAME OVER", 400, 280, 0, "center")
    love.graphics.printf("Score: "..love.score, 400, 320, 0, "center")
end

function love.update()
end

function love.mousepressed()
end
