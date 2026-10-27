// feather disable GM2017
// ============================================================================
//  INTERAÇÃO — scr_interacao
// ----------------------------------------------------------------------------
//  Um único "árbitro" decide com o que o jogador interage. Só o alvo mais
//  próximo (com prioridade) recebe a tecla Interagir. Acima da cabeça aparece
//  "[F] Falar com Tio Beto", "[F] Entrar", "[F] Dormir"...
//
//  Fluxo:
//   - obj_player Step chama interacao_tick() (só quando o jogo não está pausado).
//   - interacao_tick percorre global.interacoes, acha o melhor alvo, guarda em
//     global.interacao_alvo e, se apertou Interagir, chama a ação dele.
//   - Ações "pedido": marcam o alvo (interacao_marcar) e o próprio objeto executa
//     o código dele no Step com  if (interacao_pedida()) { ... }.
//
//  COMO ADICIONAR ALGO INTERATIVO
//    Uma linha em interacao_definir():
//      _i(obj, prioridade, "Texto", perto(inst, player) -> bool, acao(inst), pode(inst) opcional)
//    texto pode ter {nome} (variável nome da instância).
// ============================================================================

#macro INTER_PRIORIDADE_PESO   24     // px de "vantagem" por ponto de prioridade
#macro INTER_JANELA_MS         150    // tempo que um pedido fica valendo (interacao_pedida)

/// distance_to_object de _a até _b (borda a borda)
function interacao_dist_obj(_a, _b) { var _d = infinity; with (_a) _d = distance_to_object(_b); return _d; }

/// Distância do pé do player até um ponto
function interacao_dist_pe(_p, _x, _y) { return point_distance(_p.x, _p.bbox_bottom, _x, _y); }

function interacao_definir() {
    global.interacoes = [];
    var _i = function(_obj, _prio, _txt, _perto, _acao, _pode = undefined) {
        if (!object_exists(_obj)) return;
        array_push(global.interacoes, { obj: _obj, prio: _prio, txt: _txt, perto: _perto, acao: _acao, pode: _pode });
    };

    // --- NPC de missão (scr_missoes) ---
    _i(obj_npc_missao, 10, "Falar com {nome}",
        function(_n, _p) { return !_n.saindo && point_distance(_n.x, _n.y, _p.x, _p.y) < MISSAO_DIST_FALAR; },
        interacao_marcar,
        function(_n) { return !missoes_dialogo_aberto() && global.missoes_dlg.espera <= 0; });

    // --- Itens no chão ---
    _i(obj_item, 8, "Pegar {nome}",
        function(_it, _p) { return interacao_dist_obj(_p, _it) <= 26; },
        interacao_pegar_item);

    // --- Vendedor ---
    _i(obj_par_npc_vendedor_um, 7, "Loja",
        function(_v, _p) { return point_distance(_v.x, _v.y, _p.x, _p.y) < min(140, _v.distancia_interacao); },
        interacao_marcar);

    // --- Baú do jogador ---
    _i(obj_bau_jogador, 6, "Abrir baú",
        function(_b, _p) { return interacao_dist_obj(_p, _b) <= BAU_DIST_ABRIR; },
        interacao_marcar,
        function(_b) { return !_b.aberto && !instance_exists(global.bau_aberto); });

    // --- Cama (móvel da casa) ---
    _i(obj_movel_casa, 6, "Dormir",
        function(_m, _p) { return _m.tipo == "cama" && casa_movel_perto(_m, _p, 44); },
        sono_tentar_dormir);

    // --- Móveis que abrem (armário, geladeira...) ---
    _i(obj_movel_abre, 5, "Abrir",
        function(_m, _p) { return !_m.aberto && casa_movel_perto(_m, _p); },
        casa_movel_abrir);

    // --- Escada do porão ---
    _i(obj_escada_porao, 5, "Usar escada",
        function(_e, _p) { return escada_porao_perto(_e, _p); },
        escada_porao_usar);

    // --- Móveis antigos das fases (geladeira, guarda-roupa, escrivaninha) ---
    _i(obj_geladeira,    4, "Abrir", function(_m, _p) { return !_m.aberto && point_distance(_m.x, _m.y, _p.x, _p.y) <= 100; }, interacao_marcar);
    _i(obj_guarda_roupa, 4, "Abrir", function(_m, _p) { return !_m.aberto && point_distance(_m.x, _m.y, _p.x, _p.y) <= 100; }, interacao_marcar);
    _i(obj_mesa_1,       4, "Abrir", function(_m, _p) { return !_m.aberto && point_distance(_m.x, _m.y, _p.x, _p.y) <= 100; }, interacao_marcar);

    // --- Vela ---
    _i(obj_vela, 4, "Pegar vela",
        function(_v, _p) { return interacao_dist_obj(_p, _v) <= 6; },   // encostado (o código roda na colisão)
        interacao_marcar);

    // --- Altar do chefe ---
    _i(obj_secondary_boss, 3, "Invocar o chefe",
        function(_a, _p) { return !_a.boss_invocado && point_distance(_a.x, _a.y, _p.x, _p.y) <= _a.distancia_interacao; },
        interacao_marcar);

    // --- Porta das casas (por último: só ganha se não tiver nada mais perto) ---
    _i(obj_estrutura, 0, "Entrar",
        function(_c, _p) { return _c.visible && interacao_dist_pe(_p, _c.x, _c.y) <= 110 && _p.bbox_bottom >= _c.y - 30; },
        interacao_marcar);
}

