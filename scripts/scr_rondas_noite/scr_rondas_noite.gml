// feather disable GM2017
/// @desc scr_rondas_noite — Rondas da noite (estilo Vampire Survivors)
/// [O QUE]: Linha do tempo da noite. Cada ronda libera novos inimigos e eventos (anel/elite),
///          e TUDO fica mais forte com o tempo: vida, dano, XP, tamanho, velocidade e ritmo de spawn.
/// [COMO] :
///  - global.rondas (rondas_definir) é a ÚNICA tabela que você mexe para montar a noite.
///  - O tempo usado é "minutos de noite acumulados": noite 1 vai de 0 a 6, noite 2 de 6 a 12...
///    Então a 2ª noite já começa mais difícil que o fim da 1ª.
///  - Os status base vêm do Create de cada inimigo; aqui só entram multiplicadores.
///  - Inimigos comuns viram horda (obj_horde); os de horde_instance_only continuam instâncias.
///  - Chamado por obj_control_vamp: init_night_waves() no Create e process_night_waves() no Step.

// ---------------------------------------------------------------------------
// ESCALONAMENTO (por minuto de noite acumulado)
// ---------------------------------------------------------------------------
#macro RONDA_VIDA_POR_MIN       0.30   // +30% de vida por minuto
#macro RONDA_DANO_POR_MIN       0.10   // +10% de dano por minuto
#macro RONDA_XP_POR_MIN         0.20   // +20% de XP por minuto
#macro RONDA_ESCALA_POR_MIN     0.025  // +2.5% de tamanho por minuto...
#macro RONDA_ESCALA_MAX         1.6    // ...até no máximo 1.6x
#macro RONDA_VELOC_POR_MIN      0.015  // +1.5% de velocidade por minuto...
#macro RONDA_VELOC_MAX          1.35   // ...até no máximo 1.35x
#macro RONDA_TAXA_POR_MIN       0.06   // spawns 6% mais frequentes por minuto...
#macro RONDA_TAXA_MAX           3.0    // ...até 3x mais rápido
#macro RONDA_GRUPO_A_CADA_MIN   4      // +1 inimigo em cada grupo a cada N minutos
#macro RONDA_VIDA_POR_LEVEL     0.08   // +8% de vida por nível do jogador (em degraus de 3 níveis)

// ---------------------------------------------------------------------------
// ELITES (mini-chefes dos eventos "elite")
// ---------------------------------------------------------------------------
#macro RONDA_ELITE_VIDA         12
#macro RONDA_ELITE_DANO         2
#macro RONDA_ELITE_XP           15
#macro RONDA_ELITE_ESCALA       1.8
#macro RONDA_ELITE_VELOC        0.85

// ---------------------------------------------------------------------------
// AVISO NA TELA
// ---------------------------------------------------------------------------
#macro RONDA_AVISO_SEGUNDOS     3
#macro RONDA_AVISO_Y            0.18   // altura do aviso (fração da altura da GUI)

