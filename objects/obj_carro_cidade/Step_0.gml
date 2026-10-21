// feather disable GM2017
depth = -y;

// Pausas do jogo (inventário aberto / tela de level up)
if (instance_exists(obj_inventario) && obj_inventario.is_open) exit;
if (variable_global_exists("level_up") && global.level_up) exit;

var _dx = cidade_dx(dir);
var _dy = cidade_dy(dir);

// ---------- tem alguém na frente? ----------
// alcance da "visão": logo à frente do para-choque (subindo, a frente fica "comp" px acima da origem)
var _ax = x, _ay = y;
switch (dir) {
    case 1: case 2: _ax = x + _dx * (meio + 40); _ay = y - larg / 2; break;
    case 0:         _ay = y + 66;                break;
    case 3:         _ay = y - comp - 40;         break;
}
var _x0 = _ax - 46, _x1 = _ax + 46, _y0 = _ay - 34, _y1 = _ay + 34;
var _jogador = collision_rectangle(_x0, _y0, _x1, _y1, obj_player, false, true) != noone;
var _bloq = _jogador;
if (!_bloq && parado_timer < 240) _bloq = collision_rectangle(_x0, _y0, _x1, _y1, obj_humano_cidade, false, true) != noone;
if (!_bloq && parado_timer < 150) {
    // outro carro na mesma faixa, logo à frente
    var _eu = id;
    with (obj_carro_cidade) {
        if (id == _eu) continue;
        var _rx = x - _eu.x, _ry = y - _eu.y;
        var _frente = _rx * _dx + _ry * _dy;
        var _lado = abs(_rx * _dy) + abs(_ry * _dx);
        // distância entre origens até encostar: de lado = os dois meios; na vertical = o comprimento de quem está em cima
        var _lim = (_dx != 0) ? _eu.meio + meio + 30 : ((_dy > 0) ? comp : _eu.comp) + 30;
        if (_frente > 0 && _frente < _lim && _lado < 50) { _bloq = true; break; }
    }
}

if (_bloq) { vel = max(0, vel - 0.25); parado_timer++; }
else       { vel = min(vel_max, vel + 0.05); parado_timer = 0; }

// buzina quando o jogador fica parado na frente
if (_jogador && vel == 0) {
    buzina_timer++;
    if (buzina_timer == 50) balao = 70;
} else buzina_timer = 0;
if (balao > 0) balao--;

// ---------- anda ----------
x += _dx * vel;
y += _dy * vel;

// fim da cidade logo à frente (borda ondulada): meia-volta
if (terreno_bioma_em(x + _dx * 120, y + _dy * 120) != "cidade") meia_volta();

// ---------- cruzamentos ----------
var _c = cidade_cruzamento(x, y);
if (is_struct(_c)) {
    var _k = string(_c.j) + "," + string(max(_c.desce, _c.sobe));
    if (_k != inter_atual && virar_para == -1) {
        inter_atual = _k;
        cruz = _c;
        virar_para = escolher_saida(_c);
        if (virar_para == dir) virar_para = -1;
        else if (virar_para == cidade_oposta(dir)) meia_volta();
    }
} else if (dir == 0 || dir == 3) {
    // rua vertical acabando (avenida desalinhada / calçada à frente): meia-volta
    var _fr = cidade_tipo_em(x, y + cidade_dy(dir) * 110);
    if (_fr == CID_CALCADA || _fr == CID_MIOLO) meia_volta();
}

// executa a curva quando chega na faixa da nova direção
if (virar_para != -1) {
    var _alvo = faixa_de(virar_para);
    var _chegou = false;
    switch (dir) {
        case 2: _chegou = (x >= _alvo); break;
        case 1: _chegou = (x <= _alvo); break;
        case 0: _chegou = (y >= _alvo); break;
        case 3: _chegou = (y <= _alvo); break;
    }
    if (_chegou) {
        if (virar_para == 0 || virar_para == 3) x = _alvo; else y = _alvo;
        dir = virar_para;
        virar_para = -1;
    }
}

// ---------- visual ----------
if (vel > 0.2) anim = (anim + vel * 0.1) mod 4;   // 4 passos: roda girando + balanço + fumaça
image_index = dir * 4 + floor(anim);
// faróis na frente do carro
switch (dir) {
    case 0:  light_offset_x = 0;                         light_offset_y = 20;          break;
    case 3:  light_offset_x = 0;                         light_offset_y = -comp - 20;  break;
    default: light_offset_x = cidade_dx(dir) * (meio + 20); light_offset_y = -larg / 2; break;
}
