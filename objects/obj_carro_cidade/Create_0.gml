// feather disable GM2017
/// @desc Carrinho da cidade: anda pelas faixas (mão dupla), vira nos cruzamentos
/// e nunca sai da cidade. Para quando tem gente na frente.
/// Sprite: 8 frames = dir*2 + roda  (0 baixo, 1 esquerda, 2 direita, 3 cima)
var _visuais = [spr_cid_carro_vermelho, spr_cid_fusca_azul, spr_cid_onibus_escolar, spr_cid_sorveteria];
if (!variable_instance_exists(id, "variante") || variante < 0) variante = irandom(array_length(_visuais) - 1);
variante = clamp(variante, 0, array_length(_visuais) - 1);
if (!variable_instance_exists(id, "dir")) dir = 2;

sprite_index = _visuais[variante];
image_speed  = 0;
var _vels    = [2.6, 2.3, 1.8, 1.6];
vel_max      = _vels[variante] * random_range(0.9, 1.1);
vel          = vel_max;
var _meios   = [80, 72, 120, 92];   // meio comprimento (px) visto de lado
meio         = _meios[variante];
anim         = 0;
virar_para   = -1;      // direção escolhida no cruzamento (executa ao chegar na faixa certa)
inter_atual  = "";      // cruzamento onde a decisão já foi tomada
parado_timer = 0;       // tempo parado (evita travar para sempre em outro carro)
buzina_timer = 0;
balao        = 0;
depth        = -y;

// faróis à noite (sistema de luzes)
raio = 170;
luz_1 = raio; luz_2 = raio * 0.75; luz_3 = raio * 0.45; luz_4 = raio * 0.3; luz_5 = raio * 0.2;
light_intensity = 0.35;
light_color     = c_white;
light_offset_x  = 0;
light_offset_y  = -30;
light_style     = "soft";
if (variable_global_exists("lista_luzes") && ds_exists(global.lista_luzes, ds_type_list)) {
    ds_list_add(global.lista_luzes, id);
}

cruz = undefined;        // último cruzamento (struct de cidade_cruzamento)

/// coordenada da faixa (x para dir 0/3, y para dir 1/2).
/// No cruzamento usa as ruas dele; fora dele, a rua onde o carro está.
faixa_de = function(_d) {
    if (is_struct(cruz)) {
        switch (_d) {
            case 0: if (cruz.desce != -infinity) return cruz.desce * CIDADE_T + 48;  break;  // descendo
            case 3: if (cruz.sobe  != -infinity) return cruz.sobe  * CIDADE_T + 144; break;  // subindo
            case 2: return cruz.av * CIDADE_T + 178;   // indo para a direita (faixa de baixo)
            case 1: return cruz.av * CIDADE_T + 84;    // indo para a esquerda (faixa de cima)
        }
    }
    return cidade_faixa_aqui(x, y, _d);
};

/// a rua nessa direção continua dentro da cidade?
caminho_ok = function(_d, _cx, _cy) {
    var _dx = cidade_dx(_d), _dy = cidade_dy(_d);
    var _dists = [300, 700, 1100];
    for (var _i = 0; _i < 3; _i++) {
        if (terreno_bioma_em(_cx + _dx * _dists[_i], _cy + _dy * _dists[_i]) != "cidade") return false;
    }
    return true;
};

/// escolhe a saída do cruzamento _c: reto (mais comum), esquerda ou direita
escolher_saida = function(_c) {
    var _cx = x, _cy = _c.av * CIDADE_T + 96;
    var _ops = [];
    // na avenida sempre dá pra seguir para os lados
    var _pode = [false, true, true, false];
    _pode[0] = (_c.desce != -infinity);
    _pode[3] = (_c.sobe  != -infinity);
    // reto na vertical só se a rua do outro lado estiver alinhada
    if (dir == 0) _pode[0] = _pode[0] && (_c.desce == _c.sobe);
    if (dir == 3) _pode[3] = _pode[3] && (_c.desce == _c.sobe);
    for (var _d = 0; _d < 4; _d++) {
        if (!_pode[_d] || _d == cidade_oposta(dir)) continue;
        if (!caminho_ok(_d, _cx, _cy)) continue;
        array_push(_ops, _d);
        if (_d == dir) array_push(_ops, _d, _d);   // reto é mais comum
    }
    if (array_length(_ops) == 0) return cidade_oposta(dir);   // sem saída: meia-volta
    return _ops[irandom(array_length(_ops) - 1)];
};

/// meia-volta imediata trocando de faixa
meia_volta = function() {
    dir = cidade_oposta(dir);
    if (dir == 0 || dir == 3) x = cidade_faixa_aqui(x, y, dir); else y = cidade_faixa_aqui(x, y, dir);
    virar_para = -1;
};
