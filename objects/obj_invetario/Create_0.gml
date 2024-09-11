inventario = false;
escala = 2.5;

comeco_x = 21 *escala;
comeco_y = 74 *escala;

comeco_x_nome = 19;
comeco_y_nome = 272;

comeco_x_descricao = 147+90;
comeco_y_descricao = 271;


slots_h = 6;
slots_v = 3;
total_slots = slots_h*slots_v;
tamanho_slot_x = 49 * escala;
tamanho_slot_y = 52.3 * escala;

buffer = 1.9 *escala;

inventario_w = sprite_get_width(spr_iinventario)*escala;
inventario_h = sprite_get_height(spr_iinventario)*escala;

item_selecionado = -1;
pos_selecionada = -1;

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
	Altura
	
}


enum Infos{
	item,
	quantidade,
	sprite,
	nome,
	descricao,
	sala_x,
	sala_y,
	pos_x,
	pos_y,
	Altura
	
	
}

global.grid_itens = ds_grid_create(Infos.Altura,total_slots);
ds_grid_set_region(global.grid_itens, 0, 0, Infos.Altura-1, total_slots-1, -1);


