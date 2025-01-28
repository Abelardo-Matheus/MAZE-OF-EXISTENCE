if(global.level_up == true){
	image_speed = 0;
	speed = 0;
	exit;		
}else{
	speed = veloc;
}
// Atualiza o ângulo para orbitar
angle += speed;

// Calcula a posição com base no jogador
x = obj_player.x + lengthdir_x(radius, angle);
y = obj_player.y + lengthdir_y(radius, angle);

// Reduz a duração em frames
duration--;
if (duration <= 0) {
    // Marca as shurikens como inativas quando todas terminarem
    if (instance_number(obj_shuriken) == 1) {
        global.shuriken_active = false;
    }
    instance_destroy(); // Destroi a shuriken
}


// Gira o bumerangue
image_angle += speed * 4;