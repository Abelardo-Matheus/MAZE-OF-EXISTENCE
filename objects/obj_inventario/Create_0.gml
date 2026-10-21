// feather disable GM2017
/// @desc Inventário: dados, layout e itens iniciais
/// Lógica de itens: scripts/inventario  |  Database: scripts/itens_geral

// ========================================================
// 1. ESTADO
// ========================================================
is_open = false;

grid_cols   = 6;
grid_rows   = 3;
total_slots = grid_cols * grid_rows;      // mochila
equip_slots_count = 3;                    // arma, armadura, calçado (ficam no fim da grid)
slot_index_weapon = total_slots;
slot_index_armor  = total_slots + 1;
slot_index_boots  = total_slots + 2;

// Mouse
hover_slot     = -1;   // slot embaixo do mouse
selected_slot  = -1;   // slot aberto na OFICINA (clique)
drag_slot      = -1;   // slot que está sendo arrastado
drag_ativo     = false;
drag_px        = 0;
drag_py        = 0;
hover_craft    = -1;   // receita embaixo do mouse
hover_upgrade  = false;
bau_hover      = { lado: -1, slot: -1 }; // slot embaixo do mouse no painel do baú (lado 0 = baú, 1 = mochila)

// Mensagem rápida (inventory_msg)
msg_texto = "";
msg_cor   = c_white;
msg_timer = 0;

// Craft
crafts_disponiveis = ds_list_create();
craft_ordem   = [];
craft_scroll  = 0;
craft_linhas  = 3;     // receitas visíveis de uma vez

// ========================================================
// 2. LAYOUT — tudo medido em PIXELS do spr_iinventario (586x379)
//    e convertido para a GUI pela escala. Para ajustar, mude aqui.
// ========================================================
lay_slot_x   = [24, 74, 125, 176, 227, 278]; // início (x) da parte bege de cada coluna
lay_slot_y   = [78, 132, 186];               // início (y) de cada linha
lay_slot_w   = 43;
lay_slot_h   = 45;
lay_equip_x  = 515;                           // coluna dos 3 equipamentos (mesmas linhas)

lay_status   = [369,  77, 507, 232];          // área do boneco + atributos
lay_moedas   = [ 19, 272, 106, 291];          // caixinha pequena (moedas)
lay_oficina  = [147, 272, 327, 362];          // painel do item selecionado / upgrade
lay_craft    = [367, 272, 568, 362];          // painel de craft
lay_btn_up   = [276, 343, 323, 358];          // botão MELHORAR / USAR (dentro da oficina)

scale       = 2.5;
inventory_x = 0;
inventory_y = 0;
inventory_w = sprite_get_width(spr_iinventario)  * scale;
inventory_h = sprite_get_height(spr_iinventario) * scale;

/// Recalcula escala/posição para caber em qualquer resolução da GUI
calcular_layout = function() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _sw = sprite_get_width(spr_iinventario);
    var _sh = sprite_get_height(spr_iinventario);
    scale = max(1, floor(min(_gw * 0.94 / _sw, _gh * 0.90 / _sh) * 2) / 2);
    inventory_w = _sw * scale;
    inventory_h = _sh * scale;
    inventory_x = floor(_gw / 2 - inventory_w / 2);
    inventory_y = floor(_gh / 2 - inventory_h / 2);
};

/// Converte coordenada do sprite -> GUI
ux = function(_px) { return inventory_x + _px * scale; };
uy = function(_py) { return inventory_y + _py * scale; };

/// Retângulo (GUI) do slot _i: [x1, y1, x2, y2]
slot_rect = function(_i) {
    var _x, _y;
    if (_i < total_slots) {
        _x = lay_slot_x[_i mod grid_cols];
        _y = lay_slot_y[_i div grid_cols];
    } else {
        _x = lay_equip_x;
        _y = lay_slot_y[_i - total_slots];
    }
    return [ux(_x), uy(_y), ux(_x + lay_slot_w), uy(_y + lay_slot_h)];
};

/// Retângulo (GUI) da linha _linha do craft e do botão CRIAR dela
craft_row_rect = function(_linha) {
    var _h = (lay_craft[3] - lay_craft[1] - 4) / craft_linhas;
    var _y1 = lay_craft[1] + 2 + _linha * _h;
    return [ux(lay_craft[0] + 2), uy(_y1), ux(lay_craft[2] - 8), uy(_y1 + _h - 1)];
};
craft_btn_rect = function(_linha) {
    var _r = craft_row_rect(_linha);
    var _bw = 34 * scale, _bh = 15 * scale;
    var _cy = (_r[1] + _r[3]) / 2;
    return [_r[2] - _bw - 2 * scale, _cy - _bh / 2, _r[2] - 2 * scale, _cy + _bh / 2];
};

calcular_layout();

// ========================================================
// 3. MOCHILA (DS GRID)
// ========================================================
global.grid_itens = ds_grid_create(INFOS.HEIGHT, total_slots + equip_slots_count);
ds_grid_clear(global.grid_itens, -1);
global.inventario_cheio = false;

// ========================================================
// 4. GLOBAIS DE STATUS (segurança)
// ========================================================
if (!variable_global_exists("moedas"))         global.moedas = 0;
if (!variable_global_exists("mata_fantasma"))  global.mata_fantasma = false;
if (!variable_global_exists("vida"))           global.vida = 100;
if (!variable_global_exists("vida_max"))       global.vida_max = 100;
if (!variable_global_exists("ataque"))         global.ataque = 10;
if (!variable_global_exists("armadura_bebe"))  global.armadura_bebe = 0;
if (!variable_global_exists("speed_player"))   global.speed_player = 4;
if (!variable_global_exists("level_player"))   global.level_player = 1;
if (!variable_global_exists("dano_base"))      global.dano_base = array_create(100, 5);
// Se o inventário foi recriado (restart de sala), tira o bônus antigo antes de zerar
if (variable_global_exists("equip_aplicado")) {
    global.speed_player -= global.equip_aplicado.vel;
    global.vida_max     -= global.equip_aplicado.vida;
}
global.equip_aplicado = { vel: 0, vida: 0 };
global.buffs_ativos   = [];

// ========================================================
// 5. DATABASE DE ITENS + RECEITAS (scripts/itens_geral)
// ========================================================
criar_lista_itens_padronizados();

// ========================================================
// 6. ITENS INICIAIS (teste do craft / upgrade / adesivos)
//    Coloque false para começar com a mochila vazia.
// ========================================================
itens_iniciais_teste = true;
if (itens_iniciais_teste) {
    inventory_add("madeira", 6);
    inventory_add("pedra", 4);
    inventory_add("erva", 5);
    inventory_add("frasco", 3);
    inventory_add("couro", 5);
    inventory_add("ferro", 4);
    inventory_add("papel", 5);
    inventory_add("la", 4);
    inventory_add("po_estrela", 6);
    inventory_add("pilha", 2);
    inventory_add("ad_coracao", 1);
    inventory_add("biscoito", 3);
    inventory_add("espada_madeira", 1);
}

atualizar_crafts_disponiveis();
player_stats_recalcular();
