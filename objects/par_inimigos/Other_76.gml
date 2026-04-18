if (event_data[? "message"] == "andar_slime") {
    
    // 1. Verifica se o jogador existe no mapa (muito importante para o jogo não "crashar" se o player morrer)
    if (instance_exists(obj_player)) {
        
        // 2. Define o raio máximo de audição (em pixels) - Ajuste esse valor como quiser!
        var _raio_audicao = 400; 
        
        // 3. Mede a distância entre o Slime (x, y) e o Player (obj_player.x, obj_player.y)
        var _distancia = point_distance(x, y, obj_player.x, obj_player.y);

        // 4. Se o slime estiver dentro do raio, toca o som!
        if (_distancia <= _raio_audicao) {
            
            var _som = audio_play_sound(snd_slime_walk, 1, false);
            audio_sound_pitch(_som, random_range(0.9, 1.1)); 
            
        }
    }
}