-- Needs v2

Circ = {}
function Circ:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Circ.fromCenterRadius(center, radius)
  return Circ:new{center = center, radius = radius}
end

function Circ:collides(other)
  return (self.center - other.center):len() < self.radius + other.radius
end

-- Returns the vector that would move the circle out of collision with `other`.
function Circ:reaction(other)
  local delta = other.center - self.center
  local dist = delta:len()
  local desiredDist = self.radius + other.radius
  return -delta:unit() * (desiredDist - dist)
end

Collision = {}
function Collision:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Collision.fromBodies(a,b)
  local aCirc = a:collisionCirc()
  local bCirc = b:collisionCirc()
  if aCirc:collides(bCirc) then
    return aCirc:reaction(bCirc)
  end
  return nil
end

Physics = {}
function Physics:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function averageVecs(vecs)
  local sum = v2(0,0)

  if #vecs == 0 then
    return sum
  end

  for vec in all(vecs) do
    sum = sum + vec
  end
  return sum / #vecs
end

--[[
Assume that every "body" has the following fns:
- collisionCirc() -> Circ
  - Returns the collision circle for the object.
- intention() -> Vec2
  - Returns the delta that the object would like to move.
- resolve(Vec2) -> nil
  - Updates the object to actually move by Vec2 amount.
  - TODO: Should this also include the intended vec?
]]
-- TODO: Map collision
function Physics:resolve(bodies)
  -- Probably just do a stupid n^2 approach for now. Scan through the list,
  -- higher things will move first and have priority.
  -- TODO: Maybe group by priority first? Or have the caller pass a list of
  -- lists that are ordered by priority?
  local bodyCollisions = {}
  for firstBodyI=1,#bodies do
    local firstBody = bodies[firstBodyI]
    for secondBodyI=firstBodyI+1,#bodies do
      -- printh("first " .. firstBodyI .. " second " .. secondBodyI)
      local secondBody = bodies[secondBodyI]
      local collision = Collision.fromBodies(firstBody, secondBody)
      if collision then
        if not bodyCollisions[firstBodyI] then
          bodyCollisions[firstBodyI] = {}
        end
        add(bodyCollisions[firstBodyI], collision/2)
        if not bodyCollisions[secondBodyI] then
          bodyCollisions[secondBodyI] = {}
        end
        add(bodyCollisions[secondBodyI], -collision/2)
      end
    end
  end

  -- resolve collisions and intentions
  for bodyI=1,#bodies do
    local collisions = bodyCollisions[bodyI]
    local body = bodies[bodyI]
    if not collisions then
      body:resolve(body:intention())
    else
      -- NOTE: We're mutating the collisions array here.
      add(collisions, body:intention())
      -- TODO: Actually, probably want to weight intention less strongly and
      -- collisions more strongly?
      local average = averageVecs(collisions)
      body:resolve(average)
    end
  end
end

physicstest = {}
function physicstest:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function physicstest:init()
  local c1 = Circ.fromCenterRadius(v2(0,0), 4)
  local c2 = Circ.fromCenterRadius(v2(3,0), 4)
  local col = c1:reaction(c2)
  printh("x " .. col.x .. " y " .. col.y)

  self.physics = Physics:new()
  self.bodyA = {
    pos = v2(0,0),
    rad = 4,
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.rad)
    end,
    intention = function(self)
      local vel = 0.6
      local delta = v2(0,0)
      if btn(0) then  -- left
        delta.x -= vel
      end
      if btn(1) then
        delta.x += vel
      end
      if btn(2) then
        delta.y -= vel
      end
      if btn(3) then
        delta.y += vel
      end
      return delta
    end,
    resolve = function(self, v)
      self.pos = self.pos + v
    end,
  }
  self.bodyB = {
    pos = v2(40,40),
    rad = 4,
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.rad)
    end,
    intention = function(self)
      return v2(0,0)
    end,
    resolve = function(self, v)
      self.pos = self.pos + v
    end,
  }
end

function physicstest:update()
  self.physics:resolve({self.bodyA, self.bodyB})
end

function physicstest:draw()
  cls()
  spr(1,self.bodyA.pos.x, self.bodyA.pos.y)
  spr(2,self.bodyB.pos.x, self.bodyB.pos.y)
end
