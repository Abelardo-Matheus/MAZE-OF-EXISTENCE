// feather disable GM2017
// ============================================================================
// VENTO: sistema global e aleatorio de vento
// ----------------------------------------------------------------------------
// global.vento guarda o "clima" do vento:
//   dir     -1 (sopra p/ esquerda) ou 1 (sopra p/ direita)
//   forca   0..1  intensidade atual (vai suavemente ate "alvo")
//   alvo    0..1  intensidade sorteada para o periodo atual
//   rajada  0..1  rajada passando agora (sobe e desce em ~1,5 s)
//   frente_x      posicao (x do mundo) da frente da rajada, que atravessa a tela
// Quem atualiza tudo e o obj_vento (1 por sala, criado sozinho por vento_garantir).
// As arvores leem com vento_inclinacao(x, fase) e escolhem a pose do sprite.
// ============================================================================

#macro VENTO_POSES        7      // poses por variante no spr_arvore_<bioma> (3 = reta)
#macro VENTO_LARGURA_RAJ  520    // largura (px) da faixa de rajada que passa pelas arvores
#macro VENTO_LIMIAR_EMPURRAO 50  // força (0..100) a partir da qual o vento empurra player e inimigos
#macro VENTO_EMPURRAO_MAX    3   // px/frame de empurrão com força 100 (antes da rajada)

function vento_init() {
    clima_init();
    if (variable_global_exists("vento") && is_struct(global.vento)) return;
    global.vento = {
        dir: choose(-1, 1),
        forca: 0.15,
        alvo: 0.15,
        timer: irandom_range(240, 600),
        rajada: 0,
        rajada_t: 0,          // progresso da rajada (0 = nenhuma)
        rajada_dur: 90,
        frente_x: 0,
        t: 0                  // tempo do vento (steps)
    };
}

/// @desc Garante que existe um obj_vento na sala (chamado pelas arvores)
function vento_garantir() {
    vento_init();
    if (!instance_exists(obj_vento)) instance_create_depth(0, 0, -100000, obj_vento);
}

/// @desc Avanca o vento 1 step (so o obj_vento chama)
function vento_atualizar() {
    vento_init();
    var _v = global.vento;
    _v.t += 1;

    // --- troca de "clima" de tempos em tempos -------------------------------
    _v.timer--;
    if (_v.timer <= 0) {
        _v.timer = irandom_range(360, 1080);            // 6 a 18 s
        _v.alvo = clima_sortear_vento();                // calmo quase sempre; forte só em evento (CLIMA abaixo)
        if (random(1) < 0.3) _v.dir = -_v.dir;          // as vezes vira de lado
    }
    _v.forca = lerp(_v.forca, _v.alvo, 0.006);

    clima_atualizar();                                  // eventos: chuva, tempestade, furacão...

    // --- rajadas: uma onda que atravessa a tela -----------------------------
    var _cx = 0, _cw = room_width;
    if (view_enabled && view_camera[0] != -1) {
        _cx = camera_get_view_x(view_camera[0]);
        _cw = camera_get_view_width(view_camera[0]);
    }
    if (_v.rajada_t <= 0) {
        _v.rajada = 0;
        if (random(1) < 0.002 + _v.forca * 0.012) {     // mais vento = mais rajadas
            _v.rajada_t = 1;
            _v.rajada_dur = irandom_range(70, 130);
            // comeca do lado de onde o vento vem
            _v.frente_x = (_v.dir > 0) ? _cx - VENTO_LARGURA_RAJ : _cx + _cw + VENTO_LARGURA_RAJ;
        }
    } else {
        _v.rajada_t++;
        var _p = _v.rajada_t / _v.rajada_dur;
        _v.rajada = sin(pi * clamp(_p, 0, 1)) * (0.6 + _v.forca * 0.4);
        // a frente cruza a tela inteira durante a rajada
        _v.frente_x += _v.dir * ((_cw + VENTO_LARGURA_RAJ * 2) / _v.rajada_dur);
        if (_p >= 1) _v.rajada_t = 0;
    }
}

