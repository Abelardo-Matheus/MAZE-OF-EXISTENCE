var _guiw = display_get_gui_width();
var _guih = display_get_gui_height();

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);


if(inventario == true){
	draw_set_alpha(0.7);
	draw_set_color(c_black);
	draw_rectangle(0,0,_guiw,_guih,false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	var _invx = _guiw/2 - inventario_w/2;
	var _invy = _guih/2 - inventario_h/2;
	draw_sprite_ext(spr_iinventario, 0 ,_invx,_invy,escala,escala,0,c_white,1);
	
}





