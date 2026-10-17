// feather disable GM2017
// Avança de fase. reset_level_data() já chama reset_global_variables()
// (antes chamava resetar_variaveis_globais(), que não existe -> erro ao apertar R).
global.current_level += 1;

with (ojb_control_fase_bebe) {
    reset_level_data();
}
