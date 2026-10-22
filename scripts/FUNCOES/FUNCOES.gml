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
        // teclas configuráveis (scripts/SAVES -> tecla_segurando); as setas sempre funcionam também
        esquerda: tecla_segurando("esquerda") || keyboard_check(vk_left),
        direita:  tecla_segurando("direita")  || keyboard_check(vk_right),
        cima:     tecla_segurando("cima")     || keyboard_check(vk_up),
        baixo:    tecla_segurando("baixo")    || keyboard_check(vk_down),
        shift:    tecla_segurando("correr"),
        mouse_esq_press: mouse_check_button_pressed(mb_left),
        mouse_esq_rel:   mouse_check_button_released(mb_left),
        mouse_dir_press: mouse_check_button_pressed(mb_right),
        interagir: tecla_apertou("interagir")
    };
}

/// @desc Objetos do mundo que bloqueiam o player pela MÁSCARA DO PÉ (tronco, base da pedra/casa).
///       Carros da cidade também bloqueiam: ver colisao_carro_em() (retângulo do pé do carro).
///       Eles não usam mais `solid`: o solid do GameMaker devolve o player inteiro pra posição
///       anterior (sem deslizar) e, como a máscara muda com o vento/balanço, prendia e puxava o player.
function colisao_obstaculos_player() {
    return [obj_arvore, obj_rock, obj_estrutura];
}

/// @desc Instâncias de obstáculo que o player já está sobrepondo em (x, y) — ele pode sair delas.
function colisao_sobrepostos() {
    var _res = [];
    var _objs = colisao_obstaculos_player();
    var _l = ds_list_create();
    for (var _k = 0; _k < array_length(_objs); _k++) {
        ds_list_clear(_l);
        var _n = instance_place_list(x, y, _objs[_k], _l, false);
        for (var _i = 0; _i < _n; _i++) array_push(_res, _l[| _i]);
    }
    ds_list_destroy(_l);
    return _res;
}

/// @desc true se o player em (_x, _y) bate na parede _obj ou num obstáculo do mundo.
/// @param _ignorar   instâncias já sobrepostas no começo do movimento (deixa sair delas)
/// @param _sem_parede true quando o player já começou dentro da parede (deixa sair)
function colisao_bloqueia(_x, _y, _obj, _ignorar, _sem_parede) {
    if (!_sem_parede && place_meeting(_x, _y, _obj)) return true;
    var _objs = colisao_obstaculos_player();
    for (var _k = 0; _k < array_length(_objs); _k++) {
        var _inst = instance_place(_x, _y, _objs[_k]);
        if (_inst == noone) continue;
        if (array_length(_ignorar) == 0) return true;
        // pode haver mais de uma: só bloqueia se alguma não estiver na lista de ignoradas
        var _l = ds_list_create();
        var _n = instance_place_list(_x, _y, _objs[_k], _l, false);
        var _bate = false;
        for (var _i = 0; _i < _n; _i++) {
            var _ok = false;
            for (var _j = 0; _j < array_length(_ignorar); _j++) if (_ignorar[_j] == _l[| _i]) { _ok = true; break; }
            if (!_ok) { _bate = true; break; }
        }
        ds_list_destroy(_l);
        if (_bate) return true;
    }
    if (colisao_carro_em(_x, _y)) return true;
    return false;
}

/// @desc true se quem chama (player/inimigo), movido para (_x, _y), entra no "pé" de um carro da cidade.
///       Usa o retângulo do carro no chão (obj_carro_cidade.hitbox), não a máscara do sprite (que inclui
///       o teto). Carro que já está em cima (ex.: acabou de atropelar) é ignorado, pra deixar sair.
function colisao_carro_em(_x, _y) {
    if (!instance_exists(obj_carro_cidade)) return false;
    var _ox = _x - x, _oy = _y - y;
    var _l0 = bbox_left + _ox, _t0 = bbox_top + _oy, _r0 = bbox_right + _ox, _b0 = bbox_bottom + _oy;
    var _l = bbox_left, _t = bbox_top, _r = bbox_right, _b = bbox_bottom;
    var _bate = false;
    with (obj_carro_cidade) {
        var _hb = hitbox();
        if (rectangle_in_rectangle(_l, _t, _r, _b, _hb[0], _hb[1], _hb[2], _hb[3]) != 0) continue; // já está dentro
        if (rectangle_in_rectangle(_l0, _t0, _r0, _b0, _hb[0], _hb[1], _hb[2], _hb[3]) != 0) { _bate = true; break; }
    }
    return _bate;
}

