// feather disable GM2017
event_inherited(); // IA (state), morte, XP e virar para o lado certo

if (!instance_exists(id)) exit;
if (alerta > 0) alerta--;

// Fantasmas piscam a transparencia
if (transparencia < 1) {
    image_alpha = transparencia + 0.15 * sin(current_time * 0.004 + fase_voo);
}
