// feather disable GM2017
if (inimigo_colisao_ignorar(other, true)) exit; // fantasmas especiais têm evento próprio (Collision_par_inimigos_fantasmas)
calcular_critico();

var _kb_force = 20 + global.ataque;
var _kb_dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);

scr_enemy_damage_apply(other, global.ataque, _kb_force, _kb_dir, (global.critico == 1));
