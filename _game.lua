function update_game(dt)
  SheepMgr:update(dt)
end

function draw_game()
  cls()
  
  rectfill(0,0,128,128,3)
  palt(0,false)
  SheepMgr:draw()
  palt(0,true)
end
