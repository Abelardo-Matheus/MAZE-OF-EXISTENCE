if (inimigo_colisao_ignorar(other)) exit; // fantasma especial sem o item de matar fantasma
if (!instance_exists(other)) exit;

var _kb_force = 1;
var _kb_dir = point_direction(x, y, other.x, other.y);

scr_enemy_damage_apply(other, damage, _kb_force, _kb_dir, false);
