// ============================================================================
// SCRIPT: scr_gerador_mundo
// DESCRIÇÃO: Gerencia a criação procedural de estruturas (Chunks) e o chão infinito.
// ============================================================================

/// @desc Inicializa as variáveis necessárias para o gerador (Chame no Create do seu Controlador)
function inicializar_gerador_mundo() 
{
    if (!variable_global_exists("ultimo_bloco")) {
        global.ultimo_bloco = [999999, 999999]; // Para as Estruturas/Chunks
    }
    
    // --- NOVO: Memória para o chão não causar lag ---
    if (!variable_global_exists("ultimo_tile")) {
        global.ultimo_tile = [999999, 999999]; // Para o Chão Infinito
    }
}


/// @desc Roda a lógica de geração de mundo (Chame no STEP do Player ou Controlador)
function gerenciar_mundo_procedural() 
{
    // Segurança: Só roda se o player existir
    if (!instance_exists(obj_player)) return;

    // ========================================================
    // 1. SISTEMA DE CHUNKS (Estruturas, Inimigos, Boss, NPCs)
    // ========================================================
    var _chunk_x_atual = floor(obj_player.x / global.tamanho_bloco);
    var _chunk_y_atual = floor(obj_player.y / global.tamanho_bloco);

    // Só roda a geração se o jogador MUDOU de bloco (entrou em uma nova área)
    if (_chunk_x_atual != global.ultimo_bloco[0] || _chunk_y_atual != global.ultimo_bloco[1]) 
    {
        // Chama as funções de geração para o bloco atual e vizinhos
        // DICA: Ajuste a quantidade conforme necessário para balancear
        gerar_estruturas(obj_estrutura, 10, 100);
        gerar_estruturas(obj_poste, 5, 100);
        gerar_estruturas(obj_secondary_boss, 2, 100); // Boss reduzido para não lotar o mapa
        gerar_estruturas(obj_grupo_inimigos, 10, 100);
        gerar_estruturas(par_npc_vendedor_um, 2, 100);
        
        // Atualiza a memória
        global.ultimo_bloco[0] = _chunk_x_atual;
        global.ultimo_bloco[1] = _chunk_y_atual;
    }

 //// --- 2. SISTEMA DE CHÃO INFINITO COM CULLING ---
    
 //   // 1. Defina a escala que você quer (0.5 = metade do tamanho, 0.25 = um quarto, etc)
 //   var _escala_chao = 2; 
    
 //   // 2. O script calcula o novo tamanho exato da grade automaticamente (2048 * 0.5 = 1024)
 //   var _tile_size = 24 * _escala_chao; 
    
 //   var _grid_radius = 30; 
 //   var _max_distance = (_grid_radius + 2) * _tile_size; 

 //   var _grid_x = floor(obj_player.x / _tile_size);
 //   var _grid_y = floor(obj_player.y / _tile_size);

 //   // Cria o chão em volta
 //   if (_grid_x != global.ultimo_tile[0] || _grid_y != global.ultimo_tile[1]) 
 //   {
 //       for (var i = -_grid_radius; i <= _grid_radius; i++) 
 //       {
 //           for (var j = -_grid_radius; j <= _grid_radius; j++) 
 //           {
 //               var _pos_x = (_grid_x + i) * _tile_size;
 //               var _pos_y = (_grid_y + j) * _tile_size;

 //              // Se não tem grama aqui, ele cria o objeto
 //               if (!instance_position(_pos_x, _pos_y, obj_chao_grama_vamp)) 
 //               {
 //                   var _chao = instance_create_layer(_pos_x, _pos_y, "chao", obj_chao_grama_vamp);
                    
 //                   // Sorteia se vai virar horizontalmente e verticalmente (1 = normal, -1 = virado)
 //                   var _virar_x = choose(1, -1);
 //                   var _virar_y = choose(1, -1);
                    
 //                   // Aplica a sua escala multiplicada pelo sorteio!
 //                   _chao.image_xscale = _escala_chao * _virar_x;
 //                   _chao.image_yscale = _escala_chao ;
 //               }
 //           }
 //       }
        
 //       global.ultimo_tile[0] = _grid_x;
 //       global.ultimo_tile[1] = _grid_y;
 //   }

 //   // Faz desaparecer caso vá muito longe!
 //   with (obj_chao_grama_vamp) 
 //   {
 //       if (point_distance(x, y, obj_player.x, obj_player.y) > _max_distance) 
 //       {
 //           instance_destroy();
 //       }
 //   }
}