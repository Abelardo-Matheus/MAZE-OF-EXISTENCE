/// @desc Inicialização do Bumerangue
/// [O QUE]: Define valores padrão e cria a lista de colisão.
/// [COMO] :
/// 1. Define 'timer_going' (tempo que ele viaja antes de voltar).
/// 2. Cria 'hit_list' para garantir que o bumerangue não acerte o mesmo inimigo 60 vezes por segundo.

// --- Configurações de Voo ---
timer_going = 40;       // Duração do voo de ida (em frames). Aprox 0.6 seg.
return_speed_mult = 2.5; // Multiplicador de velocidade na volta (para alcançar o player)
push = 1;
// --- Controle de Colisão ---
hit_list = ds_list_create(); // Lista de IDs de inimigos já atingidos neste voo

// --- Valores Padrão (Caso o script falhe em passar algum) ---
if (!variable_instance_exists(id, "damage")) damage = 10;
if (!variable_instance_exists(id, "move_speed")) move_speed = 5;
if (!variable_instance_exists(id, "state")) state = "going";
if (!variable_instance_exists(id, "pierce_max")) pierce_max = 999;

// Direção inicial (será sobrescrita pelo script, mas garante segurança)
if (!variable_instance_exists(id, "target_x")) target_x = x;
if (!variable_instance_exists(id, "target_y")) target_y = y;

// Calcula direção inicial imediatamente
direction = point_direction(x, y, target_x, target_y);