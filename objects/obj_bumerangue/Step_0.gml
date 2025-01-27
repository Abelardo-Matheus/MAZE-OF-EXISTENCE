if(global.level_up == true){
	image_speed = 0;
	speed = 0;
	exit;		
}else{
	speed = veloc;
}
if (!returning) {
    // Move em direção ao alvo
    if (instance_exists(target)) {
        direction = point_direction(x, y, target.x, target.y);
    } else {
        // Se o alvo não existe, começa a voltar ao jogador
        returning = true;
    }
} else {
    // Volta para o jogador
    direction = point_direction(x, y, obj_player.x, obj_player.y);

    // Destrói ao alcançar o jogador
    if (point_distance(x, y, obj_player.x, obj_player.y) <= 10) {
        ds_list_destroy(targets); // Limpa a lista local
        instance_destroy();
    }
}

// Movimento
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);

// Gira o bumerangue
image_angle += speed * 2;

