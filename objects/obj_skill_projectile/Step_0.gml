// feather disable GM2017
/// @desc Projétil genérico de skill (varinha, adagas, lâminas giras)
/// [O QUE]: Pausa no level up, roda o comportamento customizado da skill, acerta a horda e
///          some quando sai da câmera.
/// [COMO] : Lâminas giras (têm orbital_radius) perfuram e acertam cada inimigo a cada
///          HORDE_TICK_IFRAMES frames. Os demais acertam 1 inimigo e somem.

// --- Pausa (mesmo padrão das outras armas) ---
if (global.level_up) {
    speed = 0;
    exit;
}
speed = veloc;

if (variable_instance_exists(id, "Step_0_Custom")) {
    Step_0_Custom();
}
if (!instance_exists(id)) exit; // o comportamento custom pode ter destruído

if (variable_instance_exists(id, "orbital_radius")) {
    // --- Lâmina orbital: perfura ---
    hit_reset += 1;
    if (hit_reset >= HORDE_TICK_IFRAMES) {
        hit_set = {}; // libera os inimigos-instância para levarem dano de novo
        hit_reset = 0;
    }
    var _cx = instance_exists(parent_player) ? parent_player.x : x;
    var _cy = instance_exists(parent_player) ? parent_player.y : y;
    horde_hit_instance_tick(id, damage, push_force, _cx, _cy);
} else {
    // --- Tiro comum: acerta um e some, empurrando na direção do tiro ---
    if (horde_hit_instance(id, damage, push_force, x - lengthdir_x(8, direction), y - lengthdir_y(8, direction), -1, 1) > 0) {
        instance_destroy();
        exit;
    }

    // A Fase_vamp é um mundo infinito numa room de 1920x1088: o evento "Outside Room"
    // destruía o tiro assim que o jogador saía da área inicial. Agora o corte é pela câmera.
    var _cam = view_camera[0];
    var _m = 128;
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    if (x < _vx - _m || y < _vy - _m
     || x > _vx + camera_get_view_width(_cam) + _m
     || y > _vy + camera_get_view_height(_cam) + _m) {
        instance_destroy();
    }
}
