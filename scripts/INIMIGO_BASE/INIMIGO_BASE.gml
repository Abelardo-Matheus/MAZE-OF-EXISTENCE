/// @desc Funções de IA genérica para inimigos

function scr_inimigo_check_player(){
    if (instance_exists(obj_player)) {
        if (distance_to_object(obj_player) <= dist_aggro) {
            state = scr_inimigo_perseguir;
        }
    }
}

function scr_inimigo_hit(){
    alarm[2] = 180;
    empurrar_veloc = lerp(empurrar_veloc, 0, 0.05);
    hveloc = lengthdir_x(empurrar_veloc, empurrar_dir);
    vveloc = lengthdir_y(empurrar_veloc, empurrar_dir);
    
    aplicar_movimento_com_colisao(hveloc, vveloc);
}

function scr_inimigo_perseguir(){
    if (variable_instance_exists(id, "sprite_normal")) sprite_index = sprite_normal;
    image_speed = 1.5;
    
    if (instance_exists(obj_player)) {
        dest_x = obj_player.x;
        dest_y = obj_player.y;
        
        var _dir = point_direction(x, y, dest_x, dest_y);
        hveloc = lengthdir_x(veloc_perse, _dir);
        vveloc = lengthdir_y(veloc_perse, _dir);
        
        aplicar_movimento_com_colisao(hveloc, vveloc);
        
        if (distance_to_object(obj_player) >= dist_desaggro) {
            state = scr_inimigo_escolher_estado;
            alarm[0] = irandom_range(120, 240);
        }
    } else {
        state = scr_inimigo_escolher_estado;
    }
}

function scr_inimigo_escolher_estado(){
    scr_inimigo_check_player();
    var _prox_state = choose(scr_inimigo_andar, scr_inimigo_parado);
    
    if (_prox_state == scr_inimigo_andar) {
        state = scr_inimigo_andar;
        dest_x = x + irandom_range(-200, 200);
        dest_y = y + irandom_range(-200, 200);
    } else {
        state = scr_inimigo_parado;
    }
}

function scr_inimigo_andar(){
    scr_inimigo_check_player();
    if (variable_instance_exists(id, "sprite_normal")) sprite_index = sprite_normal;
    
    if (distance_to_point(dest_x, dest_y) > veloc) {
        var _dir = point_direction(x, y, dest_x, dest_y);
        hveloc = lengthdir_x(veloc, _dir);
        vveloc = lengthdir_y(veloc, _dir);
        aplicar_movimento_com_colisao(hveloc, vveloc);
    } else {
        state = scr_inimigo_escolher_estado;
        alarm[0] = irandom_range(60, 120);
    }
}

function scr_inimigo_parado(){
    scr_inimigo_check_player();
    if (variable_instance_exists(id, "sprite_parado")) sprite_index = sprite_parado;
    hveloc = 0;
    vveloc = 0;
}

// Funções de legado para compatibilidade
function scr_inimigo_colisao(){
    aplicar_movimento_com_colisao(hveloc, vveloc);
}
function scr_escolher_state_inimigo(){
    scr_inimigo_escolher_estado();
}
