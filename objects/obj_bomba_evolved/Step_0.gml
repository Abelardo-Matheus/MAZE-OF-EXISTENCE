switch (state) 
{
    // ============================================================
    // ESTADO 1: VOANDO (Movimento por Tempo) - Exatamente Igual!
    // ============================================================
    case "flying":
        flight_timer += delta_time / 1000000; 
        var _progress = flight_timer / flight_duration;

        if (_progress >= 1) 
        {
            // --- CHEGADA NO ALVO ---
            x = target_x;
            y = target_y;
            z = 0; 
            
            // Transição de Estado para Implosão
            state = "exploding";
            
            // SUBSTITUA por uma sprite de buraco negro ou vórtex!
            sprite_index = spr_confete; 
            image_index = 0;
            image_speed = 1;
            
            var _final_scale = radius / base_bomb_size;
            image_xscale = _final_scale * 4;
            image_yscale = _final_scale * 4;
            
            // Variáveis novas para o Buraco Negro
            timer_sugando = 0; 
            exploded = false; 
        } 
        else 
        {
            x = lerp(start_x, target_x, _progress);
            y = lerp(start_y, target_y, _progress);
            z = sin(_progress * pi) * 150; 
            
            var _base_scale = radius / base_bomb_size;
            var _height_scale = z / 200; 
            image_xscale = _base_scale + _height_scale;
            image_yscale = _base_scale + _height_scale;
        }
        break;

    // ============================================================
    // ESTADO 2: EXPLODINDO (Buraco Negro que Puxa)
    // ============================================================
    case "exploding":
        
        // 1. Duração do Buraco Negro (ex: 2 segundos sugando)
        timer_sugando++;
        
        // 2. Efeito de Sucção Contínuo (Acontece todo frame)
        var _enemies_in_range = ds_list_create();
        var _count = collision_circle_list(x, y, radius, par_inimigos, false, true, _enemies_in_range, false);
        
        for (var i = 0; i < _count; i++) 
        {
            var _enemy = _enemies_in_range[| i];
            if (instance_exists(_enemy)) 
            {
                // Calcula direção DO INIMIGO PARA A BOMBA (Isso que faz puxar!)
                var _dir_sugada = point_direction(_enemy.x, _enemy.y, x, y);
                
                // Mágica para puxar suavemente usando motion_add ou empurrar_dir
                // Se a distância for maior que 10 pixels, continua puxando
                if (point_distance(_enemy.x, _enemy.y, x, y) > 10) {
                    _enemy.x += lengthdir_x(push_force * 4, _dir_sugada); // Multipliquei por 4 para puxar rápido
                    _enemy.y += lengthdir_y(push_force * 4, _dir_sugada);
                }
                
                // Opcional: Dar um "dano contínuo" pequeno enquanto estão presos no buraco negro
                if (timer_sugando % 10 == 0) { // A cada 10 frames
                    _enemy.vida -= (damage * 0.1); 
                }
            }
        }
        ds_list_destroy(_enemies_in_range);
        
        // 3. O Fim do Buraco Negro (A Grande Explosão!)
        // 120 frames = 2 segundos sugando
        if (timer_sugando >= 120) 
        {
            if (!exploded) 
            {
                exploded = true;
                
                // Dá o dano final (o dano calculado no status) em quem sobrou na área
                var _final_hit_list = ds_list_create();
                var _final_count = collision_circle_list(x, y, radius, par_inimigos, false, true, _final_hit_list, false);
                
                for (var j = 0; j < _final_count; j++) 
                {
                    var _final_enemy = _final_hit_list[| j];
                    if (instance_exists(_final_enemy)) {
                        _final_enemy.vida -= damage;
                        
                        var _dmg_text = instance_create_layer(x, y, "Instances", obj_dano);
                        _dmg_text.alvo = _final_enemy;
                        _dmg_text.dano = damage;
                    }
                }
                ds_list_destroy(_final_hit_list);
            }
            
            // Destrói a bomba
            instance_destroy();
        }
        break;
}