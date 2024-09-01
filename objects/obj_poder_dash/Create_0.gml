
image_xscale = global.cell_size / sprite_get_width(sprite_index);
image_yscale = global.cell_size / sprite_get_height(sprite_index);
mask_index = sprite_index;
invisivel = false;
global.speed_dash = 20;  // Velocidade do dash
global.dash_tempo_recarga = 60*4; // Tempo de recarga do dash (2 segundos, se o jogo estiver a 60 FPS)
global.frames = 20;
global.dash_em_recarga = false;  // Indica se o dash está em recarga
global.in_dash = false;





