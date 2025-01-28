

function scr_andando_vamp(){
	
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




}

function scr_personagem_dash_vamp(){
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

function scr_player_colisao_vamp(){
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
// Atualiza a posição do player

y += vveloc;
}



	
function scr_personagem_hit_vamp(){
	if(alarm[2] > 0 ){
	
	hveloc = lengthdir_x(8,empurrar_dir);
	vveloc = lengthdir_y(8,empurrar_dir);

	scr_player_colisao_vamp();
	}else{
		state = scr_andando_vamp;
		hit = false;
	}
	
	
}