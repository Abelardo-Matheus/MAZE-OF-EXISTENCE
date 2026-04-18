// No script scr_gerenciador_audio:
function tocar_som_passo() {
    if (!audio_is_playing(snd_walk)) {
        // Aqui você pode adicionar lógica!
        // Ex: "Se global.piso_atual == 'grama', toca snd_walk_grama"
        audio_play_sound(snd_walk, 1, true); 
    }
}

function parar_som_passo() {
    if (audio_is_playing(snd_walk)) {
        audio_stop_sound(snd_walk);
    }
}

