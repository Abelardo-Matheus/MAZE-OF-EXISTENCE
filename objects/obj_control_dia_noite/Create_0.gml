/// @desc Configuração do Ciclo Dia/Noite
/// [O QUE]: Inicializa as variáveis globais de controle de tempo e a estrutura de dados (Struct) do ciclo de iluminação.
/// [COMO] :
/// 1. Define multiplicadores de tempo (para acelerar o jogo se necessário).
/// 2. Cria a struct 'global.day_night_cycle' contendo durações, cores de luz e flags de estado.
/// 3. Inicializa flags de eventos únicos (primeiro amanhecer).

// --- Controle de Tempo ---
global.time_multiplier = 1;      // Multiplicador de velocidade (1 = normal)
global.time_accelerated = false; // Estado de aceleração (ex: dormir)

// --- Estrutura do Ciclo Dia/Noite ---
global.day_night_cycle = {
    // TEMPO: (Segundos * Frames)
    // Exemplo: 5 minutos = 5 * 60 * 60 (18.000 frames)
    // Seu valor atual (3 * 60) é igual a 3 SEGUNDOS (útil para debug, muito rápido para gameplay)
    day_duration:   3 * 60,    
    night_duration: 3 * 60,    
    
    current_cycle: 0,          // Timer progressivo (vai de 0 até a duração)
    is_day: true,              // Flag booleana
    
    // ILUMINAÇÃO (0.0 = Escuro total, 1.0 = Claro total)
    base_light: 1.0,           // Luz máxima (Meio-dia)
    min_light: 0.2,            // Luz mínima (Meia-noite) - Ajuste para 0.0 se quiser breu total
    dawn_light: 0.4,           // Luz no amanhecer/anoitecer (Tintura laranja)
    current_light: 1.0,        // Luz inicial (Começa claro)
    
    overlay: -1                // ID da Surface (Inicia vazia)
};

// --- Flags de Eventos ---
// Garante que a variável exista para não dar erro em outros objetos
if (!variable_global_exists("first_dawn_passed")) 
{
    global.first_dawn_passed = false;
}