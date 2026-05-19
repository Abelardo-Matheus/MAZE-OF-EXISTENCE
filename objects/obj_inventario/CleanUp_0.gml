/// @desc Destruição Segura de Estruturas de Dados
if (ds_exists(global.grid_itens, ds_type_grid)) ds_grid_destroy(global.grid_itens);
if (ds_exists(crafts_disponiveis, ds_type_list)) ds_list_destroy(crafts_disponiveis);
