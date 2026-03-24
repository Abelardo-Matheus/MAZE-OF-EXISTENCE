/// @description Inicializa Explosão de Pólen
damage = 0; // Definido pela borboleta
radius = 0; // Definido pela borboleta
image_alpha = 1; // Para o efeito de fade out

// Flag para garantir que dê dano apenas uma vez no primeiro frame
has_damaged = false;
escala_base = radius;
image_xscale = escala_base;
image_yscale = escala_base;