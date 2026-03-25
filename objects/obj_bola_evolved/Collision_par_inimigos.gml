// 1. SE FOR A BOLA FILHA (As 4 bolinhas menores)
if (eh_filho == true) 
{
    // Dá o dano, aplica os efeitos e se destrói (não vira torreta!)
    other.vida -= damage;
    
    var _dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);
    other.empurrar_dir = _dir;
    other.empurrar_veloc = push; 
    other.state = scr_inimigo_hit;
    other.alarm[1] = 5;
    other.hit = true;

    var _inst = instance_create_layer(x, y, "Instances", obj_dano);
    _inst.alvo = other;
    _inst.dano = damage;

    instance_destroy(); // SOME AO BATER!
}

// 2. SE FOR A BOLA PRINCIPAL (Vira a torreta)
else if (estado == "voando") 
{
    estado = "parado_atirando";
    speed = 0;          
    image_speed = 0;    
    image_index = 2;    

    other.vida -= damage;

    var _dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);
    other.empurrar_dir = _dir;
    other.empurrar_veloc = push;
    other.state = scr_inimigo_hit;
    other.alarm[1] = 5;
    other.hit = true;

    var _inst = instance_create_layer(x, y, "Instances", obj_dano);
    _inst.alvo = other;
    _inst.dano = damage;
}