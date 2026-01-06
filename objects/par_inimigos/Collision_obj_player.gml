// ========================================================
// COLISÃO DO INIMIGO COM O PLAYER
// (O "other" aqui se refere ao PLAYER)
// ========================================================
var _dano = dano;
// 1. Verifica se o Player pode tomar dano no momento
if (other.tomar_dano) {

    // 2. Entra no escopo do Player para aplicar as mudanças
    with (other) {
        // --- AGORA "self" É O PLAYER ---
		
        // Tira vida
        global.vida -= _dano;

        // Calcula direção do empurrão (Do inimigo PARA o player)
        // Trava de segurança: se estiverem na mesma posição exata, empurra para a direita (0)
        if (x == other.x && y == other.y) {
             empurrar_dir = 0;
        } else {
             empurrar_dir = point_direction(other.x, other.y, x, y);
        }

        // Ativa o estado de Hit (Knockback)
        hit = true;
        alarm[ALARM_KNOCKBACK] = 15; // Duração do empurrão (ex: 15 frames)

        // Ativa a invencibilidade (i-frames)
        tomar_dano = false;
        alarm[ALARM_INVENCIBILIDADE] = 90; // Tempo invulnerável (ex: 1.5 segundos)

        // Feedback visual imediato
        image_blend = c_red;
    }

    // 3. Cria o popup de dano (na posição do player)
    if (object_exists(obj_dano)) {
        var _inst = instance_create_layer(other.x, other.y - 30, "Instances", obj_dano);
        _inst.dano = _dano;
        _inst.cor = c_red;
    }
}