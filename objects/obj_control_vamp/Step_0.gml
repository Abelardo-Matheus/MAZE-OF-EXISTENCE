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
    level_upp();
}



gerenciar_mundo_procedural();


// --- 6. Gerenciador de Ondas Noturnas ---
// Este script cuida de verificar se é noite, contar o tempo,
// mudar de onda e chamar o spawn quando o alarm[0] permitir.
process_night_waves();

