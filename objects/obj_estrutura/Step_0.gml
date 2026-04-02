// ==========================================
// EVENTO STEP - Foco total na Interação
// ==========================================

// Segurança: Garante que não vai dar erro se o player morrer ou não existir
if (instance_exists(obj_player)) 
{
    // point_distance é mais rápido que distance_to_point e instance_nearest juntos!
    if (point_distance(x, y, obj_player.x, obj_player.y) <= 100) 
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
}