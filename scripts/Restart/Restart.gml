/// @desc Reseta e recria a fase inteira baseado no nível atual.
/// [O QUE]: Incrementa o nível, limpa estruturas antigas, gera novo labirinto procedural e popula com objetos/inimigos.
function reset_level_data() 
{
    randomize();
    global.level_fase++; // Incrementa nível

    global.templo_criado = false;
    // --- 1. Limpeza de Dados Antigos ---
    reset_global_variables();
    // Destrói grids do labirinto
    if (ds_exists(global._maze, ds_type_grid)) ds_grid_destroy(global._maze);
    if (ds_exists(global.visited, ds_type_grid)) ds_grid_destroy(global.visited);

    // Reinicia configurações de sala (chama a função 'salas()' original)
    // Sugestão: Renomeie 'salas()' para 'scr_init_room_settings()' se possível
    salas(); 
    
    // Recria as grids principais
    // Nota: width/height devem estar definidos globalmente
    global._maze = ds_grid_create(global._maze_width + 2, global._maze_height + 2);
    global.visited = ds_grid_create(global._maze_width + 2, global._maze_height + 2);

    // --- 2. Geração Procedural ---
    
    // Gera layout das salas
    global.salas_geradas = gera_salas_procedurais(global.total_rooms);

    // Popula a lista de salas criadas
    // Limpa a lista antiga antes de adicionar novas
    global.salas_criadas = []; 
    
    var _total_rooms = array_length(global.salas_geradas);
    for (var i = 0; i < _total_rooms; i++) 
    {
        var _room_info = criar_salas_lista(global.salas_geradas[i], i + 1);
        array_push(global.salas_criadas, _room_info);
    }

    // --- 3. População de Objetos e Inimigos ---
    
    // Gera inimigos e itens baseados na dificuldade do nível
    gerar_inimigos_e_itens_para_o_nivel(global.salas_geradas, global.level_fase);
    
    // Móveis e Decoração
    furniture_generate_positions(global.salas_geradas, global.salas_com_escrivaninha, 3)
    furniture_generate_positions(global.salas_geradas, global.salas_com_geladeira, 1, "cozinha");
    furniture_generate_positions(global.salas_geradas, global.salas_com_guarda_roupa, 1, "quarto");
    create_escada_porao_em_fundos(global.salas_geradas);
    
    // Pontos de interesse
    create_pontos_em_salas_aleatorias(global.salas_geradas, 10, 5); 
    
    // Estruturas Especiais (Templos, Jardins, Escuridão)
    criar_templo_e_jardim(global.current_sala, global.salas_geradas);
    criar_salas_escuras(global.current_sala, global.salas_geradas, 3);
    
    // Inimigos Especiais
    create_inimigos_em_salas_escuras(2);
    
    // --- 4. Finalização ---
    
    // Carrega a sala inicial
    carregar_sala(global.current_sala, global.current_sala);
    
    // Prepara sala de tutorial (se necessário)
    sala_tuto();
    
    // Reseta Minimapa
    global.minimap = [];
    for (var i = 0; i < _total_rooms; i++) 
    {
        global.minimap[i] = c_white; // Todas as salas começam inexploradas/brancas
    }
}

/// @desc Reseta todas as variáveis globais e limpa mapas de spawn.
/// [O QUE]: Limpa todos os DS Maps e Listas usados para controlar o spawn de objetos nas salas.
function reset_global_variables() 
{
    global.current_sala = [0, 0];
    
    // Chama função auxiliar de limpar salas (se existir)
    resetar_salas(); 
    
    // --- Limpeza de DS Maps ---
    // Helper function para limpar ou criar mapas (reduz repetição de código)
    var _reset_map = function(_map_id) 
    {
        if (ds_exists(_map_id, ds_type_map)) {
            ds_map_clear(_map_id);
            return _map_id;
        } else {
            return ds_map_create();
        }
    };

    global.salas_com_amoeba       = _reset_map(global.salas_com_amoeba);
    global.salas_com_inimigos     = _reset_map(global.salas_com_inimigos);
    global.salas_com_geladeira    = _reset_map(global.salas_com_geladeira);
    global.salas_com_guarda_roupa = _reset_map(global.salas_com_guarda_roupa);
    global.sala_com_item_drop     = _reset_map(global.sala_com_item_drop);
    global.salas_com_vela         = _reset_map(global.salas_com_vela);
    global.salas_com_escrivaninha = _reset_map(global.salas_com_escrivaninha);
    global.salas_com_escada_porao = _reset_map(global.salas_com_escada_porao);
    global.salas_com_pontos       = _reset_map(global.salas_com_pontos);
    global.salas_com_torretas     = _reset_map(global.salas_com_torretas);
    global.salas_com_slow         = _reset_map(global.salas_com_slow);
    global.salas_com_paredes      = _reset_map(global.salas_com_paredes);
    global.salas_com_fantasma     = _reset_map(global.salas_com_fantasma);

    // --- Limpeza de DS Lists ---
    if (ds_exists(global.room_positions, ds_type_list)) {
        ds_list_clear(global.room_positions);
    } else {
        global.room_positions = ds_list_create();
    }

    // --- Limpeza de Arrays ---
    global.salas_geradas = [];
    global.templos_salas_pos = [];
    global.salas_escuras = [];

    // --- Reset de Flags ---
    global.templo_criado = false;
    global.inimigo_id_count = 0; 
}