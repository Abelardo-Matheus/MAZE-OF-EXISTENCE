 
function level_up_tuto() {
    global.level_player += 1;
    
    // Aumenta os atributos com base no novo nível
    global.vida_max_calc[global.level_player] = global.vida_max_calc[global.level_player - 1] + global.level_player*0.8; // Aumenta 10 de vida a cada level
    global.max_estamina_calc[global.level_player] = global.max_estamina_calc[global.level_player - 1] + 5; // Aumenta 5 de estamina
    global.dano_base[global.level_player] = global.dano_base[global.level_player - 1] + global.level_player*0.5; // Aumenta 1 de ataque base
    
    // Atualiza os valores de vida, estamina e ataque
    global.vida = global.vida_max_calc[global.level_player];
	global.vida_max = global.vida_max_calc[global.level_player];
    global.estamina = global.max_estamina_calc[global.level_player];
    global.ataque = global.dano_base[global.level_player];
    global.max_estamina = global.max_estamina_calc[global.level_player];
   
  
}

// Função para calcular o crítico
function calcular_critico_tuto() {
	randomize();
    // A chance de crítico aumenta em 2% a cada nível (por exemplo)
    var chance_critico = global.level_player * 1;
    
    // Gera um valor aleatório para decidir se o ataque é crítico ou não
    var sorteio = irandom_range(1, 100);
    
    if (sorteio <= chance_critico) {
        // Se for crítico, aumenta o dano em 50% (pode ajustar o multiplicador se desejar)
        global.critico = 1; // Marcador de crítico
        global.ataque = global.dano_base[global.level_player] * 1.5;
    } else {
        global.critico = 0; // Não foi crítico
        global.ataque = global.dano_base[global.level_player];
    }
}



function ganhar_xp_tuto(xp_ganho) {
    // Adiciona o XP ganho ao XP global
    global.xp += xp_ganho;
    
    // Laço para continuar verificando se o jogador tem XP suficiente para subir de nível
    while (true) {
        // Calcula o XP necessário para o próximo nível
        global.max_xp = global.level_player * 100;
        
        // Verifica se o jogador atingiu o XP necessário para subir de nível
        if (global.xp >= global.max_xp) {
            // Subtrai o XP necessário para o nível atual
            global.xp -= global.max_xp;
            
            // Chama a função para subir de nível
            level_up_tuto();
        } else {
            // Sai do loop se não tiver XP suficiente para subir mais um nível
            break;
        }
    }
}



function scr_andando_tuto() {
    var _in = obter_inputs_jogador();

    if (global.vida == 0) game_restart();

    var _h_input = _in.direita - _in.esquerda;
    var _v_input = _in.baixo - _in.cima;
    var _speed   = global.speed_player;

    if (_in.shift && global.estamina > 0 && (_h_input != 0 || _v_input != 0)) {
        _speed += 10;
        global.estamina -= 2;
    }

    if (_h_input != 0 || _v_input != 0) {
        var _dir_input = point_direction(0, 0, _h_input, _v_input);
        hveloc = lengthdir_x(_speed, _dir_input);
        vveloc = lengthdir_y(_speed, _dir_input);

        if (_h_input > 0) sprite_index = spr_player_direita;
        else if (_h_input < 0) sprite_index = spr_player_esquerda;
        else if (_v_input > 0) sprite_index = spr_player_baixo;
        else if (_v_input < 0) sprite_index = spr_player_cima;
    } else {
        hveloc = 0;
        vveloc = 0;
        
        var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
        dir = round(_dir_mouse / 90) % 4;
        
        switch (dir) {
            case 0: sprite_index = spr_player_direita_parado; break;
            case 1: sprite_index = spr_player_cima_parado; break;
            case 2: sprite_index = spr_player_esquerda_parado; break;
            case 3: sprite_index = spr_player_baixo_parado; break;
        }
    }

    scr_player_colisao_tuto();

    // Transições
    if (_in.mouse_esq_press) {
        if (global.armamento == Armamentos.espada) {
            image_index = 0;
            state = scr_ataque_player_tuto;
        } else if (global.armamento == Armamentos.arco) {
            image_index = 0;
            state = scr_personagem_arco_tuto;
        }
    }

    if (_in.mouse_dir_press) {
        alarm[11] = 10;
        dash_dir = point_direction(x, y, mouse_x, mouse_y);
        state = scr_personagem_dash_tuto;
    }
}

