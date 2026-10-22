damage = 0;
veloc = 0;
push_force = 2;

// Lâminas giras: controle de perfuração contra inimigos-instância
hit_set = {};
hit_reset = 0;

// Poderes novos (scr_ativos_infancia):
// perfura   -> atravessa inimigos (cada inimigo leva dano a cada HORDE_TICK_IFRAMES frames)
// ao_acertar -> method opcional chamado no primeiro acerto em vez do dano direto (ex.: bolha estoura em área)
perfura = false;
ao_acertar = undefined;

setup = function(_data) {
    damage = _data.damage;
    veloc = _data.speed;
    direction = _data.direction;
    sprite_index = _data.sprite;
    image_xscale = _data.size;
    image_yscale = _data.size;
    speed = veloc;
}
