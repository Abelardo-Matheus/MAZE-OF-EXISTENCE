
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

esquerda = keyboard_check(ord("A"));
direita = keyboard_check(ord("D"));
cima = keyboard_check(ord("W"));
baixo = keyboard_check(ord("S"));

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



hveloc = (direita - esquerda) * current_speed;
if(place_meeting(x + hveloc, y, global.sala.parede)){
	while !place_meeting(x + sign(hveloc),y,global.sala.parede){
		x += sign(hveloc);
	}
	hveloc = 0;
}
x += hveloc;
vveloc = (baixo - cima) * current_speed;
if(place_meeting(x , y + vveloc, global.sala.parede)){
	while !place_meeting(x ,y + sign(vveloc),global.sala.parede){
		y += sign(vveloc);
	}
	vveloc = 0;
}
// Atualiza a posição do player

y += vveloc;

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
	if(distance_to_point(_inst.x,_inst.y)<= 100){
		if(keyboard_check_pressed(ord("F"))){
			adicionar_item_invent(_inst.image_index,_inst.quantidade,_inst.sprite_index,_inst.nome,_inst.descricao,0,0,0,0,_inst.dano,_inst.armadura,_inst.velocidade,_inst.cura,_inst.tipo,_inst.ind);
			coletar_item(_inst.x,_inst.y,global.current_sala);
			instance_destroy(_inst);
		}
	}
}

// Manter o bloco de colisão na posição correta
if (instance_exists(global.bloco_colisao)) {
    global.bloco_colisao.x = x;
    global.bloco_colisao.y = y +30; // Ajuste 50 conforme necessário
}

