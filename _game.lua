function update_game(dt)
  player:update()
  SheepMgr:update(dt)
end

function draw_game()
  cls()
  player:draw()
  
  rectfill(0,0,128,128,7)
  palt(0,false)
  SheepMgr:draw()
  palt(0,true)
end
