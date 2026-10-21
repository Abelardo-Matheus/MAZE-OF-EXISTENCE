// feather disable GM2017
depth = -y;

if (image_number > 1) {
    anim = (anim + anim_vel) mod image_number;
    image_index = floor(anim);
}

var _p = (variable_global_exists("current_player") && instance_exists(global.current_player)) ? global.current_player : instance_find(obj_player, 0);
if (_p == noone || !instance_exists(_p)) exit;

// ---------- pombos: saem voando ----------
if (tipo == ENF_POMBOS) {
    if (!fugindo) {
        var _perto = point_distance(x, y, _p.x, _p.y) < 140;
        if (!_perto) {
            var _h = instance_nearest(x, y, obj_humano_cidade);
            _perto = (_h != noone && point_distance(x, y, _h.x, _h.y) < 70);
        }
        if (_perto) {
            fugindo = true;
            fuga_vx = (x >= _p.x ? 1 : -1) * random_range(2, 3.5);
            fuga_vy = -random_range(2.5, 4);
            anim_vel = 0.4;                     // batem as "asas" (cabeça mexendo rápido)
        }
    } else if (visible) {
        x += fuga_vx;
        y += fuga_vy;
        fuga_vy *= 1.02;
        image_alpha -= 0.025;
        if (image_alpha <= 0) visible = false;
    } else if (point_distance(casa_x, casa_y, _p.x, _p.y) > 700) {
        // jogador foi embora: os pombos voltam para o lugar
        x = casa_x; y = casa_y;
        image_alpha = 1; visible = true; fugindo = false;
        anim_vel = 0.09;
    }
    exit;
}

// ---------- coisas altas ficam transparentes com o jogador atrás ----------
if (alto) {
    var _atras = abs(_p.x - x) < sprite_width * 0.4 && _p.y < y - 10 && _p.y > y - sprite_height;
    image_alpha = _atras ? 0.45 : 1;
}
