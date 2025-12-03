event_inherited();

// --- Status Básicos (Sobrescritos pelo script scr_sapo) ---
damage = 10;
velocidade = 3;
range = 300;       // Raio de detecção
orbit_radius = 600; // Quão longe do player ele gosta de ficar

// --- Máquina de Estados ---
state = "idle"; // idle, chase, dash, cooldown
target_enemy = noone;

// --- Controle de Movimento Aleatório (Vagar) ---
wander_x = x;
wander_y = y;
wander_timer = 0;      // Tempo até escolher novo ponto
wander_interval = 120; // 2 segundos entre movimentos

// --- Controle de Ataque (Dash/Tapa) ---
dash_speed = 12;       // Velocidade do "tapa"
dash_duration = 10;    // Duração do dash (frames)
dash_timer = 0;
has_hit = false;       // Garante que só dá dano 1 vez por dash

// --- Cooldown ---
attack_cooldown_current = 0;
attack_cooldown_max = 60;
escala_base = 0.5;
// Garante que comece no tamanho certo
image_xscale = escala_base;
image_yscale = escala_base;