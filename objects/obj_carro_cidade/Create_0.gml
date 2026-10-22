// feather disable GM2017
/// @desc Carrinho da cidade: anda pelas faixas (mão dupla), vira nos cruzamentos
/// e nunca sai da cidade. Para quando tem gente na frente.
/// Sprite top-down: 16 frames = dir*4 + passo  (0 baixo, 1 esquerda, 2 direita, 3 cima)
/// Render 3D visto de cima ("Claude outputs/carros3d": rm.py + veiculos.py + gerar.py)
/// Origem = chão na borda de baixo do veículo, no meio. Calota girando, balanço e fumaça.
var _visuais = [spr_cid_carro_vermelho, spr_cid_fusca_azul, spr_cid_onibus_escolar, spr_cid_sorveteria];
if (!variable_instance_exists(id, "variante") || variante < 0) variante = irandom(array_length(_visuais) - 1);
variante = clamp(variante, 0, array_length(_visuais) - 1);
if (!variable_instance_exists(id, "dir")) dir = 2;

sprite_index = _visuais[variante];
image_speed  = 0;
var _vels    = [2.6, 2.3, 1.8, 1.6];
vel_max      = _vels[variante] * random_range(0.9, 1.1);
vel          = vel_max;
// medidas do sprite (tudo.py imprime esses números)
var _meios   = [80, 71, 126, 93];    // meio comprimento (px) andando de lado
var _comps   = [133, 118, 209, 154]; // comprimento do "pé" na tela subindo/descendo
var _largs   = [60, 55, 75, 73];     // largura do "pé" na tela andando de lado
var _altos_h = [83, 72, 120, 125];   // altura total na tela andando de lado
var _altos_v = [151, 129, 260, 199]; // altura total na tela subindo/descendo
meio         = _meios[variante];
comp         = _comps[variante];
larg         = _largs[variante];
alto_h       = _altos_h[variante];
alto_v       = _altos_v[variante];
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

// ---------- curvas suaves ----------
// A curva é uma Bézier quadrática: começa na faixa atual, passa pelo canto do cruzamento e
// termina na faixa nova. O sprite troca de direção no meio da curva, girando um pouco
// (CARRO_CURVA_GIRO graus) antes e depois da troca, então a virada fica fluida.
#macro CARRO_CURVA_RAIO  110   // a curva começa quando faltam até X px para a faixa nova
#macro CARRO_CURVA_GIRO  25    // inclinação máxima do sprite durante a curva (graus)
curva       = false;
curva_t     = 0;
curva_len   = 1;
curva_de    = dir;
curva_para  = dir;
curva_p     = [0, 0, 0, 0, 0, 0];   // p0x, p0y, p1x, p1y, p2x, p2y
vis_dir     = dir;                  // direção do frame desenhado
vis_ang     = 0;                    // giro do sprite na curva

// ---------- atropelar / reclamar ----------
#macro CARRO_VISAO_LONGE 260   // px à frente em que o motorista já vê o jogador e freia
var _danos   = [12, 10, 20, 14];   // ônibus machuca mais
dano_carro   = _danos[variante];
reclamar_cd  = 0;                  // tempo até poder reclamar de novo
jogador_longe_antes = false;
balao_texto  = "Bi-bi!";
frases_reclamar = [
    "Ei! Sai da rua!", "Olha o carro, criança!", "Atravessa na faixa!",
    "Quer ser atropelado?!", "Cadê sua mãe?!", "Sai da frente!",
    "Ô moleque, cuidado!", "Rua não é parquinho!"
];

/// "pé" do carro (retângulo no chão) numa posição/direção qualquer: [x0, y0, x1, y1]
hitbox_em = function(_x, _y, _vd) {
    if (_vd == 1 || _vd == 2) return [_x - meio, _y - larg, _x + meio, _y];
    var _w = larg * 0.9;
    return [_x - _w / 2, _y - comp, _x + _w / 2, _y];
};
/// "pé" do carro agora, conforme o frame desenhado (jogador e outros carros colidem com ele)
hitbox = function() { return hitbox_em(x, y, vis_dir); };

// ---------- não entrar dentro de outro carro ----------
#macro CARRO_FOLGA        14    // px de folga entre dois carros
#macro CARRO_ESPERA_MAX   420   // parado esperando outro carro por ~7 s: dá meia-volta para destravar
espera_de    = noone;           // carro pelo qual este está esperando (desempate de quem passa primeiro)
espera_timer = 0;
esperando_curva = false;        // parado antes do canto esperando a curva liberar

