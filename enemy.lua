Enemy = {}

function Enemy:new(o)
  o = o or {
    x = 20,
    y = 20,
    dx = 0,
    dy = 0,
    speed = 1.0,
    max_speed = 1.5,
    sprite = 152,
    target_sheep = nil,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Enemy:update()
    -- find closest sheep
    local closest_dist = 9999
    self.target_sheep = nil
    
    for i, sheep in pairs(sheep_mgr.sheep) do
      local dist = abs(sheep.pos.x - self.x) + abs(sheep.pos.y - self.y)
      if dist < closest_dist then
        closest_dist = dist
        self.target_sheep = sheep
      end
    end
    
    -- move towards target sheep
    if self.target_sheep then
      local dx = self.target_sheep.pos.x - self.x
      local dy = self.target_sheep.pos.y - self.y
      
      if dx > 0 then
        self.dx = self.speed
      elseif dx < 0 then
        self.dx = -self.speed
      else
        self.dx = 0
      end
      
      if dy > 0 then
        self.dy = self.speed
      elseif dy < 0 then
        self.dy = -self.speed
      else
        self.dy = 0
      end
    end
    
    -- check collision with sheep
    for i, sheep in pairs(sheep_mgr.sheep) do
      local dist = sqrt((sheep.pos.x - self.x)^2 + (sheep.pos.y - self.y)^2)
      if dist < 8 then  -- collision distance
        del(sheep_mgr.sheep, sheep)
        break
      end
    end
end

function Enemy:draw()
  spr(self.sprite, self.x, self.y)
end

function Enemy:collisionCirc()
  local pos = v2(self.x, self.y)
  return Circ.fromCenterRadius(pos:add(v2(4,4)), 4)
end

function Enemy:intention()
  return v2(self.dx, self.dy)
end

function Enemy:resolve(new_pos)
  if abs(new_pos.x) <= 0.2 and abs(new_pos.y) <= 0.2 then
    return
  end
  self.x += new_pos.x
  self.y += new_pos.y
end
