relogio();
// ============================================================
// PARTE 1: TELA DE LEVEL UP (Misto: Armas e Itens)
// ============================================================
if (global.level_up == true) 
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    // ========================================================
    // --- 1. Dimmer (Fundo Escuro) ---
    // ========================================================
    draw_set_alpha(0.7);
    draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // ========================================================
    // --- TEXTO: AVISO DE NÍVEIS ACUMULADOS (NOVO!) ---
    // ========================================================
    if (variable_global_exists("levels_pendentes") && global.levels_pendentes > 1) {
        draw_set_font(fnt_nomes_up); 
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        var _aviso = "Niveis Acumulados: " + string(global.levels_pendentes);
        draw_text_colour_outline(_gui_w / 2, 50, _aviso, 4, c_yellow, 8, 100, 100);
    }
    
    // ========================================================
    // --- 2. Configurações Visuais e Proteção ---
    // ========================================================
    // Otimização: Cache do tamanho da lista sorteada
    var _options_count = ds_list_size(global.upgrades_vamp_list);
    
    // Se não houver opções, não desenha nada (para evitar erros) e sai
    if (_options_count <= 0) exit; 

    // Configurações de tamanho do HUD de fundo
    var _sprite_h = sprite_get_height(spr_level_up_hud);
    var _sprite_w = sprite_get_width(spr_level_up_hud);
    
    var _padding_x = 50; // Espaço entre as cartas
    
    // Cálculo Dinâmico para Centralizar as Cartas
    var _total_width_cards = (_sprite_w * _options_count) + (_padding_x * (_options_count - 1));
    var _start_x = (_gui_w / 2) - (_total_width_cards / 2) + (_sprite_w / 2); // X do centro da primeira carta
    var _center_y = _gui_h / 2;
    
    // Coordenadas do Mouse na GUI
    var _mouse_gui_x = device_mouse_x_to_gui(0);
    var _mouse_gui_y = device_mouse_y_to_gui(0);
    
    // ========================================================
    // --- 3. LOOP DE DESENHO E INTERAÇÃO DAS CARTAS ---
    // ========================================================
    for (var i = 0; i < _options_count; i++) 
    {
        // Pega o Struct de dados sorteado
        var _card_data = global.upgrades_vamp_list[| i];
        
        // --- PROTEÇÃO CONTRA CRASH ---
        if (!is_struct(_card_data)) 
        {
            continue; // Pula esta carta para não dar crash
        }

        // --------------------------------------------------------
        // --- A. EXTRAÇÃO DE DADOS (ESTILO DATA-DRIVEN) ---
        // --------------------------------------------------------
        var _name          = _card_data.nome;
        var _desc          = _card_data.description; 
        var _next_lvl      = _card_data.next_level;       
        var _sprite_icon   = _card_data.sprite;        
        var _type          = _card_data.type;        
        var _row_index     = _card_data.id_grid;   

        // Posicionamento X da carta i
        var _card_x = _start_x + (_sprite_w + _padding_x) * i;
        
        // Configurações de Animação Hover (Valores Padrão)
        var _current_scale = 1;
        var _current_alpha = 0.75;
        var _icon_y_offset = 23;
        var _text_y_offset = 0;

        // --------------------------------------------------------
        // --- B. INTERAÇÃO (HOVER E CLIQUE) ---
        // --------------------------------------------------------
        var _x1 = _card_x - (_sprite_w / 2);
        var _y1 = _center_y - (_sprite_h / 2);
        var _x2 = _card_x + (_sprite_w / 2);
        var _y2 = _center_y + (_sprite_h / 2);

        if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, _x1, _y1, _x2, _y2)) 
        {
            // Efeito Visual Hover
            _current_alpha = 1;
            _current_scale = 1.2; // Aumenta tamanho
            _icon_y_offset = -8;   // Sobe o ícone
            _text_y_offset = 65;   // Sobe o texto do nome
            
            // ====================================================
            // --- Clique Esquerdo (LÓGICA DE FILA ATUALIZADA) ---
            // ====================================================
            if (mouse_check_button_pressed(mb_left)) 
            {
                // 1. APLICAÇÃO DO LEVEL UP NA ARMA/ITEM
                if (_type == 0) { // ARMA
                    global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index] += 1;
                } else { // ITEM
                    global.itens_vamp_grid[# Itens_vamp.level, _row_index] += 1;
                }

                // 2. GERENCIA A FILA DE LEVEL UPS PENDENTES
                if (variable_global_exists("levels_pendentes")) {
                    global.levels_pendentes -= 1;
                    
                    if (global.levels_pendentes > 0) {
                        // Sorteia cartas novas imediatamente para o próximo level!
                        level_upp(); 
                    } else {
                        // Fila acabou, fecha o menu
                        global.level_up = false;
                        global.levels_pendentes = 0;
                    }
                } else {
                    // Fallback caso a variável não exista (fecha o menu normal)
                    global.level_up = false;
                }
                
                // break sai do loop para evitar cliques duplos indesejados
                break; 
            }
        }

        // --------------------------------------------------------
        // --- C. DESENHO FINAL (VISUAL) ---
        // --------------------------------------------------------
        
        // --- 1. Fundo da Carta ---
        draw_sprite_ext(spr_level_up_hud, -1, _card_x, _center_y, _current_scale, _current_scale, 0, c_white, _current_alpha);
        
        // --- 2. Ícone Individual ---
        var _icon_final_y = _center_y - (_sprite_h / 4) + _icon_y_offset;
        
        if (sprite_exists(_sprite_icon)) {
            draw_sprite_ext(_sprite_icon, 0, _card_x, _icon_final_y, _current_scale * 2, _current_scale * 2, 0, c_white, _current_alpha);
        }
        
        // --- 3. Textos ---
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // NOME DA SKILL
        draw_set_font(fnt_nomes_up); 
        var _name_display = _name ;
        draw_text_colour_outline(_card_x, _center_y - (_sprite_h/2) - _text_y_offset, _name_display, 4, c_white, 8, 100, 100);
        
        // NÍVEL E DESCRIÇÃO
        draw_set_font(fnt_descricao); 
        var _desc_y = _center_y + (_sprite_h / 4) - 90;
        
        draw_text_colour_outline_escalado(_card_x - 2, _desc_y - 90, string(_next_lvl), 3, c_white, 7, 30, 300, _current_scale*2, _current_scale*2);
        draw_text_colour_outline_escalado(_card_x, _desc_y, _desc, 3, c_white, 7, 30, 300, _current_scale, _current_scale);
    }
    
    exit; // Sai para não desenhar o resto da GUI normal
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

draw_fps();