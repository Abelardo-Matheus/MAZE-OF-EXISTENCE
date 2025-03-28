
// EVENTO STEP DO OBJETO (substitua o código existente por este)
var time_speed = 1; // Velocidade padrão

// Verifica se a tecla L foi pressionada para alternar a velocidade
if (keyboard_check_pressed(ord("L"))) {
    global.time_accelerated = !global.time_accelerated;
    global.time_multiplier = global.time_accelerated ? 10 : 1; // 5x mais rápido quando acelerado
}

// Atualiza o timer global com o multiplicador
if (global.timer_running) {
    global.timer += (1 / room_speed) * global.time_multiplier;
}

// Atualiza minutos e segundos (agora usando o timer acelerado)
global.minutes = floor(global.timer / 60);
global.seconds = floor(global.timer) mod 60;

// Formatação do tempo (mantém o mesmo)
var formatted_minutes = (global.minutes < 10) ? "0" + string(global.minutes) : string(global.minutes);
var formatted_seconds = (global.seconds < 10) ? "0" + string(global.seconds) : string(global.seconds);

// Sistema dia/noite (código existente, mas agora usando o timer acelerado)
var cycle = global.day_night_cycle;
var total_cycle = cycle.is_day ? cycle.day_duration : cycle.night_duration;

cycle.current_cycle = (global.timer mod total_cycle) / total_cycle;

if ((global.timer mod (cycle.day_duration + cycle.night_duration)) >= cycle.day_duration && cycle.is_day) {
    cycle.is_day = false;
} else if ((global.timer mod (cycle.day_duration + cycle.night_duration)) < cycle.day_duration && !cycle.is_day) {
    cycle.is_day = true;
}

// Restante do código do ciclo dia/noite permanece igual...
// EVENTO STEP DO MESMO OBJETO:

// Calcula o tempo total do ciclo completo (dia + noite)
var full_cycle_time = cycle.day_duration + cycle.night_duration;
var current_time_in_cycle = global.timer mod full_cycle_time;

// Determina se é dia ou noite e calcula o progresso
if (current_time_in_cycle < cycle.day_duration) {
    // Ciclo diurno
    cycle.is_day = true;
    cycle.current_cycle = current_time_in_cycle / cycle.day_duration;
    
    // Amanhecer (0% a 25% do dia)
    if (cycle.current_cycle < 0.25) {
        cycle.current_light = cycle.dawn_light + (cycle.base_light - cycle.dawn_light) * (cycle.current_cycle * 4);
    }
    // Meio-dia (25% a 75% do dia)
    else if (cycle.current_cycle < 0.75) {
        cycle.current_light = cycle.base_light;
    }
    // Entardecer (75% a 100% do dia)
    else {
        cycle.current_light = cycle.base_light - (cycle.base_light - cycle.dawn_light) * ((cycle.current_cycle - 0.75) * 4);
    }
} else {
    // Ciclo noturno
    cycle.is_day = false;
    cycle.current_cycle = (current_time_in_cycle - cycle.day_duration) / cycle.night_duration;
    
    // Anoitecer (0% a 25% da noite)
    if (cycle.current_cycle < 0.25) {
        cycle.current_light = cycle.dawn_light - (cycle.dawn_light - cycle.min_light) * (cycle.current_cycle * 4);
    }
    // Meia-noite (25% a 75% da noite)
    else if (cycle.current_cycle < 0.75) {
        cycle.current_light = cycle.min_light;
    }
    // Amanhecer (75% a 100% da noite)
    else {
        cycle.current_light = cycle.min_light + (cycle.dawn_light - cycle.min_light) * ((cycle.current_cycle - 0.75) * 4);
    }
}

// Atualiza a surface de overlay (mantenha o mesmo código)
if (!surface_exists(cycle.overlay)) {
    cycle.overlay = surface_create(global.cmw, global.cmh);
}
surface_set_target(cycle.overlay);
draw_clear_alpha(c_black, 1 - cycle.current_light);
surface_reset_target();
