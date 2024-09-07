
if(verificar_sala_escura(global.current_sala)){
	global.encontrou_sala_escura = true;
	}else{
		global.encontrou_sala_escura = false;
	}
if(global.vida == 0){
	game_restart();
}

if(global.tamanho_player >3){
global.tamanho_player = 3;
}

var moving = false;
var current_image_speed = 1; // Velocidade padrão da animação
var diagonal_angle = 0;



// Controle de movimento
var h_move = 0;
var v_move = 0;

var alvo_angle;
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

// Verificar se está pressionando duas teclas simultaneamente para movimentação diagonal
if (h_move != 0 && v_move != 0) {
    if (h_move > 0 && v_move < 0) {
        diagonal_angle = 315; // Direção para cima e direita
    } else if (h_move > 0 && v_move > 0) {
        diagonal_angle = 45; // Direção para baixo e direita
    } else if (h_move < 0 && v_move < 0) {
        diagonal_angle = 45; // Direção para cima e esquerda
    } else if (h_move < 0 && v_move > 0) {
        diagonal_angle = 315; // Direção para baixo e esquerda
    }
}

// Atualiza a posição do player
x += h_move;
y += v_move;


// Atualiza o ângulo de rotação de maneira suave e direta
if (moving) {
    var diff_angle = diagonal_angle - image_angle;
    
    // Verifica a diferença de ângulo para garantir que ele não faça uma rotação completa
    if (diff_angle > 180) {
        diff_angle -= 360;
    } else if (diff_angle < -180) {
        diff_angle += 360;
    }
    
    // Interpolação suave para mudar o ângulo gradualmente
    image_angle += diff_angle * 0.1;
    
    // Simular o balanço ao andar usando uma função de seno
    var tempo = current_time / 100;  // Ajusta a frequência do balanço
    var amplitude = 2;  // Define a amplitude do balanço
    image_yscale = 1.5 + sin(tempo) * 0.05;  // Balanço no eixo Y
    
    image_speed = 0.6;
} else {
    image_speed = 0;
    image_index = 0;
    image_yscale = 1.5;  // Restaurar o valor padrão de escala
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
        current_speed = global.speed_player;
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

if(instance_exists(obj_item)and obj_invetario.inventario = false){
	var _inst = instance_nearest(x,y,obj_item);
	if(distance_to_point(_inst.x,_inst.y)<= 20){
		if(keyboard_check_pressed(ord("F"))){
			adicionar_item_invent(_inst.image_index,_inst.quantidade,_inst.sprite_index,_inst.nome,_inst.descricao);
			instance_destroy(_inst);
		}
	}
}