/// @description Insert description here
// You can write your code in this editor

global.xp++;
global.speed_sperm+=0.2;
if(global.xp > global.recorde){
	global.recorde = global.xp;
	salvar_recorde(global.recorde);
}


  coletar_ponto(x, y, global.current_sala); // Passa as coordenadas e a sala atual para a função de coleta














