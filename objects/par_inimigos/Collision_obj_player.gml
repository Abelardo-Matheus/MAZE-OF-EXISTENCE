// ========================================================
// COLISÃO DO INIMIGO COM O PLAYER
// (Coloque no evento de colisão do inimigo com obj_player)
// ========================================================

// 1. Verifica se o alvo (Player) pode tomar dano
if (other.tomar_dano) { // "tomar_dano" é uma variável booleana no player
    
    var _dano_causado = 40; // Valor do dano deste inimigo (pode ser uma variável do inimigo)

    // 2. Aplica o dano e configura o estado de "Hit" NO PLAYER
    with (other) {
        // Tira vida do player (pode ser global.vida ou uma variável de instância 'vida')
        // O ideal é usar uma função do player: player_receber_dano(_dano_causado);
        global.vida -= _dano_causado; 

        // Configura o empurrão (Knockback)
        var _dir_empurrao = point_direction(other.x, other.y, x, y); // Direção do inimigo PARA o player
        empurrar_dir = _dir_empurrao;
        
        // Ativa o estado de hit e o alarme para sair dele
        hit = true; 
        alarm[ALARM_KNOCKBACK] = 10; // Duração do empurrão (Use sua macro)

        // Ativa a invencibilidade temporária (i-frames)
        tomar_dano = false; 
        alarm[ALARM_INVENCIBILIDADE] = 100; // Duração dos i-frames (Use sua macro)
        
        // Efeito visual (opcional)
        image_blend = c_red;
    }

    // 3. Cria o número de dano flutuante (Popup)
    // O "x" e "y" aqui são do INIMIGO. Para criar em cima do player, use "other.x", "other.y"
    var _inst = instance_create_layer(other.x, other.y - 30, "Instances", obj_dano);
    _inst.dano_valor = _dano_causado; // Renomeei 'dano' para 'dano_valor' para evitar conflito
    _inst.cor = c_red;
    // _inst.alvo = other; // Se o obj_dano precisar seguir o alvo, descomente.
}