/// @desc Quanto da rajada esta passando no x informado (0..1)
function vento_rajada_em(_x) {
    var _v = global.vento;
    if (_v.rajada <= 0) return 0;
    var _d = abs(_x - _v.frente_x) / VENTO_LARGURA_RAJ;
    return _v.rajada * clamp(1 - _d, 0, 1);
}

/// @desc Inclinacao da arvore em x (-1 esquerda .. 1 direita)
///       _fase deixa cada arvore balancar num tempo um pouco diferente
function vento_inclinacao(_x, _fase) {
    vento_init();
    var _v = global.vento;
    var _raj = vento_rajada_em(_x);
    // empurrao constante no sentido do vento
    var _base = _v.dir * (_v.forca * 0.55 + _raj * 0.45);
    // vai-e-volta: mais rapido e mais largo quanto mais forte o vento
    var _vel = 0.035 + _v.forca * 0.06 + _raj * 0.05;
    var _osc = sin(_v.t * _vel + _fase + _x * 0.004) * (0.10 + _v.forca * 0.28 + _raj * 0.2);
    return clamp(_base + _osc, -1, 1);
}

/// @desc Converte inclinacao (-1..1) na pose do sprite (0..VENTO_POSES-1)
function vento_pose(_incl) {
    var _meio = (VENTO_POSES - 1) / 2;
    return clamp(round(_meio + _incl * _meio), 0, VENTO_POSES - 1);
}

/// @desc Força atual do vento de 0 a 100 (inclui a rajada passando pelo centro da tela)
function vento_forca_100() {
    vento_init();
    var _v = global.vento;
    return round(clamp(_v.forca + _v.rajada * 0.25, 0, 1) * 100);
}

/// @desc Empurrão horizontal (px/frame) que o vento aplica em x. 0 se a força for <= VENTO_LIMIAR_EMPURRAO.
function vento_empurrao_em(_x) {
    var _f = vento_forca_100();
    if (_f <= VENTO_LIMIAR_EMPURRAO) return 0;
    var _k = (_f - VENTO_LIMIAR_EMPURRAO) / (100 - VENTO_LIMIAR_EMPURRAO);  // 0..1
    return global.vento.dir * _k * VENTO_EMPURRAO_MAX * (1 + vento_rajada_em(_x));
}

/// @desc Aplica o empurrão do vento no player, nos inimigos (instâncias) e na horda. Chamado pelo obj_vento.
function vento_empurrar() {
    if (vento_forca_100() <= VENTO_LIMIAR_EMPURRAO) exit;

    // Player: não empurra com menu/baú/inventário aberto ou em diálogo
    with (obj_player) {
        var _parado = (instance_exists(obj_inventario) && obj_inventario.is_open)
                   || (variable_global_exists("bau_aberto") && instance_exists(global.bau_aberto))
                   || (variable_global_exists("colocando_bau") && global.colocando_bau.ativo)
                   || (variable_global_exists("dialogo") && global.dialogo);
        if (!_parado) {
            var _e = vento_empurrao_em(x);
            if (_e != 0) scr_player_colisao_vento(_e);
        }
    }

    // Inimigos instância (os pesados sentem menos: força 1 / escala)
    with (obj_par_inimigos) {
        var _e = vento_empurrao_em(x) * 0.8 / max(1, (variable_instance_exists(id, "escala") ? escala : 1));
        if (_e != 0) {
            if (variable_instance_exists(id, "atravessa")) inimigo_ia_mover(_e, 0);
            else aplicar_movimento_com_colisao(_e, 0);
        }
    }

    // Horda (sem instâncias)
    with (obj_horde) {
        for (var _i = 0; _i < alive; _i++) {
            ex[_i] += vento_empurrao_em(ex[_i]) * 0.8 / max(1, types[etype[_i]].escala);
        }
    }
}

/// @desc Move o player de lado pelo vento respeitando paredes (mesma parede do scr_player_colisao)
function scr_player_colisao_vento(_h) {
    var _parede = obj_parede_bebe;
    if (variable_global_exists("sala") && is_struct(global.sala) && variable_struct_exists(global.sala, "parede")) _parede = global.sala.parede;
    aplicar_movimento_com_colisao(_h, 0, _parede);
}


