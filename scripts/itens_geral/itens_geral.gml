
function adicionar_item_invent(){
	///@arg Item
	///@arg Quantidade
	///@arg Sprite
	///@arg nome
	///@arg descricao
	///@arg sala_x
	///@arg sala_y
	///@arg pos_x
	///@arg pox_y
	var _grid = global.grid_itens;
	var _empty_slots = 0;
	
	for (var i = 0; i < ds_grid_height(_grid); i++) {
    if (_grid[# Infos.item, i] == -1) {
        _empty_slots++;
    }
}
	
	if (_empty_slots > 0) {
	var _grid = global.grid_itens;
	var _check = 0;
	while _grid[# Infos.item, _check] != -1{
	_check++;	
	}
	}else {
	 global.inventario_cheio = true; // esse variavel aqui ativa uma mensagem que indica q o inventario está cheio.
	 return;
}
	_grid[# 0, _check] = argument[0];
	_grid[# 1, _check] = argument[1];
	_grid[# 2, _check] = argument[2];
	_grid[# 3, _check] = argument[3];
	_grid[# 4, _check] = argument[4];
	_grid[# 5, _check] = argument[5];
	_grid[# 6, _check] = argument[6];
	_grid[# 7, _check] = argument[7];
	_grid[# 8, _check] = argument[8];
}

