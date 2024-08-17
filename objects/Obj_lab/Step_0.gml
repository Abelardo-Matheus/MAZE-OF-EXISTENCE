show_debug_message(global.dificuldade);
if(global.dificuldade == 20 || global.dificuldade == 10){
var extra_space =  global.cell_size; // Dois blocos extras em cada direção

// Defina a posição da viewport para seguir o jogador, com extra_space em todas as direções
view_xview[0] = clamp(obj_player.x - view_wview[0] / 2 - extra_space, 0, room_width - view_wview[0] - extra_space * 2);
view_yview[0] = clamp(obj_player.y - view_hview[0] / 2 - extra_space, 0, room_height - view_hview[0] - extra_space * 2);

// Obter as coordenadas e dimensões da viewport 0
var view_x = view_xview[0] - extra_space;
var view_y = view_yview[0] - extra_space;
var view_w = view_wview[0] + extra_space * 3;
var view_h = view_hview[0] + extra_space * 2;

// Loop através de todas as instâncias do jogo
with (all) {
    // Verificar se a instância está dentro da viewport expandida
    if (bbox_right > view_x && bbox_left < view_x + view_w &&
        bbox_bottom > view_y && bbox_top < view_y + view_h) {
        visible = true;  // Tornar a instância visível
    } else {
        visible = false; // Tornar a instância invisível
    }
}
}

if (keyboard_check_pressed(ord("R"))) {
    game_restart();
}