// ============================================================================
// CLIMA: eventos aleatórios (chuva, tempestade com raios, nevasca, areia, furacão)
// ----------------------------------------------------------------------------
// global.clima.evento = "calmo" | "chuva" | "tempestade" | "furacao"
// O que aparece na tela depende do bioma onde o player está (clima_visual):
//   neve    -> chuva vira neve, tempestade/furacão vira NEVASCA
//   deserto -> não chove; tempestade/furacão (ou vento >= 75) vira NUVEM DE AREIA
//   resto   -> chuva / tempestade com RAIOS
// Furacão: nasce no evento "furacao" ou, raramente, numa tempestade com vento >= 90.
// Tudo é atualizado pelo obj_vento (vento_atualizar -> clima_atualizar) e
// desenhado no Draw dele (clima_desenhar).
// ============================================================================

#macro CLIMA_ROLAR_MIN       1200   // de quanto em quanto tempo (frames) sorteia um evento: 20..
#macro CLIMA_ROLAR_MAX       2400   // ..40 s
#macro CLIMA_CHANCE_CHUVA    0.20   // chance de cada sorteio virar chuva
#macro CLIMA_CHANCE_TEMPEST  0.07   // tempestade (vento forte + raios)
#macro CLIMA_CHANCE_FURACAO  0.015  // furacão (vento extremo)
#macro CLIMA_RAIO_AVISO      45     // frames da sombra antes do raio cair
#macro CLIMA_RAIO_DANO       25
#macro CLIMA_RAIO_RAIO       70     // área (px) do raio
#macro CLIMA_FURACAO_RAIO    90     // tamanho do furacão (px)
#macro CLIMA_FURACAO_DANO    12

function clima_init() {
    if (variable_global_exists("clima") && is_struct(global.clima)) return;
    global.clima = {
        evento: "calmo",
        timer: irandom_range(CLIMA_ROLAR_MIN, CLIMA_ROLAR_MAX),
        dur: 0,
        intens: 0,         // intensidade atual 0..1 (entra/sai suave)
        intens_alvo: 0,
        bioma: "floresta", // bioma embaixo do player (atualiza a cada 20 frames)
        visual: "nenhum",
        flash: 0,          // clarão do raio na tela
        raio_timer: 120,
        raios: [],         // { x, y, t, pts }
        furacoes: [],      // { x, y, vx, ang, vida, dur }
        precip: [],        // partículas de chuva/neve/areia
        t: 0
    };
}

/// @desc Força-alvo do vento (0..1). Calmo quase sempre; forte só em eventos.
function clima_sortear_vento() {
    clima_init();
    switch (global.clima.evento) {
        case "chuva":      return 0.20 + random(0.30);
        case "tempestade": return 0.62 + random(0.30);
        case "furacao":    return 0.92 + random(0.08);
    }
    // sem evento: curva bem puxada para baixo (só ~8% passa de 50 e empurra)
    return power(random(1), 4) * 0.70;
}

function clima_nome() {
    clima_init();
    var _c = global.clima;
    if (_c.intens < 0.25) return "";
    switch (_c.visual) {
        case "chuva":      return "Chuva";
        case "tempestade": return (_c.evento == "furacao") ? "FURACÃO!" : "Tempestade!";
        case "neve":       return "Neve";
        case "nevasca":    return (_c.evento == "furacao") ? "FURACÃO DE NEVE!" : "Nevasca!";
        case "areia":      return (_c.evento == "furacao") ? "FURACÃO DE AREIA!" : "Tempestade de areia!";
    }
    return "";
}

/// @desc Começa um evento agora ("chuva", "tempestade", "furacao") — útil para testar
function clima_iniciar(_evento) {
    clima_init();
    var _c = global.clima;
    _c.evento = _evento;
    _c.intens_alvo = 1;
    switch (_evento) {
        case "chuva":      _c.dur = irandom_range(40, 90) * 60; break;
        case "tempestade": _c.dur = irandom_range(30, 60) * 60; break;
        case "furacao":    _c.dur = irandom_range(20, 35) * 60; break;
    }
    if (variable_global_exists("vento") && is_struct(global.vento)) global.vento.timer = 0; // vento muda já
}

function clima_view() {
    if (view_enabled && view_camera[0] != -1) {
        var _cam = view_camera[0];
        return [camera_get_view_x(_cam), camera_get_view_y(_cam), camera_get_view_width(_cam), camera_get_view_height(_cam)];
    }
    return [0, 0, room_width, room_height];
}

