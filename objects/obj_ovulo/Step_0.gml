// Step Event do obj_ovulo (inimigo)

// Definir velocidade do inimigo (óvulo)
var move_speed = 8; // Ajuste a velocidade conforme necessário
var detection_radius = 100; // Distância em que o inimigo percebe o jogador

// Verificar a distância até o jogador
var player = instance_find(obj_SPERM, 0);
if (player != noone) {
    var distance_to_player = point_distance(x, y, player.x, player.y);

    // Se o jogador estiver dentro do raio de detecção
    if (distance_to_player < detection_radius) {
        // Mover na direção oposta ao jogador
        var direction_away = point_direction(x, y, player.x, player.y) + 180;
        
        // Calcular a nova posição baseada na direção oposta
        var new_x = x + lengthdir_x(move_speed, direction_away);
        var new_y = y + lengthdir_y(move_speed, direction_away);
        
        // Verificar se a nova posição resultaria em colisão com uma parede
        if (!place_meeting(new_x, new_y, obj_wall_carne)) {
            // Se não houver colisão, mover na direção oposta ao jogador
            direction = direction_away;
            speed = move_speed;
        } else {
            // Caso contrário, tenta uma direção levemente ajustada (+/- 45 graus)
            direction_away += choose(45, -45);
            new_x = x + lengthdir_x(move_speed, direction_away);
            new_y = y + lengthdir_y(move_speed, direction_away);
            
            if (!place_meeting(new_x, new_y, obj_wall_carne)) {
                direction = direction_away;
                speed = move_speed;
            }
        }
    }
}

// Movimento aleatório se a velocidade for zero (óvulo parado)
if (speed == 0) {
    var random_direction = irandom_range(0, 360); // Direção aleatória
    direction = random_direction; // Definir a direção aleatória
    speed = move_speed; // Definir a velocidade
}

// Verificar se a nova posição colidirá com uma parede
if (place_meeting(x + lengthdir_x(speed, direction), y + lengthdir_y(speed, direction), obj_wall_carne)) {
    // Se colidir com uma parede, ricochetear
    move_bounce_solid(false);
}
// Verificar se a nova posição colidirá com uma parede
if (place_meeting(x + lengthdir_x(speed, direction), y + lengthdir_y(speed, direction), obj_wall_carne_circular)) {
    // Se colidir com uma parede, ricochetear
    move_bounce_solid(false);
}



