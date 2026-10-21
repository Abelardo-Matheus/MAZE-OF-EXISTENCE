// feather disable GM2017
/// @desc Abre/fecha (E) e recolhe se vazio (F) quando o player está perto.
/// A UI do baú é desenhada em obj_inventario/Draw_64.gml (GUI), guiada por global.bau_aberto.
image_index = aberto ? 1 : 0;
depth = profundidade_pe(bbox_bottom);

if (instance_exists(obj_player) && distance_to_object(obj_player) <= 40 && !global.colocando_bau.ativo) {
    if (keyboard_check_pressed(ord("E"))) {
        aberto = !aberto;
        global.bau_aberto = aberto ? id : noone;
    }
    if (!aberto && keyboard_check_pressed(ord("F"))) {
        bau_recolher(id);
    }
} else if (aberto) {
    aberto = false; // fecha automaticamente se o player se afastar
    if (global.bau_aberto == id) global.bau_aberto = noone;
}
