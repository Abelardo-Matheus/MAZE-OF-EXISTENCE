/// @desc Movimento Orbital e Timer
/// [O QUE]: Atualiza a posição da shuriken baseada no ângulo atual e no raio, mantendo-a presa ao player.
/// [COMO] : 
/// 1. Pausa se level up.
/// 2. Incrementa o ângulo (rotação).
/// 3. Usa 'lengthdir_x/y' para calcular a posição X/Y relativa ao player.
/// 4. Conta o tempo de vida e se destrói ao final.

// --- 1. Pausa ---
if (global.level_up) exit;

// --- 2. Controle de Tempo de Vida ---
life_timer += delta_time / 1000; // Incrementa em ms

if (life_timer >= duration) 
{
    // Efeito visual ao sumir (fade out opcional)
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
}
else
{
    // --- 3. Movimento Orbital ---
    if (instance_exists(obj_player)) 
    {
        // Incrementa o ângulo
        current_angle += rotation_speed;
        
        // Mantém o ângulo dentro de 0-360 (boa prática matemática)
        if (current_angle >= 360) current_angle -= 360;

        // Trigonometria: Calcula posição ao redor do player
        x = obj_player.x + lengthdir_x(orbit_radius, current_angle);
        y = obj_player.y + lengthdir_y(orbit_radius, current_angle);
        
        // Rotação do próprio sprite (visual)
        image_angle += 15;
    }
    else
    {
        // Se o player morrer, a shuriken some
        instance_destroy();
    }
}

// Reseta a lista de hits a cada 0.5 segundos (500ms)
// Isso permite que a shuriken acerte o MESMO inimigo de novo se ele continuar encostando
reset_hit_timer += delta_time / 1000;
if (reset_hit_timer >= 500) 
{
    ds_list_clear(hit_list);
    reset_hit_timer = 0;
}