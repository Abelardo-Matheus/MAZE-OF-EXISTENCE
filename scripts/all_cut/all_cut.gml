function cutscene_fada1() 
{
    var _scene = new CutsceneBuilder();

    _scene
        .set_var(obj_npc_fada, "dig", 3)
        .move(obj_npc_fada, 0, 200, true, 3)     // Move relativo (+200y para descer)
        .sound(snd_fala, false)
        .scale(obj_npc_fada, -3)                // Olha para o player (escala 3 base)
        .wait(1)
        .create(obj_npc_fada.x + 200, obj_npc_fada.y, "Instances_Enemys", obj_amoeba)
        .dialogue("C1")                         // NOVO: Chama o diálogo "C1" e espera terminar
        .move(obj_npc_fada, 800, 0, true, 3)
        .finish(obj_cutscene)
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