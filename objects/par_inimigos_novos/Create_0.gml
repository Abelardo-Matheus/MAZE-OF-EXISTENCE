// feather disable GM2017
// ============================================================================
// PAI DOS INIMIGOS NOVOS
// Os filhos so precisam: event_inherited(); e depois mudar os valores abaixo
// e chamar inimigo_novo_aplicar_nivel() no final.
// ============================================================================
event_inherited();

// --- Sprites ---
sprite_normal = sprite_index;
sprite_parado = sprite_index;

// --- Atributos base (os filhos sobrescrevem) ---
vida = 10;
dano = 8;
veloc = 0.6;          // velocidade andando a toa
veloc_perse = 1.2;    // velocidade perseguindo
escala = 1;

// --- Area de deteccao ---
dist_aggro = 220;     // jogador entrou nesse raio -> persegue
dist_desaggro = 450;  // jogador passou desse raio -> desiste e volta
casa_x = x;
casa_y = y;
raio_patrulha = 120;

// --- Comportamento ---
comportamento = "perseguir";
atravessa = false;    // fantasmas e voadores ignoram paredes
voa = false;          // muda a sombra e faz o corpo flutuar
fase_voo = random(100);
alerta = 0;           // contador do "!" quando ve o jogador

// --- Tiro (comportamento "distancia") ---
sprite_tiro = spr_flecha_osso;
dist_tiro = 200;
cadencia_tiro = 90;
recarga_tiro = 60;
dano_tiro = 8;
vel_tiro = 4;
altura_tiro = 20;

// --- Investida ---
investida_timer = 0;
investida_dir = 0;
recarga_investida = 90;

// --- Extras ---
roubo_vida = 0;       // 1 = cura 100% do dano causado
transparencia = 1;    // fantasmas ficam meio transparentes
sombra_largura = 30;

state = scr_novo_escolher_estado;
alarm[0] = 1;

/// @desc Aplica o nivel da area (vindo do spawn virtual) e o tamanho final.
/// Chamar no FIM do Create de cada filho.
inimigo_novo_aplicar_nivel = function() {
    var _lvl = 1;
    if (variable_instance_exists(id, "lvl") && is_real(lvl) && lvl > 0) _lvl = lvl;
    lvl_inimigo = _lvl;
    vida = round(vida * (1 + (_lvl - 1) * 0.5));
    max_vida = vida;
    dano = dano + (_lvl - 1) * 2;
    escala = escala * (1 + (_lvl - 1) * 0.08);
    image_xscale = escala;
    image_yscale = escala;
    sprite_index = sprite_parado;
};
