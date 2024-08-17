var moving = false;
// Variável para controlar a velocidade do player
var current_speed = global.speed_player;
var current_image_speed = 1; // Velocidade padrão da animação

// Se a tecla Shift estiver pressionada, reduz a velocidade
if (keyboard_check(vk_shift)) {
    current_speed = global.speed_player * 5; // Reduz a velocidade do player
    current_image_speed = 0.3; // Reduz a velocidade da animação (ajuste conforme necessário)
} else {
    current_image_speed = 0.6; // Volta à velocidade normal da animação
}

// Controle de movimento
var h_move = 0;
var v_move = 0;

if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
    h_move = -current_speed;
	image_angle = 270;

        moving = true;
} else if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
    h_move = current_speed;

        moving = true;
		image_angle = 90;
}

if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
    v_move = -current_speed;
	image_angle = 180;
        moving = true;
} else if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
    v_move = current_speed;
	image_angle = 0;
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





