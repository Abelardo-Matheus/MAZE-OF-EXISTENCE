// feather disable GM2017
if (variable_global_exists("lista_luzes") && ds_exists(global.lista_luzes, ds_type_list)) {
    var _i = ds_list_find_index(global.lista_luzes, id);
    if (_i != -1) ds_list_delete(global.lista_luzes, _i);
}
