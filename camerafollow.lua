function _camera_init()
 x_follow=64
 y_follow=64
end

function _camera_update()
 if btn(0) then x_follow-=1 end
 if btn(1) then x_follow+=1 end
 if btn(2) then y_follow-=1 end
 if btn(3) then y_follow+=1 end
end

function _camera_draw()
 --get player position and center camera
 cam_x=x_follow-64
 cam_y=y_follow-64

 --do not move camera outside borders
 cam_x=mid(0,cam_x,128)
 cam_y=mid(0,cam_y,128)

 
 camera(cam_x,cam_y)

 cls(1)
 map(0,0,0,0,32,32)
 spr(128,x_follow,y_follow)
end