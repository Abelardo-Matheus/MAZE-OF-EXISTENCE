

event_inherited();
wander_timer = 0;
wander_max = 60; // 1 segundo (room_speed = 60)
follow_distance = 400; // por exemplo, raio ao redor do player
wander_direction = irandom(359);
wander_target_x = x;
wander_target_y = y;

is_attacking = false;
attack_target = noone;
cooldown = false;
cooldown_timer = 0;
cooldown_max = 60; // 1 segundo cooldown
is_returning = false;

damage = 10;      // Exemplo, defina conforme seu pet config
velocidade = 3;
range = 200;      // alcance de detecção de inimigos
