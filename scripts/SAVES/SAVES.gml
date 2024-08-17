// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function salvar_recorde(recorde_atualizado){
	ini_open("Savegame.ini");
	
	ini_write_real("Player", "Recorde",recorde_atualizado);
	
	ini_close();
}

function ler_recorde(){
	var recorde_salvo = 0;
	
	if(file_exists("Savegame.ini")){
		ini_open("Savegame.ini");
		
		recorde_salvo = ini_read_real("Player", "Recorde", 0);
		
		ini_close();
		
	}
	
	return recorde_salvo;
}