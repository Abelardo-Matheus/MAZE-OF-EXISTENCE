// feather disable GM2017
/// @desc Baú colocado pelo jogador (casa ou mundo aberto). Criado por bau_instanciar() — itens_geral.gml
dados   = undefined; // struct salvo em bau_lista_atual() { x, y, cw, item_id, slots, spr, escala, grid }
grid    = -1;        // ds_grid com os itens guardados (INFOS.HEIGHT colunas x slots linhas)
slots   = 6;
aberto  = false;
perto   = false;     // player perto o bastante pra abrir com E (e este é o baú mais próximo)
colisao = noone;     // caixa de colisão do pé (mesmo objeto de parede que o player usa)

solid = false;       // a colisão fica na caixa do pé; o sprite inteiro não bloqueia nada
image_speed = 0;
image_index = 0;     // 0 = fechado, 1 = aberto (igual aos móveis de casa — scr_casa_moveis)
