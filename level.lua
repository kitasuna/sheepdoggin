Level = {}
function Level:new(o)
  o = o or {
    goal_upperleft = {},
    goal_hw = nil
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Level:setGoal(x, y, w, h)
  self.goal_upperleft = v2(x, y)
  self.goal_bottomright = v2(x+w, y+h)
end

-- () -> (v2, v2)
function Level:getGoalCorners()
  return self.goal_upperleft, self.goal_bottomright
end

function Level:draw()
  rectfill(
    self.goal_upperleft.x,
    self.goal_upperleft.y,
    self.goal_bottomright.x,
    self.goal_bottomright.y,
    2)
end
