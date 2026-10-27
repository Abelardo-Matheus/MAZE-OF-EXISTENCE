// feather disable GM2017
// ============================================================================
//  CASA PRINCIPAL, AVISO DA NOITE E CAMA — scr_sono
// ----------------------------------------------------------------------------
//  - Casa principal = a casa azul da quadra inicial, onde o jogador nasce
//    (scr_cidade -> cidade_gerar_quadra_inicial). Sempre a mesma em todo jogo.
//  - No entardecer aparece um aviso grande; no minimapa a casa fica grande e
//    pulsando e uma seta na tela aponta para ela.
//  - Cama: só a da casa principal. Dormir (entardecer ou noite) pula para a
//    manhã seguinte, enche vida/sanidade/estamina, conta como "noite" para as
//    missões e salva o jogo.
//  Ligações: obj_player Step -> if (sono_tick()) exit;   (antes das pausas)
//            obj_inventario Draw GUI -> sono_desenhar_gui();
//            obj_estrutura (ao entrar) -> sono_ao_entrar_casa(id);
//            mini_mapa_vamp -> sono_marcador_casa()
// ============================================================================

#macro SONO_ENTARDECER       0.72   // fração do dia em que já é "entardecer" (pode dormir / aviso)
#macro SONO_FADE             45     // frames escurecendo / clareando
#macro SONO_DORMINDO         100    // frames de tela preta com "Zzz"
#macro SONO_AVISO_SEG        7      // segundos do aviso grande
#macro SONO_RAIO_CASA        450    // px da porta da casa inicial para ela contar como principal

#region ---------- CASA PRINCIPAL ----------

/// Posição da porta da casa principal no mundo
function casa_principal_pos() {
    var _sx = cidade_spawn_x(), _sy = cidade_spawn_y();
    if (instance_exists(obj_casa_cidade)) {
        var _c = instance_nearest(_sx, _sy, obj_casa_cidade);
        if (_c != noone && point_distance(_c.x, _c.y, _sx, _sy) < SONO_RAIO_CASA) return [_c.x, _c.y];
    }
    return [_sx, _sy - 80];
}

function casa_e_principal(_inst) {
    return point_distance(_inst.x, _inst.y, cidade_spawn_x(), cidade_spawn_y()) < SONO_RAIO_CASA;
}

/// Chamado quando o jogador entra numa casa (obj_estrutura)
function sono_ao_entrar_casa(_inst) {
    global.na_casa_principal = casa_e_principal(_inst);
}

#endregion

#region ---------- HORA DO DIA ----------

/// "dia" | "entardecer" | "noite"
function sono_fase_do_dia() {
    if (!variable_global_exists("day_night_cycle")) return "dia";
    var _c = global.day_night_cycle;
    if (!_c.is_day) return "noite";
    if (variable_global_exists("first_dawn_passed") && global.first_dawn_passed && _c.current_cycle >= SONO_ENTARDECER) return "entardecer";
    return "dia";
}

function sono_perigo() { return sono_fase_do_dia() != "dia"; }

#endregion

#region ---------- DORMIR ----------

function sono_ativo() { return variable_global_exists("sono") && is_struct(global.sono) && global.sono.ativo; }

/// Ação da cama (scr_interacao)
function sono_tentar_dormir(_cama) {
    var _principal = (room == Fase_BEBE) && variable_global_exists("na_casa_principal") && global.na_casa_principal;
    if (!_principal) { inventory_msg("Essa cama não é sua. Durma na sua casa!", ui_cor("vermelho")); return; }
    if (!sono_perigo()) { inventory_msg("Ainda é cedo para dormir. Volte quando escurecer.", ui_cor("ouro")); return; }
    global.sono = { ativo: true, t: 0, aplicado: false };
}

/// Step do obj_player. Retorna true enquanto dorme (o player fica parado).
function sono_tick() {
    sono_aviso_tick();
    if (!sono_ativo()) return false;
    var _s = global.sono;
    _s.t++;
    if (!_s.aplicado && _s.t >= SONO_FADE) { _s.aplicado = true; sono_acordar_de_manha(); }
    if (_s.t >= SONO_FADE * 2 + SONO_DORMINDO) {
        _s.ativo = false;
        inventory_msg("Bom dia! Jogo salvo.", ui_cor("verde"));
    }
    image_speed = 0;
    return true;
}

/// Pula para a manhã seguinte e recupera tudo
function sono_acordar_de_manha() {
    if (variable_global_exists("day_night_cycle")) {
        var _c = global.day_night_cycle;
        var _full = _c.day_duration + _c.night_duration;
        global.timer = (floor(global.timer / _full) + 1) * _full + 1;
        _c.is_day = true;
        _c.current_cycle = 0;
        _c.current_light = _c.dawn_light;
    }
    global.first_dawn_passed = true;
    // a noite acabou dormindo: as rondas não contam de novo no amanhecer
    global.night_started = false;
    if (variable_global_exists("ronda_idx")) global.ronda_idx = -1;

    global.vida = global.vida_max;
    if (variable_global_exists("max_sanidade")) global.sanidade = global.max_sanidade;
    if (variable_global_exists("max_estamina")) global.estamina = global.max_estamina;

    missoes_evento("noite");   // dormir conta como passar a noite
    jogo_salvar();
}

#endregion

#region ---------- AVISO DA NOITE ----------

function sono_aviso_tick() {
    if (!variable_global_exists("sono_aviso")) global.sono_aviso = { t: 0, ciclo: -1 };
    if (global.sono_aviso.t > 0) global.sono_aviso.t -= 1 / game_get_speed(gamespeed_fps);
    if (!instance_exists(obj_otimizador) || !variable_global_exists("day_night_cycle")) return;   // só no mundo aberto
    if (!sono_perigo()) return;
    var _c = global.day_night_cycle;
    var _ciclo = floor(global.timer / (_c.day_duration + _c.night_duration));
    if (global.sono_aviso.ciclo == _ciclo) return;
    global.sono_aviso.ciclo = _ciclo;
    global.sono_aviso.t = SONO_AVISO_SEG;
}

