if(global.level_up == true){
	image_speed = 0;
	speed = 0;
	exit;		
}else{
	speed = veloc;
}
var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);
var _camera_w = camera_get_view_width(view_camera[0]);
var _camera_h = camera_get_view_height(view_camera[0]);

// Verifica se a bola está fora dos limites da câmera com uma margem de 64 pixels
if (x < _camera_x - 64 || x > _camera_x + _camera_w + 64 || 
    y < _camera_y - 64 || y > _camera_y + _camera_h + 64) {
    instance_destroy();
}

