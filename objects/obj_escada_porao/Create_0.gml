// feather disable GM2017
/// @desc Escada fundos <-> porão (dados e lógica em spr_fase_criation > região Escada)
sprite_index = spr_escada_porao_top;   // frame 0 = descendo (fundos) | 1 = subindo (porão)
image_speed  = 0;
image_xscale = global._cell_size / 64;
image_yscale = global._cell_size / 64;
image_angle  = 0;
destino = undefined; // [x, y] da sala do outro lado (preenchido por recriar_escada_na_sala_atual)
sobe = false;
