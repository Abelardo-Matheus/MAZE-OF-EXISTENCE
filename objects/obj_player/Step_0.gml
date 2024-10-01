ganhar_xp(1);
script_execute(state);
depth = -y;
if(global.estamina <= global.max_estamina && !andar){
global.estamina += 0.5;
}

if (global.estamina <= 0 && !andar){
andar = true;
global.estamina = 0;
alarm[0] = 50;
}
