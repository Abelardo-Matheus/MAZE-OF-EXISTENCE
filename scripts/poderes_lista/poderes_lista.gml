

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


enum Upgrades{
	Name,
	Script,
	frequency,
	description,
	Length
}


global.upgrades_grid = ds_grid_create(Upgrades.Length, 0);
ds_grid_add_upgrade("BOLA",			-1, -1, "Joga uma bola que persegue o inimigo mais próximo."); // Linha 0
ds_grid_add_upgrade("PENA",			-1, -1, "Deixa o jogador mais rápido, como se estivesse flutuando."); // Linha 1
ds_grid_add_upgrade("IMÃ",			-1, -1, "Coleta recursos e itens de mais longe, como se fosse mágica."); // Linha 2
ds_grid_add_upgrade("ESTRELA",		-1, -1, "Emite uma energia pulsante que repele os inimigos ao redor."); // Linha 3
ds_grid_add_upgrade("SHURIKEN",		-1, -1, "Fica girando ao redor do jogador, causando dano aos inimigos."); // Linha 4
ds_grid_add_upgrade("SAPO",			-1, -1, "Um pet sapo que engole inimigos aleatórios próximos."); // Linha 5
ds_grid_add_upgrade("BULMERANGUE",	-1, -1, "Arremessa um bumerangue que vai e volta, atingindo os inimigos."); // Linha 6
ds_grid_add_upgrade("ORBE",			-1, -1, "Um orbe especial que explode em confetes quando atinge os inimigos."); // Linha 7
ds_grid_add_upgrade("BORBOLETA",	-1, -1, "Uma borboleta mágica que distrai os inimigos por um curto período."); // Linha 8
ds_grid_add_upgrade("BOLHAS",		-1, -1, "Uma chuva de bolhas que estoura ao encostar nos inimigos."); // Linha 9
ds_grid_add_upgrade("USRO",			-1, -1, "Cria um ursinho de pelúcia gigante que bloqueia os inimigos por alguns segundos."); // Linha 10



function ds_grid_add_upgrade(_name, _script, _frequency, _description){
	var _grid = upgrades_grid;
	var _y = ds_grid_add_row(_grid);
 
	_grid[# 0, _y] = _name;
	_grid[# 1, _y] = _script;
	_grid[# 2, _y] = _frequency;
	_grid[# 3, _y] = _description;
}