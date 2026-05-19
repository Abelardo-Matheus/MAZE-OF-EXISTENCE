raio = 600;

luz_1 = raio;
luz_2 = raio * 0.9;
luz_3 = raio * 0.7;
luz_4 = raio * 0.4;
luz_5 = raio * 0.3;
light_intensity = 0.5;
light_color = c_yellow;
light_offset_x = 0;
light_offset_y = -65;
light_style = "flicker";

// Adiciona na lista global (Garantido pelo ALL_GLOBAL)
if (variable_global_exists("lista_luzes") && ds_exists(global.lista_luzes, ds_type_list)) {
    ds_list_add(global.lista_luzes, id);
}
