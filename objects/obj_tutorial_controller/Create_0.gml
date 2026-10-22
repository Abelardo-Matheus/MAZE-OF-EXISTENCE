// feather disable GM2017
/// @desc Controlador do Tutorial (passos data-driven em scr_tutorial -> tutorial_passos)
passos = tutorial_passos();
tutorial_step = 0;
passo_iniciado = false;
preparado = false;          // decoração + progresso são feitos no 1º Step (quando o piso já existe)

// Dados usados pelos passos
start_x = obj_player.x;
start_y = obj_player.y;
correr_frames = 0;
fez_dash = false;
amoebas_treino = [];

/// @desc Abre um diálogo do tutorial (textos em scr_textos)
falar = function(_nome) {
    if (!instance_exists(obj_dialogo)) {
        var _dialogo = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
        _dialogo.npc_nome = _nome;
    }
}

/// @desc Quantas amoebas do treino ainda estão vivas
amoebas_vivas = function() {
    var _n = 0;
    for (var _i = 0; _i < array_length(amoebas_treino); _i++) if (instance_exists(amoebas_treino[_i])) _n++;
    return _n;
}
