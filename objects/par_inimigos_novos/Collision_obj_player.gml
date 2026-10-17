// feather disable GM2017
// Usa o dano padrao do pai; morcego vampiro ainda recupera vida ao acertar
var _acertou = other.tomar_dano;
event_inherited();
if (_acertou && roubo_vida > 0) {
    vida = min(max_vida, vida + dano * roubo_vida);
}
