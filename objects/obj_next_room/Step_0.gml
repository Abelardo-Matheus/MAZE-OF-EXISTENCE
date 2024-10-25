// Contar o número total de inimigos na sala (todos os inimigos que têm 'par_inimigos' como parente)
var total_inimigos = instance_number(par_inimigos)+instance_number(par_boss);

//if (total_inimigos == 0) {
//    global.permitido = true;  // Não há mais inimigos na sala
//	image_speed = 1;  // Define a velocidade da animação, ajuste conforme necessário
//	if(image_index == 7){
//	image_speed = 0;
//	}
//} else {
//    global.permitido = false; // Ainda há inimigos na sala
//	image_speed = 1;  // Pausa a animação
//	image_index = 0;  // Começa a animação do início (opcional)
//}
