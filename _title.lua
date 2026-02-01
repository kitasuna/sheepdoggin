-- title stuff
title = {}

function title:init()
  music(42)
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
  music(32)
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
    map(57, 8, 0, 0, 16, 16)
    palt(8, true)
    spr(243, 7*8, 12*8, 2, 1) -- fox
    palt(8, false)
    print("\^o9ffdespite your best efforts", 15, 5, 3)
    print("\^o9ffthe fox pulled the wool", 19, 15, 3)
    print("\^o9ffover your eyes", 38, 25, 3)
    print("\^o9ffback to title?", 38, 110, 3)
    print("\^o9ffpress \151 or \142", 38, 120, 3)
end

-- win stuff
victory = {}
function victory:init()
  music(-1,4000)
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
    map(57, 8, 0, 0, 16, 16)
    palt(8, true)
    spr(197, 4*8, 8*8, 2, 2) -- sheep
    spr(229, 4*8, 10*8, 2, 2) -- fish
    spr(247, 6*8, 10*8, 2, 1) -- mouse
    spr(217, 8*8, 10*8, 2, 1) -- frog
    spr(249, 7*8, 11*8, 2, 1) -- dog
    spr(203, 10*8, 8*8, 4, 4) -- giraffe
    spr(215, 9*8, 9*8, 2, 1) -- duck
    spr(243, 7*8, 12*8, 2, 1) -- fox
    palt(8, false)
    print("\^o9ffthe sheepdog soul", 30, 5, 3)
    print("\^o9ffburns bright within you", 20, 15, 3)
    print("\^o9ffyou herded "..#total_sheep.."\^o9ff sheep", 30, 37, 3)
    print("\^o9ffback to title?", 38, 110, 3)
    print("\^o9ffpress \151 or \142", 38, 120, 3)
end