function scr_personagem_dash_tuto() {
    global.estamina -= 3;
    hveloc = lengthdir_x(dash_veloc, dash_dir);
    vveloc = lengthdir_y(dash_veloc, dash_dir);
    
    scr_player_colisao_tuto();
    
    var _inst = instance_create_layer(x, y, "instances", obj_rastro_player);
    _inst.sprite_index = sprite_index;
}

function scr_personagem_arco_tuto() {
    var _dir_mouse = point_direction(x, y, mouse_x, mouse_y);
    dir = round(_dir_mouse / 90) % 4;

    // Atualiza sprite do player
    switch (dir) {
        case 0: sprite_index = spr_player_direita_parado; break;
        case 1: sprite_index = spr_player_cima_parado; break;
        case 2: sprite_index = spr_player_esquerda_parado; break;
        case 3: sprite_index = spr_player_baixo_parado; break;
    }

    // Gerencia o Arco
    if (!instance_exists(obj_arco)) {
        instance_create_layer(x, y, "Instances_itens", obj_arco);
    }

    with (obj_arco) {
        x = other.x + lengthdir_x(30, _dir_mouse);
        y = other.y + lengthdir_y(30, _dir_mouse) + 10;
        image_angle = _dir_mouse + 90;
        if (fim_animation()) image_index = 4;
    }

    // Permite movimento enquanto mira (Tutorial style)
    scr_andando_tuto(); 

    if (mouse_check_button_released(mb_left)) {
        if (instance_exists(obj_arco) && obj_arco.image_index >= 4) {
            var _flecha = instance_create_layer(obj_arco.x, obj_arco.y, "Instances_itens", obj_flecha);
            _flecha.direction = _dir_mouse;
            _flecha.speed = 15;
            _flecha.image_angle = _dir_mouse;
            
            instance_destroy(obj_arco);
            empurrar_dir = point_direction(mouse_x, mouse_y, x, y);
            alarm[2] = 5;
            state = scr_personagem_hit_tuto;
        } else {
            instance_destroy(obj_arco);
            state = scr_andando_tuto;
        }
    }
}



function scr_ataque_player_tuto(){
    // Define a sprite de ataque baseada na direção
    switch (dir) {
        case 0: sprite_index = spr_player_direita_parado_atacando; break;
        case 1: sprite_index = spr_player_cima_parado_atacando; break;
        case 2: sprite_index = spr_player_esquerda_parado_atacando; break;
        case 3: sprite_index = spr_player_baixo_parado_atacando; break;
    }

	if(image_index >= 1){
	if(atacando = false){
	switch dir{
	 default:
	  instance_create_layer( x + 10, y - 20, "instances", obj_hibox_ataque);
	 break;
	 case 1:
	  instance_create_layer( x - 40 , y -70, "instances", obj_hibox_ataque);
	 break;
	 case 2:
	  instance_create_layer( x - 70, y -20 , "instances", obj_hibox_ataque);
	 break;
	 case 3:
	  instance_create_layer( x - 40 , y + 20, "instances", obj_hibox_ataque);
	 break;
 }	
 atacando = true;
		}
	}
	if fim_animation(){
		state = scr_andando_tuto;
		atacando = false;
	}
	
}
	
function scr_personagem_hit_tuto(){
	if(alarm[2] > 0 ){
	
	hveloc = lengthdir_x(8,empurrar_dir);
	vveloc = lengthdir_y(8,empurrar_dir);

	scr_player_colisao_tuto();
	}else{
		state = scr_andando_tuto;
	}
}

function scr_player_colisao_tuto(){
    aplicar_movimento_com_colisao(hveloc, vveloc, [obj_parede_invi, obj_par_cenario_casa]);
}