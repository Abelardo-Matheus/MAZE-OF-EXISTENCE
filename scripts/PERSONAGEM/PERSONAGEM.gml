// ========================================================
// 1. ESTADO: ANDANDO (Movimento Padrão)
// ========================================================
function scr_personagem_andando() {
    // --- Entradas (Inputs) ---
    var _left  = keyboard_check(ord("A")) || keyboard_check(vk_left);
    var _right = keyboard_check(ord("D")) || keyboard_check(vk_right);
    var _up    = keyboard_check(ord("W")) || keyboard_check(vk_up);
    var _down  = keyboard_check(ord("S")) || keyboard_check(vk_down);
    var _run   = keyboard_check(vk_shift);

    // --- Cálculo de Velocidade ---
    var _h_input = _right - _left;
    var _v_input = _down - _up;
    var _speed   = global.speed_player;

    // Sistema de Corrida (Gasta Estamina)
    if (_run && global.estamina > 0 && (_h_input != 0 || _v_input != 0)) {
        _speed += 2; // Bônus de velocidade
        andar = true; // Flag para parar regeneração de estamina
        global.estamina -= 0.5; // Custo por frame
        alarm[ALARM_ESTAMINA] = 60; // Delay para voltar a regenerar
    } else {
        andar = false;
    }

    // Aplica Movimento
    if (_h_input != 0 || _v_input != 0) {
        var _dir = point_direction(0, 0, _h_input, _v_input);
        hveloc = lengthdir_x(_speed, _dir);
        vveloc = lengthdir_y(_speed, _dir);

        // Define Sprite de Movimento
        if (_h_input > 0) sprite_index = spr_player_direita;
        else if (_h_input < 0) sprite_index = spr_player_esquerda;
        else if (_v_input > 0) sprite_index = spr_player_baixo;
        else if (_v_input < 0) sprite_index = spr_player_cima;
        
    } else {
        hveloc = 0;
        vveloc = 0;
        
        // Define Sprite Parado (Baseado no Mouse)
        dir = floor((point_direction(x, y, mouse_x, mouse_y) + 45) / 90);
        switch (dir) {
            case 0: sprite_index = spr_player_direita_parado; break;
            case 1: sprite_index = spr_player_cima_parado; break;
            case 2: sprite_index = spr_player_esquerda_parado; break;
            case 3: sprite_index = spr_player_baixo_parado; break;
            default: sprite_index = spr_player_baixo_parado; break;
        }
    }

    // Aplica Colisão
    scr_player_colisao();

    // --- Transição de Estados (Ataque e Dash) ---
    
    // Ataque (Botão Esquerdo)
    if (mouse_check_button_pressed(mb_left)) {
        if (global.armamento == Armamentos.espada) {
            image_index = 0;
            atacando = false; // Reseta flag de hitbox
            state = scr_ataque_player;
        } 
        else if (global.armamento == Armamentos.arco) {
            image_index = 0;
            state = scr_personagem_arco;
        }
    }

    // Dash (Botão Direito)
    if (mouse_check_button_pressed(mb_right) && global.estamina >= 10 && alarm[ALARM_DASH_COOLDOWN] <= 0) {
        global.estamina -= 10;
        alarm[ALARM_ESTAMINA] = 60;
        
        dash_dir = point_direction(x, y, mouse_x, mouse_y);
        global.in_dash = true;
        state = scr_personagem_dash;
    }
}

// ========================================================
// 2. ESTADO: DASH
// ========================================================
function scr_personagem_dash() {
    // Movimento fixo na direção do dash
    hveloc = lengthdir_x(dash_veloc, dash_dir);
    vveloc = lengthdir_y(dash_veloc, dash_dir);

    // Colisão (Opcional: Se quiser atravessar paredes, remova esta linha)
    scr_player_colisao();

    // Cria rastro visual
    var _rastro = instance_create_layer(x, y, "Instances", obj_rastro_player);
    _rastro.sprite_index = sprite_index;
    _rastro.image_index = image_index;
    _rastro.image_alpha = 0.5;

    // Condição de Saída (Velocidade diminui ou tempo acaba)
    // Aqui estou usando um decaimento simples da velocidade para sair do dash
    dash_veloc *= 0.9; 

    if (dash_veloc < global.speed_player) {
        dash_veloc = 10; // Reseta para o próximo dash
        global.in_dash = false;
        alarm[ALARM_DASH_COOLDOWN] = 20; // Cooldown para não spammar
        state = scr_personagem_andando;
    }
}

