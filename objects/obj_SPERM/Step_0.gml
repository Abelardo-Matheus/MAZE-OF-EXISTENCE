show_debug_message(global.destino_templo);
show_debug_message(global.current_sala);
if(global.vida_sperm == 0){
	game_restart();
}

if(global.tamanho_player >3){
global.tamanho_player = 3;
}
image_xscale = global.tamanho_player;
image_yscale = global.tamanho_player;
var moving = false;
// Variável para controlar a velocidade do player

var current_image_speed = 1; // Velocidade padrão da animação




// Controle de movimento
var h_move = 0;
var v_move = 0;

// Verificar teclas de movimento
var moving_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var moving_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var moving_up = keyboard_check(vk_up) || keyboard_check(ord("W"));
var moving_down = keyboard_check(vk_down) || keyboard_check(ord("S"));

// Movimento horizontal
if (moving_left) {
    h_move = -current_speed;
} else if (moving_right) {
    h_move = current_speed;
}

// Movimento vertical
if (moving_up) {
    v_move = -current_speed;
} else if (moving_down) {
    v_move = current_speed;
}

// Definir o ângulo com base na direção do movimento
if (moving_left && moving_up) {
    image_angle = 225; // Esquerda e cima (diagonal)
} else if (moving_left && moving_down) {
    image_angle = 315; // Esquerda e baixo (diagonal)
} else if (moving_right && moving_up) {
    image_angle = 135; // Direita e cima (diagonal)
} else if (moving_right && moving_down) {
    image_angle = 45; // Direita e baixo (diagonal)
} else if (moving_left) {
    image_angle = 270; // Esquerda
} else if (moving_right) {
    image_angle = 90; // Direita
} else if (moving_up) {
    image_angle = 180; // Cima
} else if (moving_down) {
    image_angle = 0; // Baixo
}

// Atualiza a posição do player
x += h_move;
y += v_move;

// Atualiza a animação do player se ele estiver se movendo
if (h_move != 0 || v_move != 0) {
    moving = true;
}

if (moving) {
    image_speed = current_image_speed; // Define a velocidade da animação com base na velocidade atual
} else {
    image_speed = 0; // Para a animação do player
    image_index = 0; // Opcional: redefine para o primeiro quadro da animação
}
// Verifica se o dash está habilitado e se não está em recarga
if (global.dash_habilitado && !global.dash_em_recarga) {
    if (keyboard_check_pressed(vk_shift)) {
		global.in_dash =true;
        // Inicia o dash
        current_speed = global.speed_dash;
        global.dash_em_recarga = true;  // Ativa a recarga do dash
        alarm[0] = global.frames;  // Define a duração do dash
    } else {
        // Volta à velocidade normal
		global.in_dash = false;
        current_speed = global.speed_sperm;
        current_image_speed = 0.6;
    }
}

if(global.in_dash == true){
	var rastro = instance_create_layer(obj_SPERM.x,obj_SPERM.y,"instances",obj_rastro);
		with(rastro){
			if (moving_left && moving_up) {
    image_angle = 225; // Esquerda e cima (diagonal)
		} else if (moving_left && moving_down) {
    image_angle = 315; // Esquerda e baixo (diagonal)
		} else if (moving_right && moving_up) {
    image_angle = 135; // Direita e cima (diagonal)
		} else if (moving_right && moving_down) {
    image_angle = 45; // Direita e baixo (diagonal)
		} else if (moving_left) {
    image_angle = 270; // Esquerda
		} else if (moving_right) {
    image_angle = 90; // Direita
		} else if (moving_up) {
    image_angle = 180; // Cima
		} else if (moving_down) {
    image_angle = 0; // Baixo
}
		
		}
}


// Verificar quando o dash termina
if (alarm[0] <= 0 && global.dash_em_recarga) {
    global.dash_em_recarga = false;  // Reseta o estado de recarga
}