/// @desc Controle de Animação e Dano
/// [O QUE]: Aplica o dano em área no momento certo da animação e se destrói ao final.
/// [COMO] : 
/// 1. Verifica se a animação chegou no frame 2 (image_index >= 1).
/// 2. Se sim e o dano ainda não foi aplicado: cria lista de colisão, aplica dano/knockback e marca 'damage_applied'.
/// 3. Se a animação terminou, destrói o objeto.

// --- 1. Lógica de Dano (No Frame 2) ---
// Nota: Frame 1 = index 0. Frame 2 = index 1.
if (image_index >= 1 && !damage_applied) 
{
    damage_applied = true; // Trava imediata
    
    // Cria lista para armazenar quem foi atingido
    var _hit_list = ds_list_create();
    
    // Colisão Circular (Área de Efeito)
    var _count = collision_circle_list(x, y, radius, par_inimigos, false, true, _hit_list, false);
    
    // Loop pelos inimigos atingidos
    for (var i = 0; i < _count; i++) 
    {
        var _enemy_id = _hit_list[| i];
        
        if (instance_exists(_enemy_id)) 
        {
            // Aplica Dano
            _enemy_id.vida -= damage;
            
            // Aplica Empurrão (Knockback para fora do centro do raio)
            if (push_force > 0) 
            {
                var _push_dir = point_direction(x, y, _enemy_id.x, _enemy_id.y);
                _enemy_id.empurrar_dir = _push_dir;
                _enemy_id.empurrar_veloc = push_force;
            }
            
            // Estados e Feedback Visual
            _enemy_id.state = scr_inimigo_hit; // Script de hit do inimigo
            _enemy_id.alarm[1] = 5;            // Tempo de flash branco
            _enemy_id.hit = true;
            
            // Cria Pop-up de Dano
            var _txt = instance_create_layer(_enemy_id.x, _enemy_id.y, "Instances", obj_dano);
            _txt.alvo = _enemy_id;
            _txt.dano = damage;
        }
    }
    
    // Limpeza de Memória Obrigatória
    ds_list_destroy(_hit_list);
    
    // Opcional: Tocar som de trovão aqui
    // audio_play_sound(snd_thunder, 1, false);
}

// --- 2. Destruição (Fim da Animação) ---
if (image_index >= image_number - 1) 
{
    instance_destroy();
}