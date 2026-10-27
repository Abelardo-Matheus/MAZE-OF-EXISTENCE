// feather disable GM2017
if (!variable_instance_exists(id, "seed")) seed = random(999999);
if (!variable_instance_exists(id, "grupo_id")) grupo_id = irandom(99999);

nivel_area = progressao_nivel_area(x, y); // scr_progressao
var _resultado = grupo_inimigo_configurar(seed, nivel_area);

dificuldade = _resultado[0];
quantidade_total = _resultado[1];
tempo_entre_spawns = _resultado[2];
spawn_radius = 100;
inimigos_spawnados = 0;
spawn_timer = 0;
distancia_criar = 600;