/// @function rondas_definir()
/// @description Tabela da noite. Tempos em SEGUNDOS desde o início da noite (a noite tem 360 s).
///   inicio   : quando a ronda começa
///   nome     : texto do aviso
///   inimigos : spawns contínuos -> obj, intervalo (s entre grupos), grupo (qtd por grupo), xp (peso, opcional)
///   eventos  : acontecem uma vez na ronda -> tempo (s depois do início da ronda),
///              tipo "anel" (cerco em volta do jogador) ou "elite" (mini-chefe), obj, qtd
function rondas_definir() {
    global.rondas = [
        // 0:00 — só o básico
        { inicio: 0, nome: "O Anoitecer",
          inimigos: [
            { obj: obj_amoeba,        intervalo: 1.4, grupo: 2 },
            { obj: obj_morcego,       intervalo: 3.5, grupo: 1 }
          ],
          eventos: [] },

        // 0:45 — slimes coloridos + primeiro cerco
        { inicio: 45, nome: "Gosma na Escuridão",
          inimigos: [
            { obj: obj_amoeba,        intervalo: 1.2, grupo: 2 },
            { obj: obj_amoeba_azul,   intervalo: 2.0, grupo: 2 },
            { obj: obj_morcego,       intervalo: 2.5, grupo: 2 }
          ],
          eventos: [
            { tempo: 20, tipo: "anel", obj: obj_amoeba, qtd: 40 }
          ] },

        // 1:30 — ratos e os primeiros esqueletos
        { inicio: 90, nome: "Ratos do Esgoto",
          inimigos: [
            { obj: obj_amoeba_azul,   intervalo: 1.6, grupo: 2 },
            { obj: obj_rato,          intervalo: 1.8, grupo: 3 },
            { obj: obj_esqueleto,     intervalo: 2.5, grupo: 2 }
          ],
          eventos: [
            { tempo: 30, tipo: "elite", obj: obj_rato_gigante, qtd: 1 }
          ] },

        // 2:15 — ossos
        { inicio: 135, nome: "Ossos ao Luar",
          inimigos: [
            { obj: obj_esqueleto,          intervalo: 1.0, grupo: 3 },
            { obj: obj_esqueleto_corredor, intervalo: 2.5, grupo: 2 },
            { obj: obj_amoeba_laranja,     intervalo: 4.0, grupo: 1, xp: 2 }
          ],
          eventos: [
            { tempo: 15, tipo: "anel",  obj: obj_esqueleto, qtd: 60 }
          ] },

        // 3:00 — meio da noite: guerreiros, fantasmas, vampiros e arqueiros
        { inicio: 180, nome: "A Legião",
          inimigos: [
            { obj: obj_esqueleto_guerreiro, intervalo: 2.2, grupo: 2, xp: 2 },
            { obj: obj_fantasma_azul,       intervalo: 2.0, grupo: 2 },
            { obj: obj_morcego_vampiro,     intervalo: 2.5, grupo: 3 },
            { obj: obj_esqueleto_arqueiro,  intervalo: 6.0, grupo: 1, xp: 2 }
          ],
          eventos: [
            { tempo: 10, tipo: "anel",  obj: obj_morcego_vampiro, qtd: 60 },
            { tempo: 35, tipo: "elite", obj: obj_esqueleto_guerreiro, qtd: 1 }
          ] },

        // 3:45 — assombração
        { inicio: 225, nome: "Assombração",
          inimigos: [
            { obj: obj_fantasma_azul,       intervalo: 1.4, grupo: 3 },
            { obj: obj_fantasma_verde,      intervalo: 2.0, grupo: 2 },
            { obj: obj_cogumelo_venenoso,   intervalo: 2.5, grupo: 2 },
            { obj: obj_rato_gigante,        intervalo: 5.0, grupo: 1, xp: 3 }
          ],
          eventos: [
            { tempo: 20, tipo: "elite", obj: obj_fantasma_verde, qtd: 2 }
          ] },

        // 4:30 — caçadores
        { inicio: 270, nome: "Caçadores da Noite",
          inimigos: [
            { obj: obj_fantasma_vermelho,   intervalo: 3.0, grupo: 2, xp: 2 },
            { obj: obj_esqueleto_guerreiro, intervalo: 1.5, grupo: 3, xp: 2 },
            { obj: obj_morcego_vampiro,     intervalo: 1.2, grupo: 3 },
            { obj: obj_olho_vazio,          intervalo: 7.0, grupo: 1, xp: 3 }
          ],
          eventos: [
            { tempo: 15, tipo: "anel",  obj: obj_fantasma_azul, qtd: 80 },
            { tempo: 30, tipo: "elite", obj: obj_fantasma_vermelho, qtd: 2 }
          ] },

        // 5:15 até o amanhecer — tudo junto
        { inicio: 315, nome: "Meia-Noite Sangrenta",
          inimigos: [
            { obj: obj_esqueleto,           intervalo: 0.8, grupo: 4 },
            { obj: obj_esqueleto_guerreiro, intervalo: 1.4, grupo: 3, xp: 2 },
            { obj: obj_fantasma_vermelho,   intervalo: 2.5, grupo: 2, xp: 2 },
            { obj: obj_morcego_vampiro,     intervalo: 1.0, grupo: 3 },
            { obj: obj_amoeba_laranja,      intervalo: 3.0, grupo: 2, xp: 2 },
            { obj: obj_esqueleto_arqueiro,  intervalo: 5.0, grupo: 1, xp: 2 }
          ],
          eventos: [
            { tempo: 5,  tipo: "anel",  obj: obj_morcego_vampiro, qtd: 100 },
            { tempo: 20, tipo: "elite", obj: obj_rato_gigante, qtd: 2 },
            { tempo: 30, tipo: "anel",  obj: obj_esqueleto_guerreiro, qtd: 100 }
          ] }
    ];
}

#region ---------- TEMPO / DIFICULDADE ----------

/// Segundos desde o início da noite atual (0 se for dia).
function rondas_tempo_na_noite() {
    var _c = global.day_night_cycle;
    var _full = _c.day_duration + _c.night_duration;
    return max(0, (global.timer mod _full) - _c.day_duration);
}

/// Minutos de noite acumulados (a dificuldade cresce noite após noite).
function rondas_minutos() {
    var _c = global.day_night_cycle;
    return global.ronda_noite_idx * (_c.night_duration / 60) + rondas_tempo_na_noite() / 60;
}

