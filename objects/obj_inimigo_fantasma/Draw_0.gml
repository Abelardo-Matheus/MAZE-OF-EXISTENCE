// feather disable GM2017
if dest_x < x{
	image_xscale = -escala;
}else{
	image_xscale = escala
}

if(hit == true){
gpu_set_fog(true, c_white,0,0);

draw_self();
gpu_set_fog(false, c_white,0,0);
}else{

draw_self();
}

// Barra de vida: inimigo_desenhar_hud() no Draw End (obj_par_inimigos)













