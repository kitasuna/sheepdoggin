-- for player code

animal_behavior = {
  dog = {
    acc = 0.25,
    max_dx = 1,
    max_dy = 1,
    waddle = 0,
    sprite = 129,
    friction = 0.85,
    flop = 0,
    text = "bark",
    sound = 2,
  },
  mouse = {
    acc = 0.5,
    max_dx = 2,
    max_dy = 2,
    waddle = 0,
    sprite = 130,
    friction = 0.85,
    flop = 0,
    text = "squeak",
    sound = 1,
  },
  duck = {
    acc = 0.15,
    max_dx = 0.75,
    max_dy = 0.75,
    waddle = 0.6,
    sprite = 131,
    friction = 0.85,
    flop = 0,
    text = "quack",
    sound = 2,
  },
  fish = {
    acc = 0.10,
    max_dx = 3,
    max_dy = 3,
    waddle = 0,
    sprite = 132,
    friction = 0.97,
    flop = 0.2,
    text = "flop",
    sound = 0.1,
  },
}

STARTING_ANIMAL = "dog"

player = {
  x = 63,
  y = 63,
  dx = 0,
  dy = 0,
  mask = STARTING_ANIMAL,
  behavior = animal_behavior[STARTING_ANIMAL],
}

function player:update()
  self.dy *= self.behavior.friction
  self.dx *= self.behavior.friction

  -- controls
  if btn(⬆️) then
      self.dy -= self.behavior.acc
      self.dx += rnd(self.behavior.waddle)
      self.dx -= rnd(self.behavior.waddle)
  end
  if btn(⬇️) then
      self.dy += self.behavior.acc
      self.dx += rnd(self.behavior.waddle)
      self.dx -= rnd(self.behavior.waddle)
  end
  if btn(⬅️) then
      self.dx -= self.behavior.acc
      self.dy += rnd(self.behavior.waddle)
      self.dy -= rnd(self.behavior.waddle)
  end
  if btn(➡️) then
      self.dx += self.behavior.acc
      self.dy += rnd(self.behavior.waddle)
      self.dy -= rnd(self.behavior.waddle)
  end
  if btnp(4) then
      if self.mask == "dog" then
          self.mask = "mouse"
      elseif self.mask == "mouse" then
          self.mask = "duck"
      elseif self.mask == "duck" then
          self.mask = "fish"
      elseif self.mask == "fish" then
          self.mask = "dog"
      end
  end
  if (btnp(5)) new_bark(self.x + self.dx, self.y + self.dy, 4, 4, self.behavior.sound*self.dx, self.behavior.sound*self.dy)
  local i, j=1, 1
  while(barks[i]) do
      if barks[i]:update() then
          if i != j then
              barks[j] = barks[i]
              barks[i] = nil
          end
          j += 1
      else
          barks[i] = nil
      end
      i += 1
  end

  if btn(⬆️) == false and btn(⬇️) == false and btn(⬅️) == false and btn(➡️) == false then
      self.dx += rnd(self.behavior.flop)
      self.dx -= rnd(self.behavior.flop)
      self.dy += rnd(self.behavior.flop)
      self.dy -= rnd(self.behavior.flop)
  end

  self.dx = mid(-self.behavior.max_dx, self.dx, self.behavior.max_dx)
  self.dy = mid(-self.behavior.max_dy, self.dy, self.behavior.max_dy)
  -- self.x += self.dx
  -- self.y += self.dy
  self.behavior = animal_behavior[self.mask]
end

function player:draw()
    for bark in all(barks) do
        bark:draw()
    end
    print(player.mask, 0, 0, 3)
end

function player:collisionCirc()
    local pos = v2(self.x, self.y)
    -- update this 4,4 if we change player sprite size
    return Circ.fromCenterRadius(pos:add(v2(4,4)),4)
end

function player:influenceCirc()
    local pos = v2(self.x, self.y)
    -- update this 4,4 if we change player sprite size
    return Circ.fromCenterRadius(pos:add(v2(4,4)),14)
end

function player:intention()
  local delta = v2(
    self.dx,
    self.dy
  )
  return delta
end

function player:resolve(delta)
    if abs(delta.x) <= 0.2 and abs(delta.y) <= 0.2 then
        return
    end
    self.x += delta.x
    self.y += delta.y
end

-- handling barks
barks = {}
function bark_draw(o)
    print(o.text, o.x, o.y, 3)
end

function bark_update(b)
    b.dy *= 0.97
    b.dx *= 0.97
    b.x += b.dx
    b.y += b.dy
    b.time -= 1
    return b.time > 0
end

function new_bark(x, y, w, h, dx, dy)
    local b = {
        x=x, y=y, dx=dx, dy=dy, w=w, h=h,
        time = 40,
        update = bark_update,
        text = player.behavior.text,
        draw = bark_draw
    }
    add(barks, b)
    return b
end

