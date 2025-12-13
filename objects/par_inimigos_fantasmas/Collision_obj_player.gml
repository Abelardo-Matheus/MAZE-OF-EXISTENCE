// ========================================================
// COLISÃO DO INIMIGO COM O PLAYER
// (Coloque no evento de colisão do inimigo (ex: obj_amoeba) com obj_player)
// ========================================================

// O "other" aqui se refere ao PLAYER

// 1. Verifica se o alvo (Player) pode tomar dano
// Certifique-se que o player tem a variável "tomar_dano" no Create
if (other.tomar_dano) { 
    
    // Sugestão: Em vez de 40 fixo, use uma variável do inimigo, ex: "meu_dano"
    var _dano_causado = 40; 

    // 2. Aplica o dano e configura o estado de "Hit" NO PLAYER
    with (other) {
        // --- DENTRO DESTE BLOCO, "self" é o PLAYER e "other" é o INIMIGO ---

        // Tira vida global
        global.vida -= _dano_causado; 

        // --- Trava de Segurança de Direção ---
        // Se eles estiverem na posição exata, força uma direção (ex: direita) para evitar erros
        if (x == other.x && y == other.y) {
            empurrar_dir = 0;
        } else {
            // Direção do inimigo (other.x,y) PARA o player (x,y)
            empurrar_dir = point_direction(other.x, other.y, x, y); 
        }
        // -------------------------------------
        
        // Ativa o estado de hit e o alarme para sair dele
        // Certifique-se que a macro ALARM_KNOCKBACK existe (ex: é o alarm[2])
        hit = true; 
        alarm[ALARM_KNOCKBACK] = 10; 

        // Ativa a invencibilidade temporária (i-frames)
        // Certifique-se que a macro ALARM_INVENCIBILIDADE existe (ex: é o alarm[3])
        tomar_dano = false; 
        alarm[ALARM_INVENCIBILIDADE] = 100; 
        
        // Efeito visual: fica vermelho
        image_blend = c_red;
    }

    // 3. Cria o número de dano flutuante (Popup)
    // Cria na posição do player (other.x, other.y)
    var _inst = instance_create_layer(other.x, other.y - 30, "Instances", obj_dano);
    
    // Certifique-se que seu obj_dano usa a variável "dano_valor" para mostrar o texto
    _inst.dano_valor = _dano_causado; 
    _inst.cor = c_red;
}