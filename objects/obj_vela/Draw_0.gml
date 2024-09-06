
draw_self();
if(place_meeting(x,y,obj_player)){
var pulsacao_alpha = 1 + (sin(current_time / 200) * 0.5);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale*pulsacao_alpha, image_yscale*pulsacao_alpha, 0, c_white, 0.4); // Brilho ao redor
draw_self(); // Desenha o item normal por cima
}