if(hit == true){
gpu_set_fog(true, c_white,0,0);
draw_sprite_ext(spr_sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
gpu_set_fog(false, c_white,0,0);
}else{
draw_sprite_ext(spr_sombra, image_index, x+1, y+16,1.3,1,0,c_white,1);
draw_self();
}

draw_sprite_ext(spr_barra_vida_boss, image_index, room_width/2-(sprite_get_width(spr_hud_vida_boss)/2*escala_hud), 80,(vida/vida_max)*escala_hud,escala_hud,0,c_white,1);
draw_sprite_ext(spr_hud_vida_boss, image_index, room_width/2-(sprite_get_width(spr_hud_vida_boss)/2*escala_hud), 80,escala_hud,escala_hud,0,c_white,1);