/// Para o minimapa: { x, y, grande, texto }
function sono_marcador_casa() {
    var _p = casa_principal_pos();
    return { x: _p[0], y: _p[1], grande: sono_perigo(), texto: sono_perigo() ? "Sua casa: durma aqui à noite!" : "Sua casa" };
}

#endregion

#region ---------- GUI ----------

/// Draw GUI do obj_inventario (aviso, seta da casa e fade do sono)
function sono_desenhar_gui() {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k = max(1, _gh / 360);
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));

    // --- Seta para a casa (entardecer/noite, no mundo, casa fora da tela) ---
    if (instance_exists(obj_otimizador) && instance_exists(obj_player) && sono_perigo() && !sono_ativo()) sono_desenhar_seta_casa(_gw, _gh, _k, _fh);

    // --- Aviso grande ---
    if (variable_global_exists("sono_aviso") && global.sono_aviso.t > 0 && instance_exists(obj_otimizador)) {
        var _a = min(1, global.sono_aviso.t / 0.6, (SONO_AVISO_SEG - global.sono_aviso.t) / 0.4 + 0.01);
        var _w = min(_gw - 30 * _k, 330 * _k), _h = 46 * _k;
        var _x1 = (_gw - _w) / 2, _y1 = _gh * 0.2;
        draw_set_alpha(_a);
        ui_card(_x1, _y1, _x1 + _w, _y1 + _h, 8 * _k, make_color_rgb(44, 40, 72), ui_cor("borda"), max(2, round(2 * _k)));
        minimapa_icone("casa", _x1 + 22 * _k, _y1 + _h / 2 + 2 * _k, 11 * _k, _a);
        draw_set_alpha(_a);
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_x1 + 42 * _k, _y1 + 15 * _k, "Está escurecendo!", ui_cor("ouro"), (11 * _k) / _fh, ui_cor("escuro"));
        ui_text_fit(_x1 + 42 * _k, _y1 + 32 * _k, "À noite é perigoso. Volte para casa e durma.", c_white, (8 * _k) / _fh, _w - 50 * _k);
        draw_set_alpha(1);
    }

    // --- Dormindo: escurece, "Zzz", clareia ---
    if (sono_ativo()) {
        var _t = global.sono.t, _a = 1;
        if (_t < SONO_FADE) _a = _t / SONO_FADE;
        else if (_t > SONO_FADE + SONO_DORMINDO) _a = 1 - (_t - SONO_FADE - SONO_DORMINDO) / SONO_FADE;
        draw_set_alpha(clamp(_a, 0, 1));
        draw_set_color(c_black);
        draw_rectangle(0, 0, _gw, _gh, false);
        if (_t >= SONO_FADE * 0.6 && _t <= SONO_FADE + SONO_DORMINDO) {
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            var _z = "Z" + string_repeat(" z", 1 + (floor(_t / 20) mod 3));
            ui_text(_gw / 2, _gh / 2 - 10 * _k + sin(_t / 12) * 3 * _k, _z, make_color_rgb(170, 200, 255), (18 * _k) / _fh, c_black);
            ui_text(_gw / 2, _gh / 2 + 16 * _k, "Dormindo...", c_white, (8 * _k) / _fh, c_black);
        }
        draw_set_alpha(1);
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function sono_desenhar_seta_casa(_gw, _gh, _k, _fh) {
    var _c = casa_principal_pos();
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
    if (point_in_rectangle(_c[0], _c[1] - 60, _vx, _vy, _vx + _vw, _vy + _vh)) return;

    var _cx = _gw / 2, _cy = _gh / 2;
    var _dx = (_c[0] - _vx) / _vw * _gw - _cx;
    var _dy = (_c[1] - 60 - _vy) / _vh * _gh - _cy;
    var _mg = 30 * _k;
    var _s = min((_gw / 2 - _mg) / max(0.001, abs(_dx)), (_gh / 2 - _mg) / max(0.001, abs(_dy)));
    var _px = _cx + _dx * _s, _py = _cy + _dy * _s;
    var _ang = point_direction(0, 0, _dx, _dy);
    var _r = 12 * _k * (1 + dsin(current_time * 0.35) * 0.08);

    var _ax = _px + lengthdir_x(_r * 1.8, _ang), _ay = _py + lengthdir_y(_r * 1.8, _ang);
    var _bx = _px + lengthdir_x(_r * 0.9, _ang + 90), _by = _py + lengthdir_y(_r * 0.9, _ang + 90);
    var _ex = _px + lengthdir_x(_r * 0.9, _ang - 90), _ey = _py + lengthdir_y(_r * 0.9, _ang - 90);
    draw_set_color(ui_cor("escuro"));
    draw_triangle(_ax, _ay, _bx, _by, _ex, _ey, false);
    draw_circle(_px, _py, _r + 2 * _k, false);
    draw_set_color(make_color_rgb(110, 150, 230));
    draw_circle(_px, _py, _r, false);
    minimapa_icone("casa", _px, _py + 1 * _k, _r * 0.62);

    var _pl = obj_player;
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    var _txt = string(floor(point_distance(_pl.x, _pl.y, _c[0], _c[1]) / 32)) + "m";
    ui_text(_px - lengthdir_x(_r * 2.2, _ang), _py - lengthdir_y(_r * 2.2, _ang), _txt, c_white, (7 * _k) / _fh, ui_cor("escuro"));
}

#endregion
