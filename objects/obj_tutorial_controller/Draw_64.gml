/// @desc Desenha o Objetivo Atual na Tela
draw_set_font(fnt_dialogos);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

var _txt = "";
switch (tutorial_step) {
    case 0: _txt = "OBJETIVO: Mova-se usando WASD ou Setas"; break;
    case 1: _txt = "OBJETIVO: Fale com a Fada (Pressione 'F')"; break;
    case 2: 
        if (amoeba_spawned && !instance_exists(obj_dialogo)) {
            _txt = "OBJETIVO: Derrote a Amoeba (Botão Esquerdo)"; 
        }
        break;
    case 3: _txt = "OBJETIVO: Use o Dash (Botão Direito)"; break;
    case 4: _txt = "OBJETIVO: Troque de arma (Roda do Mouse)"; break;
    case 5: _txt = "OBJETIVO: Entre no portal para começar"; break;
}

// Desenha fundo simples para o texto
var _w = string_width(_txt) + 20;
var _h = string_height(_txt) + 10;
var _xx = display_get_gui_width() / 2;
var _yy = 50;

draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(_xx - _w/2, _yy, _xx + _w/2, _yy + _h, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_text(_xx, _yy + 5, _txt);

// RESET PARA NÃO AFETAR OUTROS OBJETOS (BOA PRÁTICA)
draw_set_halign(fa_left);
draw_set_valign(fa_top);
