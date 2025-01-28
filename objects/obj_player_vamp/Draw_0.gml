
draw_sprite_ext(spr_sombra,0,x,y+20,0.8,0.8,0,c_white,1);
draw_self();


	
if (alarm[3] > 0){
	if(image_alpha >=1){
		dano_alfa = -0.05;
	}else if(image_alpha <= 0){
		dano_alfa = 0.05;
	}
	image_alpha += dano_alfa;
}else{
	image_alpha = 1;
}













