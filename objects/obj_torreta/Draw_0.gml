// feather disable GM2017


if(hit == true){
gpu_set_fog(true, c_white,0,0);
draw_sprite_ext(spr_sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
gpu_set_fog(false, c_white,0,0);
}else{
draw_sprite_ext(spr_sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
}
if dest_x < x{
	image_xscale = escala;
}else{
	image_xscale = -escala
}
// Barra de vida: inimigo_desenhar_hud() no Draw End (obj_par_inimigos)













