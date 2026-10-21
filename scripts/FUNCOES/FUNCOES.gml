// feather disable GM2017
function fim_animation(){
	var _sprite = sprite_index;
	var _image = image_index;
	if(argument_count > 0) _sprite = argument[0];
	if(argument_count > 1) _image = argument[1];
	var _type = sprite_get_speed_type(sprite_index);
	var _spd = sprite_get_speed(sprite_index)*image_speed;
	if(_type == spritespeed_framespersecond)
	    _spd = _spd / game_get_speed(gamespeed_fps);
	if(argument_count > 2) _spd = argument[2];
	return _image + _spd >= sprite_get_number(_sprite);
}

/// @desc Captura os inputs do jogador de forma padronizada
function obter_inputs_jogador() {
    return {
        esquerda: keyboard_check(ord("A")) || keyboard_check(vk_left),
        direita:  keyboard_check(ord("D")) || keyboard_check(vk_right),
        cima:     keyboard_check(ord("W")) || keyboard_check(vk_up),
        baixo:    keyboard_check(ord("S")) || keyboard_check(vk_down),
        shift:    keyboard_check(vk_shift),
        mouse_esq_press: mouse_check_button_pressed(mb_left),
        mouse_esq_rel:   mouse_check_button_released(mb_left),
        mouse_dir_press: mouse_check_button_pressed(mb_right),
        interagir: keyboard_check_pressed(ord("F"))
    };
}

/// @desc Executa movimentação com colisão pixel-perfect
/// @param _hveloc Velocidade horizontal desejada
/// @param _vveloc Velocidade vertical desejada
/// @param _col_obj Objeto ou instância de colisão (padrão: global.sala.parede)
function aplicar_movimento_com_colisao(_hveloc, _vveloc, _col_obj = undefined) {
    var _obj = _col_obj;
    
    // Se nenhum objeto foi passado, tenta pegar a parede da sala atual ou o padrão
    if (_obj == undefined) {
        if (variable_global_exists("sala") && variable_struct_exists(global.sala, "parede")) {
            _obj = global.sala.parede;
        } else {
            _obj = obj_wall;
        }
    }

    // Colisão Horizontal
    if (place_meeting(x + _hveloc, y, _obj)) {
        while (!place_meeting(x + sign(_hveloc), y, _obj)) {
            x += sign(_hveloc);
        }
        _hveloc = 0;
    }
    x += _hveloc;

    // Colisão Vertical
    if (place_meeting(x, y + _vveloc, _obj)) {
        while (!place_meeting(x, y + sign(_vveloc), _obj)) {
            y += sign(_vveloc);
        }
        _vveloc = 0;
    }
    y += _vveloc;
}

// ============================================================================
// AJUSTE DE ESCALA DOS SPRITES REFEITOS (pixel art 64x64)
// ============================================================================
/// @desc Fator que mantém o tamanho no mundo dos sprites refeitos em quadro 64x64.
///       Multiplique a escala que o objeto já usava por este valor. Sprites não refeitos devolvem 1.
/// @param {Asset.GMSprite} _spr
function sprite_ajuste(_spr) {
    switch (_spr) {
        case spr_player_baixo_parado_atacando: return 1.26562;
        case spr_player_cima_parado_atacando: return 1.26562;
        case spr_player_direita_parado_atacando: return 1.26562;
        case spr_player_esquerda_parado_atacando: return 1.26562;
        case spr_bola: return 2.8125;
        case spr_shuriken: return 1.35938;
        case spr_bulmerangue: return 2.09375;
        case spr_confete: return 3.4375;
        case spr_bomba_vamp: return 1.25;
        case spr_explosion: return 1.60938;
        case spr_raio: return 3.29687;
        case spr_borboleta_idle: return 0.98438;
        case spr_sapo_idle: return 1.65625;
        case spr_sapo_walk: return 1.65625;
        case spr_sapo_attack: return 1.65625;
        case spr_sapo_teleporte: return 1.65625;
        case spr_sapo_teleporte_inverso: return 1.65625;
        case spr_esqueleto: return 8.42188;
        case spr_esqueleto_idle: return 8.42188;
        case spr_totem_boss: return 9.10938;
        case spr_seta: return 4.82812;
        case spr_poste: return 4.5;
        case spr_vela: return 2.59375;
        case spr_cerca: return 2.90625;
        default: return 1;
    }
}

/// @desc Largura do sprite antes de ser refeito (para fórmulas que usavam sprite_get_width).
/// @param {Asset.GMSprite} _spr
function sprite_largura_original(_spr) {
    switch (_spr) {
        case spr_confete: return 267;
        default: return sprite_get_width(_spr);
    }
}
