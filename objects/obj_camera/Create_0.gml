// feather disable GM2017
// Zoom padrão: começa CAMERA_ZOOM_PADRAO vezes mais perto que a view da room (Camera.gml)
global.cmw = max(CAMERA_ZOOM_MIN_W, camera_get_view_width(view_camera[0]) / CAMERA_ZOOM_PADRAO);
global.cmh = global.cmw * (1080 / 1920); // mesma proporção usada no zoom()
camera_set_view_size(view_camera[0], global.cmw, global.cmh);

global.cmx = obj_player.x - global.cmw/2;
global.cmy = obj_player.y - global.cmh/2;