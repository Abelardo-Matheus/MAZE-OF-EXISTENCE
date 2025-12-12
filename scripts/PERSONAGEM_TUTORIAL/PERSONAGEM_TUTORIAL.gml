 
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



function scr_andando_tuto(){
	
if (global.estamina > 0 ){

if(global.vida == 0){
	game_restart();
}

if(global.tamanho_player >3){
global.tamanho_player = 3;
}

var moving = false;
var current_image_speed = 1; // Velocidade padrão da animação
var diagonal_angle = 0;

if(andar = false){
esquerda = keyboard_check(ord("A")) || keyboard_check(vk_left);
direita = keyboard_check(ord("D")) || keyboard_check(vk_right);
cima = keyboard_check(ord("W")) || keyboard_check(vk_up);
baixo = keyboard_check(ord("S")) || keyboard_check(vk_down);


if (esquerda) {
	sprite_index = spr_player_esquerda;
     moving = true;
	
} else if (direita) {
	sprite_index = spr_player_direita;
        moving = true;
}

else if (cima) { 
	 sprite_index = spr_player_cima;
      moving = true;
	  
} else if (baixo) { 
	sprite_index = spr_player_baixo;
        moving = true;
		
}


vveloc = (baixo - cima) ;
hveloc = (direita - esquerda);

veloc_dir = point_direction(x, y, x + hveloc, y + vveloc);

if(hveloc != 0 or vveloc != 0){
	current_speed = global.speed_player;
}else{
	current_speed = 0;
}

hveloc = lengthdir_x(current_speed, veloc_dir);
vveloc = lengthdir_y(current_speed, veloc_dir);

if(keyboard_check(vk_shift) && global.estamina > 0){
		hveloc = lengthdir_x(current_speed+10, veloc_dir);
		vveloc = lengthdir_y(current_speed+10, veloc_dir);
		global.estamina-=2;
	}else if(keyboard_check(vk_shift) && global.estamina == 0){
		hveloc = 0;
		vveloc = 0;
		
	}
	

scr_player_colisao_tuto();
dir = floor((point_direction(x,y,mouse_x,mouse_y)+ 45)/90);

if(hveloc == 0 and vveloc == 0){
 switch dir{
	 default:
	 sprite_index = spr_player_direita_parado
	 break;
	 case 1:
	 sprite_index = spr_player_cima_parado
	 break;
	 case 2:
	 sprite_index = spr_player_esquerda_parado
	 break;
	 case 3:
	 sprite_index = spr_player_baixo_parado
	 break;
 }	
}
}

if(global.in_dash == true){
	var rastro = instance_create_layer(x,y,"instances",obj_rastro_player);
		with(rastro){
		if (obj_player.esquerda) {
    sprite_index = spr_player_esquerda;
		} else if (obj_player.direita) {
    sprite_index = spr_player_direita;
		} else if (obj_player.cima) {
    sprite_index = spr_player_cima;
		} else if (obj_player.baixo) {
     sprite_index = spr_player_baixo;
}
		
		}
}




if(instance_exists(obj_item)and obj_inventario.inventario = false and !global.inventario_cheio){
	var _inst = instance_nearest(x,y,obj_item);
	if(distance_to_point(_inst.x,_inst.y)<= 180){
		desenha_botao = true;
		if(keyboard_check_pressed(ord("F"))&& pegar = true){
			adicionar_item_invent(_inst.image_index,_inst.quantidade,_inst.sprite_index,_inst.nome,_inst.descricao,0,0,0,0,_inst.dano,_inst.armadura,_inst.velocidade,_inst.cura,_inst.tipo,_inst.ind);
			coletar_item(_inst.x,_inst.y,global.current_sala);
			instance_destroy(_inst);
			desenha_botao = false;
			pegar = false;
		}
	}
}

// Manter o bloco de colisão na posição correta
if (instance_exists(global.bloco_colisao)) {
    global.bloco_colisao.x = x;
    global.bloco_colisao.y = y +30; // Ajuste 50 conforme necessário
}
}


if(mouse_check_button(mb_left)){
	if(global.armamento == Armamentos.espada){
	image_index = 0;
	switch dir{
	 default:
	 sprite_index = spr_player_direita_parado_atacando;
	 break;
	 case 1:
	 sprite_index = spr_player_cima_parado_atacando;
	 break;
	 case 2:
	 sprite_index = spr_player_esquerda_parado_atacando;
	 break;
	 case 3:
	 sprite_index = spr_player_baixo_parado_atacando;
	 break;
	}
	 state = scr_ataque_player_tuto;
 }else if (global.armamento == Armamentos.arco){
	 
	image_index = 0;
	state = scr_personagem_arco_tuto;
	}
}

if(mouse_check_button_pressed(mb_right)){
	
	alarm[11] = 10;
	dash_dir = point_direction(x, y, mouse_x, mouse_y);
	state = scr_personagem_dash_tuto;
}
}