/// área de sobreposição de dois retângulos [x0, y0, x1, y1] (0 se não encostam)
ret_area = function(_a, _b) {
    var _w = min(_a[2], _b[2]) - max(_a[0], _b[0]);
    var _h = min(_a[3], _b[3]) - max(_a[1], _b[1]);
    return (_w > 0 && _h > 0) ? _w * _h : 0;
};

/// outro carro que impede o retângulo _hb (posição futura deste carro), ou noone.
/// Só conta se o movimento aproxima os dois (sobreposição futura > atual), assim um carro
/// que já está saindo de perto não trava ninguém. Empate (um esperando o outro): passa o de id menor.
carro_no_caminho = function(_hb) {
    var _f = [_hb[0] - CARRO_FOLGA, _hb[1] - CARRO_FOLGA, _hb[2] + CARRO_FOLGA, _hb[3] + CARRO_FOLGA];
    var _agora = hitbox();
    var _eu = id, _achou = noone;
    with (obj_carro_cidade) {
        if (id == _eu) continue;
        var _ob = hitbox();
        var _fut = _eu.ret_area(_f, _ob);
        if (_fut <= 0) continue;
        if (_fut <= _eu.ret_area(_agora, _ob)) continue;          // não está chegando mais perto
        if (espera_de == _eu && real(_eu) < real(id)) continue;                // ele já espera por mim: eu passo
        _achou = id;
        break;
    }
    return _achou;
};

/// a curva inteira (da posição atual até a faixa nova) está livre de outros carros?
/// Simula a Bézier sem começar a curva. Retorna o carro que atrapalha ou noone.
curva_livre = function(_nova, _alvo, _resto) {
    var _cx = (dir == 1 || dir == 2) ? _alvo : x;
    var _cy = (dir == 1 || dir == 2) ? y : _alvo;
    var _p = [x, y, _cx, _cy, _cx + cidade_dx(_nova) * _resto, _cy + cidade_dy(_nova) * _resto];
    for (var _i = 1; _i <= 5; _i++) {
        var _t = _i / 5, _u = 1 - _t;
        var _px = _u * _u * _p[0] + 2 * _u * _t * _p[2] + _t * _t * _p[4];
        var _py = _u * _u * _p[1] + 2 * _u * _t * _p[3] + _t * _t * _p[5];
        var _o = carro_no_caminho(hitbox_em(_px, _py, (_t < 0.5) ? dir : _nova));
        if (_o != noone) return _o;
    }
    // e a faixa logo depois da curva
    return carro_no_caminho(hitbox_em(_p[4] + cidade_dx(_nova) * 60, _p[5] + cidade_dy(_nova) * 60, _nova));
};

/// ponto da curva em t (0..1)
curva_ponto = function(_t) {
    var _u = 1 - _t, _p = curva_p;
    return [_u * _u * _p[0] + 2 * _u * _t * _p[2] + _t * _t * _p[4],
            _u * _u * _p[1] + 2 * _u * _t * _p[3] + _t * _t * _p[5]];
};

/// começa a curva da direção atual para _nova; _alvo = coordenada da faixa nova, _resto = distância até ela
curva_iniciar = function(_nova, _alvo, _resto) {
    var _cx = (dir == 1 || dir == 2) ? _alvo : x;
    var _cy = (dir == 1 || dir == 2) ? y : _alvo;
    curva_p = [x, y, _cx, _cy, _cx + cidade_dx(_nova) * _resto, _cy + cidade_dy(_nova) * _resto];
    // comprimento aproximado (amostrando a curva)
    curva_len = 0;
    var _ant = [x, y];
    for (var _i = 1; _i <= 8; _i++) {
        var _pt = curva_ponto(_i / 8);
        curva_len += point_distance(_ant[0], _ant[1], _pt[0], _pt[1]);
        _ant = _pt;
    }
    curva_len  = max(1, curva_len);
    curva_t    = 0;
    curva_de   = dir;
    curva_para = _nova;
    curva      = true;
};

/// ângulo de tela de cada direção (0 baixo, 1 esquerda, 2 direita, 3 cima)
dir_ang = function(_d) {
    switch (_d) { case 0: return 270; case 1: return 180; case 2: return 0; }
    return 90;
};

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
