// feather disable GM2017
/// @desc Percorre os passos do tutorial (scr_tutorial -> tutorial_passos)

// 1. Primeira vez: decora a casa e prepara XP/poderes de verdade
if (!preparado) {
    preparado = true;
    tutorial_decorar_casa();
    tutorial_preparar_progresso();
}

if (!instance_exists(obj_player)) exit;

// 2. Monitora ações que duram poucos frames (contam mesmo com o objetivo ainda não visível)
var _in = obter_inputs_jogador();
if (_in.shift && global.estamina > 0 && (obj_player.hveloc != 0 || obj_player.vveloc != 0)) correr_frames++;
if (obj_player.state == scr_personagem_dash_tuto) fez_dash = true;

// 3. Espera diálogos e a tela de level up terminarem
if (global.level_up || instance_exists(obj_dialogo)) exit;
if (tutorial_step >= array_length(passos)) exit;

// 4. Passo atual
var _p = passos[tutorial_step];
if (!passo_iniciado) {
    passo_iniciado = true;
    _p.iniciar(id);
    exit;
}
if (_p.concluido(id)) {
    tutorial_step++;
    passo_iniciado = false;
}
