// scr_cutscenes.gml

function cutscene_fada1() {
    return [
		[scr_cutscene_change_variable, obj_npc_fada, "dig", 3],
        [scr_cutscenes_move_obj, obj_npc_fada, 0, 500, true, 3],
        [scr_play_sound_cutscene, snd_fala, false],
        [scr_xscale_cutescene, obj_npc_fada],
        [scr_cutscenes_wait, 1, obj_npc_fada],
        [scr_create_instance_cutescene, 100, 100, "instances", obj_amoeba],
        [scr_cutscenes_move_obj, obj_npc_fada, 800, 0, true, 3],
		[scr_acaba_cut, obj_cutscene],
    ];
}

function cutscene_example2() {
    return [
        [scr_cutscenes_move_obj, obj_npc_enemy, 100, 200, false, 5],
        [scr_play_sound_cutscene, snd_enemy_fala, true],
        [scr_cutscenes_wait, 2, obj_npc_enemy],
		[scr_acaba_cut(obj_cutscene)],
    ];
}
