

if(hit == true){
gpu_set_fog(true, c_white,0,0);
draw_sprite_ext(spr_sombra, 0, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
gpu_set_fog(false, c_white,0,0);
}else{
draw_sprite_ext(spr_sombra, 0, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
}
if dest_x < x{
	image_xscale = -3;
}else{
	image_xscale = 3;
}


draw_set_font(fnt_descricao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);















