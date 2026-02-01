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
    camera()
    cls()
    -- print("sheepdoggin'!", 37, 37, 3)
    rectfill(0,0,128,128,8)
    map(75,9,8,12,14,11)
    print("\^o9ffpress \151 or \142", 38, 96, 3)
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
    camera()
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
    camera()
    cls()
    print("you win!", 37, 37, 3)
    print("restart", 50, 80, 3) 
end
