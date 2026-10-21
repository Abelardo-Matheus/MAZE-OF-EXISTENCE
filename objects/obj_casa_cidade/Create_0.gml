// feather disable GM2017
/// @desc Casa/loja animada da cidade (filha de obj_estrutura: entra com F, fica transparente atrás)
event_inherited();

// mesma ordem das macros CASA_* (scr_cidade)
var _visuais = [
    spr_cid_casa_azul, spr_cid_casa_tijolo, spr_cid_sobrado, spr_cid_moinho,
    spr_cid_padaria, spr_cid_brinquedos, spr_cid_floricultura, spr_cid_escola
];
if (!variable_instance_exists(id, "variante") || variante < 0) variante = irandom(array_length(_visuais) - 1);
variante = clamp(variante, 0, array_length(_visuais) - 1);

sprite_index = _visuais[variante];
mask_index   = sprite_index;
// arte já vem no tamanho certo (3x): sem a escala aleatória do obj_estrutura
escala = 1;
image_xscale = 1;
image_yscale = 1;
image_speed  = 0;

// animação: frames 0-3 de dia, 4-7 de noite (janelas acesas)
anim     = random(4);
anim_vel = (variante == CASA_MOINHO) ? 0.10 : 0.07;

// luz quente das janelas à noite (sistema de luzes do dia_noite)
raio = sprite_width * 0.7;
luz_1 = raio; luz_2 = raio * 0.75; luz_3 = raio * 0.45; luz_4 = raio * 0.3; luz_5 = raio * 0.2;
light_intensity = 0.45;
light_color     = make_color_rgb(255, 200, 120);
light_offset_x  = 0;
light_offset_y  = -sprite_height * 0.3;
light_style     = "soft";
if (variable_global_exists("lista_luzes") && ds_exists(global.lista_luzes, ds_type_list)) {
    ds_list_add(global.lista_luzes, id);
}
