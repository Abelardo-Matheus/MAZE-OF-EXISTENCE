// feather disable GM2017
/// @desc Sprite do baú no mundo + destaque e tecla E quando o player está perto.
/// A UI de guardar/retirar itens é desenhada no Draw GUI do obj_inventario (bau_ui_desenhar).

// sombra no chão
var _w = sprite_get_width(sprite_index) * image_xscale;
draw_set_alpha(0.25); draw_set_color(c_black);
draw_ellipse(x - _w * 0.45, y - 5, x + _w * 0.45, y + 4, false);
draw_set_alpha(1); draw_set_color(c_white);

draw_self();

if (perto && !aberto) {
    // brilho leve por cima do sprite
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 0.12 + 0.08 * sin(current_time / 180));
    gpu_set_blendmode(bm_normal);
    // tecla E (spr_botoes: frame 0 = E, 1 = F)
    draw_sprite_ext(spr_botoes, 0, x, bbox_top - 14, 0.6, 0.6, 0, c_white, 0.75 + 0.25 * sin(current_time / 150));
}
