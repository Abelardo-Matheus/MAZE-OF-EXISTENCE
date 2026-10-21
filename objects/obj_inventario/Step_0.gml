// feather disable GM2017
/// @desc Passivas (sempre) + interação com o inventário (quando aberto)

// Baú aberto: o painel Baú | Mochila assume o mouse (itens_geral.gml -> bau_ui_step)
if (instance_exists(global.bau_aberto)) {
    is_open = false;
    itens_passivas_tick();
    if (msg_timer > 0) msg_timer--;
    drag_slot = -1; drag_ativo = false;
    bau_ui_step();
    exit;
}

// Regeneração e tempo dos buffs rodam com o inventário fechado
if (!is_open) {
    itens_passivas_tick();
    if (msg_timer > 0) msg_timer--;
    drag_slot = -1; drag_ativo = false;
    exit;
}
if (msg_timer > 0) msg_timer--;

calcular_layout();

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _grid = global.grid_itens;
var _n_slots = ds_grid_height(_grid);

// ========================================================
// 1. HOVER: slot, receita e botão de upgrade
// ========================================================
hover_slot = -1;
for (var _i = 0; _i < _n_slots; _i++) {
    var _r = slot_rect(_i);
    if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) { hover_slot = _i; break; }
}

hover_craft = -1;
var _n_rec = array_length(craft_ordem);
for (var _l = 0; _l < craft_linhas; _l++) {
    var _idx = craft_scroll + _l;
    if (_idx >= _n_rec) break;
    var _rr = craft_row_rect(_l);
    if (point_in_rectangle(_mx, _my, _rr[0], _rr[1], _rr[2], _rr[3])) { hover_craft = _l; break; }
}

hover_upgrade = point_in_rectangle(_mx, _my, ux(lay_btn_up[0]), uy(lay_btn_up[1]), ux(lay_btn_up[2]), uy(lay_btn_up[3]));

// Item selecionado sumiu/mudou? fecha a oficina
if (selected_slot != -1 && _grid[# INFOS.ITEM, selected_slot] == -1) selected_slot = -1;

// ========================================================
// 2. ARRASTAR E SOLTAR / CLICAR
// ========================================================
if (mouse_check_button_pressed(mb_left) && hover_slot != -1 && _grid[# INFOS.ITEM, hover_slot] != -1) {
    drag_slot  = hover_slot;
    drag_ativo = false;
    drag_px = _mx;
    drag_py = _my;
}

if (drag_slot != -1 && mouse_check_button(mb_left)) {
    if (!drag_ativo && point_distance(drag_px, drag_py, _mx, _my) > 6) drag_ativo = true;
}

if (drag_slot != -1 && mouse_check_button_released(mb_left)) {
    if (drag_ativo) {
        if (hover_slot != -1 && hover_slot != drag_slot) {
            var _era_sel = (selected_slot == drag_slot);
            inventory_mover(drag_slot, hover_slot);
            // a oficina acompanha o item que foi movido
            if (_era_sel && _grid[# INFOS.ITEM, hover_slot] != -1) selected_slot = hover_slot;
        }
    } else {
        // Clique simples: abre/fecha na oficina
        selected_slot = (selected_slot == drag_slot) ? -1 : drag_slot;
    }
    drag_slot  = -1;
    drag_ativo = false;
}

// ========================================================
// 3. TECLAS SOBRE O SLOT
// ========================================================
if (hover_slot != -1 && drag_slot == -1) {
    // Botão direito / E: usar, equipar ou desequipar
    if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("E"))) {
        inventory_use_item(hover_slot);
    }
    // F: soltar no chão
    if (keyboard_check_pressed(ord("F"))) {
        if (selected_slot == hover_slot) selected_slot = -1;
        inventory_drop_item(hover_slot);
    }
}

// ========================================================
// 4. OFICINA: upgrade (clique no botão ou tecla U)
// ========================================================
if (selected_slot != -1) {
    var _tipo_sel = _grid[# INFOS.TIPO, selected_slot];
    var _clique_btn = hover_upgrade && mouse_check_button_pressed(mb_left);
    if (_tipo_sel == "uso") {
        if (_clique_btn) inventory_use_item(selected_slot);          // botão USAR
    } else if (_clique_btn || keyboard_check_pressed(ord("U"))) {
        item_upgrade(selected_slot);                                 // botão MELHORAR / tecla U
    }
}

// ========================================================
// 5. CRAFT: scroll e botão CRIAR
// ========================================================
var _area_craft = point_in_rectangle(_mx, _my, ux(lay_craft[0]), uy(lay_craft[1]), ux(lay_craft[2]), uy(lay_craft[3]));
if (_area_craft) {
    if (mouse_wheel_down()) craft_scroll++;
    if (mouse_wheel_up())   craft_scroll--;
}
craft_scroll = clamp(craft_scroll, 0, max(0, _n_rec - craft_linhas));

if (mouse_check_button_pressed(mb_left) && hover_craft != -1) {
    var _b = craft_btn_rect(hover_craft);
    if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) {
        craft_fazer(craft_ordem[craft_scroll + hover_craft]);
    }
}
