// feather disable GM2017
// Detectar distância do jogador
var _dist = point_distance(x, y, obj_player.x, obj_player.y);

// Se o jogador estiver próximo e apertar F
if ((_dist < distancia_interacao and interacao_pedida()) or abrir_venda) { // tecla Interagir (scr_interacao)
    venda_aberta = !venda_aberta; // abre/fecha a loja
	abrir_venda = false;
}
// Afastou do vendedor: fecha a loja
if (venda_aberta && _dist > distancia_interacao * 1.5) venda_aberta = false;


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