/// Multiplicadores para um inimigo nascido agora. Os valores andam em degraus de 1 minuto
/// (e de 3 níveis do jogador) para a horda não criar um tipo novo a cada frame.
function rondas_mults(_minutos, _elite, _xp_peso = 1) {
    var _tier = floor(_minutos);
    var _lvl  = variable_global_exists("level_player") ? global.level_player : 1;
    var _lb   = floor(max(0, _lvl - 1) / 3);
    return {
        hp:    (1 + _tier * RONDA_VIDA_POR_MIN) * (1 + _lb * 3 * RONDA_VIDA_POR_LEVEL) * (_elite ? RONDA_ELITE_VIDA : 1),
        dmg:   (1 + _tier * RONDA_DANO_POR_MIN) * (_elite ? RONDA_ELITE_DANO : 1),
        xp:    (1 + _tier * RONDA_XP_POR_MIN) * _xp_peso * (_elite ? RONDA_ELITE_XP : 1),
        esc:   min(RONDA_ESCALA_MAX, 1 + _tier * RONDA_ESCALA_POR_MIN) * (_elite ? RONDA_ELITE_ESCALA : 1),
        spd:   min(RONDA_VELOC_MAX,  1 + _tier * RONDA_VELOC_POR_MIN)  * (_elite ? RONDA_ELITE_VELOC  : 1),
        elite: _elite,
        chave: "|r" + string(_tier) + "|L" + string(_lb) + "|x" + string(_xp_peso) + (_elite ? "|e" : "")
    };
}

/// Monta o pedido de spawn de um item da tabela.
function rondas_spec(_obj, _qtd, _elite, _xp_peso = 1) {
    return { obj: _obj, qtd: max(1, _qtd), mult: rondas_mults(rondas_minutos(), _elite, _xp_peso) };
}

/// Um inimigo aleatório da ronda atual que possa ser horda (usado pelo cerco automático do obj_horde).
function rondas_spec_aleatorio(_qtd) {
    if (!variable_global_exists("ronda_idx") || global.ronda_idx < 0) return undefined;
    var _lista = global.rondas[global.ronda_idx].inimigos;
    var _n = array_length(_lista);
    for (var _try = 0; _try < 6; _try++) {
        var _e = _lista[irandom(_n - 1)];
        if (!horde_instance_only(_e.obj)) return rondas_spec(_e.obj, _qtd, false, _e[$ "xp"] ?? 1);
    }
    return undefined;
}

#endregion

#region ---------- CICLO DA NOITE ----------

/// @function init_night_waves()
/// @description Chamar no CREATE do controlador (obj_control_vamp).
function init_night_waves() {
    rondas_definir();
    global.night_started        = false;
    global.ronda_noite_idx      = 0;     // 0 = primeira noite
    global.ronda_idx            = -1;    // ronda atual
    global.current_wave_idx     = -1;    // compatibilidade com código antigo
    global.ronda_acc            = [];    // acumulador de tempo de cada spawn contínuo
    global.ronda_eventos_feitos = [];
    global.ronda_timer_ant      = global.timer;
    global.ronda_aviso_t        = 0;     // segundos restantes do aviso na tela
    global.ronda_aviso_txt      = "";
    global.ronda_aviso_sub      = "";
}

/// Índice da última ronda cujo início já passou.
function rondas_indice_no_tempo(_t) {
    var _idx = 0;
    var _n = array_length(global.rondas);
    for (var _i = 0; _i < _n; _i++) {
        if (global.rondas[_i].inicio <= _t) _idx = _i; else break;
    }
    return _idx;
}

function rondas_iniciar(_idx) {
    global.ronda_idx = _idx;
    global.current_wave_idx = _idx;
    var _r = global.rondas[_idx];
    var _n = array_length(_r.inimigos);
    global.ronda_acc = array_create(_n, 0);
    // Primeiro grupo de cada inimigo sai logo que a ronda começa
    for (var _i = 0; _i < _n; _i++) global.ronda_acc[_i] = _r.inimigos[_i].intervalo;
    global.ronda_eventos_feitos = array_create(array_length(_r.eventos), false);

    global.ronda_aviso_t   = RONDA_AVISO_SEGUNDOS;
    global.ronda_aviso_txt = "NOITE " + string(global.ronda_noite_idx + 1) + "  -  RONDA " + string(_idx + 1);
    global.ronda_aviso_sub = _r.nome;
    show_debug_message("RONDA " + string(_idx + 1) + " (" + _r.nome + ") | noite " + string(global.ronda_noite_idx + 1)
        + " | minuto acumulado " + string_format(rondas_minutos(), 0, 2));
}

