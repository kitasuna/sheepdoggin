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
                    self.mask = "chihuahua"
                elseif self.mask == "chihuahua" then
                    self.mask = "duck"
                elseif self.mask == "duck" then
                    self.mask = "fish"
                elseif self.mask == "fish" then
                    self.mask = "dog"
                end
            end
            if (btnp(5)) new_bark(self.x + self.dx, self.y + self.dy, 4, 4, self.sound*self.dx, self.sound*self.dy)
            local i, j=1, 1
            while(objects[i]) do
                if objects[i]:update() then
                    if(i!=j) objects[j] = objects[i] objects[i] = nil
                    j += 1
                else
                    objects[i] = nil
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
            self.x += self.dx
            self.y += self.dy
    
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
            if self.mask == "chihuahua" then
                self.acc = 0.5
                self.max_dx = 2
                self.max_dy = 2
                self.waddle = 0
                self.sprite = 130
                self.friction = 0.85
                self.flop = 0
                self.text = "yap"
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
            cls()
            spr(self.sprite, self.x, self.y)
            for b in all(objects) do
                b:draw()
            end
            print(player.mask, 0, 0)
        end
    }

-- handling barks
objects = {}
function bark_draw(o)
    print(o.text, o.x, o.y)
    --spr(o.sprite, o.x, o.y, 2, 1)
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
    add(objects, b)
    return b
end

