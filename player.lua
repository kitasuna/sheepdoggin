-- for player code
player = {
        x = 63,
        y = 63,
        dx = 0,
        dy = 0,
        max_dx = 1,
        max_dy = 1,
        acc = 0.25,
        waddle = 0,
        friction = 0.85,
        flop = 0,
        sprite = 1,
        text = "bark",
        mask = "dog",
        bark = 1,
        update = function(self)
            self.dy *= self.friction
            self.dx *= self.friction

    -- controls
			if btn(⬆️) then
                self.dy -= self.acc
                self.dx += rnd(self.waddle)
                self.dx -= rnd(self.waddle)
            end
            if btn(⬇️) then
                self.dy += self.acc
                self.dx += rnd(self.waddle)
                self.dx -= rnd(self.waddle)
            end
            if btn(⬅️) then
                self.dx -= self.acc
                self.dy += rnd(self.waddle)
                self.dy -= rnd(self.waddle)
            end
            if btn(➡️) then
                self.dx += self.acc
                self.dy += rnd(self.waddle)
                self.dy -= rnd(self.waddle)
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
            if (btnp(5)) new_bark(self.x + self.dx, self.y + self.dy, 4, 4, self.sound*self.dx, self.sound*self.dy)
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
                self.dx += rnd(self.flop)
                self.dx -= rnd(self.flop)
                self.dy += rnd(self.flop)
                self.dy -= rnd(self.flop)
            end

            self.dx = mid(-self.max_dx, self.dx, self.max_dx)
            self.dy = mid(-self.max_dy, self.dy, self.max_dy)
            -- self.x += self.dx
            -- self.y += self.dy
    
     --masks
            if self.mask == "dog" then
    	        self.acc = 0.25
                self.max_dx = 1
                self.max_dy = 1
                self.waddle = 0
    	        self.sprite = 129
                self.friction = 0.85
                self.flop = 0
                self.text = "bark"
                self.sound = 2
            end
            if self.mask == "mouse" then
                self.acc = 0.5
                self.max_dx = 2
                self.max_dy = 2
                self.waddle = 0
                self.sprite = 130
                self.friction = 0.85
                self.flop = 0
                self.text = "squeak"
                self.sound = 1
            end
            if self.mask == "duck" then
                self.acc = 0.15
                self.max_dx = 0.75
                self.max_dy = 0.75
                self.waddle = 0.6
                self.sprite = 131
                self.friction = 0.85
                self.flop = 0
                self.text = "quack"
                self.sound = 2
            end
            if self.mask == "fish" then
                self.acc = 0.10
                self.max_dx = 3
                self.max_dy = 3
                self.waddle = 0
                self.sprite = 132
                self.friction = 0.97
                self.flop = 0.2
                self.text = "flop"
                self.sound = 0.1
            end
    
        end,

        draw = function(self)
            for bark in all(barks) do
                bark:draw()
            end
            print(player.mask, 0, 0, 3)
        end,

        collisionCirc = function(self)
            local pos = v2(self.x, self.y)
            -- update this 4,4 if we change player sprite size
            return Circ.fromCenterRadius(pos:add(v2(4,4)),4)
        end,
        influenceCirc = function(self)
            local pos = v2(self.x, self.y)
            -- update this 4,4 if we change player sprite size
            return Circ.fromCenterRadius(pos:add(v2(4,4)),14)
        end,

        intention = function(self)

          local delta = v2(
            self.dx,
            self.dy
          )
          return delta
        end,
        resolve = function(self, delta)
            if abs(delta.x) <= 0.2 and abs(delta.y) <= 0.2 then
                return
            end
            self.x += delta.x
            self.y += delta.y
        end,
    }

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
        text = player.text,
        draw = bark_draw
    }
    add(barks, b)
    return b
end

