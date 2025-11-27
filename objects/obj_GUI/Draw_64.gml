
// ============================================================
// PARTE 1: TELA DE LEVEL UP (Misto: Armas e Itens)
// ============================================================
if (global.level_up == true) 
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    // Dimmer
    draw_set_alpha(0.7);
    draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // Configurações Visuais
    var _base_scale = 1;
    var _sprite_h = sprite_get_height(spr_level_up_hud);
    var _sprite_w = sprite_get_width(spr_level_up_hud);
    var _padding_x = 50;
    var _start_x = 270;
    var _center_y = _gui_h / 2;
    
    var _mouse_gui_x = device_mouse_x_to_gui(0);
    var _mouse_gui_y = device_mouse_y_to_gui(0);
    
    // Otimização: Cache do tamanho da lista para o loop
    var _options_count = ds_list_size(global.upgrades_vamp_list);

   for (var i = 0; i < _options_count; i++) 
    {
        // Pega o dado da lista
        var _data_raw = global.upgrades_vamp_list[| i];
        
        var _type = 0;
        var _id = 0;

        // --- PROTEÇÃO CONTRA CRASH ---
        if (is_array(_data_raw)) 
        {
            // É o formato novo [TIPO, ID]
            _type = _data_raw[0];
            _id   = _data_raw[1];
        } 
        else 
        {
            // É o formato antigo (apenas ID). Assumimos que é Arma (0).
            _type = 0; 
            _id   = _data_raw;
        }

        // Variáveis temporárias...
        var _name, _desc, _script, _sprite_icon;
        
        if (_type == 0) 
        {
            // É ARMA (UPGRADE)
            _name   = global.upgrades_vamp_grid[# Upgrades_vamp.Name, _id];
            _desc   = global.upgrades_vamp_grid[# Upgrades_vamp.description, _id];
            _script = global.upgrades_vamp_grid[# Upgrades_vamp.Script, _id];
            _sprite_icon = spr_ups_vamp; // Sprite sheet das armas
        } 
        else 
        {
            // É ITEM PASSIVO
            _name   = global.itens_vamp_grid[# Itens_vamp.Name, _id];
            _desc   = global.itens_vamp_grid[# Itens_vamp.description, _id];
            _script = global.itens_vamp_grid[# Itens_vamp.Script, _id];
            // ATENÇÃO: Crie um sprite para itens passivos ou use o mesmo se estiverem juntos
            _sprite_icon = spr_itens_vamp; // Sprite sheet dos itens
        }

        // Posicionamento
        var _card_x = _start_x + (_sprite_w + _padding_x) * i;
        
        // Animação Hover
        var _current_scale = 1;
        var _current_alpha = 0.75;
        var _icon_y_offset = 23;
        var _text_y_offset = 0;

        // --- Interação ---
        if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, _card_x - _sprite_w/2, _center_y - _sprite_h/2, _card_x + _sprite_w/2, _center_y + _sprite_h/2)) 
        {
            _current_alpha = 1;
            _current_scale += 0.2;
            _icon_y_offset = -8;
            _text_y_offset = 65;
            
            // Clique
            if (mouse_check_button_pressed(mb_left)) 
            {
                // Executa lógica específica dependendo do tipo
                if (_type == 0) {
                    // Lógica de subir nível da ARMA
                    // (Assumindo que você tem essa função ou faz manual)
                    var _lvl = global.upgrades_vamp_grid[# Upgrades_vamp.level, _id];
                    global.upgrades_vamp_grid[# Upgrades_vamp.level, _id] = _lvl + 1;
                } else {
                    // Lógica de subir nível do ITEM
                    var _lvl = global.itens_vamp_grid[# Itens_vamp.level, _id];
                    global.itens_vamp_grid[# Itens_vamp.level, _id] = _lvl + 1;
                }

                // Adiciona Script aos Ativos (Funciona para ambos se o script existir)
                if (_script != -1) {
                    // Verifica se já não está na lista para evitar duplicação (opcional)
                    if (ds_list_find_index(global.active_upgrades, _script) == -1) {
                        ds_list_add(global.active_upgrades, _script);
                    }
                    
                    // Se for item passivo (como a Pena), executa uma vez agora para aplicar status
                    if (_type == 1) {
                        script_execute(_script);
                    }
                }

                global.level_up = false;
                break;
            }
        }

        // --- Desenho ---
        // Fundo
        draw_sprite_ext(spr_level_up_hud, -1, _card_x, _center_y, _current_scale, _current_scale, 0, c_white, _current_alpha);
        
        // Ícone (Usa o sprite correto selecionado acima)
        draw_sprite_ext(_sprite_icon, _id, _card_x, _center_y - (_sprite_h/4) + _icon_y_offset, _current_scale, _current_scale, 0, c_white, _current_alpha);
        
        // Textos
        draw_set_font(fnt_nomes_up);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_colour_outline(_card_x, _center_y - (_sprite_h/2) - _text_y_offset, _name, 4, c_white, 8, 100, 100);
        
        draw_set_font(fnt_descricao);
        draw_text_colour_outline_escalado(_card_x, _center_y + (_sprite_h/4) - 90, _desc, 3, c_white, 7, 30, 300, _current_scale, _current_scale);
    }
    
    alarm[0]++; 
    exit; 
}


// ============================================================
// PARTE 2: HUD DE JOGO (Timer e Status)
// ============================================================

// --- Relógio / Timer ---
global.minutes = floor(global.timer / 60);
global.seconds = floor(global.timer) mod 60;

// Formatação com zero à esquerda (Pad)
var _str_min = (global.minutes < 10) ? "0" + string(global.minutes) : string(global.minutes);
var _str_sec = (global.seconds < 10) ? "0" + string(global.seconds) : string(global.seconds);
var _time_text = _str_min + ":" + _str_sec;

// Desenha Timer
draw_set_font(fnt_nomes_itens);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text_colour_outline_escalado(display_get_gui_width() / 2, 10, _time_text, 3, c_black, 7, 30, 300, 1, 1);

// --- Elementos do HUD ---
desenha_barra_vida();

// Minimapa Contextual
if (global.map_bebe) 
{
    mini_mapa_bebe();
} 
else if (global.map_vamp) 
{
    mini_mapa_vamp();
}