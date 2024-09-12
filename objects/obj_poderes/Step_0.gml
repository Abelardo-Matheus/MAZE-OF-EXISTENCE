if(poder_correr){
	obj_player.current_speed += 15;
}

if(poder_dash){
global.dash_habilitado = true;
global.speed_dash = 20;  // Velocidade do dash
global.dash_tempo_recarga = 60*4; // Tempo de recarga do dash (2 segundos, se o jogo estiver a 60 FPS)
global.frames = 20;
global.dash_em_recarga = false;  // Indica se o dash está em recarga
global.in_dash = false;

}
if(poder_lanterna){
	
	
}

if(poder_mapa){
	global.map = true;
}







