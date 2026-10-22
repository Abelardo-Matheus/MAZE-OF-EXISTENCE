// feather disable GM2017
// ==============================================================================
// scr_tutorial — Tutorial da casa (room Main_tutorial)
// ==============================================================================
// [O QUE]: 1) Decora a casa do tutorial (piso por cômodo, móveis, tapetes e quadros).
//          2) Define os PASSOS do tutorial (data-driven): cada passo tem o texto do objetivo,
//             o que fazer ao começar (diálogo, spawn...) e a condição para terminar.
// [COMO] : obj_tutorial_controller chama tutorial_decorar_casa() + tutorial_preparar_progresso()
//          no 1º Step e percorre o array de tutorial_passos(). Para mudar a ordem ou adicionar
//          um passo, é só mexer no array. Os textos dos diálogos ficam em scr_textos ("Tuto_...").
// ==============================================================================

#macro TUTO_ESCALA_MOVEIS 0.6     // os móveis da fase bebê são grandes: aqui combinam com a mesa/cadeiras da sala
#macro TUTO_ARENA_X 2600          // centro da sala de brinquedos (treino com poderes)
#macro TUTO_ARENA_Y 1290

#region ---------- LAYOUT DA CASA ----------

/// Móveis: [tipo (global.casa_catalogo), x do pé, y do pé, de costas (0/1)]
function tutorial_moveis_lista() {
    return [
        ["cama", 400, 260, 0],
        ["criado_mudo", 480, 130, 0],
        ["brinquedos", 380, 470, 0],
        ["brinquedos", 560, 300, 0],
        ["bau", 560, 480, 1],
        ["luminaria", 980, 200, 0],
        ["planta", 980, 480, 0],
        ["pufe", 900, 480, 0],
        ["sofa", 470, 680, 0],
        ["mesa_centro", 470, 760, 0],
        ["planta", 360, 640, 0],
        ["tv", 880, 650, 0],
        ["poltrona", 880, 800, 1],
        ["luminaria", 980, 760, 0],
        ["estante", 400, 1500, 1],
        ["relogio", 560, 1500, 1],
        ["planta", 360, 1300, 0],
        ["planta", 1060, 1120, 0],
        ["caixas", 1060, 1500, 1],
        ["barril", 1120, 1500, 1],
        ["planta", 1430, 1120, 0],
        ["geladeira", 1550, 580, 0],
        ["fogao", 1660, 580, 0],
        ["armario_cozinha", 1760, 580, 0],
        ["balcao", 1880, 580, 0],
        ["lixeira", 1990, 580, 0],
        ["mesa_jantar", 1820, 820, 0],
        ["cadeira", 1790, 735, 1],
        ["cadeira", 1850, 735, 1],
        ["cadeira", 1790, 870, 0],
        ["cadeira", 1850, 870, 0],
        ["planta", 2130, 580, 0],
        ["planta", 1530, 980, 0],
        ["cavalinho", 2280, 1130, 0],
        ["brinquedos", 2400, 1120, 0],
        ["estante", 2560, 1130, 0],
        ["brinquedos", 2720, 1120, 0],
        ["caixas", 2860, 1130, 0],
        ["caixas", 2910, 1140, 0],
        ["relogio", 3060, 1130, 0],
        ["pufe", 2300, 1500, 1],
        ["bau", 2600, 1500, 1],
        ["planta", 3060, 1500, 0],
        ["brinquedos", 2900, 1500, 0],
        ["banheira", 830, 2040, 1],
        ["privada", 1010, 2040, 1],
        ["armario_banheiro", 1150, 2040, 1],
        ["maquina_lavar", 1300, 1720, 0],
        ["cesto_roupa", 1310, 1860, 0],
        ["lixeira", 730, 1640, 0]
    ];
}

/// Tapetes: [frame do spr_tapete_casa, x, y, escala]
function tutorial_tapetes_lista() {
    return [
        [2, 450, 300, 0.55],
        [0, 470, 740, 0.6],
        [3, 1820, 800, 0.6],
        [5, 2600, 1300, 0.8],
        [4, 1020, 1820, 0.5]
    ];
}

