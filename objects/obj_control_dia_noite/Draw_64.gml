// 1. Processa a renderização da surface de luzes primeiro
day_night_render();

// 2. Desenha a surface resultante na tela
if (surface_exists(global.day_night_cycle.overlay)) {
    draw_surface(global.day_night_cycle.overlay, 0, 0);
}
