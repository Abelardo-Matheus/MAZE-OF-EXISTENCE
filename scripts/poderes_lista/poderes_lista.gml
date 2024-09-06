

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


