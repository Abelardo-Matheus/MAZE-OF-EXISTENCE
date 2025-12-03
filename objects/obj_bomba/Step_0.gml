/// @desc Máquina de Estados da Bomba (Voo e Explosão)
/// [O QUE]: Controla o movimento parabólico da bomba até o alvo e, ao chegar, executa a lógica de dano em área e animação.
/// [COMO] : 
/// 1. Estado 'flying': Usa 'lerp' baseada no tempo para mover a bomba e 'sin' para calcular a altura (z).
/// 2. Estado 'exploding': Detecta colisão circular uma única vez, aplica dano com redução por distância (splash) e destrói o objeto ao fim da animação.

switch (state) 
{
    // ============================================================
    // ESTADO 1: VOANDO (Movimento por Tempo)
    // ============================================================
    case "flying":
        // 1. Atualiza o cronômetro
        // delta_time é em microssegundos, dividimos por 1 milhão para ter segundos
        flight_timer += delta_time / 1000000; 
        
        // 2. Calcula o progresso (0.0 = Início, 1.0 = Chegou)
        var _progress = flight_timer / flight_duration;

        if (_progress >= 1) 
        {
            // --- CHEGADA NO ALVO ---
            x = target_x;
            y = target_y;
            z = 0; // Altura zera no chão (impacto)
            
            // Transição de Estado
            state = "exploding";
            sprite_index = spr_explosion;
            image_index = 0;
            image_speed = 1;
            
            // Define escala final da explosão baseada no raio
            // Nota: Certifique-se que 'base_bomb_size' está definido no Create (ex: 64)
            var _final_scale = radius / base_bomb_size;
            image_xscale = _final_scale*4;
            image_yscale = _final_scale*4;
            
            exploded = false; // Prepara para causar dano no próximo frame
        } 
        else 
        {
            // --- MOVIMENTO ---
            // Interpolação Linear: Move do Start ao Target suavemente
            x = lerp(start_x, target_x, _progress);
            y = lerp(start_y, target_y, _progress);

            // --- CÁLCULO DE ARCO (ALTURA 'Z') ---
            // Seno de 0 a PI cria um arco perfeito (sobe e desce)
            // 150 é a altura máxima em pixels (pode ajustar se quiser mais alto)
            z = sin(_progress * pi) * 150; 

            // --- EFEITO VISUAL (Escala Dinâmica) ---
            // A bomba cresce levemente enquanto sobe para dar sensação de 3D
            var _base_scale = radius / base_bomb_size;
            var _height_scale = z / 200; 
            
            image_xscale = _base_scale + _height_scale;
            image_yscale = _base_scale + _height_scale;
        }
        break;

    // ============================================================
    // ESTADO 2: EXPLODINDO (Dano e Animação)
    // ============================================================
    case "exploding":
        // 1. Lógica de Dano (Roda apenas uma vez no início da explosão)
        if (!exploded) 
        {
            exploded = true; // Trava para não rodar novamente
            
            // Cria lista para armazenar inimigos atingidos
            var _enemies_hit_list = ds_list_create();
            
            // Verifica colisão circular (retorna quantos colidiram)
            var _count = collision_circle_list(x, y, radius, par_inimigos, false, true, _enemies_hit_list, false);
            
            for (var i = 0; i < _count; i++) 
            {
                var _enemy_id = _enemies_hit_list[| i];
                
                if (instance_exists(_enemy_id)) 
                {
                    // Cálculo de Splash Damage (Dano cai conforme a distância do centro)
                    var _dist_to_center = point_distance(x, y, _enemy_id.x, _enemy_id.y);
                    var _final_damage = damage;

                    if (_dist_to_center > 0) 
                    {
                        // Fórmula: Dano reduzido baseado na distância e no multiplicador de splash
                        _final_damage = damage * (1 - (_dist_to_center / radius) * (1 - splash_multiplier));
                        _final_damage = max(0, _final_damage); // Evita cura acidental
                    }

                    // Aplica Dano
                    _enemy_id.vida -= _final_damage;

                    // Aplica Empurrão (Knockback)
                    if (push_force > 0) 
                    {
                        var _push_dir = point_direction(obj_player.x, obj_player.y, _enemy_id.x, _enemy_id.y);
                        // Assumindo variáveis padrão do seu inimigo
                        _enemy_id.empurrar_dir = _push_dir;
                        _enemy_id.empurrar_veloc = push_force;
                    }

                    // Feedback Visual no Inimigo
                    _enemy_id.state = scr_inimigo_hit; 
                    _enemy_id.alarm[1] = 5; // Tempo do flash branco
                    _enemy_id.hit = true;

                    // Cria texto de dano (Pop-up)
                    var _dmg_text = instance_create_layer(x, y, "Instances", obj_dano);
                    _dmg_text.alvo = _enemy_id;
                    _dmg_text.dano = _final_damage;
                }
            }
            // Limpeza de memória obrigatória
            ds_list_destroy(_enemies_hit_list);
            
            // Opcional: Efeitos de tela ou som
            // audio_play_sound(snd_explosion, 1, false);
        }

        // 2. Destruição após o fim da animação
        if (image_index >= image_number - 1) 
        {
            instance_destroy();
        }
        break;
}