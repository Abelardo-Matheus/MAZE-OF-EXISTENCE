
script_execute(state);
depth = -y;
if(global.estamina <= global.max_estamina && !andar){
global.estamina += 0.5;
}

if(global.vida <= 0){
	game_end();
}

if (global.estamina <= 0 && !andar){
andar = true;
global.estamina = 0;
alarm[0] = 50;
}




