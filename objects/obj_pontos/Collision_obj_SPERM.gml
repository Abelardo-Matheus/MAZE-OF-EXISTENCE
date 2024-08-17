/// @description Insert description here
// You can write your code in this editor

global.pontos++;
if(global.pontos > global.recorde){
	global.recorde = global.pontos;
	salvar_recorde(global.recorde);
}


  coletar_ponto(x, y, global.current_sala); // Passa as coordenadas e a sala atual para a função de coleta














