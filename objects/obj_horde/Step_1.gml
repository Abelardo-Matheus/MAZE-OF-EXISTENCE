// feather disable GM2017
/// @desc obj_horde — Begin Step
/// [O QUE]: Atualiza a horda inteira ANTES do Step normal, para que armas e pets
///          consultem o hash espacial já atualizado no Step delas.
/// [COMO] : números de dano -> pausa de level up -> mortes/XP -> diretor -> hash -> IA -> contato -> gemas.

var _p = horde_player();
if (_p == noone) exit;

if (som_cd > 0) som_cd -= 1;
if (som_xp_cd > 0) som_xp_cd -= 1;
_horde_popups_update(); // obj_dano também não pausava

// Mesma pausa de todos os inimigos (obj_par_inimigos)
paused = global.level_up;
if (paused) exit;

frame += 1;
_horde_view();
horde_px = _p.x;
horde_py = _p.y;
horde_pr = max(8, (_p.bbox_right - _p.bbox_left) * 0.5);
depth = _p.depth + 1; // horda logo atrás do jogador

var _noite = !global.day_night_cycle.is_day;

_horde_process_deaths();      // 1) remove mortos (dano aplicado no frame anterior), XP, divisão
_horde_director(_noite);      // 2) enxame em anel / sumir ao amanhecer

// Teste de estresse (só com HORDE_DEBUG): F9 cria +500 inimigos perto da tela
if (HORDE_DEBUG && keyboard_check_pressed(vk_f9)) _horde_stress_test(500);
_horde_grid_build();          // 3) hash espacial
_horde_move(_noite);          // 4) IA + separação + teleporte de borda
_horde_player_contact(_p);    // 5) dano de contato
_horde_gems_update();         // 6) gemas de XP
