/// @desc Inicialização do Controlador de Tutorial
tutorial_step = 0;
last_step = -1;
dialogue_active = false;

// Posição inicial do player para checar movimento
start_x = obj_player.x;
start_y = obj_player.y;

// Flag para saber se a amoeba do tutorial foi criada
amoeba_spawned = false;
portal_spawned = false;

// Função para iniciar um diálogo de tutorial
function start_tuto_dialogue(_nome) {
    if (!instance_exists(obj_dialogo)) {
        var _dialogo = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
        _dialogo.npc_nome = _nome;
        dialogue_active = true;
    }
}
