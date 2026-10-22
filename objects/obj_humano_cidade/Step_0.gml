// feather disable GM2017
if (!visible) exit; // dormindo fora da tela (scr_desempenho -> desempenho_cull)
/// @desc IA de passeio do humano da cidade
depth = -y;

// Pausas do jogo (inventário aberto / tela de level up)
if (instance_exists(obj_inventario) && obj_inventario.is_open) exit;
if (variable_global_exists("level_up") && global.level_up) exit;

if (balao_timer > 0) balao_timer--;

// --- Jogador perto: para, olha e fala ---
var _p = (variable_global_exists("current_player") && instance_exists(global.current_player)) ? global.current_player : instance_find(obj_player, 0);
if (_p != noone && instance_exists(_p)) {
    var _dist = point_distance(x, y, _p.x, _p.y);
    if (_dist < 90) {
        if (estado != "conversando") {
            estado = "conversando";
            if (!conversou || balao_timer <= 0) {
                balao_texto = frases[irandom(array_length(frases) - 1)];
                balao_timer = 180;
                conversou = true;
            }
        }
        var _dx = _p.x - x, _dy = _p.y - y;
        if (abs(_dx) > abs(_dy)) dir = (_dx < 0) ? 1 : 2;
        else dir = (_dy < 0) ? 3 : 0;
        image_index = dir * 4 + 1;
        exit;
    } else if (estado == "conversando" && _dist > 130) {
        estado = "parado";
        timer = irandom_range(30, 90);
        conversou = false;
    }
}

switch (estado) {
    case "parado":
        image_index = dir * 4 + 1;      // em pé
        timer--;
        if (timer <= 0) escolher_destino();
        break;

    case "andando":
        timer--;
        var _ang = point_direction(x, y, alvo_x, alvo_y);
        var _mx = lengthdir_x(vel, _ang);
        var _my = lengthdir_y(vel, _ang);
        var _andou = false;

        if (pode_pisar(x + _mx, y + _my)) { x += _mx; y += _my; _andou = true; }
        else if (abs(_mx) > 0.1 && pode_pisar(x + _mx, y)) { x += _mx; _andou = true; }   // desliza no eixo X
        else if (abs(_my) > 0.1 && pode_pisar(x, y + _my)) { y += _my; _andou = true; }   // desliza no eixo Y

        if (_andou) {
            if (abs(_mx) > abs(_my)) dir = (_mx < 0) ? 1 : 2;
            else dir = (_my < 0) ? 3 : 0;
            anim = (anim + vel * 0.11) mod 4;
            image_index = dir * 4 + floor(anim);
        }

        if (!_andou || point_distance(x, y, alvo_x, alvo_y) < vel * 2 || timer <= 0) {
            estado = "parado";
            timer  = irandom_range(40, 200);
            anim   = 0;
        }
        break;

    case "conversando":
        image_index = dir * 4 + 1;
        break;
}
