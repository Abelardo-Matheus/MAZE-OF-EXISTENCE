// feather disable GM2017
event_inherited();
vida = 10;
dano = 10;
state = scr_escolher_state_amoeba; // Usa o nome compatível que agora aponta para a lógica nova
sombra_sprite = spr_sombra;
if (!variable_instance_exists(id, "lvl")) lvl = 0; // 0 = nível da área (scr_progressao)

sprite_normal = spr_amoeba_verde;
sprite_parado = spr_amoeba_verde_parada;
hit = false;