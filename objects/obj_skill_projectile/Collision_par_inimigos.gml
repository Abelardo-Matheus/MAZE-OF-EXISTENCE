if (!instance_exists(other)) exit;

// Lâmina orbital (Lâminas Giras) e projéteis com perfura = true (Pião): atravessam.
if (variable_instance_exists(id, "orbital_radius") || perfura) {
    var _chave = string(other.id);
    if (variable_struct_exists(hit_set, _chave)) exit;
    hit_set[$ _chave] = true;
    scr_enemy_damage_apply(other, damage, push_force, point_direction(x, y, other.x, other.y), false);
    exit;
}

// Efeito especial no acerto (ex.: Bolha de Sabão estoura em área)
if (is_method(ao_acertar)) {
    ao_acertar();
    instance_destroy();
    exit;
}

var _kb_force = push_force;
var _kb_dir = direction;

scr_enemy_damage_apply(other, damage, _kb_force, _kb_dir, false);

instance_destroy();
