if (!variable_instance_exists(id, "seed")) seed = random(999999);
if (!variable_instance_exists(id, "grupo_id")) grupo_id = irandom(99999);

var resultado = grupo_inimigo_configurar(seed);

dificuldade = resultado[0];
quantidade_total = resultado[1];
tempo_entre_spawns = resultado[2];
spawn_radius = 100;
inimigos_spawnados = 0;
spawn_timer = 0;
distancia_criar = 600;