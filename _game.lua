MAP_WIDTH = 128
MAP_HEIGHT = 128

function init_game()
  _now = time()
  _last_ts = _now

  sheep_mgr = SheepMgr:new()
  sheep_mgr:spawn()
  physics = Physics:new()
  enemy = Enemy:new()

  --__update = update_title
  --__draw = draw_title
  __update = update_game
  __draw = draw_game
  _init_animation()
end

function update_game(dt)
  player:update()
  sheep_mgr:update(dt)
  enemy:update()
  --_camera_update()
  --_update_animation()

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
  physics:resolveCollisions(merge(sheep_mgr.sheep, {player, enemy}))
  _update_animation()
end

function draw_game()
  _camera_draw()
  player:draw()
  enemy:draw()
  palt(0,false)
  sheep_mgr:draw()
  palt(0,true)
  --_draw_animation()
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
