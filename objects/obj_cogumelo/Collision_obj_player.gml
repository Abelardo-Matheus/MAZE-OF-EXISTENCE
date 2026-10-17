// feather disable GM2017
var _acertou = other.tomar_dano;
event_inherited();      // dano padrao do obj_par_inimigos
if (_acertou && roubo_vida > 0) {
    vida = min(max_vida, vida + dano * roubo_vida); // morcego vampiro se cura
}
