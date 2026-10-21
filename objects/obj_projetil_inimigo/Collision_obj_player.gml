// feather disable GM2017
// Mesmo dano/knockback que o toque dos inimigos
if (other.tomar_dano) {
    var _dano = player_dano_recebido(dano); // defesa e esquiva (scripts/inventario)
    if (_dano <= 0) exit;
    with (other) {
        global.vida -= _dano;
        empurrar_dir = other.direction;
        hit = true;
        alarm[ALARM_KNOCKBACK] = 10;
        tomar_dano = false;
        alarm[ALARM_INVENCIBILIDADE] = 90;
        image_blend = c_red;
    }
    if (object_exists(obj_dano)) {
        var _inst = instance_create_layer(other.x, other.y - 30, "Instances", obj_dano);
        _inst.dano = _dano;
        _inst.cor = c_red;
    }
}
instance_destroy();
