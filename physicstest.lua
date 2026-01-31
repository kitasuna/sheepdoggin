DummyBody = {}
function DummyBody:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function DummyBody.fromCenterRadius(center, r)
  return DummyBody:new{
    collisionCircle = Circ.fromCenterRadius(center, r)
  }
end

function DummyBody:collisionCirc()
  return self.collisionCircle
end

function DummyBody:intention()
  -- Ohhh yeah, we're super dumb.
  return v2(0,0)
end

function DummyBody:resolve(v)
  self.collisionCircle.center += v
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
  self.player = {
    pos = v2(0,0),
    radius = 10,
    collisionCirc = function(self)
      return Circ.fromCenterRadius(self.pos, self.radius)
    end,
    intention = function(self)
      local vel = 2.0
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
  self.dummies = {}
  for x=1,4 do
    for y=1,4 do
      add(self.dummies, DummyBody.fromCenterRadius(v2(40+x*8,40+y*8), 4))
    end
  end
end

function physicstest:update()
  local bodies = {self.player}
  for body in all(self.dummies) do
    add(bodies, body)
  end
  self.physics:resolveCollisions(bodies)
end

function physicstest:draw()
  cls()
  spr(1,self.player.pos.x - 4, self.player.pos.y - 4)
  for body in all(self.dummies) do
    local circ = body:collisionCirc()
    spr(2,circ.center.x - circ.radius, circ.center.y - circ.radius)
  end
end
