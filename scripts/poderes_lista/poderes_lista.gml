function poderes(){
if (!variable_global_exists("lista_poderes")) {
    global.lista_poderes = ds_list_create();
    
    // Adicionar os objetos de poderes
	ds_list_set(global.lista_poderes, 0, obj_poder_correr);
	ds_list_set(global.lista_poderes, 1, obj_poder_dash);
	ds_list_set(global.lista_poderes, 2, obj_poder_mapa);

    // Adicione quantos objetos forem necessários
}
}

