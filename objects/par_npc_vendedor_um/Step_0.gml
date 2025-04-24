// Detectar distância do jogador
var dist = point_distance(x, y, obj_player.x, obj_player.y);

// Se o jogador estiver próximo e apertar F
if ((dist < distancia_interacao and keyboard_check_pressed(ord("F")) or abrir_venda)) {
    venda_aberta = !venda_aberta; // abre/fecha a loja
	abrir_venda = false;
}


switch dig{
  case 0:
	nome = "Primeiro_encontro";
	break;
  case 1:
	nome = "Segundo_encontro";
	break;
 case 2:
	nome = "Depois_de_compra";
	break;
 case 3:
	nome = "Adeus";
 break;
}


