// ========================================================
// ESTADO 1: ENQUANTO ESTÁ VOANDO ATÉ O INIMIGO
// ========================================================
if (estado == "voando") 
{
    // 1. Faz a bola andar de verdade!
    speed = veloc; 
    image_angle = direction;

    // 2. Faz a animação de "surgimento" tocar do frame 0 até o 2 enquanto voa
    if (image_index < 2) {
        image_index += velocidade_aparecer;
    }
}
// ========================================================
// ESTADO 2: QUANDO BATE E VIRA UMA TORRETA
// ========================================================
else if (estado == "parado_atirando") 
{
    // 1. Animação Ping-Pong (Vai e volta entre o frame 2 e 4)
    image_index += 0.2 * anim_direcao; 

    if (image_index >= 4) {
        anim_direcao = -1; 
    } else if (image_index <= 2) {
        anim_direcao = 1;  
    }

    // 2. Temporizador e Disparo das Bolinhas
    timer_efeito++; 

    // Atira 2 vezes: no frame 10 e no frame 60
    if (timer_efeito == 10 || timer_efeito == 60 || timer_efeito == 120) 
    {
        // Pega um círculo completo (360) e divide pela quantidade de bolinhas
        var _angulo_distancia = 360 / qtd_bolinhas;
        
        // Loop vai rodar a quantidade de vezes que você definiu na variável
        for (var i = 0; i < qtd_bolinhas; i++) 
        {
            var _tiro = instance_create_layer(x, y, "Instances", obj_bola_evolved);
            
            _tiro.eh_filho = true; 
            _tiro.escala_base = 0.3;
            _tiro.image_xscale = 0.3; 
            _tiro.image_yscale = 0.3;
            
            // MÁGICA DOS ÂNGULOS AQUI: Multiplica a distância pelo número da bolinha
            // Ex (4 bolas): 0*90=0, 1*90=90, 2*90=180, 3*90=270...
            _tiro.direction = i * _angulo_distancia; 
            
            _tiro.veloc = 6; 
            _tiro.speed = 6; 
            _tiro.damage = damage * 0.5; // Metade do dano
            _tiro.image_angle = _tiro.direction; 
        }
    }

    // 3. Destrói após o tempo acabar
    if (timer_efeito >= 120) {
        instance_destroy();
    }
}