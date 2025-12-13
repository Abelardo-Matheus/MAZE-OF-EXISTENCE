/// @desc Gerenciador de Mundo (Chunks, Inimigos e Terreno)
/// [O QUE]: Controla a geração procedural do mapa, o spawn contínuo de inimigos nas bordas, a renderização do chão infinito e ferramentas de debug.
/// [COMO] :
/// 1. Debug: Monitora clique do mouse para coordenadas.
/// 2. Level Up: Pausa a lógica de spawn se o menu de nível estiver aberto.
/// 3. Chunks: Verifica se o jogador cruzou a fronteira de um bloco (30k pixels). Se sim, gera novas estruturas.
/// 4. Inimigos: Se for noite e o timer zerar, cria inimigos fora da visão da câmera.
/// 5. Terreno: Cria tiles de grama ao redor do jogador e destrói os distantes para economizar memória.
// --- 6. Gerenciador de Ondas Noturnas ---

// --- 1. Inicialização de Segurança e Debug ---
// Garante que o contador de IDs de inimigos exista
if (!variable_global_exists("enemy_id_counter")) 
{
    global.enemy_id_counter = 0;
}

// Debug: Clique do Mouse
if (mouse_check_button_pressed(mb_left)) 
{
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    show_debug_message("Mouse clicado na posição GUI: x=" + string(_mx) + ", y=" + string(_my));
}

// --- 2. Pause de Level Up ---
if (global.level_up == true) 
{
    alarm[0]++; // Congela o timer de spawn
    exit;       // O código PARA aqui. Nada abaixo executa.
}

// Cheat: Level Up Manual com Enter
if (keyboard_check_pressed(vk_enter)) 
{
    level_up();
}



// --- 3. Sistema de Chunks (Geração de Estruturas) ---
// Calcula em qual "blocozão" do mundo o jogador está agora
var _chunk_x_atual = floor(obj_player.x / global.tamanho_bloco);
var _chunk_y_atual = floor(obj_player.y / global.tamanho_bloco);

// Só roda a geração se o jogador MUDOU de bloco (entrou em uma nova área)
if (_chunk_x_atual != global.ultimo_bloco[0] || _chunk_y_atual != global.ultimo_bloco[1]) 
{

    
    // Chama as funções de geração para o bloco atual e vizinhos
    gerar_estruturas(obj_estrutura, quantidade_estruturas, distancia_minima);
    gerar_estruturas(obj_poste, 5, 100);
    gerar_estruturas(obj_grupo_inimigos, 10, 100);
    gerar_estruturas(par_npc_vendedor_um, 10, 100);
    
    // Atualiza a memória para não rodar de novo no próximo frame
    global.ultimo_bloco[0] = _chunk_x_atual;
    global.ultimo_bloco[1] = _chunk_y_atual;
}



// --- 5. Geração Procedural de Terreno (Tiles) ---
var _tile_size = 272; 
var _grid_radius = 10; // Tamanho da área carregada ao redor do player
var _max_distance = (_grid_radius + 2) * _tile_size; // Distância para deletar tiles velhos

// Posição do jogador na grid de tiles
var _grid_x = floor(obj_player.x / _tile_size);
var _grid_y = floor(obj_player.y / _tile_size);

// Loop para criar tiles ao redor do jogador
for (var i = -_grid_radius; i <= _grid_radius; i++) 
{
    for (var j = -_grid_radius; j <= _grid_radius; j++) 
    {
        var _tile_x = (_grid_x + i) * _tile_size;
        var _tile_y = (_grid_y + j) * _tile_size;

        // Otimização: Só cria se não existir nada naquela posição exata
        if (!instance_position(_tile_x, _tile_y, obj_chao_grama_vamp)) 
        {
            var _new_tile = instance_create_layer(_tile_x, _tile_y, "chao", obj_chao_grama_vamp);
            
            // Randomiza rotação visual
            var _random_angle = choose(0, 90, 180, 270);
            _new_tile.image_angle = _random_angle;
            
            // Define variável de rotação física (se o objeto usar)
            if (variable_instance_exists(_new_tile, "rotation")) {
                _new_tile.rotation = _random_angle;
            }
        }
    }
}


// --- 6. Gerenciador de Ondas Noturnas ---
// Este script cuida de verificar se é noite, contar o tempo,
// mudar de onda e chamar o spawn quando o alarm[0] permitir.
process_night_waves();

// Limpeza de Memória (Culling)
// Destrói tiles que ficaram muito longe
with (obj_chao_grama_vamp) 
{
    if (point_distance(x, y, obj_player.x, obj_player.y) > _max_distance) 
    {
        instance_destroy();
    }
}