// feather disable GM2017
/// @desc Humano da cidade — anda aleatoriamente sem sair do bioma "cidade"
/// Criado pelo obj_otimizador a partir dos dados de gerar_humanos_para_bloco (scripts/spr_mundo).
/// Sprite: 16 frames = 4 direções x 4 passos (0-3 baixo, 4-7 esquerda, 8-11 direita, 12-15 cima).

// Lista de visuais (mesma ordem usada em gerar_humanos_para_bloco)
var _visuais = [
    spr_humano_vendedora, spr_humano_executivo, spr_humano_vovo,
    spr_humano_carteiro, spr_humano_padeiro, spr_humano_jardineira,
    spr_humano_lenhador, spr_humano_florista, spr_humano_vovozinho
];
if (!variable_instance_exists(id, "variante") || variante < 0) variante = irandom(array_length(_visuais) - 1);
variante = clamp(variante, 0, array_length(_visuais) - 1);
sprite_index = _visuais[variante];
image_speed  = 0;
image_index  = 0;

// Movimento
casa_x     = x;                 // ponto onde nasceu (âncora)
casa_y     = y;
raio_max   = 900;               // não se afasta mais do que isso da âncora
vel        = random_range(0.9, 1.4);
dir        = irandom(3);        // 0 baixo, 1 esquerda, 2 direita, 3 cima
estado     = "parado";          // "parado", "andando", "conversando"
timer      = irandom_range(20, 120);
alvo_x     = x;
alvo_y     = y;
anim       = 0;

// Conversa com o jogador
balao_timer = 0;
balao_texto = "";
frases = [
    "Olá, pequeno!", "Que dia bonito!", "Cuidado ao atravessar a rua!",
    "Já comeu sua fruta hoje?", "A vendedora tem coisas legais!",
    "Volte pra casa antes de escurecer.", "Você viu meu gato por aí?",
    "Que roupa legal a sua!", "Hoje tem bolo na padaria!",
    "Os monstros têm medo de gente corajosa.", "Bom dia! Ou boa tarde?",
    "Lave as mãos antes de comer!"
];
conversou = false;

/// Este ponto é um lugar onde o humano pode ficar?
ponto_valido = function(_x, _y) {
    if (point_distance(_x, _y, casa_x, casa_y) > raio_max) return false;
    if (terreno_bioma_em(_x, _y) != "cidade") return false;
    return true;
};

/// Escolhe um novo destino dentro da cidade
escolher_destino = function() {
    // na calçada: costuma seguir reto por ela (e atravessa na faixa de pedestre)
    var _aqui = cidade_tipo_em(x, y);
    if ((_aqui == CID_CALCADA || _aqui == CID_FAIXA) && random(1) < 0.65) {
        repeat (4) {
            var _d4 = irandom(3);
            var _dist = random_range(150, 600);
            var _sx = x + cidade_dx(_d4) * _dist;
            var _sy = y + cidade_dy(_d4) * _dist;
            if (ponto_valido(_sx, _sy) && cidade_tipo_em(_sx, _sy) != CID_RUA) {
                alvo_x = _sx; alvo_y = _sy;
                estado = "andando";
                timer  = irandom_range(300, 600);
                return true;
            }
        }
    }
    repeat (10) {
        var _a = random(360);
        var _d = random_range(70, 260);
        var _tx = x + lengthdir_x(_d, _a);
        var _ty = y + lengthdir_y(_d, _a);
        if (ponto_valido(_tx, _ty) && cidade_tipo_em(_tx, _ty) != CID_RUA && !collision_point(_tx, _ty, obj_estrutura, false, true)) {
            alvo_x = _tx; alvo_y = _ty;
            estado = "andando";
            timer  = irandom_range(180, 420);   // desiste se demorar demais
            return true;
        }
    }
    // não achou: volta um pouco na direção de casa
    alvo_x = lerp(x, casa_x, 0.5);
    alvo_y = lerp(y, casa_y, 0.5);
    estado = "andando";
    timer  = 200;
    return false;
};

/// Pode pisar em (_x, _y)? Não entra em casas/postes e não sai da cidade.
pode_pisar = function(_x, _y) {
    if (!ponto_valido(_x, _y)) return false;
    var _ja_dentro = place_meeting(x, y, obj_estrutura);   // nasceu encostado numa casa: deixa sair
    if (!_ja_dentro && place_meeting(_x, _y, obj_estrutura)) return false;
    if (place_meeting(_x, _y, obj_par_cenario)) return false;
    if (place_meeting(_x, _y, obj_carro_cidade)) return false;
    // rua só na faixa de pedestre (se já estiver na rua, pode sair dela)
    if (cidade_tipo_em(x, y) != CID_RUA && cidade_tipo_em(_x, _y) == CID_RUA) return false;
    return true;
};
