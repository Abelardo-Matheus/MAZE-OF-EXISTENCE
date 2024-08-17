// Inicializar a direção inicial se ainda não estiver definida
randomize();
if (!variable_instance_exists(id, "direction")) {
    direction = choose(0, 90, 180, 270); // Direções iniciais: direita, cima, esquerda, baixo
}

// Movimento do inimigo
var current_speed = enemy_speed;

// Definir o array de direções fora da verificação de colisão
var directions = [0, 90, 180, 270]; // Todas as direções possíveis

// Inicializar a variável valid_directions
var valid_directions = [];

// Verificar se o inimigo está centralizado na grid (no meio do tile de 64x64)
if ((x mod global.cell_size == global.cell_size / 2) && (y mod global.cell_size == global.cell_size / 2)) {
    
    // Verificar as direções disponíveis
    for (var i = 0; i < 4; i++) {
        var new_direction = directions[i];
        var new_x = x + lengthdir_x(current_speed, new_direction);
        var new_y = y + lengthdir_y(current_speed, new_direction);

        // Verificar se não há parede na nova direção
        if (!place_meeting(new_x, new_y, obj_wall) && !place_meeting(new_x, new_y, obj_wall_cima)) {
            // Evitar retornar ao caminho anterior imediatamente
            if (new_direction != (direction + 180) mod 360) {
                array_push(valid_directions, new_direction);
            }
        }
    }

    // Se houver mais de duas direções livres, escolher uma aleatoriamente
    if (array_length_1d(valid_directions) > 1) {
        // Parada rápida na bifurcação
        current_speed = 0; // Faz a parada
        alarm[0] = 60*5; // Define um alarme para retomar o movimento após 10 steps (ajuste conforme necessário)
		current_speed = enemy_speed;
        direction = valid_directions[irandom(array_length_1d(valid_directions) - 1)];
        show_debug_message("At bifurcation. Chosen direction: " + string(direction));
    } else if (array_length_1d(valid_directions) == 2) {
        // Se houver apenas duas direções livres, continuar na direção atual até colidir
        show_debug_message("Two paths available, continuing in current direction: " + string(direction));
    } else if (array_length_1d(valid_directions) == 0) {
        // Se não houver direções válidas, permitir retornar à direção anterior (beco sem saída)
        direction = (direction + 180) mod 360;
        show_debug_message("Dead end detected, reversing direction: " + string(direction));
    }
}

// Verificar colisão com a parede antes de mover
if (place_meeting(x + lengthdir_x(current_speed, direction), y + lengthdir_y(current_speed, direction), obj_wall) || 
    place_meeting(x + lengthdir_x(current_speed, direction), y + lengthdir_y(current_speed, direction), obj_wall_cima)) {

    // Calcular a distância exata até a colisão e mover o inimigo até lá
    while (!place_meeting(x + sign(lengthdir_x(1, direction)), y + sign(lengthdir_y(1, direction)), obj_wall) && 
           !place_meeting(x + sign(lengthdir_x(1, direction)), y + sign(lengthdir_y(1, direction)), obj_wall_cima)) {
        x += sign(lengthdir_x(1, direction));
        y += sign(lengthdir_y(1, direction));
    }

    show_debug_message("Collision detected at X: " + string(x) + ", Y: " + string(y));

    // Se colidir, escolher uma nova direção válida aleatoriamente entre as disponíveis
    if (array_length_1d(valid_directions) > 0) {
        direction = valid_directions[irandom(array_length_1d(valid_directions) - 1)];
        show_debug_message("New direction after collision: " + string(direction));
    } else {
        // Caso raro onde todas as direções estão bloqueadas, o inimigo escolhe a única direção possível (volta)
        direction = (direction + 180) mod 360;
        show_debug_message("No valid directions available. Reversing direction: " + string(direction));
    }
} else {
    // Movimento suave até o destino
    x += lengthdir_x(current_speed, direction);
    y += lengthdir_y(current_speed, direction);
}