/// Quadros (desenhos de criança) nas paredes: [frame do spr_quadros, x, y]
function tutorial_quadros_lista() {
    return [
        [0, 420, 45],
        [3, 680, 45],
        [2, 500, 555],
        [7, 880, 555],
        [1, 1140, 1040],
        [4, 1360, 1040],
        [5, 1960, 470],
        [6, 2080, 470],
        [3, 2300, 1040],
        [0, 2500, 1040],
        [6, 2700, 1040],
        [5, 2900, 1040]
    ];
}

/// Piso de cada cômodo: [frame base do spr_chao_bebe_2, x1, y1, x2, y2]
/// 0 taco | 2 tábua clara | 4 carpete azul | 6 carpete rosa | 8 cimento (o resto fica em taco)
function tutorial_pisos_lista() {
    return [
        [4, 320, 0, 1024, 540],
        [2, 1472, 448, 2176, 1024],
        [6, 2176, 1024, 3136, 1536],
        [6, 1472, 1024, 2176, 1536],
        [8, 704, 1536, 1408, 2048]
    ];
}
#endregion

#region ---------- DECORAÇÃO ----------

/// @desc Frame base do piso para uma posição (x, y) do tutorial
function tutorial_piso_frame(_x, _y) {
    var _p = tutorial_pisos_lista();
    for (var _i = 0; _i < array_length(_p); _i++) {
        var _r = _p[_i];
        if (_x >= _r[1] && _y >= _r[2] && _x < _r[3] && _y < _r[4]) return _r[0];
    }
    return 0;
}

/// @desc Coloca piso, tapetes, quadros e móveis na casa do tutorial (rodar uma vez)
function tutorial_decorar_casa() {
    if (!variable_global_exists("casa_catalogo")) casa_moveis_definir();
    var _esc = TUTO_ESCALA_MOVEIS;

    // 1. Piso diferente em cada cômodo (mantém a variação 0/1 sorteada pelo próprio piso)
    with (obj_chao_tijolo) image_index = tutorial_piso_frame(x, y) + (image_index mod 2);

    // 2. Tapetes (acima do piso, abaixo de tudo)
    var _tap = tutorial_tapetes_lista();
    for (var _i = 0; _i < array_length(_tap); _i++) {
        var _t = _tap[_i];
        var _ti = instance_create_depth(_t[1], _t[2], 950, obj_tapete_casa);
        _ti.image_index  = _t[0];
        _ti.image_xscale = _t[3];
        _ti.image_yscale = _t[3];
    }

    // 3. Quadros nas paredes (acima das camadas de tiles, atrás do jogador e dos móveis)
    var _q = tutorial_quadros_lista();
    for (var _k = 0; _k < array_length(_q); _k++) {
        var _qi = instance_create_depth(_q[_k][1], _q[_k][2], 290, obj_movel_casa);
        _qi.sprite_index = spr_quadros;
        _qi.image_index  = _q[_k][0];
        _qi.image_xscale = 1.5;
        _qi.image_yscale = 1.5;
        _qi.tipo = "quadro";
    }

    // 4. Parede com porta dupla no lugar da parede invisível que fecha a sala de brinquedos
    //    (a Fada destranca no passo 8; a colisão continua sendo global.id_parede_um até abrir)
    if (variable_global_exists("id_parede_um") && instance_exists(global.id_parede_um) && !instance_exists(obj_porta_tutorial)) {
        instance_create_depth(global.id_parede_um.x, global.id_parede_um.y, 790, obj_porta_tutorial);
    }

    // 5. Móveis (decoração com colisão no pé, igual às casas da fase bebê)
    var _m = tutorial_moveis_lista();
    for (var _j = 0; _j < array_length(_m); _j++) {
        var _d = _m[_j];
        var _cat = global.casa_catalogo[$ _d[0]];
        if (is_undefined(_cat)) continue;
        var _mi = instance_create_depth(_d[1], _d[2], -_d[2], obj_movel_casa);
        _mi.tipo = _d[0];
        _mi.sprite_index = _cat.spr;
        _mi.image_index  = casa_movel_frame(_cat.spr, _cat.abre, _d[3], false);
        _mi.image_xscale = _esc;
        _mi.image_yscale = _esc;
        if (_cat[$ "solido"] ?? true) tutorial_colisao_movel(_d[1], _d[2], _cat.w, _cat.h, _esc);
    }
}

