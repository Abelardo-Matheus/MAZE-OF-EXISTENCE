global.speed_sperm = 7;
global.dash_habilitado = false;  // Inicialmente, o dash está desabilitado
global.dash_em_recarga = false;  // Indica se o dash está em recarga
global.in_dash = false;
global.speed_dash = 0;  // Velocidade do dash
global.dash_tempo_recarga = 0; // Tempo de recarga do dash (2 segundos, se o jogo estiver a 60 FPS)
global.frames = 0;
global.dash_em_recarga = false;  // Indica se o dash está em recarga
global.in_dash = false;

function salvar_estado_dash() {
    global.dash_estado_speed = global.current_player.current_speed;
    global.dash_em_recarga = global.dash_em_recarga;
    global.dash_alarm = alarm[0];
    global.frames_restantes = alarm[0] > 0 ? alarm[0] : 0;

}
/// Função para restaurar o estado do dash após a troca de room
function restaurar_estado_dash() {
    if (global.dash_em_recarga) {
        global.current_player.current_speed = global.dash_estado_speed;
        global.dash_em_recarga = true;
        alarm[0] = global.frames_restantes;  // Restaura o tempo restante da recarga
    } else {
        global.current_player.current_speed = global.speed_sperm;  // Define a velocidade normal
        global.dash_em_recarga = false;
    }
}
