function update_title(dt)
    if btn(4) or btn(5) then
        __update = update_game
        __draw = draw_game
    end
end

function draw_title(dt)
    cls()
    print("sheepdoggin'!", 37, 37, 3)
    print("start", 50, 80, 3)
end