/// @desc Avança o clima 1 step (vento_atualizar chama)
function clima_atualizar() {
    clima_init();
    var _c = global.clima;
    _c.t++;

    // ---------- sorteio de eventos ----------
    if (_c.evento == "calmo") {
        _c.timer--;
        if (_c.timer <= 0) {
            _c.timer = irandom_range(CLIMA_ROLAR_MIN, CLIMA_ROLAR_MAX);
            var _sorte = random(1);
            if (_sorte < CLIMA_CHANCE_FURACAO)                                         clima_iniciar("furacao");
            else if (_sorte < CLIMA_CHANCE_FURACAO + CLIMA_CHANCE_TEMPEST)             clima_iniciar("tempestade");
            else if (_sorte < CLIMA_CHANCE_FURACAO + CLIMA_CHANCE_TEMPEST + CLIMA_CHANCE_CHUVA) clima_iniciar("chuva");
        }
    } else {
        _c.dur--;
        if (_c.dur <= 0) {
            _c.evento = "calmo";
            _c.intens_alvo = 0;
            if (variable_global_exists("vento") && is_struct(global.vento)) global.vento.timer = 0;
        }
    }
    _c.intens = lerp(_c.intens, _c.intens_alvo, 0.005);
    if (_c.intens < 0.01 && _c.intens_alvo == 0) _c.intens = 0;

    // ---------- o que mostrar (bioma do player) ----------
    if (_c.t mod 20 == 0 && instance_exists(obj_player)) {
        _c.bioma = terreno_bioma_em(obj_player.x, obj_player.y);
    }
    var _f100 = vento_forca_100();
    var _ev = _c.evento;
    var _vis = "nenhum";
    if (_c.bioma == "neve") {
        if (_ev == "chuva") _vis = "neve";
        else if (_ev != "calmo") _vis = "nevasca";
    } else if (_c.bioma == "deserto") {
        if (_ev == "tempestade" || _ev == "furacao" || _f100 >= 75) _vis = "areia";
    } else {
        if (_ev == "chuva") _vis = "chuva";
        else if (_ev != "calmo") _vis = "tempestade";
    }
    // areia sem evento (só vento forte) não espera a intensidade do evento
    if (_vis == "areia" && _ev == "calmo") _c.intens = max(_c.intens, clamp((_f100 - 75) / 25, 0, 1) * 0.6);
    if (_ev != "calmo" || _vis != "nenhum") _c.visual = _vis;   // mudou de bioma no meio do evento -> troca na hora
    else if (_c.intens <= 0.02) _c.visual = "nenhum";            // evento acabou: some devagar

    var _v = clima_view();

    // ---------- raios (só tempestade fora da neve/deserto) ----------
    if (_c.visual == "tempestade" && _c.intens > 0.4) {
        _c.raio_timer--;
        if (_c.raio_timer <= 0) {
            _c.raio_timer = irandom_range(90, 300);
            var _rx, _ry;
            if (instance_exists(obj_player) && random(1) < 0.35) {
                _rx = obj_player.x + random_range(-160, 160);
                _ry = obj_player.y + random_range(-120, 120);
            } else {
                _rx = _v[0] + random(_v[2]);
                _ry = _v[1] + random(_v[3]);
            }
            array_push(_c.raios, { x: _rx, y: _ry, t: 0, pts: [] });
        }
    }
    for (var _i = array_length(_c.raios) - 1; _i >= 0; _i--) {
        var _r = _c.raios[_i];
        _r.t++;
        if (_r.t == CLIMA_RAIO_AVISO) clima_raio_cair(_r, _v);
        if (_r.t > CLIMA_RAIO_AVISO + 16) array_delete(_c.raios, _i, 1);
    }
    _c.flash = max(0, _c.flash - 0.06);

    // ---------- furacões ----------
    var _vd = (variable_global_exists("vento") && is_struct(global.vento)) ? global.vento.dir : 1;
    var _quer = (_c.evento == "furacao" && _c.intens > 0.5)
             || (_c.evento == "tempestade" && _f100 >= 90 && random(1) < 0.002);
    if (_quer && array_length(_c.furacoes) < ((_c.evento == "furacao") ? 2 : 1) && random(1) < 0.01) {
        var _fx = (_vd > 0) ? _v[0] - CLIMA_FURACAO_RAIO * 2 : _v[0] + _v[2] + CLIMA_FURACAO_RAIO * 2;
        array_push(_c.furacoes, {
            x: _fx, y: _v[1] + _v[3] * random_range(0.25, 0.85),
            vx: _vd * random_range(1.2, 2.2), ang: 0, vida: 0, dur: irandom_range(900, 1500), fase: random(100)
        });
    }
    for (var _i = array_length(_c.furacoes) - 1; _i >= 0; _i--) {
        var _h = _c.furacoes[_i];
        _h.vida++;
        _h.ang += 0.25;
        _h.x += _h.vx;
        _h.y += sin((_h.vida + _h.fase) * 0.02) * 1.2;
        // vai atrás do player devagar (só no eixo y), assim ele tem que fugir
        if (instance_exists(obj_player)) _h.y += sign(obj_player.y - _h.y) * 0.4;
        clima_furacao_puxar(_h);
        var _fora = (_h.x < _v[0] - 600) || (_h.x > _v[0] + _v[2] + 600);
        if (_h.vida > _h.dur || (_fora && _h.vida > 300)) array_delete(_c.furacoes, _i, 1);
    }
}

