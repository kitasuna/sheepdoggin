function update_game(dt)
  player:update()
  sheep_mgr:update(dt)
  --_camera_update()
  --_update_animation()
  local stuff = 
  physics:bodyBodyCollisions(merge(sheep_mgr.sheep, {player}))
end

function draw_game()
  cls()
  
  rectfill(0,0,128,128,7)
  player:draw()
  _camera_draw()
  _draw_animation()
  palt(0,false)
  sheep_mgr:draw()
  palt(0,true)
  print("cpu: " .. stat(1),0,10)

end

function merge(t0, t1)
	local t2 = {}
	for k,v in pairs(t0) do
		add(t2, v)
	end
	for k,v in pairs(t1) do
		add(t2, v)
	end
	return t2
end
