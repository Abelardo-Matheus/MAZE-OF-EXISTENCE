if (!instance_exists(other)) exit;

// Lâmina orbital (Lâminas Giras): perfura. Antes ela sumia no primeiro inimigo,
// contrariando a descrição da skill ("dano a qualquer inimigo que tocarem").
if (variable_instance_exists(id, "orbital_radius")) {
    var _chave = string(other.id);
    if (variable_struct_exists(hit_set, _chave)) exit;
    hit_set[$ _chave] = true;
    scr_enemy_damage_apply(other, damage, push_force, point_direction(x, y, other.x, other.y), false);
    exit;
}

var _kb_force = push_force;
var _kb_dir = direction;

scr_enemy_damage_apply(other, damage, _kb_force, _kb_dir, false);

instance_destroy();