/// Ação padrão: avisa o objeto (ele executa o próprio código com interacao_pedida)
function interacao_marcar(_inst) { _inst.interagir_ate = current_time + INTER_JANELA_MS; }

/// No Step do objeto: true uma vez quando o jogador escolheu interagir com ELE
function interacao_pedida() {
    if (!variable_instance_exists(id, "interagir_ate") || interagir_ate < current_time) return false;
    interagir_ate = 0;
    return true;
}

function interacao_pegar_item(_it) {
    if (inventory_pegar_instancia(_it)) {
        coletar_item(_it.pos_x, _it.pos_y, global.current_sala);
        instance_destroy(_it);
    }
}

/// Texto do alvo (troca {nome})
function interacao_texto(_e, _inst) {
    var _t = _e.txt;
    if (string_pos("{nome}", _t) > 0) {
        var _n = "";
        if (_e.obj == obj_item && variable_instance_exists(_inst, "item_id")) {
            var _d = item_db(_inst.item_id);
            _n = is_undefined(_d) ? "item" : _d.nome;
        } else if (variable_instance_exists(_inst, "nome") && is_string(_inst.nome)) _n = _inst.nome;
        _t = string_trim(string_replace_all(_t, "{nome}", _n));
    }
    return _t;
}

/// Escolhe o melhor alvo deste frame e executa a ação se apertou Interagir (Step do obj_player)
function interacao_tick() {
    if (!variable_global_exists("interacoes")) interacao_definir();
    global.interacao_alvo = noone;
    global.interacao_txt  = "";
    desenha_botao = false;

    if (instance_exists(obj_inventario) && obj_inventario.is_open) return;
    if (variable_global_exists("level_up") && global.level_up) return;
    if (missoes_dialogo_aberto() || sono_ativo()) return;
    if (variable_global_exists("dialogo") && global.dialogo) return;

    var _p = id;
    var _melhor = noone, _melhor_e = undefined, _melhor_s = infinity;
    var _n = array_length(global.interacoes);
    for (var _k = 0; _k < _n; _k++) {
        var _e = global.interacoes[_k];
        // testa as 3 instâncias mais próximas desse tipo (ex.: várias camas/itens juntos)
        var _lista = ds_list_create();
        var _q = collision_circle_list(x, bbox_bottom, 220, _e.obj, false, true, _lista, true);
        for (var _j = 0; _j < min(_q, 3); _j++) {
            var _inst = _lista[| _j];
            if (!_e.perto(_inst, _p)) continue;
            if (!is_undefined(_e.pode) && !_e.pode(_inst)) continue;
            var _s = interacao_dist_pe(_p, _inst.x, _inst.y) - _e.prio * INTER_PRIORIDADE_PESO;
            if (_s < _melhor_s) { _melhor_s = _s; _melhor = _inst; _melhor_e = _e; }
        }
        ds_list_destroy(_lista);
    }
    if (_melhor == noone) return;

    global.interacao_alvo = _melhor;
    global.interacao_txt  = interacao_texto(_melhor_e, _melhor);
    desenha_botao = true;

    if (tecla_apertou("interagir")) {
        _melhor_e.acao(_melhor);
        global.interacao_alvo = noone;
        desenha_botao = false;
    }
}

/// Prompt acima da cabeça do player (Draw End do obj_player)
function interacao_desenhar_prompt() {
    if (!variable_global_exists("interacao_alvo") || !instance_exists(global.interacao_alvo) || global.interacao_txt == "") return false;
    var _t = "[" + tecla_nome(tecla("interagir")) + "] " + global.interacao_txt;
    draw_set_font(fnt_dialogos);
    var _esc = 0.3;
    var _w = string_width(_t) * _esc / 2 + 7, _h = string_height("Ag") * _esc / 2 + 4;
    var _cy = y - 74 + sin(current_time / 250) * 1.5;
    draw_set_alpha(0.85);
    draw_set_color(make_color_rgb(52, 32, 26));
    draw_roundrect_ext(x - _w, _cy - _h, x + _w, _cy + _h, 9, 9, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 200, 58));
    draw_roundrect_ext(x - _w, _cy - _h, x + _w, _cy + _h, 9, 9, true);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(255, 250, 238));
    draw_text_transformed(x, _cy, _t, _esc, _esc, 0);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white);
    return true;
}
