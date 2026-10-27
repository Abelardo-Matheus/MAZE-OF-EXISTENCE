// feather disable GM2017

event_inherited();
sprite_normal = spr_esqueleto;
sprite_parado = spr_esqueleto_idle;
vida=10;
dano = 10; // Defina o dano deste inimigo
state = scr_escolher_state_amoeba;
sombra_sprite = spr_sombra;
if (!variable_instance_exists(id, "lvl")) lvl = 0; // 0 = nível da área (scr_progressao)
escala = 0.13 * sprite_ajuste(spr_esqueleto); // sprite refeito em 64x64
// Garante que comece no tamanho certo
image_xscale = escala;
image_yscale = escala;