Transition = {}

function Transition:new(o)
  o = o or {
    swapstart = 0,
    active = false,
    player_reset = false,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Transition:start()
  self.swapstart = time()
  self.active = true
  self.player_reset = false
end

function Transition:update()
  if not self.active then
    return
  end
  
  local t = time() - self.swapstart
  
  -- reset player to start position
  if t >= 1.2 and not self.player_reset then
    player:reset()
    player:nextAnimal()
    self.player_reset = true
  end
  
  -- transition ends after 2.2 seconds
  if t > 2.2 then
    self.active = false
    -- respawn sheep for next level
    sheep_mgr.clearedSheep = {}
    sheep_mgr:spawn()
  end
end

function Transition:draw()
  if not self.active then
    return
  end
  
  -- reset camera for transition
  camera()
  
  local t = time() - self.swapstart
  
  if t > 0 and t < 1.2 then
    self:horizbars(t)
  elseif t > 0 then
    self:vertbars_in(t)
  end
end

function Transition:horizbars(t)
  -- draw black bars
  local a = 0
  for y = 0, 127 do
    a = flr(t * 59)
    if y % 2 == 0 then
      line(127, y, 127 - a, y, 0)
    else
      line(0, y, a, y, 0)
    end
  end
  
  -- copy data from screen left/right
  local offset = flr(t * 30)
  for y = 0, 127 do
    local scr = 0x6000 + (y * 64)
    if y % 2 == 0 then
      if offset < 64 then
        memcpy(scr, scr + offset, 64 - offset)
      end
    else
      if offset < 64 then
        memcpy(scr + offset, scr, 64 - offset)
      end
    end
  end
end

function Transition:vertbars_in(t)
  local a = 0
  for x = 0, 127 do
    a = flr((2.2 * 120) - t * 120)
    if x % 2 == 0 then
      line(x, -1, x, a, 0)
    else
      line(x, 128, x, 127 - a, 0)
    end
  end
end
