
global.time_multiplier = 1; // Multiplicador de velocidade normal
global.time_accelerated = false; // Estado da aceleração


global.day_night_cycle = {
    day_duration: 3 * 60,      // 5 minutos de dia
    night_duration: 3 * 60,    // 5 minutos de noite
    current_cycle: 0,          // Progresso no ciclo atual (0-1)
    is_day: true,              // Flag para dia/noite
    base_light: 1.0,           // Luz máxima (meio-dia)
    min_light: 0.2,            // Luz mínima (meia-noite)
    dawn_light: 0.4,           // Luz no amanhecer/anoitecer
    current_light: 0.8,        // Valor atual de luz
    overlay: -1                // ID da surface
};
// Cria uma surface para o efeito de escurecimento
global.day_night_cycle.overlay = surface_create(global.room_width, global.room_height);
surface_set_target(global.day_night_cycle.overlay);
draw_clear_alpha(c_black, 0);
surface_reset_target();

