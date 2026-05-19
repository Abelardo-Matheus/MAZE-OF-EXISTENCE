/// @desc Lógica do Tutorial por Passos

// 1. Monitora Diálogos
if (dialogue_active && !instance_exists(obj_dialogo)) {
    dialogue_active = false;
    // Se acabamos de falar o texto inicial, não avançamos o step ainda, esperamos a ação
}

// 2. Máquina de Estados do Tutorial
switch (tutorial_step) {
    case 0: // ENSINAR MOVIMENTO
        if (last_step != tutorial_step) {
            start_tuto_dialogue("Tuto_Move");
            last_step = tutorial_step;
        }
        
        // Critério de avanço: se moveu 200 pixels
        if (point_distance(start_x, start_y, obj_player.x, obj_player.y) > 200) {
            tutorial_step = 1;
        }
        break;

    case 1: // ENSINAR INTERAÇÃO
        if (last_step != tutorial_step) {
            start_tuto_dialogue("Tuto_Interact");
            last_step = tutorial_step;
        }
        
        // Critério de avanço: conversou com a Fada
        // A Fada muda seu 'dig' ao conversar. Vamos monitorar isso ou o diálogo.
        if (instance_exists(obj_npc_fada) && obj_npc_fada.dig > 0) {
            tutorial_step = 2;
        }
        break;

    case 2: // ENSINAR COMBATE
        if (last_step != tutorial_step) {
            last_step = tutorial_step;
        }
        
        // Verifica se a cutscene criou a amoeba
        if (!amoeba_spawned && instance_exists(obj_amoeba)) {
            amoeba_spawned = true;
        }
        
        // Critério de avanço: Amoeba morreu
        if (amoeba_spawned && !instance_exists(obj_amoeba)) {
            if (last_step == tutorial_step) { // Garante que roda uma vez
                start_tuto_dialogue("Tuto_Combat_Win");
                last_step = -2; // Estado intermediário
            }
            
            // Só avança o step quando o diálogo de vitória fechar
            if (!instance_exists(obj_dialogo)) {
                tutorial_step = 3;
            }
        }
        break;

    case 3: // ENSINAR DASH
        if (last_step != tutorial_step) {
            start_tuto_dialogue("Tuto_Dash");
            last_step = tutorial_step;
        }
        
        // Critério de avanço: Usou o Dash
        if (global.in_dash) {
            tutorial_step = 4;
        }
        break;

    case 4: // ENSINAR TROCA DE ARMA
        if (last_step != tutorial_step) {
            start_tuto_dialogue("Tuto_Weapon");
            last_step = tutorial_step;
        }
        
        // Critério de avanço: Trocou para o arco (Armamentos.arco = 1)
        if (global.armamento == Armamentos.arco) {
            tutorial_step = 5;
        }
        break;

    case 5: // FINALIZAR TUTORIAL
        if (last_step != tutorial_step) {
            start_tuto_dialogue("Tuto_End");
            last_step = tutorial_step;
            
            // Permite que a fada responda com o diálogo final se o player interagir novamente
            if (instance_exists(obj_npc_fada)) {
                obj_npc_fada.dig = 4;
            }
        }
        break;
}