function rondas_evento(_ev) {
    switch (_ev.tipo) {
        case "anel":
            var _spec = rondas_spec(_ev.obj, _ev.qtd, false);
            if (!horde_spawn_anel(_spec)) spawn_night_enemy(_spec); // instâncias: nascem no quadrado
            break;
        case "elite":
            spawn_night_enemy(rondas_spec(_ev.obj, _ev.qtd, true));
            global.ronda_aviso_t   = RONDA_AVISO_SEGUNDOS;
            global.ronda_aviso_txt = "ELITE!";
            global.ronda_aviso_sub = "";
            break;
    }
}

/// @function process_night_waves()
/// @description Chamar no STEP do controlador (já pausa junto no level up).
function process_night_waves() {
    var _dt = clamp(global.timer - global.ronda_timer_ant, 0, 1); // tempo do jogo (respeita o "L" acelerado)
    global.ronda_timer_ant = global.timer;
    if (global.ronda_aviso_t > 0) global.ronda_aviso_t -= 1 / game_get_speed(gamespeed_fps);

    var _c = global.day_night_cycle;

    // 1. Dia: encerra a noite
    if (_c.is_day) {
        if (global.night_started) {
            global.night_started = false;
            global.ronda_idx = -1;
            global.current_wave_idx = -1;
            show_debug_message("DIA AMANHECEU!");
        }
        return;
    }

    // 2. Começo da noite
    if (!global.night_started) {
        global.night_started = true;
        global.ronda_noite_idx = floor(global.timer / (_c.day_duration + _c.night_duration));
        global.ronda_idx = -1;
        show_debug_message("NOITE " + string(global.ronda_noite_idx + 1) + " COMEÇOU! Timer: " + string(global.timer));
    }

    // 3. Troca de ronda
    var _t = rondas_tempo_na_noite();
    var _idx = rondas_indice_no_tempo(_t);
    if (_idx != global.ronda_idx) rondas_iniciar(_idx);

    var _r = global.rondas[global.ronda_idx];
    var _m = rondas_minutos();

    // 4. Spawns contínuos (ritmo e tamanho do grupo crescem com o tempo)
    var _taxa  = min(RONDA_TAXA_MAX, 1 + _m * RONDA_TAXA_POR_MIN);
    var _extra = floor(_m / RONDA_GRUPO_A_CADA_MIN);
    var _n = array_length(_r.inimigos);
    for (var _i = 0; _i < _n; _i++) {
        var _e = _r.inimigos[_i];
        var _int = max(0.05, _e.intervalo);
        global.ronda_acc[_i] += _dt * _taxa;
        var _guard = 0;
        while (global.ronda_acc[_i] >= _int && _guard < 4) {
            global.ronda_acc[_i] -= _int;
            spawn_night_enemy(rondas_spec(_e.obj, _e.grupo + _extra, false, _e[$ "xp"] ?? 1));
            _guard += 1;
        }
        if (_guard >= 4) global.ronda_acc[_i] = min(global.ronda_acc[_i], _int);
    }

    // 5. Eventos da ronda (uma vez cada)
    var _ne = array_length(_r.eventos);
    for (var _j = 0; _j < _ne; _j++) {
        if (global.ronda_eventos_feitos[_j]) continue;
        var _ev = _r.eventos[_j];
        if (_t >= _r.inicio + _ev.tempo) {
            global.ronda_eventos_feitos[_j] = true;
            rondas_evento(_ev);
        }
    }
}

#endregion

#region ---------- GUI ----------

/// Aviso de ronda/elite no topo da tela (chamado no Draw GUI do obj_horde).
function rondas_desenhar_gui() {
    if (!variable_global_exists("ronda_aviso_t") || global.ronda_aviso_t <= 0) return;
    var _a = clamp(global.ronda_aviso_t / 0.6, 0, 1); // some nos últimos 0.6 s
    var _gx = display_get_gui_width() * 0.5;
    var _gy = display_get_gui_height() * RONDA_AVISO_Y;

    draw_set_font(fnt_dano);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_a);
    draw_set_color((global.ronda_aviso_txt == "ELITE!") ? c_red : c_white);
    // feather ignore GM2043
    draw_text_colour_outline(_gx, _gy, global.ronda_aviso_txt, 4, c_black, 8, 100, 100);
    if (global.ronda_aviso_sub != "") {
        draw_set_color(c_orange);
        // feather ignore GM2043
        draw_text_colour_outline(_gx, _gy + 40, global.ronda_aviso_sub, 4, c_black, 8, 100, 100);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

#endregion
