if (ds_list_find_index(hit_list, other.id) == -1) 
{
    // Dano
    other.vida -= damage;
    ds_list_add(hit_list, other.id);
    
    // Knockback
    if (push_force > 0) {
        var _dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);
        other.empurrar_dir = _dir;
        other.empurrar_veloc = push_force;
    }

    // Feedback
    other.state = scr_inimigo_hit;
    other.alarm[1] = 5;
    other.hit = true;
    
    var _txt = instance_create_layer(x, y, "Instances", obj_dano);
    _txt.alvo = other;
    _txt.dano = damage;
}