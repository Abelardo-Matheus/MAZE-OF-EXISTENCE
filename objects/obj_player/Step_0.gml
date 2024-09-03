

if(global.vida_sperm == 0){
	game_restart();
}

if(global.tamanho_player >3){
global.tamanho_player = 3;
}

var moving = false;
// Variável para controlar a velocidade do player

var current_image_speed = 1; // Velocidade padrão da animação




// Controle de movimento
var h_move = 0;
var v_move = 0;


// Controle de movimento
var h_move = 0;
var v_move = 0;

if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
    h_move = -current_speed;
	sprite_index = spr_player_esquerda;
        moving = true;
} else if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
    h_move = current_speed;
	sprite_index = spr_player_direita;
        moving = true;
}

if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
    v_move = -current_speed;
	 sprite_index = spr_player_cima;
        moving = true;
} else if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
    v_move = current_speed;
	sprite_index = spr_player_baixo;
        moving = true;
}

// Atualiza a posição do player
x += h_move;
y += v_move;


// Atualiza a animação do player se ele estiver se movendo
if (moving) {
	
	image_speed = current_image_speed; // Define a velocidade da animação baseada na velocidade atual
} else {
    image_speed = 0; // Para a animação do player
    image_index = 0; // Opcional: redefine para o primeiro quadro da animação
}


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



// Verificar quando o dash termina
if (alarm[0] <= 0 && global.dash_em_recarga) {
    global.dash_em_recarga = false;  // Reseta o estado de recarga
}

// Manter o bloco de colisão na posição correta
if (instance_exists(global.bloco_colisao)) {
    global.bloco_colisao.x = x;
    global.bloco_colisao.y = y +30; // Ajuste 50 conforme necessário
}