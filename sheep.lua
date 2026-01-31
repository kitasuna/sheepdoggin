SheepMgr = {
  sheep = {},
  init = function(self)
    -- add(self.sheep, new_sheep(32, 32))
    for i=10,110,7 do
      for j=10,110,7 do
        local decision = rnd()
        if decision >= 0.9 then
          add(self.sheep, new_sheep(i+rnd(3),j+rnd(3)))
        end
      end
    end
  end,
  update = function(self, dt)
    for i, sheep in pairs(self.sheep) do
      sheep:update(dt) 
    end
  end,
  draw = function(self)
    for i, sheep in pairs(self.sheep) do
      sheep:draw() 
    end
  end,
}

SheepState = {
  Wait = "wait",
  Nibble = "nibble",
  Walk = "walk",
}

function new_sheep(x, y) 
  return {
    pos = v2(x,y),
    vel = v2(0,0),
    tgt_pos = nil,
    rad = 4,
    hops = {0,1,1,2,2,3,3,4,3,3,2,2,1,1,0},
    hop_index = 1,
    next_state = nil,
    flip_x = false,
    state_f = sheep_state_wait,
    state = SheepState.Wait,
    state_ttl = rnd(3),
    draw = function(self)
      palt(14, true)
      spr(144,
        self.pos.x,
        self.pos.y + self.hops[self.hop_index],
        1,1,
        self.flip_x
      )
      if self.state == SheepState.Nibble then
        print("yum", self.pos.x-3, self.pos.y-7, 3)
      end
      palt(14, false)
    end,
    update = function(self, dt)
      -- do current state actions
      self:state_f(dt)

      if self.state_ttl <= 0 then
        -- choose next action 
        local decision = rnd(1)

        if decision <= 0.3 then
          self.state = SheepState.Wait
          self.state_f = sheep_state_wait
        elseif decision > 0.3 and decision <= 0.8 then
          self.state = SheepState.Walk
          self.state_f = sheep_state_walk
          local circpt = rnd()
          self.tgt_pos = v2(
            self.pos.x + (10 * cos(circpt)),
            self.pos.y + (10 * sin(circpt))
          )
        else
          -- wait longer  
          self.state = SheepState.Nibble
          self.state_f = sheep_state_nibble
        end
        self.state_ttl = rnd(3)
      end
    end,
  }
end

function sheep_state_wait(sheep, dt)
  sheep.state_ttl = sheep.state_ttl - dt
end

function sheep_state_nibble(sheep, dt)
  sheep.state_ttl = sheep.state_ttl - dt
end

function sheep_state_walk(sheep, dt)
  -- we're close to the tgt, so just cheat and change state
  local remaining = sheep.tgt_pos:sub(sheep.pos)
  if abs(remaining.x) < 1 and abs(remaining.y) < 1 then
    sheep.pos.x = sheep.tgt_pos.x
    sheep.pos.y = sheep.tgt_pos.y
    sheep.tgt_pos = nil
    sheep.state_ttl = rnd(2)
    sheep.state = SheepState.Wait
    sheep.state_f = sheep_state_wait
    sheep.hop_index = 1
    return
  end

  if remaining.x < 0 then
    sheep.flip_x = false
  else
    sheep.flip_x = true
  end

  -- otherwise, keep walkin
  sheep.pos.x += dt * remaining.x
  sheep.pos.y += dt * remaining.y
  sheep.hop_index += 1
  if sheep.hop_index > #sheep.hops then
    sheep.hop_index = 1
  end
end

