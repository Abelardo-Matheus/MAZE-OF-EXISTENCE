function scr_torreta_check_player(){
	if(distance_to_object(obj_player) <= dist_aggro){
		state = scr_amoeba_perseguir;
	}
}
function scr_torreta_hit(){
		alarm[2] = 180;
	empurrar_veloc = lerp(empurrar_veloc,0,0.05);
	hveloc = lengthdir_x(empurrar_veloc,empurrar_dir);
	vveloc = lengthdir_y(empurrar_veloc,empurrar_dir);
	
	scr_amoeba_colisao();
}


function scr_torreta_colisao(){
if(place_meeting(x + hveloc, y, global.sala.parede)){
	while !place_meeting(x + sign(hveloc),y,global.sala.parede){
		x += sign(hveloc);
	}
	hveloc = 0;
}


if(place_meeting(x , y + vveloc, global.sala.parede)){
	while !place_meeting(x ,y + sign(vveloc),global.sala.parede){
		y += sign(vveloc);
	}
	vveloc = 0;
}
// Atualiza a posição do player


}

function atirar_torreta(){
	
    // Obtém a posição do obj_sperm
    var alvo_x = obj_player.x;
    var alvo_y = obj_player.y;
    
    // Direção do inimigo para o obj_sperm
    var direcao = point_direction(x, y, alvo_x, alvo_y);
    
  
    image_angle = direcao -180;  // Subtrai 90 graus para alinhar o "frente" do retângulo corretamente




if(tiro == true){
var tiros = instance_create_layer(x,y,"instances",obj_tiro);
with(tiros){
	direction =  direcao ;
}
tiro = false;
}




}

function scr_torreta_parada(){
	if(alarm[2] == 0){
		state = atirar_torreta;
	}
	
}