// feather disable GM2017

/// @desc Sistema universal de dano para inimigos
/// @param _enemy A instância do inimigo que vai tomar dano
/// @param _damage Quantidade de dano
/// @param _knockback_force Força do empurrão
/// @param _knockback_dir Direção do empurrão
/// @param _is_crit Se o dano é crítico (opcional)
function scr_enemy_damage_apply(_enemy, _damage, _knockback_force, _knockback_dir, _is_crit = false) {
    if (!instance_exists(_enemy)) return;
    
    // 1. Aplica o dano
    _enemy.vida -= _damage;
    
    // 2. Aplica Knockback
    _enemy.empurrar_dir = _knockback_dir;
    _enemy.empurrar_veloc = _knockback_force;
    _enemy.hit = true;
    
    // Estado de hit (knockback). O Alarm 1 do inimigo encerra o hit e
    // volta hit = false (inimigo_ia_fim_hit / Alarm_1 do obj_par_inimigos).
    _enemy.state = scr_inimigo_hit;
    _enemy.alarm[1] = 5; // Tempo de stun/hit
    _enemy.alarm[2] = 180; // mostra a barra de vida

    // 3. Efeito visual: o flash branco é feito no Draw enquanto hit == true.
    // NÃO mexer em image_blend aqui (c_red escurecia o sprite e ficava preto).

    // 4. Cria o Popup de Dano
    var _dano_obj = asset_get_index("obj_dano");
    if (_dano_obj != -1) {
        var _inst = instance_create_layer(_enemy.x, _enemy.y, "instances", _dano_obj);
        _inst.alvo = _enemy;
        _inst.dano = _damage;
        
        if (_is_crit) {
            _inst.cor = c_red;
            var _fnt_crit = asset_get_index("fnt_dano_crit");
            if (_fnt_crit != -1) _inst.fonte = _fnt_crit;
        }
    }
    
    // 5. Som de Impacto
    var _snd = asset_get_index("snd_damage");
    if (_snd != -1) audio_play_sound(_snd, 1, false);
}
