// Verifica se a viewport 0 está ativa
if (view_enabled[0]) {
    // Viewport 0 está ativa, usa as configurações da câmera
    var _cl = camera_get_view_width(view_camera[0]);
    var _ca = camera_get_view_height(view_camera[0]);

    escalax = display_get_gui_width() / _cl;
    escalay = display_get_gui_height() / _ca;

    var _cx = camera_get_view_x(view_camera[0]);
    var _cy = camera_get_view_y(view_camera[0]);

    var _x = (xx - _cx) * escalax;
    var _y = (yy - _cy) * escalay;
} else {
    // Viewport 0 está desligada, usa o tamanho da tela total
    var _cl = display_get_width();
    var _ca = display_get_height();

    escalax = display_get_gui_width() / _cl;
    escalay = display_get_gui_height() / _ca;

    var _x = xx * escalax;
    var _y = yy * escalay;
}

// Continua com o desenho
draw_set_font(fonte);

draw_set_alpha(alpha);
draw_set_color(cor);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_colour_outline(_x, _y, string(round(dano)), 4, c_black, 8, 100, 100);
draw_set_alpha(1);
draw_set_color(c_white);
