// feather disable GM2017
if (inimigo_colisao_ignorar(other)) exit; // fantasma especial sem o item de matar fantasma
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
    var _damage = damage; 

    // --- Aplicação de Dano Universal ---
    var _kb_dir = point_direction(x, y, other.x, other.y); 
    scr_enemy_damage_apply(other, _damage, push_force, _kb_dir, false);

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