/// @desc O raio cai: clarão, dano em inimigos (obj_raio) e no player
function clima_raio_cair(_r, _v) {
    var _c = global.clima;
    _c.flash = 1;
    // zigue-zague do céu (topo da tela) até o chão
    var _y0 = _v[1] - 40;
    var _n = 9;
    _r.pts = [];
    for (var _k = 0; _k <= _n; _k++) {
        var _p = _k / _n;
        var _jx = (_k == 0 || _k == _n) ? 0 : random_range(-26, 26);
        array_push(_r.pts, [_r.x + _jx + (_k == 0 ? random_range(-60, 60) : 0), lerp(_y0, _r.y, _p)]);
    }
    // inimigos: reaproveita o obj_raio (já faz dano em instâncias + horda)
    if (object_exists(obj_raio)) {
        var _o = instance_create_depth(_r.x, _r.y, -_r.y, obj_raio);
        _o.damage = CLIMA_RAIO_DANO;
        _o.radius = CLIMA_RAIO_RAIO;
        _o.push_force = 4;
    }
    // player
    with (obj_player) {
        if (point_distance(x, y, _r.x, _r.y) <= CLIMA_RAIO_RAIO * 0.8) clima_dano_player(CLIMA_RAIO_DANO, _r.x, _r.y, c_yellow);
    }
}

/// @desc Dano de clima no player (mesmo esquema do carro). Rodar dentro de with(obj_player).
function clima_dano_player(_base, _de_x, _de_y, _cor) {
    if (!tomar_dano) exit;
    var _dano = player_dano_recebido(_base);
    if (_dano <= 0) exit;
    global.vida -= _dano;
    empurrar_dir = (x == _de_x && y == _de_y) ? 0 : point_direction(_de_x, _de_y, x, y);
    hit = true;
    alarm[ALARM_KNOCKBACK] = 15;
    tomar_dano = false;
    alarm[ALARM_INVENCIBILIDADE] = 90;
    player_sinal_dano(_cor, 90);
    if (object_exists(obj_dano)) {
        var _pop = instance_create_layer(x, y - 30, "Instances", obj_dano);
        _pop.dano = _dano;
        _pop.cor = _cor;
    }
}

