// feather disable GM2017
image_xscale = global._cell_size / sprite_get_width(sprite_index);
image_yscale = global._cell_size / sprite_get_height(sprite_index);
image_speed = 0;
// spr_chao_bebe_2: 0-1 taco | 2-3 tábua clara | 4-5 carpete azul | 6-7 carpete rosa | 8-9 cimento
var _s = procurar_sala_por_numero(global.current_sala);
var _tipo = is_struct(_s) ? _s.tipo : "";
var _base = 0;
switch (_tipo) {
    case "quarto":    _base = 4; break;
    case "quarto2":   _base = 6; break;
    case "quarto3":   _base = 2; break;
    case "banheiro2": _base = 2; break;
    case "fundos":
    case "porao":     _base = 8; break;
    default:          _base = 0; break;   // sala de estar e outros: taco
}
image_index = _base + irandom(1);
