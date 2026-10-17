// feather disable GM2017
if (inimigo_colisao_ignorar(other)) exit; // fantasma especial sem o item de matar fantasma
if (!instance_exists(other)) exit;

var _kb_force = push;
var _kb_dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);

scr_enemy_damage_apply(other, damage, _kb_force, _kb_dir, false);

instance_destroy();