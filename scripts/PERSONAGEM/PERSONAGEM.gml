function scr_andando(){
	
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

if (andar = false){
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

if (keyboard_check(vk_shift) && global.estamina > 0) {
    var speed_corrida = current_speed + 10; // ou qualquer valor extra de velocidade
    hveloc = lengthdir_x(speed_corrida, veloc_dir);
    vveloc = lengthdir_y(speed_corrida, veloc_dir);
    
    //global.estamina -= 0.4; // consome estamina (opcional)
    
} else {
    hveloc = lengthdir_x(current_speed, veloc_dir);
    vveloc = lengthdir_y(current_speed, veloc_dir);
}

	

scr_player_colisao();
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




if(instance_exists(obj_item)and obj_invetario.inventario = false and !global.inventario_cheio){
	var _inst = instance_nearest(x,y,obj_item);
	if(distance_to_point(_inst.x,_inst.y)<= 180){
		desenha_botao = true;
		if(keyboard_check_pressed(ord("F"))and pegar = true){
			adicionar_item_invent(_inst.image_index,_inst.quantidade,_inst.sprite_index,_inst.nome,_inst.descricao,0,0,0,0,_inst.dano,_inst.armadura,_inst.velocidade,_inst.cura,_inst.tipo,_inst.ind,_inst.preco);
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
	 state = scr_ataque_player;
 }else if (global.armamento == Armamentos.arco){
	 
	image_index = 0;
	state = scr_personagem_arco;
	}
}

if(mouse_check_button_pressed(mb_right)){
	
	alarm[11] = 10;
	dash_dir = point_direction(x, y, mouse_x, mouse_y);
	state = scr_personagem_dash;
}
}

function scr_personagem_dash(){
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

function scr_player_colisao(){
if(place_meeting(x + hveloc, y, global.sala.parede)){
	while !place_meeting(x + sign(hveloc),y,global.sala.parede){
		x += sign(hveloc);
	}
	hveloc = 0;
}
x += hveloc;

if(place_meeting(x , y + vveloc, global.sala.parede)){
	while !place_meeting(x ,y + sign(vveloc),global.sala.parede){
		y += sign(vveloc);
	}
	vveloc = 0;
}

y += vveloc;
}

function scr_personagem_arco() {
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
    scr_andando();  // Chama a função de movimento do jogador

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
            state = scr_personagem_hit;
        } else {
            with (obj_arco) {
                instance_destroy();
            }
            state = scr_andando;
        }
    }
}



function scr_ataque_player(){

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
		state = scr_andando;
		atacando = false;
	}
	
}
	
function scr_personagem_hit(){
	if(alarm[2] > 0 ){
	
	hveloc = lengthdir_x(8,empurrar_dir);
	vveloc = lengthdir_y(8,empurrar_dir);

	scr_player_colisao();
	}else{
		state = scr_andando;
		hit = false;
	}
	
	
}
