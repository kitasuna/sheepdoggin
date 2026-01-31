function update_game(dt)
  player:update()
  sheep_mgr:update(dt)
  enemy:update()
  --_camera_update()
  --_update_animation()
  local stuff = 
  physics:bodyBodyCollisions(merge(sheep_mgr.sheep, {player}))


  -- dog / sheep collision time
  local dogCirc = player:influenceCirc()
  for i, sheep in pairs(sheep_mgr.sheep) do
    local sheepCirc = sheep:collisionCirc() 
    if sheep.state != SheepState.Panic and dogCirc:collides(sheepCirc) then
      local dir = v2(
        sheep.pos.x+(sheep.pos.x - player.x),
        sheep.pos.y+(sheep.pos.y - player.y)
      )
      sheep_to_panic(sheep, dir)
    elseif sheep.state == SheepState.Panic then
      sheep_to_wait(sheep)
    end
  end
  physics:resolve(merge(sheep_mgr.sheep, {player, enemy}))
end

function draw_game()
  cls()
  
  rectfill(0,0,128,128,7)
  player:draw()
  _camera_draw()
  _draw_animation()
  enemy:draw()
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
