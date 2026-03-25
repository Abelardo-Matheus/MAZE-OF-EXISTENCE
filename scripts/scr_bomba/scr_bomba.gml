/// @desc Retorna a estrutura de dados (Vetor de Skill) da BOMBA (Arremesso)
function scr_bomb_config()
{
    return {
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        stats_base: {
            damage: 20,                 
            sprite_icon: spr_bomba_icon,
            cooldown: 7000,             
            radius: 100,                
            push_force: 0,              
            bomb_count: 0,              
            splash_multiplier: 0.5,     
            flight_duration: 1.0        
        },

        // ========================================================
        // --- NOVO: DADOS DA EVOLUÇÃO ---
        // ========================================================
        evolucao: {
            nivel: 15, // Nível em que a evolução acontece
            sprite_icon: spr_bomba_icon_evol, // SUBSTITUA pelo seu novo ícone!
            desc: "EVOLUÇÃO (NV 15): A BOMBA GERA UM BURACO NEGRO QUE PUXA OS INIMIGOS!"
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        niveis: [
            { desc: "LANÇA UMA BOMBA EM ARCO QUE EXPLODE AO ATINGIR O CHÃO.", upgrade: function(_s) { _s.bomb_count = 1; } },
            { desc: "DANO DA BOMBA AUMENTADO EM 35%", upgrade: function(_s) { _s.damage *= 1.35; } },
            { desc: "TEMPO DE RECARGA REDUZIDO EM 10% (-Cooldown)", upgrade: function(_s) { _s.cooldown *= 0.90; } },
            { desc: "RAIO DA EXPLOSÃO AUMENTADO (+Área)", upgrade: function(_s) { _s.radius += 20; } },
            { desc: "LANÇA MAIS DUAS BOMBAS (+2 Qtd)", upgrade: function(_s) { _s.bomb_count += 2; } },
            { desc: "BOMBA EMPURRA OS INIMIGOS (+Knockback)", upgrade: function(_s) { _s.push_force += 0.02; } },
            { desc: "DANO EM ÁREA AUMENTADO (+Splash)", upgrade: function(_s) { _s.splash_multiplier += 0.05; } }
        ]
    };
}
/// @desc Executa a lógica da 'Bomba'
function scr_bomba(_row_index) 
{
    if (global.level_up) exit; 

    // --- VARIÁVEL QUE DEFINE QUAL OBJETO VAI NASCER ---
    var _bomb_obj = obj_bomba;

    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    if (_current_level <= 0) exit;

    var _config = scr_bomb_config(); 
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- O DESVIO DA EVOLUÇÃO (NÍVEL 15) ---
    // ========================================================
    if (_current_level >= 15) {
        _bomb_obj = obj_bomba_evolved; // Troca para a bomba de implosão!
    }

    if (!variable_global_exists("bomb_timer")) global.bomb_timer = 0;
    global.bomb_timer += delta_time / 1000; 

    if (global.bomb_timer >= _stats.cooldown) 
    {
        global.bomb_timer = 0; 

        if (!instance_exists(obj_player)) exit; 
        
        var _player_x = obj_player.x;
        var _player_y = obj_player.y;
        var _targets_list = ds_list_create();

        with (par_inimigos) 
        {
            if (point_distance(x, y, _player_x, _player_y) <= 1000) {
                ds_list_add(_targets_list, id);
            }
        }

        var _total_targets = ds_list_size(_targets_list);

        if (_total_targets > 0) 
        {
            var _priority_queue = ds_priority_create();
            
            for(var k = 0; k < _total_targets; k++)
            {
                var _enemy = _targets_list[| k];
                var _dist = point_distance(_player_x, _player_y, _enemy.x, _enemy.y);
                ds_priority_add(_priority_queue, _enemy, _dist);
            }

            // Cálculo infinito: Ganha +1 bomba a cada 5 níveis depois do 15
            var _bombas_extras = floor(max(0, _current_level - 15) / 5);
            var _total_bombs_to_throw = _stats.bomb_count + _bombas_extras;

            var _bombs_to_throw = min(_total_bombs_to_throw, _total_targets);

            for (var i = 0; i < _bombs_to_throw; i++) 
            {
                var _target_id = ds_priority_delete_min(_priority_queue);

                if (instance_exists(_target_id)) 
                {
                    // --- MUDANÇA AQUI: Usa a variável _bomb_obj ---
                    var _bomb = instance_create_layer(_player_x, _player_y, "Instances", _bomb_obj);
                    
                    _bomb.start_x = _player_x;     
                    _bomb.start_y = _player_y;
                    _bomb.target_x = _target_id.x;    
                    _bomb.target_y = _target_id.y;
                    
                    _bomb.flight_duration = _stats.flight_duration; 
                    _bomb.flight_timer = 0;           
                    _bomb.state = "flying";           

                    _bomb.damage = _stats.damage;
                    _bomb.radius = _stats.radius;
                    _bomb.push_force = _stats.push_force; 
                    _bomb.splash_multiplier = _stats.splash_multiplier;
                }
            }
            ds_priority_destroy(_priority_queue);
        }
        ds_list_destroy(_targets_list);
    }
}