function scr_personagem_dash_tuto(){
	global.estamina -= 3;
	andar = true;
	alarm[0] = 50;
	tomar_dano = false;
	hveloc = lengthdir_x(dash_veloc, dash_dir);
	vveloc = lengthdir_y(dash_veloc, dash_dir);
	
	x += hveloc;
	y += vveloc;
	
	var _inst = instance_create_layer(x, y, "instances", obj_rastro_player);
	_inst.sprite_index = sprite_index;
}

function scr_player_colisao_tuto(){
if (place_meeting(x + hveloc, y, obj_parede_invi) or place_meeting(x + hveloc, y, obj_par_cenario)) {
    while (!place_meeting(x + sign(hveloc), y, obj_parede_invi) && !place_meeting(x + sign(hveloc), y, obj_par_cenario)) {
        x += sign(hveloc);
    }
    hveloc = 0;
}

x += hveloc;

if (place_meeting(x, y + vveloc, obj_parede_invi) or place_meeting(x, y + vveloc, obj_par_cenario)) {
    while (!place_meeting(x, y + sign(vveloc), obj_parede_invi) && !place_meeting(x, y + sign(vveloc), obj_par_cenario)) {
        y += sign(vveloc);
    }
    vveloc = 0;
}

// Atualiza a posição do player

y += vveloc;


}

function scr_personagem_arco_tuto() {
    // Calcula a direção do mouse em relação ao jogador
    var direction_to_mouse = point_direction(x, y, mouse_x, mouse_y);
	var xx,yy;
	dir = floor((point_direction(x,y,mouse_x,mouse_y)+ 45)/90);
	switch dir{
	 default:
	 sprite_index = spr_player_direita_parado;
	 break;
	 case 1:
	 sprite_index = spr_player_cima_parado;
	 break;
	 case 2:
	 sprite_index = spr_player_esquerda_parado;
	 break;
	 case 3:
	 sprite_index = spr_player_baixo_parado;
	 break;
	}
    // Define o raio do círculo ao redor do jogador onde o arco será criado e posicionado
    var raio = 30; // Ajuste o valor conforme necessário

    // Verifica se o arco já foi criado
    if (!instance_exists(obj_arco)) {
        // Converte a direção para coordenadas polares (posição no círculo)
        var arco_x = x + lengthdir_x(raio, direction_to_mouse);
        var arco_y = y + lengthdir_y(raio, direction_to_mouse);

        // Cria o obj_arco na posição calculada
        var arco_inst = instance_create_layer(arco_x, arco_y, "Instances_itens", obj_arco);
        arco_inst.direction = direction_to_mouse;
        arco_inst.image_angle = direction_to_mouse;
    } else {
        // Se o arco já existe, atualiza sua posição e direção
        with (obj_arco) {
            // Atualiza a posição do arco para que ele se mova ao redor do jogador
            x = other.x + lengthdir_x(raio, direction_to_mouse);
            y = other.y+10 + lengthdir_y(raio, direction_to_mouse);
			xx = x;
			yy = y;
            // Atualiza a direção e o ângulo do arco para apontar para o mouse
            direction = point_direction(x, y, mouse_x, mouse_y);
            image_angle = direction+90;
			
			 // Verifica se a animação do arco terminou
            if (fim_animation(sprite_index, image_index, image_speed)) {
                image_index = 4;  // Define um frame específico da animação, se aplicável
            }
        }
    }

    // Permite que o jogador ande enquanto usa o arco
    scr_andando_tuto();  // Chama a função de movimento do jogador

    if (mouse_check_button_released(mb_left)) {
        if (obj_arco.image_index >= 4) {
            var _flecha = instance_create_layer(obj_arco.x, obj_arco.y, "Instances_itens", obj_flecha);
            with (_flecha) {
                direction = point_direction(x, y, mouse_x, mouse_y);
                speed = 15;
                image_angle = direction;
            }

            with (obj_arco) {
                instance_destroy();
            }

            empurrar_dir = point_direction(mouse_x, mouse_y, x, y);
            alarm[2] = 5;
            state = scr_personagem_hit_tuto;
        } else {
            with (obj_arco) {
                instance_destroy();
            }
            state = scr_andando_tuto;
        }
    }
}



function scr_ataque_player_tuto(){
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