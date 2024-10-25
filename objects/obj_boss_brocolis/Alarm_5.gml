/// @description Insert description here
// You can write your code in this editor
// Código no alarm[5] para disparar projéteis múltiplos
if (ataque_ativo) {
    var proj_x = x;  // Posição inicial do projétil no eixo X (a posição atual do chefe)
    var proj_y = y;  // Posição inicial do projétil no eixo Y (a posição atual do chefe)
    var dir = point_direction(x, y, obj_player.x, obj_player.y);  // Direção para onde o projétil será disparado (direção do jogador)

    // Criar o projétil e definir suas propriedades
    var proj = instance_create_layer(proj_x, proj_y, "instances", obj_projetil_boss);
    with (proj) {
        direction = dir;  // Define a direção do projétil
        speed = 8;  // Velocidade do projétil
        damage = 10;  // Dano causado pelo projétil
    }

    // Incrementar o contador de tiros disparados
    tiros_disparados++;

    // Verificar se ainda há projéteis para disparar
    if (tiros_disparados < tiros_totais) {
        alarm[5] = 20;  // Definir o intervalo entre os próximos disparos (ajustável)
    } else {
        ataque_ativo = false;  // Desativar o estado de ataque após disparar todos os projéteis
        estado = scr_boss_escolher_atk;  // Voltar a escolher outro ataque
    }
}

















