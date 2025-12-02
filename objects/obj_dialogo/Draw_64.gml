/// @desc Renderização da Interface de Diálogo
/// [O QUE]: Desenha a caixa de texto, retrato e nome baseados no lado (Esquerda/Direita). Gerencia o menu de escolhas se necessário.
/// [COMO] : 
/// 1. Extrai dados da Grid usando o Enum.
/// 2. Desenha o fundo preto e o texto baseado no alinhamento (Lado 0 ou 1).
/// 3. Se 'draw_options' for true, desenha o menu de seleção e processa o input do teclado.

// Verifica se inicializou
if (initialized == true) 
{
    
	

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    // --- Configurações de Layout ---
    var _box_height = 200;
    var _box_y = _gui_h - _box_height;
    var _padding = 32;
    var _color_bg = c_black;
    
    // --- Extração de Dados ---
    // Pega o sprite, o texto cortado (efeito digitar) e o alinhamento
    var _current_portrait = text_grid[# DialogInfo.PORTRAIT, page];
    var _current_text = string_copy(text_grid[# DialogInfo.TEXT, page], 0, char_index);
    var _current_name = text_grid[# DialogInfo.NAME, page];
    var _alignment = text_grid[# DialogInfo.SIDE, page]; // 0 = Esquerda, 1 = Direita
	
	
    draw_set_font(fnt_dialogos);

    // ============================================================
    // PARTE 1: CAIXA DE DIÁLOGO E RETRATO
    // ============================================================
    
    if (_alignment == 0) 
    {
        // --- LADO ESQUERDO (NPC) ---
        // Fundo
        draw_rectangle_color(200, _box_y, _gui_w, _gui_h, _color_bg, _color_bg, _color_bg, _color_bg, false);
        
        // Texto e Nome
        draw_text_ext(232, _box_y + _padding, _current_text, 32, _gui_w - 264);
        draw_text(216, _box_y - 32, _current_name);
        
        // Retrato (Na esquerda)
        draw_sprite_ext(_current_portrait, 0, 100, _gui_h, 6, 6, 0, c_white, 1);
    } 
    else 
    {
        // --- LADO DIREITO (PLAYER) ---
        // Fundo
        draw_rectangle_color(0, _box_y, _gui_w - 200, _gui_h, _color_bg, _color_bg, _color_bg, _color_bg, false);
        
        // Texto e Nome
        var _name_width = string_width(_current_name);
        draw_text_ext(32, _box_y + _padding, _current_text, 32, _gui_w - 264);
        draw_text(_gui_w - 216 - _name_width, _box_y - 32, _current_name);
        
        // Retrato (Na direita, espelhado com -6)
        draw_sprite_ext(_current_portrait, 0, _gui_w - 100, _gui_h, -6, 6, 0, c_white, 1);
    }

    // ============================================================
    // PARTE 2: MENU DE OPÇÕES (ESCOLHAS)
    // ============================================================
    
    if (op_draw) 
    {
        var _op_x = 32;
        var _op_y = _box_y - 48;
        var _op_sep = 48; // Separação vertical
        var _op_border = 6;
        
        // --- Input de Seleção ---
        // W sobe (index diminui), S desce (index aumenta)
        // Usamos a subtração direta dos booleanos para obter -1, 0 ou 1
        var _input_dir = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));
        
        if (_input_dir != 0) {
            op_selected += _input_dir;
            // Garante que a seleção não saia dos limites (Loop ou Clamp)
            op_selected = clamp(op_selected, 0, op_num - 1);
        }
        
        // --- Desenho das Opções ---
        draw_set_font(fnt_escolhas);
        
        for (var i = 0; i < op_num; i++) 
        {
            var _string_w = string_width(op[i]);
            var _current_y = _op_y - (_op_sep * i); // Desenha de baixo para cima
            
            // Fundo da Opção
            draw_sprite_ext(spr_bloco, 0, _op_x, _current_y, (_string_w + _op_border * 2) / 16, 1, 0, c_white, 1);
            
            // Texto da Opção
            draw_text(_op_x + _op_border, _current_y - 3, op[i]);
            
            // Seletor (Setinha)
            if (op_selected == i) 
            {
                draw_sprite(spr_seletor, 0, 15, _current_y + 15);
            }
        }
        
        // --- Confirmação ---
        if (keyboard_check_pressed(ord("E"))) 
        {
            // Cria um novo diálogo baseado na resposta escolhida
            var _next_dialog_id = op_resposta[op_selected];
            var _new_dialog = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
            _new_dialog.npc_nome = _next_dialog_id;
            
            // Destrói o diálogo atual (substituição)
            instance_destroy();
        }
    }
}