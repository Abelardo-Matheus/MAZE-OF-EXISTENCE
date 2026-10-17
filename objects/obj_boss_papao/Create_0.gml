// feather disable GM2017
/// @desc Bicho-Papão — boss da fase bebê (filho de par_boss)
/// Sombras: some e reaparece, olhos no escuro que fecham o cerco, rajada e sombras teleguiadas.
event_inherited();
boss_infancia_init("papao", 450, 18, 1400, [boss_papao_teleporte, boss_papao_olhos, boss_papao_rajada, boss_papao_perseguir]);
