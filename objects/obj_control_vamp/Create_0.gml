// feather disable GM2017
/// @desc Configuração do Mapa e Geração Procedural
/// [O QUE]: Define o tipo de bioma (Vamp/Bebe), configura parâmetros de spawn de estruturas e reposiciona o player ao retornar de uma sub-área.
/// [COMO] : 
/// 1. Define flags globais do tipo de mapa.
/// 2. Configura distância e quantidade para geração procedural.
/// 3. Verifica 'global.sair': Se verdadeiro, significa que o player voltou de uma estrutura. O código recria as estruturas salvas e move o player para a porta de entrada (+ offset Y).

// --- Configuração de Bioma/Mapa ---
global.map_vamp = true;
global.map_bebe = false;

inicializar_gerador_mundo();
// Inicializa sistema de ondas
init_night_waves();

// Vento (força aleatória 0..100, empurra acima de 50): garante o obj_vento na fase
vento_garantir();

// Gerenciador da horda noturna (milhares de inimigos sem instâncias)
if (!instance_exists(obj_horde)) instance_create_layer(0, 0, "Instances", obj_horde);

// Garanta que o alarme 0 comece zerado para o sistema assumir
alarm[0] = 0;

//Inicializa grid de poderes
inicializar_tudo();


// --- Primeiro spawn: na calçada, na porta da casa inicial da cidade ---
// (feito no 1º Step, quando o obj_player com certeza já existe)
spawn_inicial_pendente = !global.sair;

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

// --- Baús que o jogador colocou no mundo aberto (itens_geral -> global.baus_fora) ---
// Roda na 1ª entrada e em toda volta de uma casa: a room não é persistente, então recria.
recriar_baus();
