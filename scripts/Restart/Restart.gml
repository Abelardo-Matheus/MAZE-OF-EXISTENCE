// feather disable GM2017
/// @desc Reseta e recria a fase inteira baseado no nível atual.
/// [O QUE]: Incrementa o nível, limpa estruturas antigas, gera novo labirinto procedural e popula com objetos/inimigos.
function reset_level_data() 
{
    // Cada casa do mundo tem sua seed (obj_estrutura): mesma seed = mesma casa
    var _seed = (variable_global_exists("seed_atual") && global.seed_atual != noone) ? real(global.seed_atual) : noone;
    if (_seed != noone) random_set_seed(_seed); else randomize();
    global.level_fase++; // Incrementa nível

    global.templo_criado = false;
    // --- 1. Limpeza de Dados Antigos ---
    reset_global_variables();
    // Destrói grids do labirinto
    if (ds_exists(global._maze, ds_type_grid)) ds_grid_destroy(global._maze);
    if (ds_exists(global.visited, ds_type_grid)) ds_grid_destroy(global.visited);

    // Tipos e formatos de sala (spr_fase_criation -> SISTEMA DE SALAS)
    salas(); 
    
    // Recria as grids principais
    // Nota: width/height devem estar definidos globalmente
    global._maze = ds_grid_create(global._maze_width + 2, global._maze_height + 2);
    global.visited = ds_grid_create(global._maze_width + 2, global._maze_height + 2);

    // --- Casa já visitada? Restaura tudo como estava (cômodos, formatos, móveis, escada...) ---
    if (casa_restaurar(_seed)) {
        carregar_sala(global.current_sala, global.current_sala);
        return;
    }

    // --- 2. Geração Procedural ---
    
    // Gera layout das salas
    global.salas_geradas = gera_salas_procedurais(global.total_rooms);

    // Popula a lista de salas criadas
    // Limpa a lista antiga antes de adicionar novas
    global.salas_criadas = []; 
    
    var _total_rooms = array_length(global.salas_geradas);
    for (var _i = 0; _i < _total_rooms; _i++) 
    {
        var _room_info = criar_salas_lista(global.salas_geradas[_i], _i + 1);
        array_push(global.salas_criadas, _room_info);
    }

    // Cômodos da casa (sem templo/jardim/escuras) para inimigos comuns
    var _salas_casa = [];
    array_copy(_salas_casa, 0, global.salas_geradas, 0, array_length(global.salas_geradas));

    // --- 3. Estruturas Especiais (antes dos layouts: templo/jardim viram vizinhos e ganham porta) ---
    criar_templo_e_jardim(global.current_sala, global.salas_geradas);
    criar_salas_escuras(global.current_sala, global.salas_geradas, 3);

    // --- 4. Formato de cada cômodo (spr_fase_criation): gerado uma vez e salvo em global.salas_layout ---
    if (_seed != noone) random_set_seed(_seed + 1);
    sala_gerar_todos_layouts();

    // --- 5. População de Objetos e Inimigos (usam o formato para não nascer fora da casa) ---
    gerar_inimigos_e_itens_para_o_nivel(_salas_casa, global.level_fase);

    // Mobília e escada com seed própria (inimigos criados acima chamam randomize() no Create)
    if (_seed != noone) random_set_seed(_seed + 2);
    // Escada fundos <-> porão primeiro (a mobília desvia dela)
    create_escada_porao_em_fundos(global.salas_geradas);
    // Mobília organizada por cômodo (scr_casa_moveis), respeitando o formato da sala
    casa_gerar_moveis(global.salas_geradas);

    // Inimigos Especiais
    create_inimigos_em_salas_escuras(2);
    
    // --- 6. Finalização ---
    
    // Carrega a sala inicial
    carregar_sala(global.current_sala, global.current_sala);
    

    
    // Reseta Minimapa
    global.minimap = [];
    for (var _i = 0; _i < _total_rooms; _i++) 
    {
        global.minimap[_i] = c_white; // Todas as salas começam inexploradas/brancas
    }

    // Guarda a casa: a próxima visita (mesma seed) restaura tudo igual
    casa_salvar(_seed);
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
    // Mapas de uma casa salva não podem ser limpos (são o save dela): casa_novo_mapa cria outro
    var _reset_map = function(_map_id) 
    {
        return casa_novo_mapa(_map_id);
    };

    global.salas_com_amoeba       = _reset_map(global.salas_com_amoeba);
    global.salas_com_inimigos     = _reset_map(global.salas_com_inimigos);
    global.salas_com_geladeira    = _reset_map(global.salas_com_geladeira);
    global.salas_com_guarda_roupa = _reset_map(global.salas_com_guarda_roupa);
    global.sala_com_item_drop     = _reset_map(global.sala_com_item_drop);
    global.sala_com_bau           = _reset_map(global.sala_com_bau);
    global.colocando_bau          = { ativo: false };
    global.bau_aberto             = noone;
    global.salas_com_vela         = _reset_map(global.salas_com_vela);
    global.salas_com_escrivaninha = _reset_map(global.salas_com_escrivaninha);
    global.salas_com_escada_porao = _reset_map(global.salas_com_escada_porao);
    global.salas_com_pontos       = _reset_map(global.salas_com_pontos);
    global.salas_com_torretas     = _reset_map(global.salas_com_torretas);
    global.salas_com_slow         = _reset_map(global.salas_com_slow);
    global.salas_com_paredes      = _reset_map(global.salas_com_paredes);
    global.salas_com_fantasma     = _reset_map(global.salas_com_fantasma);
    global.salas_com_moveis       = _reset_map(variable_global_exists("salas_com_moveis") ? global.salas_com_moveis : -1);

    // --- Limpeza de DS Lists ---
    if (ds_exists(global.room_positions, ds_type_list)) {
        ds_list_clear(global.room_positions);
    } else {
        global.room_positions = ds_list_create();
    }

    // --- Limpeza de Arrays ---
    global.salas_geradas = [];
    global.templos_salas_pos = [];
    global.sala_jardim = [];
    global.templo_poder = -1;   // poder do templo é sorteado de novo a cada fase
    global.salas_escuras = [];
    global.salas_layout = {};   // formatos salvos das salas (spr_fase_criation)

    // --- Reset de Flags ---
    global.templo_criado = false;
    global.inimigo_id_count = 0; 
}
