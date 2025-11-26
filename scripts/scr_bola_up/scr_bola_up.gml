/// @desc Calcula os atributos da 'Bola' baseado no nível
/// [O QUE]: Define os status base e aplica os modificadores acumulativos de cada nível. Também atualiza a descrição do upgrade na Grid.
/// [COMO] : Itera de 1 até o nível atual, aplicando bônus matemáticos (multiplicadores ou somas) e definindo o texto da UI.
function scr_ball_calculate_stats(_level) 
{
    // --- Status Base (Nível 0) ---
    var _stats = {
        damage: 10,             // Dano base
        cooldown: 5000,         // Tempo em ms (5 segundos)
        size: 1,                // Escala do sprite
        speed: 8,               // Velocidade de movimento
        projectile_count: 1,    // Quantidade de projéteis
        knockback: 0            // Força de empurrão
    };

    // --- Cálculo de Nível (Acumulativo) ---
    for (var i = 1; i <= _level; i++) 
    {
        // Otimização: Usamos switch no resto da divisão para criar padrões repetitivos de upgrade
        switch (i % 6) 
        {
            case 5: // Níveis 5, 11, 17... (+1 Projétil)
                _stats.projectile_count += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "MAIS 1 BOLA ATIRADA";
                break;

            case 2: // Níveis 2, 8, 14... (+5% Velocidade)
                _stats.speed *= 1.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "DISPARO MAIS RÁPIDO";
                break;

            case 3: // Níveis 3, 9, 15... (-25% Cooldown)
                _stats.cooldown *= 0.75;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "FREQUÊNCIA AUMENTADA EM 25%";
                break;

            case 1: // Níveis 1, 7, 13... (+10% Dano + Base)
                _stats.damage *= 1.10;
                _stats.damage += global.ataque; // Adiciona ataque base do player
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "AUMENTO DE 10% DE DANO";
                break;

            case 4: // Níveis 4, 10, 16... (+Knockback)
                _stats.knockback += 0.01;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "EMPURRA MAIS OS INIMIGOS";
                break;
                
            // case 0: (Múltiplos de 6) - Pode adicionar um "Mega Upgrade" aqui se quiser
        }
    }

    return _stats;
}

/// @desc Executa a lógica da 'Bola' (Cooldown e Disparo)
/// [O QUE]: Gerencia o temporizador, seleciona inimigos aleatórios na tela e cria os projéteis.
/// [COMO] : 
/// 1. Obtém os stats atuais chamando a função de config.
/// 2. Incrementa o timer global (em milissegundos).
/// 3. Se o timer estourar, cria uma lista de todos os inimigos, sorteia alvos e dispara.
function scr_bola() 
{
    // 1. Obter Nível e Stats
    // Nota: 0 é o índice da linha da BOLA na sua grid (conforme seu código anterior)
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 0]; 
    var _stats = scr_ball_calculate_stats(_current_level); 

    // 2. Gerenciamento do Timer (Cooldown)
    if (!variable_global_exists("ball_timer")) global.ball_timer = 0;

    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.ball_timer += delta_time / 1000; 

    // 3. Disparo
    if (global.ball_timer >= _stats.cooldown) 
    {
        global.ball_timer = 0; // Reseta timer

        // --- Sistema de Alvo (Targeting) ---
        var _all_enemies_list = ds_list_create();
        
        // Coleta todos os inimigos ativos
        with (par_inimigos) 
        {
            ds_list_add(_all_enemies_list, id);
        }
        
        var _total_enemies = ds_list_size(_all_enemies_list);
        
        // Define quantos tiros vão sair (mínimo entre status ou inimigos disponíveis)
        var _shots_to_fire = min(_stats.projectile_count, _total_enemies);

        // Loop de Disparo
        for (var i = 0; i < _shots_to_fire; i++) 
        {
            // Sorteia um índice da lista
            var _random_index = irandom(ds_list_size(_all_enemies_list) - 1);
            var _target_enemy = _all_enemies_list[| _random_index];
            
            // Remove da lista para não atirar no mesmo cara 2 vezes
            ds_list_delete(_all_enemies_list, _random_index); 

            if (instance_exists(_target_enemy)) 
            {
                // Criação do Projétil
                var _projectile = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bola);
                
                // Configuração do Projétil
                _projectile.direction = point_direction(obj_player.x, obj_player.y, _target_enemy.x, _target_enemy.y);
                _projectile.veloc = _stats.speed;       // GameMaker usa 'speed' nativo para mover automatico
                _projectile.damage = _stats.damage;
                _projectile.image_xscale = _stats.size;
                _projectile.image_yscale = _stats.size;
                _projectile.push_force = _stats.knockback; // Renomeado para evitar conflito com palavra reservada
                
                // Aplicação imediata de Knockback (Opcional: pode ser feito na colisão da bala também)
                with (_target_enemy) 
                {
                    var _knock_dir = point_direction(obj_player.x, obj_player.y, x, y);
                    motion_add(_knock_dir, _stats.knockback);
                }
            }
        }

        // Limpeza de Memória Obrigatória
        ds_list_destroy(_all_enemies_list);
    }
}