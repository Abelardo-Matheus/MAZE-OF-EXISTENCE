/// @desc Retorna a estrutura de dados (Vetor de Skill) da BOLA
function scr_bola_config()
{
    return {
        // --- Status Base ---
        stats_base: {
            damage: 10,
            sprite_icon: spr_bola_icon,
            cooldown: 5000, 
            size: 1,
            speed: 8,
            projectile_count: 0, 
            knockback: 0
        },

        // ========================================================
        // --- NOVO: DADOS DA EVOLUÇÃO ---
        // ========================================================
        evolucao: {
            nivel: 15, // Nível em que a evolução acontece
            sprite_icon: spr_bola_icon_evol, // SUBSTITUA pelo seu novo ícone!
            desc: "EVOLUÇÃO (NV 15): A BOLA AGORA QUICA NOS INIMIGOS!" // Texto único
        },

        // --- Definição Nível a Nível (O ciclo infinito) ---
        niveis: [
            { desc: "JOGA UMA BOLA QUE PERSEGUE INIMIGOS.\nATIRAR + DANO.", upgrade: function(_s) { _s.projectile_count = 1; _s.damage *= 1.10; _s.damage += global.ataque; } },
            { desc: "DISPARO MAIS RÁPIDO (+5%)", upgrade: function(_s) { _s.speed *= 1.05; } },
            { desc: "FREQUÊNCIA AUMENTADA EM 25% (-Cooldown)", upgrade: function(_s) { _s.cooldown *= 0.75; } },
            { desc: "EMPURRA MAIS OS INIMIGOS", upgrade: function(_s) { _s.knockback += 0.01; } },
            { desc: "MAIS 1 BOLA ATIRADA", upgrade: function(_s) { _s.projectile_count += 1; } },
            { desc: "MEGA UPGRADE: BOLAS GIGANTES E MORTAIS", upgrade: function(_s) { _s.damage *= 2; _s.size *= 1.5; _s.speed *= 1.2; } }
        ]
    };
}

/// @desc Executa a lógica da 'Bola' NORMAL (Níveis 1 ao 14)
function scr_bola(_row_index) 
{
    if (global.level_up) exit; 

    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    if (_current_level <= 0) exit;

    var _config = scr_bola_config(); 
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // Se chegou no nível 15, chama a função da bola que quica!
    if (_current_level >= 15) {
        scr_bola_evolvida(_stats);
        exit; 
    }

    if (!variable_global_exists("ball_timer")) global.ball_timer = 0;
    global.ball_timer += delta_time / 1000; 

    if (global.ball_timer >= _stats.cooldown) 
    {
        global.ball_timer = 0; 
        var _all_enemies_list = ds_list_create();
        with (par_inimigos) { ds_list_add(_all_enemies_list, id); }
        
        var _shots_to_fire = min(_stats.projectile_count, ds_list_size(_all_enemies_list));

        for (var i = 0; i < _shots_to_fire; i++) 
        {
            var _random_index = irandom(ds_list_size(_all_enemies_list) - 1);
            var _target_enemy = _all_enemies_list[| _random_index];
            ds_list_delete(_all_enemies_list, _random_index); 

            if (instance_exists(_target_enemy)) 
            {
                var _projectile = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bola);
                _projectile.direction = point_direction(obj_player.x, obj_player.y, _target_enemy.x, _target_enemy.y);
                _projectile.veloc = _stats.speed; 
                _projectile.damage = _stats.damage;
                _projectile.image_xscale = _stats.size * 0.2;
                _projectile.image_yscale = _stats.size * 0.2;
                _projectile.push_force = _stats.knockback; 
                
                _projectile.pode_quicar = false; // Bola normal não quica
            }
        }
        ds_list_destroy(_all_enemies_list);
    }
}

/// @desc Executa a lógica da 'Bola' EVOLVIDA (Nível 15 para sempre)
function scr_bola_evolvida(_stats) 
{
    if (!variable_global_exists("ball_timer")) global.ball_timer = 0;
    global.ball_timer += delta_time / 1000; 

    if (global.ball_timer >= _stats.cooldown) 
    {
        global.ball_timer = 0; 
        var _all_enemies_list = ds_list_create();
        with (par_inimigos) { ds_list_add(_all_enemies_list, id); }
        
        var _shots_to_fire = min(_stats.projectile_count, ds_list_size(_all_enemies_list));

        for (var i = 0; i < _shots_to_fire; i++) 
        {
            var _random_index = irandom(ds_list_size(_all_enemies_list) - 1);
            var _target_enemy = _all_enemies_list[| _random_index];
            ds_list_delete(_all_enemies_list, _random_index); 

            if (instance_exists(_target_enemy)) 
            {
                var _projectile = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bola);
                _projectile.direction = point_direction(obj_player.x, obj_player.y, _target_enemy.x, _target_enemy.y);
                _projectile.veloc = _stats.speed; 
                
                // Usa o Dano Infinito (que já foi calculado e acumulado) e dá um boost extra!
                _projectile.damage = _stats.damage * 1.5; 
                _projectile.image_xscale = _stats.size * 0.2;
                _projectile.image_yscale = _stats.size * 0.2;
                _projectile.push_force = _stats.knockback; 
                
                // Mágica ativada para o obj_bola bater e voltar
                _projectile.pode_quicar = true; 
                _projectile.quicadas_restantes = 3; 
                _projectile.inimigos_atingidos = ds_list_create(); 
            }
        }
        ds_list_destroy(_all_enemies_list);
    }
}