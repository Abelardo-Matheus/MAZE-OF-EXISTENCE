/// @description Lógica de Voo, Segurança e Pólen
if (!instance_exists(obj_player)) exit;

// ========================================================
// 1. SISTEMA DE SEGURANÇA (Teletransporte se longe)
// ========================================================
// Define uma distância máxima de segurança (ex: dobro do raio de voo)
var _dist_seguranca = wander_radius * 2.5; 
var _dist_player = point_distance(x, y, obj_player.x, obj_player.y);

// Se a borboleta se afastou demais (ficou presa ou jogador correu)
if (_dist_player > _dist_seguranca) {
    // Teletransporta instantaneamente para perto do jogador
    x = obj_player.x + irandom_range(-20, 20);
    y = obj_player.y + irandom_range(-20, 20);
    
    // Reseta a lógica de movimento para definir um novo ponto
    timer_state = 0; 
    speed = 0;
    
    // Opcional: Efeito visual de teletransporte (ex: fumaça)
    // instance_create_layer(x, y, "Instances", obj_efeito_teleporte);
    
    show_debug_message("Borboleta teletransportada por segurança.");
}

// ========================================================
// 2. LÓGICA DE VOO ALEATÓRIO (Perto do Player)
// ========================================================
if (timer_state <= 0) {
    // Define um novo ponto aleatório dentro do wander_radius do player
    target_x = obj_player.x + irandom_range(-wander_radius, wander_radius);
    target_y = obj_player.y + irandom_range(-wander_radius, wander_radius);
    
    // Define quanto tempo vai demorar para mudar de ponto (frames)
    timer_state = irandom_range(30, 90); 
} else {
    timer_state--;
}

// Move-se em direção ao ponto alvo
var _dist_to_target = point_distance(x, y, target_x, target_y);
if (_dist_to_target > velocidade) {
    move_towards_point(target_x, target_y, velocidade);
} else {
    speed = 0; // Chegou perto do ponto, para um pouco
}

// Ajusta o sprite (olhar para esquerda/direita)
if (hspeed != 0) {
    image_xscale = sign(hspeed) * escala_base;
}

// ========================================================
// 3. LÓGICA DE SOLTAR PÓLEN
// ========================================================
var _enemy_near = instance_nearest(x, y, par_inimigos); 

if (_enemy_near != noone && distance_to_object(_enemy_near) < 50) {
    // Chance por frame de soltar pólen
    if (random(1) < pollen_chance) {
        var _pollen = instance_create_layer(x, y, "Instances", obj_butterfly_pollen);
        _pollen.damage = damage;
        _pollen.radius = pollen_radius;
    }
}