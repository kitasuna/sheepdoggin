-- for player code

animal_behavior = {
  dog = {
    acc = 0.25,
    max_dx = 1,
    max_dy = 1,
    radius = 6,
    waddle = 0,
    sprite = {
      topLeft = 45,
      w = 2,
      h = 2,
    },
    mask = nil,
    friction = 0.85,
    flop = 0,
    text = "bark",
    sound = 2,
    sfx_id = 62,
  },
  mouse = {
    acc = 0.5,
    max_dx = 2,
    max_dy = 2,
    radius = 4,
    waddle = 0,
    sprite = {
      topLeft = 9,
      w = 2,
      h = 1,
    },
    mask = 16,
    friction = 0.85,
    flop = 0,
    text = "squeak",
    sound = 1,
    sfx_id = 58,
  },
  duck = {
    acc = 0.15,
    max_dx = 0.75,
    max_dy = 0.75,
    radius = 3,
    waddle = 0.6,
    sprite = {
      topLeft = 1,
      w = 1,
      h = 2,
    },
    mask = 16,
    friction = 0.85,
    flop = 0,
    text = "quack",
    sound = 2,
    sfx_id = 56,
  },
  fish = {
    acc = 0.10,
    max_dx = 3,
    max_dy = 3,
    radius = 4,
    waddle = 0,
    sprite = {
      topLeft = 41,
      w = 2,
      h = 1,
    },
    mask = 16,
    friction = 0.97,
    flop = 0.2,
    text = "flop",
    sound = 0.1,
    sfx_id = 57,
  },
}

STARTING_ANIMAL = "dog"

player = {}
function player:init()
  self.current_animal = STARTING_ANIMAL
  self.behavior = animal_behavior[STARTING_ANIMAL]
  self.x = 63
  self.y = 63
  self.dx = 0
  self.dy = 0
end

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
      if self.current_animal == "dog" then
          self.current_animal = "mouse"
      elseif self.current_animal == "mouse" then
          self.current_animal = "duck"
      elseif self.current_animal == "duck" then
          self.current_animal = "fish"
      elseif self.current_animal == "fish" then
          self.current_animal = "dog"
      end
  end
  if btnp(5) then
    if self.behavior.sfx_id then
      sfx(self.behavior.sfx_id)
    end
    new_bark(self.x + self.dx, self.y + self.dy, 4, 4, self.behavior.sound*self.dx, self.behavior.sound*self.dy)
  end
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
  -- dx and dy are applied in :resolve
  self.behavior = animal_behavior[self.current_animal]
end

function player:draw()
    local previousPalette = exportPalette()
    palt(0, false)
    palt(8, true)
    -- TODO: Add sprite flipping.
    local spritePos = self:pos() + self:spriteOffset()
    spr(
      self.behavior.sprite.topLeft,
      spritePos.x,
      spritePos.y,
      self.behavior.sprite.w,
      self.behavior.sprite.h
    )
    if self.behavior.mask then
      spr(
        self.behavior.mask,
        spritePos.x + (self.behavior.sprite.w - 1) * 8,
        spritePos.y,
        1,
        1
      )
    end
    for bark in all(barks) do
        bark:draw()
    end
    print(player.current_animal, 0, 0, 3)
    importPalette(previousPalette)
end

function player:spriteOffset()
  return v2(-self.behavior.sprite.w * 8 / 2, -self.behavior.sprite.h * 8 + 4)
end

function player:pos()
    return v2(self.x, self.y)
end

function player:collisionCirc()
    return Circ.fromCenterRadius(self:pos(), self.behavior.radius)
end

function player:influenceCirc()
    local pos = v2(self.x, self.y)
    return Circ.fromCenterRadius(pos, 14)
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

function player:nextAnimal()
  if self.current_animal == "dog" then
    self.current_animal = "mouse"
  elseif self.current_animal == "mouse" then
    self.current_animal = "duck"
  elseif self.current_animal == "duck" then
    self.current_animal = "fish"
  elseif self.current_animal == "fish" then
    current_gamestate = victory
  end
  self.behavior = animal_behavior[self.current_animal]
end

function player:reset()
  self.x = 63
  self.y = 63
  self.dx = 0
  self.dy = 0
  barks = {}
end

