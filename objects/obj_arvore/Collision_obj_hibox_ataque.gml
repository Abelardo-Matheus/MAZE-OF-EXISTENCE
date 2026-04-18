vida -= 10;
show_debug_message(vida);
var _quantis = choose(1, 2, 3, 4, 5, 6);
audio_play_sound(snd_damage, 1, false);
// --- ATIVA OS EFEITOS VISUAIS ---
tempo_piscar = 8;   // Quantidade de frames que vai ficar piscando
tempo_balancar = 15; // Quantidade de frames que vai ficar balançando
// --------------------------------

if (vida <= 0) {
    criar_drop_especifico(x, y, "Madeira", _quantis, 0);
    instance_destroy();
}