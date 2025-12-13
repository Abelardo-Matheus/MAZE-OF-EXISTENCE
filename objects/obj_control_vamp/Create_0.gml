/// @desc Configuração do Mapa e Geração Procedural
/// [O QUE]: Define o tipo de bioma (Vamp/Bebe), configura parâmetros de spawn de estruturas e reposiciona o player ao retornar de uma sub-área.
/// [COMO] : 
/// 1. Define flags globais do tipo de mapa.
/// 2. Configura distância e quantidade para geração procedural.
/// 3. Verifica 'global.sair': Se verdadeiro, significa que o player voltou de uma estrutura. O código recria as estruturas salvas e move o player para a porta de entrada (+ offset Y).

// --- Configuração de Bioma/Mapa ---
global.map_vamp = true;
global.map_bebe = false;


// Inicializa sistema de ondas
init_night_waves();

// Garanta que o alarme 0 comece zerado para o sistema assumir
alarm[0] = 0;

//Inicializa grid de poderes
inicializar_tudo();

// --- Parâmetros de Geração (Procedural) ---
spaw_timer = 10;            // Timer para controle de spawn
distancia_minima = 200;     // Raio mínimo entre estruturas
quantidade_estruturas = 8;  // Limite de estruturas neste mapa

// --- Lógica de Retorno (Transição de Sala) ---
// Verifica se o jogador está "saindo" de um interior para este mapa
if (global.sair) 
{
    global.estruturas_criadas = true;
    
    // Reconstrói as estruturas que já existiam
    recriar_estruturas();
    
    // Reposiciona o player na posição salva (porta de entrada)
    // O '+ 300' serve para o player não nascer preso dentro da porta/parede
    obj_player.x = global.pos_x_map;
    obj_player.y = global.pos_y_map + 300;
    
    // Reseta a flag para impedir que isso rode novamente
    global.sair = false;
}