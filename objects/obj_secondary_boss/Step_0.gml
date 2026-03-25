// 1. Só roda a lógica se o boss ainda NÃO foi invocado e se o jogador existe
if (!boss_invocado && instance_exists(obj_player)) 
{
    // 2. Calcula a distância entre este objeto e o jogador
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);

    // 3. Checa se o jogador está perto o suficiente
    if (_dist <= distancia_interacao) 
    {
        // 4. Checa se o jogador apertou a tecla 'F'
        if (keyboard_check_pressed(ord("F"))) 
        {
            // Marca que o boss foi invocado para travar esse código
            boss_invocado = true;

            // ========================================================
            // AÇÃO: INVOCA O BOSS
            // ========================================================
            // SUBSTITUA 'obj_boss' pelo nome do objeto do seu boss
            // O boss vai nascer 100 pixels acima (y - 100) deste altar
            var _boss = instance_create_layer(x, y - 100, "Instances", obj_boss_brocolis);
            
            // Opcional: Efeitos visuais e sonoros na hora de sumonar!
            // audio_play_sound(snd_boss_spawn, 1, false);
            /*
            repeat (20) {
                instance_create_layer(x + irandom_range(-30, 30), y + irandom_range(-30, 30), "Instances", obj_particula_magia);
            }
            */
            
            // Opcional: Se quiser que o altar de invocação suma depois de usado:
            instance_destroy(); 
        }
    }
}

var _inst = instance_nearest(x,y,obj_player);
	if(distance_to_point(_inst.x,_inst.y)<= 100){
    obj_player.desenha_botao = true;
} 

