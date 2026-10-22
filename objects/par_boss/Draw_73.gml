// feather disable GM2017
/// @desc Barra de vida do boss (Draw End: por cima de móveis/paredes)
draw_sprite_ext(spr_barra_vida_boss, image_index, room_width/2-(sprite_get_width(spr_hud_vida_boss)/2*escala_hud), 80,clamp(vida / max(1, vida_max), 0, 1)*escala_hud,escala_hud,0,c_white,1);
draw_sprite_ext(spr_hud_vida_boss, image_index, room_width/2-(sprite_get_width(spr_hud_vida_boss)/2*escala_hud), 80,escala_hud,escala_hud,0,c_white,1);
