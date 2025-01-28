var _damage = damage;
other.vida -= _damage;

var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.empurrar_dir = _dir;
other.empurrar_veloc = 4;
other.state = scr_inimigo_hit;
other.alarm[1] = 5;
other.hit = true;

var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = _damage;


// Dano no inimigo
with (other) {
    vida -= _damage; // Reduz a vida do inimigo em 10
}
