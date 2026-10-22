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
// outro carro no caminho (mesma faixa, cruzamento ou curva): espera, sem atravessar ninguém
var _carro_frente = noone;
if (!_bloq) {
    var _adiante = vel_max * 10 + 20;
    var _fx, _fy, _fd;
    if (curva) {
        var _t2 = min(1, curva_t + _adiante / curva_len);
        var _pf = curva_ponto(_t2);
        _fx = _pf[0]; _fy = _pf[1]; _fd = (_t2 < 0.5) ? curva_de : curva_para;
    } else {
        _fx = x + _dx * _adiante; _fy = y + _dy * _adiante; _fd = dir;
    }
    _carro_frente = carro_no_caminho(hitbox_em(_fx, _fy, _fd));
    _bloq = (_carro_frente != noone);
}
if (_carro_frente != noone) espera_de = _carro_frente;
else if (!esperando_curva) espera_de = noone;
if (_carro_frente != noone || esperando_curva) espera_timer++; else espera_timer = 0;

if (_bloq) { vel = max(0, vel - 0.25); parado_timer++; }
else       { vel = min(vel_max, vel + 0.05); parado_timer = 0; }

// travou esperando outro carro por muito tempo (os dois se esperando): dá meia-volta
if (espera_timer > CARRO_ESPERA_MAX && !curva) { meia_volta(); espera_timer = 0; espera_de = noone; esperando_curva = false; }

// ---------- jogador atravessando lá na frente: freia devagar e reclama ----------
var _lx0, _ly0, _lx1, _ly1;
var _longe = CARRO_VISAO_LONGE + vel * 30;
switch (dir) {
    case 2: _lx0 = x + meio;           _lx1 = _lx0 + _longe; _ly0 = y - larg - 30; _ly1 = y + 30; break;
    case 1: _lx1 = x - meio;           _lx0 = _lx1 - _longe; _ly0 = y - larg - 30; _ly1 = y + 30; break;
    case 0: _lx0 = x - 70; _lx1 = x + 70; _ly0 = y;                _ly1 = y + _longe;          break;
    default:_lx0 = x - 70; _lx1 = x + 70; _ly1 = y - comp;         _ly0 = _ly1 - _longe;       break;
}
var _jogador_longe = !curva && collision_rectangle(_lx0, _ly0, _lx1, _ly1, obj_player, false, true) != noone;
if (_jogador_longe && !_jogador) vel = max(0, vel - 0.12);   // freia antes de chegar no jogador
if (_jogador_longe && !jogador_longe_antes && reclamar_cd <= 0) {
    balao_texto = frases_reclamar[irandom(array_length(frases_reclamar) - 1)];
    balao = 110;
    reclamar_cd = 240;
}
jogador_longe_antes = _jogador_longe;
if (reclamar_cd > 0) reclamar_cd--;

// buzina quando o jogador fica parado na frente
if (_jogador && vel == 0) {
    buzina_timer++;
    if (buzina_timer == 50) { balao = 70; balao_texto = "Bi-bi!"; }
} else buzina_timer = 0;
if (balao > 0) balao--;

// ---------- anda (reto ou fazendo a curva) ----------
if (curva) {
    curva_t = min(1, curva_t + vel / curva_len);
    var _pt = curva_ponto(curva_t);
    x = _pt[0]; y = _pt[1];
    if (curva_t >= 1) {
        dir = curva_para;
        if (dir == 0 || dir == 3) x = curva_p[4]; else y = curva_p[5];   // trava na faixa nova
        curva = false;
        virar_para = -1;
    }
} else {
    x += _dx * vel;
    y += _dy * vel;
    // fim da cidade logo à frente (borda ondulada): meia-volta
    if (terreno_bioma_em(x + _dx * 120, y + _dy * 120) != "cidade") meia_volta();
}

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

// começa a curva perto da faixa da nova direção (antes virava de uma vez ao chegar nela)
esperando_curva = false;
if (virar_para != -1 && !curva) {
    var _alvo = faixa_de(virar_para);
    var _resto = 0;
    switch (dir) {
        case 2: _resto = _alvo - x; break;
        case 1: _resto = x - _alvo; break;
        case 0: _resto = _alvo - y; break;
        case 3: _resto = y - _alvo; break;
    }
    if (_resto <= 2) {
        // já passou do ponto (ex.: decidiu tarde demais): vira na hora, como antes
        if (virar_para == 0 || virar_para == 3) x = _alvo; else y = _alvo;
        dir = virar_para;
        virar_para = -1;
    } else if (_resto <= CARRO_CURVA_RAIO) {
        // só vira com a curva toda livre; senão espera parado antes do canto
        var _atrapalha = curva_livre(virar_para, _alvo, _resto);
        if (_atrapalha == noone) curva_iniciar(virar_para, _alvo, _resto);
        else {
            vel = max(0, vel - 0.4);
            espera_de = _atrapalha;
            esperando_curva = true;
        }
    }
}

// ---------- visual ----------
if (vel > 0.2) anim = (anim + vel * 0.1) mod 4;   // 4 passos: roda girando + balanço + fumaça
// na curva: primeira metade com o frame antigo inclinando para o lado da curva,
// segunda metade com o frame novo voltando a ficar reto
if (curva) {
    var _giro = sign(angle_difference(dir_ang(curva_para), dir_ang(curva_de))) * CARRO_CURVA_GIRO;
    if (curva_t < 0.5) { vis_dir = curva_de;   vis_ang = _giro * (curva_t / 0.5); }
    else               { vis_dir = curva_para; vis_ang = -_giro * ((1 - curva_t) / 0.5); }
} else {
    vis_dir = dir;
    vis_ang = 0;
}
image_index = vis_dir * 4 + floor(anim);

// ---------- atropelou o jogador? ----------
if (vel > 0.6 && instance_exists(obj_player)) {
    var _hb = hitbox();
    var _alvo_p = collision_rectangle(_hb[0], _hb[1], _hb[2], _hb[3], obj_player, false, true);
    if (_alvo_p != noone && _alvo_p.tomar_dano) {
        var _dano = player_dano_recebido(dano_carro);
        if (_dano > 0) {
            var _cx = (_hb[0] + _hb[2]) / 2, _cy = (_hb[1] + _hb[3]) / 2;
            with (_alvo_p) {
                global.vida -= _dano;
                empurrar_dir = (x == _cx && y == _cy) ? 0 : point_direction(_cx, _cy, x, y);
                hit = true;
                alarm[ALARM_KNOCKBACK] = 15;
                tomar_dano = false;
                alarm[ALARM_INVENCIBILIDADE] = 90;
                player_sinal_dano(c_red, 90);
            }
            if (object_exists(obj_dano)) {
                var _pop = instance_create_layer(_alvo_p.x, _alvo_p.y - 30, "Instances", obj_dano);
                _pop.dano = _dano;
                _pop.cor = c_red;
            }
            balao_texto = "Eu buzinei!!";
            balao = 90;
            vel = 0;   // freia na hora
        }
    }
}
// faróis na frente do carro
switch (vis_dir) {
    case 0:  light_offset_x = 0;                         light_offset_y = 20;          break;
    case 3:  light_offset_x = 0;                         light_offset_y = -comp - 20;  break;
    default: light_offset_x = cidade_dx(vis_dir) * (meio + 20); light_offset_y = -larg / 2; break;
}
