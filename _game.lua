MAP_WIDTH = 128
MAP_HEIGHT = 128

function init_game()
  _now = time()
  _last_ts = _now

  sheep_mgr = SheepMgr:new()
  sheep_mgr:spawn()
  physics = Physics:new()
  enemy = Enemy:new()
  level = Level:new()
  level:setGoal(52,
    8,
    24,
    8
  )

  --__update = update_title
  --__draw = draw_title
  __update = update_game
  __draw = draw_game
  _init_animation()
end

function update_game(dt)
  player:update()
  sheep_mgr:update(dt)
  -- enemy:update()
  --_camera_update()
  --_update_animation()

  -- dog / sheep collision time
  local dogCirc = player:influenceCirc()
  local dogPosVec = v2(player.x, player.y)
  local dogVelVec = v2(player.dx, player.dy)
  local dottedDog = dogPosVec:dot(dogVelVec)
  if player.dx != 0 or player.dy != 0 then
    for i, sheep in pairs(sheep_mgr.sheep) do
      local sheepCirc = sheep:collisionCirc() 
      local dogSheepVec = sheep.pos - dogPosVec
      local dotted = dogVelVec:dot(dogSheepVec)
      if abs(dogSheepVec.x) < 14 and abs(dogSheepVec.y) < 14 then
        local toSheepMag = sqrt(dogSheepVec.x^2 + dogSheepVec.y^2)
        local dogVelMag = sqrt(dogVelVec.x^2 + dogVelVec.y^2)
        local cosTheta = dotted / (dogVelMag * toSheepMag)
        if toSheepMag > 0.001
          and dogVelMag > 0.001 
          and sheep.state != SheepState.Panic
          and cosTheta >= cos(0.3) then
            local dir = v2(
              player.x + (player.dx * 20),
              player.y + (player.dy * 20)
            )
            sheep_to_panic(sheep, dir)
          end
      elseif sheep.state == SheepState.Panic then
        sheep_to_wait(sheep)
      end
    end
  end

  -- sheep / goal collision stuff
  local topLeft, bottomRight = level:getGoalCorners()
  for i, sheep in pairs(sheep_mgr.sheep) do
    if sheep.state == SheepState.Panic and sheep:collisionCirc():collidesRect(topLeft, bottomRight) then
      sheep_to_evac(sheep)
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
  level:draw()
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
