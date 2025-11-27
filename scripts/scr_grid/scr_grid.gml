function ds_grid_add_row(){
	///@arg ds_grid
 
	var _grid = argument[0];
	ds_grid_resize(_grid,ds_grid_width(_grid),ds_grid_height(_grid)+1);
	return(ds_grid_height(_grid)-1);	
}

function ds_grid_add_text(){
	///@arg _text_string
	///@arg _portrait
	///@arg _side
	///@arg _name
	///@arg op
	
	var _grid = text_grid;
	var _y = ds_grid_add_row(_grid);

	// Verifica se o texto é vazio e se há opções disponíveis
	if (argument[0] == "" && op_num > 0) {
		// Ativa a exibição das opções diretamente
		op_draw = true;
	} else {
		// Caso contrário, adiciona o texto normalmente ao grid
		_grid[# 0, _y] = argument[0];
		_grid[# 1, _y] = argument[1];
		_grid[# 2, _y] = argument[2];
		_grid[# 3, _y] = argument[3];
		_grid[# 4, _y] = argument[4];
	}
}
