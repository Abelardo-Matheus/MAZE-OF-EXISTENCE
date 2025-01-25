/// @description Move o objeto para trás antes de ir em direção ao jogador

if (distance_to_object(obj_player) <= global.coleta) {


        var _dir = point_direction(x, y, obj_player.x, obj_player.y);
        hspd = lengthdir_x(spd, _dir);
        vspd = lengthdir_y(spd, _dir);

        x += hspd;
        y += vspd;
    }

