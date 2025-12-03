/// @desc Aplica o "Tapa"
// Só causa dano se estiver no meio do Dash e ainda não tiver batido
if (state == "dash" && !has_hit) 
{
    // Marca que bateu
    has_hit = true; 
    
    // --- Dano e Empurrão ---
    other.vida -= damage;
    
    var _knock_dir = point_direction(x, y, other.x, other.y);
    other.empurrar_dir = _knock_dir;
    other.empurrar_veloc = 4; // Empurrão forte do tapa
    
    // Feedback
    other.state = scr_inimigo_hit;
    other.alarm[1] = 5;
    other.hit = true;
    
    // Texto de Dano
    var _txt = instance_create_layer(x, y, "Instances", obj_dano);
    _txt.alvo = other;
    _txt.dano = damage;
    
    // Opcional: Som de tapa
    // audio_play_sound(snd_slap, 1, false);
    
    // Opcional: Ao bater, o sapo pode parar ou recuar um pouco (Bounce back)
    speed = -2; 
    state = "cooldown";
    attack_cooldown_current = attack_cooldown_max;
}