/// @desc Caixa de colisão no pé do móvel (obj_parede_invi: o player do tutorial já colide com ela)
function tutorial_colisao_movel(_px, _py, _w, _h, _esc) {
    var _lw = _w * 64 * _esc - 8;
    var _lh = _h * 64 * _esc - 6;
    var _c = instance_create_layer(_px - _lw / 2, _py - _lh, "Instances_parede", obj_parede_invi);
    with (_c) {
        mask_index   = spr_parede_mascara;
        image_xscale = _lw / 64;
        image_yscale = _lh / 64;
        visible      = false;
    }
    return _c;
}

#endregion

#region ---------- PROGRESSO (poderes de verdade no tutorial) ----------

/// @desc Prepara XP, grade de poderes e passivas para o tutorial ensinar o level up de verdade
function tutorial_preparar_progresso() {
    inicializar_tudo();               // grids de poderes/passivas, mods e rerolls (poderes_lista)
    global.level_player = 1;
    global.xp = 0;
    global.max_xp = 100;
    global.levels_pendentes = 0;
    global.level_up = false;
    if (!variable_global_exists("upgrades_vamp_list")) global.upgrades_vamp_list = ds_list_create();
}

/// @desc Zera o que foi ganho no tutorial antes de ir para a aventura (chamado em "Sair_Tutorial")
function tutorial_resetar_progresso() {
    global.level_player = 1;
    global.xp = 0;
    global.max_xp = 100;
    global.levels_pendentes = 0;
    global.level_up = false;
    global.vida = global.vida_max;
    if (variable_global_exists("upgrades_vamp_list")) ds_list_clear(global.upgrades_vamp_list);
}

