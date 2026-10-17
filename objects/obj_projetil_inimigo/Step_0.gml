// feather disable GM2017
if (global.level_up == true) { image_speed = 0; exit; }
image_speed = 1;
depth = -y;

x += lengthdir_x(vel, direction);
y += lengthdir_y(vel, direction);
image_angle = gira ? image_angle + 8 : direction;

vida_util--;
if (vida_util <= 0) instance_destroy();
