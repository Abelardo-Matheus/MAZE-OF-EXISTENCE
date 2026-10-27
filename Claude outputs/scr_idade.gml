// feather disable GM2017
// ============================================================================
//  IDADE DO PERSONAGEM — scr_idade
// ----------------------------------------------------------------------------
//  O personagem cresce com os DIAS sobrevividos (cada amanhecer ou noite dormida).
//  Fases: criança -> adolescente -> adulto -> idoso (tabela idade_fases()).
//  Cada fase muda:
//   - o SPRITE do player (spr_idade): spr_player_baixo -> spr_player_baixo_adolescente ...
//     Se o sprite da fase não existir, usa o de criança (dá para ir entregando a arte aos poucos).
//   - bônus leves de atributos (somados em equip_calcular_bonus -> idade_somar_bonus)
//   - aviso grande "Você cresceu!" com uma fala da história.
//  O dia vem do relógio do jogo (global.timer), que o save já guarda: nada extra no save.
//
//  COMO MUDAR
//   - Dias de cada fase e bônus: idade_fases().
//   - Sprite de outra coisa por idade: crie spr_<nome>_<sufixo> e use spr_idade(spr_<nome>).
//   - Teste rápido: global.idade_forcar = 0..3 (-1 = normal).
// ============================================================================

#macro IDADE_AVISO_SEG 6

function idade_fases() {
    static _f = [
        { id: "crianca",     nome: "Criança",     dia: 1,  sufixo: "",
          bonus: { xp_item: 10 },
          fala: "" },
        { id: "adolescente", nome: "Adolescente", dia: 7,  sufixo: "adolescente",
          bonus: { vel: 1, esquiva: 5 },
          fala: "As roupas ficaram pequenas. O Labirinto parece menor... ou será você que cresceu?" },
        { id: "adulto",      nome: "Adulto",      dia: 15, sufixo: "adulto",
          bonus: { dano_pct: 15, defesa: 2, vida: 20 },
          fala: "Agora você carrega o peso das escolhas. Os medos também cresceram." },
        { id: "idoso",       nome: "Idoso",       dia: 30, sufixo: "idoso",
          bonus: { xp_item: 25, sanidade_regen: 0.5, vel: -1 },
          fala: "Os passos ficaram lentos, mas cada lembrança vale mais do que nunca." },
    ];
    return _f;
}

/// Dia atual (1, 2, 3...) a partir do relógio do jogo
function idade_dia() {
    if (!variable_global_exists("day_night_cycle") || !variable_global_exists("timer")) return 1;
    var _c = global.day_night_cycle;
    return floor(global.timer / max(1, _c.day_duration + _c.night_duration)) + 1;
}

/// Índice da fase atual (0 = criança)
function idade_indice() {
    if (variable_global_exists("idade_forcar") && global.idade_forcar >= 0) return clamp(global.idade_forcar, 0, array_length(idade_fases()) - 1);
    var _f = idade_fases(), _d = idade_dia(), _i = 0;
    for (var _k = 0; _k < array_length(_f); _k++) if (_d >= _f[_k].dia) _i = _k;
    return _i;
}

function idade_atual() { return idade_fases()[idade_indice()]; }

/// Sprite da idade atual para _spr (ex.: spr_player_baixo -> spr_player_baixo_adulto). Sem arte = o próprio _spr.
function spr_idade(_spr) {
    if (!sprite_exists(_spr)) return _spr;
    var _i = idade_indice();
    if (_i == 0) return _spr;
    if (!variable_global_exists("idade_cache")) global.idade_cache = {};
    var _chave = string(_spr) + "_" + string(_i);
    var _r = global.idade_cache[$ _chave];
    if (is_undefined(_r)) {
        _r = _spr;
        // procura da fase atual para trás (idoso sem arte usa a de adulto, etc.)
        for (var _k = _i; _k >= 1; _k--) {
            var _a = asset_get_index(sprite_get_name(_spr) + "_" + idade_fases()[_k].sufixo);
            if (_a != -1 && sprite_exists(_a)) { _r = _a; break; }
        }
        global.idade_cache[$ _chave] = _r;
    }
    return _r;
}

/// Soma os bônus da idade nos atributos (chamado no fim de equip_calcular_bonus)
function idade_somar_bonus(_e) {
    var _b = idade_atual().bonus;
    var _n = variable_struct_get_names(_b);
    for (var _k = 0; _k < array_length(_n); _k++) _equip_somar(_e, _n[_k], _b[$ _n[_k]]);
}

/// Step do obj_player: percebe a mudança de fase
function idade_tick() {
    if (!variable_global_exists("idade_aviso")) global.idade_aviso = { t: 0, idx: -1 };
    if (global.idade_aviso.t > 0) global.idade_aviso.t -= 1 / game_get_speed(gamespeed_fps);
    var _i = idade_indice();
    if (!variable_global_exists("idade_idx_ant")) { global.idade_idx_ant = _i; return; }
    if (_i == global.idade_idx_ant) return;
    var _cresceu = _i > global.idade_idx_ant;
    global.idade_idx_ant = _i;
    global.idade_cache = {};             // sprites da nova fase
    player_stats_recalcular();           // bônus da nova fase
    if (_cresceu) { global.idade_aviso.t = IDADE_AVISO_SEG; global.idade_aviso.idx = _i; }
}

/// Sincroniza sem aviso (ao carregar o save / começar jogo novo)
function idade_sincronizar() {
    global.idade_idx_ant = idade_indice();
    global.idade_cache = {};
    if (variable_global_exists("idade_aviso")) global.idade_aviso.t = 0;
}

/// Draw do obj_player: desenha o sprite da idade no lugar do sprite_index (máscara e animação continuam as da criança)
function idade_draw_player(_cor, _alfa) {
    var _s = spr_idade(sprite_index);
    var _aj = sprite_ajuste(sprite_index);
    var _n = max(1, sprite_get_number(_s));
    var _img = (_s == sprite_index) ? image_index : (floor(image_index) mod _n);
    draw_sprite_ext(_s, _img, x, y, image_xscale * _aj, image_yscale * _aj, image_angle, _cor, _alfa);
}

/// Aviso "Você cresceu!" (Draw GUI do obj_inventario)
function idade_desenhar_gui() {
    if (!variable_global_exists("idade_aviso") || global.idade_aviso.t <= 0) return;
    var _f = idade_fases()[clamp(global.idade_aviso.idx, 0, array_length(idade_fases()) - 1)];
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k = max(1, _gh / 360);
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    var _w = min(_gw - 30 * _k, 340 * _k), _h = 58 * _k;
    var _x1 = (_gw - _w) / 2, _y1 = _gh * 0.32;
    ui_card(_x1, _y1, _x1 + _w, _y1 + _h, 9 * _k, make_color_rgb(250, 238, 214), ui_cor("ouro"), max(2, round(2.5 * _k)));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text(_x1 + _w / 2, _y1 + 15 * _k, "Você cresceu!", ui_cor("ouro"), (13 * _k) / _fh, ui_cor("escuro"));
    ui_text(_x1 + _w / 2, _y1 + 30 * _k, "Agora você é " + string_lower(_f.nome) + "  (dia " + string(idade_dia()) + ")", c_white, (8.5 * _k) / _fh, ui_cor("escuro"));
    if (_f.fala != "") ui_text_fit(_x1 + _w / 2, _y1 + 45 * _k, _f.fala, ui_cor("texto"), (7 * _k) / _fh, _w - 20 * _k);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}

/// Texto curto para HUD/tooltip: "Adolescente · dia 9"
function idade_texto() { return idade_atual().nome + " - dia " + string(idade_dia()); }