/// @desc Linha de um poder na upgrades_vamp_grid pelo nome (-1 se não existir)
function tutorial_linha_upgrade(_nome) {
    var _g = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) if (_g[# UPGRADES_VAMP.NAME, _i] == _nome) return _i;
    return -1;
}

/// @desc Cria uma amoeba de treino (mais vida e menos dano que a normal)
function tutorial_criar_amoeba(_x, _y) {
    var _a = instance_create_layer(_x, _y, "Instances_Enemys", obj_amoeba);
    _a.vida = 25;
    _a.dano = 4;
    return _a;
}

#endregion

#region ---------- PASSOS DO TUTORIAL (data-driven) ----------
// Cada passo: { objetivo: texto do HUD (função, pode ser dinâmico), iniciar(_c), concluido(_c) }
// _c = o obj_tutorial_controller. iniciar() roda uma vez; concluido() é checado com o jogo
// livre (sem diálogo aberto e sem tela de level up).

function tutorial_passos() {
    return [
        // 0. Andar
        { objetivo: function(_c) { return "Ande usando WASD ou as setas"; },
          iniciar: function(_c) { _c.start_x = obj_player.x; _c.start_y = obj_player.y; _c.falar("Tuto_Move"); },
          concluido: function(_c) { return point_distance(_c.start_x, _c.start_y, obj_player.x, obj_player.y) > 200; } },

        // 1. Correr (estamina)
        { objetivo: function(_c) { return "Segure SHIFT enquanto anda para correr"; },
          iniciar: function(_c) { _c.correr_frames = 0; _c.falar("Tuto_Run"); },
          concluido: function(_c) { return _c.correr_frames >= 40; } },

        // 2. Conversar com a Fada
        { objetivo: function(_c) { return "Chegue perto da Fada e aperte F para conversar"; },
          iniciar: function(_c) { _c.falar("Tuto_Interact"); },
          concluido: function(_c) { return instance_exists(obj_npc_fada) && obj_npc_fada.dig > 0; } },

        // 3. Dizer que está pronto (a cutscene da Fada solta a Amoeba)
        { objetivo: function(_c) { return "Fale com a Fada de novo (F) e diga que está pronto"; },
          iniciar: function(_c) { if (instance_exists(obj_npc_fada)) obj_npc_fada.dig = 2; _c.falar("Tuto_Pronto"); },
          concluido: function(_c) { return instance_exists(obj_amoeba); } },

        // 4. Combate corpo a corpo
        { objetivo: function(_c) { return "Derrote a Amoeba: clique com o botão ESQUERDO"; },
          iniciar: function(_c) { _c.falar("Tuto_Combat"); },
          concluido: function(_c) { return !instance_exists(obj_amoeba); } },

        // 5. Vitória
        { objetivo: function(_c) { return ""; },
          iniciar: function(_c) { _c.falar("Tuto_Combat_Win"); },
          concluido: function(_c) { return true; } },

        // 6. Dash
        { objetivo: function(_c) { return "Dê um Dash: botão DIREITO do mouse"; },
          iniciar: function(_c) { _c.fez_dash = false; _c.falar("Tuto_Dash"); },
          concluido: function(_c) { return _c.fez_dash; } },

        // 7. Trocar de arma
        { objetivo: function(_c) { return "Troque para o arco: gire a roda do mouse"; },
          iniciar: function(_c) { _c.falar("Tuto_Weapon"); },
          concluido: function(_c) { return global.armamento == ARMAMENTOS.ARCO; } },

        // 8. Cristais de XP -> level up de verdade (abre a passagem para a sala de brinquedos)
        { objetivo: function(_c) { return "Vá para a sala de brinquedos e pegue os cristais de XP"; },
          iniciar: function(_c) {
              // A porta dupla abre (animação) e só no fim libera a passagem (obj_porta_tutorial)
              if (instance_exists(obj_porta_tutorial)) {
                  with (obj_porta_tutorial) abrir();
              } else if (variable_global_exists("id_parede_um") && instance_exists(global.id_parede_um)) {
                  instance_destroy(global.id_parede_um);
              }
              for (var _i = 0; _i < 7; _i++) {
                  instance_create_layer(1620 + _i * 70, 1290 + ((_i mod 2) * 40), "Instances_Enemys", obj_xp_um);
              }
              _c.falar("Tuto_XP");
          },
          concluido: function(_c) { return global.level_player >= 2 && (slots_ativos_usados() + slots_passivos_usados()) > 0; } },

        // 9. Explica cartas, slots, reroll e pets (garante um poder ativo para o treino)
        { objetivo: function(_c) { return ""; },
          iniciar: function(_c) {
              if (slots_ativos_usados() == 0) {
                  var _row = tutorial_linha_upgrade("ESTILINGUE");
                  if (_row != -1) global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row] = 1;
                  mods_recalcular();
                  _c.falar("Tuto_Cartas_Presente");
              } else {
                  _c.falar("Tuto_Cartas");
              }
          },
          concluido: function(_c) { return true; } },

        // 10. Treino: poderes atacam sozinhos
        { objetivo: function(_c) { return "Sobreviva! Seus poderes atacam sozinhos (" + string(_c.amoebas_vivas()) + " restantes)"; },
          iniciar: function(_c) {
              _c.amoebas_treino = [];
              for (var _i = 0; _i < 6; _i++) {
                  var _ang = _i * 60 + 30;
                  var _ax = clamp(obj_player.x + lengthdir_x(380, _ang), 1560, 3060);
                  var _ay = clamp(obj_player.y + lengthdir_y(380, _ang), 1110, 1470);
                  array_push(_c.amoebas_treino, tutorial_criar_amoeba(_ax, _ay));
              }
              _c.falar("Tuto_Auto");
          },
          concluido: function(_c) { return _c.amoebas_vivas() == 0; } },

        // 11. Resumo do resto do jogo (a Fada vem até você)
        { objetivo: function(_c) { return ""; },
          iniciar: function(_c) {
              if (instance_exists(obj_npc_fada)) {
                  obj_npc_fada.x = obj_player.x + 120;
                  obj_npc_fada.y = obj_player.y - 40;
              }
              _c.falar("Tuto_Resumo");
          },
          concluido: function(_c) { return true; } },

        // 12. Fim: falar com a Fada para sair (diálogo "Tuto_End" -> "Sair_Tutorial")
        { objetivo: function(_c) { return "Fale com a Fada (F) para começar a aventura"; },
          iniciar: function(_c) { if (instance_exists(obj_npc_fada)) obj_npc_fada.dig = 4; },
          concluido: function(_c) { return false; } }
    ];
}

#endregion
