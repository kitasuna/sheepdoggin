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
  local delta = self.center - other.center
  local radiusSum = self.radius + other.radius
  -- Check for the obvious case of one of the axes being greater than the
  -- combined radii.
  if abs(delta.x) > radiusSum or abs(delta.y) > radiusSum then
    return false
  end
  return delta:len() < self.radius + other.radius
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

function Physics:getCollidingTiles(body)
  local circ = body:collisionCirc()
  local upperLeft = circ.center - v2(circ.radius, circ.radius)
  local lowerRight = circ.center + v2(circ.radius, circ.radius)
  local tiles = {}
  for y=upperLeft.y\8,lowerRight.y\8 do
    for x=upperLeft.x\8,lowerRight.x\8 do
      -- Check flag 0 on the tile, if set it's a colliding tile.
      if fget(mget(x,y),0) then
        add(tiles, {x=x,y=y})
      end
    end
  end
  return tiles
end

-- Returns response vector for the body. The body must respect it.
function Physics:mapCollision(body)
  -- TODO: I'm starting with square square collision here because it's easier.
  -- We can do circle square later if we have time.
  local tiles = self:getCollidingTiles(body)
  for tile in all(tiles) do
  end
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
function Physics:bodyBodyCollisions(bodies)
  -- Probably just do a stupid n^2 approach for now. Scan through the list,
  -- higher things will move first and have priority.
  -- TODO: Maybe group by priority first? Or have the caller pass a list of
  -- lists that are ordered by priority?
  local bodyCollisions = {}
  for firstBodyI=1,#bodies do
    local firstBody = bodies[firstBodyI]
    for secondBodyI=firstBodyI+1,#bodies do
      local secondBody = bodies[secondBodyI]
      -- TODO: This should add the intentions to the positions before checking
      -- collision.
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