/// @desc Executa movimentação com colisão pixel a pixel, deslizando em paredes e obstáculos.
///       - Eixos separados: andando na diagonal contra algo, desliza pelo outro eixo.
///       - Quina escorregadia: batendo de frente na ponta de algo (até COLISAO_QUINA px),
///         o player é empurrado de lado pra contornar em vez de ficar agarrado (vale correndo/dash).
///       - Se já começar sobreposto (ex.: árvore balançou em cima), deixa sair em vez de travar.
/// @param _hveloc Velocidade horizontal desejada
/// @param _vveloc Velocidade vertical desejada
/// @param _col_obj Objeto ou instância de colisão (padrão: global.sala.parede)
#macro COLISAO_QUINA 10
function aplicar_movimento_com_colisao(_hveloc, _vveloc, _col_obj = undefined) {
    var _obj = _col_obj;

    // Se nenhum objeto foi passado, tenta pegar a parede da sala atual ou o padrão
    if (_obj == undefined) {
        if (variable_global_exists("sala") && is_struct(global.sala) && variable_struct_exists(global.sala, "parede")) {
            _obj = global.sala.parede;
        } else {
            _obj = obj_wall;
        }
    }

    var _ign = colisao_sobrepostos();
    var _sem_parede = place_meeting(x, y, _obj);
    var _h_ori = _hveloc, _v_ori = _vveloc;

    // ---------- Horizontal ----------
    if (_hveloc != 0) {
        if (colisao_bloqueia(x + _hveloc, y, _obj, _ign, _sem_parede)) {
            var _s = sign(_hveloc);
            repeat (ceil(abs(_hveloc))) {
                if (colisao_bloqueia(x + _s, y, _obj, _ign, _sem_parede)) break;
                x += _s;
            }
            // quina: só quando não está apertando pra cima/baixo
            if (_v_ori == 0) {
                var _passo = max(1, min(abs(_h_ori), 3));
                for (var _d = 1; _d <= COLISAO_QUINA; _d++) {
                    if (!colisao_bloqueia(x + _s, y - _d, _obj, _ign, _sem_parede) && !colisao_bloqueia(x, y - _passo, _obj, _ign, _sem_parede)) { y -= _passo; break; }
                    if (!colisao_bloqueia(x + _s, y + _d, _obj, _ign, _sem_parede) && !colisao_bloqueia(x, y + _passo, _obj, _ign, _sem_parede)) { y += _passo; break; }
                }
            }
        } else {
            x += _hveloc;
        }
    }

    // ---------- Vertical ----------
    if (_vveloc != 0) {
        if (colisao_bloqueia(x, y + _vveloc, _obj, _ign, _sem_parede)) {
            var _s2 = sign(_vveloc);
            repeat (ceil(abs(_vveloc))) {
                if (colisao_bloqueia(x, y + _s2, _obj, _ign, _sem_parede)) break;
                y += _s2;
            }
            if (_h_ori == 0) {
                var _passo2 = max(1, min(abs(_v_ori), 3));
                for (var _d2 = 1; _d2 <= COLISAO_QUINA; _d2++) {
                    if (!colisao_bloqueia(x - _d2, y + _s2, _obj, _ign, _sem_parede) && !colisao_bloqueia(x - _passo2, y, _obj, _ign, _sem_parede)) { x -= _passo2; break; }
                    if (!colisao_bloqueia(x + _d2, y + _s2, _obj, _ign, _sem_parede) && !colisao_bloqueia(x + _passo2, y, _obj, _ign, _sem_parede)) { x += _passo2; break; }
                }
            }
        } else {
            y += _vveloc;
        }
    }
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
