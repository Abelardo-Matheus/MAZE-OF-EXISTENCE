var index = ds_list_find_index(global.enemy_list, id);
if (index != -1) {
    ds_list_delete(global.enemy_list, index);
}
