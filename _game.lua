function update_game(dt)
  player:update()
  sheep_mgr:update(dt)
  physics:resolve(sheep_mgr.sheep)
end

function draw_game()
  cls()
  player:draw()
  
  rectfill(0,0,128,128,7)
  palt(0,false)
  sheep_mgr:draw()
  palt(0,true)
end
