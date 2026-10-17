damage = 0;
veloc = 0;
push_force = 2;

// Lâminas giras: controle de perfuração contra inimigos-instância
hit_set = {};
hit_reset = 0;

setup = function(_data) {
    damage = _data.damage;
    veloc = _data.speed;
    direction = _data.direction;
    sprite_index = _data.sprite;
    image_xscale = _data.size;
    image_yscale = _data.size;
    speed = veloc;
}
