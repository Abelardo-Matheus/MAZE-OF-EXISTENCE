// feather disable GM2017
/// @desc Enfeite da cidade (banco, árvore, fonte, parquinho, pombos...)
/// "tipo" chega pela struct do instance_create (ver macros ENF_* em scr_cidade)
var _visuais = [
    spr_cid_banco, spr_cid_hidrante, spr_cid_caixa_correio, spr_cid_lixeira,
    spr_cid_canteiro, spr_cid_arvore, spr_cid_fonte, spr_cid_balanco,
    spr_cid_gangorra, spr_cid_escorregador, spr_cid_arbusto, spr_cid_pombos
];
var _solido = [true, true, true, true, false, true, true, true, true, true, true, false];
var _vel    = [0, 0, 0.012, 0, 0.06, 0.04, 0.14, 0.07, 0.05, 0, 0.035, 0.09];
var _alto   = [false, false, false, false, false, true, true, true, false, true, false, false];

if (!variable_instance_exists(id, "tipo")) tipo = 0;
tipo = clamp(tipo, 0, array_length(_visuais) - 1);

sprite_index = _visuais[tipo];
mask_index   = sprite_index;
solid        = _solido[tipo];
alto         = _alto[tipo];        // fica transparente quando o jogador passa atrás
image_speed  = 0;
anim         = random(image_number);
anim_vel     = _vel[tipo] * random_range(0.85, 1.15);
depth        = -y;

// pombos voam quando alguém chega perto
fugindo = false;
casa_x = x;
casa_y = y;
fuga_vx = 0;
fuga_vy = 0;
