// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_textos(){
	switch npc_nome{
		case "BV":
		texto_1 = "Olá quem é voçe?";
		 ds_grid_add_text(texto_1, spr_retrato1_player, 0 , "Voçe");
		 texto_2 = "Opa voçe esta aqui, prazer!";
		 ds_grid_add_text(texto_2, spr_retrato1_fada, 1 , "Fada");
		 texto_3 = "Prazer mas porque o espanto?";
		 ds_grid_add_text(texto_3, spr_retrato3_player, 0 , "Voçe");
		 texto_4 = "Porque voçe atingiu sua consciencia e está me vendo!";
		 ds_grid_add_text(texto_4, spr_retrato2_fada, 1 , "Fada");
		 texto_5 = "Como assim te vendo, eu não sou cego";
		 ds_grid_add_text(texto_5, spr_retrato3_player, 0 , "Voçe");
		 texto_6 = "Sim eu sei, mas antes voçe não tinha consciencia da propria vida, aprendeu a falar e andar agora pode viver!!";
		 ds_grid_add_text(texto_6, spr_retrato1_fada, 1 , "Fada");
		 
		break;
		
		
	}
}
function ds_grid_add_text(){
	///@arg texto
	///@arg retrato
	///@arg lado
	///@arg nome
 
	var _grid = texto_grid;
	var _y = ds_grid_add_row(_grid);
 
	_grid[# 0, _y] = argument[0];
	_grid[# 1, _y] = argument[1];
	_grid[# 2, _y] = argument[2];
	_grid[# 3, _y] = argument[3];
}