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
    print("\^o9ffpress \151 or \142 to bark", 22, 96, 3)
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
    rectfill(0,0,128,128,8)
    print("\^o9ffdespite your best efforts", 15, 5, 3)
    print("\^o9ffthe fox pulled the wool", 19, 15, 3)
    print("\^o9ffover your eyes", 38, 25, 3)
    print("\^o9ffback to title?", 38, 110, 3)
    print("\^o9ffpress \151 or \142", 38, 120, 3)
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
    rectfill(0,0,128,128,8)
    print("\^o9ffthe sheepdog soul", 30, 5, 3)
    print("\^o9ffburns bright within you", 20, 15, 3)
    print("\^o9ffyou herded "..#sheep_mgr.clearedSheep.."\^o9ff sheep", 30, 37, 3)
    print("\^o9ffback to title?", 38, 110, 3)
    print("\^o9ffpress \151 or \142", 38, 120, 3)
end
