function _camera_draw()
 --get player position and center camera
 cam_x=player.x-64
 cam_y=player.y-64

 --do not move camera outside borders
 cam_x=mid(0,cam_x,MAP_WIDTH)
 cam_y=mid(0,cam_y,MAP_HEIGHT)

 
 camera(cam_x,cam_y)

 cls(1)
 map(0,0,0,0,32,32)
end
