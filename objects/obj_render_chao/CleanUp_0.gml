// feather disable GM2017
// Libera todas as surfaces do chao
var _chaves = ds_map_keys_to_array(regioes);
for (var _i = 0; _i < array_length(_chaves); _i++) {
    var _sf = regioes[? _chaves[_i]];
    if (surface_exists(_sf)) surface_free(_sf);
}
ds_map_destroy(regioes);
