// 1. Desenha Sombra no chão (x, y reais)
draw_sprite_ext(spr_sombra, 0, x, y, 0.5, 0.5, 0, c_white, 0.5);

// 2. Desenha a Bomba "voando" (y - z)
// Se 'z' não existir por algum motivo, usa 0
var _draw_height = variable_instance_exists(id, "z") ? z : 0;

draw_sprite_ext(sprite_index, image_index, x, y - _draw_height, image_xscale, image_yscale, image_angle, c_white, image_alpha);