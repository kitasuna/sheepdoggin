-- title stuff
title = {}

function title:init()
end

function title:update(dt)
    if btnp(4) or btnp(5) then
        current_gamestate = game
        current_gamestate:init()
    end
end

function title:draw()
    cls()
    print("sheepdoggin'!", 37, 37, 3)
    print("start", 50, 80, 3)
end

-- lose stuff
gameover = {}
function gameover:init()

end

function gameover:update(dt)
    if btnp(4) or btnp(5) then
        current_gamestate = title
        current_gamestate:init()
    end
end

function gameover:draw()
    cls()
    print("game over ;_;", 37, 37, 3)
    print("restart", 50, 80, 3) 
end

-- win stuff
victory = {}
function victory:init()

end

function victory:update(dt)
    if btnp(4) or btnp(5) then
        current_gamestate = title
        current_gamestate:init()
    end
end

function victory:draw()
    cls()
    print("you win!", 37, 37, 3)
    print("restart", 50, 80, 3) 
end