// Evento BROADCAST MESSAGE da Flecha
if (event_data[? "message"] == "som_flecha") {
    
    // Verifica a nossa trava: O som já tocou?
    if (som_flecha_tocado == false) {
        
        // Se não tocou, toca agora!
        var _som = audio_play_sound(snd_flecha, 1, false);
        audio_sound_pitch(_som, random_range(0.9, 1.1)); 
        
        // Fecha a trava! Assim ele NUNCA MAIS entra nesse 'if' para essa flecha.
        som_flecha_tocado = true; 
    }
    
}