// ========================================================
// 3. ESTADO: ATAQUE (ESPADA)
// ========================================================
function scr_ataque_player() {
    hveloc = 0;
    vveloc = 0;

    // Define Sprite de Ataque baseado na direção do olhar (dir)
    switch (dir) {
        case 0: sprite_index = spr_player_direita_parado_atacando; break;
        case 1: sprite_index = spr_player_cima_parado_atacando; break;
        case 2: sprite_index = spr_player_esquerda_parado_atacando; break;
        case 3: sprite_index = spr_player_baixo_parado_atacando; break;
    }

    // Cria Hitbox no momento certo da animação (ex: frame 1 ou 2)
    if (image_index >= 1 && !atacando) {
        atacando = true;
        
        var _xx = x;
        var _yy = y;
        
        // Ajuste da posição da hitbox
        switch (dir) {
            case 0: _xx += 20; break; // Direita
            case 1: _yy -= 20; break; // Cima
            case 2: _xx -= 20; break; // Esquerda
            case 3: _yy += 20; break; // Baixo
        }
        
        var _hitbox = instance_create_layer(_xx, _yy, "Instances", obj_hibox_ataque);
        _hitbox.dano = global.ataque; // Passa o dano atual do player
        
        // Lógica da Espada Mata-Fantasma
        _hitbox.pode_matar_fantasma = global.mata_fantasma;
    }

    // Fim da Animação
    if (fim_animation_()) {
        atacando = false;
        state = scr_personagem_andando;
    }
}

// ========================================================
// 4. ESTADO: ARCO E FLECHA
// ========================================================
function scr_personagem_arco() {
    // Trava movimento ou permite andar devagar (opcional)
    hveloc = 0;
    vveloc = 0;

    var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
    
    // Atualiza sprite do player para a direção do mouse
    dir = floor((_dir_mouse + 45) / 90);
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
        // Só atira se o arco estiver "carregado" (frame 4 por exemplo)
        if (instance_exists(obj_arco) && obj_arco.image_index >= 3) {
            var _flecha = instance_create_layer(obj_arco.x, obj_arco.y, "Instances", obj_flecha);
            _flecha.direction = _dir_mouse;
            _flecha.image_angle = _dir_mouse;
            _flecha.speed = 12;
            _flecha.dano = global.ataque; // Dano da flecha
            
            // Recuo no player
            var _recuo_dir = _dir_mouse + 180;
            hveloc = lengthdir_x(4, _recuo_dir);
            vveloc = lengthdir_y(4, _recuo_dir);
            state = scr_personagem_hit; // Usa o estado de hit para fazer o recuo
            alarm[ALARM_KNOCKBACK] = 5; // Duração do recuo curto
        } else {
            // Cancelou o tiro
            state = scr_personagem_andando;
        }
        
        instance_destroy(obj_arco);
    }
}

function scr_personagem_hit() {
    // Verifica se a parede existe na sala (baseado no seu código de geração procedural)
    var _parede = (variable_global_exists("sala") && variable_struct_exists(global.sala, "parede")) ? global.sala.parede : obj_parede_bebe;

    // Limite máximo de loops para evitar travamentos
    var _max_loops = 32; 
    var _loops = 0;

    // ========================================================
    // COLISÃO HORIZONTAL
    // ========================================================
    if (place_meeting(x + hveloc, y, _parede)) {
        // Reseta contador
        _loops = 0;
        
        // Enquanto não encontrar uma parede a 1 pixel de distância...
        // E o número de loops for menor que o limite...
        while (!place_meeting(x + sign(hveloc), y, _parede) && _loops < _max_loops) {
            x += sign(hveloc);
            _loops++; // --- TRAVA DE SEGURANÇA: Incrementa contador
        }
        
        // Se atingiu o limite, é porque ia travar. Debug opcional.
        if (_loops >= _max_loops) {
             show_debug_message("ALERTA: Evitou travamento na colisão Horizontal!");
        }
        
        hveloc = 0;
    }
    x += hveloc;

    // ========================================================
    // COLISÃO VERTICAL
    // ========================================================
    if (place_meeting(x, y + vveloc, _parede)) {
        // Reseta contador
        _loops = 0;
        
        while (!place_meeting(x, y + sign(vveloc), _parede) && _loops < _max_loops) {
            y += sign(vveloc);
            _loops++; // --- TRAVA DE SEGURANÇA: Incrementa contador
        }

        // Se atingiu o limite, é porque ia travar.
        if (_loops >= _max_loops) {
             show_debug_message("ALERTA: Evitou travamento na colisão Vertical!");
        }

        vveloc = 0;
    }
    y += vveloc;
}

// ========================================================
// 6. HELPER: COLISÃO
// ========================================================
function scr_player_colisao() {
    // Verifica se a parede existe na sala (baseado no seu código de geração procedural)
    var _parede = (variable_global_exists("sala") && variable_struct_exists(global.sala, "parede")) ? global.sala.parede : obj_parede_bebe;

    // Colisão Horizontal
    if (place_meeting(x + hveloc, y, _parede)) {
        while (!place_meeting(x + sign(hveloc), y, _parede)) {
            x += sign(hveloc);
        }
        hveloc = 0;
    }
    x += hveloc;

    // Colisão Vertical
    if (place_meeting(x, y + vveloc, _parede)) {
        while (!place_meeting(x, y + sign(vveloc), _parede)) {
            y += sign(vveloc);
        }
        vveloc = 0;
    }
    y += vveloc;
}

// ========================================================
// 7. HELPER: FIM DA ANIMAÇÃO
// ========================================================
function fim_animation_() {
    return (image_index + image_speed >= image_number);
}