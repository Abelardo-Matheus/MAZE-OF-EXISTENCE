image_xscale = escala;
image_yscale = escala;
script_execute(state);
depth = -y;

if (vida <= 0) {
	remover_inimigo_por_id(global.current_sala, inimigo_id);
	instance_create_layer(x, y, "instances", obj_xp_um);
    instance_destroy();
}

if (instance_exists(obj_camera)){
var _border = 64;
if(y < global.cmy - _border){
	y = global.cmy + global.cmh + _border;
}
if(y > global.cmy + global.cmh + _border){
	y = global.cmy - _border;
}
if(x < global.cmx - _border){
	x = global.cmx + global.cmw + _border;	
}
if(x > global.cmx + global.cmw + _border){
	x = global.cmx - _border;
}
}