/// @desc Furacão puxa e gira player e inimigos que estão perto
function clima_furacao_puxar(_h) {
    var _alc = CLIMA_FURACAO_RAIO * 1.8;
    with (obj_player) {
        var _parado = (instance_exists(obj_inventario) && obj_inventario.is_open)
                   || (variable_global_exists("dialogo") && global.dialogo);
        var _d = point_distance(x, y, _h.x, _h.y);
        if (!_parado && _d < _alc) {
            var _k = 1 - _d / _alc;
            var _a = point_direction(x, y, _h.x, _h.y);
            var _mx = lengthdir_x(_k * 2.6, _a) + lengthdir_x(_k * 2.0, _a + 90);
            var _my = lengthdir_y(_k * 2.6, _a) + lengthdir_y(_k * 2.0, _a + 90);
            var _parede = obj_parede_bebe;
            if (variable_global_exists("sala") && is_struct(global.sala) && variable_struct_exists(global.sala, "parede")) _parede = global.sala.parede;
            aplicar_movimento_com_colisao(_mx, _my, _parede);
            if (_d < CLIMA_FURACAO_RAIO * 0.4) clima_dano_player(CLIMA_FURACAO_DANO, _h.x, _h.y, make_color_rgb(180, 200, 220));
        }
    }
    with (obj_par_inimigos) {
        var _d = point_distance(x, y, _h.x, _h.y);
        if (_d < _alc) {
            var _k = (1 - _d / _alc) / max(1, (variable_instance_exists(id, "escala") ? escala : 1));
            var _a = point_direction(x, y, _h.x, _h.y);
            var _mx = lengthdir_x(_k * 3, _a) + lengthdir_x(_k * 3, _a + 90);
            var _my = lengthdir_y(_k * 3, _a) + lengthdir_y(_k * 3, _a + 90);
            if (variable_instance_exists(id, "atravessa")) inimigo_ia_mover(_mx, _my);
            else aplicar_movimento_com_colisao(_mx, _my);
        }
    }
    with (obj_horde) {
        for (var _i = 0; _i < alive; _i++) {
            var _d = point_distance(ex[_i], ey[_i], _h.x, _h.y);
            if (_d < _alc && _d > 1) {
                var _k = (1 - _d / _alc) * 3 / max(1, types[etype[_i]].escala);
                var _a = point_direction(ex[_i], ey[_i], _h.x, _h.y);
                ex[_i] += lengthdir_x(_k, _a) + lengthdir_x(_k, _a + 90);
                ey[_i] += lengthdir_y(_k, _a) + lengthdir_y(_k, _a + 90);
            }
        }
    }
}

/// @desc Cria e move as partículas de chuva/neve/areia (obj_vento Step)
function clima_particulas() {
    clima_init();
    var _c = global.clima;
    var _v = clima_view();
    var _vt = global.vento;
    var _vis = _c.visual;
    var _max = 0, _taxa = 0;
    switch (_vis) {
        case "chuva":      _max = 220; _taxa = 6;  break;
        case "tempestade": _max = 380; _taxa = 10; break;
        case "neve":       _max = 160; _taxa = 3;  break;
        case "nevasca":    _max = 380; _taxa = 10; break;
        case "areia":      _max = 340; _taxa = 10; break;
    }
    _max = round(_max * _c.intens);
    repeat (_taxa) if (array_length(_c.precip) < _max) {
        var _p = { tipo: _vis, x: _v[0] + random_range(-100, _v[2] + 100), y: _v[1] - random(40),
                   vx: 0, vy: 0, vida: 0, chao: _v[1] + random(_v[3]), esc: 1, fase: random(2 * pi) };
        switch (_vis) {
            case "chuva": case "tempestade":
                _p.vy = random_range(9, 12);
                _p.vx = _vt.dir * _vt.forca * 6;
                break;
            case "neve": case "nevasca":
                _p.vy = random_range(0.8, 1.8) * (_vis == "nevasca" ? 1.6 : 1);
                _p.vx = _vt.dir * (0.4 + _vt.forca * (_vis == "nevasca" ? 9 : 3));
                _p.esc = choose(1, 1, 2, 2, 3);
                if (_vis == "nevasca") { // entra pelo lado do vento
                    _p.x = (_vt.dir > 0) ? _v[0] - 20 : _v[0] + _v[2] + 20;
                    _p.y = _v[1] + random(_v[3]);
                    _p.chao = 999999;
                }
                break;
            case "areia":
                _p.x = (_vt.dir > 0) ? _v[0] - 20 : _v[0] + _v[2] + 20;
                _p.y = _v[1] + random(_v[3]);
                _p.vx = _vt.dir * random_range(7, 13) * (0.6 + _vt.forca);
                _p.vy = random_range(-0.8, 0.8);
                _p.esc = choose(1, 2, 2, 3);
                _p.chao = 999999;
                break;
        }
        array_push(_c.precip, _p);
    }
    for (var _i = array_length(_c.precip) - 1; _i >= 0; _i--) {
        var _p = _c.precip[_i];
        if (_p.vida < 0) { // respingo da chuva (vida negativa = contando o respingo)
            _p.vida++;
            if (_p.vida >= 0) array_delete(_c.precip, _i, 1);
            continue;
        }
        _p.vida++;
        _p.x += _p.vx * (1 + vento_rajada_em(_p.x));
        _p.y += _p.vy;
        if (_p.tipo == "neve" || _p.tipo == "nevasca") _p.x += sin(_p.vida * 0.05 + _p.fase) * 0.6;
        if (_p.y >= _p.chao) {
            if (_p.tipo == "chuva" || _p.tipo == "tempestade") { _p.vida = -8; _p.vx = 0; _p.vy = 0; continue; }
            array_delete(_c.precip, _i, 1);
            continue;
        }
        var _fora = (_p.x < _v[0] - 150) || (_p.x > _v[0] + _v[2] + 150) || (_p.y > _v[1] + _v[3] + 60);
        if (_fora || _p.vida > 900) array_delete(_c.precip, _i, 1);
    }
}

