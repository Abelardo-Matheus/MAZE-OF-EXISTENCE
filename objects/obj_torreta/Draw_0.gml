

if(hit == true){
gpu_set_fog(true, c_white,0,0);
draw_sprite_ext(sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
gpu_set_fog(false, c_white,0,0);
}else{
draw_sprite_ext(sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
}
if dest_x < x{
	image_xscale = escala;
}else{
	image_xscale = -escala
}
if (alarm[2] >= 0){
	var _sprw = sprite_get_width(spr_hud_vida_inimigo)/2*escala;
draw_sprite_ext(spr_hud_vida_inimigo, 0, x -_sprw-15, y -20, 4, 4,0,c_white,1);
draw_sprite_ext(Sprite86, 0, x -_sprw-15, y -20, (vida/max_vida)*4, 4, 0, c_white, 1);
}













