inventario = false;
escala = 2.5;

comeco_x = 21 *escala;
comeco_y = 74 *escala;
sprite_indexX = -1;
comeco_x_status = 513 *escala;
comeco_y_status = 74 *escala;


comeco_x_nome = 19;
comeco_y_nome = 272;

comeco_x_descricao = 147+90;
comeco_y_descricao = 271;

slot_arma = -1;
slot_armadura = -1;
slot_bota = -1;
	
slot_status_h = 1;
slot_status_v = 3;
total_slot_status = slot_status_h* slot_status_v;
slots_h = 6;
slots_v = 3;
total_slots = slots_h*slots_v;
tamanho_slot_x = 49 * escala;
tamanho_slot_y = 52.3 * escala;
ind = -1;
buffer = 1.9 *escala;

inventario_w = sprite_get_width(spr_iinventario)*escala;
inventario_h = sprite_get_height(spr_iinventario)*escala;
global.inventario_cheio = false; 
item_selecionado = -1;
pos_selecionada = -1;
pos_index_selecionada = -1;
tempo_cooldown = 0;  // Inicialize o cooldown

arma_equipada = false;
armadura_equipada = false;
bota_equipada = false;

enum itens_ativos{
	batata,
	maca,
	banana,
	uva,
	vitamina,
	leite,
	Altura
	
}

enum itens_passivos{
	Vela,
	cobertor,
	bota,
	Altura
	
}

enum itens_armas{
	graveto,
	vassoura,
	espada_madeira,
	espada_plastico,
	espada_ouro,
	espada_mata_fantasma,
	Altura
	
}

enum itens_pe{
	tenis_velho,
	sapato_velho,
	patins,
	skate,
	tenis_novo,
	sapato_novo,
	meia_vermelha,
	meia_amarela,
	Altura
	
}


enum Infos {
    item,
    quantidade,
    sprite,
    nome,
    descricao,
    sala_x,
    sala_y,
    pos_x,
    pos_y,
    dano,  // Adicione dano
    armadura,  // Adicione armadura
    velocidade,  // Adicione velocidade
	cura,
	tipo,
	image_ind,
    Altura
}


global.grid_itens = ds_grid_create(Infos.Altura,total_slots+3);
ds_grid_set_region(global.grid_itens, 0, 0, Infos.Altura-1, total_slots-1+3, -1);