/// @desc Desenha tudo do clima (obj_vento Draw, por cima do cenário)
function clima_desenhar() {
    clima_init();
    var _c = global.clima;
    var _v = clima_view();
    var _x1 = _v[0] - 4, _y1 = _v[1] - 4, _x2 = _v[0] + _v[2] + 4, _y2 = _v[1] + _v[3] + 4;

    // ---------- céu escurecendo / neblina ----------
    if (_c.intens > 0.01) {
        var _cor = c_black, _al = 0;
        switch (_c.visual) {
            case "chuva":      _cor = make_color_rgb(30, 40, 70);    _al = 0.18; break;
            case "tempestade": _cor = make_color_rgb(20, 24, 48);    _al = 0.38; break;
            case "neve":       _cor = make_color_rgb(230, 240, 255); _al = 0.12; break;
            case "nevasca":    _cor = make_color_rgb(235, 242, 255); _al = 0.45; break;
            case "areia":      _cor = make_color_rgb(205, 160, 90);  _al = 0.50; break;
        }
        if (_al > 0) {
            draw_set_alpha(_al * _c.intens);
            draw_rectangle_colour(_x1, _y1, _x2, _y2, _cor, _cor, _cor, _cor, false);
        }
    }

    // ---------- sombra de aviso do raio ----------
    for (var _i = 0; _i < array_length(_c.raios); _i++) {
        var _r = _c.raios[_i];
        if (_r.t < CLIMA_RAIO_AVISO) {
            var _p = _r.t / CLIMA_RAIO_AVISO;
            var _pisca = (_r.t mod 8 < 4) ? 1 : 0.6;
            draw_set_alpha(0.25 + 0.35 * _p * _pisca);
            draw_set_colour(c_black);
            draw_ellipse(_r.x - CLIMA_RAIO_RAIO * _p, _r.y - CLIMA_RAIO_RAIO * 0.5 * _p,
                         _r.x + CLIMA_RAIO_RAIO * _p, _r.y + CLIMA_RAIO_RAIO * 0.5 * _p, false);
            draw_set_alpha(0.7 * _pisca);
            draw_set_colour(c_yellow);
            draw_ellipse(_r.x - CLIMA_RAIO_RAIO, _r.y - CLIMA_RAIO_RAIO * 0.5,
                         _r.x + CLIMA_RAIO_RAIO, _r.y + CLIMA_RAIO_RAIO * 0.5, true);
        }
    }

    // ---------- furacões ----------
    for (var _i = 0; _i < array_length(_c.furacoes); _i++) {
        var _h = _c.furacoes[_i];
        var _al = min(1, _h.vida / 60, (_h.dur - _h.vida) / 60);
        var _base = make_color_rgb(120, 130, 145);
        var _clara = make_color_rgb(200, 210, 220);
        if (_c.bioma == "deserto") { _base = make_color_rgb(170, 125, 70); _clara = make_color_rgb(230, 195, 140); }
        if (_c.bioma == "neve")    { _base = make_color_rgb(170, 185, 210); _clara = c_white; }
        var _R = CLIMA_FURACAO_RAIO;
        // sombra no chão
        draw_set_alpha(0.3 * _al);
        draw_set_colour(c_black);
        draw_ellipse(_h.x - _R * 0.7, _h.y - _R * 0.22, _h.x + _R * 0.7, _h.y + _R * 0.22, false);
        // funil: pontos subindo em espiral, abrindo para cima
        for (var _k = 0; _k < 90; _k++) {
            var _t = _k / 90;
            var _rr = 8 + _t * _R;
            var _a = _h.ang * (2.2 - _t) + _k * 0.85;
            var _px = _h.x + cos(_a) * _rr + sin(_h.vida * 0.05 + _t * 4) * 10 * _t;
            var _py = _h.y - _t * _R * 2.4 + sin(_a) * _rr * 0.3;
            var _frente = sin(_a) > 0;
            draw_set_alpha((_frente ? 0.85 : 0.45) * _al);
            draw_set_colour(merge_colour(_base, _clara, _frente ? 0.6 : 0.1));
            draw_circle(_px, _py, 2 + _t * 6, false);
        }
        // poeira girando no pé
        for (var _k = 0; _k < 14; _k++) {
            var _a = _h.ang * 1.6 + _k * (2 * pi / 14);
            draw_set_alpha(0.5 * _al);
            draw_set_colour(_clara);
            draw_circle(_h.x + cos(_a) * _R * 0.6, _h.y + sin(_a) * _R * 0.18, 3, false);
        }
    }

    // ---------- chuva / neve / areia ----------
    var _azul = make_color_rgb(170, 200, 255);
    var _areia1 = make_color_rgb(225, 185, 120), _areia2 = make_color_rgb(180, 135, 75);
    for (var _i = 0; _i < array_length(_c.precip); _i++) {
        var _p = _c.precip[_i];
        switch (_p.tipo) {
            case "chuva": case "tempestade":
                if (_p.vida < 0) { // respingo
                    var _s = (8 + _p.vida) / 8;
                    draw_set_alpha(0.6 * (1 - _s));
                    draw_set_colour(_azul);
                    draw_ellipse(_p.x - 2 - _s * 5, _p.y - 1 - _s * 2, _p.x + 2 + _s * 5, _p.y + 1 + _s * 2, true);
                } else {
                    draw_set_alpha(0.55);
                    draw_set_colour(_azul);
                    draw_line_width(_p.x, _p.y, _p.x - _p.vx * 1.4, _p.y - _p.vy * 1.4, 1.5);
                }
                break;
            case "neve": case "nevasca":
                draw_set_alpha(0.9);
                draw_set_colour(c_white);
                draw_circle(_p.x, _p.y, _p.esc, false);
                break;
            case "areia":
                draw_set_alpha(0.75);
                draw_set_colour((_i mod 2 == 0) ? _areia1 : _areia2);
                draw_rectangle(_p.x, _p.y, _p.x + _p.esc * 2, _p.y + _p.esc, false);
                break;
        }
    }

    // ---------- raio caindo ----------
    for (var _i = 0; _i < array_length(_c.raios); _i++) {
        var _r = _c.raios[_i];
        if (_r.t >= CLIMA_RAIO_AVISO && array_length(_r.pts) > 1) {
            var _al = 1 - (_r.t - CLIMA_RAIO_AVISO) / 16;
            for (var _k = 0; _k < array_length(_r.pts) - 1; _k++) {
                var _a = _r.pts[_k], _b = _r.pts[_k + 1];
                draw_set_alpha(0.45 * _al);
                draw_set_colour(make_color_rgb(150, 190, 255));
                draw_line_width(_a[0], _a[1], _b[0], _b[1], 10);
                draw_set_alpha(_al);
                draw_set_colour(c_white);
                draw_line_width(_a[0], _a[1], _b[0], _b[1], 3);
            }
        }
    }

    // ---------- clarão ----------
    if (_c.flash > 0) {
        draw_set_alpha(_c.flash * 0.55);
        draw_rectangle_colour(_x1, _y1, _x2, _y2, c_white, c_white, c_white, c_white, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
