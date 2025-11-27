/// @desc Inicialização do Raio
/// [O QUE]: Define valores padrão e inicializa a flag de controle de dano.
/// [COMO] : 
/// 1. Define 'damage_applied' como false para garantir que o dano ocorra apenas uma vez.
/// 2. Define valores base de dano/raio caso não sejam passados pelo script criador.

// --- Controle de Lógica ---
damage_applied = false; // Trava para não dar dano infinito

// --- Valores Padrão (Fallback) ---
// Estes valores serão sobrescritos pelo script 'scr_raio', 
// mas é bom tê-los aqui para evitar erros de "variable not set".
if (!variable_instance_exists(id, "damage")) damage = 20;
if (!variable_instance_exists(id, "radius")) radius = 120;
if (!variable_instance_exists(id, "push_force")) push_force = 3;

// --- Visual ---
image_speed = 1;     // Velocidade normal da animação
image_index = 0;     // Garante que comece do frame 0