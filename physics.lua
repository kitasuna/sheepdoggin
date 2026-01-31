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

function Circ:overlap(other)
  local delta = self.center - other.center
  local dist = delta:len()
  local desiredDist = self.radius + other.radius
  return delta:unit() * (desiredDist - dist)
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
    return -aCirc:overlap(bCirc)
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
  local collisions = {}
  for firstBodyI=1,#bodies do
    local firstBody = bodies[firstBodyI]
    for secondBodyI=firstBodyI+1,#bodies do
      -- printh("first " .. firstBodyI .. " second " .. secondBodyI)
      local secondBody = bodies[secondBodyI]
      local collision = Collision.fromBodies(firstBody, secondBody)
      if collision then
        if not collisions[firstBodyI] then
          collisions[firstBodyI] = {}
        end
        add(collisions[firstBodyI], collision)
        if not collisions[secondBodyI] then
          collisions[secondBodyI] = {}
        end
        add(collisions[secondBodyI], -collision)
      end
    end
  end
  -- resolve
  for i, collision in pairs(collisions) do
    printh("object" .. i)
    printh("collisions" .. #collisions)
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
  self.physics = Physics:new()
  self.bodyA = {
    pos = v2(0,0),
    rad = 4,
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.rad)
    end,
  }
  self.bodyB = {
    pos = v2(40,40),
    rad = 4,
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.rad)
    end,
  }
end

function physicstest:update()
  local vel = 0.3
  if btn(0) then
    self.bodyA.pos.x -= vel
  end
  if btn(1) then
    self.bodyA.pos.x += vel
  end
  if btn(2) then
    self.bodyA.pos.y -= vel
  end
  if btn(3) then
    self.bodyA.pos.y += vel
  end
  self.physics:resolve({self.bodyA, self.bodyB})
end

function physicstest:draw()
  cls()
  spr(1,self.bodyA.pos.x, self.bodyA.pos.y)
  spr(2,self.bodyB.pos.x, self.bodyB.pos.y)
end
