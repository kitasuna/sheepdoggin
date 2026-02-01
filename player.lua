-- for player code

animal_behavior = {
  dog = {
    acc = 0.25,
    max_dx = 1,
    max_dy = 1,
    radius = 6,
    waddle = 0,
    anim_params = {
      frames = {45, 13},
      ticks_per_frame = 15,
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
    anim_params = {
      frames = {9, 25},
      ticks_per_frame = 15,
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
    anim_params = {
      frames = {1, 2},
      ticks_per_frame = 15,
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
    anim_params = {
      frames = {41, 57},
      ticks_per_frame = 15,
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
  player:reset()
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
  if btnp(4) or btnp(5) then
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
  self.anim:update()
end

function player:draw()
    local previousPalette = exportPalette()
    palt(0, false)
    palt(8, true)
    -- TODO: Add sprite flipping.
    local spritePos = self:pos() + self:spriteOffset()
    self.anim:draw(
      spritePos.x,
      spritePos.y
    )
    if self.behavior.mask then
      spr(
        self.behavior.mask,
        spritePos.x + (self.anim.w - 1) * 8,
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
  return v2(-self.anim.w * 8 / 2, -self.anim.h * 8 + 4)
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
        radius = 4,
        update = bark_update,
        text = player.behavior.text,
        draw = bark_draw,
        collisionCirc = function(self)
          return Circ.fromCenterRadius(v2(self.x, self.y), self.radius)
        end,
        intention = function(self)
          return v2(self.dx, self.dy)
        end,
        resolve = function(self, delta)
          if abs(delta.x) <= 0.2 and abs(delta.y) <= 0.2 then
            return
          end
          self.x += delta.x
          self.y += delta.y
        end
    }
    add(barks, b)
    return b
end

function player:nextAnimal()
  if self.current_animal == "dog" then
    --total_sheep += #sheep_mgr.clearedSheep
    self.current_animal = "mouse"
  elseif self.current_animal == "mouse" then
    --total_sheep += #sheep_mgr.clearedSheep
    self.current_animal = "fish"
  elseif self.current_animal == "fish" then
    --total_sheep += #sheep_mgr.clearedSheep
    self.current_animal = "duck"
  elseif self.current_animal == "duck" then
    --total_sheep += #sheep_mgr.clearedSheep
    current_gamestate = victory
  end
  self.behavior = animal_behavior[self.current_animal]
  self.anim = Animation:new(self.behavior.anim_params)
end

function player:reset()
  self.behavior = animal_behavior[self.current_animal]
  self.x = GOAL_X + 8
  self.y = GOAL_Y + 40
  self.dx = 0
  self.dy = 0
  barks = {}
  self.anim = Animation:new(self.behavior.anim_params)
end

