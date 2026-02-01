SheepMgr = {}
function SheepMgr:new(o)
  o = o or {
    sheep = {},
    sound_timer = rnd(5),
    clearedSheep = {},
    evac_sound_timer = 0,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function SheepMgr:update(dt)
  -- sound timer
  self.sound_timer -= dt
  if self.sound_timer <= 0 then
    sfx(63)
    self.sound_timer = rnd(20)
  end
  
  if self.evac_sound_timer > 0 then
    self.evac_sound_timer -= dt
    if self.evac_sound_timer <= 0 then
      sfx(-1, 3)  -- stop sound on channel 3 only
      self.evac_sound_timer = 0
    end
  end
  
  for i, sheep in pairs(self.sheep) do
    sheep:update(dt) 
  end
  for i, sheep in pairs(self.clearedSheep) do
    sheep:update(dt) 
  end


end

function SheepMgr:spawn()
  -- add(self.sheep, new_sheep(32, 32))
  for i=10,(45*8),7 do
    for j=20,(25*8),7 do
      local decision = rnd()
      if decision >= 0.99 and #self.sheep < 20 then
        add(self.sheep, new_sheep(i+rnd(3),j+rnd(3)))
      end
    end
  end
end

function SheepMgr:draw()
  local previousPalette = exportPalette()
  palt(0, false)
  palt(8, true)
  -- TODO: Draw these in Y order so that they can overlap.
  for i, sheep in pairs(self.sheep) do
    sheep:draw() 
  end

  for i, sheep in pairs(self.clearedSheep) do
    sheep:draw() 
  end

  importPalette(previousPalette)
end

SheepState = {
  Wait = "wait",
  Nibble = "nibble",
  Walk = "walk",
  Panic = "panic",
  Evac = "evac",
}

function new_sheep(x, y) 
  return {
    pos = v2(x,y),
    radius = 5,
    sprite = {
      topLeft = 11,
      w = 2,
      h = 2,
    },
    vel = v2(0,0),
    tgt_pos = nil,
    req_pos = v2(0,0),
    rad = 4,
    hops = {0,1,1,2,2,3,2,2,1,1,0},
    hop_index = 1,
    next_state = nil,
    flip_x = false,
    state_f = sheep_state_wait,
    state = SheepState.Wait,
    state_ttl = rnd(3),
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.radius)
    end,
    intention = function(self)
      if self.tgt_pos == nil then
        return v2(0,0)
      end

      local step = 0.1
      if self.state == SheepState.Panic then
        step = 0.25
      end

      self.req_pos = v2(
        self.tgt_pos:sub(self.pos).x * step,
        self.tgt_pos:sub(self.pos).y * step
      )
      -- printh("Tried to move "..delta.x..", "..delta.y)
      return self.req_pos
    end,
    resolve = function(self, delta)
      self.pos.x += delta.x
      self.pos.y += delta.y

      if self.state == SheepState.Wait then
        return
      end

      if self.tgt_pos == nil then
        return
      end

      local remaining = self.pos:sub(delta)
      if abs(remaining.x) <= 1 and abs(remaining.y) <=1 then
        -- printh("Arrived!")
        self.state = SheepState.Wait
        self.state_f = sheep_state_wait
        self.state_ttl = rnd(2)
        return
      end

      self.hop_index += 1
      if self.hop_index > #self.hops then
        self.hop_index = 1
      end
      -- we got a collision
      if self.req_pos.x != delta.x
        or self.req_pos.y != delta.y then
        self.state = SheepState.Wait
        self.state_f = sheep_state_wait
        self.state_ttl = rnd(2)
      end
    end,
    draw = function(self)
      -- NOTE: This relies on palette settings set in SheepMgr.
      spr(self.sprite.topLeft,
        self.pos.x - self.sprite.w * 8 / 2,
        self.pos.y - self.sprite.h * 8 + self.hops[self.hop_index],
        self.sprite.w, self.sprite.h,
        self.flip_x
      )
       if self.state == SheepState.Nibble then
         print("yum", self.pos.x - self.sprite.w * 8 / 2 - 3, self.pos.y - self.sprite.h * 8 - 7, 3)
       end
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
end

function sheep_to_panic(sheep, dir)
  sheep.state = SheepState.Panic
  sheep.tgt_pos = dir
end

function sheep_to_wait(sheep)
  sheep.state = SheepState.Wait
  sheep.state_ttl = rnd(2)
end

function sheep_to_evac(sheep)
  sheep.state = SheepState.Evac
  sheep.tgt_pos = v2(
    sheep.pos.x,
    -32
  )
  
  if sheep_mgr.evac_sound_timer <= 0 then
    sfx(61, 3)  -- play on channel 3 so that we can controll it
  end
  sheep_mgr.evac_sound_timer = 1
  
  add(sheep_mgr.clearedSheep, sheep)
  del(sheep_mgr.sheep, sheep)
  sheep.state_f = sheep_state_evac
end

function sheep_state_evac(sheep, dt)
  if sheep.pos.y >= 12 then
    sheep.pos.y -= 0.5
  end

  -- celebratory hop
  sheep.hop_index += 1
  if sheep.hop_index > #sheep.hops then
    sheep.hop_index = 1
  end
end
