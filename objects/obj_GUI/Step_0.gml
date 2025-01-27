// Inicializa o cronômetro se ainda não existir
if (!variable_global_exists("timer")) global.timer = 0; // Tempo total em segundos
if (!variable_global_exists("timer_running")) global.timer_running = true; // Controle para iniciar/parar o cronômetro

// Atualiza o cronômetro se estiver rodando
if (global.timer_running) {
    global.timer += 1 / room_speed; // Incrementa o tempo com base no room_speed
}


