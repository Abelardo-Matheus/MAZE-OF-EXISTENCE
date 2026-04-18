/// @desc Recebe mensagens da animação

// event_data é um mapa (ds_map) automático do GameMaker que contém a mensagem
if (event_data[? "message"] == "som_arco") {
    // Opcional: Variar o som levemente deixa o jogo mais profissional
    // pitch varia a velocidade/tom do som. 1 é o normal.
    var _som = audio_play_sound(snd_ataque_arco, 1, false);
    audio_sound_pitch(_som, random_range(0.9, 1.1)); 
    
}


















