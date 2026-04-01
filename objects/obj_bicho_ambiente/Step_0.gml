// 1. Efeito 3D (Z-Order)
depth = -y+(30);

// 2. Cronômetro de Decisão (Wander)
tempo_estado--;

if (tempo_estado <= 0) 
{
    if (choose(true, false)) 
    {
        estado = "andando";
        tempo_estado = irandom_range(60, 180);
        dir_movimento += random_range(-45, 45); 
        vel_atual = vel_maxima;
    } 
    else 
    {
        estado = "parado";
        tempo_estado = irandom_range(30, 90);
        vel_atual = 0;
    }
}

// 3. Aplica o movimento e a ROTAÇÃO CORRETA
if (estado == "andando") 
{
    x += lengthdir_x(vel_atual, dir_movimento);
    y += lengthdir_y(vel_atual, dir_movimento);
    
    // ========================================================
    // AJUSTE DE DIREÇÃO:
    // Se o sprite olha para BAIXO, ele está rotacionado 90 graus
    // em relação ao "zero" do GameMaker. Subtraímos 90 para compensar.
    // ========================================================
    image_angle = dir_movimento + 90;
    
    // Pequena animação de "rebolado" enquanto anda (opcional)
    // Isso faz a formiga parecer mais viva
    image_angle += sin(get_timer() * 0.00001) * 5; 
}