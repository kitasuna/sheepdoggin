Enemy = {}

function Enemy:new(o)
  o = o or {
    x = 20,
    y = 20,
    dx = 0,
    dy = 0,
    radius = 4,
    sprite = {
      topLeft = 193,
      w = 2,
      h = 2,
    },
    speed = 0.8,
    target_sheep = nil,
    confused_timer = 0,
    confused_dx = 0,
    confused_dy = 0,
  }
  setmetatable(o, self)
  self.__index = self
  sfx(60)
  return o
end

function Enemy:update()
    -- decrease confused timer
    if self.confused_timer > 0 then
      self.confused_timer -= 1/30
    end
    
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
    
    -- move towards target sheep or randomly if confused
    if self.confused_timer > 0 then
      -- run confusedly
      self.dx = self.confused_dx
      self.dy = self.confused_dy
    elseif self.target_sheep then
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
    local enemy_circ = self:collisionCirc()
    for i, sheep in pairs(sheep_mgr.sheep) do
      if enemy_circ:collides(sheep:collisionCirc()) then
        del(sheep_mgr.sheep, sheep)
        sfx(55)
        break
      end
    end
    
    -- check collision with barks
    for i, bark in pairs(barks) do
      if enemy_circ:collides(bark:collisionCirc()) then
        if self.confused_timer <= 0 then
          -- set new random direction only when first confused
          local angle = rnd(1)
          self.confused_dx = cos(angle) * self.speed * 3
          self.confused_dy = sin(angle) * self.speed * 3
        end
        self.confused_timer = 1.5
      end
    end
end

function Enemy:draw()
  local previousPalette = exportPalette()
  palt(0, false)
  palt(8, true)
  spr(self.sprite.topLeft, self.x - self.sprite.w * 8 / 2, self.y - self.sprite.h * 8 + self.radius, self.sprite.w, self.sprite.h)
  importPalette(previousPalette)
end

function Enemy:collisionCirc()
  local pos = v2(self.x, self.y)
  return Circ.fromCenterRadius(pos, self.radius)
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
