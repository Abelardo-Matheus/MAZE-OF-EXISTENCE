// ==========================================
// EVENTO STEP - Foco total na Interação
// ==========================================
depth = -y;

// Segurança: Garante que não vai dar erro se o player morrer ou não existir
if (instance_exists(obj_player)) 
{
    // ==========================================
    // INTERAÇÃO DE ENTRADA (F)
    // ==========================================
    if (point_distance(x, y, obj_player.x, obj_player.y) <= 400) 
    {
        // Marca que o jogador está na porta
        obj_player.proximo_de_estrutura = true;
        
        // Verifica o botão de ação
        if (keyboard_check_pressed(ord("F"))) 
        {
            global.pos_x_map = x;
            global.pos_y_map = y;
            global.seed_atual = seed; // Passa a seed desta casa para o gerador de salas ler!
            global.current_sala = [0, 0];
            
            room_goto(Fase_BEBE);
        }
    }

    // ==========================================
    // SISTEMA DE TRANSPARÊNCIA (Apenas Atrás)
    // ==========================================
    
    // 1. Verifica se o player está na área horizontal do objeto (Largura)
    var _max_x = (sprite_width / 2) * 0.8; 
    var _dentro_x = abs(obj_player.x - x) < _max_x;

    // 2. Verifica se o player está "Atrás" visualmente (Altura)
    // O Y do player deve ser menor que a base do objeto (y), mas não pode passar do topo (y - sprite_height)
    var _atras_y = (obj_player.y < y) && (obj_player.y > y - sprite_height/2);

    // Se as duas condições forem verdadeiras, o player sumiu atrás da imagem
    if (_dentro_x && _atras_y) 
    {
        image_alpha = 0.2; // Fica transparente
        solid = false;     // Tira a colisão
    } 
    // Se o player estiver na frente, do lado ou longe
    else 
    {
        // Só muda o alpha se precisar (economiza processamento)
        if (image_alpha != 1.0) {
            image_alpha = 1.0; 
        }
        
        // Devolve a colisão se o player já tiver saído de dentro do objeto
        if (solid == false && !place_meeting(x, y, obj_player)) {
            solid = true;
        }
    }
}