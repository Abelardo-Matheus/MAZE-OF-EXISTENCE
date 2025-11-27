function cutscene_fada1() 
{
    var _scene = new CutsceneBuilder();

    _scene
        .set_var(obj_npc_fada, "dig", 3)
        .move(obj_npc_fada, 0, 200, true, 3)    // Move relativo (+200y)
        .sound(snd_fala, false)                 // Toca som
        .scale(obj_npc_fada)                    // Inverte lado
		.destroy(global.id_parede_um)
        .wait(1)                                // Espera
        .create(1825, 735, "Instances_Enemys", obj_amoeba)
        .move(obj_npc_fada, 800, 0, true, 3)
        .finish(obj_cutscene)                   // Libera controle (se necessário)
        .run();
}

function cutscene_example2() 
{
    var _scene = new CutsceneBuilder();

    _scene
        .move(obj_npc_enemy, 100, 200, false, 5) // Move para posição absoluta 100,200
        .sound(snd_enemy_fala, true)
        .wait(2)
        .finish()
        .run();
}