

if(hit == true){
gpu_set_fog(true, c_white,0,0);
draw_sprite_ext(sombra, image_index, x+1, y+16/2,escala/2,escala/2,0,c_white,1);
draw_self();
gpu_set_fog(false, c_white,0,0);
}else{
draw_sprite_ext(sombra, image_index, x+1, y+16/2,escala/2,escala/2,0,c_white,1);
draw_self();
}
if dest_x < x{
	image_xscale = -escala;
}else{
	image_xscale = escala
}
if (alarm[2] >= 0){
	var _sprw = sprite_get_width(spr_hud_vida_inimigo)/2*escala;
	
draw_sprite_ext(spr_hud_vida_inimigo, 0, x-_sprw, y - (12*escala), escala, escala,0,c_white,1);
draw_sprite_ext(spr_vida_, 0, x -_sprw, y- (12*escala) , (vida/max_vida)*escala, escala, 0, c_white, 1);
}













