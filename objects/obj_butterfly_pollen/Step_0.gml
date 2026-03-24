/// @description Dano e Feedback Visual

// 1. Aplica dano em área no primeiro frame de existência
if (!has_damaged && radius > 0) {
    has_damaged = true;
    
    // Cria uma lista temporária para guardar inimigos atingidos
    var _hit_list = ds_list_create();
    
    // Encontra todos os inimigos no raio de colisão esférica
    var _num_hit = collision_circle_list(x, y, radius, par_inimigos, false, true, _hit_list, false);
    
    // Aplica dano a cada inimigo na lista
    for (var i = 0; i < _num_hit; i++) {
        var _enemy = _hit_list[| i];
        
        // Aplica o dano (assumindo que seus inimigos têm vida e checam por colisões)
        // Se você usa o sistema de knockback/invencibilidade do player no inimigo,
        // use o script de dano que você já tem para inimigos. Ex:
        // with (_enemy) { vida -= other.damage; hit = true; empurrar_dir = point_direction(other.x, other.y, x, y); }
        
        // Exemplo simplificado de dano:
        if (variable_instance_exists(_enemy, "vida")) {
            _enemy.vida -= damage;
            // Opcional: Efeito de cor/hit no inimigo
            _enemy.image_blend = c_yellow; 
        }
    }
    
    // Cria um efeito visual (popup de dano se você tiver)
    // var _popup = instance_create_layer(x, y, "Instances", obj_dano);
    // _popup.dano = damage;
    // _popup.cor = c_yellow;

    // Destrói a lista temporária
    ds_list_destroy(_hit_list);
}

// 2. Feedback Visual e Destruição
// Faz o pólen sumir gradualmente
image_alpha -= 0.05; 

// Quando sumir totalmente, destrói o objeto
if (image_alpha <= 0) {
    instance_destroy();
}