function scr_amoeba_check_player(){
	if(distance_to_object(obj_player) <= dist_aggro){
		state = scr_amoeba_perseguir;
	}
}
function scr_amoeba_hit(){
	alarm[2] = 180;
	empurrar_veloc = lerp(empurrar_veloc,0,0.05);
	hveloc = lengthdir_x(empurrar_veloc,empurrar_dir);
	vveloc = lengthdir_y(empurrar_veloc,empurrar_dir);
	
	scr_amoeba_colisao();
}
function scr_amoeba_perseguir(){
	sprite_index = sprite_normal;
	image_speed = 1.5;
	dest_x = obj_player.x;
	dest_y = obj_player.y;
	
	var _dir = point_direction(x, y, dest_x, dest_y);
	
	hveloc = lengthdir_x(veloc_perse, _dir);
	vveloc = lengthdir_y(veloc_perse, _dir);
	
	scr_amoeba_colisao();
	
	if(distance_to_object(obj_player) >= dist_desaggro){
		state = scr_escolher_state_amoeba;
		alarm[0] = irandom_range(120,240);
	}
	
}

function scr_amoeba_colisao(){
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
function scr_escolher_state_amoeba(){
	scr_amoeba_check_player();
	prox_state = choose(scr_amoeba_andar,scr_amoeba_parada);
	
	if(prox_state = scr_amoeba_andar){
		state = scr_amoeba_andar;
		dest_x = irandom_range(0,room_width);
		dest_y = irandom_range(0,room_height);
	}else if(prox_state = scr_amoeba_parada){
		state = scr_amoeba_parada;
	}
}

function scr_amoeba_andar(){
	scr_amoeba_check_player();
	sprite_index = sprite_normal;
	
	
	if(distance_to_point(dest_x,dest_y) > veloc){
	var _dir = point_direction(x,y, dest_x, dest_y);
	hveloc = lengthdir_x(veloc, _dir);
	vveloc = lengthdir_y(veloc, _dir);

	scr_amoeba_colisao();
	
	}else{
		x = dest_x;
		y = dest_y;
	}
}

function scr_amoeba_parada(){
	scr_amoeba_check_player();
	sprite_index = sprite_parado;
}