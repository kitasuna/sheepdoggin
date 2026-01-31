function _init_animation()
  p={}
  p.x=64
  p.y=64
  p.frame=0  -- actual animation frame
  p.anim_delay=15  -- the higher it is the slower animation transition
  p.idle_frame=0  -- separate frame counter for idle
  p.idle_delay=25  -- idle animation speed
end

function _update_animation()
  local moving=false
  
  if btn(0) or btn(1) or btn(2) or btn(3) then
    moving=true
  end
  
  if moving then
    p.frame+=1
    p.idle_frame=0  -- reset idle when moving
  else
    p.frame=0
    p.idle_frame+=1  -- increment idle frame
  end
end

function _draw_animation()
  local moving = btn(0) or btn(1) or btn(2) or btn(3)
  local sprite

  -- moving animation
  if moving then
    if flr(p.frame/p.anim_delay)%2==0 then
      sprite=129
    else
      sprite=132
    end
  else
    -- idle animation
    local idle_anim = flr(p.idle_frame/p.idle_delay)%4
    if idle_anim==0 then
      sprite=129
    elseif idle_anim==1 then
      sprite=133
    elseif idle_anim==2 then
      sprite=134
    else
      sprite=135
    end
  end
  
  spr(sprite,x_follow,y_follow)
end