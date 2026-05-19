/// @description Script unificado com todos os estados do Player
// Certifique-se que as macros (ALARM_ESTAMINA, etc.) estão definidas em um script de inicialização.

// ==============================================================================
// REGIÃO: ESTADOS PRINCIPAIS
// ==============================================================================
#region ESTADOS

// ------------------------------------------------------------------------------
// 1. ESTADO: ANDANDO (Movimento Padrão)
// ------------------------------------------------------------------------------
function scr_personagem_andando() {
    // --- Entradas (Inputs) ---
    var _in = obter_inputs_jogador();

    // --- Cálculo de Velocidade ---
    var _h_input = _in.direita - _in.esquerda;
    var _v_input = _in.baixo - _in.cima;
    var _speed   = global.speed_player;

    // Sistema de Corrida (Gasta Estamina)
    if (_in.shift && global.estamina > 0 && (_h_input != 0 || _v_input != 0)) {
        _speed += 2;
        andar = true;
        global.estamina -= 0.5;
        alarm[ALARM_ESTAMINA] = 60;
    } else {
        andar = false;
    }

    // ==========================================
    // --- APLICA MOVIMENTO E SOM DE PASSO ---
    // ==========================================
    if (_h_input != 0 || _v_input != 0) {
        tocar_som_passo();
        var _dir_input = point_direction(0, 0, _h_input, _v_input);
        hveloc = lengthdir_x(_speed, _dir_input);
        vveloc = lengthdir_y(_speed, _dir_input);

        if (_h_input > 0) { dir = 0; sprite_index = spr_player_direita; }
        else if (_h_input < 0) { dir = 2; sprite_index = spr_player_esquerda; }
        else if (_v_input > 0) { dir = 3; sprite_index = spr_player_baixo; }
        else if (_v_input < 0) { dir = 1; sprite_index = spr_player_cima; }
    } else {
        parar_som_passo();
        hveloc = 0;
        vveloc = 0;
        
        switch (dir) {
            case 0: sprite_index = spr_player_direita_parado; break;
            case 1: sprite_index = spr_player_cima_parado; break;
            case 2: sprite_index = spr_player_esquerda_parado; break;
            case 3: sprite_index = spr_player_baixo_parado; break;
        }
    }

    scr_player_colisao();

    // --- Transição de Estados ---
    if (_in.mouse_esq_press) {
        parar_som_passo();
        var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
        dir = round(_dir_mouse / 90) % 4;

        if (global.armamento == Armamentos.espada) {
            image_index = 0;
            atacando = false;
            state = scr_ataque_player;
        } 
        else if (global.armamento == Armamentos.arco) {
            image_index = 0;
            state = scr_personagem_arco;
        }
    }

    if (_in.mouse_dir_press && global.estamina >= 10 && alarm[ALARM_DASH_COOLDOWN] <= 0) {
        parar_som_passo();
        global.estamina -= 10;
        alarm[ALARM_ESTAMINA] = 60;
        dash_dir = point_direction(x, y, mouse_x, mouse_y);
        global.in_dash = true;
        state = scr_personagem_dash;
    }
}

// ------------------------------------------------------------------------------
// 2. ESTADO: DASH
// ------------------------------------------------------------------------------
function scr_personagem_dash() {
    // Movimento fixo na direção do dash
    hveloc = lengthdir_x(dash_veloc, dash_dir);
    vveloc = lengthdir_y(dash_veloc, dash_dir);

    // Aplica Colisão Segura (para não atravessar paredes)
    scr_player_colisao();

    // Cria rastro visual
    var _rastro = instance_create_layer(x, y, "Instances", obj_rastro_player);
    _rastro.sprite_index = sprite_index;
    _rastro.image_index = image_index;
    _rastro.image_alpha = 0.5;

    // Condição de Saída (Decaimento de velocidade)
    dash_veloc *= 0.9; 

    if (dash_veloc < global.speed_player) {
        dash_veloc = 10; // Reseta velocidade para o próximo dash
        global.in_dash = false;
        alarm[ALARM_DASH_COOLDOWN] = 20; // Cooldown para não spammar
        state = scr_personagem_andando;
    }
}

