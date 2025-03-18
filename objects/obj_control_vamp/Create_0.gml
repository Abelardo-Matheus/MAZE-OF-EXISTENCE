spaw_timer = 10;
randomize();

// Variáveis de controle
estruturas_criadas = false; // Verifica se as estruturas já foram criadas
distancia_minima = 1000; // Distância mínima entre as estruturas
quantidade_estruturas = 20; // Quantidade máxima de estruturas por área
raio_geracao = 8000; // Raio ao redor do jogador onde as estruturas serão geradas

// Lista para salvar as posições das estruturas
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create();
}

// Se as posições já foram salvas, cria as estruturas nas posições salvas
if (ds_list_size(global.posicoes_estruturas) > 0) {
    for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i += 2) {
        var pos_x = global.posicoes_estruturas[| i];
        var pos_y = global.posicoes_estruturas[| i + 1];
        instance_create_depth(pos_x, pos_y, 0, obj_casa);
    }
    estruturas_criadas = true;
}