function update_game(dt)
  player:update()
end

function draw_game(dt)
  cls()
  player:draw()
end
