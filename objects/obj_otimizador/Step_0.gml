// feather disable GM2017
/// @desc Mundo virtual: cria/destrói as instâncias perto da câmera e faz o cenário fora da tela
///       dormir. Antes a varredura inteira rodava TODO frame; agora cada parte tem seu intervalo.
///       Lógica e macros em scripts/scr_desempenho.
var _target = instance_exists(global.current_player) ? global.current_player : obj_player;
if (!instance_exists(_target)) exit;

otim_frame += 1;
if (otim_frame mod OTIM_INTERVALO_SPAWN == 0)    otimizador_varrer_spawn();     // na tela nasce já, margem vai pra fila
otimizador_processar_fila();                                                     // até OTIM_CRIAR_POR_FRAME por frame
if (otim_frame mod OTIM_INTERVALO_DESPAWN == 15) otimizador_despawn(_target);   // longe demais = destrói
if (otim_frame mod CULL_INTERVALO == 0)          desempenho_cull();             // fora da tela = dorme

// F10: painel de FPS / instâncias (Draw GUI)
if (keyboard_check_pressed(vk_f10)) global.desempenho_debug = !global.desempenho_debug;
