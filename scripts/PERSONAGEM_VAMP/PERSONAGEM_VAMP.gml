

function scr_andando_vamp() {
    // A movimentação do Vampiro é similar à do Personagem normal, 
    // mas com modificadores específicos de velocidade e sem custo de estamina ao correr (conforme original).

    var _in = obter_inputs_jogador();

    var _h_input = _in.direita - _in.esquerda;
    var _v_input = _in.baixo - _in.cima;
    var _speed   = global.speed_player;

    if (_in.shift && (_h_input != 0 || _v_input != 0)) {
        _speed += 90; // Velocidade extrema do Vampiro conforme o código original
    }

    if (_h_input != 0 || _v_input != 0) {
        var _dir_input = point_direction(0, 0, _h_input, _v_input);
        hveloc = lengthdir_x(_speed, _dir_input);
        vveloc = lengthdir_y(_speed, _dir_input);

        if (_h_input > 0) { dir = 0; sprite_index = spr_player_direita; }
        else if (_h_input < 0) { dir = 2; sprite_index = spr_player_esquerda; }
        else if (_v_input > 0) { dir = 3; sprite_index = spr_player_baixo; }
        else if (_v_input < 0) { dir = 1; sprite_index = spr_player_cima; }
    } else {
        hveloc = 0;
        vveloc = 0;

        switch (dir) {
            case 0: sprite_index = spr_player_direita_parado; break;
            case 1: sprite_index = spr_player_cima_parado; break;
            case 2: sprite_index = spr_player_esquerda_parado; break;
            case 3: sprite_index = spr_player_baixo_parado; break;
        }
    }

    scr_player_colisao_vamp();

    // Atualiza direção para ataques
    var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
    dir = round(_dir_mouse / 90) % 4;
}

function scr_player_colisao_vamp() {
    aplicar_movimento_com_colisao(hveloc, vveloc);
}

function scr_personagem_dash_vamp() {
    global.estamina -= 3;
    andar = true;
    alarm[0] = 50;
    tomar_dano = false;

    hveloc = lengthdir_x(dash_veloc, dash_dir);
    vveloc = lengthdir_y(dash_veloc, dash_dir);

    scr_player_colisao_vamp();

    var _inst = instance_create_layer(x, y, "instances", obj_rastro_player);
    _inst.sprite_index = sprite_index;
}

function scr_personagem_hit_vamp() {
    if (alarm[2] > 0) {
        hveloc = lengthdir_x(8, empurrar_dir);
        vveloc = lengthdir_y(8, empurrar_dir);
        scr_player_colisao_vamp();
    } else {
        state = scr_andando_vamp;
        hit = false;
    }
}