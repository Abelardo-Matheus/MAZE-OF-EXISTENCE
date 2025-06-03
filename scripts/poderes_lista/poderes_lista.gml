

function criar_poder(nome, nivel, dano, coletado,ID,objeto) {
    return {
		
        poder_nome: nome,
        poder_nivel: nivel,
        dano: dano,
        coletado: coletado, // Variável que indica se foi coletado ou não
		ID : ID,
		objeto : objeto
    };
	
}
// Criando uma lista de poderes com a variável 'coletado'
if (!variable_global_exists("lista_poderes_basicos")) {
    global.lista_poderes_basicos = ds_list_create();
	
    
    // Adicionar os poderes à lista
    var poder_correr = criar_poder("correr", 1, 0, false,0,obj_poder_correr);
    var poder_dash = criar_poder("dash", 1, 0, false,1,obj_poder_dash);
	var poder_mapa = criar_poder("mapa", 1, 0, false,2,obj_poder_mapa);
	var poder_lanterna = criar_poder("lanterna", 1, 0, false,3,obj_poder_lanterna);
    
    
    ds_list_add(global.lista_poderes_basicos, poder_correr);
    ds_list_add(global.lista_poderes_basicos, poder_dash);
	ds_list_add(global.lista_poderes_basicos, poder_mapa);
	ds_list_add(global.lista_poderes_basicos, poder_lanterna);

	
}

function procurar_poder(id_procurado){
	for (var i = 0; i < ds_list_size(global.lista_poderes_basicos); i++) {
    var poder = ds_list_find_value(global.lista_poderes_basicos, i);
    
    // Verificar se o ID do poder corresponde ao ID procurado
    if (poder.ID == id_procurado) {
        objeto_escolhido = poder;
        break;
    }
}

return objeto_escolhido;
	
}

enum Itens_vamp{
	Name,
	Script,
	frequency,
	description,
	level,
	Length
}

enum Upgrades_vamp{
	Name,
	Script,
	frequency,
	description,
	level,
	Length
}

global.itens_vamp_grid = ds_grid_create(Itens_vamp.Length, 0);
ds_grid_add_item_vamp("PENA",			scr_pena, -1, "Deixa o jogador mais rápido, como se estivesse flutuando.",0); // Linha 1
ds_grid_add_item_vamp("IMÃ",			-1, -1, "Coleta recursos e itens de mais longe, como se fosse mágica.",0); // Linha 2

global.upgrades_vamp_grid = ds_grid_create(Upgrades_vamp.Length, 0);
ds_grid_add_upgrade_vamp("BOLA",			scr_bola, -1, "Joga uma bola que persegue o inimigo mais próximo.",0); // Linha 0
ds_grid_add_upgrade_vamp("EXPLOSÃO",		scr_explosao, -1, "Emite uma energia pulsante que repele os inimigos ao redor.",0); // Linha 1
ds_grid_add_upgrade_vamp("SHURIKEN",		scr_shuriken, -1, "Fica girando ao redor do jogador, causando dano aos inimigos.", 0); // Linha 2

ds_grid_add_upgrade_vamp("BULMERANGUE",	scr_bumerangue, -1, "Arremessa um bumerangue que vai e volta, atingindo os inimigos.",0); // Linha 3
ds_grid_add_upgrade_vamp("ORBE",			-1, -1, "Um orbe especial que explode em confetes quando atinge os inimigos.",0); // Linha 4

ds_grid_add_upgrade_vamp("BOLHAS",		-1, -1, "Uma chuva de bolhas que estoura ao encostar nos inimigos.",0); // Linha 5
ds_grid_add_upgrade_vamp("RAIO",			scr_raio, -1, "Cria um ursinho de pelúcia gigante que bloqueia os inimigos por alguns segundos.",0); // Linha 6

ds_grid_add_upgrade_vamp("SAPO",			scr_sapo, -1, "Um pet sapo que engole inimigos aleatórios próximos.",100); // Linha 7
ds_grid_add_upgrade_vamp("BORBOLETA",	-1, -1, "Uma borboleta mágica que distrai os inimigos por um curto período.",0); // Linha 8



function ds_grid_add_upgrade_vamp(_name, _script, _frequency, _description, _level){
	var _grid = global.upgrades_vamp_grid;
	var _y = ds_grid_add_row(_grid);
 
	_grid[# 0, _y] = _name;
	_grid[# 1, _y] = _script;
	_grid[# 2, _y] = _frequency;
	_grid[# 3, _y] = _description;
	_grid[# 4, _y] = _level;
}

function ds_grid_add_item_vamp(_name, _script, _frequency, _description, _level){
	var _grid = global.itens_vamp_grid;
	var _y = ds_grid_add_row(_grid);
 
	_grid[# 0, _y] = _name;
	_grid[# 1, _y] = _script;
	_grid[# 2, _y] = _frequency;
	_grid[# 3, _y] = _description;
	_grid[# 4, _y] = _level;
}