other.vida_amoeba -= global.ataque;

var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.empurrar_dir = _dir;
other.empurrar_veloc = 30;
other.state = scr_amoeba_hit;
other.alarm[1] = 5;
other.hit = true;















