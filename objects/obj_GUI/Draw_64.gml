// feather disable GM2017
relogio();
// ============================================================
// PARTE 1: TELA DE LEVEL UP (Misto: Armas e Itens)
// ============================================================
if (global.level_up == true) 
{
    gui_desenhar_level_up(); // LEVEL_UP.gml (o tutorial usa a mesma tela)
    exit; // Sai para não desenhar o resto da GUI normal
}

// ============================================================
// PARTE 2: HUD DE JOGO (Timer e Status)
// ============================================================

// --- Relógio / Timer ---
global.minutes = floor(global.timer / 60);
global.seconds = floor(global.timer) mod 60;

// Formatação com zero à esquerda (Pad)
var _str_min = (global.minutes < 10) ? "0" + string(global.minutes) : string(global.minutes);
var _str_sec = (global.seconds < 10) ? "0" + string(global.seconds) : string(global.seconds);
var _time_text = _str_min + ":" + _str_sec;

// Desenha Timer
draw_set_font(fnt_nomes_itens);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text_colour_outline_escalado(display_get_gui_width() / 2, 10, _time_text, 3, c_black, 7, 30, 300, 1, 1);

// --- Elementos do HUD ---
desenha_barra_vida();
desenha_vento_hud(); // força do vento 0..100 (VIDA.gml)

// Minimapa Contextual
if (global.map_bebe) 
{
    mini_mapa_bebe();
} 
else if (global.map_vamp) 
{
    mini_mapa_vamp();
}

draw_fps();