// ------------------------------------------------------------------------------
// 3. ESTADO: ATAQUE (ESPADA) - MODIFICADO PARA USAR UM ÚNICO OBJETO ROTACIONADO
// ------------------------------------------------------------------------------
function scr_ataque_player() {
    hveloc = 0; // Trava movimento
    vveloc = 0;

    // Define Sprite de Ataque baseado na direção do olhar (dir)
    switch (dir) {
        case 0: sprite_index = spr_player_direita_parado_atacando; break;
        case 1: sprite_index = spr_player_cima_parado_atacando; break;
        case 2: sprite_index = spr_player_esquerda_parado_atacando; break;
        case 3: sprite_index = spr_player_baixo_parado_atacando; break;
    }

    // Cria Hitbox (A Lógica de Dano continua aqui)
    if (image_index >= 1 && !atacando) {
        atacando = true; 
        
        var _xx = x;
        var _yy = y;
        var _angle = 0; 
        
        switch (dir) {
            case 0: _xx += 20; _angle = 0;   break;
            case 1: _yy -= 20; _angle = 90;  break;
            case 2: _xx -= 20; _angle = 180; break;
            case 3: _yy += 20; _angle = 270; break;
        }
        
        var _hitbox = instance_create_layer(_xx, _yy, "Instances", obj_hibox_ataque);
        _hitbox.image_angle = _angle; 
        _hitbox.dano = global.ataque;
        _hitbox.pode_matar_fantasma = global.mata_fantasma;
    }

    // Fim da Animação -> Volta a andar
    if (fim_animation_()) {
        atacando = false;
        state = scr_personagem_andando;
    }
}
// ------------------------------------------------------------------------------
// 4. ESTADO: ARCO E FLECHA
// ------------------------------------------------------------------------------
function scr_personagem_arco() {
   hveloc = 0; // Trava movimento
    vveloc = 0;

    var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
    
    // Atualiza a direção do olhar baseado no mouse (MATEMÁTICA CORRIGIDA)
    dir = round(_dir_mouse / 90);
    if (dir == 4) dir = 0; 
    
    // Mantém o sprite parado na direção correta enquanto mira
    switch (dir) {
        case 0: sprite_index = spr_player_direita_parado; break;
        case 1: sprite_index = spr_player_cima_parado; break;
        case 2: sprite_index = spr_player_esquerda_parado; break;
        case 3: sprite_index = spr_player_baixo_parado; break;
    }

    // Gerencia o Objeto Arco Visual
    if (!instance_exists(obj_arco)) {
        instance_create_layer(x, y, "Instances_itens", obj_arco);
    }

    with (obj_arco) {
        x = other.x + lengthdir_x(10, _dir_mouse);
        y = other.y + lengthdir_y(10, _dir_mouse) + 5; // +5 ajuste vertical
        image_angle = _dir_mouse;
        
        // Toca animação de "puxar a corda" e trava no final
        if (image_index >= image_number - 1) image_speed = 0;
        else image_speed = 1;
    }

    // Soltou o botão -> Atira
    if (mouse_check_button_released(mb_left)) {
        // Só atira se o arco estiver "carregado" (frame 3 ou mais)
        if (instance_exists(obj_arco) && obj_arco.image_index >= 3) {
            var _flecha = instance_create_layer(obj_arco.x, obj_arco.y, "Instances", obj_flecha);
            _flecha.direction = _dir_mouse;
            _flecha.image_angle = _dir_mouse;
            _flecha.speed = 12;
            _flecha.dano = global.ataque;
            
            // Pequeno recuo ao atirar
            var _recuo_dir = _dir_mouse + 180;
            hveloc = lengthdir_x(4, _recuo_dir);
            vveloc = lengthdir_y(4, _recuo_dir);
            state = scr_personagem_hit; // Usa o estado de hit para o recuo
            alarm[ALARM_KNOCKBACK] = 5; // Duração curta para o recuo do tiro
        } else {
            // Cancelou o tiro antes de carregar
            state = scr_personagem_andando;
        }
        
        instance_destroy(obj_arco);
    }
}

// ========================================================
// ESTADO: HIT (Sendo Empurrado)
// ========================================================
function scr_personagem_hit() {
    // Define uma velocidade fixa para o empurrão
    var _forca_empurrao = 4;

    // Aplica a velocidade na direção definida no momento da colisão
    hveloc = lengthdir_x(_forca_empurrao, empurrar_dir);
    vveloc = lengthdir_y(_forca_empurrao, empurrar_dir);

    // Opcional: Mudar sprite para "machucado"
    // sprite_index = spr_player_machucado;

    // --- APLICA COLISÃO SEGURA ---
    // É CRUCIAL usar o script de colisão auxiliar aqui para não
    // atravessar paredes enquanto é empurrado.
    scr_player_colisao();

    // --- CONDIÇÃO DE SAÍDA DO ESTADO ---
    // Verifica se o Alarme de Knockback terminou.
    // Se alarm[2] for menor ou igual a zero, o tempo acabou.
    if (alarm[ALARM_KNOCKBACK] <= 0) {
        // 1. Para o movimento residual
        hveloc = 0;
        vveloc = 0;

        // 2. Reseta a flag que força este estado
        hit = false;

        // 3. Reseta a cor visual (se mudou para vermelho)
        image_blend = c_white;

        // 4. Volta para o estado de movimento normal
        state = scr_personagem_andando;
    }
}
#endregion

// ==============================================================================
// REGIÃO: FUNÇÕES AUXILIARES (HELPERS)
// ==============================================================================
#region HELPERS

// ------------------------------------------------------------------------------
// HELPER: COLISÃO SEGURA (Com trava anti-travamento)
// ------------------------------------------------------------------------------
function scr_player_colisao() {
    // Verifica se a parede existe na sala
    var _parede = (variable_global_exists("sala") && variable_struct_exists(global.sala, "parede")) ? global.sala.parede : obj_wall;
    aplicar_movimento_com_colisao(hveloc, vveloc, _parede);
}

// ------------------------------------------------------------------------------
// HELPER: VERIFICA FIM DA ANIMAÇÃO
// ------------------------------------------------------------------------------
function fim_animation_() {
    return (image_index + image_speed >= image_number);
}

#endregion