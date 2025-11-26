/// @desc Aplica Dano e Verifica Perfuração
/// [O QUE]: Causa dano apenas se o inimigo ainda não foi atingido neste voo, aplica knockback e gerencia a contagem de perfuração (pierce).
/// [COMO] : 
/// 1. Verifica se o ID do inimigo está na 'hit_list'.
/// 2. Se não estiver, aplica dano, efeitos visuais e empurrão.
/// 3. Adiciona o inimigo na lista para não bater de novo.
/// 4. Reduz 'pierce_max'. Se zerar, muda o estado para "returning".

// 1. Verificação de Lista (Evita dano múltiplo no mesmo inimigo)
if (ds_list_find_index(hit_list, other.id) == -1) 
{
    var _damage = damage; // Variável local para o dano

    // --- Aplicação de Dano e Status ---
    other.vida -= _damage;
    other.hit = true;
    other.state = scr_inimigo_hit; // Coloca o inimigo no estado de hit
    other.alarm[1] = 5;            // Tempo do flash branco

    // --- Lógica de Empurrão (Knockback) ---
    // Usamos 'push_force' que definimos no Create/Config
    // Se a variável for 'push' no seu jogo, altere abaixo
    if (push_force > 0) 
    {
        // Empurra na direção que o bumerangue está indo ou vindo do player? 
        // Geralmente bumerangue empurra na direção do impacto:
        var _dir = point_direction(x, y, other.x, other.y); 
        
        other.empurrar_dir = _dir;
        other.empurrar_veloc = push_force;
    }

    // --- Visual: Número de Dano ---
    var _inst = instance_create_layer(x, y, "Instances", obj_dano);
    _inst.alvo = other;
    _inst.dano = _damage;

    // --- Lógica do Bumerangue (Perfuração) ---
    
    // 1. Marca este inimigo como atingido
    ds_list_add(hit_list, other.id);

    // 2. Reduz a contagem de perfuração
    pierce_max--;

    // 3. Se acabou a perfuração, força a volta imediatamente
    if (pierce_max <= 0) 
    {
        state = "returning";
    }
}